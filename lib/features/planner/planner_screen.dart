import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/design/design_system.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';

enum _PlannerTab { calendar, boards }

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  _PlannerTab _tab = _PlannerTab.calendar;
  bool _weekMode = false;
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  Future<void> _addItemForDay(DateTime day) async {
    final title = await showLumiTextPromptDialog(
      context: context,
      title: 'Schedule for ${DateFormat('MMM d').format(day)}',
      hintText: 'Task or note title...',
    );
    if (title == null || title.trim().isEmpty) return;

    final item = await ref
        .read(itemsRepositoryProvider)
        .createItem(
          type: LumiItemType.card,
          title: title.trim(),
          dueDate: DateTime(day.year, day.month, day.day, 10, 0),
          boardStatus: LumiBoardStatus.todo,
        );
    await ref
        .read(checklistRepositoryProvider)
        .addEntry(itemId: item.id, text: title.trim());
  }

  Future<void> _addBoardCard(LumiBoardStatus status) async {
    final title = await showLumiTextPromptDialog(
      context: context,
      title: 'Add to ${status.label}',
      hintText: 'Card title...',
    );
    if (title == null || title.trim().isEmpty) return;

    await ref
        .read(itemsRepositoryProvider)
        .createItem(
          type: LumiItemType.card,
          title: title.trim(),
          boardStatus: status,
        );
  }

  @override
  Widget build(BuildContext context) {
    final summaries = ref.watch(itemSummariesProvider);
    final reminders =
        ref.watch(scheduledRemindersStreamProvider).value ?? const [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LumiSpacing.md,
                LumiSpacing.sm,
                LumiSpacing.md,
                LumiSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Plan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(width: LumiSpacing.sm),
                  LumiGlass(
                    borderRadius: LumiRadius.pill,
                    blur: 16,
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LumiGlassChip(
                          label: 'Calendar',
                          icon: Icons.calendar_month_rounded,
                          selected: _tab == _PlannerTab.calendar,
                          onTap: () =>
                              setState(() => _tab = _PlannerTab.calendar),
                        ),
                        const SizedBox(width: 4),
                        LumiGlassChip(
                          label: 'Boards',
                          icon: Icons.view_kanban_rounded,
                          selected: _tab == _PlannerTab.boards,
                          onTap: () =>
                              setState(() => _tab = _PlannerTab.boards),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tab == _PlannerTab.calendar
                  ? _CalendarView(
                      focusedMonth: _focusedMonth,
                      selectedDay: _selectedDay,
                      weekMode: _weekMode,
                      summaries: summaries,
                      reminders: reminders,
                      onToggleWeekMode: () =>
                          setState(() => _weekMode = !_weekMode),
                      onChangeMonth: (delta) => setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + delta,
                        );
                      }),
                      onSelectDay: (day) => setState(() => _selectedDay = day),
                      onAddForDay: _addItemForDay,
                    )
                  : _BoardsView(
                      summaries: summaries,
                      onAddCard: _addBoardCard,
                      onMoveCard: (itemId, status) {
                        if (LumiDesignScope.maybeOf(context)?.hapticsEnabled ??
                            true) {
                          HapticFeedback.lightImpact();
                        }
                        ref
                            .read(itemsRepositoryProvider)
                            .updateMetadata(id: itemId, boardStatus: status);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView({
    required this.focusedMonth,
    required this.selectedDay,
    required this.weekMode,
    required this.summaries,
    required this.reminders,
    required this.onToggleWeekMode,
    required this.onChangeMonth,
    required this.onSelectDay,
    required this.onAddForDay,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final bool weekMode;
  final List<LumiItemSummary> summaries;
  final List<Reminder> reminders;
  final VoidCallback onToggleWeekMode;
  final ValueChanged<int> onChangeMonth;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<DateTime> onAddForDay;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final now = DateTime.now();
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    final leadingBlanks = (firstOfMonth.weekday - 1) % 7;

    final days = <DateTime?>[];
    if (weekMode) {
      final weekStart = selectedDay.subtract(
        Duration(days: (selectedDay.weekday - 1) % 7),
      );
      for (var i = 0; i < 7; i++) {
        days.add(weekStart.add(Duration(days: i)));
      }
    } else {
      for (var i = 0; i < leadingBlanks; i++) {
        days.add(null);
      }
      for (var d = 1; d <= daysInMonth; d++) {
        days.add(DateTime(focusedMonth.year, focusedMonth.month, d));
      }
    }

    final eventDays = <String>{};
    for (final s in summaries) {
      final d = s.item.dueDate;
      if (d != null) eventDays.add('${d.year}-${d.month}-${d.day}');
    }
    for (final r in reminders) {
      final d = r.fireAt;
      eventDays.add('${d.year}-${d.month}-${d.day}');
    }

    final dayItems = summaries
        .where(
          (s) =>
              s.item.dueDate != null && _sameDay(s.item.dueDate!, selectedDay),
        )
        .toList();
    final dayReminders = reminders
        .where((r) => _sameDay(r.fireAt, selectedDay))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LumiSpacing.md,
        0,
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
                LumiGlass.card(
                  padding: const EdgeInsets.all(LumiSpacing.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: () => onChangeMonth(-1),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat('MMMM yyyy').format(focusedMonth),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: () => onChangeMonth(1),
                          ),
                          const SizedBox(width: 4),
                          LumiGlassChip(
                            label: weekMode ? 'Month' : 'Week',
                            onTap: onToggleWeekMode,
                          ),
                        ],
                      ),
                      const SizedBox(height: LumiSpacing.xs),
                      Row(
                        children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                            .map(
                              (w) => Expanded(
                                child: Text(
                                  w,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: LumiSpacing.xs),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: days.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                        itemBuilder: (context, index) {
                          final day = days[index];
                          if (day == null) return const SizedBox.shrink();
                          final selected = _sameDay(day, selectedDay);
                          final isToday = _sameDay(day, now);
                          final hasEvents = eventDays.contains(
                            '${day.year}-${day.month}-${day.day}',
                          );

                          return GestureDetector(
                            onTap: () => onSelectDay(day),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? ext.accentColor
                                    : isToday
                                    ? ext.accentColor.withValues(alpha: 0.16)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  LumiRadius.sm,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: selected || isToday
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selected ? Colors.white : ext.ink,
                                    ),
                                  ),
                                  if (hasEvents)
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selected
                                            ? Colors.white
                                            : ext.accentColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: LumiSpacing.md),
                Row(
                  children: [
                    Text(
                      DateFormat('EEE, MMM d').format(selectedDay),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    LumiGlassChip(
                      label: 'Add Item',
                      icon: Icons.add_rounded,
                      selected: true,
                      onTap: () => onAddForDay(selectedDay),
                    ),
                  ],
                ),
                const SizedBox(height: LumiSpacing.sm),
                if (dayItems.isEmpty && dayReminders.isEmpty)
                  LumiGlass.card(
                    child: Text(
                      'Nothing scheduled on this day yet. Tap "Add Item" to plan ahead.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: ext.inkMuted),
                    ),
                  )
                else ...[
                  ...dayItems.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: LumiSpacing.xs),
                      child: LumiGlass.card(
                        onTap: () => context.push('/editor/${s.item.id}'),
                        child: Row(
                          children: [
                            Icon(
                              s.type == LumiItemType.checklist
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.note_outlined,
                              color: ext.accentColor,
                            ),
                            const SizedBox(width: LumiSpacing.sm),
                            Expanded(
                              child: Text(
                                s.item.title.isEmpty
                                    ? 'Untitled'
                                    : s.item.title,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Text(
                              s.boardStatus.label,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ...dayReminders.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: LumiSpacing.xs),
                      child: LumiGlass.card(
                        onTap: () => context.push('/editor/${r.itemId}'),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_active_outlined,
                              color: LumiColors.warning,
                            ),
                            const SizedBox(width: LumiSpacing.sm),
                            Expanded(
                              child: Text(
                                'Reminder at ${DateFormat('h:mm a').format(r.fireAt)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BoardsView extends StatelessWidget {
  const _BoardsView({
    required this.summaries,
    required this.onAddCard,
    required this.onMoveCard,
  });

  final List<LumiItemSummary> summaries;
  final ValueChanged<LumiBoardStatus> onAddCard;
  final void Function(String itemId, LumiBoardStatus status) onMoveCard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;
        final colWidth = wide
            ? (constraints.maxWidth - 48) / 3
            : constraints.maxWidth * 0.80;

        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(
            LumiSpacing.md,
            0,
            LumiSpacing.md,
            120,
          ),
          children: LumiBoardStatus.values.map((status) {
            final colCards = summaries
                .where((s) => s.boardStatus == status)
                .toList();

            return Container(
              width: colWidth.clamp(250.0, 380.0),
              margin: const EdgeInsets.only(right: LumiSpacing.sm),
              child: DragTarget<String>(
                onAcceptWithDetails: (details) =>
                    onMoveCard(details.data, status),
                builder: (context, candidateData, rejectedData) {
                  final hovered = candidateData.isNotEmpty;
                  return LumiGlass.card(
                    tintColor: hovered ? context.lumiTheme.accentColor : null,
                    padding: const EdgeInsets.all(LumiSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              status.label,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${colCards.length}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.add_rounded, size: 20),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Add card to ${status.label}',
                              onPressed: () => onAddCard(status),
                            ),
                          ],
                        ),
                        const SizedBox(height: LumiSpacing.xs),
                        Expanded(
                          child: ListView.separated(
                            itemCount: colCards.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: LumiSpacing.xs),
                            itemBuilder: (context, idx) {
                              final card = colCards[idx];
                              return Draggable<String>(
                                data: card.item.id,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: 240,
                                    child: LumiGlass(
                                      blur: 16,
                                      elevated: true,
                                      grouped: false,
                                      padding: const EdgeInsets.all(
                                        LumiSpacing.sm,
                                      ),
                                      child: Text(
                                        card.item.title.isEmpty
                                            ? 'Untitled'
                                            : card.item.title,
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.35,
                                  child: _BoardCardTile(
                                    summary: card,
                                    onMove: onMoveCard,
                                  ),
                                ),
                                child: _BoardCardTile(
                                  summary: card,
                                  onMove: onMoveCard,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _BoardCardTile extends StatelessWidget {
  const _BoardCardTile({required this.summary, required this.onMove});

  final LumiItemSummary summary;
  final void Function(String itemId, LumiBoardStatus status) onMove;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final item = summary.item;
    final status = summary.boardStatus;

    return LumiGlass.card(
      onTap: () => context.push('/editor/${item.id}'),
      padding: const EdgeInsets.all(LumiSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title.isEmpty ? 'Untitled' : item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (item.plainText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.plainText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: ext.inkMuted),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              if (summary.checklistTotal > 0)
                Text(
                  '${summary.checklistDone}/${summary.checklistTotal}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              const Spacer(),
              if (status != LumiBoardStatus.todo)
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Move left',
                  onPressed: () => onMove(
                    item.id,
                    status == LumiBoardStatus.done
                        ? LumiBoardStatus.doing
                        : LumiBoardStatus.todo,
                  ),
                ),
              if (status != LumiBoardStatus.done)
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Move right',
                  onPressed: () => onMove(
                    item.id,
                    status == LumiBoardStatus.todo
                        ? LumiBoardStatus.doing
                        : LumiBoardStatus.done,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
