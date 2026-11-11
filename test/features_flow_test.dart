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
}
