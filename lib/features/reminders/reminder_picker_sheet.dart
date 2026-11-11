import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/design/design_system.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import 'notification_service.dart';

/// Opens a glass sheet to create or edit a standalone or item-linked reminder
/// with custom title, independent date & time pickers, early heads-up alert
/// (from 5 minutes to 1 month before), and repeat cadence.
Future<Reminder?> showReminderPickerSheet({
  required BuildContext context,
  WidgetRef? ref,
  String? itemId,
  String itemTitle = '',
  Reminder? existingReminder,
  String? entryId,
  String? entryLabel,
}) {
  final heading = existingReminder != null
      ? 'Edit Reminder'
      : entryLabel != null
      ? 'Remind: $entryLabel'
      : 'Schedule Reminder';

  return showLumiGlassBottomSheet<Reminder>(
    context: context,
    title: heading,
    builder: (ctx) => _ReminderPickerContent(
      itemId: itemId,
      itemTitle: itemTitle,
      existingReminder: existingReminder,
      entryId: entryId,
      entryLabel: entryLabel,
    ),
  );
}

class _ReminderPickerContent extends ConsumerStatefulWidget {
  const _ReminderPickerContent({
    this.itemId,
    required this.itemTitle,
    this.existingReminder,
    this.entryId,
    this.entryLabel,
  });

  final String? itemId;
  final String itemTitle;
  final Reminder? existingReminder;
  final String? entryId;
  final String? entryLabel;

  @override
  ConsumerState<_ReminderPickerContent> createState() =>
      _ReminderPickerContentState();
}

class _ReminderPickerContentState
    extends ConsumerState<_ReminderPickerContent> {
  late final TextEditingController _titleController;
  late DateTime _selectedDateTime;
  late LumiRepeatRule _repeat;
  late LumiEarlyReminder _early;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingReminder;
    final now = DateTime.now();
    if (existing != null) {
      _selectedDateTime = existing.fireAt;
      _repeat = LumiRepeatRule.fromDb(existing.repeatRule);
      _early = LumiEarlyReminder.fromMinutes(existing.earlyReminderMinutes);
      final initialTitle = existing.title.trim().isNotEmpty
          ? existing.title.trim()
          : (widget.entryLabel?.trim().isNotEmpty == true
                ? widget.entryLabel!.trim()
                : widget.itemTitle.trim());
      _titleController = TextEditingController(text: initialTitle);
    } else {
      _selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      ).add(const Duration(hours: 1));
      _repeat = LumiRepeatRule.none;
      _early = LumiEarlyReminder.none;
      final initialTitle = widget.entryLabel?.trim().isNotEmpty == true
          ? widget.entryLabel!.trim()
          : widget.itemTitle.trim();
      _titleController = TextEditingController(text: initialTitle);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDay = DateTime(
      _selectedDateTime.year,
      _selectedDateTime.month,
      _selectedDateTime.day,
    );
    final firstDate = currentDay.isBefore(today)
        ? currentDay
        : today.subtract(const Duration(days: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDay.isBefore(firstDate) ? today : currentDay,
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 365 * 5)),
    );
    if (pickedDate == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final rawTitle = _titleController.text.trim();
      final resolvedTitle = rawTitle.isNotEmpty
          ? rawTitle
          : (widget.itemTitle.trim().isNotEmpty
                ? widget.itemTitle.trim()
                : 'Reminder');

      final notifications = ref.read(notificationServiceProvider);
      try {
        await notifications.requestPermissions().timeout(
          const Duration(seconds: 2),
        );
      } catch (_) {}

      final remindersRepo = ref.read(remindersRepositoryProvider);
      final itemsRepo = ref.read(itemsRepositoryProvider);
      final existing = widget.existingReminder;

      Reminder? result;
      if (existing != null) {
        await notifications.cancelReminderAndEarly(existing);
        result = await remindersRepo.updateReminder(
          id: existing.id,
          title: resolvedTitle,
          fireAt: _selectedDateTime,
          repeatRule: _repeat,
          earlyReminderMinutes: _early.minutes,
        );
      } else {
        var targetItemId = widget.itemId;
        if (targetItemId == null || targetItemId.isEmpty) {
          final created = await itemsRepo.createItem(
            type: LumiItemType.reminder,
            title: resolvedTitle,
            dueDate: _selectedDateTime,
          );
          targetItemId = created.id;
        } else {
          final parent = await itemsRepo.getItem(targetItemId);
          if (parent != null && parent.dueDate == null) {
            await itemsRepo.updateMetadata(
              id: targetItemId,
              dueDate: Value(_selectedDateTime),
            );
          }
        }

        result = await remindersRepo.scheduleReminder(
          itemId: targetItemId,
          entryId: widget.entryId,
          title: resolvedTitle,
          fireAt: _selectedDateTime,
          repeatRule: _repeat,
          earlyReminderMinutes: _early.minutes,
        );
      }

      if (result != null) {
        try {
          await notifications
              .scheduleForReminder(reminder: result, title: resolvedTitle)
              .timeout(const Duration(seconds: 2));
        } catch (_) {}
      }

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final now = DateTime.now();
    final presets = <(String, DateTime)>[
      ('In 15 min', now.add(const Duration(minutes: 15))),
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
          LumiGlass.card(
            padding: const EdgeInsets.symmetric(
              horizontal: LumiSpacing.sm,
              vertical: 2,
            ),
            child: TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.title_rounded, size: 19),
                hintText: 'Reminder title (e.g. Call Alex, Take medicine)',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: LumiSpacing.xs + 2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < presets.length; i++) ...[
                  if (i > 0) const SizedBox(width: LumiSpacing.xs),
                  LumiGlassChip(
                    label: presets[i].$1,
                    selected:
                        (_selectedDateTime.difference(presets[i].$2).inMinutes)
                            .abs() <
                        2,
                    icon: Icons.schedule_rounded,
                    onTap: () => setState(
                      () => _selectedDateTime = DateTime(
                        presets[i].$2.year,
                        presets[i].$2.month,
                        presets[i].$2.day,
                        presets[i].$2.hour,
                        presets[i].$2.minute,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: LumiSpacing.sm),
          Text('Date & Time', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: LumiSpacing.xs),
          Row(
            children: [
              Expanded(
                child: LumiGlass.card(
                  key: const ValueKey('reminder_date_picker_btn'),
                  onTap: _pickDate,
                  padding: const EdgeInsets.symmetric(
                    horizontal: LumiSpacing.sm,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: ext.accentColor,
                        size: 18,
                      ),
                      const SizedBox(width: LumiSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEE, MMM d')
                                  .format(_selectedDateTime),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              'Change date',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: ext.inkMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: LumiSpacing.xs),
              Expanded(
                child: LumiGlass.card(
                  key: const ValueKey('reminder_time_picker_btn'),
                  onTap: _pickTime,
                  padding: const EdgeInsets.symmetric(
                    horizontal: LumiSpacing.sm,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: ext.accentColor,
                        size: 18,
                      ),
                      const SizedBox(width: LumiSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('h:mm a').format(_selectedDateTime),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              'Change time',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: ext.inkMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LumiSpacing.sm),
          Row(
            children: [
              Text(
                'Early Reminder',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(width: LumiSpacing.sm),
              Expanded(
                child: Text(
                  _early.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _early == LumiEarlyReminder.none
                        ? ext.inkMuted
                        : ext.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LumiSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < LumiEarlyReminder.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: LumiSpacing.xs),
                  LumiGlassChip(
                    label: LumiEarlyReminder.values[i].shortLabel,
                    selected: _early == LumiEarlyReminder.values[i],
                    onTap: () =>
                        setState(() => _early = LumiEarlyReminder.values[i]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: LumiSpacing.sm),
          Text('Repeat', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: LumiSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < LumiRepeatRule.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: LumiSpacing.xs),
                  LumiGlassChip(
                    label: LumiRepeatRule.values[i].label,
                    selected: _repeat == LumiRepeatRule.values[i],
                    onTap: () =>
                        setState(() => _repeat = LumiRepeatRule.values[i]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: LumiSpacing.md),
          LumiGlassButton(
            label: widget.existingReminder != null
                ? 'Update Reminder'
                : 'Set Reminder Alarm',
            primary: true,
            expanded: true,
            isLoading: _saving,
            icon: Icons.alarm_add_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
