import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/dashboard/screens/widgets/level_up_dialog.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../models/workout_result_model.dart';
import '../../providers/workout_provider.dart';

class WorkoutSummary extends ConsumerStatefulWidget {
  const WorkoutSummary({super.key});

  @override
  ConsumerState<WorkoutSummary> createState() => _WorkoutSummaryState();
}

class _WorkoutSummaryState extends ConsumerState<WorkoutSummary>
    with SingleTickerProviderStateMixin {

  late final AnimationController _animCtrl;
  late final Animation<double>    _fadeAnim;
  late final Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    // Check level-up after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLevelUp());
  }

  void _checkLevelUp() {
    final result = ref.read(workoutProvider).result;
    if (result != null && result.didLevelUp &&
        result.previousLevel != null && result.newLevel != null) {
      final prev = int.tryParse(result.previousLevel ?? '');
      final next = int.tryParse(result.newLevel ?? '');
      if (prev != null && next != null) {
        LevelUpDialog.show(
          context,
          previousLevel: prev,
          newLevel:      next,
        );
      }
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(workoutProvider.select((s) => s.result));
    if (result == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppConstants.pageHPad, 24,
                  AppConstants.pageHPad, 40),
              child: Column(children: [

                // ── Status hero ──────────────────────────────────────────────
                _StatusHero(isVerified: result.isVerified),
                const SizedBox(height: 24),

                // ── Score meters ─────────────────────────────────────────────
                Row(children: [
                  Expanded(child: _ScoreMeter(
                    label: 'Overall score',
                    value: result.qualityScore,
                    color: AppColors.coach,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _ScoreMeter(
                    label: 'Duration',
                    value: (result.durationSeconds / 60).round()
                        .clamp(0, 99),
                    suffix: 'min',
                    color: AppColors.lime,
                  )),
                ]),
                const SizedBox(height: 10),

                // ── Stats grid ───────────────────────────────────────────────
                Row(children: [
                  Expanded(child: _StatTile(
                    icon:  Icons.bolt_rounded,
                    color: const Color(0xFFFBBF24),
                    bg:    const Color(0x1AFBBF24),
                    label: 'XP earned',
                    value: '+${result.xpEarned}',
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatTile(
                    icon:  Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF8C42),
                    bg:    const Color(0x1AFF6B00),
                    label: 'Calories',
                    value: '${result.totalCaloriesBurned}',
                  )),
                ]),
                const SizedBox(height: 18),

                // ── Verification breakdown ───────────────────────────────────
                _VerificationCard(result: result),
                const SizedBox(height: 18),

                // ── Reason / message ─────────────────────────────────────────
                if (result.reason.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:        result.isVerified
                          ? AppColors.limeDim
                          : AppColors.dangerDim,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: result.isVerified
                            ? AppColors.limeBorder
                            : AppColors.dangerBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          result.isVerified
                              ? Icons.info_outline_rounded
                              : Icons.warning_amber_rounded,
                          color: result.isVerified
                              ? AppColors.lime
                              : AppColors.danger,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(
                          result.reason,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 13,
                            color: result.isVerified
                                ? AppColors.lime
                                : const Color(0xFFFF8888),
                            height: 1.5,
                          ),
                        )),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // ── CTAs ─────────────────────────────────────────────────────
                FCButton(
                  label:    'New workout',
                  fullWidth: true,
                  size:     FCButtonSize.lg,
                  trailing: const Icon(Icons.arrow_forward_rounded,
                      size: 18, color: AppColors.bg),
                  onPressed: () =>
                      ref.read(workoutProvider.notifier).reset(),
                ),
                const SizedBox(height: 10),
                FCButton(
                  label:    'Back to dashboard',
                  variant:  FCButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () {
                    ref.read(workoutProvider.notifier).reset();
                    context.go('/dashboard');
                  },
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  final bool isVerified;
  const _StatusHero({required this.isVerified});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        color: isVerified ? AppColors.limeDim : AppColors.dangerDim,
        shape: BoxShape.circle,
        border: Border.all(
          color: isVerified ? AppColors.limeBorder : AppColors.dangerBorder,
          width: 1,
        ),
      ),
      child: Icon(
        isVerified
            ? Icons.verified_rounded
            : Icons.cancel_outlined,
        color: isVerified ? AppColors.lime : AppColors.danger,
        size: 36,
      ),
    ),
    const SizedBox(height: 14),
    Text(
      isVerified ? 'Workout complete!' : 'Session not verified',
      style: const TextStyle(
        fontFamily:    'Inter',
        fontSize:      22,
        fontWeight:    FontWeight.w800,
        color:         AppColors.textPrimary,
        letterSpacing: -0.4,
      ),
    ),
    const SizedBox(height: 6),
    Text(
      isVerified
          ? 'Great job — XP has been added to your profile'
          : 'Check the details below',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Inter', fontSize: 13,
        color: AppColors.textSecondary,
      ),
    ),
  ]);
}

class _ScoreMeter extends StatelessWidget {
  final String label;
  final int    value;
  final String? suffix;
  final Color  color;
  const _ScoreMeter({
    required this.label, required this.value,
    required this.color, this.suffix,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.circular(16),
      border:       Border.all(color: AppColors.border2, width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: const TextStyle(
        fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
        color: AppColors.textTertiary, letterSpacing: 0.9,
      )),
      const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('$value', style: TextStyle(
          fontFamily: 'Inter', fontSize: 26, fontWeight: FontWeight.w800,
          color: AppColors.textPrimary, letterSpacing: -0.5,
        )),
        if (suffix != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 3, left: 3),
            child: Text(suffix!, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 12,
              color: AppColors.textTertiary,
            )),
          ),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value:           (value / 100).clamp(0.0, 1.0),
          backgroundColor: AppColors.surface3,
          valueColor:      AlwaysStoppedAnimation(color),
          minHeight:       4,
        ),
      ),
    ]),
  );
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String label, value;
  const _StatTile({
    required this.icon, required this.color,
    required this.bg, required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.circular(16),
      border:       Border.all(color: AppColors.border2, width: 0.5),
    ),
    child: Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: -0.3,
        )),
        Text(label, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 10,
          color: AppColors.textTertiary,
        )),
      ])),
    ]),
  );
}

class _VerificationCard extends StatelessWidget {
  final WorkoutResultModel result;
  const _VerificationCard({required this.result});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.circular(16),
      border:       Border.all(color: AppColors.border2, width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('VERIFICATION', style: TextStyle(
        fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
        color: AppColors.textTertiary, letterSpacing: 0.9,
      )),
      const SizedBox(height: 12),
      _CheckRow(
        label: 'Minimum duration (2 min)',
        pass:  result.details.durationValid,
      ),
      const SizedBox(height: 8),
      _CheckRow(
        label: 'Exercises completed',
        pass:  result.details.exerciseCountValid,
      ),
      const SizedBox(height: 8),
      _CheckRow(
        label: 'No rapid clicking detected',
        pass:  result.details.clickSpacingValid,
      ),
    ]),
  );
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool   pass;
  const _CheckRow({required this.label, required this.pass});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        color:        pass ? AppColors.limeDim : AppColors.dangerDim,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(
        pass ? Icons.check_rounded : Icons.close_rounded,
        color: pass ? AppColors.lime : AppColors.danger,
        size:  13,
      ),
    ),
    const SizedBox(width: 10),
    Text(label, style: TextStyle(
      fontFamily: 'Inter', fontSize: 13,
      color: pass ? AppColors.textPrimary : AppColors.textTertiary,
    )),
  ]);
}