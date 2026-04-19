class ExerciseLogEntry {
  final String       exerciseId;
  final String       exerciseName;
  final String       gifUrl;
  final String       target;
  final String       equipment;
  int                setsCompleted;
  int                repsCompleted;
  int                durationSeconds;
  final List<int>    clickTimestamps; // unix ms — anti-cheat
  DateTime?          completedAt;

  ExerciseLogEntry({
    required this.exerciseId,
    required this.exerciseName,
    required this.gifUrl,
    required this.target,
    required this.equipment,
    this.setsCompleted   = 0,
    this.repsCompleted   = 10,
    this.durationSeconds = 0,
    List<int>? clickTimestamps,
    this.completedAt,
  }) : clickTimestamps = clickTimestamps ?? [];

  bool get hasWork => setsCompleted > 0 || durationSeconds > 0;

  Map<String, dynamic> toJson() => {
    'exercise':        exerciseId,
    'exerciseName':    exerciseName,
    'setsCompleted':   setsCompleted,
    'repsCompleted':   repsCompleted,
    'durationSeconds': durationSeconds,
    'clickTimestamps': clickTimestamps,
    'completedAt':     completedAt?.toIso8601String(),
  };

  ExerciseLogEntry copyWith({
    int?      setsCompleted,
    int?      repsCompleted,
    int?      durationSeconds,
    List<int>? clickTimestamps,
    DateTime?  completedAt,
  }) => ExerciseLogEntry(
    exerciseId:      exerciseId,
    exerciseName:    exerciseName,
    gifUrl:          gifUrl,
    target:          target,
    equipment:       equipment,
    setsCompleted:   setsCompleted   ?? this.setsCompleted,
    repsCompleted:   repsCompleted   ?? this.repsCompleted,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    clickTimestamps: clickTimestamps ?? List<int>.from(this.clickTimestamps),
    completedAt:     completedAt     ?? this.completedAt,
  );
}