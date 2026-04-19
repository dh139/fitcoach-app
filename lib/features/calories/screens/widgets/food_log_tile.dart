import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/food_log_model.dart';
import '../../providers/calorie_provider.dart';

class FoodLogTile extends ConsumerWidget {
  final FoodLogModel entry;
  const FoodLogTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key:        Key(entry.id),
      direction:  DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding:   const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color:        AppColors.dangerDim,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.danger, size: 20),
      ),
      onDismissed: (_) =>
          ref.read(calorieProvider.notifier).deleteEntry(entry.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: AppColors.border2, width: 0.5),
        ),
        child: Row(children: [
          // Source icon
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color:        _sourceBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(_sourceIcon, color: _sourceColor, size: 16),
          ),
          const SizedBox(width: 12),

          // Name + meta
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.name, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
              Text(
                '${entry.quantity} ${entry.unit}'
                '${entry.brand.isNotEmpty ? ' · ${entry.brand}' : ''}'
                '${entry.protein > 0
                  ? ' · P:${entry.protein.round()}g C:${entry.carbs.round()}g F:${entry.fat.round()}g'
                  : ''}',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 10,
                  color: AppColors.textTertiary,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ],
          )),
          const SizedBox(width: 8),

          // Calories
          Text('${entry.calories}', style: const TextStyle(
            fontFamily: 'Inter', fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )),
          const SizedBox(width: 3),
          const Text('kcal', style: TextStyle(
            fontFamily: 'Inter', fontSize: 10,
            color: AppColors.textTertiary,
          )),
        ]),
      ),
    );
  }

  Color get _sourceBg => switch (entry.source) {
    'search' => const Color(0x1A3B82F6),
    'photo'  => const Color(0x1AA855F7),
    _        => AppColors.surface2,
  };

  Color get _sourceColor => switch (entry.source) {
    'search' => const Color(0xFF60A5FA),
    'photo'  => AppColors.coach,
    _        => AppColors.textSecondary,
  };

  IconData get _sourceIcon => switch (entry.source) {
    'search' => Icons.search_rounded,
    'photo'  => Icons.camera_alt_rounded,
    _        => Icons.edit_rounded,
  };
}