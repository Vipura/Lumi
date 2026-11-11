import 'package:flutter/foundation.dart';

import '../db/lumi_database.dart';

enum LumiItemType {
  note('note'),
  checklist('checklist'),
  sticky('sticky'),
  card('card'),
  reminder('reminder'),
  calm('calm');

  const LumiItemType(this.dbValue);
  final String dbValue;

  static LumiItemType fromDb(String value) {
    return values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => LumiItemType.note,
    );
  }
}

enum LumiBoardStatus {
  todo('todo', 'To Do'),
  doing('doing', 'Doing'),
  done('done', 'Done');

  const LumiBoardStatus(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static LumiBoardStatus fromDb(String value) {
    return values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => LumiBoardStatus.todo,
    );
  }
}

enum LumiRepeatRule {
  none('none', 'Once'),
  daily('daily', 'Daily'),
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly');

  const LumiRepeatRule(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static LumiRepeatRule fromDb(String value) {
    return values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => LumiRepeatRule.none,
    );
  }
}

enum LumiEarlyReminder {
  none(0, 'At event time', 'None'),
  min5(5, '5 minutes before', '5m early'),
  min10(10, '10 minutes before', '10m early'),
  min15(15, '15 minutes before', '15m early'),
  min30(30, '30 minutes before', '30m early'),
  hour1(60, '1 hour before', '1h early'),
  hour2(120, '2 hours before', '2h early'),
  day1(1440, '1 day before', '1d early'),
  day2(2880, '2 days before', '2d early'),
  week1(10080, '1 week before', '1w early'),
  week2(20160, '2 weeks before', '2w early'),
  month1(43200, '1 month before', '1mo early');

  const LumiEarlyReminder(this.minutes, this.label, this.shortLabel);
  final int minutes;
  final String label;
  final String shortLabel;

  static LumiEarlyReminder fromMinutes(int minutes) {
    return values.firstWhere(
      (e) => e.minutes == minutes,
      orElse: () => LumiEarlyReminder.none,
    );
  }
}

enum LumiReminderStatus {
  scheduled('scheduled'),
  done('done'),
  snoozed('snoozed'),
  cancelled('cancelled');

  const LumiReminderStatus(this.dbValue);
  final String dbValue;

  static LumiReminderStatus fromDb(String value) {
    return values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => LumiReminderStatus.scheduled,
    );
  }
}

enum LumiAttachmentKind {
  image('image'),
  pdf('pdf'),
  audio('audio'),
  file('file'),
  link('link');

  const LumiAttachmentKind(this.dbValue);
  final String dbValue;

  static LumiAttachmentKind fromDb(String value) {
    return values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => LumiAttachmentKind.file,
    );
  }
}

/// Composite read model for cards, Today rows, search results, and Planner.
@immutable
class LumiItemSummary {
  const LumiItemSummary({
    required this.item,
    this.tags = const [],
    this.checklistTotal = 0,
    this.checklistDone = 0,
    this.attachmentCount = 0,
    this.nextReminder,
    this.collection,
  });

  final Item item;
  final List<Tag> tags;
  final int checklistTotal;
  final int checklistDone;
  final int attachmentCount;
  final Reminder? nextReminder;
  final Collection? collection;

  LumiItemType get type => LumiItemType.fromDb(item.type);
  LumiBoardStatus get boardStatus => LumiBoardStatus.fromDb(item.boardStatus);

  double get checklistProgress => checklistTotal == 0
      ? 0.0
      : (checklistDone / checklistTotal).clamp(0.0, 1.0);
}

@immutable
class LumiTodayProgress {
  const LumiTodayProgress({
    required this.completedCount,
    required this.totalCount,
  });

  final int completedCount;
  final int totalCount;

  double get progress =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount).clamp(0.0, 1.0);
}
