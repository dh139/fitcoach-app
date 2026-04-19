import 'package:fitcoach/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../providers/coach_provider.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_window.dart';
import 'widgets/improvement_score_card.dart';
import 'widgets/quick_prompts_row.dart';
import 'widgets/smart_alerts_list.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  bool _showScore  = true;
  bool _showAlerts = true;

  @override
  Widget build(BuildContext context) {
    final state  = ref.watch(coachProvider);
    final user   = ref.watch(currentUserProvider);
    final name   = user?.name ?? 'Athlete';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [

          // ── App bar ──────────────────────────────────────────────────────
          _AppBar(
            isStreaming:     state.isStreaming,
            clearingHistory: state.clearingHistory,
            onClear: () => ref.read(coachProvider.notifier).clearHistory(),
          ),

          // ── Scrollable top panel: score + alerts ─────────────────────────
          if (state.scoreLoading || state.scoreData != null)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppConstants.pageHPad, 10,
                    AppConstants.pageHPad, 0),
                child: Column(children: [

                  // Improvement score
                  if (state.scoreLoading)
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color:        AppColors.surface2,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: FCLoader(size: 20)),
                    )
                  else if (state.scoreData != null) ...[
                    GestureDetector(
                      onTap: () => setState(() => _showScore = !_showScore),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color:        AppColors.surface1,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.border2, width: 0.5),
                        ),
                        child: Row(children: [
                          Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              color:        const Color(0x1AC084FC),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(Icons.trending_up_rounded,
                                color: Color(0xFFC084FC), size: 14),
                          ),
                          const SizedBox(width: 10),
                          const Text('Improvement score', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          )),
                          const Spacer(),
                          Text(
                            '${state.scoreData!.composite}/100',
                            style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.lime,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _showScore
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textTertiary, size: 18,
                          ),
                        ]),
                      ),
                    ),

                    if (_showScore) ...[
                      const SizedBox(height: 8),
                      ImprovementScoreCard(data: state.scoreData!),
                    ],
                  ],

                  // Smart alerts
                  if (state.scoreData != null &&
                      state.scoreData!.alerts.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showAlerts = !_showAlerts),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color:        AppColors.surface1,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.border2, width: 0.5),
                        ),
                        child: Row(children: [
                          Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              color:        AppColors.warnDim,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(Icons.notifications_rounded,
                                color: AppColors.warn, size: 14),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Smart alerts (${state.scoreData!.alerts.length})',
                            style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _showAlerts
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textTertiary, size: 18,
                          ),
                        ]),
                      ),
                    ),

                    if (_showAlerts) ...[
                      const SizedBox(height: 8),
                      SmartAlertsList(
                        alerts: state.scoreData!.alerts,
                        onActionTap: (action) {
                          // Pre-fill input with the action text
                          // We use a key to communicate with ChatInputBar
                          // via the notifier's sendMessage directly
                          ref.read(coachProvider.notifier)
                              .sendMessage(action, name);
                        },
                      ),
                    ],
                  ],
                  const SizedBox(height: 4),
                ]),
              ),
            ),

          const Divider(height: 1, color: AppColors.border1),

          // ── Chat window ──────────────────────────────────────────────────
          const Expanded(child: ChatWindow()),

          // ── Error banner ─────────────────────────────────────────────────
          if (state.error != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:        AppColors.dangerDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.dangerBorder, width: 0.5),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.danger, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(state.error!, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 11,
                  color: Color(0xFFFF8888),
                ))),
                GestureDetector(
                  onTap: () => ref.read(coachProvider.notifier)
                      .cancelStream(),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.danger, size: 14),
                ),
              ]),
            ),

          // ── Quick prompts (only when no messages) ────────────────────────
          if (!state.hasMessages && !state.isStreaming) ...[
            const SizedBox(height: 6),
            QuickPromptsRow(
              onSelected: (prompt) =>
                  ref.read(coachProvider.notifier)
                      .sendMessage(prompt, name),
              disabled: state.isStreaming,
            ),
          ],

          // ── Chat input bar ───────────────────────────────────────────────
          ChatInputBar(
            disabled: state.isStreaming,
            onSend: (text) =>
                ref.read(coachProvider.notifier)
                    .sendMessage(text, name),
          ),
        ]),
      ),
    );
  }
}

// ── App bar widget ─────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final bool         isStreaming;
  final bool         clearingHistory;
  final VoidCallback onClear;

  const _AppBar({
    required this.isStreaming,
    required this.clearingHistory,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) => Container(
    height:  64,
    padding: const EdgeInsets.symmetric(horizontal: AppConstants.pageHPad),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(
        color: AppColors.border1, width: 1.0)),
      color: AppColors.bg,
    ),
    child: Row(children: [
      // Bot avatar
      AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        width: 44, height: 44,
        decoration: BoxDecoration(
          color:  AppColors.coachDim,
          shape:  BoxShape.circle,
          border: Border.all(color: isStreaming ? AppColors.brandPurple : AppColors.coachBorder, width: isStreaming ? 2.0 : 1.0),
          boxShadow: isStreaming ? [
            BoxShadow(color: AppColors.brandPurple.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)
          ] : [
            BoxShadow(color: AppColors.coach.withOpacity(0.2), blurRadius: 8, spreadRadius: 0)
          ],
        ),
        child: const Icon(Icons.smart_toy_rounded,
            color: AppColors.coach, size: 24),
      ),
      const SizedBox(width: 14),

      // Title + status
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:  MainAxisAlignment.center,
        children: [
          Text('FitCoach AI', style: AppTextStyles.h3),
          const SizedBox(height: 2),
          Row(children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: isStreaming ? AppColors.brandPurple : AppColors.lime,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: (isStreaming ? AppColors.brandPurple : AppColors.lime).withOpacity(0.5), blurRadius: 6, spreadRadius: 1)
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isStreaming ? 'Thinking...' : 'Online · personalised to you',
              style: AppTextStyles.label,
            ),
          ]),
        ],
      )),

      // Clear history button
      clearingHistory
          ? const FCLoader(size: 20)
          : IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.textSecondary, size: 22),
              tooltip: 'Clear chat history',
            ),
    ]),
  );
}