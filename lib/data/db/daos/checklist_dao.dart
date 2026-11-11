import 'package:drift/drift.dart';

import '../lumi_database.dart';
import '../tables.dart';

part 'checklist_dao.g.dart';

@DriftAccessor(tables: [ChecklistEntries, Items])
class ChecklistDao extends DatabaseAccessor<LumiDatabase>
    with _$ChecklistDaoMixin {
  ChecklistDao(super.db);

  Stream<List<ChecklistEntry>> watchEntriesForItem(String itemId) {
    return (select(checklistEntries)
          ..where((e) => e.itemId.equals(itemId))
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.sortOrder, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<List<ChecklistEntry>> getEntriesForItem(String itemId) {
    return (select(checklistEntries)
          ..where((e) => e.itemId.equals(itemId))
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.sortOrder, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<void> upsertEntry(ChecklistEntriesCompanion companion) {
    return into(checklistEntries).insertOnConflictUpdate(companion);
  }

  Future<void> toggleEntry(String entryId, bool done) {
    return (update(checklistEntries)..where((e) => e.id.equals(entryId))).write(
      ChecklistEntriesCompanion(
        done: Value(done),
        completedAt: Value(done ? DateTime.now() : null),
      ),
    );
  }

  Future<void> deleteEntry(String entryId) {
    return transaction(() async {
      await (delete(
        checklistEntries,
      )..where((e) => e.parentId.equals(entryId))).go();
      await (delete(checklistEntries)..where((e) => e.id.equals(entryId))).go();
    });
  }

  Future<void> reorderEntries(List<String> orderedIds) async {
    await transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(checklistEntries)
              ..where((e) => e.id.equals(orderedIds[i])))
            .write(ChecklistEntriesCompanion(sortOrder: Value(i)));
      }
    });
  }

  /// Watches all checklist entries belonging to non-deleted, non-archived items.
  Stream<List<ChecklistEntry>> watchAllActiveEntries() {
    final query = select(checklistEntries).join([
      innerJoin(items, items.id.equalsExp(checklistEntries.itemId)),
    ])..where(items.deletedAt.isNull() & items.archived.equals(false));
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(checklistEntries)).toList(),
    );
  }

  /// Moves unfinished items/tasks due on or before [fromDayEnd] to [toDay].
  /// Returns the count of rolled-over items.
  Future<int> rolloverUnfinishedToDay({
    required DateTime fromDayEnd,
    required DateTime toDay,
  }) async {
    return transaction(() async {
      final candidates =
          await (select(items)..where(
                (t) =>
                    t.deletedAt.isNull() &
                    t.archived.equals(false) &
                    t.dueDate.isNotNull() &
                    t.dueDate.isSmallerThanValue(fromDayEnd) &
                    t.boardStatus.equals('done').not(),
              ))
              .get();

      var moved = 0;
      for (final item in candidates) {
        final entries = await getEntriesForItem(item.id);
        final hasUnfinishedEntries =
            entries.isEmpty || entries.any((e) => !e.done);
        if (!hasUnfinishedEntries) continue;

        final preservedTime = item.dueDate!;
        final nextDue = DateTime(
          toDay.year,
          toDay.month,
          toDay.day,
          preservedTime.hour,
          preservedTime.minute,
        );

        await (update(items)..where((t) => t.id.equals(item.id))).write(
          ItemsCompanion(
            dueDate: Value(nextDue),
            updatedAt: Value(DateTime.now()),
          ),
        );
        moved++;
      }
      return moved;
    });
  }
}
