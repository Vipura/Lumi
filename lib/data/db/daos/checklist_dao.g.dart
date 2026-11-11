// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_dao.dart';

// ignore_for_file: type=lint
mixin _$ChecklistDaoMixin on DatabaseAccessor<LumiDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  $ChecklistEntriesTable get checklistEntries =>
      attachedDatabase.checklistEntries;
  ChecklistDaoManager get managers => ChecklistDaoManager(this);
}

class ChecklistDaoManager {
  final _$ChecklistDaoMixin _db;
  ChecklistDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$ChecklistEntriesTableTableManager get checklistEntries =>
      $$ChecklistEntriesTableTableManager(
        _db.attachedDatabase,
        _db.checklistEntries,
      );
}
