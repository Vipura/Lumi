import 'package:flutter/material.dart';

/// Spacing scale tokens (4 / 8 / 12 / 16 / 24 / 32).
abstract final class LumiSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Corner radius tokens (12 / 20 / 28 / 36).
abstract final class LumiRadius {
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double xl = 36;
  static const double pill = 999;
}

/// Motion durations and spring-inspired curves (200–350 ms max).
abstract final class LumiMotion {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 340);

  static const Curve spring = Cubic(0.22, 1.0, 0.36, 1.0);
  static const Curve pop = Cubic(0.34, 1.38, 0.64, 1.0);
  static const Curve ease = Curves.easeOutCubic;

  static bool shouldReduceMotion(BuildContext context, {bool setting = false}) {
    if (setting) return true;
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }
}

/// Ambient background themes available across Lumi.
enum LumiBackgroundTheme {
  aurora('Aurora', [Color(0xFF1D2B64), Color(0xFF0F766E), Color(0xFF7C3AED)]),
  sunset('Sunset', [Color(0xFFF97316), Color(0xFFEC4899), Color(0xFF4F46E5)]),
  ocean('Ocean', [Color(0xFF0369A1), Color(0xFF06B6D4), Color(0xFF1E3A8A)]),
  forest('Forest', [Color(0xFF065F46), Color(0xFF10B981), Color(0xFF0F766E)]),
  mono('Mono', [Color(0xFF475569), Color(0xFF64748B), Color(0xFF334155)]);

  const LumiBackgroundTheme(this.label, this.previewColors);

  final String label;
  final List<Color> previewColors;
}

/// Curated accent colors with a warm glowing amber default.
enum LumiAccentPreset {
  warmAmber('Warm Amber', Color(0xFFFF8A5B), Color(0xFFFFB870)),
  solarGold('Solar Gold', Color(0xFFF59E0B), Color(0xFFFCD34D)),
  roseQuartz('Rose Quartz', Color(0xFFF43F5E), Color(0xFFFB7185)),
  auroraViolet('Aurora Violet', Color(0xFF8B5CF6), Color(0xFFC4B5FD)),
  oceanCyan('Ocean Cyan', Color(0xFF06B6D4), Color(0xFF67E8F9)),
  emeraldGlow('Emerald Glow', Color(0xFF10B981), Color(0xFF6EE7B7));

  const LumiAccentPreset(this.label, this.color, this.glowColor);

  final String label;
  final Color color;
  final Color glowColor;
}

/// Eight soft translucent sticky-note colors tuned for light & dark surfaces.
enum LumiStickyColor {
  butter(
    'Butter',
    lightFill: Color(0xFFFFF4C7),
    darkFill: Color(0xFF4B3F1D),
    accent: Color(0xFFF59E0B),
  ),
  peach(
    'Peach',
    lightFill: Color(0xFFFFE2D4),
    darkFill: Color(0xFF4C2B22),
    accent: Color(0xFFFF8A5B),
  ),
  mint(
    'Mint',
    lightFill: Color(0xFFD8F7EA),
    darkFill: Color(0xFF1A4034),
    accent: Color(0xFF10B981),
  ),
  sky(
    'Sky',
    lightFill: Color(0xFFD9EEFF),
    darkFill: Color(0xFF1B364F),
    accent: Color(0xFF38BDF8),
  ),
  lavender(
    'Lavender',
    lightFill: Color(0xFFEAE2FF),
    darkFill: Color(0xFF32274E),
    accent: Color(0xFF8B5CF6),
  ),
  rose(
    'Rose',
    lightFill: Color(0xFFFFDCE8),
    darkFill: Color(0xFF4B2335),
    accent: Color(0xFFF43F5E),
  ),
  sage(
    'Sage',
    lightFill: Color(0xFFE4F0DC),
    darkFill: Color(0xFF283A25),
    accent: Color(0xFF84CC16),
  ),
  pearl(
    'Pearl',
    lightFill: Color(0xFFF1F5F9),
    darkFill: Color(0xFF283244),
    accent: Color(0xFF94A3B8),
  );

  const LumiStickyColor(
    this.label, {
    required this.lightFill,
    required this.darkFill,
    required this.accent,
  });

  final String label;
  final Color lightFill;
  final Color darkFill;
  final Color accent;

  Color fillFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkFill : lightFill;

  int get colorValue => accent.toARGB32();

  static LumiStickyColor fromColorValue(int? value) {
    if (value == null) return LumiStickyColor.butter;
    for (final item in values) {
      if (item.accent.toARGB32() == value ||
          item.lightFill.toARGB32() == value ||
          item.darkFill.toARGB32() == value) {
        return item;
      }
    }
    return LumiStickyColor.butter;
  }
}

/// Core semantic and neutral palette constants.
abstract final class LumiColors {
  static const Color lightCanvas = Color(0xFFF2F5FC);
  static const Color darkCanvas = Color(0xFF070B14);

  static const Color lightInk = Color(0xFF0F172A);
  static const Color lightInkMuted = Color(0xFF475569);

  static const Color darkInk = Color(0xFFF8FAFC);
  static const Color darkInkMuted = Color(0xFF94A3B8);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);
}

/// Lightweight InheritedWidget exposing user accessibility & aesthetic flags
/// to core design widgets without coupling `core/design` to providers.
class LumiDesignScope extends InheritedWidget {
  const LumiDesignScope({
    super.key,
    required this.reduceTransparency,
    required this.reduceMotion,
    required this.hapticsEnabled,
    required this.backgroundTheme,
    required this.accentColor,
    required super.child,
  });

  final bool reduceTransparency;
  final bool reduceMotion;
  final bool hapticsEnabled;
  final LumiBackgroundTheme backgroundTheme;
  final Color accentColor;

  static LumiDesignScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LumiDesignScope>();
  }

  @override
  bool updateShouldNotify(LumiDesignScope oldWidget) {
    return reduceTransparency != oldWidget.reduceTransparency ||
        reduceMotion != oldWidget.reduceMotion ||
        hapticsEnabled != oldWidget.hapticsEnabled ||
        backgroundTheme != oldWidget.backgroundTheme ||
        accentColor != oldWidget.accentColor;
  }
}
