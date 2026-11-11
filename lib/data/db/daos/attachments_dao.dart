import 'package:drift/drift.dart';

import '../lumi_database.dart';
import '../tables.dart';

part 'attachments_dao.g.dart';

@DriftAccessor(tables: [Attachments])
class AttachmentsDao extends DatabaseAccessor<LumiDatabase>
    with _$AttachmentsDaoMixin {
  AttachmentsDao(super.db);

  Stream<List<Attachment>> watchAttachmentsForItem(String itemId) {
    return (select(attachments)
          ..where((a) => a.itemId.equals(itemId))
          ..orderBy([
            (a) =>
                OrderingTerm(expression: a.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<Attachment>> watchAllAttachments() {
    return select(attachments).watch();
  }

  Future<List<Attachment>> getAttachmentsForItem(String itemId) {
    return (select(attachments)..where((a) => a.itemId.equals(itemId))).get();
  }

  Future<List<Attachment>> getAllAttachments() => select(attachments).get();

  Future<void> upsertAttachment(AttachmentsCompanion companion) {
    return into(attachments).insertOnConflictUpdate(companion);
  }

  Future<void> deleteAttachment(String id) {
    return (delete(attachments)..where((a) => a.id.equals(id))).go();
  }
}
