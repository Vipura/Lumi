import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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
      'version': 1,
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
      'reminders': <dynamic>[],
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
    await targetDb.close();
  });
}
