import "package:flutter/material.dart";
import "../../../../core/constants/app_colors.dart";
import "../../../../core/constants/app_text_styles.dart";

class XpHistoryTile extends StatelessWidget {
  final dynamic log;
  const XpHistoryTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final isPositive = log.isPositive;
    final icon = isPositive ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded;
    final color = isPositive ? AppColors.accent5 : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border1, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(log.sourceLabel ?? "Activity", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(log.timeAgo ?? "", style: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary)),
        ])),
        Text("${isPositive ? "+" : ""}${log.amount} XP", style: AppTextStyles.h4.copyWith(color: color, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

extension IntFormat on int {
  String toLocaleString() => toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},");
}
