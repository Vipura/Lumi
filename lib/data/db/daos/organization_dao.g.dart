// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_dao.dart';

// ignore_for_file: type=lint
mixin _$OrganizationDaoMixin on DatabaseAccessor<LumiDatabase> {
  $CollectionsTable get collections => attachedDatabase.collections;
  $TagsTable get tags => attachedDatabase.tags;
  $ItemsTable get items => attachedDatabase.items;
  $ItemTagsTable get itemTags => attachedDatabase.itemTags;
  $ItemLinksTable get itemLinks => attachedDatabase.itemLinks;
  OrganizationDaoManager get managers => OrganizationDaoManager(this);
}

class OrganizationDaoManager {
  final _$OrganizationDaoMixin _db;
  OrganizationDaoManager(this._db);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db.attachedDatabase, _db.collections);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$ItemTagsTableTableManager get itemTags =>
      $$ItemTagsTableTableManager(_db.attachedDatabase, _db.itemTags);
  $$ItemLinksTableTableManager get itemLinks =>
      $$ItemLinksTableTableManager(_db.attachedDatabase, _db.itemLinks);
}
