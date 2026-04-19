import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';

enum FCButtonVariant { primary, secondary, ghost, danger }
enum FCButtonSize    { sm, md, lg }

class FCButton extends StatefulWidget {
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
  State<FCButton> createState() => _FCButtonState();
}

class _FCButtonState extends State<FCButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    bool isDisabled = widget.onPressed == null || widget.loading;

    final (bg, fg, border, glowColor) = switch (widget.variant) {
      FCButtonVariant.primary   => (AppColors.lime,    AppColors.bg,            Colors.transparent, AppColors.lime.withOpacity(0.3)),
      FCButtonVariant.secondary => (AppColors.surface2, AppColors.textPrimary,  AppColors.border3,  Colors.transparent),
      FCButtonVariant.ghost     => (Colors.transparent, AppColors.textSecondary, Colors.transparent, Colors.transparent),
      FCButtonVariant.danger    => (AppColors.dangerDim, AppColors.danger,       AppColors.dangerBorder, AppColors.danger.withOpacity(0.3)),
    };

    final (vPad, hPad, textStyle) = switch (widget.size) {
      FCButtonSize.sm => (8.0,  14.0, AppTextStyles.label.copyWith(color: fg)),
      FCButtonSize.md => (12.0, 20.0, AppTextStyles.h4.copyWith(color: fg)),
      FCButtonSize.lg => (15.0, 26.0, AppTextStyles.h3.copyWith(color: fg)),
    };

    final content = widget.loading
      ? SizedBox(width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: fg))
      : Row(
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 8)],
            Text(widget.label, style: textStyle),
            if (widget.trailing != null) ...[const SizedBox(width: 8), widget.trailing!],
          ],
        );

    final btn = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp:   isDisabled ? null : (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.loading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
          decoration: BoxDecoration(
            color:        _isHovered && widget.variant == FCButtonVariant.primary ? AppColors.limeHover : bg,
            borderRadius: BorderRadius.circular(AppConstants.btnRadius),
            border:       Border.all(color: border, width: 1.0),
            boxShadow: [
              if (_isHovered && widget.variant != FCButtonVariant.ghost && !isDisabled)
                BoxShadow(
                  color: glowColor,
                  blurRadius: 12,
                  spreadRadius: 2,
                )
            ]
          ),
          transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
          transformAlignment: Alignment.center,
          child: content,
        ),
      ),
    );

    return widget.fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}