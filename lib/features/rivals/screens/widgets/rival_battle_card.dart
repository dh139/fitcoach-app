// lib/features/rivals/screens/widgets/rival_battle_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rival_model.dart';
import '../../providers/rival_provider.dart';

class RivalBattleCard extends ConsumerWidget {
  final RivalModel rival;
  final String currentUserId;

  const RivalBattleCard({
    super.key,
    required this.rival,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isChallenger = rival.challenger.id == currentUserId;
    final me = isChallenger ? rival.challenger : rival.challenged;
    final them = isChallenger ? rival.challenged : rival.challenger;

    final myScore    = _score(me);
    final theirScore = _score(them);
    final total      = myScore + theirScore;
    final myPct      = total > 0 ? myScore / total : 0.5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rival.isActive
              ? const Color(0xFFC8F53A).withOpacity(0.4)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: rival.isActive
                ? const Color(0xFFC8F53A).withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────
            Row(
              children: [
                _StatusBadge(status: rival.status),
                const Spacer(),
                if (rival.timeLeft.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(
                        rival.timeLeft,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Metric label ─────────────────────────────────────────
            Text(
              rival.metricLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.55),
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),

            // ── Players row ──────────────────────────────────────────
            Row(
              children: [
                _PlayerInfo(user: me, isYou: true, theme: theme),
                const Spacer(),
                _VsChip(theme: theme),
                const Spacer(),
                _PlayerInfo(user: them, isYou: false, theme: theme),
              ],
            ),

            const SizedBox(height: 16),

            // ── Progress bar ─────────────────────────────────────────
            if (rival.isActive || rival.isCompleted) ...[
              _BattleBar(myPct: myPct, theme: theme),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _formatScore(me, rival.metric),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFC8F53A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatScore(them, rival.metric),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ],

            // ── Pending actions ──────────────────────────────────────
            if (rival.isPending && !isChallenger) ...[
              const SizedBox(height: 14),
              _PendingActions(rivalId: rival.id, ref: ref, theme: theme),
            ],

            // ── Completed winner banner ──────────────────────────────
            if (rival.isCompleted) ...[
              const SizedBox(height: 14),
              _WinnerBanner(
                rival: rival,
                currentUserId: currentUserId,
                theme: theme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Score helpers ──────────────────────────────────────────────────────────

  int _score(RivalUser user) => switch (rival.metric) {
    'workouts' => user.stats.weeklyWorkouts,
    'streak'   => user.stats.streak,
    _          => user.stats.xp,
  };

  String _formatScore(RivalUser user, String metric) {
    final s = _score(user);
    return switch (metric) {
      'workouts' => '$s workouts',
      'streak'   => '$s day streak',
      _          => '$s XP',
    };
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active'    => ('Active', const Color(0xFFC8F53A)),
      'pending'   => ('Pending', Colors.amber),
      'completed' => ('Completed', Colors.blueAccent),
      _           => ('Declined', Colors.redAccent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerInfo extends StatelessWidget {
  final RivalUser user;
  final bool isYou;
  final ThemeData theme;
  const _PlayerInfo({
    required this.user,
    required this.isYou,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isYou ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: isYou
              ? const Color(0xFFC8F53A).withOpacity(0.2)
              : theme.colorScheme.onSurface.withOpacity(0.1),
          child: Text(
            user.initials,
            style: TextStyle(
              color: isYou
                  ? const Color(0xFFC8F53A)
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isYou ? 'You' : user.name.split(' ').first,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          user.stats.level,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.45),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _VsChip extends StatelessWidget {
  final ThemeData theme;
  const _VsChip({required this.theme});

  @override
  Widget build(BuildContext context) => Text(
        'VS',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.onSurface.withOpacity(0.2),
          letterSpacing: 2,
        ),
      );
}

class _BattleBar extends StatelessWidget {
  final double myPct;
  final ThemeData theme;
  const _BattleBar({required this.myPct, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            Flexible(
              flex: (myPct * 100).round(),
              child: Container(color: const Color(0xFFC8F53A)),
            ),
            Flexible(
              flex: ((1 - myPct) * 100).round(),
              child: Container(
                  color: theme.colorScheme.onSurface.withOpacity(0.12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingActions extends StatelessWidget {
  final String rivalId;
  final WidgetRef ref;
  final ThemeData theme;
  const _PendingActions({
    required this.rivalId,
    required this.ref,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(rivalProvider).actionLoading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: loading
                ? null
                : () => ref.read(rivalProvider.notifier).respond(rivalId, false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: theme.colorScheme.error.withOpacity(0.5)),
              foregroundColor: theme.colorScheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Decline'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: loading
                ? null
                : () => ref.read(rivalProvider.notifier).respond(rivalId, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC8F53A),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                : const Text('Accept',
                    style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

class _WinnerBanner extends StatelessWidget {
  final RivalModel rival;
  final String currentUserId;
  final ThemeData theme;
  const _WinnerBanner({
    required this.rival,
    required this.currentUserId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final iWon = rival.winner == currentUserId;
    final color = iWon ? const Color(0xFFC8F53A) : Colors.redAccent;
    final label = iWon ? '🏆 You won!' : '💀 You lost';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}