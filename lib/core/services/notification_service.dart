import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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
      settings: const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) {
        debugPrint('🔔 Notification tapped: ${details.payload}');
      },
    );

    // Timezone setup
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      String ianaId = tzInfo.identifier;
      if (ianaId == 'Asia/Calcutta') ianaId = 'Asia/Kolkata';
      if (ianaId == 'Asia/Rangoon') ianaId = 'Asia/Yangon';
      
      tz.setLocalLocation(tz.getLocation(ianaId));
      debugPrint('✅ Timezone set to: $ianaId');
    } catch (e, stack) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      debugPrint('⚠️ Timezone fallback to UTC — error: $e');
      debugPrint('Stacktrace: $stack');
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

    // 5. 10-Second delayed notification test
    debugPrint('⏳ Scheduling 10-second delayed test...');
    final nowTz = tz.TZDateTime.now(tz.local);
    final delayedTime = nowTz.add(const Duration(seconds: 10));
    
    await _notificationsPlugin.zonedSchedule(
      id: 999,
      title: '⏰ Delayed Test',
      body: 'This proves AlarmManager is working!',
      scheduledDate: delayedTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
  // SAVE PREFERRED TIME (Handled by Background Service)
  // ─────────────────────────────────────────────
  Future<void> scheduleDailyWorkoutReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    // We no longer use zonedSchedule because AlarmManager can be unreliable.
    // Instead, we just save the preferred time here, and the 24/7 background 
    // service will dynamically fetch the AI message and fire it when the time comes!
    final box = await Hive.openBox('settings');
    await box.put('notifHour', hour);
    await box.put('notifMinute', minute);
    
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('updateSettings', {
        'notifHour': hour,
        'notifMinute': minute,
      });
    }
    
    debugPrint('✅ Saved AI Notification preference for $hour:$minute');
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
      id: 888,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('🗑️ All notifications cancelled');
  }
}