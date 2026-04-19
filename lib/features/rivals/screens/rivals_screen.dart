import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../../../shared/widgets/fc_page_scaffold.dart';
import '../../../shared/widgets/level_badge.dart';
import '../models/rival_model.dart';
import '../providers/rival_provider.dart';
import 'widgets/challenge_user_sheet.dart';
import 'widgets/rival_tile.dart';

class RivalsScreen extends ConsumerWidget {
  const RivalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state  = ref.watch(rivalProvider);
    final userId = ref.watch(currentUserProvider)?.id ?? '';

    // Show snackbar for success / error messages
    ref.listen(rivalProvider.select((s) => s.successMessage),
        (_, msg) {
      if (msg != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 13,
            color: AppColors.bg,
          )),
          backgroundColor:   AppColors.lime,
          behavior:          SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
        ref.read(rivalProvider.notifier).clearMessage();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FCPageScaffold(
          child: RefreshIndicator(
            onRefresh: () => ref.read(rivalProvider.notifier).load(),
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
                        color:        AppColors.dangerDim,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.sports_kabaddi_rounded,
                          color: AppColors.danger, size: 17),
                    ),
                    const SizedBox(width: 10),
                    const Text('Rivals', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    )),
                  ]),
                  actions: [
                    if (state.pending.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color:        AppColors.dangerDim,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.dangerBorder, width: 0.5),
                        ),
                        child: Text(
                          '${state.pending.length} pending',
                          style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                  ],
                ),

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

                        // Active rivals
                        if (state.active.isNotEmpty) ...[
                          _Header('Active battles (${state.active.length})'),
                          const SizedBox(height: 10),
                          ...state.active.map((r) => RivalTile(
                            rival:         r,
                            myUserId:      userId,
                            actionLoading: state.actionLoading,
                            onAccept:  () => ref
                                .read(rivalProvider.notifier)
                                .respond(r.id, true),
                            onDecline: () => ref
                                .read(rivalProvider.notifier)
                                .respond(r.id, false),
                          )),
                          const SizedBox(height: 10),
                        ],

                        // Pending
                        if (state.pending.isNotEmpty) ...[
                          _Header('Pending challenges'),
                          const SizedBox(height: 10),
                          ...state.pending.map((r) => RivalTile(
                            rival:         r,
                            myUserId:      userId,
                            actionLoading: state.actionLoading,
                            onAccept:  () => ref
                                .read(rivalProvider.notifier)
                                .respond(r.id, true),
                            onDecline: () => ref
                                .read(rivalProvider.notifier)
                                .respond(r.id, false),
                          )),
                          const SizedBox(height: 10),
                        ],

                        // Suggestions
                        if (state.suggestions.isNotEmpty) ...[
                          _Header('Suggested rivals'),
                          const SizedBox(height: 4),
                          const Text(
                            'Athletes at your level — tap to challenge them',
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...state.suggestions.map((s) =>
                              _SuggestionTile(
                                suggestion: s,
                                onChallenge: () =>
                                    ChallengeUserSheet.show(context, s),
                              ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Completed
                        if (state.finished.isNotEmpty) ...[
                          _Header('Completed'),
                          const SizedBox(height: 10),
                          ...state.finished.map((r) => RivalTile(
                            rival:         r,
                            myUserId:      userId,
                            actionLoading: false,
                            onAccept:  () {},
                            onDecline: () {},
                          )),
                        ],

                        // Empty
                        if (!state.loading &&
                            state.rivals.isEmpty &&
                            state.suggestions.isEmpty)
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

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontFamily: 'Inter', fontSize: 13,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  ));
}

class _SuggestionTile extends StatelessWidget {
  final RivalSuggestion suggestion;
  final VoidCallback    onChallenge;
  const _SuggestionTile({
    required this.suggestion,
    required this.onChallenge,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border2, width: 0.5),
    ),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surface3, shape: BoxShape.circle),
        child: Center(child: Text(suggestion.initials, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(suggestion.name, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary,
          )),
          Row(children: [
            LevelBadge(level: suggestion.level, fontSize: 9),
            const SizedBox(width: 6),
            Text(suggestion.reason, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 10,
              color: AppColors.textTertiary,
            )),
          ]),
        ],
      )),
      GestureDetector(
        onTap: onChallenge,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color:        AppColors.dangerDim,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppColors.dangerBorder, width: 0.5),
          ),
          child: const Text('Challenge', style: TextStyle(
            fontFamily: 'Inter', fontSize: 11,
            fontWeight: FontWeight.w700, color: AppColors.danger,
          )),
        ),
      ),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.sports_kabaddi_rounded,
            color: AppColors.surface4, size: 32),
      ),
      const SizedBox(height: 14),
      const Text('No rivals yet', style: TextStyle(
        fontFamily: 'Inter', fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      )),
      const SizedBox(height: 8),
      const Text(
        'Complete more workouts to get\nmatched with rival suggestions',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter', fontSize: 13,
          color: AppColors.textTertiary, height: 1.5,
        ),
      ),
    ])),
  );
}