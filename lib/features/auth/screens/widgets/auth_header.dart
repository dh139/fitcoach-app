import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color:        AppColors.lime,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.fitness_center_rounded,
            color: AppColors.bg, size: 20),
      ),
      const SizedBox(width: 10),
      const Text('FitCoach AI', style: TextStyle(
        fontFamily:  'Inter',
        fontSize:    17,
        fontWeight:  FontWeight.w700,
        color:       AppColors.lime,
        letterSpacing: -0.3,
      )),
    ]);
  }
}