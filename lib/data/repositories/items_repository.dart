import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/delta_utils.dart';
import '../db/lumi_database.dart';
import 'lumi_models.dart';

abstract interface class ItemsRepository {
  Stream<List<Item>> watchActiveItems({
    LumiItemType? type,
    List<LumiItemType>? types,
    String? collectionId,
    String? tagId,
  });
  Stream<List<Item>> watchPinnedItems();
  Stream<List<Item>> watchArchivedItems();
  Stream<List<Item>> watchTrashItems();
  Stream<List<Item>> watchStickyItems();
  Stream<List<Item>> watchBoardItems();
  Stream<List<Item>> watchItemsInRange(DateTime start, DateTime end);
  Stream<Item?> watchItem(String id);
  Future<Item?> getItem(String id);

  Future<Item> createItem({
    required LumiItemType type,
    String title = '',
    String? bodyDeltaJson,
    String? initialPlainText,
    int? colorValue,
    bool pinned = false,
    String? collectionId,
    LumiBoardStatus boardStatus = LumiBoardStatus.todo,
    DateTime? dueDate,
    double? stickyX,
    double? stickyY,
    double? stickyW,
    double? stickyH,
    int? stickyZ,
  });

  Future<void> saveContent({
    required String id,
    required String title,
    required String bodyDeltaJson,
    bool autoDeriveTitle = true,
  });

  Future<void> updateMetadata({
    required String id,
    String? title,
    Value<int?>? colorValue,
    bool? pinned,
    bool? archived,
    Value<String?>? collectionId,
    LumiBoardStatus? boardStatus,
    Value<DateTime?>? dueDate,
    double? stickyX,
    double? stickyY,
    double? stickyW,
    double? stickyH,
    int? stickyZ,
  });

  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<void> permanentlyDelete(String id);
  Future<int> purgeExpiredTrash();
  Future<List<Item>> search(String query, {bool includeArchived = false});
}

class DriftItemsRepository implements ItemsRepository {
  DriftItemsRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final LumiDatabase _db;
  final Uuid _uuid;

  @override
  Stream<List<Item>> watchActiveItems({
    LumiItemType? type,
    List<LumiItemType>? types,
    String? collectionId,
    String? tagId,
  }) {
    return _db.itemsDao.watchActiveItems(
      type: type?.dbValue,
      types: types?.map((e) => e.dbValue).toList(),
      collectionId: collectionId,
      tagId: tagId,
    );
  }

  @override
  Stream<List<Item>> watchPinnedItems() => _db.itemsDao.watchPinnedItems();

  @override
  Stream<List<Item>> watchArchivedItems() => _db.itemsDao.watchArchivedItems();

  @override
  Stream<List<Item>> watchTrashItems() => _db.itemsDao.watchTrashItems();

  @override
  Stream<List<Item>> watchStickyItems() => _db.itemsDao.watchStickyItems();

  @override
  Stream<List<Item>> watchBoardItems() => _db.itemsDao.watchBoardItems();

  @override
  Stream<List<Item>> watchItemsInRange(DateTime start, DateTime end) =>
      _db.itemsDao.watchItemsInRange(start, end);

  @override
  Stream<Item?> watchItem(String id) => _db.itemsDao.watchItemById(id);

  @override
  Future<Item?> getItem(String id) => _db.itemsDao.getItemById(id);

  @override
  Future<Item> createItem({
    required LumiItemType type,
    String title = '',
    String? bodyDeltaJson,
    String? initialPlainText,
    int? colorValue,
    bool pinned = false,
    String? collectionId,
    LumiBoardStatus boardStatus = LumiBoardStatus.todo,
    DateTime? dueDate,
    double? stickyX,
    double? stickyY,
    double? stickyW,
    double? stickyH,
    int? stickyZ,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final delta =
        bodyDeltaJson ??
        (initialPlainText != null
            ? DeltaUtils.deltaJsonFromPlainText(initialPlainText)
            : DeltaUtils.emptyDeltaJson());
    final plain = DeltaUtils.plainTextFromDeltaJson(delta);
    final resolvedTitle = title.trim().isNotEmpty
        ? title.trim()
        : (plain.isNotEmpty
              ? DeltaUtils.deriveTitle(explicitTitle: '', plainText: plain)
              : '');

    final companion = ItemsCompanion.insert(
      id: id,
      type: type.dbValue,
      title: Value(resolvedTitle),
      body: Value(delta),
      plainText: Value(plain),
      colorValue: Value(colorValue),
      pinned: Value(pinned),
      archived: const Value(false),
      collectionId: Value(collectionId),
      boardStatus: Value(boardStatus.dbValue),
      dueDate: Value(dueDate),
      stickyX: Value(stickyX),
      stickyY: Value(stickyY),
      stickyW: Value(stickyW),
      stickyH: Value(stickyH),
      stickyZ: Value(stickyZ),
      createdAt: now,
      updatedAt: now,
    );

    await _db.itemsDao.upsertItem(companion);
    return (await _db.itemsDao.getItemById(id))!;
  }

  @override
  Future<void> saveContent({
    required String id,
    required String title,
    required String bodyDeltaJson,
    bool autoDeriveTitle = true,
  }) async {
    final existing = await _db.itemsDao.getItemById(id);
    if (existing == null) return;
    final plain = DeltaUtils.plainTextFromDeltaJson(bodyDeltaJson);
    final resolvedTitle = autoDeriveTitle
        ? DeltaUtils.deriveTitle(
            explicitTitle: title,
            plainText: plain,
            fallback: existing.type == LumiItemType.checklist.dbValue
                ? 'Checklist'
                : 'Untitled note',
          )
        : title.trim();

    await _db.itemsDao.upsertItem(
      existing
          .toCompanion(true)
          .copyWith(
            title: Value(resolvedTitle),
            body: Value(bodyDeltaJson),
            plainText: Value(plain),
            updatedAt: Value(DateTime.now()),
          ),
    );
  }

  @override
  Future<void> updateMetadata({
    required String id,
    String? title,
    Value<int?>? colorValue,
    bool? pinned,
    bool? archived,
    Value<String?>? collectionId,
    LumiBoardStatus? boardStatus,
    Value<DateTime?>? dueDate,
    double? stickyX,
    double? stickyY,
    double? stickyW,
    double? stickyH,
    int? stickyZ,
  }) async {
    final existing = await _db.itemsDao.getItemById(id);
    if (existing == null) return;
    await _db.itemsDao.upsertItem(
      existing
          .toCompanion(true)
          .copyWith(
            title: title != null ? Value(title) : const Value.absent(),
            colorValue: colorValue ?? const Value.absent(),
            pinned: pinned != null ? Value(pinned) : const Value.absent(),
            archived: archived != null ? Value(archived) : const Value.absent(),
            collectionId: collectionId ?? const Value.absent(),
            boardStatus: boardStatus != null
                ? Value(boardStatus.dbValue)
                : const Value.absent(),
            dueDate: dueDate ?? const Value.absent(),
            stickyX: stickyX != null ? Value(stickyX) : const Value.absent(),
            stickyY: stickyY != null ? Value(stickyY) : const Value.absent(),
            stickyW: stickyW != null ? Value(stickyW) : const Value.absent(),
            stickyH: stickyH != null ? Value(stickyH) : const Value.absent(),
            stickyZ: stickyZ != null ? Value(stickyZ) : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
    );
  }

  @override
  Future<void> softDelete(String id) => _db.itemsDao.softDeleteItem(id);

  @override
  Future<void> restore(String id) => _db.itemsDao.restoreItem(id);

  @override
  Future<void> permanentlyDelete(String id) =>
      _db.itemsDao.permanentlyDeleteItem(id);

  @override
  Future<int> purgeExpiredTrash() => _db.itemsDao.purgeExpiredTrash();

  @override
  Future<List<Item>> search(String query, {bool includeArchived = false}) =>
      _db.itemsDao.searchItems(query, includeArchived: includeArchived);
}
