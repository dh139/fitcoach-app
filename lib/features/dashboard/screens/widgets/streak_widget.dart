import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../../core/constants/app_colors.dart";
import "../../../../core/constants/app_text_styles.dart";

class StreakWidget extends ConsumerWidget {
  const StreakWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    const allDays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final date = today.subtract(Duration(days: 6 - i));
          final dayName = allDays[date.weekday - 1];
          final dayStr  = "${date.day}";
          final isToday = i == 6;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: isToday ? BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))],
            ) : null,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (isToday) Container(
                width: 4, height: 4, margin: const EdgeInsets.only(bottom: 6),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
              Text(dayName, style: AppTextStyles.label.copyWith(color: isToday ? Colors.white : AppColors.textTertiary, fontWeight: FontWeight.w500, letterSpacing: 0)),
              const SizedBox(height: 8),
              Text(dayStr, style: AppTextStyles.body.copyWith(color: isToday ? Colors.white : AppColors.textPrimary, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500)),
            ]),
          );
        }),
      ),
    );
  }
}
