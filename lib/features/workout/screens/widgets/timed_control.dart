import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TimedControl extends StatelessWidget {
  final int          totalSeconds;
  final Function(int) onLog;

  const TimedControl({
    super.key,
    required this.totalSeconds,
    required this.onLog,
  });

  static const _options = [30, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.timer_outlined,
          color: AppColors.textTertiary, size: 16),
      const SizedBox(width: 6),
      const Text('Log time:', style: TextStyle(
        fontFamily: 'Inter', fontSize: 12,
        color: AppColors.textTertiary,
      )),
      const SizedBox(width: 8),
      Expanded(child: Row(
        children: _options.map((secs) => Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => onLog(secs),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color:        AppColors.surface3,
                borderRadius: BorderRadius.circular(10),
                border:       Border.all(color: AppColors.border3, width: 0.5),
              ),
              child: Text(
                '${secs}s',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ))).toList(),
      )),
      if (totalSeconds > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color:        AppColors.surface3,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${totalSeconds}s done',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
    ]);
  }
}