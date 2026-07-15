import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/leaderboard_model.dart';

/// Signature top-3 podium on a deep forest panel. Champion centred and raised,
/// runners-up flanking. Falls back gracefully with fewer than 3 athletes.
class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardEntry> top;
  final String myUserId;

  const LeaderboardPodium({
    super.key,
    required this.top,
    required this.myUserId,
  });

  @override
  Widget build(BuildContext context) {
    LeaderboardEntry? at(int rank) {
      for (final e in top) {
        if (e.rank == rank) return e;
      }
      return null;
    }

    final first = at(1);
    final second = at(2);
    final third = at(3);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientHero,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _column(second, height: 78, medal: '🥈', accent: const Color(0xFFC7D0DA))),
          Expanded(child: _column(first, height: 108, medal: '🥇', accent: AppColors.lime, champion: true)),
          Expanded(child: _column(third, height: 60, medal: '🥉', accent: const Color(0xFFD8A878))),
        ],
      ),
    );
  }

  Widget _column(LeaderboardEntry? e, {
    required double height,
    required String medal,
    required Color accent,
    bool champion = false,
  }) {
    if (e == null) return const SizedBox.shrink();
    final isMe = e.userId == myUserId;
    final avatarSize = champion ? 62.0 : 50.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (champion)
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Icon(Icons.emoji_events_rounded, color: AppColors.lime, size: 22),
          ),
        // Avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [accent, accent.withValues(alpha: 0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: AppColors.forestDeep,
            child: Text(
              e.initials,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: champion ? 20 : 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          e.name.split(' ').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isMe ? AppColors.lime : Colors.white,
          ),
        ),
        Text(
          '${_fmt(e.totalScore)} pts',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 8),
        // Pedestal
        Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: champion ? 0.14 : 0.09),
                Colors.white.withValues(alpha: 0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            border: Border.all(color: accent.withValues(alpha: 0.4), width: 1),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(medal, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 2),
                Text(
                  '#${e.rank}',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
