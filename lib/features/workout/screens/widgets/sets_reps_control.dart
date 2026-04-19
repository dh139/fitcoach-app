import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SetsRepsControl extends StatelessWidget {
  final int          setsCompleted;
  final int          repsPerSet;
  final VoidCallback onSetDone;
  final VoidCallback onRepIncrease;
  final VoidCallback onRepDecrease;

  const SetsRepsControl({
    super.key,
    required this.setsCompleted,
    required this.repsPerSet,
    required this.onSetDone,
    required this.onRepIncrease,
    required this.onRepDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      // Reps stepper
      Container(
        decoration: BoxDecoration(
          color:        AppColors.surface3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _StepBtn(
            icon: Icons.remove_rounded,
            onTap: onRepDecrease,
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$repsPerSet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.add_rounded,
            onTap: onRepIncrease,
          ),
        ]),
      ),
      const SizedBox(width: 6),
      const Text('reps', style: TextStyle(
        fontFamily: 'Inter', fontSize: 12,
        color: AppColors.textTertiary,
      )),
      const Spacer(),

      // Mark set done button
      GestureDetector(
        onTap: onSetDone,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color:        AppColors.limeDim,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: AppColors.limeBorder, width: 0.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_rounded, color: AppColors.lime, size: 16),
            const SizedBox(width: 6),
            Text(
              setsCompleted > 0
                  ? 'Set ${setsCompleted + 1}'
                  : 'Mark set done',
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.lime,
              ),
            ),
          ]),
        ),
      ),

      // Sets badge
      if (setsCompleted > 0) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color:        AppColors.surface3,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$setsCompleted set${setsCompleted > 1 ? 's' : ''}',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ]);
  }
}

class _StepBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color:        AppColors.surface4,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 18),
    ),
  );
}