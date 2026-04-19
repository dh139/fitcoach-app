import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
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
                      color:        AppColors.limeDim,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.history_rounded,
                        color: AppColors.lime, size: 17),
                  ),
                  const SizedBox(width: 10),
                  const Text('Workout history', style: TextStyle(
                    fontFamily:    'Inter',
                    fontSize:      18,
                    fontWeight:    FontWeight.w700,
                    color:         AppColors.textPrimary,
                    letterSpacing: -0.3,
                  )),
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
                        iconColor: AppColors.lime,
                        iconBg:    AppColors.limeDim,
                        chart:     FrequencyBarChart(
                            data: state.frequencyData),
                      ),
                      const SizedBox(height: 12),

                      ChartCard(
                        title:     'Calories burned',
                        subtitle:  'Per session — last 14 days',
                        icon:      Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFFFF8C42),
                        iconBg:    const Color(0x1AFF6B00),
                        chart:     CalorieLineChart(
                            data: state.calorieData),
                      ),
                      const SizedBox(height: 12),

                      ChartCard(
                        title:     'XP growth',
                        subtitle:  'Cumulative — last 14 days',
                        icon:      Icons.bolt_rounded,
                        iconColor: const Color(0xFFFBBF24),
                        iconBg:    const Color(0x1AFBBF24),
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