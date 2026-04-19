import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ChartCard extends StatelessWidget {
  final String  title;
  final String  subtitle;
  final IconData icon;
  final Color   iconColor;
  final Color   iconBg;
  final Widget  chart;

  const ChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color:        iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                fontFamily:  'Inter',
                fontSize:    13,
                fontWeight:  FontWeight.w600,
                color:       AppColors.textPrimary,
              )),
              Text(subtitle, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 10,
                color: AppColors.textTertiary,
              )),
            ],
          )),
        ]),
        const SizedBox(height: 18),
        SizedBox(height: 160, child: chart),
      ]),
    );
  }
}