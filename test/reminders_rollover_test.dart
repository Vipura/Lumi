import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/data/db/lumi_database.dart';
import 'package:lumi/data/repositories/checklist_repository.dart';
import 'package:lumi/data/repositories/items_repository.dart';
import 'package:lumi/data/repositories/lumi_models.dart';
import 'package:lumi/data/repositories/reminders_repository.dart';

void main() {
  late LumiDatabase db;
  late DriftItemsRepository itemsRepo;
  late DriftChecklistRepository checklistRepo;
  late DriftRemindersRepository remindersRepo;

  setUp(() async {
    db = LumiDatabase(NativeDatabase.memory());
    itemsRepo = DriftItemsRepository(db);
    checklistRepo = DriftChecklistRepository(db);
    remindersRepo = DriftRemindersRepository(db);
    await db.organizationDao.getCollections();
  });

  tearDown(() async {
    await db.close();
  });

  test('ReminderScheduleLogic calculates daily, weekly, and clamped monthly repeats', () {
    final jan31 = DateTime(2026, 1, 31, 9, 30);
    expect(
      ReminderScheduleLogic.computeNextOccurrence(jan31, LumiRepeatRule.daily),
      DateTime(2026, 2, 1, 9, 30),
    );
    expect(
      ReminderScheduleLogic.computeNextOccurrence(jan31, LumiRepeatRule.weekly),
      DateTime(2026, 2, 7, 9, 30),
    );
    // 2026 is not a leap year -> Feb has 28 days.
    expect(
      ReminderScheduleLogic.computeNextOccurrence(
        jan31,
        LumiRepeatRule.monthly,
      ),
      DateTime(2026, 2, 28, 9, 30),
    );
  });

  test('ReminderScheduleLogic computes early reminder timestamps cleanly', () {
    final target = DateTime(2026, 3, 30, 14, 0);
    expect(
      ReminderScheduleLogic.computeEarlyFireAt(target, LumiEarlyReminder.none),
      isNull,
    );
    expect(
      ReminderScheduleLogic.computeEarlyFireAt(target, LumiEarlyReminder.min5),
      DateTime(2026, 3, 30, 13, 55),
    );
    expect(
      ReminderScheduleLogic.computeEarlyFireAt(target, LumiEarlyReminder.hour1),
      DateTime(2026, 3, 30, 13, 0),
    );
    expect(
      ReminderScheduleLogic.computeEarlyFireAt(target, LumiEarlyReminder.day1),
      DateTime(2026, 3, 29, 14, 0),
    );
    // Clamps March 30 - 1 month to February 28 in non-leap year 2026.
    expect(
      ReminderScheduleLogic.computeEarlyFireAt(
        target,
        LumiEarlyReminder.month1,
      ),
      DateTime(2026, 2, 28, 14, 0),
    );
  });

  test('RemindersRepository updates reminder time, title, and early alert in-place', () async {
    final item = await itemsRepo.createItem(
      type: LumiItemType.reminder,
      title: 'Original title',
      dueDate: DateTime(2026, 11, 15, 9, 0),
    );
    final created = await remindersRepo.scheduleReminder(
      itemId: item.id,
      title: 'Original title',
      fireAt: DateTime(2026, 11, 15, 9, 0),
      earlyReminderMinutes: LumiEarlyReminder.min15.minutes,
      repeatRule: LumiRepeatRule.none,
    );

    final updated = await remindersRepo.updateReminder(
      id: created.id,
      title: 'Updated dentist visit',
      fireAt: DateTime(2026, 11, 16, 16, 45),
      repeatRule: LumiRepeatRule.weekly,
      earlyReminderMinutes: LumiEarlyReminder.hour1.minutes,
    );

    expect(updated?.id, created.id);
    expect(updated?.title, 'Updated dentist visit');
    expect(updated?.fireAt, DateTime(2026, 11, 16, 16, 45));
    expect(updated?.repeatRule, LumiRepeatRule.weekly.dbValue);
    expect(updated?.earlyReminderMinutes, 60);

    final refreshedParent = await itemsRepo.getItem(item.id);
    expect(refreshedParent?.title, 'Updated dentist visit');
    expect(refreshedParent?.dueDate, DateTime(2026, 11, 16, 16, 45));
  });

  test('RemindersRepository snoozes and advances repeating reminders on completion', () async {
    final item = await itemsRepo.createItem(
      type: LumiItemType.note,
      title: 'Water plants',
    );
    final start = DateTime(2026, 11, 10, 8, 0);
    final reminder = await remindersRepo.scheduleReminder(
      itemId: item.id,
      fireAt: start,
      repeatRule: LumiRepeatRule.daily,
    );

    final snoozed = await remindersRepo.snoozeReminder(
      reminder.id,
      const Duration(minutes: 15),
      now: start,
    );
    expect(snoozed?.status, LumiReminderStatus.snoozed.dbValue);
    expect(snoozed?.fireAt, DateTime(2026, 11, 10, 8, 15));

    final completed = await remindersRepo.completeReminder(reminder.id);
    expect(completed?.status, LumiReminderStatus.scheduled.dbValue);
    expect(completed?.fireAt, DateTime(2026, 11, 11, 8, 15));
  });

  test('ChecklistRepository rolls over unfinished tasks to tomorrow and keeps done ones', () async {
    final today = DateTime(2026, 11, 10, 14, 0);
    final tomorrow = DateTime(2026, 11, 11);

    final unfinished = await itemsRepo.createItem(
      type: LumiItemType.checklist,
      title: 'Unfinished errands',
      dueDate: today,
    );
    await checklistRepo.addEntry(itemId: unfinished.id, text: 'Mail parcel');

    final finished = await itemsRepo.createItem(
      type: LumiItemType.checklist,
      title: 'Finished errands',
      dueDate: today,
    );
    final doneEntry = await checklistRepo.addEntry(
      itemId: finished.id,
      text: 'Morning stretch',
    );
    await checklistRepo.toggleEntry(doneEntry.id, true);

    final movedCount = await checklistRepo.rolloverUnfinishedTasks(
      fromDate: today,
      toDate: tomorrow,
    );

    expect(movedCount, 1);

    final refreshedUnfinished = await itemsRepo.getItem(unfinished.id);
    final refreshedFinished = await itemsRepo.getItem(finished.id);
    expect(refreshedUnfinished?.dueDate?.day, 11);
    expect(refreshedFinished?.dueDate?.day, 10);
  });
}
