  class ScorePillar {
  final int    score;
  final double weight;
  final String detail;

  const ScorePillar({
    required this.score,
    required this.weight,
    required this.detail,
  });

  factory ScorePillar.fromJson(Map<String, dynamic> json) => ScorePillar(
    score:  (json['score']  as num?)?.toInt()    ?? 0,
    weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    detail:  json['detail'] as String?           ?? '',
  );
}

class SmartAlert {
  final String type;    // urgent | warning | positive | info
  final String message;
  final String action;

  const SmartAlert({
    required this.type,
    required this.message,
    required this.action,
  });

  factory SmartAlert.fromJson(Map<String, dynamic> json) => SmartAlert(
    type:    json['type']    as String? ?? 'info',
    message: json['message'] as String? ?? '',
    action:  json['action']  as String? ?? '',
  );
}

class ImprovementScoreMeta {
  final int  recentWorkouts;
  final int  olderWorkouts;
  final int  foodDaysLogged;
  final int  daysSinceLast;
  final int  streak;

  const ImprovementScoreMeta({
    required this.recentWorkouts,
    required this.olderWorkouts,
    required this.foodDaysLogged,
    required this.daysSinceLast,
    required this.streak,
  });

  factory ImprovementScoreMeta.fromJson(Map<String, dynamic> json) =>
      ImprovementScoreMeta(
        recentWorkouts: (json['recentWorkouts'] as num?)?.toInt() ?? 0,
        olderWorkouts:  (json['olderWorkouts']  as num?)?.toInt() ?? 0,
        foodDaysLogged: (json['foodDaysLogged'] as num?)?.toInt() ?? 0,
        daysSinceLast:  (json['daysSinceLast']  as num?)?.toInt() ?? 0,
        streak:         (json['streak']         as num?)?.toInt() ?? 0,
      );
}

class ImprovementScoreModel {
  final int                        composite;
  final Map<String, ScorePillar>   breakdown;
  final List<SmartAlert>           alerts;
  final ImprovementScoreMeta       meta;

  const ImprovementScoreModel({
    required this.composite,
    required this.breakdown,
    required this.alerts,
    required this.meta,
  });

  factory ImprovementScoreModel.fromJson(Map<String, dynamic> json) {
    final data      = json['data'] as Map<String, dynamic>? ?? json;
    final rawBreak  = data['breakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = rawBreak.map((k, v) =>
        MapEntry(k, ScorePillar.fromJson(v as Map<String, dynamic>)));
    final alertsRaw = data['alerts'] as List<dynamic>? ?? [];

    return ImprovementScoreModel(
      composite:  (data['composite'] as num?)?.toInt() ?? 0,
      breakdown:  breakdown,
      alerts:     alertsRaw
          .map((e) => SmartAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: ImprovementScoreMeta.fromJson(
          data['meta'] as Map<String, dynamic>? ?? {}),
    );
  }

  // Ordered pillar keys as they appear in the formula
  static const pillars = [
    'weightProgress',
    'consistency',
    'strengthIncrease',
    'dietAdherence',
  ];

  static const pillarLabels = {
    'weightProgress':   'Weight progress',
    'consistency':      'Consistency',
    'strengthIncrease': 'Strength quality',
    'dietAdherence':    'Diet adherence',
  };

  static const pillarWeights = {
    'weightProgress':   '30%',
    'consistency':      '30%',
    'strengthIncrease': '20%',
    'dietAdherence':    '20%',
  };
}