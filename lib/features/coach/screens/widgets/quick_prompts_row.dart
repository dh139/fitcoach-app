import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

final _quickPrompts = [
  (icon: Icons.fitness_center_rounded,         label: 'Workout plan',
   prompt: 'Create a personalised workout plan for me based on my fitness goal and current level.'),
  (icon: Icons.restaurant_rounded,             label: 'Indian diet tips',
   prompt: 'Give me Indian-friendly meal suggestions for my fitness goal with calorie counts.'),
  (icon: Icons.trending_up_rounded,            label: 'Explain my score',
   prompt: 'Explain my improvement score and tell me exactly what I need to do to increase it.'),
  (icon: Icons.psychology_rounded,             label: 'Motivation',
   prompt: 'I need motivation. Remind me why I started and give me a push to work out today.'),
  (icon: Icons.warning_amber_rounded,          label: 'Plateau advice',
   prompt: 'I feel stuck and not progressing. What should I change in my routine?'),
  (icon: Icons.health_and_safety_rounded,       label: 'Recovery tips',
   prompt: 'What are the best recovery strategies between workouts for my level?'),
  (icon: Icons.egg_alt_rounded,                label: 'Protein sources',
   prompt: 'What are the best high-protein Indian foods I should eat for muscle building?'),
  (icon: Icons.calendar_today_rounded,         label: 'Next workout',
   prompt: 'Based on my recent sessions, what should my next workout focus on?'),
];

class QuickPromptsRow extends StatelessWidget {
  final ValueChanged<String> onSelected;
  final bool                 disabled;

  const QuickPromptsRow({
    super.key,
    required this.onSelected,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding:         const EdgeInsets.symmetric(horizontal: 16),
      itemCount:       _quickPrompts.length,
      itemBuilder: (_, i) {
        final p = _quickPrompts[i];
        return GestureDetector(
          onTap: disabled ? null : () => onSelected(p.prompt),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:        disabled
                  ? AppColors.surface2
                  : AppColors.surface2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: disabled
                    ? AppColors.border2
                    : AppColors.border3,
                width: 0.5,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(p.icon,
                  color: disabled
                      ? AppColors.textTertiary
                      : AppColors.textSecondary,
                  size: 13),
              const SizedBox(width: 6),
              Text(p.label, style: TextStyle(
                fontFamily:  'Inter',
                fontSize:    12,
                fontWeight:  FontWeight.w600,
                color: disabled
                    ? AppColors.textTertiary
                    : AppColors.textSecondary,
              )),
            ]),
          ),
        );
      },
    ),
  );
}