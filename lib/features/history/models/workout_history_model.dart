class WorkoutExerciseLog {
  final String exerciseName;
  final int    setsCompleted;
  final int    repsCompleted;
  final int    durationSeconds;

  const WorkoutExerciseLog({
    required this.exerciseName,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.durationSeconds,
  });

  factory WorkoutExerciseLog.fromJson(Map<String, dynamic> json) =>
      WorkoutExerciseLog(
        exerciseName:    json['exerciseName']    as String? ?? '',
        setsCompleted:  (json['setsCompleted']   as num?)?.toInt() ?? 0,
        repsCompleted:  (json['repsCompleted']   as num?)?.toInt() ?? 0,
        durationSeconds:(json['durationSeconds'] as num?)?.toInt() ?? 0,
      );
}

class WorkoutHistoryModel {
  final String                   id;
  final String                   workoutName;
  final int                      durationSeconds;
  final int                      totalCaloriesBurned;
  final int                      xpEarned;
  final bool                     isVerified;
  final int                      qualityScore;
  final List<WorkoutExerciseLog> exercises;
  final String                   completedAt;

  const WorkoutHistoryModel({
    required this.id,
    required this.workoutName,
    required this.durationSeconds,
    required this.totalCaloriesBurned,
    required this.xpEarned,
    required this.isVerified,
    required this.qualityScore,
    required this.exercises,
    required this.completedAt,
  });

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) =>
      WorkoutHistoryModel(
        id:                  json['_id']                  as String? ?? '',
        workoutName:         json['workoutName']          as String? ?? 'Workout',
        durationSeconds:    (json['durationSeconds']      as num?)?.toInt() ?? 0,
        totalCaloriesBurned:(json['totalCaloriesBurned']  as num?)?.toInt() ?? 0,
        xpEarned:           (json['xpEarned']             as num?)?.toInt() ?? 0,
        isVerified:         (json['isVerified']           as bool?) ?? false,
        qualityScore:       (json['qualityScore']         as num?)?.toInt() ?? 0,
        completedAt:         json['endTime']?.toString() ?? json['updatedAt']?.toString() ?? json['createdAt']?.toString() ?? '',
        exercises: ((json['exerciseLogs'] as List<dynamic>?) ?? [])
            .map((e) => WorkoutExerciseLog.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds  % 60;
    if (m >= 60) return '${m ~/ 60}h ${m % 60}m';
    return s > 0 ? '${m}m ${s}s' : '${m}m';
  }

  DateTime? get completedDateTime =>
      DateTime.tryParse(completedAt);

  String get relativeDate {
    final dt = completedDateTime;
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
    return '${diff.inDays ~/ 30} months ago';
  }
}

// For chart data
class ChartDataPoint {
  final String label;
  final double value;
  final DateTime date;

  const ChartDataPoint({
    required this.label,
    required this.value,
    required this.date,
  });
}