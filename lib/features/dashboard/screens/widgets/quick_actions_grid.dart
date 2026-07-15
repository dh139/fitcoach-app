import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "../../../../core/constants/app_colors.dart";
import "../../../../core/constants/app_constants.dart";
import "../../../../core/constants/app_text_styles.dart";

class _ActionItem {
  final String route, label, sub;
  final IconData icon;
  final Color iconColor, iconBg;
  const _ActionItem({
    required this.route,
    required this.label,
    required this.sub,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

// Enforce neutral icon treatments for secondary menu items
final _actions = [
  const _ActionItem(
    route: "/workout",
    label: "Start workout",
    sub: "Earn XP now",
    icon: Icons.fitness_center_rounded,
    iconColor: AppColors.primary,
    iconBg: AppColors.primaryDim,
  ),
  const _ActionItem(
    route: "/exercises",
    label: "Exercises",
    sub: "Browse library",
    icon: Icons.menu_book_rounded,
    iconColor: AppColors.textSecondary,
    iconBg: AppColors.surface2,
  ),
  const _ActionItem(
    route: "/calories",
    label: "Calories",
    sub: "Track meals",
    icon: Icons.local_fire_department_rounded,
    iconColor: AppColors.textSecondary,
    iconBg: AppColors.surface2,
  ),
  const _ActionItem(
    route: "/reports",
    label: "AI reports",
    sub: "Weekly insights",
    icon: Icons.bar_chart_rounded,
    iconColor: AppColors.textSecondary,
    iconBg: AppColors.surface2,
  ),
  const _ActionItem(
    route: "/leaderboard",
    label: "Leaderboard",
    sub: "See your rank",
    icon: Icons.emoji_events_rounded,
    iconColor: AppColors.textSecondary,
    iconBg: AppColors.surface2,
  ),
  const _ActionItem(
    route: "/coach",
    label: "AI coach",
    sub: "Chat now",
    icon: Icons.smart_toy_rounded,
    iconColor: AppColors.primary,
    iconBg: AppColors.primaryDim,
  ),
  const _ActionItem(
    route: "/rivals",
    label: "Rivals",
    sub: "Challenge friends",
    icon: Icons.sports_kabaddi_rounded,
    iconColor: AppColors.textSecondary,
    iconBg: AppColors.surface2,
  ),
];

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick actions", style: AppTextStyles.h3),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (_, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            final spacing = 10.0;
            final childWidth =
                ((constraints.maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount) - 0.1;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _actions
                  .map((a) => SizedBox(width: childWidth, child: _ActionCard(item: a)))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: AppColors.slate, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: item.iconColor.withOpacity(0.15), width: 0.5),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label,
                    style: AppTextStyles.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    item.sub,
                    style: AppTextStyles.label.copyWith(fontSize: 9, letterSpacing: 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
