import 'package:flutter/foundation.dart';

import '../db/lumi_database.dart';

enum LumiItemType {
  note('note'),
  checklist('checklist'),
  sticky('sticky'),
  card('card');

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
  todo('todo', 'To do'),
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
