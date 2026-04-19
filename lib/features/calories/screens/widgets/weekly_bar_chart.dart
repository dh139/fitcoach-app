import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/daily_summary_model.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<WeeklyDayModel> data;
  final String               selectedDate;
  final ValueChanged<String> onDateTap;

  const WeeklyBarChart({
    super.key,
    required this.data,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxCal = data
        .map((d) => d.calories)
        .fold(0, (a, b) => a > b ? a : b);
    final cap    = maxCal < 2000 ? 2000 : maxCal.toDouble();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('7-day overview', style: TextStyle(
        fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      )),
      const SizedBox(height: 10),
      SizedBox(
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((day) {
            final isSelected = day.date == selectedDate;
            final heightPct  = cap > 0 ? day.calories / cap : 0.0;
            final isToday    = day.date ==
                DateTime.now().toIso8601String().substring(0, 10);

            return Expanded(child: GestureDetector(
              onTap: () => onDateTap(day.date),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bar
                  Expanded(child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve:    Curves.easeOut,
                      width:    double.infinity,
                      height:   ((heightPct * 60).clamp(3.0, 60.0)),
                      margin:   const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                          ? AppColors.lime
                          : isToday
                          ? AppColors.limeDim
                          : AppColors.surface3,
                        borderRadius: BorderRadius.circular(5),
                        border: isSelected
                          ? null
                          : isToday
                          ? Border.all(
                              color: AppColors.limeBorder, width: 0.5)
                          : null,
                      ),
                    ),
                  )),
                  const SizedBox(height: 3),
                  // Logged data indicator dot
                  Container(
                    width: 4, height: 4,
                    decoration: BoxDecoration(
                      color: day.calories > 0 
                        ? (isSelected ? AppColors.lime : AppColors.brandPurple)
                        : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Day label
                  Text(
                    day.shortDay,
                    style: TextStyle(
                      fontFamily:  'Inter',
                      fontSize:    10,
                      fontWeight:  isSelected
                          ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.lime : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ));
          }).toList(),
        ),
      ),
    ]);
  }
}