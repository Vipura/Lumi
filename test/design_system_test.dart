import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/core/design/design_system.dart';
import 'package:lumi/core/design/lumi_design_gallery_screen.dart';

// Top-level enum visible to all test closures.
enum _TestTab { a, b, c }

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

  testWidgets(
    'LumiGlassButton renders primary and secondary with BackdropFilter blur',
    (tester) async {
      var primaryTapped = false;
      var secondaryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: LumiThemes.build(
            brightness: Brightness.dark,
            useGoogleFonts: false,
          ),
          home: Scaffold(
            body: Column(
              children: [
                LumiGlassButton(
                  label: 'Primary Button',
                  primary: true,
                  onPressed: () => primaryTapped = true,
                ),
                LumiGlassButton(
                  label: 'Secondary Button',
                  primary: false,
                  onPressed: () => secondaryTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.text('Secondary Button'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNWidgets(2));

      await tester.tap(find.text('Primary Button'));
      await tester.pumpAndSettle();
      expect(primaryTapped, isTrue);

      await tester.tap(find.text('Secondary Button'));
      await tester.pumpAndSettle();
      expect(secondaryTapped, isTrue);
    },
  );

  testWidgets(
    'LumiGlassSegmentedControl slides indicator, fires onChanged, and updates labels',
    (tester) async {
      var selected = _TestTab.a;

      await tester.pumpWidget(
        MaterialApp(
          theme: LumiThemes.build(
            brightness: Brightness.light,
            useGoogleFonts: false,
          ),
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Center(
                child: LumiGlassSegmentedControl<_TestTab>(
                  segments: const [
                    LumiSegment(value: _TestTab.a, label: 'For You'),
                    LumiSegment(value: _TestTab.b, label: 'Library'),
                    LumiSegment(value: _TestTab.c, label: 'Radio'),
                  ],
                  selectedValue: selected,
                  onChanged: (v) => setState(() => selected = v),
                ),
              ),
            ),
          ),
        ),
      );

      // All labels render
      expect(find.text('For You'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Radio'), findsOneWidget);

      // Initial state: 'For You' selected
      expect(selected, _TestTab.a);

      // Tap 'Library'
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      expect(selected, _TestTab.b);

      // Tap 'Radio'
      await tester.tap(find.text('Radio'));
      await tester.pumpAndSettle();
      expect(selected, _TestTab.c);

      // Tap already-selected has no effect
      await tester.tap(find.text('Radio'));
      await tester.pumpAndSettle();
      expect(selected, _TestTab.c);

      // Renders inside an unbounded Row (e.g. header bar) and supports drag scrub
      var rowSelected = _TestTab.a;
      await tester.pumpWidget(
        MaterialApp(
          theme: LumiThemes.build(
            brightness: Brightness.dark,
            useGoogleFonts: false,
          ),
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Row(
                children: [
                  const Expanded(child: Text('Plan')),
                  LumiGlassSegmentedControl<_TestTab>(
                    segments: const [
                      LumiSegment(
                        value: _TestTab.a,
                        label: 'For You',
                        icon: Icons.favorite_rounded,
                      ),
                      LumiSegment(
                        value: _TestTab.b,
                        label: 'Library',
                        icon: Icons.library_music_rounded,
                      ),
                    ],
                    selectedValue: rowSelected,
                    onChanged: (v) => setState(() => rowSelected = v),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('For You'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);

      await tester.drag(
        find.byType(LumiGlassSegmentedControl<_TestTab>),
        const Offset(100, 0),
      );
      await tester.pumpAndSettle();
      expect(rowSelected, _TestTab.b);
    },
  );

  testWidgets(
    'Desktop targets optimize background mesh and support GPU-accelerated floating glass',
    (tester) async {
      for (final platform in const [
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        await tester.pumpWidget(
          MaterialApp(
            theme: LumiThemes.build(
              brightness: Brightness.dark,
              useGoogleFonts: false,
            ),
            home: const LumiBackground(
              child: Scaffold(
                body: Column(
                  children: [
                    LumiGlass(
                      blur: 20.0,
                      elevated: true,
                      child: Text('Desktop Chrome'),
                    ),
                    LumiGlass.card(child: Text('Desktop Card')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Desktop Chrome'), findsOneWidget);
        expect(find.text('Desktop Card'), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
      }
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
