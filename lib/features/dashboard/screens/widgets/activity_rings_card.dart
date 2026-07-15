import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:fl_chart/fl_chart.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:intl/intl.dart";
import "../../../../core/constants/app_colors.dart";
import "../../../../core/constants/app_constants.dart";
import "../../providers/step_provider.dart";
import "../../../calories/providers/calorie_provider.dart";
import "../../../history/providers/history_provider.dart";

class ActivityRingsCard extends ConsumerStatefulWidget {
  const ActivityRingsCard({super.key});
  @override
  ConsumerState<ActivityRingsCard> createState() => _ActivityRingsCardState();
}

class _ActivityRingsCardState extends ConsumerState<ActivityRingsCard> {
  List<int> _weeklySteps = [];
  bool _isLoadingChart = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklySteps();
  }

  Future<void> _loadWeeklySteps() async {
    final steps = await ref.read(stepProvider.notifier).getWeeklySteps();
    if (mounted) {
      setState(() {
        _weeklySteps = steps;
        _isLoadingChart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final stepState = ref.watch(stepProvider);
      final histState = ref.watch(historyProvider);

      final steps = stepState.stepsToday;
      final stepTarget = stepState.targetSteps > 0 ? stepState.targetSteps : 10000;
      final stepPct = (steps / stepTarget).clamp(0.0, 1.0);
      final today = DateTime.now();

      final workoutsToday = histState.workouts.where((w) {
        final c = w.completedDateTime;
        return c != null && c.year == today.year && c.month == today.month && c.day == today.day;
      }).toList();

      final stepCals = (steps * 0.04).toInt();
      final workoutCals = workoutsToday.fold<int>(0, (s, w) => s + w.totalCaloriesBurned);
      final activeCals = stepCals + workoutCals;
      final calPct = (activeCals / 500).clamp(0.0, 1.0);
      final mins = workoutsToday.fold<int>(0, (s, w) => s + (w.durationSeconds ~/ 60));
      final minPct = (mins / 45).clamp(0.0, 1.0);

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: AppColors.slate, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.trending_up_rounded, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Activity",
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRing("Steps", "$steps", stepPct, AppColors.kineticGreen, Icons.directions_walk_rounded),
                _buildRing("Calories", "$activeCals", calPct, AppColors.warningAccent, Icons.local_fire_department_rounded),
                _buildRing("Minutes", "$mins", minPct, AppColors.premiumAccent, Icons.timer_rounded),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              "Last 7 Days",
              style: TextStyle(
                fontFamily: "Outfit",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: _isLoadingChart
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _buildBarChart(_weeklySteps, stepTarget),
            ),
          ],
        ),
      ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildRing(String label, String val, double pct, Color color, IconData icon) {
    return Column(
      children: [
        SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                color: color.withOpacity(0.1),
              ),
              CircularProgressIndicator(
                value: pct,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                color: color,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(height: 1),
                    Text(
                      val,
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: "PlusJakartaSans",
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<int> weekly, int target) {
    if (weekly.length < 7) {
      weekly = List.filled(7 - weekly.length, 0) + weekly;
    }
    final maxVal = ((weekly.reduce((a, b) => a > b ? a : b) + 2000) / 1000).ceil() * 1000.0;
    final topBound = maxVal < target ? target.toDouble() : maxVal;
    final today = DateTime.now();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: topBound,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (g, i, rod, j) => BarTooltipItem(
              "${rod.toY.round()} steps",
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = today.subtract(Duration(days: 6 - value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat("E").format(date),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          7,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: weekly[i].toDouble(),
                color: i == 6 ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
      swapAnimationCurve: Curves.easeOut,
      swapAnimationDuration: const Duration(milliseconds: 800),
    );
  }
}
