import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_service.dart';

import 'package:permission_handler/permission_handler.dart';
import 'core/storage/secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  await Hive.initFlutter();

  // Initialize Notifications
  await NotificationService.initialize();        // ← Static call
  final notificationService = NotificationService();
  await notificationService.requestPermission(); // ← Instance call
  await notificationService.autoScheduleDefaultIfNeeded(); // ← Schedule generic time if none set

  final token = await SecureStorage.getToken();
  final hasPermission = await Permission.activityRecognition.isGranted;
  if (token != null && hasPermission) {
    await BackgroundService.initialize();
    BackgroundService.registerPeriodicStepSync();
  }

  runApp(const ProviderScope(child: FitCoachApp()));
}