import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../dashboard/providers/step_provider.dart';
import '../providers/calorie_provider.dart';
import 'widgets/add_food_sheet.dart';
import 'widgets/food_log_list.dart';
import 'widgets/weekly_bar_chart.dart';

class CalorieScreen extends ConsumerStatefulWidget {
  const CalorieScreen({super.key});

  @override
  ConsumerState<CalorieScreen> createState() => _CalorieScreenState();
}

class _CalorieScreenState extends ConsumerState<CalorieScreen> {
  bool _showFoodLogs = true;
  String? _aiAdvice;
  bool _aiAdviceLoading = false;

  String _defaultMeal() {
    final h = DateTime.now().hour;
    if (h < 10) return 'breakfast';
    if (h < 14) return 'lunch';
    if (h < 19) return 'dinner';
    return 'snack';
  }

  Future<void> _fetchAiAdvice() async {
    final entries = ref.read(calorieProvider).entries;
    if (entries.isEmpty) {
      setState(() => _aiAdvice = 'No food logged yet today. Start by adding a meal to get personalised nutrition advice!');
      return;
    }
    setState(() { _aiAdviceLoading = true; _aiAdvice = null; });
    try {
      final summary = entries.map((e) =>
        '${e.name} (${e.calories} kcal, P:${e.protein.round()}g C:${e.carbs.round()}g F:${e.fat.round()}g)'
      ).join(', ');
      final totalCals = entries.fold<int>(0, (s, e) => s + e.calories);
      final totalProtein = entries.fold<double>(0, (s, e) => s + e.protein);
      final totalCarbs = entries.fold<double>(0, (s, e) => s + e.carbs);
      final totalFat = entries.fold<double>(0, (s, e) => s + e.fat);
      // Build a simple advice string from the data (no API call needed — purely local logic)
      final advice = _buildLocalAdvice(
        totalCals: totalCals,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        itemCount: entries.length,
        summary: summary,
      );
      if (mounted) setState(() { _aiAdvice = advice; _aiAdviceLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _aiAdvice = 'Could not generate advice. Try again later.'; _aiAdviceLoading = false; });
    }
  }

  String _buildLocalAdvice({
    required int totalCals,
    required double protein,
    required double carbs,
    required double fat,
    required int itemCount,
    required String summary,
  }) {
    final tips = <String>[];
    const targetCals = 2000;
    const targetProtein = 120.0;
    const targetCarbs = 250.0;
    const targetFat = 65.0;

    if (totalCals > targetCals * 1.1) {
      tips.add('⚠️ You\'re ${totalCals - targetCals} kcal over your daily target. Consider lighter meals for the rest of the day.');
    } else if (totalCals < targetCals * 0.6) {
      tips.add('📉 You\'ve only consumed ${totalCals} kcal today. Make sure to eat enough to fuel your workouts.');
    } else {
      tips.add('✅ You\'re tracking well at ${totalCals} kcal — within a healthy range of your ${targetCals} kcal goal.');
    }

    if (protein < targetProtein * 0.7) {
      tips.add('🥩 Protein intake looks low (${protein.round()}g). Aim for ${targetProtein.round()}g/day — try adding chicken, eggs, or legumes.');
    } else {
      tips.add('💪 Great protein intake at ${protein.round()}g. Keep it up to support muscle recovery!');
    }

    if (fat > targetFat * 1.3) {
      tips.add('🧈 Fat intake is high (${fat.round()}g). Try reducing fried foods or heavy sauces.');
    }

    if (carbs > targetCarbs * 1.2) {
      tips.add('🍞 Carb intake is elevated (${carbs.round()}g). Consider swapping refined carbs for whole grains or vegetables.');
    }

    if (itemCount >= 3) {
      tips.add('🍽️ Good meal variety with ${itemCount} food items logged today!');
    }

    return tips.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final calorieState = ref.watch(calorieProvider);
    final stepState = ref.watch(stepProvider);
    final user = ref.watch(currentUserProvider);

    final steps = stepState.stepsToday;
    final distanceMeters = (steps * 0.75).toInt();
    
    // Calorie metrics from state
    final caloriesConsumed = calorieState.totals.calories;
    const targetCalories = 2000;
    final weeklyPerformancePct = targetCalories > 0 
        ? (caloriesConsumed / targetCalories).clamp(0.0, 1.0) 
        : 0.3;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(calorieProvider.notifier).loadDay(calorieState.selectedDate);
            await ref.read(calorieProvider.notifier).loadWeekly();
          },
          color: AppColors.coach,
          backgroundColor: AppColors.surface1,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Statistics Header ─────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.bg,
                surfaceTintColor: AppColors.bg,
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 60,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    // Back arrow icon
                    GestureDetector(
                      onTap: () => context.go('/dashboard'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface1,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.slate, width: 1.0),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_left_rounded,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // User Profile Avatar on Right
               
                  ],
                ),
              ),

              // ── Main Content ──────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppConstants.pageHPad, 16, AppConstants.pageHPad, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // 1. Total Kilocalories Display
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "$caloriesConsumed Kcal",
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Total Kilocalories",
                            style: TextStyle(
                              fontFamily: "PlusJakartaSans",
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 2. Weekly Performance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A80E6), // Deep blue card
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A80E6).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Weekly Performance",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Today's calorie goal progress",
                                  style: TextStyle(
                                    fontFamily: "PlusJakartaSans",
                                    fontSize: 12,
                                    color: Colors.white.withAlpha(200),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "$caloriesConsumed / $targetCalories kcal",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withAlpha(220),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Circular Progress Ring
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 6,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                                CircularProgressIndicator(
                                  value: weeklyPerformancePct,
                                  strokeWidth: 6,
                                  strokeCap: StrokeCap.round,
                                  color: Colors.white,
                                ),
                                Center(
                                  child: Text(
                                    "${(weeklyPerformancePct * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontFamily: "Outfit",
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── AI Nutritional Advice Card ────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1B2E), Color(0xFF0F1629)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(30),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.psychology_rounded, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('AI Nutrition Advisor', style: TextStyle(
                                  fontFamily: 'Outfit', fontSize: 15,
                                  fontWeight: FontWeight.w700, color: Colors.white,
                                )),
                                Text('Personalized advice based on today\'s meals', style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 11,
                                  color: Colors.white38,
                                )),
                              ]),
                            ),
                          ]),
                          const SizedBox(height: 14),
                          if (_aiAdvice == null && !_aiAdviceLoading)
                            GestureDetector(
                              onTap: _fetchAiAdvice,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primary.withAlpha(60), width: 0.5),
                                ),
                                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
                                  SizedBox(width: 8),
                                  Text('Analyse my nutrition', style: TextStyle(
                                    fontFamily: 'Outfit', fontSize: 14,
                                    fontWeight: FontWeight.w600, color: AppColors.primary,
                                  )),
                                ]),
                              ),
                            )
                          else if (_aiAdviceLoading)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                            ))
                          else if (_aiAdvice != null)
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              ..._aiAdvice!.split('\n\n').map((tip) => tip.trim()).where((t) => t.isNotEmpty).map((tip) =>
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(tip, style: const TextStyle(
                                      fontFamily: 'Inter', fontSize: 13,
                                      color: Colors.white70, height: 1.5,
                                    )),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _fetchAiAdvice,
                                child: const Row(children: [
                                  Icon(Icons.refresh_rounded, color: Colors.white38, size: 14),
                                  SizedBox(width: 6),
                                  Text('Refresh advice', style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 11,
                                    color: Colors.white38,
                                  )),
                                ]),
                              ),
                            ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface1,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.slate, width: 1.0),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WeeklyBarChart(
                            data: calorieState.weekly,
                            selectedDate: calorieState.selectedDate,
                            onDateTap: (date) {
                              ref.read(calorieProvider.notifier).goToDate(date);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6. Food entries collapsible card (Maintains functional requirements)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface1,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.slate, width: 1.0),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            title: const Text(
                              "Meal Logger",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              "${calorieState.entries.length} items logged",
                              style: const TextStyle(
                                fontFamily: "PlusJakartaSans",
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Add food button
                                IconButton(
                                  onPressed: () => AddFoodSheet.show(context, defaultMeal: _defaultMeal()),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.coach,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  icon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.add_rounded, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Add',
                                        style: TextStyle(
                                          fontFamily: "Outfit",
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _showFoodLogs ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _showFoodLogs = !_showFoodLogs;
                              });
                            },
                          ),
                          if (_showFoodLogs)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: const FoodLogList(),
                            ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mini metric builder
  Widget _buildMiniMetric({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: "Outfit",
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: "PlusJakartaSans",
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Row progress card builder
  Widget _buildRowMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required String labelRing,
    required double pctRing,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: textColor.withOpacity(0.1), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: "PlusJakartaSans",
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Daily",
                        style: TextStyle(
                          fontFamily: "PlusJakartaSans",
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontSize: 11,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Circular progress ring
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 5,
                  color: Colors.white.withOpacity(0.5),
                ),
                CircularProgressIndicator(
                  value: pctRing,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  color: textColor,
                ),
                Center(
                  child: Text(
                    labelRing,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}