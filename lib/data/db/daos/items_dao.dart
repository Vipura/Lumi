import 'package:drift/drift.dart';

import '../lumi_database.dart';
import '../tables.dart';

part 'items_dao.g.dart';

@DriftAccessor(tables: [Items, ChecklistEntries, Tags, ItemTags, Attachments])
class ItemsDao extends DatabaseAccessor<LumiDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  Stream<List<Item>> watchActiveItems({
    String? type,
    List<String>? types,
    String? collectionId,
    String? tagId,
  }) {
    final query = select(items)
      ..where((t) => t.deletedAt.isNull() & t.archived.equals(false));

    if (type != null) {
      query.where((t) => t.type.equals(type));
    } else if (types != null && types.isNotEmpty) {
      query.where((t) => t.type.isIn(types));
    }
    if (collectionId != null) {
      query.where((t) => t.collectionId.equals(collectionId));
    }

    query.orderBy([
      (t) => OrderingTerm(expression: t.pinned, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
    ]);

    if (tagId == null) {
      return query.watch();
    }

    // Filter via ItemTags join reactively.
    final joined =
        select(items)
            .join([innerJoin(itemTags, itemTags.itemId.equalsExp(items.id))])
          ..where(
            items.deletedAt.isNull() &
                items.archived.equals(false) &
                itemTags.tagId.equals(tagId),
          );
    if (type != null) {
      joined.where(items.type.equals(type));
    }
    if (collectionId != null) {
      joined.where(items.collectionId.equals(collectionId));
    }
    joined.orderBy([
      OrderingTerm(expression: items.pinned, mode: OrderingMode.desc),
      OrderingTerm(expression: items.updatedAt, mode: OrderingMode.desc),
    ]);
    return joined.watch().map(
      (rows) => rows.map((row) => row.readTable(items)).toList(),
    );
  }

  Stream<List<Item>> watchPinnedItems() {
    return (select(items)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.archived.equals(false) &
                t.pinned.equals(true),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<Item>> watchArchivedItems() {
    return (select(items)
          ..where((t) => t.deletedAt.isNull() & t.archived.equals(true))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<Item>> watchTrashItems() {
    return (select(items)
          ..where((t) => t.deletedAt.isNotNull())
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.deletedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<Item>> watchStickyItems() {
    return (select(items)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.archived.equals(false) &
                t.type.equals('sticky'),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.stickyZ, mode: OrderingMode.asc),
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Stream<List<Item>> watchBoardItems() {
    return (select(items)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.archived.equals(false) &
                t.type.equals('card'),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.pinned, mode: OrderingMode.desc),
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<Item>> watchItemsInRange(DateTime start, DateTime end) {
    return (select(items)
          ..where(
            (t) =>
                t.deletedAt.isNull() &
                t.archived.equals(false) &
                t.dueDate.isBiggerOrEqualValue(start) &
                t.dueDate.isSmallerThanValue(end),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<Item?> watchItemById(String id) {
    return (select(items)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<Item?> getItemById(String id) {
    return (select(items)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Item>> getAllNonDeletedItems() {
    return (select(items)..where((t) => t.deletedAt.isNull())).get();
  }

  Future<void> upsertItem(ItemsCompanion companion) {
    return into(items).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteItem(String id) {
    return (update(items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        deletedAt: Value(DateTime.now()),
        pinned: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreItem(String id) {
    return (update(items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> permanentlyDeleteItem(String id) {
    return (delete(items)..where((t) => t.id.equals(id))).go();
  }

  Future<int> purgeExpiredTrash({
    Duration retention = const Duration(days: 30),
  }) {
    final cutoff = DateTime.now().subtract(retention);
    return (delete(items)..where(
          (t) =>
              t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }

  /// Searches across titles, plain text (FTS5 when available, else LIKE),
  /// checklist entries, tags, and attachment names.
  Future<List<Item>> searchItems(
    String rawQuery, {
    bool includeArchived = false,
  }) async {
    final trimmed = rawQuery.trim();
    if (trimmed.isEmpty) return const [];

    final matchedIds = <String>{};
    final likePattern = '%${trimmed.toLowerCase()}%';

    // 1. Try FTS5 for title + plainText first when available.
    var ftsSucceeded = false;
    if (db.ftsAvailable) {
      final ftsExpr = _buildFtsQuery(trimmed);
      if (ftsExpr != null) {
        try {
          final rows = await customSelect(
            'SELECT id FROM items_fts WHERE items_fts MATCH ?',
            variables: [Variable.withString(ftsExpr)],
          ).get();
          for (final row in rows) {
            matchedIds.add(row.read<String>('id'));
          }
          ftsSucceeded = true;
        } catch (_) {
          ftsSucceeded = false;
        }
      }
    }

    if (!ftsSucceeded) {
      final textRows =
          await (select(items)..where(
                (t) =>
                    t.title.lower().like(likePattern) |
                    t.plainText.lower().like(likePattern),
              ))
              .get();
      for (final item in textRows) {
        matchedIds.add(item.id);
      }
    }

    // 2. Match checklist entries.
    final entryRows = await (select(
      checklistEntries,
    )..where((e) => e.entryText.lower().like(likePattern))).get();
    for (final entry in entryRows) {
      matchedIds.add(entry.itemId);
    }

    // 3. Match tag names.
    final tagMatches = await (select(itemTags).join([
      innerJoin(tags, tags.id.equalsExp(itemTags.tagId)),
    ])..where(tags.name.lower().like(likePattern))).get();
    for (final row in tagMatches) {
      matchedIds.add(row.readTable(itemTags).itemId);
    }

    // 4. Match attachment names.
    final attachmentRows = await (select(
      attachments,
    )..where((a) => a.name.lower().like(likePattern))).get();
    for (final att in attachmentRows) {
      matchedIds.add(att.itemId);
    }

    if (matchedIds.isEmpty) return const [];

    final finalQuery = select(items)
      ..where((t) => t.id.isIn(matchedIds) & t.deletedAt.isNull());
    if (!includeArchived) {
      finalQuery.where((t) => t.archived.equals(false));
    }
    finalQuery.orderBy([
      (t) => OrderingTerm(expression: t.pinned, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
    ]);
    return finalQuery.get();
  }

  String? _buildFtsQuery(String raw) {
    final tokens = raw
        .split(RegExp(r'[^\p{L}\p{N}_]+', unicode: true))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return null;
    return tokens.map((t) => '"$t"*').join(' AND ');
  }
}
