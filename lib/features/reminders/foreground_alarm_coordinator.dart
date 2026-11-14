import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/lumi_router.dart';
import '../../core/design/design_system.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import '../../data/repositories/reminders_repository.dart';
import 'notification_service.dart';

/// Watches scheduled reminders in real time and fires both a native OS alarm
/// notification and an interactive Liquid Glass Alarm modal when a reminder hits
/// its scheduled time while Lumi is open.
class ForegroundAlarmCoordinator extends ConsumerStatefulWidget {
  const ForegroundAlarmCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ForegroundAlarmCoordinator> createState() =>
      _ForegroundAlarmCoordinatorState();
}

class _ForegroundAlarmCoordinatorState
    extends ConsumerState<ForegroundAlarmCoordinator> {
  final DateTime _sessionStart = DateTime.now();
  final Set<String> _triggeredKeys = {};
  Timer? _nextTimer;
  bool _dialogOpen = false;

  @override
  void dispose() {
    _nextTimer?.cancel();
    super.dispose();
  }

  void _syncSchedule(List<Reminder> reminders, List<Item> items) {
    _nextTimer?.cancel();
    if (!mounted || reminders.isEmpty) return;

    final now = DateTime.now();
    final itemById = {for (final item in items) item.id: item};
    DateTime? earliestFuture;

    for (final r in reminders) {
      final title = r.title.trim().isNotEmpty
          ? r.title.trim()
          : (itemById[r.itemId]?.title ?? 'Lumi Alarm');

      final early = LumiEarlyReminder.fromMinutes(r.earlyReminderMinutes);
      if (early != LumiEarlyReminder.none) {
        final earlyAt = ReminderScheduleLogic.computeEarlyFireAt(
          r.fireAt,
          early,
        );
        if (earlyAt != null) {
          final earlyKey = 'early:${r.id}:${earlyAt.millisecondsSinceEpoch}';
          if (!earlyAt.isAfter(now) &&
              earlyAt.isAfter(
                _sessionStart.subtract(const Duration(seconds: 2)),
              ) &&
              !_triggeredKeys.contains(earlyKey)) {
            _triggeredKeys.add(earlyKey);
            unawaited(
              _fireEarlyHeadsUp(
                reminder: r,
                title: title,
                earlyLabel: early.label,
              ),
            );
          } else if (earlyAt.isAfter(now)) {
            if (earliestFuture == null || earlyAt.isBefore(earliestFuture)) {
              earliestFuture = earlyAt;
            }
          }
        }
      }

      final mainKey = 'main:${r.id}:${r.fireAt.millisecondsSinceEpoch}';
      if (!r.fireAt.isAfter(now) &&
          r.fireAt.isAfter(
            _sessionStart.subtract(const Duration(seconds: 2)),
          ) &&
          !_triggeredKeys.contains(mainKey)) {
        _triggeredKeys.add(mainKey);
        unawaited(_fireMainAlarm(reminder: r, title: title));
      } else if (r.fireAt.isAfter(now)) {
        if (earliestFuture == null || r.fireAt.isBefore(earliestFuture)) {
          earliestFuture = r.fireAt;
        }
      }
    }

    if (earliestFuture != null) {
      var delay =
          earliestFuture.difference(now) + const Duration(milliseconds: 50);
      const maxDelay = Duration(hours: 6);
      if (delay > maxDelay) delay = maxDelay;
      if (delay < const Duration(milliseconds: 50)) {
        delay = const Duration(milliseconds: 50);
      }
      _nextTimer = Timer(delay, () {
        if (!mounted) return;
        final latestReminders =
            ref.read(scheduledRemindersStreamProvider).value ?? const [];
        final latestItems =
            ref.read(allActiveItemsStreamProvider).value ?? const [];
        _syncSchedule(latestReminders, latestItems);
      });
    }
  }

  Future<void> _fireEarlyHeadsUp({
    required Reminder reminder,
    required String title,
    required String earlyLabel,
  }) async {
    final hapticsOn = LumiDesignScope.maybeOf(context)?.hapticsEnabled ?? true;
    try {
      await SystemSound.play(SystemSoundType.alert);
      if (hapticsOn) {
        await HapticFeedback.selectionClick();
      }
    } catch (_) {}

    if (!mounted) return;
    final navCtx = rootNavigatorKey.currentContext;
    if (navCtx != null && navCtx.mounted) {
      ScaffoldMessenger.maybeOf(navCtx)?.showSnackBar(
        SnackBar(
          content: Text('Upcoming in $earlyLabel: $title'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _fireMainAlarm({
    required Reminder reminder,
    required String title,
  }) async {
    final hapticsOn = LumiDesignScope.maybeOf(context)?.hapticsEnabled ?? true;
    unawaited(
      ref
          .read(notificationServiceProvider)
          .showAlarmNow(reminder: reminder, title: title),
    );
    try {
      await SystemSound.play(SystemSoundType.alert);
      if (hapticsOn) {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {}

    if (!mounted || _dialogOpen) return;
    final navCtx = rootNavigatorKey.currentContext;
    if (navCtx == null || !navCtx.mounted) return;

    _dialogOpen = true;
    try {
      await showDialog<void>(
        context: navCtx,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.alarm_on_rounded,
                color: dialogCtx.lumiTheme.accentColor,
              ),
              const SizedBox(width: LumiSpacing.xs),
              const Expanded(child: Text('Reminder Alarm')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(dialogCtx).textTheme.titleLarge),
              const SizedBox(height: LumiSpacing.xs),
              Text(
                DateFormat('EEE, MMM d • h:mm a').format(reminder.fireAt),
                style: Theme.of(dialogCtx).textTheme.bodyMedium
                    ?.copyWith(color: dialogCtx.lumiTheme.inkMuted),
              ),
            ],
          ),
          actions: [
            LumiGlassButton(
              label: 'Snooze 15m',
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final updated = await ref
                    .read(remindersRepositoryProvider)
                    .snoozeReminder(reminder.id, const Duration(minutes: 15));
                if (updated != null) {
                  await ref
                      .read(notificationServiceProvider)
                      .scheduleForReminder(reminder: updated, title: title);
                }
              },
            ),
            LumiGlassButton(
              label: 'Dismiss',
              primary: true,
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final notifications = ref.read(notificationServiceProvider);
                await notifications.cancelReminderAndEarly(reminder);
                final updated = await ref
                    .read(remindersRepositoryProvider)
                    .completeReminder(reminder.id);
                if (updated != null &&
                    updated.status == LumiReminderStatus.scheduled.dbValue) {
                  await notifications.scheduleForReminder(
                    reminder: updated,
                    title: title,
                  );
                }
              },
            ),
          ],
        ),
      );
    } finally {
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminders =
        ref.watch(scheduledRemindersStreamProvider).value ?? const [];
    final items = ref.watch(allActiveItemsStreamProvider).value ?? const [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncSchedule(reminders, items);
      }
    });
    return widget.child;
  }
}
