import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../../../shared/widgets/level_badge.dart';

class LevelUpDialog extends StatefulWidget {
  final String previousLevel;
  final String newLevel;
  final int    bonusXP;
  final VoidCallback onClose;

  const LevelUpDialog({
    super.key,
    required this.previousLevel,
    required this.newLevel,
    required this.bonusXP,
    required this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required String previousLevel,
    required String newLevel,
    int bonusXP = 200,
  }) => showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => LevelUpDialog(
      previousLevel: previousLevel,
      newLevel:      newLevel,
      bonusXP:       bonusXP,
      onClose:       () => Navigator.of(context).pop(),
    ),
  );

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;
  late final Animation<double>    _scale;
  late final Animation<double>    _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.7, end: 1.0));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    // Auto-close after 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) widget.onClose();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  String get _message => switch (widget.newLevel) {
    'intermediate' => 'You\'re getting serious — keep pushing!',
    'advanced'     => 'You\'re in elite territory. Respect.',
    'elite'        => 'You\'ve reached the top. Absolute legend.',
    _              => 'Keep up the amazing work!',
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color:        AppColors.surface1,
              borderRadius: BorderRadius.circular(24),
              border:       Border.all(color: AppColors.border2, width: 0.5),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Star icon
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color:        const Color(0x1AFBBF24),
                  shape:        BoxShape.circle,
                  border:       Border.all(color: const Color(0x33FBBF24), width: 1),
                ),
                child: const Icon(Icons.star_rounded,
                    color: Color(0xFFFBBF24), size: 38),
              ),
              const SizedBox(height: 16),

              const Text('LEVEL UP!', style: TextStyle(
                fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700,
                color: AppColors.textTertiary, letterSpacing: 1.5,
              )),
              const SizedBox(height: 6),

              RichText(text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 24,
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                children: [
                  const TextSpan(text: 'You reached\n'),
                  TextSpan(
                    text: widget.newLevel[0].toUpperCase() +
                          widget.newLevel.substring(1),
                    style: const TextStyle(color: AppColors.lime),
                  ),
                ],
              ), textAlign: TextAlign.center),
              const SizedBox(height: 14),

              // Level transition
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                LevelBadge(level: widget.previousLevel),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: AppColors.textTertiary, size: 16),
                ),
                LevelBadge(level: widget.newLevel),
              ]),
              const SizedBox(height: 12),

              Text(_message, textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  color: AppColors.textSecondary, height: 1.5,
                ),
              ),
              const SizedBox(height: 14),

              // Bonus XP pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:        const Color(0x1AFBBF24),
                  borderRadius: BorderRadius.circular(20),
                  border:       Border.all(color: const Color(0x33FBBF24), width: 0.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFBBF24), size: 14),
                  const SizedBox(width: 6),
                  Text('+${widget.bonusXP} bonus XP awarded',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                      color: Color(0xFFFBBF24),
                    )),
                ]),
              ),
              const SizedBox(height: 20),

              FCButton(
                label:     'Keep training',
                fullWidth: true,
                onPressed: widget.onClose,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}