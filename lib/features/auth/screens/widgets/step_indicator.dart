import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int total;
  final int current;

  const StepIndicator({super.key, required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(total, (i) {
      final active = i <= current;
      return Expanded(child: Container(
        height: 3,
        margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
        decoration: BoxDecoration(
          color:        active ? AppColors.lime : AppColors.surface3,
          borderRadius: BorderRadius.circular(2),
        ),
      ));
    }));
  }
}