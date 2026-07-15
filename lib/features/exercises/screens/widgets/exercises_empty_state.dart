import "package:flutter/material.dart";
import "../../../../core/constants/app_colors.dart";
import "../../../../core/constants/app_text_styles.dart";

class ExercisesEmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onClear;
  const ExercisesEmptyState({super.key, required this.hasFilter, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.search_off_rounded, color: AppColors.textTertiary, size: 32),
          ),
          const SizedBox(height: 20),
          Text(hasFilter ? "No exercises found" : "No exercises yet",
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(hasFilter ? "Try adjusting your filters or search term" : "Your exercise library will appear here",
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary), textAlign: TextAlign.center),
          if (hasFilter) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(12)),
                child: const Text("Clear filters", style: TextStyle(fontFamily: "Inter", fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
