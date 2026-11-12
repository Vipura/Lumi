import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// A single segment item descriptor for [LumiGlassSegmentedControl].
class LumiSegment<T> {
  const LumiSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Apple Liquid Glass segmented control inspired by Apple's iOS/macOS 26
/// "Adopting Liquid Glass" specification (`Picker` `.segmented` style):
/// - Frosted translucent pill track with hairline rim.
/// - Bright luminous frosted glass thumb that glides between segments with
///   spring physics on tap and follows the finger/pointer on horizontal drag.
/// - Interactive optical lift: pressing or dragging elevates the glass thumb
///   slightly with a brighter specular Fresnel rim.
/// - Works safely inside both unbounded [Row]s (auto-sized equal-width
///   segments) and bounded containers ([expanded: true]).
class LumiGlassSegmentedControl<T> extends StatefulWidget {
  const LumiGlassSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onChanged,
    this.showIcons = true,
    this.expanded = false,
    this.height = 38,
  }) : assert(segments.length >= 2, 'Need at least 2 segments');

  final List<LumiSegment<T>> segments;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final bool showIcons;
  final bool expanded;
  final double height;

  @override
  State<LumiGlassSegmentedControl<T>> createState() =>
      _LumiGlassSegmentedControlState<T>();
}

class _LumiGlassSegmentedControlState<T>
    extends State<LumiGlassSegmentedControl<T>>
    with TickerProviderStateMixin {
  late final AnimationController _posCtrl;
  late final AnimationController _liftCtrl;
  late final Animation<double> _liftAnim;

  late int _selectedIndex;
  bool _dragging = false;
  double _dragStartPos = 0.0;
  double _dragAccumDx = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _indexOfValue(widget.selectedValue);
    _posCtrl = AnimationController.unbounded(
      vsync: this,
      value: _selectedIndex.toDouble(),
    );
    _liftCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 220),
      value: 0.0,
    );
    _liftAnim = CurvedAnimation(
      parent: _liftCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant LumiGlassSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = _indexOfValue(widget.selectedValue);
    if (newIndex != _selectedIndex ||
        oldWidget.segments.length != widget.segments.length) {
      _selectedIndex = newIndex.clamp(0, widget.segments.length - 1);
      if (!_dragging) {
        _animateToIndex(_selectedIndex);
      }
    }
  }

  @override
  void dispose() {
    _posCtrl.dispose();
    _liftCtrl.dispose();
    super.dispose();
  }

  int _indexOfValue(T value) {
    final idx = widget.segments.indexWhere((s) => s.value == value);
    return idx < 0 ? 0 : idx;
  }

  bool _shouldReduceMotion(BuildContext context) {
    final scope = LumiDesignScope.maybeOf(context);
    return LumiMotion.shouldReduceMotion(
      context,
      setting: scope?.reduceMotion ?? context.lumiTheme.reduceMotion,
    );
  }

  void _animateToIndex(int index) {
    final target = index.toDouble();
    if (!mounted || _shouldReduceMotion(context)) {
      _posCtrl.value = target;
      return;
    }
    _posCtrl.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: LumiMotion.spring,
    );
  }

  void _setLift(bool active) {
    if (!mounted || _shouldReduceMotion(context)) {
      _liftCtrl.value = 0.0;
      return;
    }
    if (active) {
      _liftCtrl.forward();
    } else {
      _liftCtrl.reverse();
    }
  }

  void _triggerHaptic() {
    final scope = LumiDesignScope.maybeOf(context);
    if ((scope?.hapticsEnabled ?? true) &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)) {
      HapticFeedback.selectionClick();
    }
  }

  void _selectIndex(int index) {
    final clamped = index.clamp(0, widget.segments.length - 1);
    if (clamped == _selectedIndex) {
      _animateToIndex(clamped);
      return;
    }
    _triggerHaptic();
    _selectedIndex = clamped;
    _animateToIndex(clamped);
    widget.onChanged(widget.segments[clamped].value);
  }

  void _handleDragStart(DragStartDetails details) {
    _dragging = true;
    _dragStartPos = _posCtrl.value.clamp(
      0.0,
      (widget.segments.length - 1).toDouble(),
    );
    _dragAccumDx = 0.0;
    _setLift(true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    final box = context.findRenderObject() as RenderBox?;
    final totalWidth = box?.size.width ?? 0;
    final segWidth = totalWidth > 12
        ? (totalWidth - 6) / widget.segments.length
        : 64.0;
    _dragAccumDx += details.delta.dx;
    final maxIdx = (widget.segments.length - 1).toDouble();
    final nextPos = (_dragStartPos + _dragAccumDx / segWidth).clamp(
      0.0,
      maxIdx,
    );
    _posCtrl.value = nextPos;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    _setLift(false);
    final nearest = _posCtrl.value.round().clamp(0, widget.segments.length - 1);
    _selectIndex(nearest);
  }

  void _handleDragCancel() {
    if (!_dragging) return;
    _dragging = false;
    _setLift(false);
    _animateToIndex(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scope = LumiDesignScope.maybeOf(context);
    final reduceTransparency =
        scope?.reduceTransparency ?? ext.reduceTransparency;
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: scope?.reduceMotion ?? ext.reduceMotion,
    );
    final n = widget.segments.length;

    // Outer recessed frosted capsule track.
    final outerFill = reduceTransparency
        ? ext.glassSolidFallback
        : (isDark
              ? Colors.white.withValues(alpha: 0.085)
              : Colors.black.withValues(alpha: 0.055));
    final outerBorder = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.08);

    // Floating Liquid Glass pill thumb colors.
    final indicatorFillTop = reduceTransparency
        ? (isDark ? const Color(0xFF2E3854) : Colors.white)
        : (isDark
              ? Colors.white.withValues(alpha: 0.24)
              : Colors.white.withValues(alpha: 0.94));
    final indicatorFillBottom = reduceTransparency
        ? (isDark ? const Color(0xFF252E47) : const Color(0xFFF3F6FC))
        : (isDark
              ? Colors.white.withValues(alpha: 0.13)
              : Colors.white.withValues(alpha: 0.78));
    final indicatorBorder = isDark
        ? Colors.white.withValues(alpha: 0.34)
        : Colors.white.withValues(alpha: 0.96);

    final inactiveColor = ext.inkMuted;
    final activeColor = ext.ink;

    final stack = Stack(
      children: [
        // ── Sliding Liquid Glass pill thumb ────────────────────────────
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_posCtrl, _liftAnim]),
            builder: (context, _) {
              final pos = reduceMotion
                  ? _selectedIndex.toDouble()
                  : _posCtrl.value.clamp(0.0, (n - 1).toDouble());
              final lift = reduceMotion ? 0.0 : _liftAnim.value;
              final alignX = -1.0 + (2.0 * pos + 1.0) / n;

              final elevatedTop = Color.lerp(
                indicatorFillTop,
                Colors.white.withValues(alpha: isDark ? 0.34 : 0.98),
                lift * 0.65,
              )!;
              final elevatedBottom = Color.lerp(
                indicatorFillBottom,
                Colors.white.withValues(alpha: isDark ? 0.20 : 0.88),
                lift * 0.55,
              )!;

              return Align(
                alignment: Alignment(alignX, 0),
                child: FractionallySizedBox(
                  widthFactor: 1.0 / n,
                  heightFactor: 1.0,
                  child: Transform.scale(
                    scale: lerpDouble(1.0, 1.045, lift)!,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [elevatedTop, elevatedBottom],
                        ),
                        borderRadius: BorderRadius.circular(LumiRadius.pill),
                        border: Border.all(
                          color: Color.lerp(
                            indicatorBorder,
                            Colors.white,
                            lift * 0.4,
                          )!,
                          width: lerpDouble(0.95, 1.25, lift)!,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: (isDark ? 0.28 : 0.12) + lift * 0.08,
                            ),
                            blurRadius: lerpDouble(5.0, 10.0, lift)!,
                            offset: Offset(0, lerpDouble(1.5, 3.0, lift)!),
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Segment labels (define intrinsic width & hit regions) ──────
        Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          children: List.generate(n, (i) {
            final seg = widget.segments[i];
            final isSelected = i == _selectedIndex;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _setLift(true),
                onTapUp: (_) {
                  _setLift(false);
                  _selectIndex(i);
                },
                onTapCancel: () => _setLift(false),
                child: Semantics(
                  label: seg.label,
                  selected: isSelected,
                  button: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AnimatedBuilder(
                      animation: _posCtrl,
                      builder: (context, _) {
                        final pos = reduceMotion
                            ? _selectedIndex.toDouble()
                            : _posCtrl.value.clamp(0.0, (n - 1).toDouble());
                        final proximity = (1.0 - (pos - i).abs()).clamp(
                          0.0,
                          1.0,
                        );
                        final labelColor = Color.lerp(
                          inactiveColor,
                          activeColor,
                          proximity,
                        )!;

                        return Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.showIcons && seg.icon != null) ...[
                                  Icon(seg.icon, size: 15, color: labelColor),
                                  const SizedBox(width: 5),
                                ],
                                Text(
                                  seg.label,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: proximity > 0.5
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: labelColor,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );

    final track = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onHorizontalDragCancel: _handleDragCancel,
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: outerFill,
          borderRadius: BorderRadius.circular(LumiRadius.pill),
          border: Border.all(color: outerBorder, width: 1.0),
        ),
        child: stack,
      ),
    );

    return Semantics(
      container: true,
      label: 'Segmented control',
      child: RepaintBoundary(
        child: widget.expanded ? track : IntrinsicWidth(child: track),
      ),
    );
  }
}
