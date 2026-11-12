import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lumi_glass.dart';
import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Primary or frosted Liquid Glass action button with >=48dp accessible hit target.
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
            useBlur: false,
            blur: 0,
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

/// FreeFrontend-inspired Apple Liquid Glass Lens CTA pill featuring an optical
/// translucent lens capsule, 45-degree corner caustics, inner bevel halo, and
/// circular trailing icon badge (`.start-btn` + `.btn-icon`).
class LumiGlassLensButton extends StatefulWidget {
  const LumiGlassLensButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.tintColor,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? tintColor;
  final bool compact;

  @override
  State<LumiGlassLensButton> createState() => _LumiGlassLensButtonState();
}

class _LumiGlassLensButtonState extends State<LumiGlassLensButton> {
  bool _pressed = false;
  bool _hovered = false;

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

    final badgeColor = widget.tintColor ?? (isDark ? Colors.white : ext.ink);
    final badgeIconColor = widget.tintColor != null
        ? Colors.white
        : (isDark ? LumiColors.darkCanvas : Colors.white);

    final scale = _pressed && !reduceMotion
        ? 0.94
        : (_hovered && !reduceMotion ? 1.018 : 1.0);

    return Semantics(
      button: widget.onPressed != null,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: widget.onPressed == null
              ? null
              : (_) => setState(() => _pressed = true),
          onTapUp: widget.onPressed == null
              ? null
              : (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onPressed == null
              ? null
              : () {
                  if (scope?.hapticsEnabled ?? true) {
                    HapticFeedback.lightImpact();
                  }
                  widget.onPressed?.call();
                },
          child: AnimatedScale(
            scale: scale,
            duration: reduceMotion ? Duration.zero : LumiMotion.fast,
            curve: LumiMotion.spring,
            child: RepaintBoundary(
              child: Opacity(
                opacity: widget.onPressed == null ? 0.55 : 1.0,
                child: CustomPaint(
                  foregroundPainter: LumiLiquidLensPainter(
                    borderRadius: LumiRadius.pill,
                    isDark: isDark,
                    showOpticalSheen: !reduceTransparency,
                    topLeftColor: ext.glassBorderTopLeft,
                    bottomRightColor: ext.glassBorderBottomRight,
                    innerHighlight: ext.glassInnerHighlight,
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      widget.compact ? 14 : 18,
                      widget.compact ? 6 : 8,
                      widget.compact ? 6 : 8,
                      widget.compact ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(LumiRadius.pill),
                      color: reduceTransparency
                          ? ext.glassSolidFallback
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : Colors.white.withValues(alpha: 0.40)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.24 : 0.10,
                          ),
                          blurRadius: _hovered ? 12 : 8,
                          offset: Offset(0, _hovered ? 4 : 3),
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              widget.label,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: ext.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          SizedBox(width: widget.compact ? 8 : 12),
                          AnimatedScale(
                            scale: _hovered && !reduceMotion ? 1.08 : 1.0,
                            duration: reduceMotion
                                ? Duration.zero
                                : LumiMotion.fast,
                            child: Container(
                              width: widget.compact ? 30 : 34,
                              height: widget.compact ? 30 : 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: badgeColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: badgeColor.withValues(alpha: 0.28),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                size: widget.compact ? 16 : 18,
                                color: badgeIconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
    final isPill = widget.borderRadius >= 100;
    final radius = BorderRadius.circular(widget.borderRadius);
    final OutlinedBorder shape = isPill
        ? RoundedRectangleBorder(borderRadius: radius)
        : RoundedSuperellipseBorder(borderRadius: radius);
    final borderSide = BorderSide(
      color: Colors.white.withValues(alpha: 0.52),
      width: 1,
    );
    final OutlinedBorder foregroundShape = isPill
        ? RoundedRectangleBorder(borderRadius: radius, side: borderSide)
        : RoundedSuperellipseBorder(borderRadius: radius, side: borderSide);

    final innerContent = Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(widget.accent, Colors.white, 0.22)!,
                  widget.accent,
                  Color.lerp(widget.accent, Colors.black, 0.08)!,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 22,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );

    final clippedContent = isPill
        ? ClipRRect(borderRadius: radius, child: innerContent)
        : ClipRSuperellipse(borderRadius: radius, child: innerContent);

    return GestureDetector(
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
        child: RepaintBoundary(
          child: Container(
            decoration: ShapeDecoration(
              shape: shape,
              shadows: [
                BoxShadow(
                  color: widget.accent.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                  spreadRadius: -3,
                ),
              ],
            ),
            foregroundDecoration: ShapeDecoration(shape: foregroundShape),
            child: clippedContent,
          ),
        ),
      ),
    );
  }
}

/// Circular or pill frosted icon button (>= 44x44 tap target when standalone,
/// or borderless inside grouped Liquid Glass capsules via `chrome: false`).
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
    this.useBlur = false,
    this.grouped = true,
    this.chrome = true,
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
  final bool grouped;
  final bool chrome;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final iconStack = Stack(
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
    );

    final Widget button = chrome
        ? LumiGlass(
            width: size,
            height: size,
            borderRadius: LumiRadius.pill,
            blur: useBlur ? 5.5 : 0,
            variant: LumiGlassVariant.clear,
            tintColor: tintColor,
            elevated: true,
            useBlur: useBlur,
            grouped: grouped,
            hasShadow: useBlur,
            onTap: onTap,
            semanticLabel: tooltip,
            alignment: Alignment.center,
            child: iconStack,
          )
        : _GroupedCapsuleIconButton(
            size: size,
            tintColor: tintColor,
            tooltip: tooltip,
            onTap: onTap,
            child: iconStack,
          );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

class _GroupedCapsuleIconButton extends StatefulWidget {
  const _GroupedCapsuleIconButton({
    required this.size,
    required this.tintColor,
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  final double size;
  final Color? tintColor;
  final String? tooltip;
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_GroupedCapsuleIconButton> createState() =>
      _GroupedCapsuleIconButtonState();
}

class _GroupedCapsuleIconButtonState extends State<_GroupedCapsuleIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scope = LumiDesignScope.maybeOf(context);
    final reduceMotion = LumiMotion.shouldReduceMotion(
      context,
      setting: scope?.reduceMotion ?? false,
    );
    final activeTint = widget.tintColor;

    Widget content = GestureDetector(
      behavior: HitTestBehavior.opaque,
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
        scale: _pressed && !reduceMotion ? 0.90 : 1.0,
        duration: reduceMotion ? Duration.zero : LumiMotion.fast,
        curve: LumiMotion.spring,
        child: Container(
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: activeTint != null
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeTint.withValues(alpha: 0.16),
                )
              : null,
          child: widget.child,
        ),
      ),
    );

    if (widget.tooltip != null) {
      content = Semantics(
        label: widget.tooltip,
        button: widget.onTap != null,
        child: content,
      );
    }

    return content;
  }
}

/// Prominent Liquid Glass Lens "+" capture orb styled after FreeFrontend `.box`.
class LumiCaptureFab extends StatefulWidget {
  const LumiCaptureFab({
    super.key,
    required this.onTap,
    this.size = 54,
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

    return Semantics(
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
            child: RepaintBoundary(
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ext.accentColor.withValues(alpha: 0.40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomPaint(
                    painter: LumiLiquidLensPainter(
                      borderRadius: LumiRadius.pill,
                      isDark: false,
                      showOpticalSheen: true,
                      topLeftColor: Colors.white.withValues(alpha: 0.95),
                      bottomRightColor: Colors.white.withValues(alpha: 0.72),
                      innerHighlight: Colors.white.withValues(alpha: 0.55),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(ext.accentColor, Colors.white, 0.30)!,
                            ext.accentColor,
                            Color.lerp(ext.accentColor, Colors.black, 0.14)!,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
