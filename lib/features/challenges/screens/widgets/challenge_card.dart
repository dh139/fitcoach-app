import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_badge.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../models/challenge_model.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final bool           claiming;
  final VoidCallback   onClaim;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.claiming,
    required this.onClaim,
  });

  (Color, Color, IconData) get _catStyle => switch (challenge.category) {
    'workout'  => (AppColors.lime,                AppColors.limeDim,
                   Icons.fitness_center_rounded),
    'calories' => (const Color(0xFFFF8C42),        const Color(0x1AFF6B00),
                   Icons.local_fire_department_rounded),
    'streak'   => (const Color(0xFFF59E0B),        const Color(0x1AF59E0B),
                   Icons.local_fire_department_rounded),
    _          => (const Color(0xFFFBBF24),         const Color(0x1AFBBF24),
                   Icons.bolt_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = _catStyle;
    final pct               = challenge.progressPct;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: challenge.claimed
              ? AppColors.border2
              : challenge.canClaim
              ? AppColors.limeBorder
              : AppColors.border2,
          width: challenge.canClaim ? 1 : 0.5,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // ── Header ──────────────────────────────────────────────────────
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color:        challenge.claimed
                  ? AppColors.surface2 : bg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon,
              color: challenge.claimed ? AppColors.textTertiary : color,
              size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(challenge.title, style: TextStyle(
                fontFamily: 'Inter', fontSize: 13,
                fontWeight: FontWeight.w600,
                color: challenge.claimed
                    ? AppColors.textTertiary : AppColors.textPrimary,
              )),
              Text(challenge.description, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 10,
                color: AppColors.textTertiary,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          )),
          const SizedBox(width: 8),
          FCBadge(
            label:   challenge.type.toUpperCase(),
            variant: challenge.type == 'daily'
                ? FCBadgeVariant.blue : FCBadgeVariant.purple,
          ),
        ]),
        const SizedBox(height: 14),

        // ── Progress bar ─────────────────────────────────────────────────
        Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(
                  '${challenge.current} / ${challenge.target}',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: challenge.claimed
                        ? AppColors.textTertiary : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (challenge.timeRemaining.isNotEmpty)
                  Text(challenge.timeRemaining, style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    color: AppColors.textTertiary,
                  )),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value:           pct,
                  backgroundColor: AppColors.surface3,
                  valueColor: AlwaysStoppedAnimation(
                    challenge.claimed
                        ? AppColors.surface4
                        : pct >= 1.0 ? AppColors.lime : color,
                  ),
                  minHeight: 5,
                ),
              ),
            ],
          )),
        ]),
        const SizedBox(height: 12),

        // ── Reward + action ───────────────────────────────────────────────
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color:        const Color(0x1AFBBF24),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.bolt_rounded,
                  color: Color(0xFFFBBF24), size: 13),
              const SizedBox(width: 4),
              Text('+${challenge.xpReward} XP',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFBBF24),
                )),
            ]),
          ),
          const Spacer(),
          if (challenge.claimed)
            const Row(children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.textTertiary, size: 15),
              SizedBox(width: 5),
              Text('Claimed', style: TextStyle(
                fontFamily: 'Inter', fontSize: 12,
                color: AppColors.textTertiary,
              )),
            ])
          else if (challenge.canClaim)
            FCButton(
              label:    claiming ? 'Claiming…' : 'Claim XP',
              loading:  claiming,
              size:     FCButtonSize.sm,
              leading:  const Icon(Icons.bolt_rounded,
                  size: 14, color: AppColors.onLime),
              onPressed: onClaim,
            )
          else
            Text(
              '${(pct * 100).round()}% complete',
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
        ]),
      ]),
    );
  }
}