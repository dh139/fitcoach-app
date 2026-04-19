import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LevelBadge extends StatelessWidget {
  final String level;
  final double fontSize;

  const LevelBadge({super.key, required this.level, this.fontSize = 10});

  (Color, Color, Color) get _colors => switch (level) {
    'intermediate' => (AppColors.intermediateDim, AppColors.intermediate, AppColors.intermediateBorder),
    'advanced'     => (AppColors.advancedDim,     AppColors.advanced,     AppColors.advancedBorder),
    'elite'        => (AppColors.eliteDim,         AppColors.elite,        AppColors.eliteBorder),
    _              => (AppColors.beginnerDim,       AppColors.beginner,     AppColors.beginnerBorder),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, text, border) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(100),
        border:       Border.all(color: border, width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5, decoration: BoxDecoration(color: text, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(
          level[0].toUpperCase() + level.substring(1),
          style: TextStyle(fontFamily:'Inter', fontSize: fontSize, fontWeight:FontWeight.w600, color:text, letterSpacing:0.4),
        ),
      ]),
    );
  }
}