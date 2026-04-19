import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../providers/step_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color:  AppColors.surface2,
              shape:  BoxShape.circle,
            ),
            child: ClipOval(
              child: Center(
                child: Text(
                  user?.initials ?? '?',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.lime,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Centered Header Text
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello, ${user?.name ?? "Athlete"}',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
            ),
            Builder(
              builder: (context) {
                final now = DateTime.now();
                final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                return Text(
                  'Today ${now.day} ${months[now.month - 1]}.',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary),
                );
              }
            ),
          ],
        ),

        // Actions
        Row(
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color:  AppColors.surface1,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border2, width: 1.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_walk_rounded, size: 16, color: AppColors.lime),
                  const SizedBox(width: 4),
                  Consumer(
                    builder: (context, ref, _) {
                      final stepState = ref.watch(stepProvider);
                      return Text(
                        '${stepState.stepsToday}',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 13,
                          fontWeight: FontWeight.w700, color: AppColors.textPrimary
                        ),
                      );
                    }
                  ),
                ]
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color:  AppColors.surface1,
                shape:  BoxShape.circle,
                border: Border.all(color: AppColors.border2, width: 1.0),
              ),
              child: IconButton(
                icon: const Icon(Icons.history_rounded, size: 20, color: AppColors.textPrimary),
                onPressed: () => context.go('/history'),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color:  AppColors.surface1,
                shape:  BoxShape.circle,
                border: Border.all(color: AppColors.border2, width: 1.0),
              ),
              child: IconButton(
                icon: const Icon(Icons.settings_rounded, size: 20, color: AppColors.textPrimary),
                onPressed: () => context.go('/profile'),
              ),
            ),
          ]
        ),
      ]
    );
  }
}