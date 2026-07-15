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
  final String? initialMessage;
  const CoachScreen({this.initialMessage, super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  bool _showScore  = true;
  bool _showAlerts = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userName = ref.read(currentUserProvider)?.name ?? 'Athlete';
        ref.read(coachProvider.notifier).sendMessage(widget.initialMessage!, userName);
      });
    }
  }

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
            Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.pageHPad, 10, AppConstants.pageHPad, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Improvement Score Row Card
                  if (state.scoreLoading)
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color:        AppColors.surface2,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: FCLoader(size: 20)),
                    )
                  else if (state.scoreData != null)
                    GestureDetector(
                      onTap: () {
                        // Open the gorgeous breakdown bottom sheet!
                        _showScoreBreakdownSheet(context, state.scoreData!);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color:        AppColors.surface1,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border2, width: 0.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color:        AppColors.coachDim,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.trending_up_rounded, color: AppColors.coach, size: 14),
                          ),
                          const SizedBox(width: 10),
                          const Text('Improvement Score', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          )),
                          const Spacer(),
                          Text(
                            '${state.scoreData!.composite}/100',
                            style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.coach,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 12),
                        ]),
                      ),
                    ),

                  // Smart Alerts list (if present)
                  if (state.scoreData != null && state.scoreData!.alerts.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SmartAlertsList(
                      alerts: state.scoreData!.alerts,
                      onActionTap: (action) {
                        ref.read(coachProvider.notifier).sendMessage(action, name);
                      },
                    ),
                  ],
                ],
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
                Expanded(child: Text(state.error!, style: TextStyle(
                  fontFamily: 'Inter', fontSize: 11,
                  color: AppColors.danger,
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

  void _showScoreBreakdownSheet(BuildContext context, dynamic scoreData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Performance Score",
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface2,
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Score card itself
            ImprovementScoreCard(data: scoreData),
            const SizedBox(height: 16),
          ],
        ),
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
          color:  AppColors.forest,
          shape:  BoxShape.circle,
          border: Border.all(color: isStreaming ? AppColors.lime : Colors.transparent, width: 2.0),
          boxShadow: isStreaming ? [
            BoxShadow(color: AppColors.lime.withOpacity(0.45), blurRadius: 15, spreadRadius: 2)
          ] : [
            BoxShadow(color: AppColors.forest.withOpacity(0.25), blurRadius: 8, spreadRadius: 0)
          ],
        ),
        child: const Icon(Icons.smart_toy_rounded,
            color: AppColors.lime, size: 24),
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
                color: isStreaming ? AppColors.coach : AppColors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: (isStreaming ? AppColors.coach : AppColors.success).withOpacity(0.5), blurRadius: 6, spreadRadius: 1)
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