import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/core/design/design_system.dart';
import 'package:lumi/core/design/lumi_design_gallery_screen.dart';

void main() {
  testWidgets(
    'LumiGlass renders child, supports tap, and honors reduceTransparency',
    (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: LumiThemes.build(
            brightness: Brightness.light,
            useGoogleFonts: false,
          ),
          home: LumiDesignScope(
            reduceTransparency: false,
            reduceMotion: true,
            hapticsEnabled: false,
            backgroundTheme: LumiBackgroundTheme.aurora,
            accentColor: LumiAccentPreset.warmAmber.color,
            child: Scaffold(
              body: LumiGlass(
                onTap: () => tapped = true,
                child: const Text('Hello Glass'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello Glass'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);

      await tester.tap(find.text('Hello Glass'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      // Verify reduceTransparency removes BackdropFilter fallback cleanly.
      await tester.pumpWidget(
        MaterialApp(
          theme: LumiThemes.build(
            brightness: Brightness.dark,
            reduceTransparency: true,
            useGoogleFonts: false,
          ),
          home: LumiDesignScope(
            reduceTransparency: true,
            reduceMotion: true,
            hapticsEnabled: false,
            backgroundTheme: LumiBackgroundTheme.mono,
            accentColor: LumiAccentPreset.oceanCyan.color,
            child: const Scaffold(
              body: LumiGlass(child: Text('Solid Fallback')),
            ),
          ),
        ),
      );

      expect(find.text('Solid Fallback'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    },
  );

  testWidgets('LumiDesignGalleryScreen renders without overflow or errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LumiThemes.build(
          brightness: Brightness.dark,
          useGoogleFonts: false,
        ),
        home: const LumiDesignGalleryScreen(initialBrightness: Brightness.dark),
      ),
    );
    await tester.pump();
    expect(find.text('Lumi Design Gallery'), findsOneWidget);
    expect(find.byType(LumiLogo), findsAtLeastNWidgets(1));
  });
}
