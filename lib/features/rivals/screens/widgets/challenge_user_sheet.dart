import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../models/rival_model.dart';
import '../../providers/rival_provider.dart';

class ChallengeUserSheet extends ConsumerStatefulWidget {
  final RivalSuggestion suggestion;

  const ChallengeUserSheet({super.key, required this.suggestion});

  static Future<void> show(
    BuildContext context,
    RivalSuggestion suggestion,
  ) => showModalBottomSheet(
    context:            context,
    backgroundColor:    Colors.transparent,
    isScrollControlled: true,
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child:  ChallengeUserSheet(suggestion: suggestion),
    ),
  );

  @override
  ConsumerState<ChallengeUserSheet> createState() =>
      _ChallengeUserSheetState();
}

class _ChallengeUserSheetState extends ConsumerState<ChallengeUserSheet> {
  String _metric   = 'xp';
  int    _duration = 7;

  static const _metrics = [
    (v: 'xp',        l: 'Most XP'),
    (v: 'workouts',  l: 'Most workouts'),
    (v: 'calories',  l: 'Most calories'),
    (v: 'streak',    l: 'Longest streak'),
  ];

  static const _durations = [3, 7, 14];

  Future<void> _send() async {
    final ok = await ref.read(rivalProvider.notifier).challenge(
      userId:   widget.suggestion.id,
      metric:   _metric,
      duration: _duration,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(
        rivalProvider.select((s) => s.actionLoading));

    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color:        AppColors.border3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Opponent info
            Row(children: [
              Container(
                width: 46, height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.surface3, shape: BoxShape.circle),
                child: Center(child: Text(
                  widget.suggestion.initials,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.suggestion.name, style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 15,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                  )),
                  Text(widget.suggestion.reason, style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 11,
                    color: AppColors.textTertiary,
                  )),
                ],
              )),
            ]),
            const SizedBox(height: 20),

            // Metric selector
            const Align(alignment: Alignment.centerLeft,
              child: Text('CHALLENGE TYPE', style: TextStyle(
                fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
                color: AppColors.textTertiary, letterSpacing: 0.9,
              )),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount:   2,
              shrinkWrap:       true,
              physics:          const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing:  8,
              childAspectRatio: 3.5,
              children: _metrics.map((m) {
                final sel = _metric == m.v;
                return GestureDetector(
                  onTap: () => setState(() => _metric = m.v),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sel ? AppColors.limeDim : AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? AppColors.limeBorder : AppColors.border3,
                        width: sel ? 1 : 0.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(m.l, style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? AppColors.lime : AppColors.textSecondary,
                    )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Duration selector
            const Align(alignment: Alignment.centerLeft,
              child: Text('DURATION', style: TextStyle(
                fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
                color: AppColors.textTertiary, letterSpacing: 0.9,
              )),
            ),
            const SizedBox(height: 8),
            Row(children: _durations.map((d) {
              final sel = _duration == d;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _duration = d),
                child: Container(
                  margin: EdgeInsets.only(
                      right: d != _durations.last ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.lime : AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel ? AppColors.lime : AppColors.border3,
                      width: 0.5,
                    ),
                  ),
                  child: Column(children: [
                    Text('$d', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: sel ? AppColors.bg : AppColors.textPrimary,
                    )),
                    Text('days', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 10,
                      color: sel ? AppColors.bg : AppColors.textTertiary,
                    )),
                  ]),
                ),
              ));
            }).toList()),
            const SizedBox(height: 20),

            FCButton(
              label:    loading ? 'Sending…' : 'Send challenge ⚔️',
              loading:  loading,
              fullWidth: true,
              size:     FCButtonSize.lg,
              onPressed: loading ? null : _send,
            ),
          ]),
        ),
      ),
    );
  }
}