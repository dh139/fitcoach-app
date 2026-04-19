import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum FCBadgeVariant { lime, red, amber, blue, purple, gray }

class FCBadge extends StatelessWidget {
  final String        label;
  final FCBadgeVariant variant;
  final double        fontSize;

  const FCBadge({
    super.key,
    required this.label,
    this.variant  = FCBadgeVariant.lime,
    this.fontSize = 10,
  });

  (Color, Color, Color) get _colors => switch (variant) {
    FCBadgeVariant.lime   => (AppColors.limeDim,    AppColors.lime,          AppColors.limeBorder),
    FCBadgeVariant.red    => (AppColors.dangerDim,   AppColors.danger,        AppColors.dangerBorder),
    FCBadgeVariant.amber  => (AppColors.warnDim,     AppColors.warn,          const Color(0x33F59E0B)),
    FCBadgeVariant.blue   => (AppColors.infoDim,     AppColors.info,          const Color(0x333B82F6)),
    FCBadgeVariant.purple => (AppColors.coachDim,    AppColors.coach,         AppColors.coachBorder),
    FCBadgeVariant.gray   => (AppColors.surface2,    AppColors.textSecondary, AppColors.border3),
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
      child: Text(label, style: TextStyle(
        fontFamily: 'Inter',
        fontSize:   fontSize,
        fontWeight: FontWeight.w600,
        color:      text,
        letterSpacing: 0.3,
      )),
    );
  }
}