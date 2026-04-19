import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_button.dart';

class ExercisesEmptyState extends StatelessWidget {
  final bool   hasFilter;
  final VoidCallback onClear;

  const ExercisesEmptyState({
    super.key,
    required this.hasFilter,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color:        AppColors.surface2,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.fitness_center_rounded,
              color: AppColors.surface4, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          hasFilter ? 'No exercises found' : 'No exercises yet',
          style: const TextStyle(
            fontFamily:  'Inter',
            fontSize:    16,
            fontWeight:  FontWeight.w600,
            color:       AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasFilter
            ? 'Try different filters or search terms'
            : 'Check your connection and try again',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter', fontSize: 13,
            color: AppColors.textTertiary, height: 1.5,
          ),
        ),
        if (hasFilter) ...[
          const SizedBox(height: 20),
          FCButton(
            label:    'Clear filters',
            variant:  FCButtonVariant.secondary,
            onPressed: onClear,
          ),
        ],
      ]),
    ));
  }
}