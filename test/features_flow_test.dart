import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/app/lumi_app.dart';
import 'package:lumi/core/design/design_system.dart';
import 'package:lumi/data/db/lumi_database.dart';
import 'package:lumi/data/repositories/items_repository.dart';
import 'package:lumi/data/repositories/lumi_models.dart';
import 'package:lumi/data/repositories/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<(LumiDatabase, SharedPreferences)> createHarness({
    bool tourCompleted = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      'lumi.onboardingCompleted': true,
      'lumi.tourCompleted': tourCompleted,
      'lumi.reduceMotion': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final db = LumiDatabase(NativeDatabase.memory());
    await db.organizationDao.getCollections();
    return (db, prefs);
  }

  testWidgets(
    'Checklist lives strictly in Checklists tab (not Notes) and autosaves edits',
    (tester) async {
      final (db, prefs) = await createHarness();
      final repo = DriftItemsRepository(db);
      final seededChecklist = await repo.createItem(
        type: LumiItemType.checklist,
        title: 'Launch Checklist',
        initialPlainText: 'Final release review',
        pinned: true,
      );
      await repo.createItem(
        type: LumiItemType.note,
        title: 'Studio Ideas',
        initialPlainText: 'Voice and photo drafts live here.',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            databaseProvider.overrideWith((ref) {
              ref.onDispose(db.close);
              return db;
            }),
          ],
          child: const LumiApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      // Notes tab strictly shows notes only — no checklists.
      await tester.tap(find.text('Notes').last);
      await tester.pumpAndSettle();
      expect(find.text('Studio Ideas'), findsOneWidget);
      expect(find.text('Launch Checklist'), findsNothing);

      // Checklists tab strictly shows checklists — no notes.
      await tester.tap(find.text('Checklists').last);
      await tester.pumpAndSettle();
      expect(find.text('Launch Checklist'), findsOneWidget);
      expect(find.text('Studio Ideas'), findsNothing);

      await tester.tap(find.text('Launch Checklist'));
      await tester.pumpAndSettle();

      // Verify checklist section rendered and update title with debounced autosave.
      expect(find.text('Checklist'), findsOneWidget);

      final titleField = find.widgetWithText(TextField, 'Launch Checklist');
      await tester.enterText(titleField, 'Updated Release Plan');
      await tester.pump(const Duration(milliseconds: 550));
      await tester.pumpAndSettle();

      final reloaded = await repo.getItem(seededChecklist.id);
      expect(reloaded?.title, 'Updated Release Plan');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );

  testWidgets(
    'Sticky Wall adds sticky note and Settings Liquid Glass switch toggles persist at 1.4x scale',
    (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.4;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      final (db, prefs) = await createHarness();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            databaseProvider.overrideWith((ref) {
              ref.onDispose(db.close);
              return db;
            }),
          ],
          child: const LumiApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Wall and add a sticky note via the empty state CTA.
      await tester.tap(find.text('Wall').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(LumiGlassButton, 'Add Sticky'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Sticky'), findsOneWidget);
      final bodyField = find.widgetWithText(
        TextField,
        'Write a quick thought...',
      );
      await tester.enterText(bodyField, 'Sync design tokens');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Sync design tokens'), findsOneWidget);

      // Return to Today -> open Settings and toggle Liquid Glass switch.
      await tester.tap(find.text('Today').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Ocean'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ocean'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Reduce transparency'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reduce transparency'));
      await tester.pumpAndSettle();

      expect(find.byType(LumiDesignScope), findsWidgets);
      expect(prefs.getBool('lumi.reduceTransparency'), isTrue);
      expect(
        prefs.getString('lumi.backgroundTheme'),
        LumiBackgroundTheme.ocean.name,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );

  testWidgets(
    'Reminders tab creates reminder with custom time/title/early alert/repeat and updates in-place',
    (tester) async {
      final (db, prefs) = await createHarness();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            databaseProvider.overrideWith((ref) {
              ref.onDispose(db.close);
              return db;
            }),
          ],
          child: const LumiApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      // Open Reminders tab.
      await tester.tap(find.text('Reminders').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Reminder'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(
          TextField,
          'Reminder title (e.g. Call Alex, Take medicine)',
        ),
        'Take evening vitamins',
      );

      // Change user time explicitly using the time picker dial -> input mode.
      await tester.tap(find.byKey(const ValueKey('reminder_time_picker_btn')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Switch to text input mode'));
      await tester.pumpAndSettle();

      final timeFields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(timeFields.at(0), '8');
      await tester.enterText(timeFields.at(1), '45');
      if (find.text('PM').evaluate().isNotEmpty) {
        await tester.tap(find.text('PM'));
      }
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.textContaining('8:45'), findsOneWidget);

      await tester.ensureVisible(find.text('15m early'));
      await tester.tap(find.text('15m early'));
      await tester.ensureVisible(find.text('Daily'));
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Set Reminder Alarm'));
      await tester.tap(find.text('Set Reminder Alarm'));
      await tester.pumpAndSettle();

      final reminders = (await db.remindersDao.getAllReminders())
          .where((r) => r.status != LumiReminderStatus.cancelled.dbValue)
          .toList();
      expect(reminders.length, 1);
      expect(reminders.single.title, 'Take evening vitamins');
      expect(reminders.single.fireAt.minute, 45);
      expect(reminders.single.earlyReminderMinutes, 15);
      expect(reminders.single.repeatRule, LumiRepeatRule.daily.dbValue);

      // Edit existing reminder in-place and change time again.
      await tester.tap(find.text('Take evening vitamins'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('reminder_time_picker_btn')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Switch to text input mode'));
      await tester.pumpAndSettle();
      final editFields = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(editFields.at(0), '9');
      await tester.enterText(editFields.at(1), '15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Update Reminder'));
      await tester.tap(find.text('Update Reminder'));
      await tester.pumpAndSettle();

      final updatedList = (await db.remindersDao.getAllReminders())
          .where((r) => r.status != LumiReminderStatus.cancelled.dbValue)
          .toList();
      expect(updatedList.length, 1);
      expect(updatedList.single.id, reminders.single.id);
      expect(updatedList.single.fireAt.minute, 15);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );

  testWidgets(
    'Plan tab excludes notes/reminders/checklists, defaults new Plans to To Do, and changes status',
    (tester) async {
      tester.view.physicalSize = const Size(1180, 860);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final (db, prefs) = await createHarness();
      final repo = DriftItemsRepository(db);
      final today = DateTime.now();

      await repo.createItem(
        type: LumiItemType.note,
        title: 'Secret Note Leaks Test',
        dueDate: today,
      );
      await repo.createItem(
        type: LumiItemType.checklist,
        title: 'Hidden Checklist Test',
        dueDate: today,
      );
      await repo.createItem(
        type: LumiItemType.reminder,
        title: 'Hidden Reminder Test',
        dueDate: today,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            databaseProvider.overrideWith((ref) {
              ref.onDispose(db.close);
              return db;
            }),
          ],
          child: const LumiApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Plan').last);
      await tester.pumpAndSettle();

      // Notes, checklists, and reminders never appear in Plan Calendar or Boards.
      expect(find.text('Secret Note Leaks Test'), findsNothing);
      expect(find.text('Hidden Checklist Test'), findsNothing);
      expect(find.text('Hidden Reminder Test'), findsNothing);

      await tester.tap(find.text('Boards'));
      await tester.pumpAndSettle();

      expect(find.text('To Do'), findsOneWidget);
      expect(find.text('Doing'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Secret Note Leaks Test'), findsNothing);

      await tester.tap(find.byTooltip('Add plan to To Do'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Plan title'),
        'Finish v1.1 release',
      );
      await tester.tap(find.text('Create Plan'));
      await tester.pumpAndSettle();

      expect(find.text('Finish v1.1 release'), findsOneWidget);

      // Verify persisted default status is To Do, then promote to Doing.
      final createdPlans = await db.itemsDao.searchItems('Finish v1.1 release');
      expect(createdPlans.single.boardStatus, LumiBoardStatus.todo.dbValue);

      await tester.tap(find.byTooltip('Move right'));
      await tester.pumpAndSettle();

      final promoted = await repo.getItem(createdPlans.single.id);
      expect(promoted?.boardStatus, LumiBoardStatus.doing.dbValue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );

  testWidgets(
    'Interactive new-user tour walks across tabs and Calm Space creates freeform story',
    (tester) async {
      final (db, prefs) = await createHarness(tourCompleted: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            databaseProvider.overrideWith((ref) {
              ref.onDispose(db.close);
              return db;
            }),
          ],
          child: const LumiApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      // Interactive tour appears on first visit to workspace.
      expect(find.text('Quick Tour • 1 of 7'), findsOneWidget);
      expect(find.text('Welcome to Today'), findsOneWidget);

      for (var step = 2; step <= 7; step++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(find.text('Quick Tour • $step of 7'), findsOneWidget);
      }

      await tester.tap(find.text('Finish Tour'));
      await tester.pumpAndSettle();
      expect(prefs.getBool('lumi.tourCompleted'), isTrue);

      // Navigate to Today and enter Calm Space.
      await tester.tap(find.text('Today').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Space'));
      await tester.pumpAndSettle();

      expect(find.text('A quiet place for your mind'), findsOneWidget);
      await tester.tap(find.text('Short story'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Title your thought or story...'),
        'Moonlight on Kandy Lake',
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final calmItems = await db.itemsDao.searchItems('Moonlight');
      expect(calmItems.length, 1);
      expect(calmItems.single.type, LumiItemType.calm.dbValue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );
}
