import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../../../shared/widgets/fc_page_scaffold.dart';
import '../providers/challenge_provider.dart';
import 'widgets/challenge_card.dart';
import 'widgets/challenge_claimed_dialog.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challengeProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FCPageScaffold(
          child: RefreshIndicator(
            onRefresh: () => ref.read(challengeProvider.notifier).load(),
            color:           AppColors.lime,
            backgroundColor: AppColors.surface1,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [

                // ── App bar ────────────────────────────────────────────
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
                        color:        const Color(0x1AFBBF24),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.emoji_events_rounded,
                          color: Color(0xFFFBBF24), size: 17),
                    ),
                    const SizedBox(width: 10),
                    const Text('Challenges', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    )),
                  ]),
                  actions: [
                    if (state.pendingCount > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color:        AppColors.limeDim,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.limeBorder, width: 0.5),
                        ),
                        child: Text(
                          '${state.pendingCount} to claim',
                          style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lime,
                          ),
                        ),
                      ),
                  ],
                ),

                // ── Content ────────────────────────────────────────────
                if (state.loading)
                  const SliverFillRemaining(
                    child: Center(child: FCLoader()))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppConstants.pageHPad, 12,
                        AppConstants.pageHPad, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([

                        // Info strip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.coachDim,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.coachBorder, width: 0.5),
                          ),
                          child: const Row(children: [
                            Icon(Icons.auto_awesome_rounded,
                                color: AppColors.coach, size: 14),
                            SizedBox(width: 8),
                            Expanded(child: Text(
                              'AI-generated challenges refresh daily and weekly — tailored to your goals',
                              style: TextStyle(
                                fontFamily: 'Inter', fontSize: 11,
                                color: Color(0xFFD8B4FE), height: 1.4,
                              ),
                            )),
                          ]),
                        ),
                        const SizedBox(height: 20),

                        // Daily challenges
                        if (state.daily.isNotEmpty) ...[
                          const _SectionHeader('Daily challenges',
                              Icons.wb_sunny_outlined),
                          const SizedBox(height: 10),
                          ...state.daily.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ChallengeCard(
                              challenge: c,
                              claiming:  state.claiming,
                              onClaim: () async {
                                final ok = await ref
                                    .read(challengeProvider.notifier)
                                    .claim(c.id);
                                if (ok && context.mounted) {
                                  final s =
                                      ref.read(challengeProvider);
                                  await ChallengeClaimed.show(
                                    context,
                                    xpEarned: s.claimedXP ?? c.xpReward,
                                    message:  s.claimedMessage ?? 'XP earned!',
                                  );
                                  ref.read(challengeProvider.notifier)
                                      .clearClaimed();
                                }
                              },
                            ),
                          )),
                          const SizedBox(height: 10),
                        ],

                        // Weekly challenges
                        if (state.weekly.isNotEmpty) ...[
                          const _SectionHeader('Weekly challenges',
                              Icons.calendar_view_week_rounded),
                          const SizedBox(height: 10),
                          ...state.weekly.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ChallengeCard(
                              challenge: c,
                              claiming:  state.claiming,
                              onClaim: () async {
                                final ok = await ref
                                    .read(challengeProvider.notifier)
                                    .claim(c.id);
                                if (ok && context.mounted) {
                                  final s =
                                      ref.read(challengeProvider);
                                  await ChallengeClaimed.show(
                                    context,
                                    xpEarned: s.claimedXP ?? c.xpReward,
                                    message:  s.claimedMessage ?? 'XP earned!',
                                  );
                                  ref.read(challengeProvider.notifier)
                                      .clearClaimed();
                                }
                              },
                            ),
                          )),
                        ],

                        // Empty state
                        if (!state.loading &&
                            state.challenges.isEmpty)
                          _EmptyState(),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String   label;
  final IconData icon;
  const _SectionHeader(this.label, this.icon);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppColors.textTertiary, size: 15),
    const SizedBox(width: 7),
    Text(label, style: const TextStyle(
      fontFamily: 'Inter', fontSize: 13,
      fontWeight: FontWeight.w600, color: AppColors.textPrimary,
    )),
  ]);
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color:        AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.emoji_events_outlined,
            color: AppColors.surface4, size: 32),
      ),
      const SizedBox(height: 14),
      const Text('No challenges yet', style: TextStyle(
        fontFamily: 'Inter', fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      )),
      const SizedBox(height: 8),
      const Text(
        'Complete a verified workout to unlock\nAI-generated daily challenges',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter', fontSize: 13,
          color: AppColors.textTertiary, height: 1.5,
        ),
      ),
    ])),
  );
}