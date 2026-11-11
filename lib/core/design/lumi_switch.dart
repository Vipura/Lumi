import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lumi_glass.dart';
import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Authentic Apple Liquid Glass toggle switch inspired by CSS Liquid Glass lens
/// controls: recessed refractive glass channel + floating optical crystal thumb
/// that stretches & clarifies on interaction with 45-degree corner caustics.
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

class _LumiGlassSwitchState extends State<LumiGlassSwitch> {
  bool _pressed = false;
  bool _hovered = false;

  void _toggle() {
    final cb = widget.onChanged;
    if (cb == null) return;
    final scope = LumiDesignScope.maybeOf(context);
    if (scope?.hapticsEnabled ?? true) {
      HapticFeedback.selectionClick();
    }
    cb(!widget.value);
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

    final enabled = widget.onChanged != null;
    final onColor = widget.activeColor ?? ext.accentColor;

    final trackOffTop = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.10);
    final trackOffBottom = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);

    // Thumb stretches horizontally into a translucent refractive lens when pressed.
    final thumbWidth = _pressed && !reduceMotion ? 35.0 : 28.0;
    const thumbHeight = 24.0;
    const trackWidth = 58.0;
    const trackHeight = 32.0;

    final trackColors = widget.value
        ? [
            Color.lerp(onColor, Colors.white, 0.22)!.withValues(alpha: 0.94),
            onColor.withValues(alpha: 0.96),
          ]
        : reduceTransparency
        ? [ext.glassSolidFallback, ext.glassSolidFallback]
        : [trackOffTop, trackOffBottom];

    Widget control = FocusableActionDetector(
      enabled: enabled,
      onShowHoverHighlight: (v) {
        if (_hovered != v) setState(() => _hovered = v);
      },
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onHorizontalDragStart: enabled
            ? (_) => setState(() => _pressed = true)
            : null,
        onHorizontalDragEnd: enabled
            ? (details) {
                setState(() => _pressed = false);
                final vx = details.primaryVelocity ?? 0;
                if (vx > 40 && !widget.value) {
                  widget.onChanged?.call(true);
                } else if (vx < -40 && widget.value) {
                  widget.onChanged?.call(false);
                } else {
                  _toggle();
                }
              }
            : null,
        onTap: enabled ? _toggle : null,
        child: SizedBox(
          width: 62,
          height: 44,
          child: Center(
            child: Opacity(
              opacity: enabled ? 1.0 : 0.48,
              child: AnimatedContainer(
                duration: duration,
                curve: LumiMotion.spring,
                width: trackWidth,
                height: trackHeight,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(LumiRadius.pill),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: trackColors,
                  ),
                  border: Border.all(
                    color: widget.value
                        ? Colors.white.withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: isDark ? 0.22 : 0.62),
                    width: 1.05,
                  ),
                  boxShadow: [
                    if (widget.value && !reduceTransparency)
                      BoxShadow(
                        color: onColor.withValues(alpha: 0.34),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                        spreadRadius: -2,
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.30 : 0.08,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        spreadRadius: -2,
                      ),
                  ],
                ),
                child: AnimatedAlign(
                  duration: duration,
                  curve: LumiMotion.spring,
                  alignment: widget.value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: LumiMotion.spring,
                    width: thumbWidth,
                    height: thumbHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(LumiRadius.pill),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _pressed && !reduceTransparency
                            ? [
                                Colors.white.withValues(alpha: 0.56),
                                Colors.white.withValues(alpha: 0.26),
                              ]
                            : [
                                Colors.white.withValues(
                                  alpha: isDark ? 0.96 : 1.0,
                                ),
                                Colors.white.withValues(
                                  alpha: isDark ? 0.82 : 0.90,
                                ),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: _hovered || _pressed ? 0.28 : 0.18,
                          ),
                          blurRadius: _hovered || _pressed ? 8 : 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: LumiLiquidLensPainter(
                        borderRadius: LumiRadius.pill,
                        isDark: false,
                        showOpticalSheen: !reduceTransparency,
                        topLeftColor: Colors.white.withValues(alpha: 0.98),
                        bottomRightColor: Colors.white.withValues(alpha: 0.72),
                        innerHighlight: Colors.white.withValues(alpha: 0.65),
                      ),
                      child: const SizedBox.expand(),
                    ),
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
