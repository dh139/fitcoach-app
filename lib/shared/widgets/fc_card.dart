import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

enum FCButtonVariant { primary, secondary, ghost, danger }
enum FCButtonSize    { sm, md, lg }

class FCButton extends StatelessWidget {
  final String        label;
  final VoidCallback? onPressed;
  final FCButtonVariant variant;
  final FCButtonSize    size;
  final Widget?       leading;
  final Widget?       trailing;
  final bool          loading;
  final bool          fullWidth;

  const FCButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant  = FCButtonVariant.primary,
    this.size     = FCButtonSize.md,
    this.leading,
    this.trailing,
    this.loading  = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      FCButtonVariant.primary   => (AppColors.lime,    AppColors.bg,            Colors.transparent),
      FCButtonVariant.secondary => (Colors.transparent, AppColors.textPrimary,  AppColors.border3),
      FCButtonVariant.ghost     => (Colors.transparent, AppColors.textSecondary, AppColors.border3),
      FCButtonVariant.danger    => (AppColors.dangerDim, AppColors.danger,       AppColors.dangerBorder),
    };

    final (vPad, hPad, fontSize) = switch (size) {
      FCButtonSize.sm => (8.0,  14.0, 12.0),
      FCButtonSize.md => (12.0, 20.0, 13.0),
      FCButtonSize.lg => (15.0, 26.0, 15.0),
    };

    final content = loading
      ? SizedBox(width: fontSize + 2, height: fontSize + 2,
          child: CircularProgressIndicator(strokeWidth: 2, color: fg))
      : Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(label, style: TextStyle(
              fontFamily: 'Inter', fontSize: fontSize,
              fontWeight: FontWeight.w700, color: fg, letterSpacing: 0.2,
            )),
            if (trailing != null) ...[const SizedBox(width: 6), trailing!],
          ],
        );

    final btn = GestureDetector(
      onTap: loading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(AppConstants.btnRadius),
          border:       Border.all(color: border, width: 0.5),
        ),
        child: content,
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}