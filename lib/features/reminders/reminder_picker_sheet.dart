import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/design/design_system.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import 'notification_service.dart';

/// Opens a glass sheet to attach a one-time or repeating reminder to an item
/// (or a specific checklist entry).
Future<Reminder?> showReminderPickerSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String itemId,
  required String itemTitle,
  String? entryId,
  String? entryLabel,
}) {
  return showLumiGlassBottomSheet<Reminder>(
    context: context,
    title: entryLabel != null ? 'Remind: $entryLabel' : 'Schedule Reminder',
    builder: (ctx) => _ReminderPickerContent(
      itemId: itemId,
      itemTitle: itemTitle,
      entryId: entryId,
    ),
  );
}

class _ReminderPickerContent extends ConsumerStatefulWidget {
  const _ReminderPickerContent({
    required this.itemId,
    required this.itemTitle,
    this.entryId,
  });

  final String itemId;
  final String itemTitle;
  final String? entryId;

  @override
  ConsumerState<_ReminderPickerContent> createState() =>
      _ReminderPickerContentState();
}

class _ReminderPickerContentState
    extends ConsumerState<_ReminderPickerContent> {
  late DateTime _selectedDateTime;
  LumiRepeatRule _repeat = LumiRepeatRule.none;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateTime = DateTime(now.year, now.month, now.day, now.hour + 1);
  }

  Future<void> _pickCustomDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime.isBefore(now) ? now : _selectedDateTime,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final notifications = ref.read(notificationServiceProvider);
    await notifications.requestPermissions();

    final repo = ref.read(remindersRepositoryProvider);
    final reminder = await repo.scheduleReminder(
      itemId: widget.itemId,
      entryId: widget.entryId,
      fireAt: _selectedDateTime,
      repeatRule: _repeat,
    );

    await notifications.scheduleForReminder(
      reminder: reminder,
      title: widget.itemTitle.isEmpty ? 'Lumi Reminder' : widget.itemTitle,
    );

    if (mounted) {
      Navigator.of(context).pop(reminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final now = DateTime.now();
    final presets = <(String, DateTime)>[
      ('In 1 hour', now.add(const Duration(hours: 1))),
      (
        'Tonight 6 PM',
        DateTime(now.year, now.month, now.day, 18, 0).isAfter(now)
            ? DateTime(now.year, now.month, now.day, 18, 0)
            : DateTime(now.year, now.month, now.day + 1, 18, 0),
      ),
      ('Tomorrow 9 AM', DateTime(now.year, now.month, now.day + 1, 9, 0)),
      ('Next week', DateTime(now.year, now.month, now.day + 7, 9, 0)),
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: LumiSpacing.xs,
            runSpacing: LumiSpacing.xs,
            children: presets.map((preset) {
              final selected =
                  (_selectedDateTime.difference(preset.$2).inMinutes).abs() < 2;
              return LumiGlassChip(
                label: preset.$1,
                selected: selected,
                icon: Icons.schedule_rounded,
                onTap: () => setState(() => _selectedDateTime = preset.$2),
              );
            }).toList(),
          ),
          const SizedBox(height: LumiSpacing.md),
          LumiGlass.card(
            onTap: _pickCustomDateTime,
            padding: const EdgeInsets.all(LumiSpacing.md),
            child: Row(
              children: [
                Icon(Icons.event_rounded, color: ext.accentColor),
                const SizedBox(width: LumiSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEE, MMM d • h:mm a')
                            .format(_selectedDateTime),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Tap to choose custom date & time',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_calendar_rounded,
                  color: ext.inkMuted,
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: LumiSpacing.md),
          Text('Repeat', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: LumiSpacing.xs),
          Wrap(
            spacing: LumiSpacing.xs,
            runSpacing: LumiSpacing.xs,
            children: LumiRepeatRule.values
                .map(
                  (rule) => LumiGlassChip(
                    label: rule.label,
                    selected: _repeat == rule,
                    onTap: () => setState(() => _repeat = rule),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: LumiSpacing.lg),
          LumiGlassButton(
            label: 'Set Reminder',
            primary: true,
            expanded: true,
            isLoading: _saving,
            icon: Icons.notifications_active_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
