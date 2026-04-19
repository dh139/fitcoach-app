import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/level_badge.dart';
import '../../models/leaderboard_model.dart';

class MyRankCard extends StatelessWidget {
  final List<MyPeriodRank> stats;
  const MyRankCard({super.key, required this.stats});

  static const _labels = {
    'daily':   'Today',
    'weekly':  'This week',
    'monthly': 'This month',
  };

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: AppColors.limeBorder, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color:        const Color(0x1AFBBF24),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: Color(0xFFFBBF24), size: 15),
          ),
          const SizedBox(width: 10),
          const Text('Your rankings', style: TextStyle(
            fontFamily: 'Inter', fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary,
          )),
        ]),
        const SizedBox(height: 14),
        Row(children: stats.map((s) => Expanded(child: Padding(
          padding: EdgeInsets.only(
            right: s != stats.last ? 8 : 0),
          child: _PeriodTile(stat: s),
        ))).toList()),
      ]),
    );
  }
}

class _PeriodTile extends StatelessWidget {
  final MyPeriodRank stat;
  const _PeriodTile({required this.stat});

  static const _labels = {
    'daily':   'Today',
    'weekly':  'This week',
    'monthly': 'This month',
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color:        AppColors.surface2,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(children: [
      Text(
        _labels[stat.period] ?? stat.period,
        style: const TextStyle(
          fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w600,
          color: AppColors.textTertiary, letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        stat.rank != null ? '#${stat.rank}' : '—',
        style: const TextStyle(
          fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w800,
          color: AppColors.textPrimary, letterSpacing: -0.5, height: 1.0,
        ),
      ),
      if (stat.totalUsers > 0)
        Text('of ${stat.totalUsers}', style: const TextStyle(
          fontFamily: 'Inter', fontSize: 9,
          color: AppColors.textTertiary,
        )),
      if (stat.entry != null) ...[
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.bolt_rounded,
              color: Color(0xFFFBBF24), size: 11),
          const SizedBox(width: 2),
          Text('${stat.entry!.verifiedXP}', style: const TextStyle(
            fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700,
            color: Color(0xFFFBBF24),
          )),
        ]),
      ],
    ]),
  );
}