import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/design/lumi_tokens.dart';
import '../db/lumi_database.dart';
import 'checklist_repository.dart';
import 'items_repository.dart';
import 'lumi_models.dart';
import 'organization_repository.dart';
import 'reminders_repository.dart';

/// Seeds realistic first-launch sample items once behind an explicit dev flag.
abstract final class SampleSeedHelper {
  static const seedKey = 'lumi.dev.sample_seeded_v1';

  static Future<void> seedIfFirstLaunch({
    required LumiDatabase db,
    required SharedPreferences prefs,
  }) async {
    if (prefs.getBool(seedKey) ?? false) return;

    final existingItems = await db.itemsDao.getAllNonDeletedItems();
    if (existingItems.isNotEmpty) {
      await prefs.setBool(seedKey, true);
      return;
    }

    final itemsRepo = DriftItemsRepository(db);
    final checklistRepo = DriftChecklistRepository(db);
    final orgRepo = DriftOrganizationRepository(db);
    final remindersRepo = DriftRemindersRepository(db);

    final now = DateTime.now();
    final todayNoon = DateTime(now.year, now.month, now.day, 12, 0);
    final eveningReminder = DateTime(now.year, now.month, now.day, 18, 30);

    final welcomeBody = jsonEncode([
      {
        'insert': 'Welcome to Lumi\n',
        'attributes': {'header': 1},
      },
      {
        'insert': 'A calm, luminous desk for everything worth remembering — notes, nested checklists, reminders, and sticky thoughts.\n\n',
      },
      {
        'insert': 'Try these in under 10 seconds:\n',
        'attributes': {'bold': true},
      },
      {'insert': 'Tap the glowing + button below to capture instantly'},
      {
        'insert': '\n',
        'attributes': {'list': 'bullet'},
      },
      {'insert': 'Pin key thoughts to keep them at the top of Today'},
      {
        'insert': '\n',
        'attributes': {'list': 'bullet'},
      },
      {'insert': 'Arrange bright reminders on the free-form Sticky Wall'},
      {
        'insert': '\n',
        'attributes': {'list': 'bullet'},
      },
    ]);

    final welcomeNote = await itemsRepo.createItem(
      type: LumiItemType.note,
      title: 'Welcome to Lumi',
      bodyDeltaJson: welcomeBody,
      pinned: true,
      collectionId: 'col_personal',
      boardStatus: LumiBoardStatus.doing,
    );
    await orgRepo.addTagToItem(itemId: welcomeNote.id, tagName: 'welcome');
    await orgRepo.addTagToItem(itemId: welcomeNote.id, tagName: 'guide');

    final checklist = await itemsRepo.createItem(
      type: LumiItemType.checklist,
      title: 'Morning Focus Ritual',
      pinned: true,
      collectionId: 'col_personal',
      dueDate: todayNoon,
      boardStatus: LumiBoardStatus.doing,
    );
    final step1 = await checklistRepo.addEntry(
      itemId: checklist.id,
      text: 'Review top 3 priorities for today',
    );
    await checklistRepo.toggleEntry(step1.id, true);
    final step2 = await checklistRepo.addEntry(
      itemId: checklist.id,
      text: 'Block 45 minutes for deep work',
    );
    await checklistRepo.addEntry(
      itemId: checklist.id,
      text: 'Silence non-urgent notifications',
      parentId: step2.id,
    );
    await checklistRepo.addEntry(
      itemId: checklist.id,
      text: 'Take a 10-minute afternoon walk',
    );
    await orgRepo.addTagToItem(itemId: checklist.id, tagName: 'focus');

    final reminderTarget = eveningReminder.isAfter(now)
        ? eveningReminder
        : now.add(const Duration(hours: 2));
    await remindersRepo.scheduleReminder(
      itemId: checklist.id,
      fireAt: reminderTarget,
      repeatRule: LumiRepeatRule.daily,
    );

    final workNote = await itemsRepo.createItem(
      type: LumiItemType.card,
      title: 'Weekly Design Critique Prep',
      initialPlainText: 'Collect before/after liquid glass motion clips and check high-contrast fallback states.',
      collectionId: 'col_work',
      dueDate: todayNoon.add(const Duration(days: 1)),
      boardStatus: LumiBoardStatus.todo,
    );
    await orgRepo.addTagToItem(itemId: workNote.id, tagName: 'design');

    await itemsRepo.createItem(
      type: LumiItemType.sticky,
      title: 'Hydrate & breathe',
      initialPlainText: 'Step away from screens for 5 min every hour.',
      colorValue: LumiStickyColor.peach.colorValue,
      stickyX: 36,
      stickyY: 48,
      stickyW: 176,
      stickyH: 176,
      stickyZ: 1,
    );
    await itemsRepo.createItem(
      type: LumiItemType.sticky,
      title: 'Reading list',
      initialPlainText:
          'The Design of Everyday Things\nGrid Systems in Graphic Design',
      colorValue: LumiStickyColor.mint.colorValue,
      stickyX: 228,
      stickyY: 92,
      stickyW: 184,
      stickyH: 184,
      stickyZ: 2,
      pinned: true,
    );

    await prefs.setBool(seedKey, true);
  }
}
