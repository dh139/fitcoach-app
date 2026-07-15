import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/models/user_model.dart';

class ProfileStatsRow extends StatelessWidget {
  final UserModel user;
  const ProfileStatsRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _Tile('${user.totalWorkouts}',          'workouts'),
      _Divider(),
      _Tile('${user.streak}d',                'streak'),
      _Divider(),
      _Tile('${user.totalCaloriesBurned}',    'cal burned'),
      _Divider(),
      _Tile('${user.streakFreezeCount}',      'freezes'),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final String value, label;
  const _Tile(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(
      fontFamily:    'Inter',
      fontSize:      18,
      fontWeight:    FontWeight.w700,
      color:         AppColors.textPrimary,
      letterSpacing: -0.4,
    )),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(
      fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w600,
      color: AppColors.textTertiary, letterSpacing: 0.5,
    )),
  ]));
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1.0, height: 32,
    color: AppColors.slate,
  );
}