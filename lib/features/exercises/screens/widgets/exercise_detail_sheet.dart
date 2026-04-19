import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_badge.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../../../shared/widgets/level_badge.dart';
import '../../models/exercise_model.dart';
import '../../providers/exercise_provider.dart';
import 'exercise_gif_view.dart';

class ExerciseDetailSheet extends ConsumerWidget {
  final ExerciseModel exercise;

  const ExerciseDetailSheet({super.key, required this.exercise});

  static Future<void> show(
    BuildContext context,
    ExerciseModel exercise,
  ) => showModalBottomSheet(
    context:           context,
    isScrollControlled: true,
    backgroundColor:    Colors.transparent,
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: ExerciseDetailSheet(exercise: exercise),
    ),
  );

  FCBadgeVariant get _diffVariant => switch (exercise.difficulty) {
    'beginner'  => FCBadgeVariant.lime,
    'advanced'  => FCBadgeVariant.red,
    _           => FCBadgeVariant.blue,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(exerciseProvider
        .select((s) => s.favoriteIds.contains(exercise.id)));

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize:     0.5,
      maxChildSize:     0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color:        AppColors.border3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(child: ListView(
            controller:  scrollCtrl,
            padding:     const EdgeInsets.fromLTRB(20, 8, 20, 110),
            children: [

              // ── Header row ─────────────────────────────────────────────
              Row(children: [
                Expanded(child: Text(
                  exercise.capitalizedName,
                  style: const TextStyle(
                    fontFamily:    'Inter',
                    fontSize:      20,
                    fontWeight:    FontWeight.w700,
                    color:         AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                )),
                // Favorite toggle
                GestureDetector(
                  onTap: () => ref
                      .read(exerciseProvider.notifier)
                      .toggleFavorite(exercise.id),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isFav ? AppColors.dangerDim : AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFav
                            ? AppColors.dangerBorder
                            : AppColors.border3,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? AppColors.danger : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // ── Badges row ─────────────────────────────────────────────
              Wrap(spacing: 8, runSpacing: 8, children: [
                FCBadge(label: exercise.difficulty, variant: _diffVariant),
                FCBadge(label: exercise.capitalizedBodyPart, variant: FCBadgeVariant.gray),
                FCBadge(label: exercise.equipment, variant: FCBadgeVariant.gray),
              ]),
              const SizedBox(height: 16),

              // ── GIF ────────────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ExerciseGifView(
                  gifUrl: exercise.gifUrl,
                  name:   exercise.capitalizedName,
                  width:  double.infinity,
                  height: 260,
                  fit:    BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // ── Muscles ────────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.gps_fixed_rounded,
                label: 'Primary muscle',
              ),
              const SizedBox(height: 8),
              Text(
                exercise.target[0].toUpperCase() + exercise.target.substring(1),
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),

              if (exercise.secondaryMuscles.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionHeader(
                  icon: Icons.compress_rounded,
                  label: 'Secondary muscles',
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6,
                  children: exercise.secondaryMuscles
                      .map((m) => FCBadge(
                        label:   m[0].toUpperCase() + m.substring(1),
                        variant: FCBadgeVariant.gray,
                      ))
                      .toList(),
                ),
              ],

              // ── Calories ───────────────────────────────────────────────
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        AppColors.limeDim,
                  borderRadius: BorderRadius.circular(14),
                  border:       Border.all(color: AppColors.limeBorder, width: 0.5),
                ),
                child: Row(children: [
                  const Icon(Icons.bolt_rounded,
                      color: AppColors.lime, size: 20),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('ESTIMATED BURN', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lime,
                      letterSpacing: 0.8,
                    )),
                    RichText(text: TextSpan(children: [
                      TextSpan(
                        text: '~${exercise.caloriesPerMinute} ',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const TextSpan(
                        text: 'cal / min',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ])),
                  ]),
                ]),
              ),

              // ── Instructions ───────────────────────────────────────────
              if (exercise.instructions.isNotEmpty) ...[
                const SizedBox(height: 20),
                _SectionHeader(
                  icon: Icons.format_list_numbered_rounded,
                  label: 'Instructions',
                ),
                const SizedBox(height: 12),
                ...exercise.instructions.asMap().entries.map((entry) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24, height: 24,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color:        AppColors.limeDim,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                                color: AppColors.limeBorder, width: 0.5),
                          ),
                          child: Center(child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.lime,
                            ),
                          )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.55,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],

              // ── CTA ────────────────────────────────────────────────────
              const SizedBox(height: 8),
              FCButton(
                label:    'Start workout with this exercise',
                fullWidth: true,
                size:     FCButtonSize.lg,
                trailing: const Icon(Icons.arrow_forward_rounded,
                    size: 18, color: AppColors.bg),
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/workout');
                },
              ),
            ],
          )),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        color:        AppColors.surface2,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 14),
    ),
    const SizedBox(width: 8),
    Text(label.toUpperCase(), style: const TextStyle(
      fontFamily:    'Inter',
      fontSize:      10,
      fontWeight:    FontWeight.w700,
      color:         AppColors.textTertiary,
      letterSpacing: 0.9,
    )),
  ]);
}