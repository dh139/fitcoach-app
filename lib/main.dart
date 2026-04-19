import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/services/notification_service.dart';   // Make sure path is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  await Hive.initFlutter();

  // Initialize Notifications
  await NotificationService.initialize();        // ← Static call
  final notificationService = NotificationService();
  await notificationService.requestPermission(); // ← Instance call
  await notificationService.autoScheduleDefaultIfNeeded(); // ← Schedule generic time if none set

  runApp(const ProviderScope(child: FitCoachApp()));
}