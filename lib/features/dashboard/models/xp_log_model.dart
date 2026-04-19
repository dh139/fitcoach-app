class XpLogModel {
  final String  id;
  final int     amount;
  final String  source;
  final int     balanceAfter;
  final String  createdAt;
  final Map<String, dynamic>? meta;

  const XpLogModel({
    required this.id,
    required this.amount,
    required this.source,
    required this.balanceAfter,
    required this.createdAt,
    this.meta,
  });

  factory XpLogModel.fromJson(Map<String, dynamic> json) => XpLogModel(
    id:           json['_id']          as String? ?? '',
    amount:      (json['amount']       as num?)?.toInt() ?? 0,
    source:       json['source']       as String? ?? 'manual',
    balanceAfter:(json['balanceAfter'] as num?)?.toInt() ?? 0,
    createdAt:    json['createdAt']    as String? ?? '',
    meta:         json['meta']         as Map<String, dynamic>?,
  );

  bool get isPositive => amount > 0;

  // Human-readable source label
  String get sourceLabel => switch (source) {
    'workout_complete' => 'Workout',
    'streak_bonus'     => 'Streak bonus',
    'comeback_bonus'   => 'Comeback bonus',
    'level_up_bonus'   => 'Level up',
    'xp_decay'         => 'XP decay',
    _                  => 'Bonus',
  };

  // Relative time
  String get timeAgo {
    final dt   = DateTime.tryParse(createdAt);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60)  return 'just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}