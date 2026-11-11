import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Core Apple-inspired Liquid Glass container featuring single-pass optical blur,
/// hardware fast-path `ClipRRect`, 45-degree opposing corner caustics, inner
/// optical bevel halo (`.circle-overlay`), and press-scale + light haptic.
class LumiGlass extends StatefulWidget {
  const LumiGlass({
    super.key,
    required this.child,
    this.borderRadius = LumiRadius.md,
    this.blur = 8,
    this.tintColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.elevated = false,
    this.useBlur = true,
    this.grouped = true,
    this.hasShadow,
    this.haptic = true,
    this.borderOpacity = 1.0,
    this.alignment,
    this.semanticLabel,
  });

  /// Lightweight translucent content card without `BackdropFilter` or
  /// per-item CustomPaint shader allocations so long lists stay at 60/120 fps.
  const LumiGlass.card({
    super.key,
    required this.child,
    this.borderRadius = LumiRadius.md,
    this.tintColor,
    this.padding = const EdgeInsets.all(LumiSpacing.md),
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.elevated = false,
    this.hasShadow = false,
    this.haptic = true,
    this.borderOpacity = 0.85,
    this.alignment,
    this.semanticLabel,
  }) : blur = 0,
       useBlur = false,
       grouped = false;

  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool elevated;
  final bool useBlur;

  /// When `true` and a parent [BackdropGroup] exists at the same layer depth,
  /// shares the backdrop snapshot via [BackdropFilter.grouped]. Set `false`
  /// on modal sheets, dialogs, and overlays floating above scrolling content.
  final bool grouped;

  /// Explicit override for outer elevation shadow. Defaults to `true` for
  /// blurred or elevated floating chrome and `false` for list content cards.
  final bool? hasShadow;

  final bool haptic;
  final double borderOpacity;
  final AlignmentGeometry? alignment;
  final String? semanticLabel;

  @override
  State<LumiGlass> createState() => _LumiGlassState();
}

class _LumiGlassState extends State<LumiGlass> {
  static final Map<int, ImageFilter> _filterCache = {};

  bool _pressed = false;

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  static ImageFilter _resolveGlassFilter(double sigma) {
    final step = (sigma * 2).round().clamp(1, 20);
    final cached = _filterCache[step];
    if (cached != null) return cached;
    if (_filterCache.length > 20) {
      _filterCache.clear();
    }
    final clampedSigma = step / 2.0;
    final built = ImageFilter.blur(
      sigmaX: clampedSigma,
      sigmaY: clampedSigma,
      tileMode: TileMode.mirror,
    );
    _filterCache[step] = built;
    return built;
  }

  void _setPressed(bool value) {
    if (!_interactive || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (widget.haptic) {
      final scope = LumiDesignScope.maybeOf(context);
      if (scope?.hapticsEnabled ?? true) {
        HapticFeedback.lightImpact();
      }
    }
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (widget.haptic) {
      final scope = LumiDesignScope.maybeOf(context);
      if (scope?.hapticsEnabled ?? true) {
        HapticFeedback.mediumImpact();
      }
    }
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scope = LumiDesignScope.maybeOf(context);
    final osHighContrast = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .highContrast;
    final reduceTransparency =
        (scope?.reduceTransparency ?? ext.reduceTransparency) || osHighContrast;
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: scope?.reduceMotion ?? ext.reduceMotion,
    );

    final radius = BorderRadius.circular(widget.borderRadius);
    final effectiveBlur =
        (!widget.useBlur || reduceTransparency || widget.blur <= 0)
        ? 0.0
        : widget.blur.clamp(0.0, 10.0);

    final baseTop = widget.elevated
        ? ext.glassElevatedFillTop
        : ext.glassFillTop;
    final baseBottom = widget.elevated
        ? ext.glassElevatedFillBottom
        : ext.glassFillBottom;

    final tint = widget.tintColor;
    var fillTop = tint == null
        ? baseTop
        : Color.alphaBlend(
            tint.withValues(alpha: widget.elevated ? 0.22 : 0.14),
            baseTop,
          );
    var fillBottom = tint == null
        ? baseBottom
        : Color.alphaBlend(
            tint.withValues(alpha: widget.elevated ? 0.11 : 0.06),
            baseBottom,
          );

    final solidSurface = tint == null
        ? ext.glassSolidFallback
        : Color.alphaBlend(
            tint.withValues(alpha: 0.18),
            ext.glassSolidFallback,
          );

    if (effectiveBlur <= 0 && !reduceTransparency) {
      fillTop = Color.lerp(fillTop, solidSurface, isDark ? 0.14 : 0.18)!;
      fillBottom = Color.lerp(fillBottom, solidSurface, isDark ? 0.10 : 0.12)!;
    }

    final paintShadow =
        widget.hasShadow ?? (effectiveBlur > 0 || widget.elevated);

    final clipped = ClipRRect(
      borderRadius: radius,
      child: _buildSurfaceBody(
        context: context,
        isDark: isDark,
        radius: radius,
        effectiveBlur: effectiveBlur,
        reduceTransparency: reduceTransparency,
        fillTop: fillTop,
        fillBottom: fillBottom,
        solidSurface: solidSurface,
        ext: ext,
      ),
    );

    Widget surface;
    if (paintShadow) {
      final shadowBlur = widget.elevated ? 14.0 : 8.0;
      final shadowOffset = widget.elevated
          ? const Offset(0, 6)
          : const Offset(0, 3);
      surface = Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: ext.glassShadow,
              blurRadius: shadowBlur,
              offset: shadowOffset,
              spreadRadius: -3,
            ),
          ],
        ),
        child: clipped,
      );
    } else if (widget.width != null ||
        widget.height != null ||
        widget.margin != null) {
      surface = Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        child: clipped,
      );
    } else {
      surface = clipped;
    }

    if (_interactive) {
      surface = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap != null ? _handleTap : null,
        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
        child: AnimatedScale(
          scale: _pressed && !reduceMotion ? 0.976 : 1.0,
          duration: reduceMotion ? Duration.zero : LumiMotion.fast,
          curve: LumiMotion.spring,
          child: surface,
        ),
      );
    }

    if (widget.semanticLabel != null) {
      surface = Semantics(
        label: widget.semanticLabel,
        button: widget.onTap != null,
        child: surface,
      );
    }

    if (effectiveBlur > 0 || widget.elevated) {
      return RepaintBoundary(child: surface);
    }
    return surface;
  }

  Widget _buildSurfaceBody({
    required BuildContext context,
    required bool isDark,
    required BorderRadius radius,
    required double effectiveBlur,
    required bool reduceTransparency,
    required Color fillTop,
    required Color fillBottom,
    required Color solidSurface,
    required LumiThemeExtension ext,
  }) {
    final isLiquidChrome = effectiveBlur > 0 || widget.elevated;
    final topBorder = ext.glassBorderTopLeft.withValues(
      alpha: (ext.glassBorderTopLeft.a * widget.borderOpacity).clamp(0, 1),
    );
    final bottomBorder = ext.glassBorderBottomRight.withValues(
      alpha: (ext.glassBorderBottomRight.a * widget.borderOpacity).clamp(0, 1),
    );

    // Fast-path cards use a single BoxDecoration with zero CustomPainter shaders.
    if (!isLiquidChrome) {
      return Container(
        alignment: widget.alignment,
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: reduceTransparency ? solidSurface : null,
          gradient: reduceTransparency
              ? null
              : LinearGradient(
                  begin: const Alignment(-0.85, -1.0),
                  end: const Alignment(0.85, 1.0),
                  colors: [fillTop, fillBottom],
                ),
          border: Border.all(
            color: Color.lerp(topBorder, bottomBorder, 0.48)!,
            width: 1.0,
          ),
        ),
        child: Material(type: MaterialType.transparency, child: widget.child),
      );
    }

    final content = CustomPaint(
      painter: LumiLiquidLensPainter(
        borderRadius: widget.borderRadius,
        isDark: isDark,
        showOpticalSheen: !reduceTransparency,
        topLeftColor: topBorder,
        bottomRightColor: bottomBorder,
        innerHighlight: ext.glassInnerHighlight,
      ),
      child: Container(
        alignment: widget.alignment,
        padding: widget.padding,
        decoration: reduceTransparency
            ? BoxDecoration(color: solidSurface)
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.7, -1.0),
                  end: const Alignment(0.7, 1.0),
                  colors: [fillTop, fillBottom],
                ),
              ),
        child: Material(type: MaterialType.transparency, child: widget.child),
      ),
    );

    if (effectiveBlur <= 0) {
      return content;
    }

    final filter = _resolveGlassFilter(effectiveBlur);
    final useGrouped = widget.grouped && BackdropGroup.of(context) != null;

    if (useGrouped) {
      return BackdropFilter.grouped(filter: filter, child: content);
    }

    return BackdropFilter(filter: filter, child: content);
  }
}

/// Paints FreeFrontend-inspired Apple Liquid Glass lens caustics:
/// 1. Upper dome reflection sheen.
/// 2. 45-degree opposing bright white corner caustics (`0% -> 25%` & `75% -> 100%`).
/// 3. Subtle refractive edge contour (`rgba(0,0,0,0.14)` light / crisp halo).
/// 4. Inner `.circle-overlay` bevel halo (`inset ~4px`).
class LumiLiquidLensPainter extends CustomPainter {
  const LumiLiquidLensPainter({
    required this.borderRadius,
    required this.isDark,
    required this.showOpticalSheen,
    required this.topLeftColor,
    required this.bottomRightColor,
    required this.innerHighlight,
  });

  final double borderRadius;
  final bool isDark;
  final bool showOpticalSheen;
  final Color topLeftColor;
  final Color bottomRightColor;
  final Color innerHighlight;

  RRect _rrectFor(Rect rect, double r) {
    final maxR = rect.shortestSide / 2.0;
    final effective = r >= 100 ? maxR : r.clamp(0.0, maxR);
    return RRect.fromRectAndRadius(rect, Radius.circular(effective));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final outerRect = rect.deflate(0.6);

    if (showOpticalSheen && rect.height >= 20) {
      // Upper optical dome reflection wash
      final sheenPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: const Alignment(0, -0.05),
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.11 : 0.30),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(rect);
      canvas.drawRRect(_rrectFor(outerRect, borderRadius), sheenPaint);

      // Subtle dark/neutral lower crystal depth rim (inspired by .box:before)
      final contourPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.55, 1.0],
          colors: [
            Colors.transparent,
            Colors.transparent,
            (isDark ? Colors.black : const Color(0xFF0F172A)).withValues(
              alpha: isDark ? 0.28 : 0.10,
            ),
          ],
        ).createShader(rect);
      canvas.drawRRect(
        _rrectFor(rect.deflate(0.35), borderRadius),
        contourPaint,
      );
    }

    // 45° opposing corner caustics (top-left bright <-> middle whisper <-> bottom-right bright)
    final causticBright = Colors.white.withValues(alpha: isDark ? 0.54 : 0.88);
    final causticOpposite = Colors.white.withValues(
      alpha: isDark ? 0.38 : 0.72,
    );
    final midWhisper = Color.lerp(
      topLeftColor,
      Colors.transparent,
      isDark ? 0.82 : 0.74,
    )!;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.22, 0.50, 0.78, 1.0],
        colors: [
          Color.lerp(topLeftColor, causticBright, 0.5)!,
          midWhisper,
          Colors.white.withValues(alpha: isDark ? 0.05 : 0.10),
          midWhisper,
          Color.lerp(bottomRightColor, causticOpposite, 0.55)!,
        ],
      ).createShader(rect);
    canvas.drawRRect(_rrectFor(outerRect, borderRadius), borderPaint);

    // Inner optical .circle-overlay halo
    final insetRect = rect.deflate(2.2);
    if (insetRect.width > 16 && insetRect.height > 12) {
      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.38, 0.78, 1.0],
          colors: [
            innerHighlight,
            Colors.transparent,
            Colors.transparent,
            showOpticalSheen
                ? Colors.white.withValues(alpha: isDark ? 0.14 : 0.28)
                : Colors.transparent,
          ],
        ).createShader(insetRect);
      canvas.drawRRect(
        _rrectFor(insetRect, (borderRadius - 1.6).clamp(0, 999)),
        innerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LumiLiquidLensPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isDark != isDark ||
        oldDelegate.showOpticalSheen != showOpticalSheen ||
        oldDelegate.topLeftColor != topLeftColor ||
        oldDelegate.bottomRightColor != bottomRightColor ||
        oldDelegate.innerHighlight != innerHighlight;
  }
}
