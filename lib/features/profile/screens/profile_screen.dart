import 'package:fitcoach/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/fc_button.dart';
import '../../../shared/widgets/fc_loader.dart';
import '../../../shared/widgets/level_badge.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_stats_row.dart';
import 'widgets/tdee_calculator.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: FCLoader()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── App bar ──────────────────────────────────────────────
            SliverAppBar(
              pinned:          true,
              backgroundColor: AppColors.bg,
              expandedHeight:  0,
              toolbarHeight:   56,
              automaticallyImplyLeading: false,
              title: const Text('Profile', style: TextStyle(
                fontFamily:    'Inter',
                fontSize:      18,
                fontWeight:    FontWeight.w700,
                color:         AppColors.textPrimary,
                letterSpacing: -0.3,
              )),
              actions: [
                // Edit button
                GestureDetector(
                  onTap: () => EditProfileSheet.show(context, user),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color:        AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.border3, width: 0.5),
                    ),
                    child: const Row(children: [
                      Icon(Icons.edit_rounded,
                          color: AppColors.textSecondary, size: 15),
                      SizedBox(width: 6),
                      Text('Edit', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      )),
                    ]),
                  ),
                ),
              ],
            ),

            // ── Body ─────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pageHPad, 20,
                AppConstants.pageHPad, 40,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Avatar + name
                  ProfileAvatar(user: user),
                  const SizedBox(height: 24),

                  // Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:        AppColors.surface1,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border2, width: 0.5),
                    ),
                    child: ProfileStatsRow(user: user),
                  ),
                  const SizedBox(height: 16),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color:        AppColors.surface1,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border2, width: 0.5),
                    ),
                    child: Column(children: [
                      _InfoRow(Icons.person_outline_rounded,
                          'Goal', user.readableGoal),
                      const Divider(height: 16, color: AppColors.border2),
                      _InfoRow(Icons.directions_run_rounded,
                          'Activity', _actLabel(user.activityLevel)),
                      if (user.weight != null) ...[
                        const Divider(height: 16, color: AppColors.border2),
                        _InfoRow(Icons.monitor_weight_outlined,
                            'Weight', '${user.weight} kg'),
                      ],
                      if (user.height != null) ...[
                        const Divider(height: 16, color: AppColors.border2),
                        _InfoRow(Icons.height_rounded,
                            'Height', '${user.height} cm'),
                      ],
                      if (user.age != null) ...[
                        const Divider(height: 16, color: AppColors.border2),
                        _InfoRow(Icons.cake_outlined,
                            'Age', '${user.age} years'),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // TDEE Calculator
                  TdeeCalculator(user: user),
                  const SizedBox(height: 16),

                  // App Settings
                  const _Section('App settings'),
                  const SizedBox(height: 10),
                  Consumer(builder: (context, ref, _) {
                    return _NavTile(
                      icon:  Icons.notifications_active_rounded,
                      color: const Color(0xFF8B5CF6),
                      bg:    const Color(0xFF8B5CF6).withOpacity(0.15),
                      label: 'Daily AI Reminder',
                      sub:   'Receive custom workout push notifications',
                      onTap: () async {
                        final notifService =
                            ref.read(notificationServiceProvider);

                        // ✅ FIX: Always request permissions before scheduling.
                        // This ensures exact alarm permission is granted on
                        // Android 12+ before we try to set the alarm.
                        await notifService.requestPermission();

                        if (!context.mounted) return;

                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.brandPurple,
                                  surface: AppColors.surface1,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (time != null && context.mounted) {
                          // Schedule the exact daily recurring alarm
                          await notifService.scheduleDailyWorkoutReminder(
                            id: 1,
                            title: 'FitCoach AI Reminder ⚡',
                            body:
                                'Your dynamic workout plan is ready. Let\'s hit those targets today!',
                            hour: time.hour,
                            minute: time.minute,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Saved! Daily reminder set for ${time.format(context)}.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 24),

                  // Navigation shortcuts
                  const _Section('Quick navigation'),
                  const SizedBox(height: 10),
                  _NavTile(
                    icon:  Icons.history_rounded,
                    color: AppColors.lime,
                    bg:    AppColors.limeDim,
                    label: 'Workout history',
                    sub:   'View all past sessions and charts',
                    onTap: () => context.go('/history'),
                  ),
                  const SizedBox(height: 8),

                  _NavTile(
                    icon:  Icons.leaderboard_rounded,
                    color: const Color(0xFFFBBF24),
                    bg:    const Color(0x1AFBBF24),
                    label: 'Leaderboard',
                    sub:   'See your global ranking',
                    onTap: () => context.go('/leaderboard'),
                  ),
                  const SizedBox(height: 8),
                  _NavTile(
                    icon:  Icons.bar_chart_rounded,
                    color: AppColors.coach,
                    bg:    AppColors.coachDim,
                    label: 'AI reports',
                    sub:   'Daily, weekly, monthly insights',
                    onTap: () => context.go('/reports'),
                  ),
                  const SizedBox(height: 24),

                  // Logout
                  FCButton(
                    label:    'Sign out',
                    variant:  FCButtonVariant.danger,
                    fullWidth: true,
                    leading:  const Icon(Icons.logout_rounded,
                        size: 16, color: AppColors.danger),
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/auth/login');
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _actLabel(String level) => switch (level) {
    'sedentary'   => 'Sedentary',
    'light'       => 'Light (1–3 days/wk)',
    'moderate'    => 'Moderate (3–5 days/wk)',
    'active'      => 'Active (6–7 days/wk)',
    'very_active' => 'Very active (2× daily)',
    _             => level,
  };
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label, value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppColors.textTertiary, size: 16),
    const SizedBox(width: 10),
    Text(label, style: const TextStyle(
      fontFamily: 'Inter', fontSize: 13,
      color: AppColors.textSecondary,
    )),
    const Spacer(),
    Text(value, style: const TextStyle(
      fontFamily: 'Inter', fontSize: 13,
      fontWeight: FontWeight.w600, color: AppColors.textPrimary,
    )),
  ]);
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontFamily: 'Inter', fontSize: 13,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  ));
}

class _NavTile extends StatelessWidget {
  final IconData     icon;
  final Color        color, bg;
  final String       label, sub;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon, required this.color,
    required this.bg,   required this.label,
    required this.sub,  required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 13,
              fontWeight: FontWeight.w600, color: AppColors.textPrimary,
            )),
            Text(sub, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              color: AppColors.textTertiary,
            )),
          ],
        )),
        const Icon(Icons.chevron_right_rounded,
            color: AppColors.textTertiary, size: 18),
      ]),
    ),
  );
}