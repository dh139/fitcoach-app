import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/workout_history_model.dart';

class FrequencyBarChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  const FrequencyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const _EmptyChart();

    final maxY = data
        .map((d) => d.value)
        .fold(0.0, (a, b) => a > b ? a : b);
    final yMax = maxY < 4 ? 4.0 : maxY + 1;

return BarChart(
  BarChartData(
    maxY: yMax,
    minY: 0,
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 1,
      getDrawingHorizontalLine: (_) => FlLine(
        color: AppColors.border2,
        strokeWidth: 0.5,
      ),
    ),
    borderData: FlBorderData(show: false),
    titlesData: FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 24,
          getTitlesWidget: (value, _) {
            if (value != value.roundToDouble()) return const SizedBox();
            return Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTitlesWidget: (value, _) {
            final idx = value.toInt();
            if (idx < 0 || idx >= data.length) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                data[idx].label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: AppColors.textTertiary,
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    barGroups: data.asMap().entries.map((entry) {
      final isToday = entry.key == data.length - 1;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value,
            width: 16,
            color: isToday
                ? AppColors.lime
                : AppColors.lime.withOpacity(0.4),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(5),
            ),
          ),
        ],
        showingTooltipIndicators: entry.value.value > 0 ? [0] : [],
      );
    }).toList(),
    barTouchData: BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => AppColors.surface3,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            '${rod.toY.toInt()} workout${rod.toY != 1 ? "s" : ""}',
            const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          );
        },
      ),
    ),
  ),
);
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) => const Center(child: Text(
    'No workout data yet',
    style: TextStyle(
      fontFamily: 'Inter', fontSize: 12,
      color: AppColors.textTertiary,
    ),
  ));
}