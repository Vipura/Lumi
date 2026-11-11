import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/delta_utils.dart';
import '../db/lumi_database.dart';
import 'lumi_models.dart';

/// Pure reminder date calculations (easy to unit test cleanly).
abstract final class ReminderScheduleLogic {
  static DateTime computeNextOccurrence(DateTime from, LumiRepeatRule rule) {
    return switch (rule) {
      LumiRepeatRule.none => from,
      LumiRepeatRule.daily => from.add(const Duration(days: 1)),
      LumiRepeatRule.weekly => from.add(const Duration(days: 7)),
      LumiRepeatRule.monthly => _addOneMonthClamped(from),
    };
  }

  static DateTime computeSnoozeTarget(DateTime referenceNow, Duration offset) {
    return referenceNow.add(offset);
  }

  static DateTime? computeEarlyFireAt(
    DateTime fireAt,
    LumiEarlyReminder early,
  ) {
    return switch (early) {
      LumiEarlyReminder.none => null,
      LumiEarlyReminder.month1 => _subtractOneMonthClamped(fireAt),
      _ => fireAt.subtract(Duration(minutes: early.minutes)),
    };
  }

  static int earlyNotificationIdFor(String reminderId) =>
      DeltaUtils.deterministicNotificationId('${reminderId}_early');

  static DateTime _addOneMonthClamped(DateTime dt) {
    final nextMonth = dt.month == 12 ? 1 : dt.month + 1;
    final nextYear = dt.month == 12 ? dt.year + 1 : dt.year;
    final maxDaysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
    final clampedDay = dt.day > maxDaysInMonth ? maxDaysInMonth : dt.day;
    return DateTime(
      nextYear,
      nextMonth,
      clampedDay,
      dt.hour,
      dt.minute,
      dt.second,
    );
  }

  static DateTime _subtractOneMonthClamped(DateTime dt) {
    final prevMonth = dt.month == 1 ? 12 : dt.month - 1;
    final prevYear = dt.month == 1 ? dt.year - 1 : dt.year;
    final maxDaysInMonth = DateTime(prevYear, prevMonth + 1, 0).day;
    final clampedDay = dt.day > maxDaysInMonth ? maxDaysInMonth : dt.day;
    return DateTime(
      prevYear,
      prevMonth,
      clampedDay,
      dt.hour,
      dt.minute,
      dt.second,
    );
  }
}

abstract interface class RemindersRepository {
  Stream<List<Reminder>> watchScheduledReminders();
  Stream<List<Reminder>> watchAllNonCancelledReminders();
  Stream<List<Reminder>> watchRemindersForItem(String itemId);
  Stream<List<Reminder>> watchRemindersForDay(DateTime day);

  Future<Reminder> scheduleReminder({
    required String itemId,
    String? entryId,
    String title = '',
    required DateTime fireAt,
    LumiRepeatRule repeatRule = LumiRepeatRule.none,
    int earlyReminderMinutes = 0,
  });

  Future<Reminder?> updateReminder({
    required String id,
    String? title,
    required DateTime fireAt,
    LumiRepeatRule? repeatRule,
    int? earlyReminderMinutes,
  });

  Future<Reminder?> snoozeReminder(String id, Duration offset, {DateTime? now});
  Future<Reminder?> completeReminder(String id);
  Future<void> cancelReminder(String id);
  Future<void> deleteReminder(String id);
}

class DriftRemindersRepository implements RemindersRepository {
  DriftRemindersRepository(this._db, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final LumiDatabase _db;
  final Uuid _uuid;

  @override
  Stream<List<Reminder>> watchScheduledReminders() =>
      _db.remindersDao.watchScheduledReminders();

  @override
  Stream<List<Reminder>> watchAllNonCancelledReminders() =>
      _db.remindersDao.watchAllNonCancelledReminders();

  @override
  Stream<List<Reminder>> watchRemindersForItem(String itemId) =>
      _db.remindersDao.watchRemindersForItem(itemId);

  @override
  Stream<List<Reminder>> watchRemindersForDay(DateTime day) =>
      _db.remindersDao.watchRemindersForDay(day);

  @override
  Future<Reminder> scheduleReminder({
    required String itemId,
    String? entryId,
    String title = '',
    required DateTime fireAt,
    LumiRepeatRule repeatRule = LumiRepeatRule.none,
    int earlyReminderMinutes = 0,
  }) async {
    final id = _uuid.v4();
    final notificationId = DeltaUtils.deterministicNotificationId(id);

    await _db.remindersDao.upsertReminder(
      RemindersCompanion.insert(
        id: id,
        itemId: itemId,
        entryId: Value(entryId),
        title: Value(title.trim()),
        fireAt: fireAt,
        repeatRule: Value(repeatRule.dbValue),
        earlyReminderMinutes: Value(earlyReminderMinutes),
        status: Value(LumiReminderStatus.scheduled.dbValue),
        notificationId: notificationId,
      ),
    );
    return (await _db.remindersDao.getById(id))!;
  }

  @override
  Future<Reminder?> updateReminder({
    required String id,
    String? title,
    required DateTime fireAt,
    LumiRepeatRule? repeatRule,
    int? earlyReminderMinutes,
  }) async {
    final existing = await _db.remindersDao.getById(id);
    if (existing == null) return null;

    await _db.remindersDao.updateReminder(
      id,
      RemindersCompanion(
        title: title != null ? Value(title.trim()) : const Value.absent(),
        fireAt: Value(fireAt),
        repeatRule: repeatRule != null
            ? Value(repeatRule.dbValue)
            : const Value.absent(),
        earlyReminderMinutes: earlyReminderMinutes != null
            ? Value(earlyReminderMinutes)
            : const Value.absent(),
        status: Value(LumiReminderStatus.scheduled.dbValue),
      ),
    );

    if (title != null) {
      final parent = await _db.itemsDao.getItemById(existing.itemId);
      if (parent != null && parent.type == LumiItemType.reminder.dbValue) {
        await _db.itemsDao.upsertItem(
          parent
              .toCompanion(true)
              .copyWith(
                title: Value(title.trim()),
                dueDate: Value(fireAt),
                updatedAt: Value(DateTime.now()),
              ),
        );
      }
    }

    return _db.remindersDao.getById(id);
  }

  @override
  Future<Reminder?> snoozeReminder(
    String id,
    Duration offset, {
    DateTime? now,
  }) async {
    final existing = await _db.remindersDao.getById(id);
    if (existing == null) return null;
    final nextTime = ReminderScheduleLogic.computeSnoozeTarget(
      now ?? DateTime.now(),
      offset,
    );
    await _db.remindersDao.updateReminder(
      id,
      RemindersCompanion(
        fireAt: Value(nextTime),
        status: Value(LumiReminderStatus.snoozed.dbValue),
      ),
    );
    return _db.remindersDao.getById(id);
  }

  @override
  Future<Reminder?> completeReminder(String id) async {
    final existing = await _db.remindersDao.getById(id);
    if (existing == null) return null;
    final rule = LumiRepeatRule.fromDb(existing.repeatRule);
    if (rule == LumiRepeatRule.none) {
      await _db.remindersDao.updateReminder(
        id,
        RemindersCompanion(status: Value(LumiReminderStatus.done.dbValue)),
      );
    } else {
      final nextFireAt = ReminderScheduleLogic.computeNextOccurrence(
        existing.fireAt,
        rule,
      );
      await _db.remindersDao.updateReminder(
        id,
        RemindersCompanion(
          fireAt: Value(nextFireAt),
          status: Value(LumiReminderStatus.scheduled.dbValue),
        ),
      );
    }
    return _db.remindersDao.getById(id);
  }

  @override
  Future<void> cancelReminder(String id) async {
    await _db.remindersDao.updateReminder(
      id,
      RemindersCompanion(status: Value(LumiReminderStatus.cancelled.dbValue)),
    );
  }

  @override
  Future<void> deleteReminder(String id) => _db.remindersDao.deleteReminder(id);
}
