import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../exercises/models/exercise_model.dart';
import '../models/workout_session_model.dart';
import '../models/workout_result_model.dart';
import '../repositories/workout_repository.dart';
final workoutRepositoryProvider =
    Provider<WorkoutRepository>((_) => const WorkoutRepository());

// ── Workout stage ──────────────────────────────────────────────────────────────
enum WorkoutStage { session, completing, summary }

// ── State ──────────────────────────────────────────────────────────────────────
class WorkoutState {
  final WorkoutStage            stage;
  final String                  workoutName;
  final List<ExerciseModel>     selectedExercises;
  final List<ExerciseLogEntry>  logs;
  final String?                 workoutId;
  final int                     elapsedSeconds;
  final bool                    timerRunning;
  final WorkoutResultModel?     result;
  final String?                 error;

  const WorkoutState({
    this.stage             = WorkoutStage.session,
    this.workoutName       = 'My Workout',
    this.selectedExercises = const [],
    this.logs              = const [],
    this.workoutId,
    this.elapsedSeconds    = 0,
    this.timerRunning      = false,
    this.result,
    this.error,
  });

  // Anti-cheat: minimum 120 seconds
  static const int minSeconds = 120;

  bool get isUnlocked     => elapsedSeconds >= minSeconds;
  int  get completedCount =>
      logs.where((l) => l.hasWork).length;
  bool get canFinish      => isUnlocked && completedCount >= 1;
  int  get progressPct    => selectedExercises.isEmpty ? 0
      : ((completedCount / selectedExercises.length) * 100).round();

  WorkoutState copyWith({
    WorkoutStage?            stage,
    String?                  workoutName,
    List<ExerciseModel>?     selectedExercises,
    List<ExerciseLogEntry>?  logs,
    Object?                  workoutId = _sentinel,
    int?                     elapsedSeconds,
    bool?                    timerRunning,
    WorkoutResultModel?      result,
    Object?                  error    = _sentinel,
  }) => WorkoutState(
    stage:             stage             ?? this.stage,
    workoutName:       workoutName       ?? this.workoutName,
    selectedExercises: selectedExercises ?? this.selectedExercises,
    logs:              logs              ?? this.logs,
    workoutId:         workoutId == _sentinel
        ? this.workoutId : workoutId as String?,
    elapsedSeconds:    elapsedSeconds    ?? this.elapsedSeconds,
    timerRunning:      timerRunning      ?? this.timerRunning,
    result:            result            ?? this.result,
    error:             error == _sentinel
        ? this.error : error as String?,
  );
}

const _sentinel = Object();

// ── Notifier ───────────────────────────────────────────────────────────────────
class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final WorkoutRepository _repo;
  Timer? _timer;

  WorkoutNotifier(this._repo) : super(const WorkoutState());

  // ── Setup phase ──────────────────────────────────────────────────────────────
  void setWorkoutName(String name) =>
      state = state.copyWith(workoutName: name);

  void toggleExercise(ExerciseModel exercise) {
    final current = List<ExerciseModel>.from(state.selectedExercises);
    final idx     = current.indexWhere((e) => e.id == exercise.id);
    if (idx >= 0) {
      current.removeAt(idx);
    } else {
      current.add(exercise);
    }
    state = state.copyWith(selectedExercises: current);
  }

  bool isSelected(String exerciseId) =>
      state.selectedExercises.any((e) => e.id == exerciseId);

  Future<void> startCustomSession(List<ExerciseModel> exercises, String name) async {
    state = state.copyWith(
      selectedExercises: exercises,
      workoutName: name,
    );
    await startSession();
  }

  // ── Start session ─────────────────────────────────────────────────────────────
  Future<void> startSession() async {
    if (state.selectedExercises.isEmpty) return;

    state = state.copyWith(error: null);
    try {
      final id = await _repo.startWorkout(workoutName: state.workoutName);

      // Build initial logs
      final logs = state.selectedExercises
          .map((ex) => ExerciseLogEntry(
            exerciseId:   ex.id,
            exerciseName: ex.name,
            gifUrl:       ex.gifUrl,
            target:       ex.target,
            equipment:    ex.equipment,
          ))
          .toList();

      state = state.copyWith(
        stage:         WorkoutStage.session,
        workoutId:     id,
        logs:          logs,
        elapsedSeconds: 0,
        timerRunning:   true,
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ── Timer ─────────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void pauseTimer()  => _timer?.cancel();
  void resumeTimer() => _startTimer();

  // ── Exercise logging ──────────────────────────────────────────────────────────
  void markSetDone(String exerciseId) {
    final now  = DateTime.now().millisecondsSinceEpoch;
    final logs = List<ExerciseLogEntry>.from(state.logs);
    final idx  = logs.indexWhere((l) => l.exerciseId == exerciseId);
    if (idx < 0) return;

    final log = logs[idx];
    logs[idx] = log.copyWith(
      setsCompleted:   log.setsCompleted + 1,
      clickTimestamps: [...log.clickTimestamps, now],
      completedAt:     DateTime.now(),
    );
    state = state.copyWith(logs: logs);
  }

  void adjustReps(String exerciseId, int delta) {
    final logs = List<ExerciseLogEntry>.from(state.logs);
    final idx  = logs.indexWhere((l) => l.exerciseId == exerciseId);
    if (idx < 0) return;

    final log     = logs[idx];
    final newReps = (log.repsCompleted + delta).clamp(1, 99);
    logs[idx]     = log.copyWith(repsCompleted: newReps);
    state         = state.copyWith(logs: logs);
  }

  void logTimedSeconds(String exerciseId, int seconds) {
    final now  = DateTime.now().millisecondsSinceEpoch;
    final logs = List<ExerciseLogEntry>.from(state.logs);
    final idx  = logs.indexWhere((l) => l.exerciseId == exerciseId);
    if (idx < 0) return;

    final log = logs[idx];
    logs[idx] = log.copyWith(
      durationSeconds: log.durationSeconds + seconds,
      clickTimestamps: [...log.clickTimestamps, now],
      completedAt:     DateTime.now(),
    );
    state = state.copyWith(logs: logs);
  }

  // ── Complete session ──────────────────────────────────────────────────────────
  Future<void> completeSession() async {
    if (!state.canFinish || state.workoutId == null) return;

    _timer?.cancel();
    state = state.copyWith(stage: WorkoutStage.completing);

    try {
      final result = await _repo.completeWorkout(
        workoutId:    state.workoutId!,
        exerciseLogs: state.logs,
      );
      state = state.copyWith(
        stage:  WorkoutStage.summary,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        stage: WorkoutStage.session,
        error: e.toString(),
        timerRunning: false,
      );
    }
  }

  // ── Reset / new workout ───────────────────────────────────────────────────────
  void reset() {
    _timer?.cancel();
    state = const WorkoutState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier(ref.watch(workoutRepositoryProvider));
});