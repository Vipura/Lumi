import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Core Apple-inspired Liquid Glass container built with `ClipRSuperellipse`,
/// vibrant `BackdropFilter` composition (`ColorFilter.matrix` + Gaussian blur),
/// multi-stop diagonal specular/caustic rim, inner bevel sheen, and optional
/// press-scale + light haptic.
class LumiGlass extends StatefulWidget {
  const LumiGlass({
    super.key,
    required this.child,
    this.borderRadius = LumiRadius.md,
    this.blur = 16,
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

  /// Lightweight translucent content card without `BackdropFilter` or heavy
  /// per-item blurred shadows so long lists and grids stay locked at 60/120 fps.
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

// Apple Liquid Glass vibrancy saturation matrices (Rec.709 neutral-preserving).
const ColorFilter _kLightLiquidVibrancy = ColorFilter.matrix(<double>[
  1.378,
  -0.343,
  -0.035,
  0,
  5,
  -0.102,
  1.137,
  -0.035,
  0,
  5,
  -0.102,
  -0.343,
  1.445,
  0,
  5,
  0,
  0,
  0,
  1,
  0,
]);

const ColorFilter _kDarkLiquidVibrancy = ColorFilter.matrix(<double>[
  1.441,
  -0.401,
  -0.040,
  0,
  8,
  -0.119,
  1.159,
  -0.040,
  0,
  8,
  -0.119,
  -0.401,
  1.520,
  0,
  8,
  0,
  0,
  0,
  1,
  0,
]);

class _LumiGlassState extends State<LumiGlass> {
  static final Map<(bool, int), ImageFilter> _filterCache = {};

  bool _pressed = false;

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  static ImageFilter _resolveGlassFilter(bool isDark, double sigma) {
    final step = (sigma * 2).round().clamp(1, 48);
    final key = (isDark, step);
    final cached = _filterCache[key];
    if (cached != null) return cached;
    if (_filterCache.length > 24) {
      _filterCache.clear();
    }
    final clampedSigma = step / 2.0;
    final built = ImageFilter.compose(
      outer: ImageFilter.blur(
        sigmaX: clampedSigma,
        sigmaY: clampedSigma,
        tileMode: TileMode.mirror,
      ),
      inner: isDark ? _kDarkLiquidVibrancy : _kLightLiquidVibrancy,
    );
    _filterCache[key] = built;
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

    final isPill = widget.borderRadius >= 100;
    final radius = BorderRadius.circular(widget.borderRadius);
    final effectiveBlur =
        (!widget.useBlur || reduceTransparency || widget.blur <= 0)
        ? 0.0
        : widget.blur.clamp(0.0, 24.0);

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
            tint.withValues(alpha: widget.elevated ? 0.22 : 0.15),
            baseTop,
          );
    var fillBottom = tint == null
        ? baseBottom
        : Color.alphaBlend(
            tint.withValues(alpha: widget.elevated ? 0.12 : 0.07),
            baseBottom,
          );

    final solidSurface = tint == null
        ? ext.glassSolidFallback
        : Color.alphaBlend(
            tint.withValues(alpha: 0.18),
            ext.glassSolidFallback,
          );

    // Subtle frosted density lift for lightweight cards without BackdropFilter.
    if (effectiveBlur <= 0 && !reduceTransparency) {
      fillTop = Color.lerp(fillTop, solidSurface, isDark ? 0.14 : 0.18)!;
      fillBottom = Color.lerp(fillBottom, solidSurface, isDark ? 0.10 : 0.12)!;
    }

    final paintShadow =
        widget.hasShadow ?? (effectiveBlur > 0 || widget.elevated);

    final clipped = isPill
        ? ClipRRect(
            borderRadius: radius,
            child: _buildBackdropOrFallback(
              context: context,
              isDark: isDark,
              isPill: true,
              effectiveBlur: effectiveBlur,
              reduceTransparency: reduceTransparency,
              fillTop: fillTop,
              fillBottom: fillBottom,
              solidSurface: solidSurface,
              ext: ext,
            ),
          )
        : ClipRSuperellipse(
            borderRadius: radius,
            child: _buildBackdropOrFallback(
              context: context,
              isDark: isDark,
              isPill: false,
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
      final shadowBlur = widget.elevated ? 18.0 : 10.0;
      final shadowOffset = widget.elevated
          ? const Offset(0, 8)
          : const Offset(0, 4);
      final shape = isPill
          ? RoundedRectangleBorder(borderRadius: radius)
          : RoundedSuperellipseBorder(borderRadius: radius);
      surface = Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: ShapeDecoration(
          shape: shape,
          shadows: [
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
          scale: _pressed && !reduceMotion ? 0.974 : 1.0,
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

    // Only isolate repaint boundaries on interactive, blurred, or elevated surfaces.
    if (effectiveBlur > 0 || widget.elevated || _interactive) {
      return RepaintBoundary(child: surface);
    }
    return surface;
  }

  Widget _buildBackdropOrFallback({
    required BuildContext context,
    required bool isDark,
    required bool isPill,
    required double effectiveBlur,
    required bool reduceTransparency,
    required Color fillTop,
    required Color fillBottom,
    required Color solidSurface,
    required LumiThemeExtension ext,
  }) {
    final isLiquidChrome = effectiveBlur > 0 || widget.elevated;
    final content = CustomPaint(
      painter: _LumiBorderPainter(
        borderRadius: widget.borderRadius,
        isPill: isPill,
        isDark: isDark,
        showOpticalSheen: !reduceTransparency && isLiquidChrome,
        topLeftColor: ext.glassBorderTopLeft.withValues(
          alpha: (ext.glassBorderTopLeft.a * widget.borderOpacity).clamp(0, 1),
        ),
        bottomRightColor: ext.glassBorderBottomRight.withValues(
          alpha: (ext.glassBorderBottomRight.a * widget.borderOpacity).clamp(
            0,
            1,
          ),
        ),
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

    final filter = _resolveGlassFilter(isDark, effectiveBlur);
    final useGrouped = widget.grouped && BackdropGroup.of(context) != null;

    if (useGrouped) {
      return BackdropFilter.grouped(filter: filter, child: content);
    }

    return BackdropFilter(filter: filter, child: content);
  }
}

class _LumiBorderPainter extends CustomPainter {
  const _LumiBorderPainter({
    required this.borderRadius,
    required this.isPill,
    required this.isDark,
    required this.showOpticalSheen,
    required this.topLeftColor,
    required this.bottomRightColor,
    required this.innerHighlight,
  });

  final double borderRadius;
  final bool isPill;
  final bool isDark;
  final bool showOpticalSheen;
  final Color topLeftColor;
  final Color bottomRightColor;
  final Color innerHighlight;

  void _strokeShape(Canvas canvas, Rect rect, double radiusValue, Paint paint) {
    if (isPill) {
      final capsuleRadius = Radius.circular(rect.shortestSide / 2.0);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, capsuleRadius), paint);
    } else {
      canvas.drawRSuperellipse(
        RSuperellipse.fromRectAndRadius(rect, Radius.circular(radiusValue)),
        paint,
      );
    }
  }

  void _fillShape(Canvas canvas, Rect rect, double radiusValue, Paint paint) {
    if (isPill) {
      final capsuleRadius = Radius.circular(rect.shortestSide / 2.0);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, capsuleRadius), paint);
    } else {
      canvas.drawRSuperellipse(
        RSuperellipse.fromRectAndRadius(rect, Radius.circular(radiusValue)),
        paint,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final outerRect = rect.deflate(0.55);

    // Subtle upper optical lens dome highlight inside floating glass chrome.
    if (showOpticalSheen && rect.height >= 24) {
      final sheenPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: const Alignment(0, -0.05),
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.085 : 0.24),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(rect);
      _fillShape(canvas, outerRect, borderRadius, sheenPaint);
    }

    // Diagonal multi-stop specular rim + secondary caustic bounce gleam.
    final midEdge = Color.lerp(
      topLeftColor,
      Colors.transparent,
      isDark ? 0.78 : 0.68,
    )!;
    final faintSide = topLeftColor.withValues(alpha: topLeftColor.a * 0.14);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.26, 0.52, 0.78, 1.0],
        colors: [
          topLeftColor,
          midEdge,
          faintSide,
          Color.lerp(bottomRightColor, midEdge, 0.35)!,
          bottomRightColor,
        ],
      ).createShader(rect);
    _strokeShape(canvas, outerRect, borderRadius, borderPaint);

    // Subtle internal glass edge refraction line along the upper & lower bevel.
    final insetRect = rect.deflate(1.65);
    if (insetRect.width > 16 && insetRect.height > 10) {
      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.36, 0.78, 1.0],
          colors: [
            innerHighlight,
            Colors.transparent,
            Colors.transparent,
            showOpticalSheen
                ? bottomRightColor.withValues(alpha: bottomRightColor.a * 0.35)
                : Colors.transparent,
          ],
        ).createShader(insetRect);
      _strokeShape(
        canvas,
        insetRect,
        (borderRadius - 1.1).clamp(0, 999),
        innerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LumiBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isPill != isPill ||
        oldDelegate.isDark != isDark ||
        oldDelegate.showOpticalSheen != showOpticalSheen ||
        oldDelegate.topLeftColor != topLeftColor ||
        oldDelegate.bottomRightColor != bottomRightColor ||
        oldDelegate.innerHighlight != innerHighlight;
  }
}
