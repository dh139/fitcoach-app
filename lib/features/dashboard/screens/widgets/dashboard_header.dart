import 'package:fitcoach/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/widgets/fc_screen_header.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final name = user?.name.split(' ').first ?? 'Athlete';

    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = "Good Morning ☀️";
    } else if (hour < 17) {
      greeting = "Good Afternoon 🌤️";
    } else if (hour < 21) {
      greeting = "Good Evening 🌤️";
    } else {
      greeting = "Good Night 🌙";
    }

    return SizedBox(
      height: 60,
      child: Row(
        children: [
          // Left Grid Menu Icon Button
      
          const SizedBox(width: 14),

          // Centered Welcome Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  "Hello $name!",
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Right Circular Profile Photo Button
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textPrimary, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: CircleAvatar(
                  backgroundColor: AppColors.surface2,
                  child: Text(
                    user?.initials ?? '?',
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
