import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_badge.dart';
import '../../models/workout_history_model.dart';

class WorkoutHistoryTile extends StatefulWidget {
  final WorkoutHistoryModel workout;
  const WorkoutHistoryTile({super.key, required this.workout});

  @override
  State<WorkoutHistoryTile> createState() => _WorkoutHistoryTileState();
}

class _WorkoutHistoryTileState extends State<WorkoutHistoryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.workout;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _expanded
                ? AppColors.limeBorder
                : AppColors.border2,
            width: _expanded ? 1 : 0.5,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // ── Row 1: icon + name + verified + chevron ──────────────────
          Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color:        w.isVerified
                    ? AppColors.limeDim : AppColors.surface2,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: w.isVerified
                      ? AppColors.limeBorder : AppColors.border3,
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: w.isVerified
                    ? AppColors.lime : AppColors.textTertiary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.workoutName,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  w.relativeDate,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            )),
            if (w.isVerified)
              const FCBadge(label: 'Verified',
                  variant: FCBadgeVariant.lime),
            const SizedBox(width: 8),
            Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.textTertiary, size: 18,
            ),
          ]),

          // ── Row 2: stats pills ────────────────────────────────────────
          const SizedBox(height: 10),
          Row(children: [
            _StatPill(
              Icons.timer_rounded,
              w.formattedDuration,
              AppColors.lime,
              AppColors.limeDim,
            ),
            const SizedBox(width: 8),
            _StatPill(
              Icons.local_fire_department_rounded,
              '${w.totalCaloriesBurned} cal',
              const Color(0xFFFF8C42),
              const Color(0x1AFF6B00),
            ),
            const SizedBox(width: 8),
            _StatPill(
              Icons.bolt_rounded,
              '+${w.xpEarned} XP',
              const Color(0xFFFBBF24),
              const Color(0x1AFBBF24),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:        AppColors.surface3,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Q: ${w.qualityScore}',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ]),

          // ── Expanded: exercises list ──────────────────────────────────
          if (_expanded && w.exercises.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border2),
            const SizedBox(height: 10),
            const Text('EXERCISES', style: TextStyle(
              fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
              color: AppColors.textTertiary, letterSpacing: 0.9,
            )),
            const SizedBox(height: 8),
            ...w.exercises.map((ex) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(children: [
                Container(
                  width: 4, height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.lime,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  ex.exerciseName.isEmpty
                      ? 'Unknown exercise'
                      : ex.exerciseName[0].toUpperCase() +
                        ex.exerciseName.substring(1),
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                )),
                if (ex.setsCompleted > 0)
                  Text(
                    '${ex.setsCompleted} × ${ex.repsCompleted} reps',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  )
                else if (ex.durationSeconds > 0)
                  Text(
                    '${ex.durationSeconds}s',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ]),
            )),
          ],
        ]),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String   value;
  final Color    color, bg;
  const _StatPill(this.icon, this.value, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.circular(8),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 12),
      const SizedBox(width: 4),
      Text(value, style: TextStyle(
        fontFamily: 'Inter', fontSize: 10,
        fontWeight: FontWeight.w600, color: color,
      )),
    ]),
  );
}