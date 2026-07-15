import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../../../shared/widgets/fc_badge.dart';
import '../../models/exercise_model.dart';
import 'exercise_gif_view.dart';
import '../../../workout/providers/workout_provider.dart';

class ExerciseDetailSheet extends ConsumerWidget {
  final ExerciseModel exercise;
  const ExerciseDetailSheet({super.key, required this.exercise});

  static void show(BuildContext context, ExerciseModel ex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExerciseDetailSheet(exercise: ex),
    );
  }

  Color get _accentColor {
    switch (exercise.bodyPart.toLowerCase()) {
      case 'chest': return AppColors.bodyChest;
      case 'back': return AppColors.bodyBack;
      case 'shoulders': return AppColors.bodyShoulders;
      case 'upper arms': return AppColors.bodyUpperArms;
      case 'upper legs': return AppColors.bodyUpperLegs;
      case 'waist': return AppColors.bodyWaist;
      case 'cardio': return AppColors.bodyCardio;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(workoutProvider.select((s) => s.selectedExercises.any((e) => e.id == exercise.id)));
    final accent = _accentColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: scrollCtrl,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: Container(
                  color: AppColors.surface2,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Center(
                      child: ExerciseGifView(
                        gifUrl: exercise.gifUrl,
                        name: exercise.capitalizedName,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.capitalizedName, style: AppTextStyles.displaySm.copyWith(color: AppColors.textPrimary, fontSize: 24)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      FCBadge(label: exercise.difficulty, variant: exercise.difficulty == 'beginner' ? FCBadgeVariant.lime : exercise.difficulty == 'advanced' ? FCBadgeVariant.red : FCBadgeVariant.blue),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: accent.withOpacity(0.3), width: 0.5)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(exercise.capitalizedBodyPart, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: accent)),
                        ]),
                      ),
                      if (exercise.equipment.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border1, width: 0.5)),
                          child: Text(exercise.equipment, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primaryBorder, width: 0.5)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.bolt_rounded, size: 12, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text('${exercise.caloriesPerMinute} cal/min', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    if (exercise.target.isNotEmpty) ...[
                      _SectionTitle('Primary Target'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(exercise.target[0].toUpperCase() + exercise.target.substring(1), style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ]),
                      ),
                    ],
                    if (exercise.secondaryMuscles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionTitle('Secondary Muscles'),
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 6, children: exercise.secondaryMuscles.map((m) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border1, width: 0.5)),
                        child: Text(m[0].toUpperCase() + m.substring(1), style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textSecondary)),
                      )).toList()),
                    ],
                    const SizedBox(height: 20),
                    _SectionTitle('Instructions'),
                    const SizedBox(height: 8),
                    if (exercise.instructions.isNotEmpty)
                      ...exercise.instructions.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(6)),
                            child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(e.value, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary, height: 1.5))),
                        ]),
                      )),
                    const SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 32),
                      child: FCButton(
                        label: isSelected ? 'Remove from Workout' : 'Add to Workout',
                        fullWidth: true,
                        variant: isSelected ? FCButtonVariant.danger : FCButtonVariant.primary,
                        leading: Icon(isSelected ? Icons.remove_rounded : Icons.add_rounded, color: Colors.white, size: 20),
                        onPressed: () {
                          ref.read(workoutProvider.notifier).toggleExercise(exercise);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 3, height: 14,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent2], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 8),
      Text(title, style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary)),
    ]);
  }
}
