import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

enum FCButtonVariant { primary, secondary, ghost, danger }
enum FCButtonSize { sm, md, lg }

/// Premium FCButton with a smooth dot-pulse loader instead of a raw spinner.
class FCButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading, fullWidth;
  final FCButtonVariant variant;
  final FCButtonSize size;
  final Widget? leading, trailing;

  const FCButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.variant = FCButtonVariant.primary,
    this.size = FCButtonSize.md,
    this.leading,
    this.trailing,
  });

  @override
  State<FCButton> createState() => _FCButtonState();
}

class _FCButtonState extends State<FCButton> with TickerProviderStateMixin {
  late final AnimationController _d1, _d2, _d3;

  @override
  void initState() {
    super.initState();
    _d1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 540))
      ..repeat(reverse: true);
    _d2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 540))
      ..repeat(reverse: true);
    _d3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 540))
      ..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _d2.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _d3.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _d1.dispose();
    _d2.dispose();
    _d3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bg, fg, border;
    EdgeInsets padding;
    double fontSize;

    switch (widget.variant) {
      case FCButtonVariant.primary:
        // Signature lime pill — deep-forest label on electric lime.
        bg = AppColors.lime;
        fg = AppColors.onLime;
        border = Colors.transparent;
      case FCButtonVariant.secondary:
        bg = Colors.transparent;
        fg = AppColors.textPrimary;
        border = AppColors.border2;
      case FCButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textSecondary;
        border = Colors.transparent;
      case FCButtonVariant.danger:
        bg = AppColors.danger;
        fg = Colors.white;
        border = Colors.transparent;
    }

    switch (widget.size) {
      case FCButtonSize.sm:
        padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
        fontSize = 12;
      case FCButtonSize.md:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
        fontSize = 13;
      case FCButtonSize.lg:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
        fontSize = 15;
    }

    final isDisabled = widget.onPressed == null || widget.loading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: isDisabled ? bg.withAlpha((0.6 * 255).toInt()) : bg,
        borderRadius: BorderRadius.circular(AppConstants.btnRadius),
        border: Border.all(color: border, width: 1),
        boxShadow: !isDisabled && widget.variant == FCButtonVariant.primary
            ? [BoxShadow(color: AppColors.lime.withAlpha(110), blurRadius: 20, offset: const Offset(0, 8))]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(AppConstants.btnRadius),
          child: Padding(
            padding: padding,
            child: widget.loading
                ? Center(child: _DotPulse(color: fg))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 8)],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (widget.trailing != null) ...[const SizedBox(width: 8), widget.trailing!],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Three bouncing dots loading animation — elegant, compact, on-brand.
class _DotPulse extends StatefulWidget {
  final Color color;
  const _DotPulse({required this.color});

  @override
  State<_DotPulse> createState() => _DotPulseState();
}

class _DotPulseState extends State<_DotPulse> with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    ));
    _anims = _ctrls.map((c) => Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: c, curve: Curves.easeInOut),
    )).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 140), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 20,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) => AnimatedBuilder(
        animation: _anims[i],
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _anims[i].value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      )),
    ),
  );
}
