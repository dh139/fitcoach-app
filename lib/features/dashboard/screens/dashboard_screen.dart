import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../../../shared/widgets/stat_card.dart';

import '../providers/dashboard_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/decay_warning_banner.dart';
import 'widgets/level_up_dialog.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/streak_widget.dart';
import 'widgets/xp_history_tile.dart';
import '../../../shared/widgets/xp_bar.dart';
import '../providers/step_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Check for pending level-up (could come from workout completion in Phase 5)
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLevelUp());
  }

  void _checkLevelUp() {
    // In Phase 5, workout completion will set a flag — we check here
    // For now this is a placeholder hook
  }

  Future<void> _onRefresh() =>
      ref.read(dashboardProvider.notifier).refresh();

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardProvider);
    final user      = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh:  _onRefresh,
          color:      AppColors.lime,
          backgroundColor: AppColors.surface1,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [

              // ── App bar ────────────────────────────────────────────────────
              SliverAppBar(
                pinned:          true,
                floating:        false,
                backgroundColor: AppColors.bg,
                expandedHeight:  0,
                toolbarHeight:   60,
                automaticallyImplyLeading: false,
                flexibleSpace: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.pageHPad,
                  ),
                  child: DashboardHeader(),
                ),
              ),

              // ── Loading state ──────────────────────────────────────────────
              if (dashState.loading && !dashState.hasData)
                const SliverFillRemaining(
                  child: Center(child: FCLoader()),
                )

              // ── Error state ────────────────────────────────────────────────
              else if (dashState.error != null && !dashState.hasData)
                SliverFillRemaining(
                  child: Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          color: AppColors.textTertiary, size: 48),
                      const SizedBox(height: 12),
                      const Text('Failed to load dashboard',
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          )),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _onRefresh,
                        child: const Text('Try again'),
                      ),
                    ],
                  )),
                )

              // ── Content ────────────────────────────────────────────────────
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pageHPad, 8,
                    AppConstants.pageHPad, 24,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (dashState.xpProfile?.decayWarning == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: DecayWarningBanner(
                            daysInactive: dashState.xpProfile?.daysInactive,
                          ),
                        ),

                      // ── Daily Challenge (Premium Hero Section) ─────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                            ]
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [Colors.black.withOpacity(0.0), Colors.black],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ).createShader(bounds),
                                  blendMode: BlendMode.dstIn,
                                  child: Opacity(
                                    opacity: 0.4,
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=600&auto=format&fit=crop',
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ),
                              // Frosted noise/shimmer layer effect pseudo
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.1)],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
                                      ),
                                      child: const Text('DAILY CHALLENGE', style: TextStyle(
                                        fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8
                                      )),
                                    ).animate().fade().slideY(begin: 0.2, curve: Curves.easeOut, delay: 200.ms),
                                    const SizedBox(height: 12),
                                    Builder(
                                      builder: (context) {
                                        final hour = DateTime.now().hour;
                                        String greeting = 'Good\nEvening';
                                        if (hour < 12) greeting = 'Good\nMorning';
                                        else if (hour < 17) greeting = 'Good\nAfternoon';
                                        return Text(greeting, style: AppTextStyles.h1.copyWith(
                                          color: Colors.white,
                                          fontSize: 32,
                                          height: 1.1,
                                        )).animate().fade(delay: 300.ms).slideY(begin: 0.2, curve: Curves.easeOut);
                                      }
                                    ),
                                    const SizedBox(height: 12),
                                    Builder(
                                      builder: (context) {
                                        final hour = DateTime.now().hour;
                                        String subGreeting = 'Time to wind down or stretch.';
                                        if (hour < 12) subGreeting = 'Crush your plan before 12:00 PM';
                                        else if (hour < 17) subGreeting = 'Keep the momentum going strong.';
                                        return Text(subGreeting, style: AppTextStyles.bodySm.copyWith(
                                          color: Colors.white.withOpacity(0.85),
                                        )).animate().fade(delay: 400.ms);
                                      }
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                                        ]
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.bolt_rounded, size: 18, color: AppColors.brandPurple),
                                          const SizedBox(width: 4),
                                          Text('Earn 500 XP', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 2.seconds).animate().fade(delay: 500.ms),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Your Plan ───────────────────────────────────────
                      if (dashState.stats != null) ...[
                        Text('Your plan', style: AppTextStyles.h2.copyWith(fontSize: 22)),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _StatsGrid(stats: dashState.stats!),
                        ),
                      ],

                      // ── Streak ───────────────────────────────────────────
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: StreakWidget(),
                      ),

                      // ── Quick actions ────────────────────────────────────
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: QuickActionsGrid(),
                      ),

                      // ── AI Suggestion ────────────────────────────────────
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: _AiSuggestCard(),
                      ),

                      // ── XP History ───────────────────────────────────────
                      _XpHistorySection(logs: dashState.xpHistory),
                    ].animate(interval: 100.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stats grid (Bento Layout) ──────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final dynamic stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final spacing = 12.0;
        final childWidth = ((constraints.maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount) - 0.1;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: childWidth,
              child: StatCard(
                index:      0,
                icon:       Icons.fitness_center_rounded,
                iconColor:  AppColors.surface1,
                iconBg:     Colors.black26,
                value:      '${stats.totalWorkouts}',
                label:      'Workouts',
                delta:      '+${stats.weeklyWorkouts} this week',
                bgColor:    AppColors.brandOrange, // Vibrant pastel orange
                textColor:  AppColors.textPrimary,
              ),
            ),
            SizedBox(
              width: childWidth,
              child: StatCard(
                index:      1,
                icon:       Icons.local_fire_department_rounded,
                iconColor:  AppColors.lime,
                iconBg:     Colors.white,
                value:      _formatCal(stats.totalCaloriesBurned),
                label:      'Cal burned',
                delta:      'all time',
                bgColor:    AppColors.brandBlue, // Pastel blue
                textColor:  AppColors.lime,
              ),
            ),
            SizedBox(
              width: childWidth,
              child: StatCard(
                index:      2,
                icon:       Icons.timer_rounded,
                iconColor:  AppColors.textPrimary,
                iconBg:     Colors.white54,
                value:      '${stats.totalMinutesWorked}m',
                label:      'Mins trained',
                delta:      'total',
                bgColor:    AppColors.brandMint, // Pastel mint
                textColor:  AppColors.textPrimary,
              ),
            ),
            SizedBox(
              width: childWidth,
              child: StatCard(
                index:      3,
                icon:       Icons.bolt_rounded,
                iconColor:  Colors.white,
                iconBg:     Colors.white30,
                value:      _formatXP(stats.xp),
                label:      'Total XP',
                delta:      stats.level[0].toUpperCase() + stats.level.substring(1),
                bgColor:    AppColors.brandPurple, // Pastel purple
                textColor:  Colors.white,
              ),
            ),
          ],
        );
      }
    );
  }

  String _formatCal(int cal) {
    if (cal >= 1000) return '${(cal / 1000).toStringAsFixed(1)}k';
    return '$cal';
  }

  String _formatXP(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return '$xp';
  }
}



// ── XP History section ─────────────────────────────────────────────────────────
class _XpHistorySection extends StatelessWidget {
  final List<dynamic> logs;
  const _XpHistorySection({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Recent XP activity', style: AppTextStyles.h3),
        const Spacer(),
        GestureDetector(
          onTap: () => context.go('/history'),
          child: Text('View all', style: AppTextStyles.label.copyWith(
            color: AppColors.lime,
          )),
        ),
      ]),
      const SizedBox(height: 16),

      if (logs.isEmpty)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Center(child: Column(children: [
            const Icon(Icons.bolt_outlined,
                color: AppColors.textTertiary, size: 32),
            const SizedBox(height: 8),
            Text('No XP activity yet', style: AppTextStyles.body),
            const SizedBox(height: 4),
            Text('Complete a workout to earn your first XP',
              style: AppTextStyles.bodySm,
            ),
          ])),
        )
      else
        ListView.separated(
          shrinkWrap: true,
          physics:    const NeverScrollableScrollPhysics(),
          itemCount:  logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => XpHistoryTile(log: logs[i]),
        ),
    ]);
  }
}

// ── AI Suggestion Card ──────────────────────────────────────────────────────────
class _AiSuggestCard extends ConsumerWidget {
  const _AiSuggestCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepState = ref.watch(stepProvider);
    
    String aiMessage = 'Your stats suggest a lightweight recovery walk today. Prepare to hydrate and keep volume low to prevent overtraining based on yesterday\'s session.';
    if (stepState.stepsToday > 5000) {
      aiMessage = 'You have already taken ${stepState.stepsToday} steps today! Great job staying active. A quick 15-minute mobility routine would be perfect to complement your activity.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandPurple.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.brandPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily AI Suggestion', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary
                )),
                const SizedBox(height: 6),
                Text(aiMessage, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary, height: 1.5
                )),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border3, width: 0.5),
                    ),
                    child: const Text('View routine', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.lime
                    )),
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }
}