import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/reminders_repository.dart';

final notificationServiceProvider = Provider<LumiNotificationService>(
  (ref) => LumiNotificationService(),
);

/// Handles local alarm & early reminder notifications across iOS, Android,
/// macOS, Linux, Windows, and Web.
class LumiNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _tzInitialized = false;

  Future<void> initialize({
    void Function(String? payload)? onNotificationTap,
  }) async {
    if (_initialized) return;
    await _ensureTimezone();

    if (kIsWeb) {
      _initialized = true;
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open reminder',
    );
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Lumi',
      appUserModelId: 'Com.Lumi.App.Lumi',
      guid: 'a8a4b210-6c41-4c9b-9b7a-5d23d8b41c01',
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    try {
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          onNotificationTap?.call(response.payload);
        },
      );
    } catch (_) {
      // Tests / headless environments without platform channel stay safe.
    }

    _initialized = true;
  }

  Future<void> _ensureTimezone() async {
    if (_tzInitialized) return;
    tz_data.initializeTimeZones();
    if (!kIsWeb) {
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }
    _tzInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    await initialize();
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return (await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            )) ??
            false;
      }
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        final mac = _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
        return (await mac?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            )) ??
            false;
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final granted =
            (await android?.requestNotificationsPermission()) ?? true;
        await android?.requestExactAlarmsPermission();
        return granted;
      }
    } catch (_) {
      return false;
    }
    return true;
  }

  NotificationDetails _alarmDetails() {
    final androidDetails = AndroidNotificationDetails(
      'lumi_alarms_v2',
      'Lumi Reminder Alarms',
      channelDescription:
          'High-priority alarm alerts when a Lumi reminder reaches its time',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList(const [0, 450, 220, 450, 220, 600]),
      // FLAG_INSISTENT (4): repeat alarm sound until acknowledged.
      additionalFlags: Int32List.fromList(const [4]),
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
    );
    final windowsDetails = WindowsNotificationDetails(
      scenario: WindowsNotificationScenario.alarm,
      duration: WindowsNotificationDuration.long,
      audio: WindowsNotificationAudio.preset(
        sound: WindowsNotificationSound.alarm1,
        shouldLoop: true,
      ),
    );
    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );
  }

  NotificationDetails _earlyReminderDetails() {
    const androidDetails = AndroidNotificationDetails(
      'lumi_reminders',
      'Lumi Early Reminders',
      channelDescription: 'Heads-up alerts before scheduled reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
    );
    final windowsDetails = WindowsNotificationDetails(
      audio: WindowsNotificationAudio.preset(
        sound: WindowsNotificationSound.reminder,
      ),
    );
    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );
  }

  Future<void> _zonedScheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    required String payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
          matchDateTimeComponents: matchDateTimeComponents,
        );
      } catch (_) {}
    }
  }

  Future<void> scheduleForReminder({
    required Reminder reminder,
    required String title,
    String? body,
  }) async {
    await initialize();
    if (kIsWeb) return;

    final resolvedTitle = reminder.title.trim().isNotEmpty
        ? reminder.title.trim()
        : (title.trim().isNotEmpty ? title.trim() : 'Lumi Reminder');

    final early = LumiEarlyReminder.fromMinutes(reminder.earlyReminderMinutes);
    final earlyId = ReminderScheduleLogic.earlyNotificationIdFor(reminder.id);
    await cancelReminder(earlyId);

    if (!reminder.fireAt.isAfter(DateTime.now())) return;

    final scheduled = tz.TZDateTime.from(reminder.fireAt, tz.local);
    final rule = LumiRepeatRule.fromDb(reminder.repeatRule);
    final matchComponents = switch (rule) {
      LumiRepeatRule.none => null,
      LumiRepeatRule.daily => DateTimeComponents.time,
      LumiRepeatRule.weekly => DateTimeComponents.dayOfWeekAndTime,
      LumiRepeatRule.monthly => DateTimeComponents.dayOfMonthAndTime,
    };

    await _zonedScheduleWithFallback(
      id: reminder.notificationId,
      title: resolvedTitle,
      body: body ?? 'Reminder alarm • Tap to open Lumi',
      scheduledDate: scheduled,
      details: _alarmDetails(),
      payload: reminder.itemId,
      matchDateTimeComponents: matchComponents,
    );

    if (early != LumiEarlyReminder.none) {
      final earlyAt = ReminderScheduleLogic.computeEarlyFireAt(
        reminder.fireAt,
        early,
      );
      if (earlyAt != null && earlyAt.isAfter(DateTime.now())) {
        await _zonedScheduleWithFallback(
          id: earlyId,
          title: 'Upcoming: $resolvedTitle',
          body: 'Scheduled in ${early.label}',
          scheduledDate: tz.TZDateTime.from(earlyAt, tz.local),
          details: _earlyReminderDetails(),
          payload: reminder.itemId,
        );
      }
    }
  }

  /// Displays an immediate native alarm notification (used when a timer fires
  /// in-app or across desktop hosts without background wake alarms).
  Future<void> showAlarmNow({
    required Reminder reminder,
    required String title,
    String? body,
  }) async {
    await initialize();
    if (kIsWeb) return;
    final resolvedTitle = reminder.title.trim().isNotEmpty
        ? reminder.title.trim()
        : (title.trim().isNotEmpty ? title.trim() : 'Lumi Alarm');
    try {
      await _plugin.show(
        id: reminder.notificationId,
        title: resolvedTitle,
        body: body ?? 'Time for your scheduled reminder',
        notificationDetails: _alarmDetails(),
        payload: reminder.itemId,
      );
    } catch (_) {}
  }

  Future<void> cancelReminderAndEarly(Reminder reminder) async {
    await cancelReminder(reminder.notificationId);
    await cancelReminder(
      ReminderScheduleLogic.earlyNotificationIdFor(reminder.id),
    );
  }

  Future<void> cancelReminder(int notificationId) async {
    if (kIsWeb) return;
    try {
      await _plugin.cancel(id: notificationId);
    } catch (_) {}
  }
}
