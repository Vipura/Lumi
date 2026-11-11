import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/design/design_system.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import 'notification_service.dart';
import 'reminder_picker_sheet.dart';

enum _RemindersFilter { upcoming, completed }

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  _RemindersFilter _filter = _RemindersFilter.upcoming;

  Future<void> _createReminder() async {
    await showReminderPickerSheet(context: context);
  }

  Future<void> _editReminder(Reminder r, Item? parent) async {
    await showReminderPickerSheet(
      context: context,
      itemId: r.itemId,
      itemTitle: parent?.title ?? r.title,
      existingReminder: r,
    );
  }

  Future<void> _snoozeReminder(
    Reminder r,
    Item? parent,
    Duration offset,
  ) async {
    final notifications = ref.read(notificationServiceProvider);
    await notifications.cancelReminderAndEarly(r);
    final updated = await ref
        .read(remindersRepositoryProvider)
        .snoozeReminder(r.id, offset);
    if (updated != null) {
      await notifications.scheduleForReminder(
        reminder: updated,
        title: updated.title.isNotEmpty
            ? updated.title
            : (parent?.title ?? 'Lumi Reminder'),
      );
    }
  }

  Future<void> _completeReminder(Reminder r, Item? parent) async {
    final notifications = ref.read(notificationServiceProvider);
    await notifications.cancelReminderAndEarly(r);
    final updated = await ref
        .read(remindersRepositoryProvider)
        .completeReminder(r.id);
    if (updated != null &&
        updated.status == LumiReminderStatus.scheduled.dbValue) {
      await notifications.scheduleForReminder(
        reminder: updated,
        title: updated.title.isNotEmpty
            ? updated.title
            : (parent?.title ?? 'Lumi Reminder'),
      );
    }
  }

  Future<void> _deleteReminder(Reminder r, Item? parent) async {
    final notifications = ref.read(notificationServiceProvider);
    await notifications.cancelReminderAndEarly(r);
    await ref.read(remindersRepositoryProvider).deleteReminder(r.id);

    if (parent != null && parent.type == LumiItemType.reminder.dbValue) {
      final remaining = await ref
          .read(remindersRepositoryProvider)
          .watchRemindersForItem(parent.id)
          .first;
      if (remaining.isEmpty) {
        await ref.read(itemsRepositoryProvider).permanentlyDelete(parent.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final now = DateTime.now();
    final reminders = ref.watch(allRemindersStreamProvider).value ?? const [];
    final items = ref.watch(allActiveItemsStreamProvider).value ?? const [];
    final itemById = {for (final item in items) item.id: item};

    final upcoming = reminders
        .where((r) => r.status != LumiReminderStatus.done.dbValue)
        .toList();
    final completed = reminders
        .where((r) => r.status == LumiReminderStatus.done.dbValue)
        .toList();

    final visible = _filter == _RemindersFilter.upcoming ? upcoming : completed;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LumiSpacing.md,
                  LumiSpacing.sm,
                  LumiSpacing.md,
                  LumiSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Reminders',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ),
                        ),
                        const SizedBox(width: LumiSpacing.xs),
                        LumiGlassLensButton(
                          label: 'New Reminder',
                          compact: MediaQuery.sizeOf(context).width < 430,
                          icon: Icons.alarm_add_rounded,
                          onPressed: _createReminder,
                        ),
                      ],
                    ),
                    const SizedBox(height: LumiSpacing.sm),
                    Wrap(
                      spacing: LumiSpacing.xs,
                      runSpacing: LumiSpacing.xs,
                      children: [
                        LumiGlassChip(
                          label: 'Upcoming (${upcoming.length})',
                          selected: _filter == _RemindersFilter.upcoming,
                          icon: Icons.notifications_active_outlined,
                          onTap: () => setState(
                            () => _filter = _RemindersFilter.upcoming,
                          ),
                        ),
                        LumiGlassChip(
                          label: 'Completed (${completed.length})',
                          selected: _filter == _RemindersFilter.completed,
                          icon: Icons.check_circle_outline_rounded,
                          onTap: () => setState(
                            () => _filter = _RemindersFilter.completed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LumiSpacing.md,
                    LumiSpacing.md,
                    LumiSpacing.md,
                    120,
                  ),
                  child: LumiEmptyState(
                    icon: Icons.alarm_on_rounded,
                    title: _filter == _RemindersFilter.upcoming
                        ? 'No scheduled alarms'
                        : 'No completed reminders',
                    subtitle: _filter == _RemindersFilter.upcoming
                        ? 'Create a reminder with a custom title, exact time alarm, early heads-up (5m to 1mo), and repeat schedule.'
                        : 'Finished reminders appear here.',
                    actionLabel: _filter == _RemindersFilter.upcoming
                        ? 'Create Reminder'
                        : null,
                    onAction: _filter == _RemindersFilter.upcoming
                        ? _createReminder
                        : null,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  LumiSpacing.md,
                  LumiSpacing.xs,
                  LumiSpacing.md,
                  120,
                ),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: LumiSpacing.sm),
                  itemBuilder: (context, index) {
                    final r = visible[index];
                    final parent = itemById[r.itemId];
                    final displayTitle = r.title.trim().isNotEmpty
                        ? r.title.trim()
                        : (parent?.title.trim().isNotEmpty == true
                              ? parent!.title.trim()
                              : 'Reminder');
                    final isDone = r.status == LumiReminderStatus.done.dbValue;
                    final overdue = !isDone && r.fireAt.isBefore(now);
                    final early = LumiEarlyReminder.fromMinutes(
                      r.earlyReminderMinutes,
                    );
                    final repeat = LumiRepeatRule.fromDb(r.repeatRule);
                    final linkedNote =
                        parent != null &&
                        parent.type != LumiItemType.reminder.dbValue;

                    return LumiGlass.card(
                      onTap: () => _editReminder(r, parent),
                      padding: const EdgeInsets.all(LumiSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  (isDone
                                          ? LumiColors.success
                                          : overdue
                                          ? LumiColors.danger
                                          : ext.accentColor)
                                      .withValues(alpha: 0.16),
                            ),
                            child: Icon(
                              isDone
                                  ? Icons.check_rounded
                                  : Icons.alarm_rounded,
                              color: isDone
                                  ? LumiColors.success
                                  : overdue
                                  ? LumiColors.danger
                                  : ext.accentColor,
                            ),
                          ),
                          const SizedBox(width: LumiSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayTitle,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  DateFormat('EEE, MMM d • h:mm a')
                                      .format(r.fireAt),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: overdue
                                            ? LumiColors.danger
                                            : ext.inkMuted,
                                        fontWeight: overdue
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                ),
                                if (early != LumiEarlyReminder.none ||
                                    repeat != LumiRepeatRule.none ||
                                    linkedNote) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (early != LumiEarlyReminder.none)
                                        _ReminderMetaPill(
                                          icon: Icons.notifications_outlined,
                                          label: 'Early: ${early.shortLabel}',
                                          color: LumiColors.info,
                                        ),
                                      if (repeat != LumiRepeatRule.none)
                                        _ReminderMetaPill(
                                          icon: Icons.repeat_rounded,
                                          label: repeat.label,
                                          color: ext.accentColor,
                                        ),
                                      if (linkedNote)
                                        _ReminderMetaPill(
                                          icon: Icons.link_rounded,
                                          label: parent.title.isEmpty
                                              ? 'Linked item'
                                              : parent.title,
                                          color: ext.inkMuted,
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (linkedNote)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 34,
                                minHeight: 34,
                              ),
                              icon: Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                                color: ext.inkMuted,
                              ),
                              tooltip: 'Open linked item',
                              onPressed: () =>
                                  context.push('/editor/${parent.id}'),
                            ),
                          if (!isDone) ...[
                            PopupMenuButton<Duration>(
                              tooltip: 'Snooze',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 34,
                                minHeight: 34,
                              ),
                              icon: Icon(
                                Icons.snooze_rounded,
                                size: 19,
                                color: ext.inkMuted,
                              ),
                              onSelected: (d) => _snoozeReminder(r, parent, d),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: Duration(minutes: 15),
                                  child: Text('Snooze 15 min'),
                                ),
                                PopupMenuItem(
                                  value: Duration(hours: 1),
                                  child: Text('Snooze 1 hour'),
                                ),
                                PopupMenuItem(
                                  value: Duration(days: 1),
                                  child: Text('Snooze tomorrow'),
                                ),
                              ],
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 34,
                                minHeight: 34,
                              ),
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: LumiColors.success,
                                size: 21,
                              ),
                              tooltip: 'Complete reminder',
                              onPressed: () =>
                                  unawaited(_completeReminder(r, parent)),
                            ),
                          ],
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 34,
                              minHeight: 34,
                            ),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 19,
                              color: ext.inkMuted,
                            ),
                            tooltip: 'Delete reminder',
                            onPressed: () =>
                                unawaited(_deleteReminder(r, parent)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReminderMetaPill extends StatelessWidget {
  const _ReminderMetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

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
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
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
