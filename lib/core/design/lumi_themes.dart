import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lumi_tokens.dart';

/// Custom theme extension carrying all Liquid Glass surface tokens.
@immutable
class LumiThemeExtension extends ThemeExtension<LumiThemeExtension> {
  const LumiThemeExtension({
    required this.glassFillTop,
    required this.glassFillBottom,
    required this.glassElevatedFillTop,
    required this.glassElevatedFillBottom,
    required this.glassSolidFallback,
    required this.glassBorderTopLeft,
    required this.glassBorderBottomRight,
    required this.glassInnerHighlight,
    required this.glassShadow,
    required this.subtleCardFill,
    required this.accentColor,
    required this.accentGlow,
    required this.ink,
    required this.inkMuted,
    required this.reduceTransparency,
    required this.reduceMotion,
  });

  final Color glassFillTop;
  final Color glassFillBottom;
  final Color glassElevatedFillTop;
  final Color glassElevatedFillBottom;
  final Color glassSolidFallback;
  final Color glassBorderTopLeft;
  final Color glassBorderBottomRight;
  final Color glassInnerHighlight;
  final Color glassShadow;
  final Color subtleCardFill;
  final Color accentColor;
  final Color accentGlow;
  final Color ink;
  final Color inkMuted;
  final bool reduceTransparency;
  final bool reduceMotion;

  @override
  LumiThemeExtension copyWith({
    Color? glassFillTop,
    Color? glassFillBottom,
    Color? glassElevatedFillTop,
    Color? glassElevatedFillBottom,
    Color? glassSolidFallback,
    Color? glassBorderTopLeft,
    Color? glassBorderBottomRight,
    Color? glassInnerHighlight,
    Color? glassShadow,
    Color? subtleCardFill,
    Color? accentColor,
    Color? accentGlow,
    Color? ink,
    Color? inkMuted,
    bool? reduceTransparency,
    bool? reduceMotion,
  }) {
    return LumiThemeExtension(
      glassFillTop: glassFillTop ?? this.glassFillTop,
      glassFillBottom: glassFillBottom ?? this.glassFillBottom,
      glassElevatedFillTop: glassElevatedFillTop ?? this.glassElevatedFillTop,
      glassElevatedFillBottom:
          glassElevatedFillBottom ?? this.glassElevatedFillBottom,
      glassSolidFallback: glassSolidFallback ?? this.glassSolidFallback,
      glassBorderTopLeft: glassBorderTopLeft ?? this.glassBorderTopLeft,
      glassBorderBottomRight:
          glassBorderBottomRight ?? this.glassBorderBottomRight,
      glassInnerHighlight: glassInnerHighlight ?? this.glassInnerHighlight,
      glassShadow: glassShadow ?? this.glassShadow,
      subtleCardFill: subtleCardFill ?? this.subtleCardFill,
      accentColor: accentColor ?? this.accentColor,
      accentGlow: accentGlow ?? this.accentGlow,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  @override
  LumiThemeExtension lerp(ThemeExtension<LumiThemeExtension>? other, double t) {
    if (other is! LumiThemeExtension) return this;
    return LumiThemeExtension(
      glassFillTop: Color.lerp(glassFillTop, other.glassFillTop, t)!,
      glassFillBottom: Color.lerp(glassFillBottom, other.glassFillBottom, t)!,
      glassElevatedFillTop: Color.lerp(
        glassElevatedFillTop,
        other.glassElevatedFillTop,
        t,
      )!,
      glassElevatedFillBottom: Color.lerp(
        glassElevatedFillBottom,
        other.glassElevatedFillBottom,
        t,
      )!,
      glassSolidFallback: Color.lerp(
        glassSolidFallback,
        other.glassSolidFallback,
        t,
      )!,
      glassBorderTopLeft: Color.lerp(
        glassBorderTopLeft,
        other.glassBorderTopLeft,
        t,
      )!,
      glassBorderBottomRight: Color.lerp(
        glassBorderBottomRight,
        other.glassBorderBottomRight,
        t,
      )!,
      glassInnerHighlight: Color.lerp(
        glassInnerHighlight,
        other.glassInnerHighlight,
        t,
      )!,
      glassShadow: Color.lerp(glassShadow, other.glassShadow, t)!,
      subtleCardFill: Color.lerp(subtleCardFill, other.subtleCardFill, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      reduceTransparency: t < 0.5
          ? reduceTransparency
          : other.reduceTransparency,
      reduceMotion: t < 0.5 ? reduceMotion : other.reduceMotion,
    );
  }
}

extension LumiThemeBuildContextX on BuildContext {
  LumiThemeExtension get lumiTheme {
    final ext = Theme.of(this).extension<LumiThemeExtension>();
    if (ext != null) return ext;
    return LumiThemes.extensionFor(
      brightness: Theme.of(this).brightness,
      accentColor: LumiAccentPreset.warmAmber.color,
    );
  }
}

abstract final class LumiThemes {
  static LumiThemeExtension extensionFor({
    required Brightness brightness,
    required Color accentColor,
    bool reduceTransparency = false,
    bool reduceMotion = false,
  }) {
    final isDark = brightness == Brightness.dark;
    final glow = Color.lerp(accentColor, Colors.white, isDark ? 0.15 : 0.25)!;

    if (isDark) {
      return LumiThemeExtension(
        glassFillTop: Colors.white.withValues(alpha: 0.13),
        glassFillBottom: Colors.white.withValues(alpha: 0.06),
        glassElevatedFillTop: Colors.white.withValues(alpha: 0.17),
        glassElevatedFillBottom: Colors.white.withValues(alpha: 0.08),
        glassSolidFallback: const Color(0xFF151C2E),
        glassBorderTopLeft: Colors.white.withValues(alpha: 0.34),
        glassBorderBottomRight: Colors.white.withValues(alpha: 0.08),
        glassInnerHighlight: Colors.white.withValues(alpha: 0.14),
        glassShadow: Colors.black.withValues(alpha: 0.42),
        subtleCardFill: const Color(0xFF131A2B).withValues(alpha: 0.72),
        accentColor: accentColor,
        accentGlow: glow,
        ink: LumiColors.darkInk,
        inkMuted: LumiColors.darkInkMuted,
        reduceTransparency: reduceTransparency,
        reduceMotion: reduceMotion,
      );
    }

    return LumiThemeExtension(
      glassFillTop: Colors.white.withValues(alpha: 0.24),
      glassFillBottom: Colors.white.withValues(alpha: 0.11),
      glassElevatedFillTop: Colors.white.withValues(alpha: 0.36),
      glassElevatedFillBottom: Colors.white.withValues(alpha: 0.16),
      glassSolidFallback: const Color(0xFFF6F8FD),
      glassBorderTopLeft: Colors.white.withValues(alpha: 0.88),
      glassBorderBottomRight: Colors.white.withValues(alpha: 0.24),
      glassInnerHighlight: Colors.white.withValues(alpha: 0.38),
      glassShadow: const Color(0xFF0F172A).withValues(alpha: 0.10),
      subtleCardFill: Colors.white.withValues(alpha: 0.45),
      accentColor: accentColor,
      accentGlow: glow,
      ink: LumiColors.lightInk,
      inkMuted: LumiColors.lightInkMuted,
      reduceTransparency: reduceTransparency,
      reduceMotion: reduceMotion,
    );
  }

  static ThemeData build({
    required Brightness brightness,
    Color? accentColor,
    bool reduceTransparency = false,
    bool reduceMotion = false,
    bool useGoogleFonts = true,
  }) {
    final isDark = brightness == Brightness.dark;
    final accent = accentColor ?? LumiAccentPreset.warmAmber.color;
    final ext = extensionFor(
      brightness: brightness,
      accentColor: accent,
      reduceTransparency: reduceTransparency,
      reduceMotion: reduceMotion,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      primary: accent,
      surface: isDark ? LumiColors.darkCanvas : LumiColors.lightCanvas,
      onSurface: ext.ink,
    );

    final baseTextTheme = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;

    TextStyle bodyStyle(
      TextStyle? base, {
      double? fontSize,
      FontWeight? fontWeight,
      double? height,
      Color? color,
    }) {
      final styled = (base ?? const TextStyle()).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        color: color,
      );
      return useGoogleFonts ? GoogleFonts.manrope(textStyle: styled) : styled;
    }

    TextStyle displayStyle(
      TextStyle? base, {
      double? fontSize,
      FontWeight? fontWeight,
      double? letterSpacing,
      double? height,
      Color? color,
    }) {
      final styled = (base ?? const TextStyle()).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
      return useGoogleFonts
          ? GoogleFonts.plusJakartaSans(textStyle: styled)
          : styled;
    }

    final textTheme = baseTextTheme.copyWith(
      displayLarge: displayStyle(
        baseTextTheme.displayLarge,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.12,
        color: ext.ink,
      ),
      displayMedium: displayStyle(
        baseTextTheme.displayMedium,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.15,
        color: ext.ink,
      ),
      headlineLarge: displayStyle(
        baseTextTheme.headlineLarge,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: ext.ink,
      ),
      headlineMedium: displayStyle(
        baseTextTheme.headlineMedium,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: ext.ink,
      ),
      titleLarge: displayStyle(
        baseTextTheme.titleLarge,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: ext.ink,
      ),
      titleMedium: bodyStyle(
        baseTextTheme.titleMedium,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ext.ink,
      ),
      titleSmall: bodyStyle(
        baseTextTheme.titleSmall,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ext.ink,
      ),
      bodyLarge: bodyStyle(
        baseTextTheme.bodyLarge,
        fontSize: 16,
        height: 1.5,
        color: ext.ink,
      ),
      bodyMedium: bodyStyle(
        baseTextTheme.bodyMedium,
        fontSize: 14,
        height: 1.45,
        color: ext.ink,
      ),
      bodySmall: bodyStyle(
        baseTextTheme.bodySmall,
        fontSize: 12,
        height: 1.35,
        color: ext.inkMuted,
      ),
      labelLarge: bodyStyle(
        baseTextTheme.labelLarge,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ext.ink,
      ),
      labelMedium: bodyStyle(
        baseTextTheme.labelMedium,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: ext.ink,
      ),
      labelSmall: bodyStyle(
        baseTextTheme.labelSmall,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: ext.inkMuted,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      extensions: [ext],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: ext.ink,
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerTheme: DividerThemeData(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFF0F172A),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LumiRadius.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: textTheme.bodyMedium?.copyWith(color: ext.inkMuted),
      ),
    );
  }
}
