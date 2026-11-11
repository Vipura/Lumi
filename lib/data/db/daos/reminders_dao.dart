import 'package:drift/drift.dart';

import '../lumi_database.dart';
import '../tables.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [Reminders, Items])
class RemindersDao extends DatabaseAccessor<LumiDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  Stream<List<Reminder>> watchScheduledReminders() {
    final query =
        select(reminders)
            .join([innerJoin(items, items.id.equalsExp(reminders.itemId))])
          ..where(
            items.deletedAt.isNull() &
                (reminders.status.equals('scheduled') |
                    reminders.status.equals('snoozed')),
          )
          ..orderBy([
            OrderingTerm(expression: reminders.fireAt, mode: OrderingMode.asc),
          ]);
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(reminders)).toList(),
    );
  }

  Stream<List<Reminder>> watchRemindersForItem(String itemId) {
    return (select(reminders)
          ..where((r) => r.itemId.equals(itemId))
          ..orderBy([
            (r) => OrderingTerm(expression: r.fireAt, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Stream<List<Reminder>> watchRemindersForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final query =
        select(reminders)
            .join([innerJoin(items, items.id.equalsExp(reminders.itemId))])
          ..where(
            items.deletedAt.isNull() &
                reminders.fireAt.isBiggerOrEqualValue(start) &
                reminders.fireAt.isSmallerThanValue(end) &
                reminders.status.equals('cancelled').not(),
          )
          ..orderBy([
            OrderingTerm(expression: reminders.fireAt, mode: OrderingMode.asc),
          ]);
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(reminders)).toList(),
    );
  }

  Future<Reminder?> getById(String id) {
    return (select(reminders)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  Future<List<Reminder>> getAllReminders() => select(reminders).get();

  Future<void> upsertReminder(RemindersCompanion companion) {
    return into(reminders).insertOnConflictUpdate(companion);
  }

  Future<void> updateReminder(String id, RemindersCompanion companion) {
    return (update(reminders)..where((r) => r.id.equals(id))).write(companion);
  }

  Future<void> deleteReminder(String id) {
    return (delete(reminders)..where((r) => r.id.equals(id))).go();
  }
}
