import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/exercise_model.dart';
import 'exercise_gif_view.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final bool isFavorited, isSelected;
  final VoidCallback onTap, onFavoriteTap;
  final VoidCallback? onSelectTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isFavorited,
    this.isSelected = false,
    required this.onTap,
    required this.onFavoriteTap,
    this.onSelectTap,
  });

  Color get _bodyPartColor {
    switch (exercise.bodyPart.toLowerCase()) {
      case 'chest':       return AppColors.bodyChest;
      case 'back':        return AppColors.bodyBack;
      case 'shoulders':   return AppColors.bodyShoulders;
      case 'upper arms':  return AppColors.bodyUpperArms;
      case 'upper legs':  return AppColors.bodyUpperLegs;
      case 'waist':       return AppColors.bodyWaist;
      case 'cardio':      return AppColors.bodyCardio;
      default:            return AppColors.primary;
    }
  }

  Color get _difficultyColor {
    switch (exercise.difficulty.toLowerCase()) {
      case 'beginner':     return AppColors.beginner;
      case 'advanced':     return AppColors.advanced;
      default:             return AppColors.primary;
    }
  }

  Color get _difficultyBg {
    switch (exercise.difficulty.toLowerCase()) {
      case 'beginner':     return AppColors.beginnerDim;
      case 'advanced':     return AppColors.advancedDim;
      default:             return AppColors.primaryDim;
    }
  }

  // Estimate a duration based on calories per minute (100 cal workout)
  int get _estMinutes => (100 / exercise.caloriesPerMinute.clamp(1, 20)).round().clamp(3, 30);

  @override
  Widget build(BuildContext context) {
    final accent = _bodyPartColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary.withAlpha(130) : AppColors.border1,
            width: isSelected ? 1.5 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isSelected ? 18 : 8),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image / GIF area ─────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // GIF fills entire image area
                  Positioned.fill(
                    child: ExerciseGifView(
                      gifUrl: exercise.gifUrl,
                      name: exercise.capitalizedName,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Very subtle top gradient for badge readability
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surface2.withAlpha(200),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Difficulty badge — top-left
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _difficultyBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _difficultyColor.withAlpha(40),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        exercise.difficulty.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: _difficultyColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Select toggle — overlaid on difficulty when active
                  if (onSelectTap != null)
                    Positioned(
                      top: 8, left: 8,
                      child: GestureDetector(
                        onTap: onSelectTap,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.textPrimary
                                : Colors.black.withAlpha(45),
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(60),
                                      blurRadius: 8,
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isSelected ? Icons.check_rounded : Icons.add_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),

                  // Favourite button — top-right
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: isFavorited
                              ? AppColors.accent2Dim
                              : Colors.white.withAlpha(210),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorited
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorited
                              ? AppColors.accent2
                              : AppColors.textTertiary,
                          size: 15,
                        ),
                      ),
                    ),
                  ),

                  // Thin accent bar at very bottom of image
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(height: 2, color: accent.withAlpha(120)),
                  ),
                ],
              ),
            ),

            // ── Info area ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Exercise name
                  Text(
                    exercise.capitalizedName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Body part row
                  Row(children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        exercise.capitalizedBodyPart,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 7),

                  // Stats row: duration | calorie burn rate
                  Row(children: [
                    const Icon(Icons.timer_outlined,
                        size: 11, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      '$_estMinutes min',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 7),
                      width: 1, height: 10,
                      color: AppColors.border3,
                    ),
                    Icon(Icons.local_fire_department_outlined,
                        size: 11, color: AppColors.accent2),
                    const SizedBox(width: 3),
                    Text(
                      '${exercise.caloriesPerMinute} kcal/m',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
