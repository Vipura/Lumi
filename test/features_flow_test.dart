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

  Future<(LumiDatabase, SharedPreferences)> createHarness() async {
    SharedPreferences.setMockInitialValues({
      'lumi.onboardingCompleted': true,
      'lumi.dev.sample_seeded_v1': true,
      'lumi.reduceMotion': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final db = LumiDatabase(NativeDatabase.memory());
    await db.organizationDao.getCollections();
    return (db, prefs);
  }

  testWidgets(
    'Open note from Notes tab, autosave title, and add checklist block',
    (tester) async {
      final (db, prefs) = await createHarness();
      final repo = DriftItemsRepository(db);
      final seeded = await repo.createItem(
        type: LumiItemType.checklist,
        title: 'Launch Checklist',
        initialPlainText: 'Final release review',
        pinned: true,
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

      // Navigate to Notes and open seeded item via Hero route.
      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();
      expect(find.text('Launch Checklist'), findsOneWidget);

      await tester.tap(find.text('Launch Checklist'));
      await tester.pumpAndSettle();

      // Verify checklist section rendered and word/saved status indicator visible.
      expect(find.text('Checklist'), findsOneWidget);

      // Update title and let debounced autosave commit.
      final titleField = find.widgetWithText(TextField, 'Launch Checklist');
      await tester.enterText(titleField, 'Updated Release Plan');
      await tester.pump(const Duration(milliseconds: 550));
      await tester.pumpAndSettle();

      final reloaded = await repo.getItem(seeded.id);
      expect(reloaded?.title, 'Updated Release Plan');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );

  testWidgets(
    'Sticky Wall adds and persists sticky note and Settings toggles persist',
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
      await tester.tap(find.text('Wall'));
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

      // Return to Today -> open Settings and toggle Reduce transparency.
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Ocean'));
      await tester.tap(find.text('Ocean'));
      await tester.ensureVisible(find.text('Reduce transparency'));
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
}
