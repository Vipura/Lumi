import 'package:drift/drift.dart';

import 'daos/attachments_dao.dart';
import 'daos/checklist_dao.dart';
import 'daos/items_dao.dart';
import 'daos/organization_dao.dart';
import 'daos/reminders_dao.dart';
import 'database_connection.dart';
import 'tables.dart';

part 'lumi_database.g.dart';

@DriftDatabase(
  tables: [
    Items,
    ChecklistEntries,
    Reminders,
    Attachments,
    Tags,
    ItemTags,
    Collections,
    ItemLinks,
  ],
  daos: [ItemsDao, ChecklistDao, RemindersDao, AttachmentsDao, OrganizationDao],
)
class LumiDatabase extends _$LumiDatabase {
  LumiDatabase([QueryExecutor? executor])
    : super(executor ?? openLumiConnection());

  bool ftsAvailable = false;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_items_type_updated '
        'ON items (type, updated_at DESC)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_items_due_date '
        'ON items (due_date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_checklist_item_order '
        'ON checklist_entries (item_id, sort_order)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_reminders_fire_status '
        'ON reminders (fire_at, status)',
      );
      await _ensureFts5();
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _probeFts5();
      await _seedDefaultCollections();
    },
  );

  Future<void> _ensureFts5() async {
    try {
      await customStatement(
        'CREATE VIRTUAL TABLE IF NOT EXISTS items_fts '
        'USING fts5(id UNINDEXED, title, plain_text)',
      );
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS items_fts_ai AFTER INSERT ON items BEGIN
          INSERT INTO items_fts (id, title, plain_text)
          VALUES (new.id, new.title, new.plain_text);
        END;
      ''');
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS items_fts_au AFTER UPDATE ON items BEGIN
          DELETE FROM items_fts WHERE id = old.id;
          INSERT INTO items_fts (id, title, plain_text)
          VALUES (new.id, new.title, new.plain_text);
        END;
      ''');
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS items_fts_ad AFTER DELETE ON items BEGIN
          DELETE FROM items_fts WHERE id = old.id;
        END;
      ''');
      ftsAvailable = true;
    } catch (_) {
      ftsAvailable = false;
    }
  }

  Future<void> _probeFts5() async {
    try {
      await customSelect('SELECT count(*) FROM items_fts').getSingle();
      ftsAvailable = true;
    } catch (_) {
      await _ensureFts5();
    }
  }

  Future<void> _seedDefaultCollections() async {
    final existing = await select(collections).get();
    if (existing.isNotEmpty) return;

    await batch((b) {
      b.insertAll(collections, [
        CollectionsCompanion.insert(
          id: 'col_personal',
          name: 'Personal',
          iconName: const Value('person'),
          colorValue: 0xFFFF8A5B,
          sortOrder: const Value(0),
        ),
        CollectionsCompanion.insert(
          id: 'col_work',
          name: 'Work',
          iconName: const Value('briefcase'),
          colorValue: 0xFF38BDF8,
          sortOrder: const Value(1),
        ),
        CollectionsCompanion.insert(
          id: 'col_study',
          name: 'Study',
          iconName: const Value('book'),
          colorValue: 0xFF8B5CF6,
          sortOrder: const Value(2),
        ),
      ]);
    });
  }
}
