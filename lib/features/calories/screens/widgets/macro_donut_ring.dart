import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/daily_summary_model.dart';

class MacroDonutRing extends StatelessWidget {
  final MacroTotals totals;
  final int         goal;

  const MacroDonutRing({
    super.key,
    required this.totals,
    this.goal = 2000,
  });

  static const _protein = AppColors.accent5;
  static const _carbs   = Color(0xFF22C55E);
  static const _fat     = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final total = totals.protein + totals.carbs + totals.fat;
    final pPct  = total > 0 ? totals.protein / total : 0.0;
    final cPct  = total > 0 ? totals.carbs   / total : 0.0;
    final fPct  = total > 0 ? totals.fat     / total : 0.0;
    final goalP = (totals.calories / goal).clamp(0.0, 1.0);

    return Row(children: [
      // Donut
      SizedBox(
        width: 110, height: 110,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(
            size: const Size(110, 110),
            painter: _DonutPainter(
              proteinPct: pPct,
              carbsPct:   cPct,
              fatPct:     fPct,
              hasData:    total > 0,
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              '${totals.calories}',
              style: const TextStyle(
                fontFamily:    'Inter',
                fontSize:      20,
                fontWeight:    FontWeight.w800,
                color:         AppColors.textPrimary,
                letterSpacing: -0.5,
                height:        1.0,
              ),
            ),
            const Text('kcal', style: TextStyle(
              fontFamily: 'Inter', fontSize: 10,
              color: AppColors.textTertiary,
            )),
          ]),
        ]),
      ),
      const SizedBox(width: 16),

      // Right panel
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal bar
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Daily goal', style: TextStyle(
                fontFamily: 'Inter', fontSize: 10,
                color: AppColors.textTertiary,
              )),
              const Spacer(),
              Text('$goal kcal', style: const TextStyle(
                fontFamily: 'Inter', fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              )),
            ]),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value:          goalP,
                backgroundColor: AppColors.surface3,
                valueColor: AlwaysStoppedAnimation(
                  goalP >= 1.0 ? AppColors.danger
                  : goalP >= 0.8 ? AppColors.warn
                  : AppColors.lime,
                ),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${totals.calories} / $goal kcal',
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Macro rows
          _MacroRow('Protein', totals.protein, _protein),
          const SizedBox(height: 6),
          _MacroRow('Carbs',   totals.carbs,   _carbs),
          const SizedBox(height: 6),
          _MacroRow('Fat',     totals.fat,     _fat),
        ],
      )),
    ]);
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double value;
  final Color  color;
  const _MacroRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 6, height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
    const SizedBox(width: 7),
    Text(label, style: const TextStyle(
      fontFamily: 'Inter', fontSize: 11, color: AppColors.textSecondary,
    )),
    const Spacer(),
    Text('${value.round()}g', style: const TextStyle(
      fontFamily: 'Inter', fontSize: 11,
      fontWeight: FontWeight.w600, color: AppColors.textPrimary,
    )),
  ]);
}

class _DonutPainter extends CustomPainter {
  final double proteinPct;
  final double carbsPct;
  final double fatPct;
  final bool   hasData;

  const _DonutPainter({
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
    required this.hasData,
  });

  static const strokeW = 12.0;
  static const gap     = 0.04; // gap between segments in radians

  @override
  void paint(Canvas canvas, Size size) {
    final cx   = size.width  / 2;
    final cy   = size.height / 2;
    final r    = (size.width  / 2) - strokeW / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final paint = Paint()
      ..strokeWidth = strokeW
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    if (!hasData) {
      canvas.drawArc(rect, 0, 2 * math.pi, false,
        paint..color = AppColors.surface3);
      return;
    }

    final total = 2 * math.pi;
    double start = -math.pi / 2;

    void drawArc(double pct, Color color) {
      final sweep = (pct * total - gap).clamp(0.0, total);
      if (sweep > 0) {
        canvas.drawArc(rect, start, sweep, false, paint..color = color);
        start += pct * total;
      }
    }

    drawArc(proteinPct, AppColors.accent5);
    drawArc(carbsPct,   const Color(0xFF22C55E));
    drawArc(fatPct,     const Color(0xFFF59E0B));
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.proteinPct != proteinPct ||
      old.carbsPct   != carbsPct   ||
      old.fatPct     != fatPct;
}