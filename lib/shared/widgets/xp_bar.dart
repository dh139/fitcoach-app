import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'level_badge.dart';

class XpBar extends StatelessWidget {
  final int xp;
  final int level;           // We'll convert if needed
  final double progressPct;
  final int xpToNext;
  final String nextLevelName;

  const XpBar({
    super.key,
    required this.xp,
    required this.level,
    required this.progressPct,
    required this.xpToNext,
    required this.nextLevelName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Level $level',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            LevelBadge(
              level: nextLevelName.toLowerCase(),
              fontSize: 11,
            ),
            const Spacer(),
            Text(
              '$xp XP',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Progress Bar
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                widthFactor: progressPct.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.lime, Color(0xFFa3e635)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$xpToNext XP to ${nextLevelName[0].toUpperCase()}${nextLevelName.substring(1)}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '${progressPct.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.lime,
              ),
            ),
          ],
        ),
      ],
    );
  }
}