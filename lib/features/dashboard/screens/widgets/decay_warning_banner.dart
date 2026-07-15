import "package:flutter/material.dart";
import "../../../../core/constants/app_colors.dart";
import "../../../../core/constants/app_text_styles.dart";

class DecayWarningBanner extends StatelessWidget {
  final int? daysInactive;
  const DecayWarningBanner({super.key, this.daysInactive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        border: Border(
          left: BorderSide(color: AppColors.warningAccent, width: 3),
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warningAccent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "XP Decay Warning",
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warningAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  daysInactive != null
                      ? "$daysInactive days inactive - complete a workout to stop XP loss."
                      : "Complete a workout to stop XP loss.",
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
