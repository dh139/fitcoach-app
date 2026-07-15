import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/workout/providers/workout_provider.dart';

class SessionTimerRing extends StatelessWidget {
  final int  elapsedSeconds;
  final bool isUnlocked;

  const SessionTimerRing({
    super.key,
    required this.elapsedSeconds,
    required this.isUnlocked,
  });

  static const _minSeconds = WorkoutState.minSeconds;

  String _format(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs  % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (elapsedSeconds / _minSeconds).clamp(0.0, 1.0);
    final color    = isUnlocked ? AppColors.lime : AppColors.primary;

    return SizedBox(
      width: 130, height: 130,
      child: Stack(alignment: Alignment.center, children: [
        // Background ring
        SizedBox(
          width: 130, height: 130,
          child: CustomPaint(painter: _RingPainter(
            progress:  progress,
            color:     color,
            bgColor:   AppColors.surface3,
            strokeW:   10,
          )),
        ),

        // Center content
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            _format(elapsedSeconds),
            style: const TextStyle(
              fontFamily:    'Inter',
              fontSize:      26,
              fontWeight:    FontWeight.w800,
              color:         AppColors.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isUnlocked
              ? Row(mainAxisSize: MainAxisSize.min, key: const ValueKey('unlock'), children: [
                  const Icon(Icons.lock_open_rounded,
                      color: AppColors.lime, size: 11),
                  const SizedBox(width: 3),
                  const Text('XP ready', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lime,
                  )),
                ])
              : Text(
                  '${_format(_minSeconds - elapsedSeconds)} left',
                  key: const ValueKey('locked'),
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
          ),
        ]),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color  color;
  final Color  bgColor;
  final double strokeW;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
    required this.strokeW,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = (size.width  / 2) - strokeW / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Background arc
    canvas.drawArc(
      rect, 0, 2 * math.pi, false,
      Paint()
        ..color       = bgColor
        ..strokeWidth = strokeW
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,              // start at top
        2 * math.pi * progress,    // sweep
        false,
        Paint()
          ..color       = color
          ..strokeWidth = strokeW
          ..style       = PaintingStyle.stroke
          ..strokeCap   = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}