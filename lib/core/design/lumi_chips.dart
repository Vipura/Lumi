import 'package:flutter/material.dart';

import 'lumi_glass.dart';
import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Translucent chip for tags, collections, filters, and quick actions.
class LumiGlassChip extends StatelessWidget {
  const LumiGlassChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onDelete,
    this.icon,
    this.dotColor,
    this.tintColor,
    this.useBlur = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final IconData? icon;
  final Color? dotColor;
  final Color? tintColor;
  final bool useBlur;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final activeTint = tintColor ?? (selected ? ext.accentColor : null);
    final labelColor = selected ? ext.ink : ext.ink.withValues(alpha: 0.88);

    return LumiGlass(
      onTap: onTap,
      useBlur: useBlur,
      elevated: selected,
      hasShadow: false,
      tintColor: activeTint,
      borderRadius: LumiRadius.pill,
      padding: const EdgeInsets.symmetric(
        horizontal: LumiSpacing.sm,
        vertical: LumiSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: LumiSpacing.xs),
          ] else if (icon != null) ...[
            Icon(
              icon,
              size: 15,
              color: selected ? ext.accentColor : ext.inkMuted,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: labelColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 6),
            Semantics(
              label: 'Remove $label',
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: ext.inkMuted,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
