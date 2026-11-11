import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/core/utils/delta_utils.dart';
import 'package:lumi/data/db/lumi_database.dart';
import 'package:lumi/data/repositories/attachments_repository.dart';
import 'package:lumi/data/repositories/checklist_repository.dart';
import 'package:lumi/data/repositories/items_repository.dart';
import 'package:lumi/data/repositories/lumi_models.dart';
import 'package:lumi/data/repositories/organization_repository.dart';

void main() {
  late LumiDatabase db;
  late DriftItemsRepository itemsRepo;
  late DriftChecklistRepository checklistRepo;
  late DriftOrganizationRepository orgRepo;
  late DriftAttachmentsRepository attachmentsRepo;

  setUp(() async {
    db = LumiDatabase(NativeDatabase.memory());
    itemsRepo = DriftItemsRepository(db);
    checklistRepo = DriftChecklistRepository(db);
    orgRepo = DriftOrganizationRepository(db);
    attachmentsRepo = DriftAttachmentsRepository(db);
    // Ensure default collections seed on first query.
    await db.organizationDao.getCollections();
  });

  tearDown(() async {
    await db.close();
  });

  test('DeltaUtils extracts text, auto-titles, counts words, and exports Markdown', () {
    const delta =
        '[{"insert":"Morning thoughts\\n","attributes":{"header":1}},{"insert":"Drink water and plan."},{"insert":"\\n"}]';
    final plain = DeltaUtils.plainTextFromDeltaJson(delta);
    expect(plain, 'Morning thoughts\nDrink water and plan.');
    expect(DeltaUtils.wordCount(plain), 6);
    expect(
      DeltaUtils.deriveTitle(explicitTitle: '', plainText: plain),
      'Morning thoughts',
    );
    final md = DeltaUtils.markdownFromDeltaJson(delta);
    expect(md, contains('# Morning thoughts'));
    expect(md, contains('Drink water and plan.'));
  });

  test('ItemsRepository creates, updates, soft deletes, restores, and searches across entities', () async {
    final note = await itemsRepo.createItem(
      type: LumiItemType.note,
      initialPlainText: 'Architecture blueprint\nLiquid glass surfaces',
      collectionId: 'col_work',
    );
    expect(note.title, 'Architecture blueprint');

    await orgRepo.addTagToItem(itemId: note.id, tagName: 'design');
    await checklistRepo.addEntry(itemId: note.id, text: 'Buy espresso beans');
    await attachmentsRepo.addAttachment(
      itemId: note.id,
      kind: LumiAttachmentKind.pdf,
      path: '/tmp/roadmap.pdf',
      name: 'Q4_Roadmap.pdf',
    );

    // Search by title/body, checklist entry, tag, and attachment name.
    expect(
      (await itemsRepo.search('blueprint')).map((e) => e.id),
      contains(note.id),
    );
    expect(
      (await itemsRepo.search('espresso')).map((e) => e.id),
      contains(note.id),
    );
    expect(
      (await itemsRepo.search('design')).map((e) => e.id),
      contains(note.id),
    );
    expect(
      (await itemsRepo.search('Q4_Roadmap')).map((e) => e.id),
      contains(note.id),
    );

    // Soft delete hides from active search, restore brings it back.
    await itemsRepo.softDelete(note.id);
    expect(await itemsRepo.search('blueprint'), isEmpty);
    await itemsRepo.restore(note.id);
    expect((await itemsRepo.search('blueprint')).length, 1);
  });

  test('Default collections Personal, Work, and Study are seeded', () async {
    final cols = await db.organizationDao.getCollections();
    expect(cols.map((c) => c.name), containsAll(['Personal', 'Work', 'Study']));
  });
}
