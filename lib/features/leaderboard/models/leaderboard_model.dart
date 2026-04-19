class LeaderboardEntry {
  final int    rank;
  final String userId;
  final String name;
  final String avatar;
  final String level;
  final int    verifiedXP;
  final int    consistencyScore;
  final int    improvementScore;
  final int    totalScore;
  final int    workoutsCompleted;
  final int    totalCalories;
  final int    totalMinutes;
  final int    avgQualityScore;
  final int    streak;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.avatar,
    required this.level,
    required this.verifiedXP,
    required this.consistencyScore,
    required this.improvementScore,
    required this.totalScore,
    required this.workoutsCompleted,
    required this.totalCalories,
    required this.totalMinutes,
    required this.avgQualityScore,
    required this.streak,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank:             (json['rank']             as num?)?.toInt() ?? 0,
        userId:           json['user']?.toString()  ?? '',
        name:              json['name']             as String? ?? 'Unknown',
        avatar:            json['avatar']           as String? ?? '',
        level:             json['level']            as String? ?? 'beginner',
        verifiedXP:       (json['verifiedXP']       as num?)?.toInt() ?? 0,
        consistencyScore: (json['consistencyScore'] as num?)?.toInt() ?? 0,
        improvementScore: (json['improvementScore'] as num?)?.toInt() ?? 0,
        totalScore:       (json['totalScore']       as num?)?.toInt() ?? 0,
        workoutsCompleted:(json['workoutsCompleted'] as num?)?.toInt() ?? 0,
        totalCalories:    (json['totalCalories']    as num?)?.toInt() ?? 0,
        totalMinutes:     (json['totalMinutes']     as num?)?.toInt() ?? 0,
        avgQualityScore:  (json['avgQualityScore']  as num?)?.toInt() ?? 0,
        streak:           (json['streak']           as num?)?.toInt() ?? 0,
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class MyPeriodRank {
  final String             period;
  final int?               rank;
  final int                totalUsers;
  final LeaderboardEntry?  entry;

  const MyPeriodRank({
    required this.period,
    this.rank,
    required this.totalUsers,
    this.entry,
  });

  factory MyPeriodRank.fromJson(Map<String, dynamic> json) => MyPeriodRank(
    period:     json['period']     as String? ?? '',
    rank:      (json['rank']       as num?)?.toInt(),
    totalUsers:(json['totalUsers'] as num?)?.toInt() ?? 0,
    entry:      json['entry'] != null
        ? LeaderboardEntry.fromJson(json['entry'] as Map<String, dynamic>)
        : null,
  );
}

class LeaderboardData {
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry?      myRank;
  final String                 period;
  final String                 periodKey;
  final DateTime?              builtAt;
  final int                    total;
  final int                    totalPages;
  final int                    currentPage;

  const LeaderboardData({
    required this.entries,
    this.myRank,
    required this.period,
    required this.periodKey,
    this.builtAt,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    final data       = json['data'] as Map<String, dynamic>? ?? {};
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
    final entriesRaw = data['entries'] as List<dynamic>? ?? [];

    return LeaderboardData(
      entries:     entriesRaw
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      myRank:      data['myRank'] != null
          ? LeaderboardEntry.fromJson(
              data['myRank'] as Map<String, dynamic>)
          : null,
      period:      data['period']    as String? ?? '',
      periodKey:   data['periodKey'] as String? ?? '',
      builtAt:     data['builtAt'] != null
          ? DateTime.tryParse(data['builtAt'] as String)
          : null,
      total:      (pagination['total']      as num?)?.toInt() ?? 0,
      totalPages: (pagination['totalPages'] as num?)?.toInt() ?? 1,
      currentPage:(pagination['page']       as num?)?.toInt() ?? 1,
    );
  }
}