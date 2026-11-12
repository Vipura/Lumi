import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  testWidgets(
    'LumiGlass uses ClipRSuperellipse, groups inside BackdropGroup, and skips blur & clip on cards',
    (tester) async {
      final groupKey = BackdropKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: LumiThemes.build(
            brightness: Brightness.light,
            useGoogleFonts: false,
          ),
          home: Scaffold(
            body: BackdropGroup(
              backdropKey: groupKey,
              child: const Column(
                children: [
                  LumiGlass(
                    borderRadius: LumiRadius.md,
                    child: Text('Grouped Surface'),
                  ),
                  LumiGlass(
                    borderRadius: LumiRadius.pill,
                    variant: LumiGlassVariant.clear,
                    child: Text('Clear Pill'),
                  ),
                  LumiGlass.card(child: Text('Fast Card')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ClipRSuperellipse), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNWidgets(2));

      final renderBackdrop = tester.renderObject<RenderBackdropFilter>(
        find.byType(BackdropFilter).first,
      );
      expect(renderBackdrop.backdropKey, equals(groupKey));
    },
  );

  testWidgets(
    'LumiGlassEffectContainer and LumiScrollEdge render cleanly without overflow at 1.4x text scale',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
          child: MaterialApp(
            theme: LumiThemes.build(
              brightness: Brightness.dark,
              useGoogleFonts: false,
            ),
            home: const Stack(
              children: [
                LumiDesignGalleryScreen(initialBrightness: Brightness.dark),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LumiScrollEdge(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(LumiGlassEffectContainer), findsAtLeastNWidgets(1));
      expect(find.byType(LumiScrollEdge), findsOneWidget);
    },
  );

  testWidgets(
    'LumiGlassSwitch and LumiGlassSwitchTile toggle via tap and horizontal drag',
    (tester) async {
      var value = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: LumiThemes.build(
            brightness: Brightness.light,
            useGoogleFonts: false,
          ),
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: LumiGlass.card(
                child: LumiGlassSwitchTile(
                  title: const Text('Liquid toggle'),
                  subtitle: const Text('Refractive crystal knob'),
                  value: value,
                  onChanged: (next) => setState(() => value = next),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LumiGlassSwitch), findsOneWidget);
      expect(value, isFalse);

      await tester.tap(find.byType(LumiGlassSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);

      // Drag left to switch off.
      await tester.drag(find.byType(LumiGlassSwitch), const Offset(-28, 0));
      await tester.pumpAndSettle();
      expect(value, isFalse);

      await tester.tap(find.text('Liquid toggle'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    },
  );

  testWidgets('LumiGlassLensButton renders label, icon, and fires tap', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: LumiThemes.build(
          brightness: Brightness.dark,
          useGoogleFonts: false,
        ),
        home: Scaffold(
          body: LumiGlassLensButton(
            label: 'Begin Focus',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Begin Focus'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

    await tester.tap(find.byType(LumiGlassLensButton));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('Grouped LumiGlassIconButton omits chrome border but fires tap', (
    tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: LumiThemes.build(
          brightness: Brightness.dark,
          useGoogleFonts: false,
        ),
        home: Scaffold(
          body: LumiGlass(
            borderRadius: LumiRadius.pill,
            child: LumiGlassIconButton(
              icon: Icons.search_rounded,
              tooltip: 'Search notes',
              useBlur: false,
              chrome: false,
              onTap: () => pressed = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(LumiGlass), findsOneWidget);
    await tester.tap(find.byTooltip('Search notes'));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
  });
}
