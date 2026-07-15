import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CustomPaint(
            painter: _TinyLogoPainter(),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'FitCoach',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'AI',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TinyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.22;
    const shift = 4.0;

    paint.shader = const LinearGradient(
      colors: [AppColors.primary, Color(0xFF6B8EFF)],
    ).createShader(Rect.fromCircle(center: center.translate(-shift, 0), radius: radius));
    canvas.drawCircle(center.translate(-shift, 0), radius, paint);

    paint.shader = const LinearGradient(
      colors: [AppColors.accent2, Color(0xFFFF9E7C)],
    ).createShader(Rect.fromCircle(center: center.translate(shift, 0), radius: radius));
    canvas.drawCircle(center.translate(shift, 0), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}