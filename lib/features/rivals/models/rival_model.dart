class RivalUserStats {
  final int    xp;
  final int    streak;
  final String level;
  final int    totalWorkouts;
  final int    weeklyWorkouts;
  final int    avgQualityScore;

  const RivalUserStats({
    required this.xp,
    required this.streak,
    required this.level,
    required this.totalWorkouts,
    required this.weeklyWorkouts,
    required this.avgQualityScore,
  });

  factory RivalUserStats.fromJson(Map<String, dynamic> json) =>
      RivalUserStats(
        xp:             (json['xp']             as num?)?.toInt() ?? 0,
        streak:         (json['streak']         as num?)?.toInt() ?? 0,
        level:          (json['level']          as String?) ?? 'beginner',
        totalWorkouts:  (json['totalWorkouts']  as num?)?.toInt() ?? 0,
        weeklyWorkouts: (json['weeklyWorkouts'] as num?)?.toInt() ?? 0,
        avgQualityScore:(json['avgQualityScore'] as num?)?.toInt() ?? 0,
      );
}

class RivalUser {
  final String       id;
  final String       name;
  final RivalUserStats stats;

  const RivalUser({
    required this.id,
    required this.name,
    required this.stats,
  });

  factory RivalUser.fromJson(Map<String, dynamic> json) {
    final user  = json['user']  as Map<String, dynamic>? ?? json;
    final stats = json['stats'] as Map<String, dynamic>?
                  ?? json['userStats'] as Map<String, dynamic>? ?? {};
    return RivalUser(
      id:    (user['_id'] ?? user['id']) as String? ?? '',
      name:   user['name']               as String? ?? 'Unknown',
      stats:  RivalUserStats.fromJson(stats),
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class RivalModel {
  final String     id;
  final RivalUser  challenger;
  final RivalUser  challenged;
  final String     status;  // pending | active | completed | declined
  final String     metric;  // xp | workouts | calories | streak
  final int        duration;
  final String?    winner;
  final String     createdAt;
  final String?    endsAt;

  const RivalModel({
    required this.id,
    required this.challenger,
    required this.challenged,
    required this.status,
    required this.metric,
    required this.duration,
    this.winner,
    required this.createdAt,
    this.endsAt,
  });

  factory RivalModel.fromJson(Map<String, dynamic> json) => RivalModel(
    id:          json['_id']       as String? ?? '',
    status:     (json['status']    as String?) ?? 'pending',
    metric:     (json['metric']    as String?) ?? 'xp',
    duration:   (json['duration']  as num?)?.toInt() ?? 7,
    winner:      json['winner']    as String?,
    createdAt:  (json['createdAt'] as String?) ?? '',
    endsAt:      json['endsAt']    as String?,
    challenger: RivalUser.fromJson(
        json['challenger'] as Map<String, dynamic>? ?? {}),
    challenged: RivalUser.fromJson(
        json['challenged'] as Map<String, dynamic>? ?? {}),
  );

  bool get isPending   => status == 'pending';
  bool get isActive    => status == 'active';
  bool get isCompleted => status == 'completed';

  String get metricLabel => switch (metric) {
    'workouts' => 'Most workouts',
    'calories' => 'Most calories burned',
    'streak'   => 'Longest streak',
    _          => 'Most XP earned',
  };

  String get timeLeft {
    if (endsAt == null) return '';
    final end  = DateTime.tryParse(endsAt!);
    if (end == null) return '';
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    return '${diff.inHours}h left';
  }
}

class RivalSuggestion {
  final String id;
  final String name;
  final String level;
  final int    xp;
  final int    weeklyWorkouts;
  final String reason;

  const RivalSuggestion({
    required this.id,
    required this.name,
    required this.level,
    required this.xp,
    required this.weeklyWorkouts,
    required this.reason,
  });

  factory RivalSuggestion.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return RivalSuggestion(
      id:            (user['_id'] ?? user['id']) as String? ?? '',
      name:           user['name']               as String? ?? 'Unknown',
      level:         (user['level']              as String?) ?? 'beginner',
      xp:            (user['xp']                 as num?)?.toInt() ?? 0,
      weeklyWorkouts:(json['weeklyWorkouts']      as num?)?.toInt() ?? 0,
      reason:        (json['reason']             as String?) ?? 'Similar level',
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}