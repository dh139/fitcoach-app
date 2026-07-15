import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class FCCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final Gradient? borderGradient;
  final VoidCallback? onTap;

  const FCCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.0,
    this.gradient,
    this.borderGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppConstants.cardRadius;

    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.surface1) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius - borderWidth),
      ),
      child: child,
    );

    Widget decoratedCard;
    if (borderGradient != null) {
      decoratedCard = Container(
        margin: margin,
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          gradient: borderGradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - borderWidth),
          child: cardContent,
        ),
      );
    } else {
      decoratedCard = Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor ?? AppColors.slate,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: cardContent,
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: decoratedCard,
      );
    }
    return decoratedCard;
  }
}