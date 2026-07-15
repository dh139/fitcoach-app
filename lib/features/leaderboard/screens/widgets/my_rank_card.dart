import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/level_badge.dart';
import '../../models/leaderboard_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/providers/step_provider.dart';

class MyRankCard extends ConsumerWidget {
  final List<MyPeriodRank> stats;
  const MyRankCard({super.key, required this.stats});

  static const _labels = {
    'daily':   'Today',
    'weekly':  'This week',
    'monthly': 'This month',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stats.isEmpty) return const SizedBox.shrink();
    
    final stepsToday = ref.watch(stepProvider).stepsToday;

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
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.limeDim,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.directions_walk_rounded, color: AppColors.lime, size: 12),
              const SizedBox(width: 4),
              Text('$stepsToday steps today', style: const TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                fontWeight: FontWeight.w700, color: AppColors.lime,
              )),
            ]),
          ),
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