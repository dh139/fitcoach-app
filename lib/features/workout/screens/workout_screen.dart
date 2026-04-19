import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_provider.dart';
import 'widgets/workout_setup.dart';
import 'widgets/workout_session.dart';
import 'widgets/workout_summary.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = ref.watch(workoutProvider.select((s) => s.stage));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve:  Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child:   child,
      ),
      child: switch (stage) {
        WorkoutStage.setup      => const WorkoutSetup(key: ValueKey('setup')),
        WorkoutStage.session    => const WorkoutSession(key: ValueKey('session')),
        WorkoutStage.completing => const WorkoutSession(key: ValueKey('completing')),
        WorkoutStage.summary    => const WorkoutSummary(key: ValueKey('summary')),
      },
    );
  }
}