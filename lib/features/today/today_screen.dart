import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/design/design_system.dart';
import '../../core/utils/delta_utils.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import '../notes/widgets/note_summary_card.dart';
import '../reminders/notification_service.dart';
import '../reminders/reminder_picker_sheet.dart';
import '../settings/backup_export_service.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final _quickController = TextEditingController();
  bool _captureAsChecklist = false;

  @override
  void dispose() {
    _quickController.dispose();
    super.dispose();
  }

  String _greeting(DateTime now) {
    final h = now.hour;
    if (h >= 5 && h < 12) return 'Good morning';
    if (h >= 12 && h < 17) return 'Good afternoon';
    if (h >= 17 && h < 22) return 'Good evening';
    return 'Quiet night';
  }

  Future<void> _submitQuickCapture() async {
    final text = _quickController.text.trim();
    if (text.isEmpty) return;
    _quickController.clear();
    final now = DateTime.now();

    if (_captureAsChecklist) {
      final item = await ref
          .read(itemsRepositoryProvider)
          .createItem(type: LumiItemType.checklist, title: text, dueDate: now);
      await ref
          .read(checklistRepositoryProvider)
          .addEntry(itemId: item.id, text: text);
    } else {
      await ref
          .read(itemsRepositoryProvider)
          .createItem(
            type: LumiItemType.note,
            initialPlainText: text,
            dueDate: now,
          );
    }

    if (!mounted) return;
    if (LumiDesignScope.maybeOf(context)?.hapticsEnabled ?? true) {
      unawaited(HapticFeedback.lightImpact());
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _captureAsChecklist ? 'Task added for today' : 'Note captured',
        ),
        duration: const Duration(seconds: 2),
      ),
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

  Future<void> _openCalmWrite() async {
    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(type: LumiItemType.calm);
    if (mounted) {
      unawaited(context.push('/calm/${item.id}'));
    }
  }

  Future<void> _exportLatestCalmPdf(Item entry) async {
    try {
      final exported = await ref
          .read(backupExportServiceProvider)
          .exportNotePdf(entry);
      if (exported && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported Calm Space entry as PDF.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final ext = context.lumiTheme;

    final progress = ref.watch(todayProgressProvider);
    final summaries = ref.watch(itemSummariesProvider);
    final calmEntries = ref.watch(calmFeedStreamProvider).value ?? const [];
    final reminders =
        ref.watch(scheduledRemindersStreamProvider).value ?? const [];
    final allEntries =
        ref.watch(allChecklistEntriesStreamProvider).value ?? const [];

    final itemById = {for (final s in summaries) s.item.id: s};
    final visibleWorkspaceSummaries = summaries
        .where(
          (s) => s.type != LumiItemType.reminder && s.type != LumiItemType.calm,
        )
        .toList();

    final todayReminders = reminders.where((r) {
      return !r.fireAt.isAfter(todayEnd);
    }).toList();

    final dueTodayItems = visibleWorkspaceSummaries.where((s) {
      final due = s.item.dueDate;
      if (due == null) return false;
      return due.isBefore(todayEnd);
    }).toList();

    final unfinishedDueCount = dueTodayItems.where((s) {
      if (s.boardStatus == LumiBoardStatus.done) return false;
      if (s.checklistTotal > 0 && s.checklistDone == s.checklistTotal) {
        return false;
      }
      return true;
    }).length;

    final showEveningRollover = unfinishedDueCount > 0 && now.hour >= 17;

    final pinned = visibleWorkspaceSummaries
        .where((s) => s.item.pinned)
        .toList();
    final dueTodayIds = dueTodayItems.map((s) => s.item.id).toSet();
    final todayEntries = allEntries
        .where((e) => dueTodayIds.contains(e.itemId))
        .take(12)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            LumiSpacing.md,
            LumiSpacing.sm,
            LumiSpacing.md,
            120,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with logo, greeting, date, and Settings button
                    Row(
                      children: [
                        const LumiLogo(size: 36),
                        const SizedBox(width: LumiSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(now),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                              Text(
                                DateFormat('EEEE, MMMM d').format(now),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: ext.inkMuted),
                              ),
                            ],
                          ),
                        ),
                        LumiGlassEffectContainer(
                          children: [
                            LumiGlassIconButton(
                              icon: Icons.search_rounded,
                              size: 38,
                              iconSize: 19,
                              useBlur: false,
                              chrome: false,
                              tooltip: 'Search',
                              onTap: () => context.push('/search'),
                            ),
                            LumiGlassIconButton(
                              icon: Icons.settings_outlined,
                              size: 38,
                              iconSize: 19,
                              useBlur: false,
                              chrome: false,
                              tooltip: 'Settings',
                              onTap: () => context.push('/settings'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: LumiSpacing.md),

                    // Instant Quick-Capture Bar (< 2 seconds)
                    LumiGlass(
                      borderRadius: LumiRadius.lg,
                      useBlur: false,
                      blur: 0,
                      elevated: true,
                      hasShadow: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: LumiSpacing.md,
                        vertical: LumiSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(
                              () => _captureAsChecklist = !_captureAsChecklist,
                            ),
                            child: Tooltip(
                              message: _captureAsChecklist
                                  ? 'Mode: Today Task (tap for Note)'
                                  : 'Mode: Quick Note (tap for Task)',
                              child: Icon(
                                _captureAsChecklist
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.edit_note_rounded,
                                color: ext.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: LumiSpacing.sm),
                          Expanded(
                            child: TextField(
                              controller: _quickController,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submitQuickCapture(),
                              decoration: InputDecoration(
                                hintText: _captureAsChecklist
                                    ? 'Add a task for today...'
                                    : 'Quick capture — type and hit Done...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          LumiGlassIconButton(
                            icon: Icons.arrow_upward_rounded,
                            size: 36,
                            iconSize: 18,
                            useBlur: false,
                            tintColor: ext.accentColor,
                            iconColor: ext.accentColor,
                            tooltip: 'Save',
                            onTap: _submitQuickCapture,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LumiSpacing.md),

                    // Completed-Today Progress Ring Hero
                    LumiGlass.card(
                      padding: const EdgeInsets.all(LumiSpacing.md),
                      child: Row(
                        children: [
                          LumiProgressRing(
                            progress: progress.progress,
                            size: 62,
                            strokeWidth: 5.5,
                            child: Text(
                              progress.totalCount == 0
                                  ? '0%'
                                  : '${(progress.progress * 100).round()}%',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          const SizedBox(width: LumiSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Today's momentum",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  progress.totalCount == 0
                                      ? 'Add tasks due today to track progress'
                                      : '${progress.completedCount} of ${progress.totalCount} steps completed today',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: ext.inkMuted),
                                ),
                              ],
                            ),
                          ),
                          if (unfinishedDueCount > 0)
                            TextButton(
                              onPressed: () async {
                                final moved = await ref
                                    .read(checklistRepositoryProvider)
                                    .rolloverUnfinishedTasks();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Moved $moved unfinished item${moved == 1 ? '' : 's'} to tomorrow',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Roll over'),
                            ),
                        ],
                      ),
                    ),

                    if (showEveningRollover) ...[
                      const SizedBox(height: LumiSpacing.sm),
                      LumiGlass.card(
                        tintColor: ext.accentColor,
                        padding: const EdgeInsets.all(LumiSpacing.md),
                        child: Row(
                          children: [
                            Icon(
                              Icons.nights_stay_rounded,
                              color: ext.accentColor,
                            ),
                            const SizedBox(width: LumiSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Evening wrap-up',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  Text(
                                    '$unfinishedDueCount unfinished item${unfinishedDueCount == 1 ? '' : 's'} remaining. Move them to tomorrow?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            LumiGlassButton(
                              label: 'Move',
                              primary: true,
                              onPressed: () async {
                                final moved = await ref
                                    .read(checklistRepositoryProvider)
                                    .rolloverUnfinishedTasks();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Rolled over $moved task${moved == 1 ? '' : 's'} to tomorrow',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Calm Space Sanctuary Section
                    const SizedBox(height: LumiSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _TodayHeader(
                            title: 'Calm Space',
                            count: calmEntries.length,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/calm'),
                          child: const Text('Open Space'),
                        ),
                      ],
                    ),
                    const SizedBox(height: LumiSpacing.xs),
                    LumiGlass.card(
                      tintColor: ext.accentColor,
                      onTap: () => calmEntries.isNotEmpty
                          ? context.push('/calm/${calmEntries.first.id}')
                          : context.push('/calm'),
                      padding: const EdgeInsets.all(LumiSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ext.accentColor.withValues(
                                    alpha: 0.16,
                                  ),
                                ),
                                child: Icon(
                                  Icons.spa_rounded,
                                  color: ext.accentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: LumiSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      calmEntries.isEmpty
                                          ? 'Write thoughts, stories & reflections'
                                          : (calmEntries.first.title
                                                    .trim()
                                                    .isEmpty
                                                ? 'Calm Space Entry'
                                                : calmEntries.first.title
                                                      .trim()),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      calmEntries.isEmpty
                                          ? 'An unhurried space for whatever is on your mind — exportable as PDF.'
                                          : (calmEntries.first.plainText
                                                    .trim()
                                                    .isNotEmpty
                                                ? calmEntries.first.plainText
                                                      .trim()
                                                : '${DeltaUtils.wordCount(calmEntries.first.plainText)} words • Updated ${DateFormat('MMM d').format(calmEntries.first.updatedAt)}'),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: ext.inkMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: LumiSpacing.sm),
                          Wrap(
                            spacing: LumiSpacing.xs,
                            runSpacing: LumiSpacing.xs,
                            children: [
                              LumiGlassLensButton(
                                label: 'Write Thought',
                                icon: Icons.edit_rounded,
                                onPressed: _openCalmWrite,
                              ),
                              if (calmEntries.isNotEmpty)
                                LumiGlassButton(
                                  label: 'Export PDF',
                                  icon: Icons.picture_as_pdf_outlined,
                                  onPressed: () =>
                                      _exportLatestCalmPdf(calmEntries.first),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Today's Reminders
                    if (todayReminders.isNotEmpty) ...[
                      const SizedBox(height: LumiSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _TodayHeader(
                              title: 'Reminders',
                              count: todayReminders.length,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/reminders'),
                            child: const Text('All reminders'),
                          ),
                        ],
                      ),
                      const SizedBox(height: LumiSpacing.xs),
                      ...todayReminders.map((r) {
                        final parent = itemById[r.itemId]?.item;
                        final resolvedTitle = r.title.trim().isNotEmpty
                            ? r.title.trim()
                            : (parent?.title.trim().isNotEmpty == true
                                  ? parent!.title.trim()
                                  : 'Reminder');
                        final overdue = r.fireAt.isBefore(now);
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: LumiSpacing.xs,
                          ),
                          child: LumiGlass.card(
                            onTap: () => showReminderPickerSheet(
                              context: context,
                              itemId: r.itemId,
                              itemTitle: resolvedTitle,
                              existingReminder: r,
                            ),
                            padding: const EdgeInsets.all(LumiSpacing.sm),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notifications_active_rounded,
                                  color: overdue
                                      ? LumiColors.danger
                                      : ext.accentColor,
                                ),
                                const SizedBox(width: LumiSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resolvedTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      Text(
                                        DateFormat('MMM d • h:mm a')
                                            .format(r.fireAt),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: overdue
                                                  ? LumiColors.danger
                                                  : ext.inkMuted,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<Duration>(
                                  tooltip: 'Snooze',
                                  icon: Icon(
                                    Icons.snooze_rounded,
                                    color: ext.inkMuted,
                                    size: 20,
                                  ),
                                  onSelected: (d) =>
                                      _snoozeReminder(r, parent, d),
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
                                  icon: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: LumiColors.success,
                                  ),
                                  tooltip: 'Complete reminder',
                                  onPressed: () => _completeReminder(r, parent),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],

                    // Today's Tasks & Checklists
                    if (todayEntries.isNotEmpty ||
                        dueTodayItems.isNotEmpty) ...[
                      const SizedBox(height: LumiSpacing.lg),
                      _TodayHeader(
                        title: 'Due Today',
                        count: dueTodayItems.length,
                      ),
                      const SizedBox(height: LumiSpacing.xs),
                      if (todayEntries.isNotEmpty)
                        LumiGlass.card(
                          padding: const EdgeInsets.symmetric(
                            horizontal: LumiSpacing.sm,
                            vertical: LumiSpacing.xs,
                          ),
                          child: Column(
                            children: todayEntries.map((entry) {
                              final parentTitle =
                                  itemById[entry.itemId]?.item.title ?? '';
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Checkbox(
                                  value: entry.done,
                                  activeColor: ext.accentColor,
                                  shape: const CircleBorder(),
                                  onChanged: (val) => ref
                                      .read(checklistRepositoryProvider)
                                      .toggleEntry(entry.id, val ?? false),
                                ),
                                title: Text(
                                  entry.entryText,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        decoration: entry.done
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: entry.done
                                            ? ext.inkMuted
                                            : ext.ink,
                                      ),
                                ),
                                subtitle: parentTitle.isNotEmpty
                                    ? Text(
                                        parentTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      )
                                    : null,
                                onTap: () =>
                                    context.push('/editor/${entry.itemId}'),
                              );
                            }).toList(),
                          ),
                        )
                      else
                        ...dueTodayItems.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: LumiSpacing.xs,
                            ),
                            child: NoteSummaryCard(
                              summary: s,
                              compact: true,
                              enableHero: false,
                              onTap: () => context.push('/editor/${s.item.id}'),
                            ),
                          ),
                        ),
                    ],

                    // Pinned Notes
                    const SizedBox(height: LumiSpacing.lg),
                    _TodayHeader(title: 'Pinned', count: pinned.length),
                    const SizedBox(height: LumiSpacing.xs),
                    if (pinned.isEmpty)
                      LumiGlass.card(
                        child: Text(
                          'Pin any note or checklist to keep it right here at a glance.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: ext.inkMuted),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final twoCol = constraints.maxWidth >= 540;
                          if (!twoCol) {
                            return Column(
                              children: pinned
                                  .map(
                                    (s) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: LumiSpacing.sm,
                                      ),
                                      child: NoteSummaryCard(
                                        summary: s,
                                        heroPrefix: 'today',
                                        onTap: () => context.push(
                                          '/editor/${s.item.id}?hero=today',
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pinned.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: LumiSpacing.sm,
                                  crossAxisSpacing: LumiSpacing.sm,
                                  childAspectRatio: 1.45,
                                ),
                            itemBuilder: (_, idx) => NoteSummaryCard(
                              summary: pinned[idx],
                              compact: true,
                              heroPrefix: 'today',
                              onTap: () => context.push(
                                '/editor/${pinned[idx].item.id}?hero=today',
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(width: LumiSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: ext.accentColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(LumiRadius.pill),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ext.accentColor,
            ),
          ),
        ),
      ],
    );
  }
}
