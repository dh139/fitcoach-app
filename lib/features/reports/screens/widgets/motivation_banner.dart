import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MotivationBanner extends StatelessWidget {
  final String message;
  const MotivationBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.coachDim,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.coachBorder, width: 0.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color:        AppColors.coachDim,
            borderRadius: BorderRadius.circular(9),
            border:       Border.all(color: AppColors.coachBorder, width: 0.5),
          ),
          child: const Icon(Icons.smart_toy_rounded,
              color: AppColors.coach, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(
          '"$message"',
          style: const TextStyle(
            fontFamily:  'Inter',
            fontSize:    13,
            fontStyle:   FontStyle.italic,
            color:       Color(0xFFD8B4FE),
            height:      1.55,
          ),
        )),
      ]),
    );
  }
}