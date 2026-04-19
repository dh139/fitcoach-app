class ReportContent {
  final String       summary;
  final List<String> highlights;
  final List<String> improvements;
  final List<String> nextSteps;
  final String       motivationMessage;
  final String       plateauWarning;
  final String       dietFeedback;
  final String       workoutFeedback;
  final int          consistencyScore;
  final int          overallScore;

  const ReportContent({
    required this.summary,
    required this.highlights,
    required this.improvements,
    required this.nextSteps,
    required this.motivationMessage,
    required this.plateauWarning,
    required this.dietFeedback,
    required this.workoutFeedback,
    required this.consistencyScore,
    required this.overallScore,
  });

  factory ReportContent.fromJson(Map<String, dynamic> json) => ReportContent(
    summary:           json['summary']           as String? ?? '',
    motivationMessage: json['motivationMessage'] as String? ?? '',
    plateauWarning:    json['plateauWarning']    as String? ?? '',
    dietFeedback:      json['dietFeedback']      as String? ?? '',
    workoutFeedback:   json['workoutFeedback']   as String? ?? '',
    consistencyScore: (json['consistencyScore']  as num?)?.toInt() ?? 0,
    overallScore:     (json['overallScore']      as num?)?.toInt() ?? 0,
    highlights:  ((json['highlights']  as List<dynamic>?) ?? [])
        .map((e) => e as String).toList(),
    improvements:((json['improvements'] as List<dynamic>?) ?? [])
        .map((e) => e as String).toList(),
    nextSteps:   ((json['nextSteps']    as List<dynamic>?) ?? [])
        .map((e) => e as String).toList(),
  );
}

class ReportContextStats {
  final int workouts;
  final int totalMinutes;
  final int totalCaloriesBurned;
  final int xpEarned;

  const ReportContextStats({
    required this.workouts,
    required this.totalMinutes,
    required this.totalCaloriesBurned,
    required this.xpEarned,
  });

  factory ReportContextStats.fromJson(Map<String, dynamic> json) {
    final workouts = json['workouts'] as Map<String, dynamic>? ?? {};
    final xp       = json['xp']      as Map<String, dynamic>? ?? {};
    return ReportContextStats(
      workouts:            (workouts['total']            as num?)?.toInt() ?? 0,
      totalMinutes:        (workouts['totalMinutes']     as num?)?.toInt() ?? 0,
      totalCaloriesBurned: (workouts['totalCaloriesBurned'] as num?)?.toInt() ?? 0,
      xpEarned:           (xp['earned']                 as num?)?.toInt() ?? 0,
    );
  }
}

class ReportModel {
  final String              id;
  final String              type;
  final String              periodKey;
  final ReportContent       report;
  final ReportContextStats? context;
  final DateTime            generatedAt;
  final bool                cached;

  const ReportModel({
    required this.id,
    required this.type,
    required this.periodKey,
    required this.report,
    this.context,
    required this.generatedAt,
    required this.cached,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json, {bool cached = false}) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return ReportModel(
      id:          data['_id']       as String? ?? '',
      type:        data['type']      as String? ?? '',
      periodKey:   data['periodKey'] as String? ?? '',
      report: ReportContent.fromJson(
          data['report'] as Map<String, dynamic>? ?? {}),
      context: data['context'] != null
          ? ReportContextStats.fromJson(
              data['context'] as Map<String, dynamic>)
          : null,
      generatedAt: DateTime.tryParse(
          data['generatedAt'] as String? ?? '') ?? DateTime.now(),
      cached: cached,
    );
  }
}