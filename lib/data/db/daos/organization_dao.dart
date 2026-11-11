import 'package:drift/drift.dart';

import '../lumi_database.dart';
import '../tables.dart';

part 'organization_dao.g.dart';

@DriftAccessor(tables: [Collections, Tags, ItemTags, ItemLinks, Items])
class OrganizationDao extends DatabaseAccessor<LumiDatabase>
    with _$OrganizationDaoMixin {
  OrganizationDao(super.db);

  Stream<List<Collection>> watchCollections() {
    return (select(collections)..orderBy([
          (c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.asc),
        ]))
        .watch();
  }

  Future<List<Collection>> getCollections() {
    return (select(collections)..orderBy([
          (c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.asc),
        ]))
        .get();
  }

  Future<void> upsertCollection(CollectionsCompanion companion) {
    return into(collections).insertOnConflictUpdate(companion);
  }

  Stream<List<Tag>> watchTags() {
    return (select(tags)..orderBy([
          (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
        ]))
        .watch();
  }

  Future<List<Tag>> getAllTags() => select(tags).get();

  Stream<List<ItemTag>> watchAllItemTags() => select(itemTags).watch();

  Future<List<ItemTag>> getAllItemTags() => select(itemTags).get();

  Stream<List<Tag>> watchTagsForItem(String itemId) {
    final query =
        select(tags)
            .join([innerJoin(itemTags, itemTags.tagId.equalsExp(tags.id))])
          ..where(itemTags.itemId.equals(itemId))
          ..orderBy([
            OrderingTerm(expression: tags.name, mode: OrderingMode.asc),
          ]);
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(tags)).toList(),
    );
  }

  Future<Tag?> getTagByName(String name) {
    return (select(tags)
          ..where((t) => t.name.lower().equals(name.trim().toLowerCase())))
        .getSingleOrNull();
  }

  Future<void> upsertTag(TagsCompanion companion) {
    return into(tags).insertOnConflictUpdate(companion);
  }

  Future<void> attachTagToItem(String itemId, String tagId) {
    return into(itemTags).insertOnConflictUpdate(
      ItemTagsCompanion.insert(itemId: itemId, tagId: tagId),
    );
  }

  Future<void> detachTagFromItem(String itemId, String tagId) {
    return (delete(
      itemTags,
    )..where((it) => it.itemId.equals(itemId) & it.tagId.equals(tagId))).go();
  }

  Future<void> deleteTag(String tagId) {
    return (delete(tags)..where((t) => t.id.equals(tagId))).go();
  }

  Stream<List<Item>> watchBacklinks(String targetItemId) {
    final query =
        select(items).join([
          innerJoin(itemLinks, itemLinks.sourceItemId.equalsExp(items.id)),
        ])..where(
          itemLinks.targetItemId.equals(targetItemId) &
              items.deletedAt.isNull(),
        );
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(items)).toList(),
    );
  }

  Future<void> linkItems(String sourceId, String targetId) {
    return into(itemLinks).insertOnConflictUpdate(
      ItemLinksCompanion.insert(sourceItemId: sourceId, targetItemId: targetId),
    );
  }
}
