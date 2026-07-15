import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../providers/leaderboard_provider.dart';
import 'widgets/leaderboard_rank_row.dart';
import 'widgets/leaderboard_podium.dart';
import 'widgets/leaderboard_skeleton.dart';
import 'widgets/my_rank_card.dart';
import 'widgets/score_formula_row.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  static const _periods = ['daily', 'weekly', 'monthly'];
  static const _labels  = ['Today', 'This week', 'This month'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state  = ref.watch(leaderboardProvider);
    final user   = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh:       () => ref.read(leaderboardProvider.notifier).refresh(),
          color:           AppColors.lime,
          backgroundColor: AppColors.surface1,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [

              // ── App bar ──────────────────────────────────────────────────
              SliverAppBar(
                pinned:          true,
                floating:        false,
                backgroundColor: AppColors.bg,
                expandedHeight:  0,
                toolbarHeight:   56,
                automaticallyImplyLeading: false,
                title: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color:        AppColors.accent4Dim,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.leaderboard_rounded,
                        color: AppColors.accent4, size: 17),
                  ),
                  const SizedBox(width: 10),
                  const Text('Leaderboard', style: TextStyle(
                    fontFamily:    'Inter',
                    fontSize:      18,
                    fontWeight:    FontWeight.w700,
                    color:         AppColors.textPrimary,
                    letterSpacing: -0.3,
                  )),
                ]),
                actions: [
                  if (state.refreshing)
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: FCLoader(size: 18),
                    )
                  else
                    IconButton(
                      onPressed: () =>
                          ref.read(leaderboardProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.textSecondary, size: 22),
                    ),
                ],
                // Period tab bar
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(52),
                  child: Container(
                    color: AppColors.bg,
                    padding: const EdgeInsets.fromLTRB(
                        AppConstants.pageHPad, 0,
                        AppConstants.pageHPad, 10),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:        AppColors.surface1,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.border2, width: 0.5),
                      ),
                      child: Row(
                        children: List.generate(_periods.length, (i) {
                          final active = state.activePeriod == _periods[i];
                          return Expanded(child: GestureDetector(
                            onTap: () => ref
                                .read(leaderboardProvider.notifier)
                                .setPeriod(_periods[i]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 9),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.textPrimary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Text(
                                _labels[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily:  'Inter',
                                  fontSize:    12,
                                  fontWeight:  FontWeight.w700,
                                  color: active
                                      ? Colors.white
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ));
                        }),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppConstants.pageHPad, 12,
                    AppConstants.pageHPad, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // Anti-cheat notice
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color:        AppColors.accent5Dim,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.accent5Light, width: 0.5),
                      ),
                      child: Row(children: [
                        Icon(Icons.verified_rounded,
                            color: AppColors.accent5, size: 15),
                        const SizedBox(width: 8),
                        Expanded(child: Text(
                          'Rankings use verified XP only — cheat sessions excluded',
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            color: AppColors.accent5, height: 1.4,
                          ),
                        )),
                      ]),
                    ),
                    const SizedBox(height: 14),

                    // My ranks card
                    if (state.myStats.isNotEmpty) ...[
                      MyRankCard(stats: state.myStats),
                      const SizedBox(height: 14),
                    ],

                    // Score formula
                    const ScoreFormulaRow(),
                    const SizedBox(height: 16),

                    // Last updated
                    if (state.current?.builtAt != null) ...[
                      Row(children: [
                        const Icon(Icons.access_time_rounded,
                            color: AppColors.textTertiary, size: 12),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Updated ${_timeAgo(state.current!.builtAt!)} · refreshes hourly',
                            style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                    ],

                    // Entries header
                    if (state.current != null &&
                        state.current!.total > 0) ...[
                      Text(
                        '${state.current!.total} athlete${state.current!.total != 1 ? 's' : ''} ranked',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Skeleton
                    if (state.loading)
                      const LeaderboardSkeleton()

                    // Error
                    else if (state.error != null &&
                             state.current == null)
                      Center(child: Column(children: [
                        const SizedBox(height: 40),
                        const Icon(Icons.wifi_off_rounded,
                            color: AppColors.textTertiary, size: 40),
                        const SizedBox(height: 12),
                        const Text('Failed to load leaderboard',
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 14,
                              color: AppColors.textSecondary,
                            )),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref
                              .read(leaderboardProvider.notifier).refresh(),
                          child: const Text('Try again'),
                        ),
                      ]))

                    // Empty
                    else if (state.current != null &&
                             state.current!.entries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text(
                          'No ranked athletes yet for this period.\nComplete a verified workout to appear here!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 13,
                            color: AppColors.textSecondary, height: 1.6,
                          ),
                        )),
                      )

                    // Podium (top 3) + remaining rows
                    else if (state.current != null) ...[
                      if (state.current!.entries.length >= 3) ...[
                        LeaderboardPodium(
                          top: state.current!.entries
                              .where((e) => e.rank <= 3)
                              .toList(),
                          myUserId: userId,
                        ),
                        const SizedBox(height: 16),
                        Column(children: state.current!.entries
                            .where((e) => e.rank > 3)
                            .map((e) => LeaderboardRankRow(
                                  entry: e,
                                  isMe:  e.userId == userId,
                                ))
                            .toList()),
                      ] else
                        Column(children: state.current!.entries
                            .map((e) => LeaderboardRankRow(
                                  entry: e,
                                  isMe:  e.userId == userId,
                                ))
                            .toList()),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}