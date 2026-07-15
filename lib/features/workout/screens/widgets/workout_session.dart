import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../../../shared/widgets/fc_loader.dart';
import '../../../../features/exercises/screens/widgets/exercise_gif_view.dart';
import '../../providers/workout_provider.dart';
import 'exercise_log_item.dart';
import 'quit_confirm_dialog.dart';
import 'session_timer_ring.dart';

class QuitConfirmDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Quit Workout?',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        content: const Text(
          'Your progress will be lost.\nAre you sure you want to quit?',
          style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}

class WorkoutSession extends ConsumerWidget {
  const WorkoutSession({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workoutProvider);

    // Find active exercise
    int activeIdx = state.logs.indexWhere((l) => !l.hasWork);
    if (activeIdx < 0 && state.logs.isNotEmpty) activeIdx = state.logs.length - 1;
    
    final activeLog = state.logs.isNotEmpty ? state.logs[activeIdx] : null;

    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        final quit = await QuitConfirmDialog.show(context);
        if (quit == true && context.mounted) {
          ref.read(workoutProvider.notifier).reset();
          context.go('/exercises');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface1, // The bottom sheet color
        body: CustomScrollView(
          slivers: [
            // ── Hero App Bar ───────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 400.0,
              pinned: true,
              backgroundColor: AppColors.surface2,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
                onPressed: () async {
                  final quit = await QuitConfirmDialog.show(context);
                  if (quit == true && context.mounted) {
                    ref.read(workoutProvider.notifier).reset();
                    context.go('/exercises');
                  }
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     Expanded(
                       child: Text(
                         activeLog?.exerciseName ?? 'Workout',
                         style: const TextStyle(
                           color: Colors.white,
                           fontWeight: FontWeight.w800,
                           fontSize: 24,
                           shadows: [Shadow(blurRadius: 10, color: Colors.black45)]
                         ),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                         '${state.completedCount}/${state.selectedExercises.length}',
                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                       ),
                     )
                  ],
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (activeLog != null)
                      ExerciseGifView(
                        gifUrl: activeLog.gifUrl,
                        name:   activeLog.exerciseName,
                        fit:    BoxFit.cover,
                      ),
                    // Gradient to ensure text readability
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black26, Colors.transparent, Colors.black87],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // ── Scrollable Sheet Content ──────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                // Wrap in Transform to pull it over the app bar slightly
                transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Pull Handle
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border2,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Timer & Progress ────────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.pageHPad),
                      child: Row(children: [
                        SessionTimerRing(
                          elapsedSeconds: state.elapsedSeconds,
                          isUnlocked:     state.isUnlocked,
                        ),
                        const SizedBox(width: 20),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StatRow(
                              icon:  Icons.bolt_rounded,
                              color: AppColors.primary,
                              label: 'Progress',
                              value: '${state.progressPct}%',
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value:           state.progressPct / 100,
                                backgroundColor: AppColors.surface2,
                                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        )),
                      ]),
                    ),

                    // ── Anti-cheat banner ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppConstants.pageHPad, 24, AppConstants.pageHPad, 12),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: state.isUnlocked
                          ? const _UnlockedBanner(key: ValueKey('unlocked'))
                          : _LockedBanner(
                              key: const ValueKey('locked'),
                              remaining: WorkoutState.minSeconds - state.elapsedSeconds,
                            ),
                      ),
                    ),

                    // ── Exercise List ──────────────────────────────────────────────────
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(AppConstants.pageHPad, 0, AppConstants.pageHPad, 32),
                      itemCount: state.logs.length,
                      itemBuilder: (_, i) {
                        final log = state.logs[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExerciseLogItem(
                            log:           log,
                            isActive:      i == activeIdx,
                            onSetDone:     () => ref.read(workoutProvider.notifier).markSetDone(log.exerciseId),
                            onRepIncrease: () => ref.read(workoutProvider.notifier).adjustReps(log.exerciseId, 1),
                            onRepDecrease: () => ref.read(workoutProvider.notifier).adjustReps(log.exerciseId, -1),
                            onTimedLog: (secs) => ref.read(workoutProvider.notifier).logTimedSeconds(log.exerciseId, secs),
                          ),
                        );
                      },
                    ),

                  ],
                )
              )
            )
          ],
        ),

        // ── Sticky Finish button ──────────────────────────────────────────
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(AppConstants.pageHPad, 12, AppConstants.pageHPad, 12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              border: const Border(top: BorderSide(color: AppColors.border1, width: 0.5)),
            ),
            child: state.completing
                ? const Center(child: FCLoader())
                : FCButton(
                    label: state.canFinish
                        ? 'Finish workout & earn XP'
                        : 'Keep going — ${_fmt(WorkoutState.minSeconds - state.elapsedSeconds)} to unlock',
                    fullWidth: true,
                    size:     FCButtonSize.lg,
                    variant:  state.canFinish ? FCButtonVariant.primary : FCButtonVariant.ghost,
                    onPressed: state.canFinish
                        ? () => ref.read(workoutProvider.notifier).completeSession()
                        : null,
                  ),
          ),
        ),
      ),
    );
  }

  String _fmt(int secs) {
    final s = secs.clamp(0, 9999);
    final m = s ~/ 60;
    final r = s  % 60;
    return m > 0 ? '${m}m ${r}s' : '${r}s';
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   label;
  final String   value;
  const _StatRow({
    required this.icon, required this.color,
    required this.label, required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: color, size: 16),
    const SizedBox(width: 6),
    Text('$value ', style: TextStyle(
      fontFamily: 'Inter', fontSize: 18,
      fontWeight: FontWeight.w800, color: color,
    )),
    Text(label, style: const TextStyle(
      fontFamily: 'Inter', fontSize: 12,
      color: AppColors.textTertiary,
    )),
  ]);
}

class _LockedBanner extends StatelessWidget {
  final int remaining;
  const _LockedBanner({super.key, required this.remaining});

  String _fmt(int secs) {
    final s = secs.clamp(0, 9999);
    final m = s ~/ 60;
    final r = s % 60;
    return m > 0 ? '${m}m ${r}s' : '${r}s';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color:        AppColors.accent5Dim,
      borderRadius: BorderRadius.circular(16),
      border:       Border.all(color: AppColors.accent5Light, width: 1),
    ),
    child: Row(children: [
      Icon(Icons.lock_rounded, color: AppColors.accent5, size: 18),
      const SizedBox(width: 12),
      Expanded(child: Text(
        'XP unlocks in ${_fmt(remaining)} — anti-cheat protection active',
        style: TextStyle(
          fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
          color: AppColors.accent5, height: 1.3,
        ),
      )),
    ]),
  );
}

class _UnlockedBanner extends StatelessWidget {
  const _UnlockedBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color:        AppColors.successDim,
      borderRadius: BorderRadius.circular(16),
      border:       Border.all(color: AppColors.success, width: 1),
    ),
    child: Row(children: [
      Icon(Icons.lock_open_rounded, color: AppColors.success, size: 18),
      const SizedBox(width: 12),
      Expanded(child: Text(
        'XP unlocked — you can finish anytime now',
        style: TextStyle(
          fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, height: 1.3,
        ),
      )),
    ]),
  );
}

extension on WorkoutState {
  bool get completing => stage == WorkoutStage.completing;
}