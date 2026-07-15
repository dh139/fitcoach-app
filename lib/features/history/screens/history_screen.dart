import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../providers/history_provider.dart';
import 'widgets/calorie_line_chart.dart';
import 'widgets/chart_card.dart';
import 'widgets/frequency_bar_chart.dart';
import 'widgets/workout_history_tile.dart';
import 'widgets/xp_area_chart.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      ref.read(historyProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(historyProvider.notifier).refresh(),
          color:           AppColors.lime,
          backgroundColor: AppColors.surface1,
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [

              // ── App bar ──────────────────────────────────────────────
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
                      color:        AppColors.primaryDim,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.history_rounded,
                        color: AppColors.primary, size: 17),
                  ),
                  const SizedBox(width: 10),
                  Text('Workout history', style: AppTextStyles.h2),
                ]),
                actions: [
                  if (state.hasData)
                    Center(child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:        AppColors.surface2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.border3, width: 0.5),
                      ),
                      child: Text(
                        '${state.workouts.length} sessions',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                ],
              ),

              // ── Loading ──────────────────────────────────────────────
              if (state.loading && !state.hasData)
                const SliverFillRemaining(
                  child: Center(child: FCLoader()),
                )

              // ── Error ────────────────────────────────────────────────
              else if (state.error != null && !state.hasData)
                SliverFillRemaining(
                  child: Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          color: AppColors.textTertiary, size: 40),
                      const SizedBox(height: 12),
                      Text(state.error!, textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            ref.read(historyProvider.notifier).refresh(),
                        child: const Text('Try again'),
                      ),
                    ],
                  )),
                )

              // ── Content ──────────────────────────────────────────────
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pageHPad, 12,
                    AppConstants.pageHPad, 40,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // ── Summary hero ──────────────────────────────────
                      _HistorySummary(
                        sessions: state.workouts.length,
                        minutes: state.workouts.fold<int>(
                            0, (s, w) => s + w.durationSeconds) ~/ 60,
                        calories: state.workouts.fold<int>(
                            0, (s, w) => s + w.totalCaloriesBurned),
                        xp: state.workouts.fold<int>(
                            0, (s, w) => s + w.xpEarned),
                      ),
                      const SizedBox(height: 20),

                      // ── Charts section ────────────────────────────────
                      const Text('Progress charts', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                      const SizedBox(height: 12),

                      ChartCard(
                        title:     'Workout frequency',
                        subtitle:  'Sessions per week — last 8 weeks',
                        icon:      Icons.bar_chart_rounded,
                        iconColor: AppColors.primary,
                        iconBg:    AppColors.primaryDim,
                        chart:     FrequencyBarChart(
                            data: state.frequencyData),
                      ),
                      const SizedBox(height: 12),

                      ChartCard(
                        title:     'Calories burned',
                        subtitle:  'Per session — last 14 days',
                        icon:      Icons.local_fire_department_rounded,
                        iconColor: AppColors.accent4,
                        iconBg:    AppColors.accent4Dim,
                        chart:     CalorieLineChart(
                            data: state.calorieData),
                      ),
                      const SizedBox(height: 12),

                      ChartCard(
                        title:     'XP growth',
                        subtitle:  'Cumulative — last 14 days',
                        icon:      Icons.bolt_rounded,
                        iconColor: AppColors.primary,
                        iconBg:    AppColors.primaryDim,
                        chart:     XpAreaChart(data: state.xpData),
                      ),
                      const SizedBox(height: 20),

                      // ── History list ──────────────────────────────────
                      const Text('All sessions', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                      const SizedBox(height: 12),

                      if (state.workouts.isEmpty && !state.loading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 32),
                          child: const Center(child: Column(children: [
                            Icon(Icons.fitness_center_outlined,
                                color: AppColors.textTertiary, size: 40),
                            SizedBox(height: 12),
                            Text('No workouts yet', style: TextStyle(
                              fontFamily: 'Inter', fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            )),
                            SizedBox(height: 6),
                            Text('Complete a session to see your history',
                              style: TextStyle(
                                fontFamily: 'Inter', fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ])),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics:    const NeverScrollableScrollPhysics(),
                          itemCount:  state.workouts.length,
                          itemBuilder: (_, i) =>
                              WorkoutHistoryTile(workout: state.workouts[i]),
                        ),

                      if (state.loadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: FCLoader()),
                        ),

                      if (!state.hasMore && state.hasData)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: Text(
                            'All sessions loaded',
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          )),
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
}

// ── History summary hero ─────────────────────────────────────────────────────
class _HistorySummary extends StatelessWidget {
  final int sessions, minutes, calories, xp;
  const _HistorySummary({
    required this.sessions,
    required this.minutes,
    required this.calories,
    required this.xp,
  });

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientHero,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: AppColors.lime, size: 18),
              const SizedBox(width: 8),
              Text(
                'Lifetime progress',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _stat('$sessions', 'Sessions'),
              _divider(),
              _stat(_fmt(minutes), 'Minutes'),
              _divider(),
              _stat(_fmt(calories), 'Calories'),
              _divider(),
              _stat(_fmt(xp), 'XP'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.white.withValues(alpha: 0.1),
      );
}