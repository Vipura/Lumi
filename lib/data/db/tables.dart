import 'package:drift/drift.dart';

/// Core items table supporting notes, checklists, sticky notes, board cards,
/// standalone reminders, and Calm Space entries.
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get type =>
      text()(); // note | checklist | sticky | card | reminder | calm
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body =>
      text().withDefault(const Constant('[{"insert":"\\n"}]'))();
  TextColumn get plainText => text().withDefault(const Constant(''))();
  IntColumn get colorValue => integer().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get collectionId => text().nullable()();
  TextColumn get boardStatus => text().withDefault(const Constant('todo'))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  RealColumn get stickyX => real().nullable()();
  RealColumn get stickyY => real().nullable()();
  RealColumn get stickyW => real().nullable()();
  RealColumn get stickyH => real().nullable()();
  IntColumn get stickyZ => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Nested checklist entries linked to an Item.
class ChecklistEntries extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get entryText => text().named('text')();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get parentId => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Scheduled local reminders attached to an Item or specific ChecklistEntry.
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get entryId => text().nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get fireAt => dateTime()();
  TextColumn get repeatRule => text().withDefault(const Constant('none'))();
  IntColumn get earlyReminderMinutes =>
      integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  IntColumn get notificationId => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local files, images, PDFs, voice recordings, and link previews.
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => text()(); // image | pdf | audio | file | link
  TextColumn get path => text()();
  TextColumn get name => text()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get metadataJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// User tags.
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  IntColumn get colorValue => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Many-to-many join between Items and Tags.
class ItemTags extends Table {
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {itemId, tagId};
}

/// Collections such as Personal, Work, Study.
class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconName => text().withDefault(const Constant('folder'))();
  IntColumn get colorValue => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Directed item links for future backlinks.
class ItemLinks extends Table {
  TextColumn get sourceItemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  TextColumn get targetItemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {sourceItemId, targetItemId};
}
