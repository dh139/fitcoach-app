import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_button.dart';

class ChallengeClaimed extends StatefulWidget {
  final int          xpEarned;
  final String       message;
  final VoidCallback onClose;

  const ChallengeClaimed({
    super.key,
    required this.xpEarned,
    required this.message,
    required this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required int    xpEarned,
    required String message,
  }) => showDialog(
    context:     context,
    barrierColor: Colors.black87,
    builder: (ctx) => ChallengeClaimed(
      xpEarned: xpEarned,
      message:  message,
      onClose:  () => Navigator.pop(ctx),
    ),
  );

  @override
  State<ChallengeClaimed> createState() => _ChallengeClaimedState();
}

class _ChallengeClaimedState extends State<ChallengeClaimed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _scale;
  late final Animation<double>    _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.7, end: 1.0));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: FadeTransition(
      opacity: _fade,
      child:   ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color:        AppColors.surface1,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.limeBorder, width: 0.5),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 68, height: 68,
              decoration: BoxDecoration(
                color:        AppColors.limeDim,
                shape:        BoxShape.circle,
                border: Border.all(color: AppColors.limeBorder, width: 1),
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: AppColors.lime, size: 34),
            ),
            const SizedBox(height: 14),
            const Text('Challenge complete!', style: TextStyle(
              fontFamily:  'Inter', fontSize: 10, fontWeight: FontWeight.w700,
              color: AppColors.textTertiary, letterSpacing: 1.2,
            )),
            const SizedBox(height: 6),
            Text(widget.message, textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, letterSpacing: -0.3, height: 1.2,
              )),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color:        AppColors.limeDim,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.limeBorder, width: 0.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.bolt_rounded,
                    color: AppColors.lime, size: 15),
                const SizedBox(width: 5),
                Text('+${widget.xpEarned} XP awarded',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w700, color: AppColors.lime,
                  )),
              ]),
            ),
            const SizedBox(height: 20),
            FCButton(
              label:     'Awesome!',
              fullWidth: true,
              onPressed: widget.onClose,
            ),
          ]),
        ),
      ),
    ),
  );
}