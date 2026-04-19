import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/xp_log_model.dart';

class XpHistoryTile extends StatelessWidget {
  final XpLogModel log;
  const XpHistoryTile({super.key, required this.log});

  (Color, Color, Color, IconData) get _style => switch (log.source) {
    'workout_complete' =>
      (const Color(0x1AFBBF24), const Color(0xFFFBBF24),
       const Color(0x33FBBF24), Icons.bolt_rounded),
    'streak_bonus' =>
      (const Color(0x1AFF8C42), const Color(0xFFFF8C42),
       const Color(0x33FF6B00), Icons.local_fire_department_rounded),
    'comeback_bonus' =>
      (AppColors.successDim, AppColors.success,
       const Color(0x3322C55E), Icons.trending_up_rounded),
    'level_up_bonus' =>
      (AppColors.coachDim, AppColors.coach,
       AppColors.coachBorder, Icons.star_rounded),
    'xp_decay' =>
      (AppColors.dangerDim, AppColors.danger,
       AppColors.dangerBorder, Icons.trending_down_rounded),
    _ =>
      (AppColors.surface2, AppColors.textSecondary,
       AppColors.border3, Icons.bolt_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, iconColor, border, icon) = _style;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Row(children: [
        // Icon
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(9),
            border:       Border.all(color: border, width: 0.5),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),

        // Label + time
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.sourceLabel, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            )),
            Text(log.timeAgo, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary,
            )),
          ],
        )),

        // Amount + balance
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${log.isPositive ? '+' : ''}${log.amount} XP',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700,
              color: log.isPositive ? AppColors.lime : AppColors.danger,
            ),
          ),
          Text(
            '${log.balanceAfter.toLocaleString()} total',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 10, color: AppColors.textTertiary,
            ),
          ),
        ]),
      ]),
    );
  }
}

extension on int {
  String toLocaleString() {
    final s   = toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}