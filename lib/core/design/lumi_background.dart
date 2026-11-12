import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'lumi_tokens.dart';

/// Time-of-day phases used to gently warm or deepen Today's ambient canvas.
enum LumiDayPhase {
  morning,
  midday,
  evening,
  night;

  static LumiDayPhase fromDateTime(DateTime dt) {
    final h = dt.hour;
    if (h >= 5 && h < 11) return LumiDayPhase.morning;
    if (h >= 11 && h < 17) return LumiDayPhase.midday;
    if (h >= 17 && h < 21) return LumiDayPhase.evening;
    return LumiDayPhase.night;
  }
}

/// Zero-idle-cost radial-orb ambient canvas behind all Lumi screens.
///
/// Renders into an isolated [RepaintBoundary] and only animates briefly when
/// theme, brightness, or day-phase changes — never invalidating downstream
/// [BackdropFilter]s at 60/120 fps while scrolling, typing, or idling.
class LumiBackground extends StatelessWidget {
  const LumiBackground({
    super.key,
    required this.child,
    this.theme,
    this.timeOfDayShift = false,
    this.now,
  });

  final Widget child;
  final LumiBackgroundTheme? theme;
  final bool timeOfDayShift;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scope = LumiDesignScope.maybeOf(context);
    final activeTheme =
        widgetThemeOrScope(theme, scope) ?? LumiBackgroundTheme.aurora;
    final reduceTransparency =
        scope?.reduceTransparency ??
        (MediaQuery.maybeOf(context) != null &&
            WidgetsBinding
                .instance
                .platformDispatcher
                .accessibilityFeatures
                .highContrast);
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: scope?.reduceMotion ?? false,
    );

    final phase = timeOfDayShift
        ? LumiDayPhase.fromDateTime(now ?? DateTime.now())
        : null;

    final palette = _resolveOrbs(activeTheme, brightness, phase);

    // On desktop platforms (macOS/Windows/Linux) & web, the 4-orb CustomPaint
    // runs on the CPU raster thread and causes fullscreen overdraw on resize.
    // Replace with a crisp three-stop LinearGradient that costs zero per frame.
    final bool useSimpleGradient =
        reduceTransparency ||
        kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android);

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: ColoredBox(
            color: palette.base,
            child: useSimpleGradient
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          palette.base,
                          Color.lerp(palette.base, palette.orbs.first, 0.22)!,
                          Color.lerp(palette.base, palette.orbs[2], 0.16)!,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  )
                : AnimatedSwitcher(
                    duration: reduceMotion ? Duration.zero : LumiMotion.slow,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: CustomPaint(
                      key: ValueKey(palette),
                      isComplex: true,
                      willChange: false,
                      painter: _LumiMeshPainter(palette: palette),
                      child: const SizedBox.expand(),
                    ),
                  ),
          ),
        ),
        child,
      ],
    );
  }

  static LumiBackgroundTheme? widgetThemeOrScope(
    LumiBackgroundTheme? widgetTheme,
    LumiDesignScope? scope,
  ) => widgetTheme ?? scope?.backgroundTheme;

  _BackgroundPalette _resolveOrbs(
    LumiBackgroundTheme theme,
    Brightness brightness,
    LumiDayPhase? phase,
  ) {
    final isDark = brightness == Brightness.dark;
    late Color base;
    late List<Color> orbs;

    switch (theme) {
      case LumiBackgroundTheme.aurora:
        base = isDark ? const Color(0xFF070B16) : const Color(0xFFEEF3FC);
        orbs = isDark
            ? const [
                Color(0xFF3B82F6),
                Color(0xFF0D9488),
                Color(0xFF7C3AED),
                Color(0xFFFF8A5B),
              ]
            : const [
                Color(0xFF93C5FD),
                Color(0xFF6EE7B7),
                Color(0xFFC4B5FD),
                Color(0xFFFDBA74),
              ];
      case LumiBackgroundTheme.sunset:
        base = isDark ? const Color(0xFF140914) : const Color(0xFFFFF3EE);
        orbs = isDark
            ? const [
                Color(0xFFEA580C),
                Color(0xFFDB2777),
                Color(0xFF6D28D9),
                Color(0xFFF59E0B),
              ]
            : const [
                Color(0xFFFDBA74),
                Color(0xFFF9A8D4),
                Color(0xFFC4B5FD),
                Color(0xFFFDE68A),
              ];
      case LumiBackgroundTheme.ocean:
        base = isDark ? const Color(0xFF05111D) : const Color(0xFFECF7FD);
        orbs = isDark
            ? const [
                Color(0xFF0284C7),
                Color(0xFF06B6D4),
                Color(0xFF1D4ED8),
                Color(0xFF2DD4BF),
              ]
            : const [
                Color(0xFF7DD3FC),
                Color(0xFF67E8F9),
                Color(0xFFA5B4FC),
                Color(0xFF99F6E4),
              ];
      case LumiBackgroundTheme.forest:
        base = isDark ? const Color(0xFF06130F) : const Color(0xFFEDF7F2);
        orbs = isDark
            ? const [
                Color(0xFF059669),
                Color(0xFF0F766E),
                Color(0xFF65A30D),
                Color(0xFF14B8A6),
              ]
            : const [
                Color(0xFF6EE7B7),
                Color(0xFF99F6E4),
                Color(0xFFBEF264),
                Color(0xFFA7F3D0),
              ];
      case LumiBackgroundTheme.mono:
        base = isDark ? const Color(0xFF0B0D12) : const Color(0xFFF3F4F6);
        orbs = isDark
            ? const [
                Color(0xFF334155),
                Color(0xFF475569),
                Color(0xFF1E293B),
                Color(0xFF64748B),
              ]
            : const [
                Color(0xFFCBD5E1),
                Color(0xFFE2E8F0),
                Color(0xFF94A3B8),
                Color(0xFFD1D5DB),
              ];
    }

    if (phase != null) {
      final tint = switch (phase) {
        LumiDayPhase.morning => const Color(0xFFFFB067),
        LumiDayPhase.midday => const Color(0xFF7DD3FC),
        LumiDayPhase.evening => const Color(0xFFF472B6),
        LumiDayPhase.night => const Color(0xFF312E81),
      };
      base = Color.lerp(base, tint, isDark ? 0.08 : 0.06)!;
      orbs = [
        Color.lerp(orbs[0], tint, 0.28)!,
        orbs[1],
        orbs[2],
        Color.lerp(orbs[3], tint, 0.35)!,
      ];
    }

    return _BackgroundPalette(
      base: base,
      orbs: orbs,
      orbOpacity: isDark ? 0.40 : 0.48,
    );
  }
}

@immutable
class _BackgroundPalette {
  const _BackgroundPalette({
    required this.base,
    required this.orbs,
    required this.orbOpacity,
  });

  final Color base;
  final List<Color> orbs;
  final double orbOpacity;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _BackgroundPalette &&
            other.base == base &&
            other.orbOpacity == orbOpacity &&
            listEquals(other.orbs, orbs));
  }

  @override
  int get hashCode => Object.hash(base, orbOpacity, Object.hashAll(orbs));
}

class _LumiMeshPainter extends CustomPainter {
  const _LumiMeshPainter({required this.palette});

  final _BackgroundPalette palette;

  static Size? _cachedSize;
  static _BackgroundPalette? _cachedPalette;
  static List<({Offset center, double radius, Paint paint})>? _cachedOrbs;

  List<({Offset center, double radius, Paint paint})> _resolveMeshOrbs(
    Size size,
  ) {
    if (_cachedSize == size &&
        _cachedPalette == palette &&
        _cachedOrbs != null) {
      return _cachedOrbs!;
    }

    final specs = [
      (
        center: Offset(size.width * 0.20, size.height * 0.18),
        radius: size.longestSide * 0.56,
        color: palette.orbs[0],
      ),
      (
        center: Offset(size.width * 0.84, size.height * 0.26),
        radius: size.longestSide * 0.52,
        color: palette.orbs[1],
      ),
      (
        center: Offset(size.width * 0.26, size.height * 0.80),
        radius: size.longestSide * 0.58,
        color: palette.orbs[2],
      ),
      (
        center: Offset(size.width * 0.80, size.height * 0.84),
        radius: size.longestSide * 0.48,
        color: palette.orbs[3],
      ),
    ];

    final built = [
      for (final orb in specs)
        (
          center: orb.center,
          radius: orb.radius,
          paint: Paint()
            ..shader =
                RadialGradient(
                  colors: [
                    orb.color.withValues(alpha: palette.orbOpacity),
                    orb.color.withValues(alpha: palette.orbOpacity * 0.36),
                    orb.color.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.48, 1.0],
                ).createShader(
                  Rect.fromCircle(center: orb.center, radius: orb.radius),
                ),
        ),
    ];

    _cachedSize = size;
    _cachedPalette = palette;
    _cachedOrbs = built;
    return built;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    for (final orb in _resolveMeshOrbs(size)) {
      canvas.drawCircle(orb.center, orb.radius, orb.paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LumiMeshPainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}
