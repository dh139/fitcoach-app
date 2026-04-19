import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DecayWarningBanner extends StatelessWidget {
  final int? daysInactive;
  const DecayWarningBanner({super.key, this.daysInactive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color:        AppColors.dangerDim,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.dangerBorder, width: 0.5),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded,
            color: AppColors.danger, size: 18),
        const SizedBox(width: 10),
        Expanded(child: RichText(text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Inter', fontSize: 12,
            color: Color(0xFFFF8888), height: 1.4,
          ),
          children: [
            const TextSpan(
              text: 'XP decay is active — ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: daysInactive != null
                ? 'you haven\'t worked out in $daysInactive days. '
                : '',
            ),
            const TextSpan(text: 'Work out now to stop losing XP.'),
          ],
        ))),
      ]),
    );
  }
}