class ChallengeModel {
  final String   id;
  final String   title;
  final String   description;
  final String   type;       // daily | weekly
  final String   category;   // workout | calories | streak | xp
  final int      target;
  final int      current;
  final int      xpReward;
  final bool     completed;
  final bool     claimed;
  final String?  expiresAt;
  final String   createdAt;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.target,
    required this.current,
    required this.xpReward,
    required this.completed,
    required this.claimed,
    this.expiresAt,
    required this.createdAt,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) =>
      ChallengeModel(
        id:          json['_id']         as String? ?? '',
        title:       json['title']       as String? ?? '',
        description: json['description'] as String? ?? '',
        type:        json['type']        as String? ?? 'daily',
        category:    json['category']    as String? ?? 'workout',
        target:     (json['target']      as num?)?.toInt() ?? 1,
        current:    (json['current']     as num?)?.toInt() ?? 0,
        xpReward:   (json['xpReward']    as num?)?.toInt() ?? 50,
        completed:  (json['completed']   as bool?) ?? false,
        claimed:    (json['claimed']     as bool?) ?? false,
        expiresAt:   json['expiresAt']   as String?,
        createdAt:  (json['createdAt']   as String?) ?? '',
      );

  double get progressPct =>
      target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  bool get canClaim => completed && !claimed;

  String get timeRemaining {
    if (expiresAt == null) return '';
    final exp  = DateTime.tryParse(expiresAt!);
    if (exp == null) return '';
    final diff = exp.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours < 1) return '${diff.inMinutes}m left';
    if (diff.inHours < 24) return '${diff.inHours}h left';
    return '${diff.inDays}d left';
  }
}