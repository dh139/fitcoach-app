import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/calorie_provider.dart';
import 'macro_donut_ring.dart';
import 'weekly_bar_chart.dart';

class DailySummaryCard extends ConsumerWidget {
  const DailySummaryCard({super.key});

  String _formatDate(String date) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final yest  = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);
    if (date == today) return 'Today';
    if (date == yest)  return 'Yesterday';
    final d = DateTime.tryParse(date);
    if (d == null) return date;
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calorieProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Column(children: [
        // ── Date navigation ──────────────────────────────────────────────────
        Row(children: [
          GestureDetector(
            onTap: () => ref.read(calorieProvider.notifier).goBack(),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color:        AppColors.surface2,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),
          Expanded(child: Column(children: [
            Text(
              _formatDate(state.selectedDate),
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(state.selectedDate, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 10,
              color: AppColors.textTertiary,
            )),
          ])),
          GestureDetector(
            onTap: state.isToday
                ? null
                : () => ref.read(calorieProvider.notifier).goForward(),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color:        state.isToday
                    ? AppColors.surface1
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(Icons.chevron_right_rounded,
                color: state.isToday
                    ? AppColors.surface3
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // ── Macro donut ──────────────────────────────────────────────────────
        MacroDonutRing(totals: state.totals),

        // ── Fiber strip ──────────────────────────────────────────────────────
        if (state.totals.fiber > 0) ...[
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border2),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.grass_rounded,
                color: Color(0xFF4ADE80), size: 14),
            const SizedBox(width: 6),
            const Text('Fiber', style: TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              color: AppColors.textSecondary,
            )),
            const Spacer(),
            Text('${state.totals.fiber.round()}g', style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            )),
          ]),
        ],

        // ── 7-day chart ──────────────────────────────────────────────────────
        if (state.weekly.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border2),
          const SizedBox(height: 14),
          WeeklyBarChart(
            data:         state.weekly,
            selectedDate: state.selectedDate,
            onDateTap:    (d) =>
                ref.read(calorieProvider.notifier).goToDate(d),
          ),
        ],
      ]),
    );
  }
}