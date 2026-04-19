class WorkoutStatsModel {
  final int totalWorkouts;
  final int totalCaloriesBurned;
  final int totalMinutesWorked;
  final int currentStreak;
  final int xp;
  final String level;
  final int weeklyWorkouts;
  final int monthlyCalories;

  const WorkoutStatsModel({
    required this.totalWorkouts,
    required this.totalCaloriesBurned,
    required this.totalMinutesWorked,
    required this.currentStreak,
    required this.xp,
    required this.level,
    required this.weeklyWorkouts,
    required this.monthlyCalories,
  });

  factory WorkoutStatsModel.fromJson(Map<String, dynamic> json) =>
      WorkoutStatsModel(
        totalWorkouts:       (json['totalWorkouts']       as num?)?.toInt() ?? 0,
        totalCaloriesBurned: (json['totalCaloriesBurned'] as num?)?.toInt() ?? 0,
        totalMinutesWorked:  (json['totalMinutesWorked']  as num?)?.toInt() ?? 0,
        currentStreak:       (json['currentStreak']       as num?)?.toInt() ?? 0,
        xp:                  (json['xp']                  as num?)?.toInt() ?? 0,
        level:               (json['level']               as String?)       ?? 'beginner',
        weeklyWorkouts:      (json['weeklyWorkouts']       as num?)?.toInt() ?? 0,
        monthlyCalories:     (json['monthlyCalories']      as num?)?.toInt() ?? 0,
      );
} 