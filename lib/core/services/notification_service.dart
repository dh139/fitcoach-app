import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // ─────────────────────────────────────────────
  // INITIALIZE  (call once in main.dart)
  // ─────────────────────────────────────────────
  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notificationsPlugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) {
        debugPrint('🔔 Notification tapped: ${details.payload}');
      },
    );

    // Timezone setup
    tz.initializeTimeZones();
    try {
      final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
      final String ianaId = tzInfo.identifier; // e.g. "Asia/Kolkata"
      tz.setLocalLocation(tz.getLocation(ianaId));
      debugPrint('✅ Timezone set to: $ianaId');
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      debugPrint('⚠️ Timezone fallback to UTC — error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // DEBUG HELPER  — call this once to diagnose
  // Add this call anywhere, e.g. a temporary button
  // in your profile screen: 
  //   ref.read(notificationServiceProvider).runDiagnostics();
  // ─────────────────────────────────────────────
  Future<void> runDiagnostics() async {
    debugPrint('──────────── NOTIFICATION DIAGNOSTICS ────────────');

    // 1. Timezone
    debugPrint('🕐 tz.local      = ${tz.local.name}');
    debugPrint('🕐 Now (TZ)      = ${tz.TZDateTime.now(tz.local)}');
    debugPrint('🕐 Now (UTC)     = ${DateTime.now().toUtc()}');

    // 2. Permissions
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? notifGranted =
          await androidPlugin?.areNotificationsEnabled();
      final bool? exactGranted =
          await androidPlugin?.canScheduleExactNotifications();

      debugPrint('🔐 Notifications enabled : $notifGranted');
      debugPrint('🔐 Exact alarms granted  : $exactGranted');

      if (exactGranted == false) {
        debugPrint('❌ EXACT ALARM MISSING — requesting now...');
        await androidPlugin?.requestExactAlarmsPermission();
      }
    }

    // 3. Pending notifications
    final pending =
        await _notificationsPlugin.pendingNotificationRequests();
    debugPrint('📋 Pending count: ${pending.length}');
    for (final n in pending) {
      debugPrint('   • id=${n.id}  title="${n.title}"');
    }

    // 4. Immediate notification to confirm channel works
    debugPrint('📤 Firing immediate test notification...');
    await showImmediateNotification(
      title: '🔧 Diagnostics test',
      body: 'Channel works! Check logcat for scheduling details.',
    );

    debugPrint('──────────── END DIAGNOSTICS ────────────');
  }

  // ─────────────────────────────────────────────
  // REQUEST PERMISSIONS
  // ─────────────────────────────────────────────
  Future<void> requestPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();

    // iOS
    await plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+ notification permission
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    // Android 12+ exact alarm permission
    if (Platform.isAndroid) {
      final canSchedule =
          await androidPlugin?.canScheduleExactNotifications();
      debugPrint('🔐 canScheduleExactNotifications = $canSchedule');
      if (canSchedule == false) {
        await androidPlugin?.requestExactAlarmsPermission();
      }
    }
  }

  // ─────────────────────────────────────────────
  // AUTO-SCHEDULE DEFAULT (9 AM) IF NEVER SET
  // ─────────────────────────────────────────────
  Future<void> autoScheduleDefaultIfNeeded() async {
    final box = await Hive.openBox('settings');
    if (!box.containsKey('notifHour')) {
      await scheduleDailyWorkoutReminder(
        id: 1,
        title: 'FitCoach AI Reminder ⚡',
        body:
            "Morning! Your customized daily plan is ready. Let's crush today's active goals!",
        hour: 9,
        minute: 0,
      );
    } else {
      await scheduleDailyWorkoutReminder(
        id: 1,
        title: 'FitCoach AI Reminder ⚡',
        body: "Your dynamic workout plan is ready. Time to hit your goals!",
        hour: box.get('notifHour') as int,
        minute: box.get('notifMinute') as int,
      );
    }
  }

  // ─────────────────────────────────────────────
  // SCHEDULE DAILY RECURRING NOTIFICATION
  // ─────────────────────────────────────────────
  Future<void> scheduleDailyWorkoutReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    // Cancel any stale notification with this id first
    await _notificationsPlugin.cancel(id);

    // Persist the chosen time
    final box = await Hive.openBox('settings');
    await box.put('notifHour', hour);
    await box.put('notifMinute', minute);

    const androidDetails = AndroidNotificationDetails(
      'daily_workout_channel_id',
      'Workout Reminders',
      channelDescription: 'Daily AI fitness suggestions',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('📅 Scheduling notification:');
    debugPrint('   • id       = $id');
    debugPrint('   • fires at = $scheduledDate');
    debugPrint('   • tz.local = ${tz.local.name}');
    debugPrint('   • now      = $now');
    debugPrint(
        '   • in       = ${scheduledDate.difference(now).inMinutes} min');

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Confirm it landed in the pending list
    final pending =
        await _notificationsPlugin.pendingNotificationRequests();
    final queued = pending.any((n) => n.id == id);
    debugPrint(queued
        ? '✅ Queued! Total pending: ${pending.length}'
        : '❌ NOT in pending list — zonedSchedule may have thrown silently');
  }

  // ─────────────────────────────────────────────
  // IMMEDIATE NOTIFICATION (milestones / test)
  // ─────────────────────────────────────────────
  Future<void> showImmediateNotification(
      {required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'milestones_channel_id',
      'Milestones',
      channelDescription: 'Goal achievements',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );
    await _notificationsPlugin.show(
      888,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('🗑️ All notifications cancelled');
  }
}