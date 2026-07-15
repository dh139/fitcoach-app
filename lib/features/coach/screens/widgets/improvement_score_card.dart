import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/improvement_score_model.dart';

class ImprovementScoreCard extends StatelessWidget {
  final ImprovementScoreModel data;

  const ImprovementScoreCard({super.key, required this.data});

  String get _grade => switch (data.composite) {
    >= 80 => 'Excellent',
    >= 60 => 'Good',
    >= 40 => 'Fair',
    _     => 'Needs work',
  };

  Color get _gradeColor => switch (data.composite) {
    >= 80 => AppColors.lime,
    >= 60 => AppColors.accent5,
    >= 40 => AppColors.warn,
    _     => AppColors.danger,
  };

  static const _pillarColors = {
    'weightProgress':   Color(0xFFFB7185),
    'consistency':      AppColors.lime,
    'strengthIncrease': AppColors.accent5,
    'dietAdherence':    Color(0xFFF59E0B),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(18),
        border:       Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          // Composite ring
          SizedBox(
            width: 64, height: 64,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(
                size: const Size(64, 64),
                painter: _ScoreRingPainter(
                  score: data.composite,
                  color: _gradeColor,
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${data.composite}', style: const TextStyle(
                  fontFamily:    'Inter',
                  fontSize:      17,
                  fontWeight:    FontWeight.w800,
                  color:         AppColors.textPrimary,
                  letterSpacing: -0.5,
                  height:        1.0,
                )),
              ]),
            ]),
          ),
          const SizedBox(width: 14),
      
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('IMPROVEMENT SCORE', style: TextStyle(
                fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
                color: AppColors.textTertiary, letterSpacing: 0.9,
              )),
              const SizedBox(height: 3),
              Text(_grade, style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    16,
                fontWeight:  FontWeight.w700,
                color:       _gradeColor,
                letterSpacing: -0.3,
              )),
              const SizedBox(height: 2),
              const Text('Last 30 days', style: TextStyle(
                fontFamily: 'Inter', fontSize: 10,
                color: AppColors.textTertiary,
              )),
            ],
          )),
        ]),
        const SizedBox(height: 14),
        const Divider(height: 1, color: AppColors.border2),
        const SizedBox(height: 12),
      
        // Pillar bars
        ...ImprovementScoreModel.pillars.map((key) {
          final pillar = data.breakdown[key];
          if (pillar == null) return const SizedBox.shrink();
          final val    = pillar.score;
          final color  = _pillarColors[key] ?? AppColors.textTertiary;
          final label  = ImprovementScoreModel.pillarLabels[key] ?? key;
          final weight = ImprovementScoreModel.pillarWeights[key] ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(
                    children: [
                      Text(label, style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                      const SizedBox(width: 6),
                      Text('($weight)', style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 9,
                        color: AppColors.textTertiary,
                      )),
                    ],
                  ),
                  Text('$val/100', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           val / 100,
                    backgroundColor: AppColors.surface3,
                    valueColor:      AlwaysStoppedAnimation(color),
                    minHeight:       4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(pillar.detail, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 9,
                  color: AppColors.textTertiary,
                )),
              ]),
          );
        }),
      ]),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final int   score;
  final Color color;
  const _ScoreRingPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx   = size.width  / 2;
    final cy   = size.height / 2;
    final r    = (size.width / 2) - 5;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final base = Paint()
      ..color       = AppColors.surface3
      ..strokeWidth = 7
      ..style       = PaintingStyle.stroke;
    final fill = Paint()
      ..color       = color
      ..strokeWidth = 7
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * math.pi, false, base);
    if (score > 0) {
      canvas.drawArc(
        rect, -math.pi / 2,
        2 * math.pi * (score / 100), false, fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.score != score;
}