import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/fc_badge.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../../../shared/widgets/level_badge.dart';
import '../../models/rival_model.dart';

class RivalTile extends StatelessWidget {
  final RivalModel   rival;
  final String       myUserId;
  final bool         actionLoading;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const RivalTile({
    super.key,
    required this.rival,
    required this.myUserId,
    required this.actionLoading,
    required this.onAccept,
    required this.onDecline,
  });

  bool get _iAmChallenger => rival.challenger.id == myUserId;

  RivalUser get _opponent =>
      _iAmChallenger ? rival.challenged : rival.challenger;

  RivalUser get _me =>
      _iAmChallenger ? rival.challenger : rival.challenged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rival.isPending
              ? AppColors.warnDim
              : rival.isActive
              ? AppColors.limeBorder : AppColors.border2,
          width: rival.isActive ? 1 : 0.5,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // ── Header: vs. row ──────────────────────────────────────────
        Row(children: [
          _Avatar(user: _me,       isMe: true),
          Expanded(child: Column(children: [
            Text('VS', style: TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              fontWeight: FontWeight.w800,
              color: rival.isActive
                  ? AppColors.danger : AppColors.textTertiary,
              letterSpacing: 1.0,
            )),
            Text(rival.metricLabel, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 9,
              color: AppColors.textTertiary,
            ), textAlign: TextAlign.center),
          ])),
          _Avatar(user: _opponent, isMe: false),
        ]),
        const SizedBox(height: 12),

        // ── Metric + time ────────────────────────────────────────────
        Row(children: [
          FCBadge(
            label:   rival.status.toUpperCase(),
            variant: rival.isPending
                ? FCBadgeVariant.amber
                : rival.isActive
                ? FCBadgeVariant.lime : FCBadgeVariant.gray,
          ),
          const SizedBox(width: 8),
          FCBadge(
            label:   rival.metricLabel,
            variant: FCBadgeVariant.gray,
          ),
          const Spacer(),
          if (rival.timeLeft.isNotEmpty)
            Text(rival.timeLeft, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              color: AppColors.textTertiary,
            )),
        ]),

        // ── Action buttons (pending + incoming only) ─────────────────
        if (rival.isPending && !_iAmChallenger) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FCButton(
              label:    'Decline',
              variant:  FCButtonVariant.danger,
              fullWidth: true,
              size:     FCButtonSize.sm,
              onPressed: actionLoading ? null : onDecline,
            )),
            const SizedBox(width: 10),
            Expanded(child: FCButton(
              label:    actionLoading ? 'Accepting…' : 'Accept',
              loading:  actionLoading,
              fullWidth: true,
              size:     FCButtonSize.sm,
              onPressed: actionLoading ? null : onAccept,
            )),
          ]),
        ],

        if (rival.isPending && _iAmChallenger) ...[
          const SizedBox(height: 8),
          const Text('Waiting for opponent to accept…',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            )),
        ],
      ]),
    );
  }
}

class _Avatar extends StatelessWidget {
  final RivalUser user;
  final bool      isMe;
  const _Avatar({required this.user, required this.isMe});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        shape:  BoxShape.circle,
        color:  isMe ? AppColors.lime : AppColors.surface3,
        border: Border.all(
          color: isMe ? AppColors.limeBorder : AppColors.border3,
          width: 0.5,
        ),
      ),
      child: Center(child: Text(
        user.initials,
        style: TextStyle(
          fontFamily: 'Inter', fontSize: 14,
          fontWeight: FontWeight.w800,
          color: isMe ? AppColors.bg : AppColors.textSecondary,
        ),
      )),
    ),
    const SizedBox(height: 4),
    LevelBadge(level: user.stats.level, fontSize: 9),
    Text('${user.stats.xp ~/ 1000}k XP',
      style: const TextStyle(
        fontFamily: 'Inter', fontSize: 10,
        color: AppColors.textTertiary,
      )),
  ]);
}