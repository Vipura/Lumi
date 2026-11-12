import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/design/design_system.dart';
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

  Future<void> _openPlanComposer({
    DateTime? defaultDueDay,
    LumiBoardStatus defaultStatus = LumiBoardStatus.todo,
  }) async {
    final result =
        await showDialog<
          ({
            String title,
            String details,
            LumiBoardStatus status,
            DateTime? due,
          })
        >(
          context: context,
          builder: (_) => _NewPlanDialog(
            defaultDueDay: defaultDueDay,
            defaultStatus: defaultStatus,
          ),
        );

    if (result == null || result.title.isEmpty) return;

    await ref
        .read(itemsRepositoryProvider)
        .createItem(
          type: LumiItemType.card,
          title: result.title,
          initialPlainText: result.details.isNotEmpty ? result.details : null,
          dueDate: result.due,
          boardStatus: result.status,
        );
  }

  void _updatePlanStatus(String itemId, LumiBoardStatus status) {
    if (LumiDesignScope.maybeOf(context)?.hapticsEnabled ?? true) {
      unawaited(HapticFeedback.lightImpact());
    }
    unawaited(
      ref
          .read(itemsRepositoryProvider)
          .updateMetadata(id: itemId, boardStatus: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansSummariesProvider);

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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Plan',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: LumiSpacing.sm),
                  LumiGlassEffectContainer(
                    showDividers: false,
                    spacing: 4,
                    padding: const EdgeInsets.all(4),
                    children: [
                      LumiGlassChip(
                        label: 'Calendar',
                        icon: Icons.calendar_month_rounded,
                        selected: _tab == _PlannerTab.calendar,
                        onTap: () =>
                            setState(() => _tab = _PlannerTab.calendar),
                      ),
                      LumiGlassChip(
                        label: 'Boards',
                        icon: Icons.view_kanban_rounded,
                        selected: _tab == _PlannerTab.boards,
                        onTap: () => setState(() => _tab = _PlannerTab.boards),
                      ),
                    ],
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
                      plans: plans,
                      onToggleWeekMode: () =>
                          setState(() => _weekMode = !_weekMode),
                      onChangeMonth: (delta) => setState(() {
                        _focusedMonth = DateTime(
                          _focusedMonth.year,
                          _focusedMonth.month + delta,
                        );
                      }),
                      onSelectDay: (day) => setState(() => _selectedDay = day),
                      onAddForDay: (day) =>
                          _openPlanComposer(defaultDueDay: day),
                      onUpdateStatus: _updatePlanStatus,
                    )
                  : _BoardsView(
                      plans: plans,
                      onAddCard: (status) =>
                          _openPlanComposer(defaultStatus: status),
                      onMoveCard: _updatePlanStatus,
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
    required this.plans,
    required this.onToggleWeekMode,
    required this.onChangeMonth,
    required this.onSelectDay,
    required this.onAddForDay,
    required this.onUpdateStatus,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final bool weekMode;
  final List<LumiItemSummary> plans;
  final VoidCallback onToggleWeekMode;
  final ValueChanged<int> onChangeMonth;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<DateTime> onAddForDay;
  final void Function(String itemId, LumiBoardStatus status) onUpdateStatus;

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
    for (final s in plans) {
      final d = s.item.dueDate;
      if (d != null) eventDays.add('${d.year}-${d.month}-${d.day}');
    }

    final dayPlans = plans
        .where(
          (s) =>
              s.item.dueDate != null && _sameDay(s.item.dueDate!, selectedDay),
        )
        .toList();

    final calendarCard = LumiGlass.card(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                onPressed: () => onChangeMonth(-1),
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(focusedMonth),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                onPressed: () => onChangeMonth(1),
              ),
              const SizedBox(width: 4),
              LumiGlassChip(
                label: weekMode ? 'Month' : 'Week',
                onTap: onToggleWeekMode,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (w) => Expanded(
                    child: Text(
                      w,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              mainAxisExtent: 34,
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
                    borderRadius: BorderRadius.circular(LumiRadius.sm),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: selected || isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? Colors.white : ext.ink,
                        ),
                      ),
                      if (hasEvents)
                        Container(
                          margin: const EdgeInsets.only(top: 1.5),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? Colors.white : ext.accentColor,
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
    );

    final dayAgenda = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('EEE, MMM d').format(selectedDay),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            LumiGlassChip(
              label: 'New Plan',
              icon: Icons.add_rounded,
              selected: true,
              onTap: () => onAddForDay(selectedDay),
            ),
          ],
        ),
        const SizedBox(height: LumiSpacing.sm),
        if (dayPlans.isEmpty)
          LumiGlass.card(
            child: Text(
              'No plans scheduled for this day yet. Tap "New Plan" to add one.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: ext.inkMuted),
            ),
          )
        else
          ...dayPlans.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: LumiSpacing.xs),
              child: LumiGlass.card(
                onTap: () => context.push('/editor/${s.item.id}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: LumiSpacing.md,
                  vertical: LumiSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.view_kanban_outlined,
                      color: ext.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: LumiSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.item.title.isEmpty
                                ? 'Untitled plan'
                                : s.item.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (s.item.plainText.trim().isNotEmpty)
                            Text(
                              s.item.plainText.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: ext.inkMuted),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: LumiSpacing.xs),
                    _PlanStatusPill(
                      status: s.boardStatus,
                      onSelected: (next) => onUpdateStatus(s.item.id, next),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 780) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              LumiSpacing.md,
              0,
              LumiSpacing.md,
              120,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 344, child: calendarCard),
                    const SizedBox(width: LumiSpacing.md),
                    Expanded(child: dayAgenda),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            LumiSpacing.md,
            0,
            LumiSpacing.md,
            120,
          ),
          children: [
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: calendarCard,
              ),
            ),
            const SizedBox(height: LumiSpacing.md),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: dayAgenda,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BoardsView extends StatelessWidget {
  const _BoardsView({
    required this.plans,
    required this.onAddCard,
    required this.onMoveCard,
  });

  final List<LumiItemSummary> plans;
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
            final colCards = plans
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
                              tooltip: 'Add plan to ${status.label}',
                              onPressed: () => onAddCard(status),
                            ),
                          ],
                        ),
                        const SizedBox(height: LumiSpacing.xs),
                        Expanded(
                          child: colCards.isEmpty
                              ? Center(
                                  child: Text(
                                    'No plans in ${status.label}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: context.lumiTheme.inkMuted,
                                        ),
                                  ),
                                )
                              : ListView.separated(
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
                                            useBlur: false,
                                            blur: 0,
                                            elevated: true,
                                            grouped: false,
                                            padding: const EdgeInsets.all(
                                              LumiSpacing.sm,
                                            ),
                                            child: Text(
                                              card.item.title.isEmpty
                                                  ? 'Untitled plan'
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
            item.title.isEmpty ? 'Untitled plan' : item.title,
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
              _PlanStatusPill(
                status: status,
                onSelected: (next) => onMove(item.id, next),
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

class _PlanStatusPill extends StatelessWidget {
  const _PlanStatusPill({required this.status, required this.onSelected});

  final LumiBoardStatus status;
  final ValueChanged<LumiBoardStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      LumiBoardStatus.todo => context.lumiTheme.inkMuted,
      LumiBoardStatus.doing => LumiColors.info,
      LumiBoardStatus.done => LumiColors.success,
    };

    return PopupMenuButton<LumiBoardStatus>(
      tooltip: 'Change status',
      padding: EdgeInsets.zero,
      onSelected: onSelected,
      itemBuilder: (_) => LumiBoardStatus.values
          .map(
            (s) => PopupMenuItem<LumiBoardStatus>(
              value: s,
              child: Row(
                children: [
                  Icon(
                    s == status
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: s == LumiBoardStatus.done
                        ? LumiColors.success
                        : s == LumiBoardStatus.doing
                        ? LumiColors.info
                        : context.lumiTheme.inkMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(s.label),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(LumiRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

class _NewPlanDialog extends StatefulWidget {
  const _NewPlanDialog({
    this.defaultDueDay,
    this.defaultStatus = LumiBoardStatus.todo,
  });

  final DateTime? defaultDueDay;
  final LumiBoardStatus defaultStatus;

  @override
  State<_NewPlanDialog> createState() => _NewPlanDialogState();
}

class _NewPlanDialogState extends State<_NewPlanDialog> {
  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  late LumiBoardStatus _chosenStatus;
  DateTime? _chosenDue;

  @override
  void initState() {
    super.initState();
    _chosenStatus = widget.defaultStatus;
    final day = widget.defaultDueDay;
    _chosenDue = day != null
        ? DateTime(day.year, day.month, day.day, 10, 0)
        : null;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    return AlertDialog(
      title: Text(
        widget.defaultDueDay != null
            ? 'New Plan • ${DateFormat('MMM d').format(widget.defaultDueDay!)}'
            : 'New Plan',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Plan title',
                hintText: 'e.g. Ship beta build, Prepare deck',
              ),
            ),
            const SizedBox(height: LumiSpacing.sm),
            TextField(
              controller: _detailsCtrl,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Details (optional)',
                hintText: 'Quick context or goal...',
              ),
            ),
            const SizedBox(height: LumiSpacing.md),
            Text('Status', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: LumiSpacing.xs),
            Wrap(
              spacing: LumiSpacing.xs,
              runSpacing: LumiSpacing.xs,
              children: LumiBoardStatus.values.map((status) {
                return LumiGlassChip(
                  label: status.label,
                  selected: _chosenStatus == status,
                  onTap: () => setState(() => _chosenStatus = status),
                );
              }).toList(),
            ),
            const SizedBox(height: LumiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _chosenDue != null
                        ? 'Due: ${DateFormat('EEE, MMM d').format(_chosenDue!)}'
                        : 'No due date set',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: ext.inkMuted),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _chosenDue ?? now,
                      firstDate: now.subtract(const Duration(days: 365)),
                      lastDate: now.add(const Duration(days: 365 * 3)),
                    );
                    if (picked != null && mounted) {
                      setState(
                        () => _chosenDue = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          10,
                          0,
                        ),
                      );
                    }
                  },
                  child: Text(_chosenDue != null ? 'Change' : 'Set Date'),
                ),
                if (_chosenDue != null)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    tooltip: 'Clear date',
                    onPressed: () => setState(() => _chosenDue = null),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        LumiGlassButton(
          label: 'Create Plan',
          primary: true,
          onPressed: () => Navigator.of(context).pop((
            title: _titleCtrl.text.trim(),
            details: _detailsCtrl.text.trim(),
            status: _chosenStatus,
            due: _chosenDue,
          )),
        ),
      ],
    );
  }
}
