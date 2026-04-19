import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_badge.dart';
import '../../models/exercise_model.dart';
import 'exercise_gif_view.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final bool          isFavorited;
  final VoidCallback  onTap;
  final VoidCallback  onFavoriteTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isFavorited,
    required this.onTap,
    required this.onFavoriteTap,
  });

  FCBadgeVariant get _diffVariant => switch (exercise.difficulty) {
    'beginner'  => FCBadgeVariant.lime,
    'advanced'  => FCBadgeVariant.red,
    _           => FCBadgeVariant.blue,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border2, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── GIF / image area ───────────────────────────────────────────
          Stack(children: [
            AspectRatio(
              aspectRatio: 1,
              child: ExerciseGifView(
                gifUrl: exercise.gifUrl,
                name:   exercise.capitalizedName,
                fit:    BoxFit.cover,
              ),
            ),

            // Favorite button — top right
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: onFavoriteTap,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color:        isFavorited
                        ? AppColors.dangerDim
                        : Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                    border: isFavorited
                        ? Border.all(color: AppColors.dangerBorder, width: 0.5)
                        : null,
                  ),
                  child: Icon(
                    isFavorited
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorited ? AppColors.danger : Colors.white70,
                    size: 16,
                  ),
                ),
              ),
            ),

            // Difficulty badge — bottom left
            Positioned(
              bottom: 8, left: 8,
              child: FCBadge(
                label:   exercise.difficulty,
                variant: _diffVariant,
              ),
            ),
          ]),

          // ── Info ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                exercise.capitalizedName,
                maxLines:     1,
                overflow:     TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily:  'Inter',
                  fontSize:    12,
                  fontWeight:  FontWeight.w600,
                  color:       AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(child: Text(
                  exercise.capitalizedBodyPart,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                )),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.bolt_rounded,
                    color: AppColors.lime, size: 12),
                const SizedBox(width: 3),
                Text(
                  '${exercise.caloriesPerMinute} cal/min',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lime,
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}