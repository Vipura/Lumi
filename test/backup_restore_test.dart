import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:lumi/data/db/lumi_database.dart';
import 'package:lumi/data/repositories/checklist_repository.dart';
import 'package:lumi/data/repositories/items_repository.dart';
import 'package:lumi/data/repositories/lumi_models.dart';
import 'package:lumi/data/repositories/organization_repository.dart';
import 'package:lumi/features/settings/backup_export_service.dart';

void main() {
  test('Backup restore imports JSON zip archive cleanly into Drift', () async {
    final sourceDb = LumiDatabase(NativeDatabase.memory());
    await sourceDb.organizationDao.getCollections();
    final itemsRepo = DriftItemsRepository(sourceDb);
    final checklistRepo = DriftChecklistRepository(sourceDb);
    final orgRepo = DriftOrganizationRepository(sourceDb);

    final item = await itemsRepo.createItem(
      type: LumiItemType.checklist,
      title: 'Trip Packing List',
      initialPlainText: 'Passport and camera',
      collectionId: 'col_personal',
    );
    await checklistRepo.addEntry(itemId: item.id, text: 'Pack charger');
    await orgRepo.addTagToItem(itemId: item.id, tagName: 'travel');

    // Build a valid backup zip payload matching exportFullBackupZip format.
    final payload = {
      'version': 2,
      'collections': [
        {
          'id': 'col_personal',
          'name': 'Personal',
          'iconName': 'person',
          'colorValue': 0xFFFF8A5B,
          'sortOrder': 0,
        },
      ],
      'tags': [
        {'id': 't1', 'name': 'travel', 'colorValue': null},
      ],
      'items': [
        {
          'id': item.id,
          'type': item.type,
          'title': item.title,
          'body': item.body,
          'plainText': item.plainText,
          'colorValue': item.colorValue,
          'pinned': item.pinned,
          'archived': item.archived,
          'deletedAt': null,
          'collectionId': item.collectionId,
          'boardStatus': item.boardStatus,
          'dueDate': null,
          'stickyX': null,
          'stickyY': null,
          'stickyW': null,
          'stickyH': null,
          'stickyZ': null,
          'createdAt': item.createdAt.toIso8601String(),
          'updatedAt': item.updatedAt.toIso8601String(),
        },
      ],
      'checklistEntries': [
        {
          'id': 'e1',
          'itemId': item.id,
          'text': 'Pack charger',
          'done': false,
          'sortOrder': 0,
          'parentId': null,
          'completedAt': null,
        },
      ],
      'reminders': [
        {
          'id': 'r1',
          'itemId': item.id,
          'entryId': null,
          'title': 'Check bags',
          'fireAt': DateTime(2026, 12, 1, 8, 30).toIso8601String(),
          'earlyReminderMinutes': 60,
          'repeatRule': 'none',
          'status': 'scheduled',
          'notificationId': 4242,
        },
      ],
      'itemTags': [
        {'itemId': item.id, 'tagId': 't1'},
      ],
      'attachments': <dynamic>[],
    };

    final jsonBytes = utf8.encode(jsonEncode(payload));
    final archive = Archive()
      ..addFile(ArchiveFile('lumi_backup.json', jsonBytes.length, jsonBytes));
    final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive));
    await sourceDb.close();

    final targetDb = LumiDatabase(NativeDatabase.memory());
    final backupService = LumiBackupExportService(targetDb);
    final restoredCount = await backupService.restoreBackupBytes(zipBytes);

    expect(restoredCount, 1);
    final restoredItem = await targetDb.itemsDao.getItemById(item.id);
    expect(restoredItem?.title, 'Trip Packing List');
    final restoredEntries = await targetDb.checklistDao.getEntriesForItem(
      item.id,
    );
    expect(restoredEntries.single.entryText, 'Pack charger');
    final restoredReminders = await targetDb.remindersDao
        .watchRemindersForItem(item.id)
        .first;
    expect(restoredReminders.single.title, 'Check bags');
    expect(restoredReminders.single.earlyReminderMinutes, 60);
    await targetDb.close();
  });

  test('PDF export embeds attached note images', () async {
    final db = LumiDatabase(NativeDatabase.memory());
    final itemsRepo = DriftItemsRepository(db);
    final service = LumiBackupExportService(db);

    final note = await itemsRepo.createItem(
      type: LumiItemType.note,
      title: 'Visual Trip Story',
      initialPlainText: 'Morning photo from the ridge.',
    );

    final pdfWithoutImage = await service.buildNotePdfBytes(note);
    expect(utf8.decode(pdfWithoutImage.take(5).toList()), '%PDF-');

    final tempDir = await Directory.systemTemp.createTemp('lumi_pdf_test_');
    try {
      final image = img.Image(width: 24, height: 24);
      img.fill(image, color: img.ColorRgb8(56, 189, 248));
      final pngFile = File('${tempDir.path}/sample.png');
      await pngFile.writeAsBytes(img.encodePng(image));

      await db.attachmentsDao.upsertAttachment(
        AttachmentsCompanion.insert(
          id: 'att_img_1',
          itemId: note.id,
          kind: 'image',
          path: pngFile.path,
          name: 'sample.png',
          createdAt: DateTime.now(),
        ),
      );

      final pdfWithImage = await service.buildNotePdfBytes(note);
      expect(utf8.decode(pdfWithImage.take(5).toList()), '%PDF-');
      expect(pdfWithImage.length, greaterThan(pdfWithoutImage.length + 100));
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      await db.close();
    }
  });
}
