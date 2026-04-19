import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ScoreMeter extends StatelessWidget {
  final String label;
  final int    value;
  final Color  color;
  final String? suffix;

  const ScoreMeter({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.suffix,
  });

  String get _grade => switch (value) {
    >= 80 => 'Excellent',
    >= 60 => 'Good',
    >= 40 => 'Fair',
    _     => 'Needs work',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
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
            fontFamily: 'Inter', fontSize: 28,
            fontWeight: FontWeight.w800, color: AppColors.textPrimary,
            letterSpacing: -0.8, height: 1.0,
          )),
          if (suffix != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 2),
              child: Text(suffix!, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 12,
                color: AppColors.textTertiary,
              )),
            ),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value:           (value / 100).clamp(0.0, 1.0),
            backgroundColor: AppColors.surface3,
            valueColor:      AlwaysStoppedAnimation(color),
            minHeight:       4,
          ),
        ),
        const SizedBox(height: 5),
        Text(_grade, style: TextStyle(
          fontFamily: 'Inter', fontSize: 10,
          fontWeight: FontWeight.w600, color: color,
        )),
      ]),
    );
  }
}