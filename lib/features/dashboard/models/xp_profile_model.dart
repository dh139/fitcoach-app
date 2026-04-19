class XpProgressModel {
  final Map<String, dynamic> current;
  final Map<String, dynamic>? next;
  final int progressPct;
  final int xpToNext;

  const XpProgressModel({
    required this.current,
    this.next,
    required this.progressPct,
    required this.xpToNext,
  });

  factory XpProgressModel.fromJson(Map<String, dynamic> json) =>
      XpProgressModel(
        current:     json['current']     as Map<String, dynamic>? ?? {},
        next:        json['next']        as Map<String, dynamic>?,
        progressPct:(json['progressPct'] as num?)?.toInt()  ?? 0,
        xpToNext:   (json['xpToNext']   as num?)?.toInt()  ?? 0,
      );

  String get currentLevelName => current['name'] as String? ?? 'beginner';
  String get nextLevelName    => next?['name']   as String? ?? '';
}

class XpProfileModel {
  final int            xp;
  final String         level;
  final int            streak;
  final int            streakFreezes;
  final int            totalWorkouts;
  final XpProgressModel progress;
  final int?           daysInactive;
  final int?           nextStreakMilestone;
  final Map<String, dynamic>? nextStreakMilestoneXP;
  final bool           decayWarning;

  const XpProfileModel({
    required this.xp,
    required this.level,
    required this.streak,
    required this.streakFreezes,
    required this.totalWorkouts,
    required this.progress,
    this.daysInactive,
    this.nextStreakMilestone,
    this.nextStreakMilestoneXP,
    required this.decayWarning,
  });

  factory XpProfileModel.fromJson(Map<String, dynamic> json) =>
      XpProfileModel(
        xp:            (json['xp']            as num?)?.toInt() ?? 0,
        level:         (json['level']         as String?)       ?? 'beginner',
        streak:        (json['streak']        as num?)?.toInt() ?? 0,
        streakFreezes: (json['streakFreezes'] as num?)?.toInt() ?? 0,
        totalWorkouts: (json['totalWorkouts'] as num?)?.toInt() ?? 0,
        progress:      XpProgressModel.fromJson(
                         json['progress'] as Map<String, dynamic>? ?? {}),
        daysInactive:  (json['daysInactive'] as num?)?.toInt(),
        nextStreakMilestone:
                       (json['nextStreakMilestone'] as num?)?.toInt(),
        nextStreakMilestoneXP:
                       json['nextStreakMilestoneXP'] as Map<String, dynamic>?,
        decayWarning:  (json['decayWarning']  as bool?) ?? false,
      );

  /// Returns which of the last 7 days had a workout.
  /// Index 0 = 6 days ago, index 6 = today.
  /// Derived from streak count ending today.
  List<bool> get last7DaysActive {
    final active = streak > 7 ? 7 : streak;
    return List.generate(7, (i) => i >= (7 - active));
  }
}