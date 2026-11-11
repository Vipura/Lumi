import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/design/design_system.dart';
import '../../../data/repositories/lumi_models.dart';

/// Lightweight translucent card used inside Notes, Today, and Search lists.
/// Uses `LumiGlass.card` (no stacked BackdropFilter) to preserve 60/120 fps scrolling.
class NoteSummaryCard extends StatelessWidget {
  const NoteSummaryCard({
    super.key,
    required this.summary,
    required this.onTap,
    this.onLongPress,
    this.onTogglePin,
    this.compact = false,
    this.enableHero = true,
    this.heroPrefix = 'item',
  });

  final LumiItemSummary summary;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onTogglePin;
  final bool compact;
  final bool enableHero;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final item = summary.item;
    final tint = item.colorValue != null ? Color(item.colorValue!) : null;
    final title = item.title.trim().isEmpty
        ? (summary.type == LumiItemType.checklist
              ? 'Checklist'
              : 'Untitled note')
        : item.title.trim();

    final rawSnippet = item.plainText.trim().replaceAll(RegExp(r'\s+'), ' ');
    final snippet = rawSnippet == title ? '' : rawSnippet;

    final cardContent = Material(
      color: Colors.transparent,
      child: LumiGlass.card(
        onTap: onTap,
        onLongPress: onLongPress,
        tintColor: tint,
        padding: EdgeInsets.all(compact ? LumiSpacing.sm : LumiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tint != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 5, right: 8),
                    decoration: BoxDecoration(
                      color: tint,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (summary.checklistTotal > 0) ...[
                  const SizedBox(width: 6),
                  LumiProgressRing(
                    progress: summary.checklistProgress,
                    size: 26,
                    strokeWidth: 3,
                    child: Text(
                      '${summary.checklistDone}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ] else if (item.pinned) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.push_pin_rounded,
                    size: 16,
                    color: ext.accentColor,
                  ),
                ],
              ],
            ),
            if (snippet.isNotEmpty) ...[
              const SizedBox(height: LumiSpacing.xs),
              Text(
                snippet,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: ext.inkMuted),
              ),
            ],
            const SizedBox(height: LumiSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (summary.collection != null)
                  _MiniBadge(
                    label: summary.collection!.name,
                    color: Color(summary.collection!.colorValue),
                  ),
                if (item.dueDate != null)
                  _MiniBadge(
                    label: DateFormat('MMM d').format(item.dueDate!),
                    icon: Icons.event_outlined,
                    color: ext.accentColor,
                  ),
                if (summary.nextReminder != null)
                  _MiniBadge(
                    label: DateFormat('h:mm a')
                        .format(summary.nextReminder!.fireAt),
                    icon: Icons.notifications_active_outlined,
                    color: LumiColors.warning,
                  ),
                if (summary.attachmentCount > 0)
                  _MiniBadge(
                    label: '${summary.attachmentCount}',
                    icon: Icons.attach_file_rounded,
                    color: LumiColors.info,
                  ),
                ...summary.tags
                    .take(2)
                    .map(
                      (tag) => _MiniBadge(
                        label: '#${tag.name}',
                        color: ext.inkMuted,
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!enableHero) return cardContent;

    return Hero(
      tag: 'lumi_${heroPrefix}_${item.id}',
      flightShuttleBuilder: (_, anim, dir, fromCtx, toCtx) =>
          Material(color: Colors.transparent, child: toCtx.widget),
      child: cardContent,
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(LumiRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
