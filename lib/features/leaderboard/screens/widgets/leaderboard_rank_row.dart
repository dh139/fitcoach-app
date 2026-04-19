import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/level_badge.dart';
import '../../models/leaderboard_model.dart';

class LeaderboardRankRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool             isMe;

  const LeaderboardRankRow({
    super.key,
    required this.entry,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin:   const EdgeInsets.only(bottom: 8),
      padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.limeDim
            : isTop3
            ? _top3Bg(entry.rank)
            : AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? AppColors.limeBorder
              : isTop3
              ? _top3Border(entry.rank)
              : AppColors.border2,
          width: isMe || isTop3 ? 1 : 0.5,
        ),
      ),
      child: Row(children: [
        // Rank indicator
        SizedBox(
          width: 32,
          child: isTop3
              ? Text(_crown(entry.rank),
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center)
              : Text(
                  '#${entry.rank}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                  ),
                ),
        ),
        const SizedBox(width: 10),

        // Avatar
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMe
                ? AppColors.lime
                : AppColors.surface3,
          ),
          child: Center(child: Text(
            entry.initials,
            style: TextStyle(
              fontFamily:  'Inter',
              fontSize:    13,
              fontWeight:  FontWeight.w800,
              color:       isMe ? AppColors.bg : AppColors.textSecondary,
            ),
          )),
        ),
        const SizedBox(width: 10),

        // Name + level
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Flexible(child: Text(
                isMe ? '${entry.name} (you)' : entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isMe ? AppColors.lime : AppColors.textPrimary,
                ),
              )),
            ]),
            const SizedBox(height: 3),
            Row(children: [
              LevelBadge(level: entry.level, fontSize: 9),
              if (entry.streak > 0) ...[
                const SizedBox(width: 6),
                Row(children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Color(0xFFFF8C42), size: 11),
                  Text('${entry.streak}d', style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF8C42),
                  )),
                ]),
              ],
            ]),
          ],
        )),
        const SizedBox(width: 8),

        // Consistency score (hidden on small screens to prevent overflow)
        if (MediaQuery.of(context).size.width > 380) ...[
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${entry.consistencyScore}',
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            const Text('consistency', style: TextStyle(
              fontFamily: 'Inter', fontSize: 9,
              color: AppColors.textTertiary,
            )),
          ]),
          const SizedBox(width: 12),
        ],

        // XP + score
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.bolt_rounded,
                color: Color(0xFFFBBF24), size: 13),
            Text(
              _formatXP(entry.verifiedXP),
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFBBF24),
              ),
            ),
          ]),
          const Text('XP', style: TextStyle(
            fontFamily: 'Inter', fontSize: 9,
            color: AppColors.textTertiary,
          )),
        ]),
        const SizedBox(width: 10),

        // Total score pill
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color:        AppColors.surface3,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${entry.totalScore}', style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              )),
              const Text('score', style: TextStyle(
                fontFamily: 'Inter', fontSize: 8,
                color: AppColors.textTertiary,
              )),
            ],
          ),
        ),
      ]),
    );
  }

  Color _top3Bg(int rank) => switch (rank) {
    1 => const Color(0x1AFFD700),
    2 => const Color(0x1AC0C0C0),
    _ => const Color(0x1ACD7F32),
  };

  Color _top3Border(int rank) => switch (rank) {
    1 => const Color(0x33FFD700),
    2 => const Color(0x33C0C0C0),
    _ => const Color(0x33CD7F32),
  };

  String _crown(int rank) => switch (rank) {
    1 => '🥇', 2 => '🥈', _ => '🥉',
  };

  String _formatXP(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return '$xp';
  }
}