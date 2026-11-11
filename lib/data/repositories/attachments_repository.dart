import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/lumi_database.dart';
import 'lumi_models.dart';

abstract interface class AttachmentsRepository {
  Stream<List<Attachment>> watchForItem(String itemId);
  Stream<List<Attachment>> watchAll();
  Future<List<Attachment>> getForItem(String itemId);

  Future<Attachment> addAttachment({
    required String itemId,
    required LumiAttachmentKind kind,
    required String path,
    required String name,
    int sizeBytes = 0,
    int? durationMs,
    Map<String, dynamic>? metadata,
  });

  Future<void> deleteAttachment(String id);
}

class DriftAttachmentsRepository implements AttachmentsRepository {
  DriftAttachmentsRepository(this._db, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final LumiDatabase _db;
  final Uuid _uuid;

  @override
  Stream<List<Attachment>> watchForItem(String itemId) =>
      _db.attachmentsDao.watchAttachmentsForItem(itemId);

  @override
  Stream<List<Attachment>> watchAll() =>
      _db.attachmentsDao.watchAllAttachments();

  @override
  Future<List<Attachment>> getForItem(String itemId) =>
      _db.attachmentsDao.getAttachmentsForItem(itemId);

  @override
  Future<Attachment> addAttachment({
    required String itemId,
    required LumiAttachmentKind kind,
    required String path,
    required String name,
    int sizeBytes = 0,
    int? durationMs,
    Map<String, dynamic>? metadata,
  }) async {
    final id = _uuid.v4();
    await _db.attachmentsDao.upsertAttachment(
      AttachmentsCompanion.insert(
        id: id,
        itemId: itemId,
        kind: kind.dbValue,
        path: path,
        name: name,
        sizeBytes: Value(sizeBytes),
        durationMs: Value(durationMs),
        metadataJson: Value(metadata == null ? null : jsonEncode(metadata)),
        createdAt: DateTime.now(),
      ),
    );
    await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
      ItemsCompanion(updatedAt: Value(DateTime.now())),
    );
    final all = await _db.attachmentsDao.getAttachmentsForItem(itemId);
    return all.firstWhere((a) => a.id == id);
  }

  @override
  Future<void> deleteAttachment(String id) =>
      _db.attachmentsDao.deleteAttachment(id);
}
