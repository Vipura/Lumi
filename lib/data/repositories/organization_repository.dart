import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/lumi_database.dart';

abstract interface class OrganizationRepository {
  Stream<List<Collection>> watchCollections();
  Future<Collection> createCollection({
    required String name,
    String iconName = 'folder',
    int colorValue = 0xFFFF8A5B,
  });

  Stream<List<Tag>> watchTags();
  Stream<List<ItemTag>> watchAllItemTags();
  Stream<List<Tag>> watchTagsForItem(String itemId);

  Future<Tag> addTagToItem({
    required String itemId,
    required String tagName,
    int? colorValue,
  });

  Future<void> removeTagFromItem(String itemId, String tagId);
  Future<void> deleteTag(String tagId);

  Stream<List<Item>> watchBacklinks(String targetItemId);
  Future<void> linkItems(String sourceId, String targetId);
}

class DriftOrganizationRepository implements OrganizationRepository {
  DriftOrganizationRepository(this._db, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final LumiDatabase _db;
  final Uuid _uuid;

  @override
  Stream<List<Collection>> watchCollections() =>
      _db.organizationDao.watchCollections();

  @override
  Future<Collection> createCollection({
    required String name,
    String iconName = 'folder',
    int colorValue = 0xFFFF8A5B,
  }) async {
    final existing = await _db.organizationDao.getCollections();
    final id = _uuid.v4();
    await _db.organizationDao.upsertCollection(
      CollectionsCompanion.insert(
        id: id,
        name: name.trim(),
        iconName: Value(iconName),
        colorValue: colorValue,
        sortOrder: Value(existing.length),
      ),
    );
    final updated = await _db.organizationDao.getCollections();
    return updated.firstWhere((c) => c.id == id);
  }

  @override
  Stream<List<Tag>> watchTags() => _db.organizationDao.watchTags();

  @override
  Stream<List<ItemTag>> watchAllItemTags() =>
      _db.organizationDao.watchAllItemTags();

  @override
  Stream<List<Tag>> watchTagsForItem(String itemId) =>
      _db.organizationDao.watchTagsForItem(itemId);

  @override
  Future<Tag> addTagToItem({
    required String itemId,
    required String tagName,
    int? colorValue,
  }) async {
    final cleaned = tagName.trim().replaceAll('#', '');
    var tag = await _db.organizationDao.getTagByName(cleaned);
    if (tag == null) {
      final id = _uuid.v4();
      await _db.organizationDao.upsertTag(
        TagsCompanion.insert(
          id: id,
          name: cleaned,
          colorValue: Value(colorValue),
        ),
      );
      tag = (await _db.organizationDao.getTagByName(cleaned))!;
    }
    await _db.organizationDao.attachTagToItem(itemId, tag.id);
    return tag;
  }

  @override
  Future<void> removeTagFromItem(String itemId, String tagId) =>
      _db.organizationDao.detachTagFromItem(itemId, tagId);

  @override
  Future<void> deleteTag(String tagId) => _db.organizationDao.deleteTag(tagId);

  @override
  Stream<List<Item>> watchBacklinks(String targetItemId) =>
      _db.organizationDao.watchBacklinks(targetItemId);

  @override
  Future<void> linkItems(String sourceId, String targetId) =>
      _db.organizationDao.linkItems(sourceId, targetId);
}
