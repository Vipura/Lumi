import 'package:flutter/material.dart';

import 'lumi_buttons.dart';
import 'lumi_glass.dart';
import 'lumi_themes.dart';
import 'lumi_tokens.dart';

/// Friendly glass card for empty views with an icon halo and optional CTA.
class LumiEmptyState extends StatelessWidget {
  const LumiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final accent = accentColor ?? ext.accentColor;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: LumiGlass.card(
          padding: const EdgeInsets.all(LumiSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.34),
                        accent.withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.38),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, size: 30, color: accent),
                ),
                const SizedBox(height: LumiSpacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: LumiSpacing.xs),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: ext.inkMuted),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: LumiSpacing.lg),
                  LumiGlassButton(
                    label: actionLabel!,
                    primary: true,
                    icon: Icons.add_rounded,
                    onPressed: onAction,
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
