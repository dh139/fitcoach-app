import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../providers/calorie_provider.dart';
import 'widgets/add_food_sheet.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/food_log_list.dart';

class CalorieScreen extends ConsumerWidget {
  const CalorieScreen({super.key});

  String _defaultMeal() {
    final h = DateTime.now().hour;
    if (h < 10) return 'breakfast';
    if (h < 14) return 'lunch';
    if (h < 19) return 'dinner';
    return 'snack';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calorieProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(calorieProvider.notifier).loadDay(
                state.selectedDate);
            await ref.read(calorieProvider.notifier).loadWeekly();
          },
          color:           AppColors.lime,
          backgroundColor: AppColors.surface1,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [

              // ── App bar ────────────────────────────────────────────────
              SliverAppBar(
                pinned:          true,
                backgroundColor: AppColors.bg,
                expandedHeight:  0,
                toolbarHeight:   56,
                automaticallyImplyLeading: false,
                title: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color:        const Color(0x1AFF6B00),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.local_fire_department_rounded,
                        color: Color(0xFFFF8C42), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Calorie counter', style: TextStyle(
                    fontFamily:    'Inter',
                    fontSize:      18,
                    fontWeight:    FontWeight.w700,
                    color:         AppColors.textPrimary,
                    letterSpacing: -0.3,
                  )),
                ]),
                actions: [
                  // Add food button
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: () => AddFoodSheet.show(
                        context,
                        defaultMeal: _defaultMeal(),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.lime,
                        foregroundColor: AppColors.bg,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 16),
                          SizedBox(width: 4),
                          Text('Add', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700,
                          )),
                        ],
                      ),
                    ),
                  ),
                  // Today entries count
                  if (state.entries.isNotEmpty)
                    Center(child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:        AppColors.surface2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border3, width: 0.5),
                      ),
                      child: Text(
                        '${state.entries.length} items',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                ],
              ),

              // ── Content ────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pageHPad, 8,
                  AppConstants.pageHPad, 100,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // Daily summary card (donut + week chart)
                    const DailySummaryCard(),
                    const SizedBox(height: 20),

                    // Food log header
                    Row(children: [
                      Text(
                        state.isToday ? "Today's log" : 'Log for ${state.selectedDate}',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (state.entries.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text('(${state.entries.length})', style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 12,
                          color: AppColors.textTertiary,
                        )),
                      ],
                    ]),
                    const SizedBox(height: 10),

                    // Food list
                    const FoodLogList(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}