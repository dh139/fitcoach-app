import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/services/notification_service.dart';

class StepState {
  final int stepsToday;
  final bool permissionsGranted;
  final bool notified;
  const StepState({this.stepsToday = 0, this.permissionsGranted = false, this.notified = false});
}

class StepNotifier extends StateNotifier<StepState> {
  StepNotifier() : super(const StepState()) {
    init();
  }

  Future<void> init() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      state = StepState(stepsToday: state.stepsToday, permissionsGranted: true, notified: state.notified);
      Pedometer.stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    }
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

    state = StepState(
      stepsToday: stepsToday, 
      permissionsGranted: true,
      notified: stepNotified,
    );

    // Notify at big milestones (e.g., 10k steps)
    if (stepsToday >= 10000 && !stepNotified) {
      await box.put('stepNotified', true);
      state = StepState(stepsToday: stepsToday, permissionsGranted: true, notified: true);
      
      final ns = NotificationService();
      // Milestone notification
      ns.showImmediateNotification(
        title: 'Step Goal Crushed! 🔥', 
        body: 'You just hit 10,000 steps today. Incredible work tracking your progress!',
      );
    }
  }

  void _onStepCountError(error) {
    print("Step Error: $error");
  }
}

final stepProvider = StateNotifierProvider<StepNotifier, StepState>((ref) => StepNotifier());
