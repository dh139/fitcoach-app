import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "../../core/constants/app_colors.dart";
import "../../core/constants/app_constants.dart";
import "../../core/constants/app_text_styles.dart";

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String value, label;
  final String? delta;
  final Color? deltaColor, textColor, bgColor;
  final int index;

  const StatCard({super.key, required this.icon, required this.iconColor, required this.iconBg, required this.value, required this.label, this.delta, this.deltaColor, this.index = 0, this.textColor, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.surface1,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: (bgColor != null ? Colors.transparent : AppColors.slate), width: 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: iconColor.withOpacity(0.15), width: 0.5)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: AppTextStyles.statValue.copyWith(color: textColor ?? AppColors.textPrimary, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            if (delta != null) ...[
              Flexible(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: (deltaColor ?? AppColors.primary).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(delta!, style: AppTextStyles.label.copyWith(color: deltaColor ?? AppColors.primary, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
              )),
              const SizedBox(width: 6),
            ],
            Expanded(child: Text(label.toUpperCase(), style: AppTextStyles.statLabel.copyWith(color: (textColor ?? AppColors.textTertiary).withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ])),
      ]),
    ).animate().fade(duration: 400.ms, delay: (100 * index).ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}
