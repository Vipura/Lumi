import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Core Liquid Glass container built with `ClipRRect`, `BackdropFilter`,
/// translucent gradient fill, 1px directional rim border, inner specular
/// highlight, soft outer shadow, and optional press-scale + light haptic.
class LumiGlass extends StatefulWidget {
  const LumiGlass({
    super.key,
    required this.child,
    this.borderRadius = LumiRadius.md,
    this.blur = 24,
    this.tintColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.elevated = false,
    this.useBlur = true,
    this.haptic = true,
    this.borderOpacity = 1.0,
    this.alignment,
    this.semanticLabel,
  });

  /// Lightweight translucent surface without `BackdropFilter` for long lists.
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
    this.haptic = true,
    this.borderOpacity = 0.85,
    this.alignment,
    this.semanticLabel,
  }) : blur = 0,
       useBlur = false;

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
  final bool haptic;
  final double borderOpacity;
  final AlignmentGeometry? alignment;
  final String? semanticLabel;

  @override
  State<LumiGlass> createState() => _LumiGlassState();
}

class _LumiGlassState extends State<LumiGlass> {
  bool _pressed = false;

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

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
        : widget.blur.clamp(0.0, 32.0);

    final baseTop = widget.elevated
        ? ext.glassElevatedFillTop
        : ext.glassFillTop;
    final baseBottom = widget.elevated
        ? ext.glassElevatedFillBottom
        : ext.glassFillBottom;

    final tint = widget.tintColor;
    final fillTop = tint == null
        ? baseTop
        : Color.alphaBlend(
            tint.withValues(alpha: widget.elevated ? 0.24 : 0.16),
            baseTop,
          );
    final fillBottom = tint == null
        ? baseBottom
        : Color.alphaBlend(
            tint.withValues(alpha: widget.elevated ? 0.14 : 0.08),
            baseBottom,
          );

    final solidSurface = tint == null
        ? ext.glassSolidFallback
        : Color.alphaBlend(
            tint.withValues(alpha: 0.18),
            ext.glassSolidFallback,
          );

    final shadowBlur = widget.elevated ? 28.0 : 18.0;
    final shadowOffset = widget.elevated
        ? const Offset(0, 12)
        : const Offset(0, 6);

    Widget surface = Container(
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
            spreadRadius: -4,
          ),
          if (widget.elevated && tint != null)
            BoxShadow(
              color: tint.withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 6),
              spreadRadius: -6,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: _buildBackdropOrFallback(
          effectiveBlur: effectiveBlur,
          reduceTransparency: reduceTransparency,
          fillTop: fillTop,
          fillBottom: fillBottom,
          solidSurface: solidSurface,
          ext: ext,
        ),
      ),
    );

    if (_interactive) {
      surface = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap != null ? _handleTap : null,
        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
        child: AnimatedScale(
          scale: _pressed && !reduceMotion ? 0.972 : 1.0,
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

    return RepaintBoundary(child: surface);
  }

  Widget _buildBackdropOrFallback({
    required double effectiveBlur,
    required bool reduceTransparency,
    required Color fillTop,
    required Color fillBottom,
    required Color solidSurface,
    required LumiThemeExtension ext,
  }) {
    final content = CustomPaint(
      painter: _LumiBorderPainter(
        borderRadius: widget.borderRadius,
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [fillTop, fillBottom],
                ),
              ),
        child: Material(type: MaterialType.transparency, child: widget.child),
      ),
    );

    if (effectiveBlur <= 0) {
      return content;
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
      child: content,
    );
  }
}

class _LumiBorderPainter extends CustomPainter {
  const _LumiBorderPainter({
    required this.borderRadius,
    required this.topLeftColor,
    required this.bottomRightColor,
    required this.innerHighlight,
  });

  final double borderRadius;
  final Color topLeftColor;
  final Color bottomRightColor;
  final Color innerHighlight;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      Radius.circular(borderRadius),
    );

    // 1px directional gradient border (bright top-left, soft bottom-right).
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [topLeftColor, bottomRightColor],
      ).createShader(rect);
    canvas.drawRRect(rrect, borderPaint);

    // Subtle inner top highlight line.
    final insetRect = rect.deflate(1.5);
    if (insetRect.width > 16 && insetRect.height > 8) {
      final innerRRect = RRect.fromRectAndRadius(
        insetRect,
        Radius.circular((borderRadius - 1).clamp(0, 999)),
      );
      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [innerHighlight, Colors.transparent],
        ).createShader(insetRect);
      canvas.drawRRect(innerRRect, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LumiBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.topLeftColor != topLeftColor ||
        oldDelegate.bottomRightColor != bottomRightColor ||
        oldDelegate.innerHighlight != innerHighlight;
  }
}
