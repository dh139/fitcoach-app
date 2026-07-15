import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/exercises/screens/widgets/exercise_gif_view.dart';
import '../../models/workout_session_model.dart';
import 'sets_reps_control.dart';
import 'timed_control.dart';

class ExerciseLogItem extends StatefulWidget {
  final ExerciseLogEntry log;
  final bool             isActive;
  final VoidCallback     onSetDone;
  final VoidCallback     onRepIncrease;
  final VoidCallback     onRepDecrease;
  final Function(int)    onTimedLog;

  const ExerciseLogItem({
    super.key,
    required this.log,
    required this.isActive,
    required this.onSetDone,
    required this.onRepIncrease,
    required this.onRepDecrease,
    required this.onTimedLog,
  });

  @override
  State<ExerciseLogItem> createState() => _ExerciseLogItemState();
}

class _ExerciseLogItemState extends State<ExerciseLogItem> {
  bool _mode = true; // true = sets, false = timed

  bool get _isDone => widget.log.hasWork;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:        _isDone
            ? AppColors.surface1 // Keep done ones white
            : widget.isActive
            ? AppColors.brandPurple.withOpacity(0.05) // Pastel purple hint
            : AppColors.surface1, // white
        borderRadius: BorderRadius.circular(24),
        border: widget.isActive ? Border.all(color: AppColors.brandPurple.withOpacity(0.5), width: 1.5) : Border.all(color: AppColors.border2, width: 0.5),
        boxShadow: widget.isActive ? [
          BoxShadow(color: AppColors.brandPurple.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
        ] : [
           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: [
        // ── Header ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(children: [
            // Done indicator
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color:        _isDone
                    ? AppColors.lime
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isDone
                      ? AppColors.lime
                      : AppColors.border3,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                color: _isDone
                    ? Colors.white
                    : Colors.transparent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // GIF thumbnail
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border2, width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ExerciseGifView(
                  gifUrl: widget.log.gifUrl,
                  name:   widget.log.exerciseName,
                  fit:    BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + meta
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.log.exerciseName
                    .split(' ')
                    .map((w) => w.isEmpty ? w :
                      '${w[0].toUpperCase()}${w.substring(1)}')
                    .join(' '),
                  maxLines:  1,
                  overflow:  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '${widget.log.target} · ${widget.log.equipment}',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            )),

            // Mode toggle (sets / timed)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color:        AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _ModeBtn(
                  label:    'Sets',
                  active:   _mode,
                  onTap: () => setState(() => _mode = true),
                ),
                _ModeBtn(
                  label:    'Time',
                  active:   !_mode,
                  onTap: () => setState(() => _mode = false),
                ),
              ]),
            ),
          ]),
        ),

        // ── Controls ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _mode
            ? SetsRepsControl(
                setsCompleted: widget.log.setsCompleted,
                repsPerSet:    widget.log.repsCompleted,
                onSetDone:     widget.onSetDone,
                onRepIncrease: widget.onRepIncrease,
                onRepDecrease: widget.onRepDecrease,
              )
            : TimedControl(
                totalSeconds: widget.log.durationSeconds,
                onLog:        widget.onTimedLog,
              ),
        ),
      ]),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String       label;
  final bool         active;
  final VoidCallback onTap;
  const _ModeBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color:        active ? AppColors.surface1 : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(label, style: TextStyle(
        fontFamily:  'Inter',
        fontSize:    11,
        fontWeight:  FontWeight.w600,
        color:       active ? AppColors.textPrimary : AppColors.textTertiary,
      )),
    ),
  );
}