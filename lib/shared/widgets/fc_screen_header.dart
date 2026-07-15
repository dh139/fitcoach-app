import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FCScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String avatarInitials;
  final VoidCallback? onAvatarTap;
  final List<Widget> trailingActions;

  const FCScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.avatarInitials,
    this.onAvatarTap,
    this.trailingActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar with gradient ring
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AppColors.gradientHero,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: AppColors.surface1,
              child: Text(
                avatarInitials,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Text Greeting Hierarchy (two lines)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Trailing Action Buttons
        if (trailingActions.isNotEmpty) ...[
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: trailingActions,
          ),
        ],
      ],
    );
  }
}

class FCHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasBadge;

  const FCHeaderButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface1,
              border: Border.all(color: AppColors.border1, width: 1.0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          if (hasBadge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent2,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
