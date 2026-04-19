import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/food_log_model.dart';
import '../../providers/calorie_provider.dart';
import 'food_log_tile.dart';

const _mealOrder   = ['breakfast', 'lunch', 'dinner', 'snack'];
const _mealIcons   = {
  'breakfast': Icons.wb_sunny_outlined,
  'lunch':     Icons.light_mode_rounded,
  'dinner':    Icons.nights_stay_outlined,
  'snack':     Icons.apple_rounded,
};

class FoodLogList extends ConsumerWidget {
  const FoodLogList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state  = ref.watch(calorieProvider);
    final byMeal = state.daySummary?.byMeal;

    if (state.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.lime,
          ),
        ),
      );
    }

    final hasAny = byMeal != null &&
        _mealOrder.any((m) => (byMeal[m] as List?)?.isNotEmpty == true);

    if (!hasAny) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color:        AppColors.surface2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.restaurant_outlined,
                color: AppColors.surface4, size: 26),
          ),
          const SizedBox(height: 12),
          const Text('No food logged yet', style: TextStyle(
            fontFamily: 'Inter', fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          )),
          const SizedBox(height: 6),
          const Text(
            'Use Search, Photo or Manual above to add meals',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 12,
              color: AppColors.textTertiary, height: 1.5,
            ),
          ),
        ])),
      );
    }

    return Column(children: _mealOrder.map((meal) {
      final raw   = byMeal?[meal];
      if (raw == null) return const SizedBox.shrink();
      final items = (raw as List<dynamic>)
          .map((e) => FoodLogModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (items.isEmpty) return const SizedBox.shrink();

      final mealCals = items.fold(0, (s, i) => s + i.calories);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(children: [
              Icon(_mealIcons[meal] ?? Icons.restaurant_outlined,
                  color: AppColors.textTertiary, size: 14),
              const SizedBox(width: 6),
              Text(
                meal[0].toUpperCase() + meal.substring(1),
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text('$mealCals kcal', style: const TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                color: AppColors.textTertiary,
              )),
            ]),
          ),
          // Items
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: FoodLogTile(entry: item),
          )),
          const SizedBox(height: 8),
        ],
      );
    }).toList());
  }
}