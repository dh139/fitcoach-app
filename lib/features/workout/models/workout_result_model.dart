class VerificationDetails {
  final bool durationValid;
  final bool exerciseCountValid;
  final bool clickSpacingValid;
  final int  qualityScore;

  const VerificationDetails({
    required this.durationValid,
    required this.exerciseCountValid,
    required this.clickSpacingValid,
    required this.qualityScore,
  });

  factory VerificationDetails.fromJson(Map<String, dynamic> json) =>
      VerificationDetails(
        durationValid:      (json['durationValid']      as bool?) ?? false,
        exerciseCountValid: (json['exerciseCountValid'] as bool?) ?? false,
        clickSpacingValid:  (json['clickSpacingValid']  as bool?) ?? false,
        qualityScore:      (json['qualityScore']        as num?)?.toInt() ?? 0,
      );
}

class WorkoutResultModel {
  final bool               isVerified;
  final int                qualityScore;
  final String             reason;
  final VerificationDetails details;
  final int                xpEarned;
  final int                totalCaloriesBurned;
  final int                durationSeconds;
  final bool               didLevelUp;
  final String?            previousLevel;
  final String?            newLevel;
  final String             workoutId;
  final String             workoutName;

  const WorkoutResultModel({
    required this.isVerified,
    required this.qualityScore,
    required this.reason,
    required this.details,
    required this.xpEarned,
    required this.totalCaloriesBurned,
    required this.durationSeconds,
    required this.didLevelUp,
    this.previousLevel,
    this.newLevel,
    required this.workoutId,
    required this.workoutName,
  });

  factory WorkoutResultModel.fromJson(Map<String, dynamic> json) {
    final data       = json['data']       as Map<String, dynamic>? ?? {};
    final validation = data['validation'] as Map<String, dynamic>? ?? {};
    final workout    = data['workout']    as Map<String, dynamic>? ?? {};

    return WorkoutResultModel(
      isVerified:          (validation['isVerified']    as bool?)  ?? false,
      qualityScore:       (validation['qualityScore']   as num?)?.toInt() ?? 0,
      reason:              validation['reason']         as String? ?? '',
      details: VerificationDetails.fromJson(
          validation['details'] as Map<String, dynamic>? ?? {}),
      xpEarned:           (data['xpEarned']             as num?)?.toInt() ?? 0,
      totalCaloriesBurned:(data['totalCaloriesBurned']   as num?)?.toInt() ?? 0,
      durationSeconds:    (workout['durationSeconds']    as num?)?.toInt() ?? 0,
      didLevelUp:          (data['didLevelUp']           as bool?) ?? false,
      previousLevel:       data['previousLevel']         as String?,
      newLevel:            data['newLevel']              as String?,
      workoutId:           workout['_id']                as String? ?? '',
      workoutName:         workout['workoutName']        as String? ?? 'Workout',
    );
  }
}