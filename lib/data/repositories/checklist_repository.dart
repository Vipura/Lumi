import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/lumi_database.dart';

abstract interface class ChecklistRepository {
  Stream<List<ChecklistEntry>> watchEntries(String itemId);
  Stream<List<ChecklistEntry>> watchAllActiveEntries();
  Future<List<ChecklistEntry>> getEntries(String itemId);

  Future<ChecklistEntry> addEntry({
    required String itemId,
    required String text,
    String? parentId,
  });

  Future<void> updateEntryText(String entryId, String text);
  Future<void> toggleEntry(String entryId, bool done);
  Future<void> deleteEntry(String entryId);
  Future<void> reorderEntries(List<String> orderedIds);

  /// Moves unfinished tasks due on or before [fromDate] to [toDate] (default tomorrow).
  Future<int> rolloverUnfinishedTasks({DateTime? fromDate, DateTime? toDate});
}

class DriftChecklistRepository implements ChecklistRepository {
  DriftChecklistRepository(this._db, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final LumiDatabase _db;
  final Uuid _uuid;

  @override
  Stream<List<ChecklistEntry>> watchEntries(String itemId) =>
      _db.checklistDao.watchEntriesForItem(itemId);

  @override
  Stream<List<ChecklistEntry>> watchAllActiveEntries() =>
      _db.checklistDao.watchAllActiveEntries();

  @override
  Future<List<ChecklistEntry>> getEntries(String itemId) =>
      _db.checklistDao.getEntriesForItem(itemId);

  @override
  Future<ChecklistEntry> addEntry({
    required String itemId,
    required String text,
    String? parentId,
  }) async {
    final existing = await _db.checklistDao.getEntriesForItem(itemId);
    final id = _uuid.v4();
    final sortOrder = existing.isEmpty
        ? 0
        : existing.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    await _db.checklistDao.upsertEntry(
      ChecklistEntriesCompanion.insert(
        id: id,
        itemId: itemId,
        entryText: text.trim(),
        done: const Value(false),
        sortOrder: Value(sortOrder),
        parentId: Value(parentId),
      ),
    );
    await _touchItem(itemId);
    final updated = await _db.checklistDao.getEntriesForItem(itemId);
    return updated.firstWhere((e) => e.id == id);
  }

  @override
  Future<void> updateEntryText(String entryId, String text) async {
    final entries = await (_db.select(
      _db.checklistEntries,
    )..where((e) => e.id.equals(entryId))).get();
    if (entries.isEmpty) return;
    final entry = entries.first;
    await _db.checklistDao.upsertEntry(
      entry.toCompanion(true).copyWith(entryText: Value(text)),
    );
    await _touchItem(entry.itemId);
  }

  @override
  Future<void> toggleEntry(String entryId, bool done) async {
    final entries = await (_db.select(
      _db.checklistEntries,
    )..where((e) => e.id.equals(entryId))).get();
    if (entries.isEmpty) return;
    await _db.checklistDao.toggleEntry(entryId, done);
    await _touchItem(entries.first.itemId);
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    final entries = await (_db.select(
      _db.checklistEntries,
    )..where((e) => e.id.equals(entryId))).get();
    await _db.checklistDao.deleteEntry(entryId);
    if (entries.isNotEmpty) {
      await _touchItem(entries.first.itemId);
    }
  }

  @override
  Future<void> reorderEntries(List<String> orderedIds) async {
    await _db.checklistDao.reorderEntries(orderedIds);
  }

  @override
  Future<int> rolloverUnfinishedTasks({DateTime? fromDate, DateTime? toDate}) {
    final now = fromDate ?? DateTime.now();
    final todayEnd = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final tomorrow =
        toDate ??
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    return _db.checklistDao.rolloverUnfinishedToDay(
      fromDayEnd: todayEnd,
      toDay: tomorrow,
    );
  }

  Future<void> _touchItem(String itemId) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
      ItemsCompanion(updatedAt: Value(DateTime.now())),
    );
  }
}
