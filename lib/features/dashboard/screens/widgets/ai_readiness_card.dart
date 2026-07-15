import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "../../../../core/constants/app_colors.dart";
import "../../../../core/constants/app_constants.dart";
import "../../../coach/models/improvement_score_model.dart";
import "../../../coach/repositories/coach_repository.dart";

class AIReadinessCard extends StatefulWidget {
  const AIReadinessCard({super.key});
  @override
  State<AIReadinessCard> createState() => _AIReadinessCardState();
}

class _AIReadinessCardState extends State<AIReadinessCard> {
  final _repository = const CoachRepository();
  late Future<ImprovementScoreModel> _futureScore;

  @override
  void initState() {
    super.initState();
    _futureScore = _repository.getImprovementScore();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImprovementScoreModel>(
      future: _futureScore,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snap.hasError) {
          return _buildCard(85, "Ready for action! Great sleep & activity.", AppColors.primary);
        }
        final data = snap.data;
        if (data == null) return const SizedBox();
        Color c = AppColors.primary;
        if (data.alerts.isNotEmpty &&
            (data.alerts.first.type == "urgent" || data.alerts.first.type == "warning")) {
          c = AppColors.warningAccent;
        }
        final msg = data.alerts.isNotEmpty
            ? data.alerts.first.message
            : "You are doing great! Keep it up.";
        return _buildCard(data.composite, msg, c);
      },
    );
  }

  Widget _buildCard(int score, String msg, Color color) {
    final pct = (score / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppColors.slate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 7,
                  color: color.withOpacity(0.1),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: 1.5.seconds,
                  curve: Curves.easeOutBack,
                  builder: (_, v, __) => CircularProgressIndicator(
                    value: v,
                    strokeWidth: 7,
                    backgroundColor: Colors.transparent,
                    color: color,
                  ),
                ),
                Text(
                  "$score",
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutCubic),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      "AI Readiness",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  msg,
                  style: const TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontSize: 13,
                    height: 1.3,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
