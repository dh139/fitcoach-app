import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "../../../../core/constants/app_colors.dart";
import "../../../../core/constants/app_text_styles.dart";

class LevelUpDialog extends StatefulWidget {
  final int previousLevel, newLevel, bonusXp;
  final VoidCallback onDismiss;
  const LevelUpDialog({super.key, required this.previousLevel, required this.newLevel, this.bonusXp = 0, this.onDismiss = _noop});

  static Future<void> show(BuildContext context, {required int previousLevel, required int newLevel, int bonusXp = 0}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => LevelUpDialog(previousLevel: previousLevel, newLevel: newLevel, bonusXp: bonusXp),
    );
  }
  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

void _noop() {}

class _LevelUpDialogState extends State<LevelUpDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 8), () { if (mounted) { Navigator.of(context).pop(); widget.onDismiss(); } });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.border1, width: 0.5),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 10))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Icon(Icons.star_rounded, color: AppColors.accent4, size: 32)
              .animate(delay: (200 * i).ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut))),
          const SizedBox(height: 20),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF0EA5E9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Center(child: Text("${widget.newLevel}", style: const TextStyle(fontFamily: "Syne", fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white))),
          ).animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text("Level Up!", style: AppTextStyles.displaySm.copyWith(color: AppColors.primary)).animate().fade(duration: 400.ms, delay: 400.ms),
          const SizedBox(height: 8),
          Text("${widget.previousLevel} \u2192 ${widget.newLevel}", style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary)).animate().fade(duration: 400.ms, delay: 500.ms),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: AppColors.accent4Dim, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.accent4Border, width: 0.5)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.bolt_rounded, size: 18, color: AppColors.accent4),
              const SizedBox(width: 6),
              Text("+${widget.bonusXp} Bonus XP", style: const TextStyle(fontFamily: "Inter", fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent4)),
            ]),
          ).animate().fade(duration: 400.ms, delay: 700.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () { Navigator.of(context).pop(); widget.onDismiss(); },
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Text("Keep Training", textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Inter", fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}
