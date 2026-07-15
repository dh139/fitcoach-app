import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/background_service.dart';

class StepState {
  final int stepsToday;
  final int targetSteps;
  final bool permissionsGranted;
  final bool notified;
  const StepState({
    this.stepsToday = 0, 
    this.targetSteps = 10000,
    this.permissionsGranted = false, 
    this.notified = false,
  });
}

class StepNotifier extends StateNotifier<StepState> {
  StepNotifier() : super(const StepState()) {
    init();
  }

  Future<void> init() async {
    final box = await Hive.openBox('settings');
    final int target = box.get('stepTarget', defaultValue: 10000);
    
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';
    final int savedSteps = box.get('recentSteps_$dateStr', defaultValue: 0);

    state = StepState(
      stepsToday: savedSteps, 
      targetSteps: target,
      permissionsGranted: state.permissionsGranted, 
      notified: state.notified,
    );

    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      state = StepState(
        stepsToday: state.stepsToday, 
        targetSteps: target,
        permissionsGranted: true, 
        notified: state.notified,
      );
      Pedometer.stepCountStream.listen(_onStepCount).onError(_onStepCountError);

      final service = FlutterBackgroundService();
      if (!await service.isRunning()) {
        await BackgroundService.initialize();
        service.startService();
      }

      service.on('update').listen((event) {
        if (event != null && event['steps'] != null) {
          final steps = event['steps'] as int;
          state = StepState(
            stepsToday: steps,
            targetSteps: state.targetSteps,
            permissionsGranted: true,
            notified: state.notified,
          );
        }
      });
    }
  }

  Future<void> setTarget(int newTarget) async {
    final box = await Hive.openBox('settings');
    await box.put('stepTarget', newTarget);
    
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('updateSettings', {'stepTarget': newTarget});
    }

    state = StepState(
      stepsToday: state.stepsToday,
      targetSteps: newTarget,
      permissionsGranted: state.permissionsGranted,
      notified: state.notified,
    );
  }

  void _onStepCount(StepCount event) async {
    final box = await Hive.openBox('settings');
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';
    final savedDate = box.get('stepDate', defaultValue: '');
    
    // Total steps from sensor since last reset
    final int sensorSteps = event.steps;

    if (savedDate != dateStr) {
      // It's a new day, save this as the baseline.
      await box.put('stepDate', dateStr);
      await box.put('baselineSteps', sensorSteps);
      await box.put('stepNotified', false);
    }

    final int baselineSteps = box.get('baselineSteps', defaultValue: sensorSteps);
    final bool stepNotified = box.get('stepNotified', defaultValue: false);
    
    int stepsToday = sensorSteps - baselineSteps;
    if (stepsToday < 0) {
      // Device rebooted, sensor steps reset.
      await box.put('baselineSteps', 0); // baseline is now 0
      stepsToday = sensorSteps;
    }

    // Save current calculated steps for quick UI loaded
    await box.put('recentSteps_$dateStr', stepsToday);

    state = StepState(
      stepsToday: stepsToday, 
      targetSteps: state.targetSteps,
      permissionsGranted: true,
      notified: stepNotified,
    );

    // Notify at big milestones
    if (stepsToday >= state.targetSteps && !stepNotified) {
      await box.put('stepNotified', true);
      state = StepState(stepsToday: stepsToday, targetSteps: state.targetSteps, permissionsGranted: true, notified: true);
      
      final ns = NotificationService();
      // Milestone notification
      ns.showImmediateNotification(
        title: 'Step Goal Crushed! 🔥', 
        body: 'You just hit ${state.targetSteps} steps today. Incredible work tracking your progress!',
      );
    }
  }

  void _onStepCountError(error) {
    print("Step Error: $error");
  }

  Future<List<int>> getWeeklySteps() async {
    final box = await Hive.openBox('settings');
    final today = DateTime.now();
    List<int> weekly = [];
    
    // We want past 6 days + today (7 total)
    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final dateStr = '${d.year}-${d.month}-${d.day}';
      
      if (i == 0) {
        // Today is live in state (or local storage if not initialized yet)
        weekly.add(state.stepsToday);
      } else {
        int historic = box.get('recentSteps_$dateStr', defaultValue: 0);
        weekly.add(historic);
      }
    }
    return weekly;
  }
}

final stepProvider = StateNotifierProvider<StepNotifier, StepState>((ref) => StepNotifier());
