import "package:flutter/material.dart";
import "../../core/constants/app_colors.dart";

enum FCBadgeVariant { lime, red, amber, blue, purple, gray }

class FCBadge extends StatelessWidget {
  final String label;
  final FCBadgeVariant variant;
  const FCBadge({super.key, required this.label, this.variant = FCBadgeVariant.lime});

  @override
  Widget build(BuildContext context) {
    Color bg, text, border;
    switch (variant) {
      case FCBadgeVariant.lime: bg = AppColors.primaryDim; text = AppColors.primary; border = AppColors.primaryLight;
      case FCBadgeVariant.red: bg = AppColors.dangerDim; text = AppColors.danger; border = AppColors.dangerBorder;
      case FCBadgeVariant.amber: bg = AppColors.accent4Dim; text = AppColors.accent4; border = AppColors.accent4Light;
      case FCBadgeVariant.blue: bg = AppColors.infoDim; text = AppColors.info; border = AppColors.accent5Light;
      case FCBadgeVariant.purple: bg = AppColors.primaryDim; text = AppColors.primary; border = AppColors.primaryLight;
      case FCBadgeVariant.gray: bg = AppColors.surface3; text = AppColors.textSecondary; border = AppColors.border2;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: border, width: 0.5)),
      child: Text(label.toUpperCase(), style: TextStyle(fontFamily: "Inter", fontSize: 9, fontWeight: FontWeight.w700, color: text, letterSpacing: 0.3)),
    );
  }
}
