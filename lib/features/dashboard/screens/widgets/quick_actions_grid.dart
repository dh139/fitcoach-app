import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class _ActionItem {
  final String   route;
  final String   label;
  final String   sub;
  final IconData icon;
  final Color    iconColor;
  final Color    iconBg;

  const _ActionItem({
    required this.route,
    required this.label,
    required this.sub,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

const _actions = [
  _ActionItem(
    route:     '/workout',
    label:     'Start workout',
    sub:       'Earn XP now',
    icon:      Icons.fitness_center_rounded,
    iconColor: AppColors.lime,
    iconBg:    AppColors.limeDim,
  ),
  _ActionItem(
    route:     '/exercises',
    label:     'Exercises',
    sub:       'Browse library',
    icon:      Icons.menu_book_rounded,
    iconColor: Color(0xFFC084FC),
    iconBg:    Color(0x1AC084FC),
  ),
  _ActionItem(
    route:     '/calories',
    label:     'Calories',
    sub:       'Track meals',
    icon:      Icons.local_fire_department_rounded,
    iconColor: Color(0xFFFF8C42),
    iconBg:    Color(0x1AFF6B00),
  ),
  _ActionItem(
    route:     '/reports',
    label:     'AI reports',
    sub:       'Weekly insights',
    icon:      Icons.bar_chart_rounded,
    iconColor: Color(0xFF5EEAD4),
    iconBg:    Color(0x1A5EEAD4),
  ),
  _ActionItem(
    route:     '/leaderboard',
    label:     'Leaderboard',
    sub:       'See your rank',
    icon:      Icons.emoji_events_rounded,
    iconColor: Color(0xFFFBBF24),
    iconBg:    Color(0x1AFBBF24),
  ),
  _ActionItem(
    route:     '/coach',
    label:     'AI coach',
    sub:       'Chat now',
    icon:      Icons.smart_toy_rounded,
    iconColor: AppColors.coach,
    iconBg:    AppColors.coachDim,
  ),
  _ActionItem(
    route:     '/rivals',
    label:     'Rivals',
    sub:       'Challenge friends',
    icon:      Icons.sports_kabaddi_rounded,
    iconColor: Color(0xFFEF4444),
    iconBg:    Color(0x1AEF4444),
  ),
];

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick actions', style: AppTextStyles.h3),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          final spacing = 10.0;
          final childWidth = ((constraints.maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount) - 0.1;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: _actions.map((a) => SizedBox(
              width: childWidth,
              child: _ActionCard(item: a)
            )).toList(),
          );
        }
      ),
    ]);
  }
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  const _ActionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ]
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:        item.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              Text(item.label, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(item.sub, style: AppTextStyles.label.copyWith(fontSize: 9, letterSpacing: 0)),
            ],
          )),
        ]),
      ),
    );
  }
}