import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/models/user_model.dart';

class TdeeCalculator extends StatelessWidget {
  final UserModel user;
  const TdeeCalculator({super.key, required this.user});

  int get _tdee {
    final w = user.weight ?? 70.0;
    final h = user.height ?? 170.0;
    final a = user.age    ?? 25;

    // Mifflin-St Jeor BMR
    final bmr = user.gender == 'female'
        ? (10 * w) + (6.25 * h) - (5 * a) - 161
        : (10 * w) + (6.25 * h) - (5 * a) + 5;

    final multiplier = switch (user.activityLevel) {
      'sedentary'   => 1.2,
      'light'       => 1.375,
      'moderate'    => 1.55,
      'active'      => 1.725,
      'very_active' => 1.9,
      _             => 1.55,
    };

    return (bmr * multiplier).round();
  }

  int get _goalCalories => switch (user.fitnessGoal) {
    'lose_weight'  => _tdee - 500,
    'gain_weight'  => _tdee + 500,
    'build_muscle' => _tdee + 200,
    _              => _tdee,
  };

  String get _goalLabel => switch (user.fitnessGoal) {
    'lose_weight'  => 'Deficit (−500 kcal)',
    'gain_weight'  => 'Surplus (+500 kcal)',
    'build_muscle' => 'Lean bulk (+200 kcal)',
    _              => 'Maintenance',
  };

  @override
  Widget build(BuildContext context) {
    final hasMeasurements =
        user.weight != null && user.height != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(22),
        border:       Border.all(color: AppColors.slate, width: 1.0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color:        const Color(0x1A22C55E),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.calculate_outlined,
                color: Color(0xFF22C55E), size: 17),
          ),
          const SizedBox(width: 10),
          const Text('TDEE calculator', style: TextStyle(
            fontFamily: 'Inter', fontSize: 13,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary,
          )),
        ]),
        const SizedBox(height: 14),

        if (!hasMeasurements) ...[
          const Text(
            'Add your weight and height in profile to see your personalised calorie targets.',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 13,
              color: AppColors.textTertiary, height: 1.5,
            ),
          ),
        ] else ...[
          Row(children: [
            _ValueBox(
              label: 'Maintenance\n(TDEE)',
              value: '$_tdee',
              suffix: 'kcal/day',
              color: AppColors.lime,
            ),
            const SizedBox(width: 10),
            _ValueBox(
              label: _goalLabel,
              value: '$_goalCalories',
              suffix: 'kcal/day',
              color: const Color(0xFF60A5FA),
            ),
          ]),
          const SizedBox(height: 12),

          // Measurement strip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color:        AppColors.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              _Metric('Weight', '${user.weight?.round() ?? '—'}kg'),
              const SizedBox(width: 16),
              _Metric('Height', '${user.height?.round() ?? '—'}cm'),
              const SizedBox(width: 16),
              _Metric('Age',    '${user.age ?? '—'}'),
              const SizedBox(width: 16),
              _Metric('Goal',   user.readableGoal),
            ]),
          ),
          const SizedBox(height: 8),
          const Text(
            'Calculated using Mifflin-St Jeor formula',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 9,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ]),
    );
  }
}

class _ValueBox extends StatelessWidget {
  final String label, value, suffix;
  final Color  color;
  const _ValueBox({
    required this.label, required this.value,
    required this.suffix, required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color:        AppColors.surface2,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w600,
        color: AppColors.textTertiary, letterSpacing: 0.5, height: 1.4,
      )),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(
        fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w800,
        color: AppColors.textPrimary, letterSpacing: -0.5, height: 1.0,
      )),
      Text(suffix, style: TextStyle(
        fontFamily: 'Inter', fontSize: 10, color: color,
        fontWeight: FontWeight.w600,
      )),
    ]),
  ));
}

class _Metric extends StatelessWidget {
  final String label, value;
  const _Metric(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(
      fontFamily: 'Inter', fontSize: 11,
      fontWeight: FontWeight.w600, color: AppColors.textPrimary,
    )),
    Text(label, style: const TextStyle(
      fontFamily: 'Inter', fontSize: 9,
      color: AppColors.textTertiary,
    )),
  ]);
}