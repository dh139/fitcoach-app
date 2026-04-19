import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ScoreFormulaRow extends StatelessWidget {
  const ScoreFormulaRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _Pill('50%', 'Verified XP',   const Color(0xFFFBBF24)),
      const SizedBox(width: 8),
      _Pill('25%', 'Consistency',   AppColors.lime),
      const SizedBox(width: 8),
      _Pill('25%', 'Improvement',   AppColors.coach),
    ]);
  }
}

class _Pill extends StatelessWidget {
  final String pct, label;
  final Color  color;
  const _Pill(this.pct, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.circular(12),
      border:       Border.all(color: AppColors.border2, width: 0.5),
    ),
    child: Column(children: [
      Text(pct, style: TextStyle(
        fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800,
        color: color, letterSpacing: -0.3,
      )),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w600,
        color: AppColors.textTertiary, letterSpacing: 0.5,
      )),
    ]),
  ));
}