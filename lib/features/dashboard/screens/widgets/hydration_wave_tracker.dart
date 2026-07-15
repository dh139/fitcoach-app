import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../../../core/constants/app_colors.dart";
import "../../../../core/constants/app_constants.dart";
import "../../../../core/constants/app_text_styles.dart";

class HydrationWaveTracker extends StatefulWidget {
  const HydrationWaveTracker({super.key});
  @override
  State<HydrationWaveTracker> createState() => _HydrationWaveTrackerState();
}

class _HydrationWaveTrackerState extends State<HydrationWaveTracker> with TickerProviderStateMixin {
  static const _key = "hydration_ml";
  static const _goal = 2000;
  int _intake = 0;
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _intake = prefs.getInt(_key) ?? 0);
  }

  Future<void> _add250() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = (_intake + 250).clamp(0, _goal);
    await prefs.setInt(_key, newVal);
    setState(() => _intake = newVal);
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_intake / _goal).clamp(0.0, 1.0);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.water_drop_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              const Text(
                "Hydration",
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                "$_intake / $_goal ml",
                style: AppTextStyles.bodySm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryDim,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: 1.seconds,
                    builder: (_, value, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 12,
                        backgroundColor: AppColors.surface1,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "${(pct * 100).toInt()}%",
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _add250,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 0.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    "+ 250 ml",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
