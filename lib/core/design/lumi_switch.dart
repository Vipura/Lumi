import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Authentic Apple Liquid Glass toggle switch styled directly after iOS 26/27:
/// - Single `RepaintBoundary -> CustomPaint` inside fixed `64x44` bounds so
///   toggling and dragging perform zero widget rebuilds and zero relayouts.
/// - Rests as a crisp luminous optical pill; on press or drag, morphs into a
///   hollow refractive optical lens capsule revealing magnified track color and
///   a C-shaped meniscus refraction rim with top/bottom Fresnel highlights.
class LumiGlassSwitch extends StatefulWidget {
  const LumiGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final String? semanticLabel;

  @override
  State<LumiGlassSwitch> createState() => _LumiGlassSwitchState();
}

class _LumiGlassSwitchState extends State<LumiGlassSwitch>
    with TickerProviderStateMixin {
  static const double _trackWidth = 56.0;
  static const double _trackHeight = 28.0;

  late final AnimationController _slideCtrl;
  late final AnimationController _pressCtrl;
  late final Animation<double> _slideAnim;
  late final Animation<double> _pressAnim;

  bool _dragging = false;
  double _dragStartValue = 0.0;
  double _dragAccumDx = 0.0;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: widget.value ? 1.0 : 0.0,
    );
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 170),
      reverseDuration: const Duration(milliseconds: 210),
      value: 0.0,
    );
    _slideAnim = CurvedAnimation(
      parent: _slideCtrl,
      curve: LumiMotion.spring,
      reverseCurve: LumiMotion.spring,
    );
    _pressAnim = CurvedAnimation(
      parent: _pressCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant LumiGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_dragging) {
      final scope = LumiDesignScope.maybeOf(context);
      final reduceMotion = LumiMotion.shouldReduceMotion(
        context,
        setting: scope?.reduceMotion ?? context.lumiTheme.reduceMotion,
      );
      if (reduceMotion) {
        _slideCtrl.value = widget.value ? 1.0 : 0.0;
      } else {
        _slideCtrl.animateTo(widget.value ? 1.0 : 0.0);
      }
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    final scope = LumiDesignScope.maybeOf(context);
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: scope?.reduceMotion ?? context.lumiTheme.reduceMotion,
    );
    if (reduceMotion) {
      _pressCtrl.value = 0.0;
      return;
    }
    if (pressed) {
      _pressCtrl.forward();
    } else {
      _pressCtrl.reverse();
    }
  }

  void _toggle() {
    final cb = widget.onChanged;
    if (cb == null) return;
    final scope = LumiDesignScope.maybeOf(context);
    if (scope?.hapticsEnabled ?? true) {
      HapticFeedback.selectionClick();
    }
    cb(!widget.value);
  }

  void _handleDragStart(DragStartDetails details) {
    if (widget.onChanged == null) return;
    _dragging = true;
    _dragStartValue = _slideCtrl.value;
    _dragAccumDx = 0.0;
    _setPressed(true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    _dragAccumDx += details.delta.dx;
    // GestureDetector absorbs touch slop before dragStart fires, so remaining
    // visual travel across the track completes smoothly in ~12-14 logical px.
    const postSlopTravel = 12.0;
    final next = (_dragStartValue + (_dragAccumDx / postSlopTravel)).clamp(
      0.0,
      1.0,
    );
    _slideCtrl.value = next;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    _setPressed(false);

    final vx = details.primaryVelocity ?? 0;
    final bool target;
    if (vx.abs() > 60) {
      target = vx > 0;
    } else if (_dragStartValue >= 0.5 && _dragAccumDx <= -4.0) {
      target = false;
    } else if (_dragStartValue < 0.5 && _dragAccumDx >= 4.0) {
      target = true;
    } else if (_dragAccumDx.abs() < 4.0) {
      target = !widget.value;
    } else {
      target = _slideCtrl.value >= 0.5;
    }

    if (target != widget.value) {
      final scope = LumiDesignScope.maybeOf(context);
      if (scope?.hapticsEnabled ?? true) {
        HapticFeedback.selectionClick();
      }
      widget.onChanged?.call(target);
    } else {
      _slideCtrl.animateTo(widget.value ? 1.0 : 0.0);
    }
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
    final enabled = widget.onChanged != null;
    final onColor = widget.activeColor ?? ext.accentColor;

    final control = FocusableActionDetector(
      enabled: enabled,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _toggle();
            return null;
          },
        ),
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: enabled ? (_) => _setPressed(true) : null,
        onPointerUp: enabled ? (_) => _setPressed(false) : null,
        onPointerCancel: (_) => _setPressed(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: enabled ? _handleDragStart : null,
          onHorizontalDragUpdate: enabled ? _handleDragUpdate : null,
          onHorizontalDragEnd: enabled ? _handleDragEnd : null,
          onHorizontalDragCancel: () {
            _dragging = false;
            _setPressed(false);
            _slideCtrl.animateTo(widget.value ? 1.0 : 0.0);
          },
          onTap: enabled ? _toggle : null,
          child: SizedBox(
            width: 64,
            height: 44,
            child: Opacity(
              opacity: enabled ? 1.0 : 0.48,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: const Size(64, 44),
                  painter: _AppleLiquidSwitchPainter(
                    slide: _slideAnim,
                    press: _pressAnim,
                    isDark: isDark,
                    reduceTransparency: reduceTransparency,
                    onColor: onColor,
                    solidFallback: ext.glassSolidFallback,
                    trackWidth: _trackWidth,
                    trackHeight: _trackHeight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      toggled: widget.value,
      enabled: enabled,
      label: widget.semanticLabel,
      child: control,
    );
  }
}

class _AppleLiquidSwitchPainter extends CustomPainter {
  _AppleLiquidSwitchPainter({
    required this.slide,
    required this.press,
    required this.isDark,
    required this.reduceTransparency,
    required this.onColor,
    required this.solidFallback,
    required this.trackWidth,
    required this.trackHeight,
  }) : super(repaint: Listenable.merge([slide, press]));

  final Animation<double> slide;
  final Animation<double> press;
  final bool isDark;
  final bool reduceTransparency;
  final Color onColor;
  final Color solidFallback;
  final double trackWidth;
  final double trackHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final s = slide.value.clamp(0.0, 1.0);
    final p = press.value.clamp(0.0, 1.0);

    final center = Offset(size.width / 2, size.height / 2);
    final trackRect = Rect.fromCenter(
      center: center,
      width: trackWidth,
      height: trackHeight,
    );
    final trackRRect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(trackHeight / 2),
    );

    // Off & On track colors
    final offColor = reduceTransparency
        ? solidFallback
        : (isDark
              ? const Color(0xFF4C4C52).withValues(alpha: 0.78)
              : const Color(0xFFC8CCD6).withValues(alpha: 0.84));
    final vividOn = Color.lerp(onColor, Colors.white, isDark ? 0.06 : 0.12)!;
    final trackColor = Color.lerp(offColor, vividOn, s)!;

    // Subtle track glow when active
    if (s > 0.08 && !reduceTransparency) {
      final glowPaint = Paint()
        ..color = onColor.withValues(alpha: 0.24 * s)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawRRect(trackRRect.shift(const Offset(0, 1.5)), glowPaint);
    }

    // Track base fill
    final trackPaint = Paint()..color = trackColor;
    canvas.drawRRect(trackRRect, trackPaint);

    // Subtle top-to-bottom depth shade along track channel
    if (!reduceTransparency) {
      final depthPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
            Colors.transparent,
            Colors.white.withValues(alpha: isDark ? 0.06 : 0.16),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(trackRect);
      canvas.drawRRect(trackRRect, depthPaint);
    }

    // Track perimeter rim
    final trackBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = Color.lerp(
        Colors.white.withValues(alpha: isDark ? 0.18 : 0.55),
        Colors.white.withValues(alpha: 0.34),
        s,
      )!;
    canvas.drawRRect(trackRRect.deflate(0.45), trackBorder);

    // Thumb geometry: elongated white pill at rest -> slightly enlarged
    // overhanging optical glass lens capsule when pressed/dragged.
    const restW = 34.0;
    const restH = 22.0;
    const pressedW = 40.0;
    const pressedH = 30.0;

    final thumbW = lerpDouble(restW, pressedW, p)!;
    final thumbH = lerpDouble(restH, pressedH, p)!;

    const restInset = 3.0;
    const pressedInset = 0.5;
    final inset = lerpDouble(restInset, pressedInset, p)!;

    final leftCenterX = trackRect.left + inset + thumbW / 2;
    final rightCenterX = trackRect.right - inset - thumbW / 2;
    final thumbCenterX = lerpDouble(leftCenterX, rightCenterX, s)!;

    final thumbRect = Rect.fromCenter(
      center: Offset(thumbCenterX, center.dy),
      width: thumbW,
      height: thumbH,
    );
    final thumbRRect = RRect.fromRectAndRadius(
      thumbRect,
      Radius.circular(thumbH / 2),
    );

    // Thumb drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: lerpDouble(0.22, 0.34, p)!)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        lerpDouble(2.5, 4.0, p)!,
      );
    canvas.drawRRect(thumbRRect.shift(const Offset(0, 1.5)), shadowPaint);

    // Press-state hollow optical lens refraction (matches Attachment #2)
    final opticalPress = reduceTransparency ? 0.0 : p;
    if (opticalPress > 0.02) {
      canvas.save();
      canvas.clipRRect(thumbRRect);

      // Dark smoked optical glass bezel body (clear-dark on dark mode, soft
      // frosted silver-slate on light mode)
      final bezelFill = isDark
          ? const Color(0xFF282A2E).withValues(alpha: 0.86 * opticalPress)
          : const Color(0xFFE4E8F0).withValues(alpha: 0.82 * opticalPress);
      canvas.drawRect(thumbRect, Paint()..color = bezelFill);

      // Subtle bezel vertical sheen
      final bezelSheen = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(
              alpha: (isDark ? 0.14 : 0.35) * opticalPress,
            ),
            Colors.transparent,
            Colors.white.withValues(
              alpha: (isDark ? 0.08 : 0.22) * opticalPress,
            ),
          ],
        ).createShader(thumbRect);
      canvas.drawRect(thumbRect, bezelSheen);

      // Inner magnified liquid window centered slightly toward the active side
      // of the track so the C-shaped meniscus wraps cleanly inside the lens.
      final rimPadY = lerpDouble(4.0, 3.2, opticalPress)!;
      final leadingEdge = s >= 0.5 ? 1.0 : -1.0;
      final innerLeft = leadingEdge >= 0
          ? thumbRect.left - 2.0
          : thumbRect.left + 7.5;
      final innerRight = leadingEdge >= 0
          ? thumbRect.right - 7.5
          : thumbRect.right + 2.0;

      final windowRect = Rect.fromLTRB(
        innerLeft,
        thumbRect.top + rimPadY,
        innerRight,
        thumbRect.bottom - rimPadY,
      );
      final windowRRect = RRect.fromRectAndRadius(
        windowRect,
        Radius.circular(windowRect.height / 2),
      );

      final magnifiedColor = Color.lerp(
        trackColor,
        s > 0.3 ? vividOn : Colors.white,
        s > 0.3 ? 0.14 : 0.22,
      )!.withValues(alpha: opticalPress);

      canvas.drawRRect(windowRRect, Paint()..color = magnifiedColor);

      // Delicate inner caustic lip along the inner window curve
      final innerRim = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85
        ..color = Color.lerp(
          Colors.white,
          onColor,
          s * 0.45,
        )!.withValues(alpha: 0.55 * opticalPress);
      canvas.drawRRect(windowRRect.deflate(0.4), innerRim);

      canvas.restore();
    }

    // Resting luminous white optical pill fill fading out cleanly on press
    final restWhiteAlpha = 1.0 - opticalPress * 0.94;
    if (restWhiteAlpha > 0.01) {
      final whiteFill = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: restWhiteAlpha),
            Color.lerp(
              Colors.white,
              const Color(0xFFECEFF6),
              0.42,
            )!.withValues(alpha: restWhiteAlpha * 0.96),
          ],
        ).createShader(thumbRect);
      canvas.drawRRect(thumbRRect, whiteFill);
    }

    // Outer optical Fresnel specular rim (strongest top & bottom arcs, subtle
    // track tint glow bleeding into the inner edge on press)
    final outerRimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lerpDouble(0.85, 1.25, opticalPress)!
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.25, 0.75, 1.0],
        colors: [
          Color.lerp(
            Colors.white.withValues(alpha: 0.92),
            Color.lerp(Colors.white, vividOn, s * 0.40)!,
            opticalPress,
          )!,
          Colors.white.withValues(alpha: lerpDouble(0.25, 0.18, opticalPress)!),
          Colors.white.withValues(alpha: lerpDouble(0.22, 0.16, opticalPress)!),
          Color.lerp(
            Colors.white.withValues(alpha: 0.80),
            Color.lerp(Colors.white, vividOn, s * 0.35)!,
            opticalPress,
          )!,
        ],
      ).createShader(thumbRect);
    canvas.drawRRect(thumbRRect.deflate(0.5), outerRimPaint);
  }

  @override
  bool shouldRepaint(covariant _AppleLiquidSwitchPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.reduceTransparency != reduceTransparency ||
        oldDelegate.onColor != onColor ||
        oldDelegate.solidFallback != solidFallback ||
        oldDelegate.trackWidth != trackWidth ||
        oldDelegate.trackHeight != trackHeight;
  }
}

/// Accessible Liquid Glass switch row that replaces plain `SwitchListTile.adaptive`.
class LumiGlassSwitchTile extends StatelessWidget {
  const LumiGlassSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.leading,
    this.activeColor,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: LumiSpacing.md,
      vertical: 6,
    ),
  });

  final Widget title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;
  final Color? activeColor;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        borderRadius: BorderRadius.circular(LumiRadius.md),
        child: Padding(
          padding: contentPadding,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: LumiSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyLarge!,
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodySmall!,
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: LumiSpacing.xs),
              LumiGlassSwitch(
                value: value,
                onChanged: onChanged,
                activeColor: activeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
