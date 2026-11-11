// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_dao.dart';

// ignore_for_file: type=lint
mixin _$ItemsDaoMixin on DatabaseAccessor<LumiDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  $ChecklistEntriesTable get checklistEntries =>
      attachedDatabase.checklistEntries;
  $TagsTable get tags => attachedDatabase.tags;
  $ItemTagsTable get itemTags => attachedDatabase.itemTags;
  $AttachmentsTable get attachments => attachedDatabase.attachments;
  ItemsDaoManager get managers => ItemsDaoManager(this);
}

class ItemsDaoManager {
  final _$ItemsDaoMixin _db;
  ItemsDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$ChecklistEntriesTableTableManager get checklistEntries =>
      $$ChecklistEntriesTableTableManager(
        _db.attachedDatabase,
        _db.checklistEntries,
      );
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$ItemTagsTableTableManager get itemTags =>
      $$ItemTagsTableTableManager(_db.attachedDatabase, _db.itemTags);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db.attachedDatabase, _db.attachments);
}
