import 'dart:async';
import 'dart:ui';
import 'dart:io' show Platform;
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'notification_service.dart';
import '../../features/coach/repositories/coach_repository.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await NotificationService.initialize();
  
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Start listening to Pedometer continuously
  final box = await Hive.openBox('settings');
  
  final initToday = DateTime.now();
  final initDateStr = '${initToday.year}-${initToday.month}-${initToday.day}';
  int currentSteps = box.get('recentSteps_$initDateStr', defaultValue: 0); // Track for UI updates

  service.on('updateSettings').listen((event) async {
    if (event != null) {
      if (event['notifHour'] != null) await box.put('notifHour', event['notifHour']);
      if (event['notifMinute'] != null) await box.put('notifMinute', event['notifMinute']);
      if (event['stepTarget'] != null) {
        await box.put('stepTarget', event['stepTarget']);
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "FitCoach Active ⚡",
            content: "$currentSteps / ${event['stepTarget']} steps today",
          );
        }
      }
    }
  });
  
  Pedometer.stepCountStream.listen((StepCount event) async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';
    final savedDate = box.get('stepDate', defaultValue: '');
    final sensorSteps = event.steps;
    
    if (savedDate != dateStr) {
      await box.put('stepDate', dateStr);
      await box.put('baselineSteps', sensorSteps);
      await box.put('stepNotified', false);
    }
    
    final int baselineSteps = box.get('baselineSteps', defaultValue: sensorSteps);
    final bool stepNotified = box.get('stepNotified', defaultValue: false);
    final int stepTargetStr = box.get('stepTarget', defaultValue: 10000);
    
    int stepsToday = sensorSteps - baselineSteps;
    if (stepsToday < 0) {
      await box.put('baselineSteps', 0);
      stepsToday = sensorSteps;
    }
    
    currentSteps = stepsToday;
    await box.put('recentSteps_$dateStr', stepsToday);

    // Update the notification UI
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "FitCoach Active ⚡",
        content: "$stepsToday / $stepTargetStr steps today",
      );
    }

    // Milestone Notification
    if (stepsToday >= stepTargetStr && !stepNotified) {
      await box.put('stepNotified', true);
      
      final ns = NotificationService();
      await ns.showImmediateNotification(
        title: 'Goal Achieved! 🔥', 
        body: 'You just hit your target of $stepTargetStr steps today. Great job!',
      );
    }
    
    service.invoke('update', {
      "steps": stepsToday,
    });
  }, onError: (err) {
    print("Pedometer stream error: $err");
  });

  // Start 1-minute check for AI Personalized Daily Reminders
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    final now = DateTime.now();
    final notifHour = box.get('notifHour', defaultValue: 9);
    final notifMinute = box.get('notifMinute', defaultValue: 0);
    final lastNotifDate = box.get('lastAINotifDate', defaultValue: '');
    final dateStr = '${now.year}-${now.month}-${now.day}';

    final scheduledTime = DateTime(now.year, now.month, now.day, notifHour, notifMinute);

    if ((now.isAfter(scheduledTime) || now.isAtSameMomentAs(scheduledTime)) && lastNotifDate != dateStr) {
      await box.put('lastAINotifDate', dateStr);
      
      try {
        // Fetch personalized AI insight
        final repo = const CoachRepository();
        final scoreData = await repo.getImprovementScore();
        
        final title = 'FitCoach AI ⚡';
        final body = scoreData.alerts.isNotEmpty 
            ? scoreData.alerts.first.message 
            : "Your daily plan is ready! Let's crush today's goals.";
            
        final ns = NotificationService();
        await ns.showImmediateNotification(title: title, body: body);
      } catch (e) {
        // Fallback generic reminder if offline
        final ns = NotificationService();
        await ns.showImmediateNotification(
          title: 'FitCoach Reminder', 
          body: "Time for your daily check-in! Let's stay active today."
        );
      }
    }
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Ensure notification channel exists
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fitcoach_foreground',
      'Live Pedometer',
      description: 'Persistent step counting service',
      importance: Importance.low, 
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'fitcoach_foreground',
        initialNotificationTitle: 'FitCoach Active ⚡',
        initialNotificationContent: 'Tracking your steps...',
        foregroundServiceNotificationId: 888,
        // Require health permissions string for modern android
        foregroundServiceTypes: [AndroidForegroundType.health],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  static void registerPeriodicStepSync() {
    // Deprecated for Workmanager, now we just run the BackgroundService
    FlutterBackgroundService().startService();
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
