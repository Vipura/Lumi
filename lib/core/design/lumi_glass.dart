import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Returns `true` if the current platform supports GPU-accelerated
/// BackdropFilter blur efficiently (iOS, Android, macOS, Windows, Linux).
/// Web CanvasKit/HTML falls back to expensive DOM filters that cause frame drops.
bool get _platformSupportsBlur => !kIsWeb;

/// Apple platforms & Android render continuous superellipses natively/cleanly;
/// Windows & Linux Skia paths use hardware fast-path `RRect` geometry to avoid
/// CPU path tessellation and software shadow mask overhead during scroll.
bool get _platformUsesSuperellipse =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.android);

/// Optical glass clarity modes inspired by Apple's SwiftUI `Glass` styles
/// (`Glass.regular` and `Glass.clear`).
enum LumiGlassVariant {
  /// Balanced translucent frosted glass for floating navigation and overlays.
  regular,

  /// High-transparency optical glass with crisp specular rims for media/lenses.
  clear,
}

/// Core Apple Liquid Glass surface following Apple's Adopting Liquid Glass
/// architecture:
/// - Floating navigation & chrome layer uses single-pass clamped optical blur
///   (`TileMode.clamp`), continuous superellipse corners (`RSuperellipse`), and
///   luminous Fresnel edge highlights.
/// - Content layer (`LumiGlass.card`) skips `BackdropFilter`, redundant clip
///   masks, and per-frame shader allocations so scrolling stays locked at
///   60/120 fps across all devices.
class LumiGlass extends StatefulWidget {
  const LumiGlass({
    super.key,
    required this.child,
    this.borderRadius = LumiRadius.md,
    this.blur = 20.0,
    this.variant = LumiGlassVariant.regular,
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
    this.clipContent = false,
    this.haptic = true,
    this.borderOpacity = 1.0,
    this.alignment,
    this.semanticLabel,
  });

  /// Lightweight translucent content card without `BackdropFilter`, clip
  /// masks, or per-item CustomPaint shader allocations so long lists stay at
  /// 60/120 fps on every platform.
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
    this.clipContent = false,
    this.haptic = true,
    this.borderOpacity = 0.85,
    this.alignment,
    this.semanticLabel,
  }) : blur = 0,
       variant = LumiGlassVariant.regular,
       useBlur = false,
       grouped = false;

  final Widget child;
  final double borderRadius;
  final double blur;
  final LumiGlassVariant variant;
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

  /// Whether unblurred cards/panels clip overflowing children. Blurred surfaces
  /// always clip to confine the `BackdropFilter` sample region.
  final bool clipContent;

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
    final step = (sigma * 2).round().clamp(1, 64);
    final cached = _filterCache[step];
    if (cached != null) return cached;
    if (_filterCache.length > 64) {
      _filterCache.clear();
    }
    final clampedSigma = step / 2.0;
    // TileMode.clamp keeps GPU sampling strictly bounded across Impeller,
    // Skia, Web CanvasKit, Android, macOS, and Windows without mirror artifacts.
    final built = ImageFilter.blur(
      sigmaX: clampedSigma,
      sigmaY: clampedSigma,
      tileMode: TileMode.clamp,
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

    final isPill = widget.borderRadius >= 100;
    final radius = BorderRadius.circular(widget.borderRadius);
    // Render GPU-accelerated BackdropFilter blur on native platforms (iOS,
    // Android, macOS, Windows, Linux). Web CanvasKit/HTML skips live blur.
    final effectiveBlur =
        (!widget.useBlur ||
            reduceTransparency ||
            widget.blur <= 0 ||
            !_platformSupportsBlur)
        ? 0.0
        : widget.blur.clamp(0.0, 32.0);

    final baseTop = widget.elevated
        ? ext.glassElevatedFillTop
        : ext.glassFillTop;
    final baseBottom = widget.elevated
        ? ext.glassElevatedFillBottom
        : ext.glassFillBottom;

    final isClear = widget.variant == LumiGlassVariant.clear;
    var fillTop = isClear
        ? baseTop.withValues(alpha: baseTop.a * (isDark ? 0.58 : 0.65))
        : baseTop;
    var fillBottom = isClear
        ? baseBottom.withValues(alpha: baseBottom.a * (isDark ? 0.50 : 0.58))
        : baseBottom;

    final tint = widget.tintColor;
    if (tint != null) {
      fillTop = Color.alphaBlend(
        tint.withValues(alpha: widget.elevated ? 0.22 : 0.14),
        fillTop,
      );
      fillBottom = Color.alphaBlend(
        tint.withValues(alpha: widget.elevated ? 0.11 : 0.06),
        fillBottom,
      );
    }

    final solidSurface = tint == null
        ? ext.glassSolidFallback
        : Color.alphaBlend(
            tint.withValues(alpha: 0.18),
            ext.glassSolidFallback,
          );

    if (effectiveBlur <= 0 && !reduceTransparency && !isClear) {
      if (widget.useBlur && !_platformSupportsBlur && widget.elevated) {
        // Desktop frosted substitute (sheets, dialogs, floating rail/bars)
        // blends enough solid surface to stay crisp and legible without blur.
        final topBlend = !widget.grouped ? (isDark ? 0.72 : 0.76) : 0.36;
        final bottomBlend = !widget.grouped ? (isDark ? 0.62 : 0.66) : 0.28;
        fillTop = Color.lerp(fillTop, solidSurface, topBlend)!;
        fillBottom = Color.lerp(fillBottom, solidSurface, bottomBlend)!;
      } else {
        fillTop = Color.lerp(fillTop, solidSurface, isDark ? 0.12 : 0.16)!;
        fillBottom = Color.lerp(
          fillBottom,
          solidSurface,
          isDark ? 0.08 : 0.11,
        )!;
      }
    }

    final useRRectShape = isPill || !_platformUsesSuperellipse;
    final paintShadow =
        widget.hasShadow ?? (effectiveBlur > 0 || widget.elevated);
    final needsClip = effectiveBlur > 0 || widget.clipContent;

    final body = _buildSurfaceBody(
      context: context,
      isDark: isDark,
      useRRectShape: useRRectShape,
      radius: radius,
      effectiveBlur: effectiveBlur,
      reduceTransparency: reduceTransparency,
      fillTop: fillTop,
      fillBottom: fillBottom,
      solidSurface: solidSurface,
      ext: ext,
    );

    final Widget maybeClipped;
    if (!needsClip) {
      maybeClipped = body;
    } else if (useRRectShape) {
      maybeClipped = ClipRRect(borderRadius: radius, child: body);
    } else {
      maybeClipped = ClipRSuperellipse(borderRadius: radius, child: body);
    }

    final OutlinedBorder outerShape = useRRectShape
        ? RoundedRectangleBorder(borderRadius: radius)
        : RoundedSuperellipseBorder(borderRadius: radius);

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
        decoration: ShapeDecoration(
          shape: outerShape,
          shadows: [
            BoxShadow(
              color: ext.glassShadow,
              blurRadius: shadowBlur,
              offset: shadowOffset,
              spreadRadius: -4,
            ),
          ],
        ),
        child: maybeClipped,
      );
    } else if (widget.width != null ||
        widget.height != null ||
        widget.margin != null) {
      surface = Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        child: maybeClipped,
      );
    } else {
      surface = maybeClipped;
    }

    // Isolate blurred / elevated chrome into its own composited layer inside
    // any interactive transform so press-scale never re-rasters painters.
    if (effectiveBlur > 0 || widget.elevated) {
      surface = RepaintBoundary(child: surface);
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

    return surface;
  }

  Widget _buildSurfaceBody({
    required BuildContext context,
    required bool isDark,
    required bool useRRectShape,
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

    // Fast-path cards use a single ShapeDecoration with zero CustomPainter
    // shader allocations and zero clip masks.
    if (!isLiquidChrome) {
      final borderSide = BorderSide(
        color: Color.lerp(topBorder, bottomBorder, 0.45)!,
        width: 1.0,
      );
      final shape = useRRectShape
          ? RoundedRectangleBorder(borderRadius: radius, side: borderSide)
          : RoundedSuperellipseBorder(borderRadius: radius, side: borderSide);

      return Container(
        alignment: widget.alignment,
        padding: widget.padding,
        decoration: ShapeDecoration(
          shape: shape,
          color: reduceTransparency ? solidSurface : null,
          gradient: reduceTransparency
              ? null
              : LinearGradient(
                  begin: const Alignment(-0.85, -1.0),
                  end: const Alignment(0.85, 1.0),
                  colors: [fillTop, fillBottom],
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
            ? ShapeDecoration(
                color: solidSurface,
                shape: useRRectShape
                    ? RoundedRectangleBorder(borderRadius: radius)
                    : RoundedSuperellipseBorder(borderRadius: radius),
              )
            : ShapeDecoration(
                shape: useRRectShape
                    ? RoundedRectangleBorder(borderRadius: radius)
                    : RoundedSuperellipseBorder(borderRadius: radius),
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

/// Groups nearby floating navigation or toolbar controls inside one unified
/// Apple Liquid Glass capsule (`GlassEffectContainer` equivalent), ensuring a
/// single optical backdrop pass instead of N separate per-button blurs.
class LumiGlassEffectContainer extends StatelessWidget {
  const LumiGlassEffectContainer({
    super.key,
    required this.children,
    this.spacing = 2,
    this.showDividers = true,
    this.useBlur = true,
    this.blur = 20.0,
    this.borderRadius = LumiRadius.pill,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    this.tintColor,
    this.hasShadow = true,
  });

  final List<Widget> children;
  final double spacing;
  final bool showDividers;
  final bool useBlur;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? tintColor;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final dividerColor = context.lumiTheme.inkMuted.withValues(alpha: 0.18);
    final rowChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rowChildren.add(children[i]);
      if (i < children.length - 1) {
        if (showDividers) {
          rowChildren.add(
            Container(
              width: 1,
              height: 18,
              margin: EdgeInsets.symmetric(horizontal: spacing / 2),
              color: dividerColor,
            ),
          );
        } else if (spacing > 0) {
          rowChildren.add(SizedBox(width: spacing));
        }
      }
    }

    return LumiGlass(
      borderRadius: borderRadius,
      useBlur: useBlur,
      blur: useBlur ? blur : 0,
      elevated: true,
      hasShadow: hasShadow,
      grouped: false,
      tintColor: tintColor,
      padding: padding,
      child: Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
    );
  }
}

/// Subtle edge-feather scrim inspired by Apple's `scrollEdgeEffect` modifier,
/// softening scrolled content behind floating Liquid Glass tab/tool bars.
class LumiScrollEdge extends StatelessWidget {
  const LumiScrollEdge({
    super.key,
    this.alignment = Alignment.bottomCenter,
    this.height = 84,
  });

  final Alignment alignment;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fromTop = alignment.y <= 0;
    final baseColor = (isDark ? LumiColors.darkCanvas : LumiColors.lightCanvas)
        .withValues(alpha: isDark ? 0.56 : 0.62);

    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
              end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [
                baseColor,
                baseColor.withValues(alpha: isDark ? 0.24 : 0.26),
                baseColor.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _LensPaintCacheKey {
  const _LensPaintCacheKey({
    required this.w,
    required this.h,
    required this.borderRadius,
    required this.isDark,
    required this.showOpticalSheen,
    required this.topLeftArgb,
    required this.bottomRightArgb,
    required this.innerHighlightArgb,
  });

  final int w;
  final int h;
  final int borderRadius;
  final bool isDark;
  final bool showOpticalSheen;
  final int topLeftArgb;
  final int bottomRightArgb;
  final int innerHighlightArgb;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _LensPaintCacheKey &&
            other.w == w &&
            other.h == h &&
            other.borderRadius == borderRadius &&
            other.isDark == isDark &&
            other.showOpticalSheen == showOpticalSheen &&
            other.topLeftArgb == topLeftArgb &&
            other.bottomRightArgb == bottomRightArgb &&
            other.innerHighlightArgb == innerHighlightArgb);
  }

  @override
  int get hashCode => Object.hash(
    w,
    h,
    borderRadius,
    isDark,
    showOpticalSheen,
    topLeftArgb,
    bottomRightArgb,
    innerHighlightArgb,
  );
}

class _CachedLensResources {
  const _CachedLensResources({
    required this.isPill,
    required this.outerRRect,
    required this.insetRRect,
    required this.outerSuperellipse,
    required this.insetSuperellipse,
    required this.sheenPaint,
    required this.borderPaint,
    required this.innerPaint,
  });

  final bool isPill;
  final RRect? outerRRect;
  final RRect? insetRRect;
  final RSuperellipse? outerSuperellipse;
  final RSuperellipse? insetSuperellipse;
  final Paint? sheenPaint;
  final Paint borderPaint;
  final Paint? innerPaint;
}

/// Paints crisp Apple Liquid Glass optical lighting & Fresnel edge reflections:
/// 1. Clean upper crystal dome wash (zero muddy underside contours).
/// 2. Diagonal Fresnel specular perimeter peak at curved corners, tapering
///    gracefully along straight edges.
/// 3. Delicate inner top-edge optical lip.
///
/// Shaders and rounded/superellipse geometries are memoized in a bounded LRU
/// cache keyed by quantized size & colors to eliminate per-frame allocations.
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

  static final LinkedHashMap<_LensPaintCacheKey, _CachedLensResources> _cache =
      LinkedHashMap<_LensPaintCacheKey, _CachedLensResources>();

  _CachedLensResources _resolveResources(Size size) {
    final key = _LensPaintCacheKey(
      w: (size.width * 2).round(),
      h: (size.height * 2).round(),
      borderRadius: borderRadius.round(),
      isDark: isDark,
      showOpticalSheen: showOpticalSheen,
      topLeftArgb: topLeftColor.toARGB32(),
      bottomRightArgb: bottomRightColor.toARGB32(),
      innerHighlightArgb: innerHighlight.toARGB32(),
    );

    final hit = _cache.remove(key);
    if (hit != null) {
      _cache[key] = hit;
      return hit;
    }

    final rect = Offset.zero & size;
    final outerRect = rect.deflate(0.55);
    final insetRect = rect.deflate(2.0);
    final isPill = borderRadius >= 100 || !_platformUsesSuperellipse;
    final maxR = outerRect.shortestSide / 2.0;
    final effectiveOuterR = borderRadius >= 100
        ? maxR
        : borderRadius.clamp(0.0, maxR);
    final effectiveInsetR = borderRadius >= 100
        ? (insetRect.shortestSide / 2.0)
        : (borderRadius - 1.5).clamp(0.0, insetRect.shortestSide / 2.0);

    final RRect? outerRRect = isPill
        ? RRect.fromRectAndRadius(outerRect, Radius.circular(effectiveOuterR))
        : null;
    final RSuperellipse? outerSuper = isPill
        ? null
        : RSuperellipse.fromRectAndRadius(
            outerRect,
            Radius.circular(effectiveOuterR),
          );

    final hasInner = insetRect.width > 14 && insetRect.height > 10;
    final RRect? insetRRect = (hasInner && isPill)
        ? RRect.fromRectAndRadius(insetRect, Radius.circular(effectiveInsetR))
        : null;
    final RSuperellipse? insetSuper = (hasInner && !isPill)
        ? RSuperellipse.fromRectAndRadius(
            insetRect,
            Radius.circular(effectiveInsetR),
          )
        : null;

    Paint? sheenPaint;
    if (showOpticalSheen && rect.height >= 20) {
      sheenPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: const Alignment(0, -0.10),
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.14),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(rect);
    }

    final causticTop = Colors.white.withValues(alpha: isDark ? 0.86 : 0.98);
    final causticBottom = Colors.white.withValues(alpha: isDark ? 0.62 : 0.88);
    final sideSilver = Colors.white.withValues(alpha: isDark ? 0.14 : 0.30);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.14, 0.50, 0.86, 1.0],
        colors: [
          Color.lerp(topLeftColor, causticTop, 0.65)!,
          Color.lerp(topLeftColor, sideSilver, 0.78)!,
          sideSilver.withValues(alpha: isDark ? 0.09 : 0.20),
          Color.lerp(bottomRightColor, sideSilver, 0.78)!,
          Color.lerp(bottomRightColor, causticBottom, 0.65)!,
        ],
      ).createShader(rect);

    Paint? innerPaint;
    if (hasInner) {
      innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.34, 0.76, 1.0],
          colors: [
            innerHighlight,
            Colors.transparent,
            Colors.transparent,
            showOpticalSheen
                ? Colors.white.withValues(alpha: isDark ? 0.14 : 0.26)
                : Colors.transparent,
          ],
        ).createShader(insetRect);
    }

    final built = _CachedLensResources(
      isPill: isPill,
      outerRRect: outerRRect,
      insetRRect: insetRRect,
      outerSuperellipse: outerSuper,
      insetSuperellipse: insetSuper,
      sheenPaint: sheenPaint,
      borderPaint: borderPaint,
      innerPaint: innerPaint,
    );

    if (_cache.length >= 64) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = built;
    return built;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final res = _resolveResources(size);

    if (res.sheenPaint != null) {
      if (res.isPill) {
        canvas.drawRRect(res.outerRRect!, res.sheenPaint!);
      } else {
        canvas.drawRSuperellipse(res.outerSuperellipse!, res.sheenPaint!);
      }
    }

    if (res.isPill) {
      canvas.drawRRect(res.outerRRect!, res.borderPaint);
    } else {
      canvas.drawRSuperellipse(res.outerSuperellipse!, res.borderPaint);
    }

    if (res.innerPaint != null) {
      if (res.isPill) {
        canvas.drawRRect(res.insetRRect!, res.innerPaint!);
      } else {
        canvas.drawRSuperellipse(res.insetSuperellipse!, res.innerPaint!);
      }
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
