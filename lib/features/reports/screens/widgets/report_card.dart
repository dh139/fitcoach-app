import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import 'motivation_banner.dart';
import 'report_section_tile.dart';
import 'score_meter.dart';

class ReportCard extends ConsumerWidget {
  final ReportModel report;
  const ReportCard({super.key, required this.report});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r           = report.report;
    final ctx         = report.context;
    final regenerating = ref.watch(
        reportProvider.select((s) => s.regenerating));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── Score meters ──────────────────────────────────────────────────────
      Row(children: [
        Expanded(child: ScoreMeter(
          label: 'Overall score',
          value: r.overallScore,
          color: AppColors.coach,
        )),
        const SizedBox(width: 10),
        Expanded(child: ScoreMeter(
          label: 'Consistency',
          value: r.consistencyScore,
          color: AppColors.lime,
        )),
      ]),
      const SizedBox(height: 10),

      // ── Context stats strip ───────────────────────────────────────────────
      if (ctx != null) ...[
        Row(children: [
          _CtxTile(label: 'Workouts',  value: '${ctx.workouts}'),
          const SizedBox(width: 8),
          _CtxTile(label: 'Minutes',   value: '${ctx.totalMinutes}'),
          const SizedBox(width: 8),
          _CtxTile(label: 'Cal burned',value: '${ctx.totalCaloriesBurned}'),
          const SizedBox(width: 8),
          _CtxTile(label: 'XP earned', value: '${ctx.xpEarned}'),
        ]),
        const SizedBox(height: 10),
      ],

      // ── Motivation banner ─────────────────────────────────────────────────
      MotivationBanner(message: r.motivationMessage),
      if (r.motivationMessage.isNotEmpty) const SizedBox(height: 10),

      // ── Plateau warning ───────────────────────────────────────────────────
      if (r.plateauWarning.isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        AppColors.warnDim,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.warn.withOpacity(0.3), width: 0.5),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.warn, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PLATEAU DETECTED', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w800,
                  color: AppColors.warn, letterSpacing: 0.8,
                )),
                const SizedBox(height: 4),
                Text(r.plateauWarning, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  color: Color(0xFFFCD34D), height: 1.5,
                )),
              ],
            )),
          ]),
        ),
        const SizedBox(height: 10),
      ],

      // ── Summary ───────────────────────────────────────────────────────────
      ReportSectionTile(
        title:     'Summary',
        icon:      Icons.summarize_rounded,
        iconColor: const Color(0xFFFBBF24),
        iconBg:    const Color(0x1AFBBF24),
        bodyText:  r.summary,
      ),
      const SizedBox(height: 10),

      // ── Highlights ────────────────────────────────────────────────────────
      ReportSectionTile(
        title:     'Highlights',
        icon:      Icons.trending_up_rounded,
        iconColor: AppColors.lime,
        iconBg:    AppColors.limeDim,
        items:     r.highlights,
        type:      ReportSectionType.highlight,
      ),
      const SizedBox(height: 10),

      // ── Workout feedback ──────────────────────────────────────────────────
      ReportSectionTile(
        title:     'Workout analysis',
        icon:      Icons.fitness_center_rounded,
        iconColor: const Color(0xFF60A5FA),
        iconBg:    const Color(0x1A3B82F6),
        bodyText:  r.workoutFeedback,
      ),
      const SizedBox(height: 10),

      // ── Diet feedback ─────────────────────────────────────────────────────
      ReportSectionTile(
        title:     'Nutrition feedback',
        icon:      Icons.restaurant_rounded,
        iconColor: const Color(0xFFFF8C42),
        iconBg:    const Color(0x1AFF6B00),
        bodyText:  r.dietFeedback,
      ),
      const SizedBox(height: 10),

      // ── Improvements ─────────────────────────────────────────────────────
      ReportSectionTile(
        title:     'Areas to improve',
        icon:      Icons.arrow_upward_rounded,
        iconColor: AppColors.warn,
        iconBg:    AppColors.warnDim,
        items:     r.improvements,
        type:      ReportSectionType.improvement,
      ),
      const SizedBox(height: 10),

      // ── Next steps ────────────────────────────────────────────────────────
      ReportSectionTile(
        title:     'Recommended actions',
        icon:      Icons.flag_rounded,
        iconColor: AppColors.coach,
        iconBg:    AppColors.coachDim,
        items:     r.nextSteps,
        type:      ReportSectionType.action,
      ),
      const SizedBox(height: 18),

      // ── Footer ────────────────────────────────────────────────────────────
      Row(children: [
        Row(children: [
          Icon(
            report.cached
                ? Icons.cached_rounded
                : Icons.auto_awesome_rounded,
            color: AppColors.textTertiary, size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            'Generated ${_timeAgo(report.generatedAt)}',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ]),
        const Spacer(),
        FCButton(
          label:   regenerating ? 'Regenerating...' : 'Regenerate',
          loading: regenerating,
          variant: FCButtonVariant.ghost,
          size:    FCButtonSize.sm,
          leading: const Icon(Icons.refresh_rounded, size: 14,
              color: AppColors.textSecondary),
          onPressed: regenerating
              ? null
              : () => ref.read(reportProvider.notifier).regenerate(),
        ),
      ]),
    ]);
  }
}

class _CtxTile extends StatelessWidget {
  final String label, value;
  const _CtxTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.circular(12),
      border:       Border.all(color: AppColors.border2, width: 0.5),
    ),
    child: Column(children: [
      Text(value, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.3,
      )),
      Text(label, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      )),
    ]),
  ));
}