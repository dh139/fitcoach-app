import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/report_provider.dart';
import 'widgets/report_card.dart';
import 'widgets/report_skeleton.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _types  = ['daily', 'weekly', 'monthly', 'yearly'];
  static const _labels = ['Today', 'Week', 'Month', 'Year'];
  static const _descriptions = {
    'daily':   'Today\'s activity, calorie balance, and tomorrow\'s tip.',
    'weekly':  'Workout frequency, strengths, weaknesses, plateau detection.',
    'monthly': 'Progress trends, habit formation, and next month\'s plan.',
    'yearly':  'Total transformation, milestones, and vision for next year.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state  = ref.watch(reportProvider);
    final type   = state.activeType;
    final report = state.current;
    final loading = state.isLoading(type);
    final error   = state.getError(type);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── App bar ──────────────────────────────────────────────────
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
                    color:        AppColors.coachDim,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.bar_chart_rounded,
                      color: AppColors.coach, size: 17),
                ),
                const SizedBox(width: 10),
                const Text('AI reports', style: TextStyle(
                  fontFamily:    'Inter',
                  fontSize:      18,
                  fontWeight:    FontWeight.w700,
                  color:         AppColors.textPrimary,
                  letterSpacing: -0.3,
                )),
              ]),
              // Type tab bar
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
                      children: List.generate(_types.length, (i) {
                        final active = type == _types[i];
                        return Expanded(child: GestureDetector(
                          onTap: () => ref
                              .read(reportProvider.notifier)
                              .setType(_types[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.coach
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
                                    ? AppColors.bg
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

                  // Description
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color:        AppColors.surface1,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.border2, width: 0.5),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.textTertiary, size: 14),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        _descriptions[type] ?? '',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 12,
                          color: AppColors.textSecondary, height: 1.4,
                        ),
                      )),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Skeleton
                  if (loading && report == null)
                    const ReportSkeleton()

                  // Error
                  else if (error != null && report == null)
                    Center(child: Column(children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.textTertiary, size: 40),
                      const SizedBox(height: 12),
                      Text(error, textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref
                            .read(reportProvider.notifier)
                            .loadReport(type),
                        child: const Text('Try again'),
                      ),
                    ]))

                  // Empty state
                  else if (report == null && !loading)
                    Center(child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color:        AppColors.surface2,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.bar_chart_rounded,
                              color: AppColors.surface4, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('No report yet', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        )),
                        const SizedBox(height: 8),
                        const Text(
                          'Complete some workouts and log meals\nto generate your first AI report',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 13,
                            color: AppColors.textTertiary, height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () => ref
                              .read(reportProvider.notifier)
                              .loadReport(type, refresh: true),
                          icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                          label: const Text('Generate report now'),
                        ),
                      ]),
                    ))

                  // Report card
                  else if (report != null)
                    ReportCard(report: report),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}