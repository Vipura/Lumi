import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/app/lumi_app.dart';
import 'package:lumi/core/design/design_system.dart';
import 'package:lumi/data/db/lumi_database.dart';
import 'package:lumi/data/repositories/lumi_models.dart';
import 'package:lumi/data/repositories/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets(
    'Fresh install has zero dummy data, navigates all 6 tabs, creates quick note, and uses template',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'lumi.onboardingCompleted': true,
        'lumi.tourCompleted': true,
        'lumi.reduceMotion': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final db = LumiDatabase(NativeDatabase.memory());

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

      // Zero dummy/sample items seeded on fresh startup.
      final allOnBoot = await db.itemsDao.searchItems('');
      expect(allOnBoot, isEmpty);

      // Today tab should be visible with Calm Space section and floating "+".
      expect(find.byType(LumiCaptureFab), findsOneWidget);
      expect(find.text("Today's momentum"), findsOneWidget);
      expect(find.text('Calm Space'), findsOneWidget);

      // Tap the glowing "+" capture button to open the capture glass sheet.
      await tester.tap(find.byType(LumiCaptureFab));
      await tester.pumpAndSettle();

      expect(find.text('Capture anything'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Checklist'), findsOneWidget);
      expect(find.text('Sticky'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget);
      expect(find.text('Photo'), findsOneWidget);
      expect(find.text('Reminder'), findsOneWidget);
      expect(find.text('Use a template'), findsOneWidget);

      // Enter a quick thought and submit it.
      final quickField = find.widgetWithText(
        TextField,
        'Instant thought... press Enter to save',
      );
      await tester.enterText(quickField, 'Buy saffron and fresh basil');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final savedItems = await db.itemsDao.searchItems('saffron');
      expect(savedItems.length, 1);
      expect(savedItems.first.title, 'Buy saffron and fresh basil');

      // Navigate across all 6 tabs cleanly.
      await tester.tap(find.text('Notes').last);
      await tester.pumpAndSettle();
      expect(find.text('Buy saffron and fresh basil'), findsOneWidget);

      await tester.tap(find.text('Checklists').last);
      await tester.pumpAndSettle();
      expect(find.text('No checklists yet'), findsOneWidget);

      await tester.tap(find.text('Reminders').last);
      await tester.pumpAndSettle();
      expect(find.text('No scheduled alarms'), findsOneWidget);

      await tester.tap(find.text('Plan').last);
      await tester.pumpAndSettle();
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Boards'), findsOneWidget);

      await tester.tap(find.text('Wall').last);
      await tester.pumpAndSettle();
      expect(find.text('Sticky Wall'), findsOneWidget);

      // Regression check: "+" -> "Use a template" opens template picker and creates item.
      await tester.tap(find.byType(LumiCaptureFab));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Use a template'));
      await tester.pumpAndSettle();

      expect(find.text('Start from a template'), findsOneWidget);
      expect(find.text('Weekly review'), findsOneWidget);

      await tester.tap(find.text('Weekly review'));
      await tester.pumpAndSettle();

      final weeklyItems = await db.itemsDao.searchItems('Weekly review');
      expect(weeklyItems, isNotEmpty);
      expect(weeklyItems.first.type, LumiItemType.note.dbValue);
      expect(find.byType(TextField), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );
}
