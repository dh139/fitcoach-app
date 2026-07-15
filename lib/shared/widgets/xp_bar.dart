import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class XPBar extends StatelessWidget {
  final int level, xp, xpToNext;
  final double progressPct;
  const XPBar({super.key, required this.level, required this.xp, required this.xpToNext, required this.progressPct});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border1, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        LevelBadge(level: level),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Level $level', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text('$xp / $xpToNext XP', style: AppTextStyles.label.copyWith(fontSize: 10)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(height: 8, width: double.infinity, color: AppColors.surface3,
              child: LayoutBuilder(builder: (_, c) => Container(
                width: c.maxWidth * progressPct.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent2], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(6),
                ),
              )),
            ),
          ),
        ])),
      ]),
    );
  }
}

class LevelBadge extends StatelessWidget {
  final int level;
  const LevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    if (level < 5) { label = 'BEGINNER'; color = AppColors.accent5; }
    else if (level < 10) { label = 'INTERMEDIATE'; color = AppColors.info; }
    else if (level < 20) { label = 'ADVANCED'; color = AppColors.primary; }
    else { label = 'ELITE'; color = AppColors.accent4; }

    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Center(child: Text('$level', style: TextStyle(fontFamily: 'Syne', fontSize: 20, fontWeight: FontWeight.w800, color: color))),
    );
  }
}
