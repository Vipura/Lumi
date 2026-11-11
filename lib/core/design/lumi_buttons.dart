import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lumi_glass.dart';
import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Primary or frosted glass action button with >=48dp accessible hit target.
class LumiGlassButton extends StatelessWidget {
  const LumiGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
    this.expanded = false,
    this.isLoading = false,
    this.tintColor,
    this.borderRadius = LumiRadius.md,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool expanded;
  final bool isLoading;
  final Color? tintColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final accent = tintColor ?? ext.accentColor;
    final enabled = onPressed != null && !isLoading;

    final foreground = primary ? Colors.white : ext.ink;

    final inner = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(foreground),
            ),
          ),
          const SizedBox(width: LumiSpacing.xs),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: LumiSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );

    final widget = primary
        ? _PrimaryGlowButton(
            onTap: enabled ? onPressed : null,
            accent: accent,
            borderRadius: borderRadius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LumiSpacing.lg,
                  vertical: LumiSpacing.sm,
                ),
                child: Center(widthFactor: expanded ? null : 1, child: inner),
              ),
            ),
          )
        : LumiGlass(
            onTap: enabled ? onPressed : null,
            tintColor: tintColor,
            borderRadius: borderRadius,
            elevated: true,
            padding: const EdgeInsets.symmetric(
              horizontal: LumiSpacing.lg,
              vertical: LumiSpacing.sm,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 24),
              child: Center(widthFactor: expanded ? null : 1, child: inner),
            ),
          );

    return Opacity(opacity: enabled ? 1.0 : 0.55, child: widget);
  }
}

class _PrimaryGlowButton extends StatefulWidget {
  const _PrimaryGlowButton({
    required this.child,
    required this.onTap,
    required this.accent,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color accent;
  final double borderRadius;

  @override
  State<_PrimaryGlowButton> createState() => _PrimaryGlowButtonState();
}

class _PrimaryGlowButtonState extends State<_PrimaryGlowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scope = LumiDesignScope.maybeOf(context);
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: scope?.reduceMotion ?? false,
    );

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (scope?.hapticsEnabled ?? true) {
                  HapticFeedback.lightImpact();
                }
                widget.onTap?.call();
              },
        child: AnimatedScale(
          scale: _pressed && !reduceMotion ? 0.97 : 1.0,
          duration: reduceMotion ? Duration.zero : LumiMotion.fast,
          curve: LumiMotion.spring,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(widget.accent, Colors.white, 0.16)!,
                  widget.accent,
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.42),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accent.withValues(alpha: 0.42),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Circular or pill frosted icon button (>= 44x44 tap target).
class LumiGlassIconButton extends StatelessWidget {
  const LumiGlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 44,
    this.iconSize = 20,
    this.tintColor,
    this.iconColor,
    this.badgeCount = 0,
    this.useBlur = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color? tintColor;
  final Color? iconColor;
  final int badgeCount;
  final bool useBlur;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final button = LumiGlass(
      width: size,
      height: size,
      borderRadius: LumiRadius.pill,
      tintColor: tintColor,
      useBlur: useBlur,
      onTap: onTap,
      semanticLabel: tooltip,
      alignment: Alignment.center,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(icon, size: iconSize, color: iconColor ?? ext.ink),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: ext.accentColor,
                  borderRadius: BorderRadius.circular(LumiRadius.pill),
                  border: Border.all(color: Colors.white, width: 1.2),
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

/// Prominent glowing "+" capture orb used in the floating bottom glass bar.
class LumiCaptureFab extends StatefulWidget {
  const LumiCaptureFab({
    super.key,
    required this.onTap,
    this.size = 56,
    this.tooltip = 'Quick capture',
  });

  final VoidCallback onTap;
  final double size;
  final String tooltip;

  @override
  State<LumiCaptureFab> createState() => _LumiCaptureFabState();
}

class _LumiCaptureFabState extends State<LumiCaptureFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final scope = LumiDesignScope.maybeOf(context);
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: scope?.reduceMotion ?? false,
    );

    return RepaintBoundary(
      child: Semantics(
        label: widget.tooltip,
        button: true,
        child: Tooltip(
          message: widget.tooltip,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {
              if (scope?.hapticsEnabled ?? true) {
                HapticFeedback.mediumImpact();
              }
              widget.onTap();
            },
            child: AnimatedScale(
              scale: _pressed && !reduceMotion ? 0.92 : 1.0,
              duration: reduceMotion ? Duration.zero : LumiMotion.fast,
              curve: LumiMotion.pop,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(ext.accentColor, Colors.white, 0.25)!,
                      ext.accentColor,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.72),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ext.accentColor.withValues(alpha: 0.55),
                      blurRadius: 22,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: ext.accentGlow.withValues(alpha: 0.35),
                      blurRadius: 34,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
