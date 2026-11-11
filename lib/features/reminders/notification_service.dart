import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';

final notificationServiceProvider = Provider<LumiNotificationService>(
  (ref) => LumiNotificationService(),
);

/// Handles local reminder notifications across iOS, Android 13+, macOS, and Web.
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

    if (kIsWeb) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
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

  Future<void> scheduleForReminder({
    required Reminder reminder,
    required String title,
    String? body,
  }) async {
    await initialize();
    if (kIsWeb) return;
    if (!reminder.fireAt.isAfter(DateTime.now())) return;

    final scheduled = tz.TZDateTime.from(reminder.fireAt, tz.local);
    final rule = LumiRepeatRule.fromDb(reminder.repeatRule);
    final matchComponents = switch (rule) {
      LumiRepeatRule.none => null,
      LumiRepeatRule.daily => DateTimeComponents.time,
      LumiRepeatRule.weekly => DateTimeComponents.dayOfWeekAndTime,
      LumiRepeatRule.monthly => DateTimeComponents.dayOfMonthAndTime,
    };

    const androidDetails = AndroidNotificationDetails(
      'lumi_reminders',
      'Lumi Reminders',
      channelDescription: 'Scheduled reminders for Lumi notes and checklists',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _plugin.zonedSchedule(
        id: reminder.notificationId,
        title: title.isEmpty ? 'Lumi Reminder' : title,
        body: body ?? 'Tap to view in Lumi',
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: reminder.itemId,
        matchDateTimeComponents: matchComponents,
      );
    } catch (_) {
      // Fallback if exact alarm permission is denied on Android 14+.
      try {
        await _plugin.zonedSchedule(
          id: reminder.notificationId,
          title: title.isEmpty ? 'Lumi Reminder' : title,
          body: body ?? 'Tap to view in Lumi',
          scheduledDate: scheduled,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: reminder.itemId,
          matchDateTimeComponents: matchComponents,
        );
      } catch (_) {}
    }
  }

  Future<void> cancelReminder(int notificationId) async {
    if (kIsWeb) return;
    try {
      await _plugin.cancel(id: notificationId);
    } catch (_) {}
  }
}
