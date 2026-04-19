import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/workout_history_model.dart';

class CalorieLineChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  const CalorieLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text(
        'No calorie data yet',
        style: TextStyle(
          fontFamily: 'Inter', fontSize: 12,
          color: AppColors.textTertiary,
        ),
      ));
    }

    final maxY = data
        .map((d) => d.value)
        .fold(0.0, (a, b) => a > b ? a : b);
    final yMax = maxY < 100 ? 200.0 : maxY * 1.2;

    const lineColor   = Color(0xFFFF8C42);
    const dotColor    = Color(0xFFFF8C42);

    final lineBar = LineChartBarData(
      spots: data.asMap().entries
          .map((e) => FlSpot(
                e.key.toDouble(), e.value.value))
          .toList(),
      isCurved:           true,
      curveSmoothness:    0.3,
      color:              lineColor,
      barWidth:           2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, __, ___) =>
            FlDotCirclePainter(
              radius:         3,
              color:          spot.y > 0
                  ? dotColor : Colors.transparent,
              strokeWidth:    0,
              strokeColor:    Colors.transparent,
            ),
      ),
      belowBarData: BarAreaData(
        show:  true,
        color: lineColor.withOpacity(0.08),
      ),
    );

    return LineChart(
      LineChartData(
        minY:     0,
        maxY:     yMax,
        showingTooltipIndicators: data.asMap().entries
            .where((e) => e.value.value > 0)
            .map((e) => ShowingTooltipIndicators([
                  LineBarSpot(lineBar, 0, lineBar.spots[e.key])
                ]))
            .toList(),
        gridData: FlGridData(
          show:             true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color:       AppColors.border2,
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:   true,
              reservedSize: 36,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox();
                return Text(
                  value >= 1000
                      ? '${(value / 1000).toStringAsFixed(1)}k'
                      : value.toInt().toString(),
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 9,
                    color: AppColors.textTertiary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles:   true,
              reservedSize: 22,
              interval:     2,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length ||
                    idx % 2 != 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    data[idx].label,
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 9,
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:   const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [lineBar],
        lineTouchData: LineTouchData(
          enabled: false,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.only(bottom: 2),
            getTooltipItems: (spots) => spots.map((s) =>
                LineTooltipItem(
                  '${s.y.toInt()}',
                  const TextStyle(
                    fontFamily: 'Inter', fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: lineColor,
                  ),
                )).toList(),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
      curve:    Curves.easeOut,
    );
  }
}