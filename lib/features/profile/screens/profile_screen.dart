import 'package:fitcoach/core/services/notification_service.dart';
import 'package:fitcoach/features/dashboard/providers/step_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/fc_button.dart';
import '../../../shared/widgets/fc_loader.dart';

import 'widgets/edit_profile_sheet.dart';
import 'widgets/profile_hero_card.dart';
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
        bottom: false,
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
            ),

            // ── Body ─────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pageHPad, 20,
                AppConstants.pageHPad, 40,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Premium profile hero (avatar + identity + headline stats)
                  ProfileHeroCard(
                    user: user,
                    onEdit: () => EditProfileSheet.show(context, user),
                  ),
                  const SizedBox(height: 16),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:        AppColors.surface1,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.slate, width: 1.0),
                    ),
                    child: Column(children: [
                      _InfoRow(Icons.person_outline_rounded,
                          'Goal', user.readableGoal),
                      const Divider(height: 20, color: AppColors.slate),
                      _InfoRow(Icons.directions_run_rounded,
                          'Activity', _actLabel(user.activityLevel)),
                      if (user.weight != null) ...[
                        const Divider(height: 20, color: AppColors.slate),
                        _InfoRow(Icons.monitor_weight_outlined,
                            'Weight', '${user.weight} kg'),
                      ],
                      if (user.height != null) ...[
                        const Divider(height: 20, color: AppColors.slate),
                        _InfoRow(Icons.height_rounded,
                            'Height', '${user.height} cm'),
                      ],
                      if (user.age != null) ...[
                        const Divider(height: 20, color: AppColors.slate),
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
                      color: AppColors.primary,
                      bg:    AppColors.primaryDim,
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
                  const SizedBox(height: 8),

                  Consumer(builder: (context, ref, _) {
                    return _NavTile(
                      icon:  Icons.directions_walk_rounded,
                      color: AppColors.lime,
                      bg:    AppColors.limeDim,
                      label: 'Daily Step Target',
                      sub:   'Set a custom step goal',
                      onTap: () async {
                        final valController = TextEditingController();
                        
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surface1,
                            title: const Text('Set Step Target', style: TextStyle(color: AppColors.textPrimary)),
                            content: TextField(
                              controller: valController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                hintText: "e.g. 10000",
                                hintStyle: TextStyle(color: AppColors.textTertiary),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                              ),
                              TextButton(
                                onPressed: () {
                                  final newTarget = int.tryParse(valController.text);
                                  if (newTarget != null && newTarget > 0) {
                                    ref.read(stepProvider.notifier).setTarget(newTarget);
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text('Save', style: TextStyle(color: AppColors.brandPurple)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 8),

                  Consumer(builder: (context, ref, _) {
                    return _NavTile(
                      icon:  Icons.notifications_active_rounded,
                      color: AppColors.accent5,
                      bg:    AppColors.accent5Dim,
                      label: 'Test Notifications',
                      sub:   'Verify alarms and timezone',
                      onTap: () async {
                        final notifService = ref.read(notificationServiceProvider);
                        await notifService.runDiagnostics();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test notification sent! Check logs for diagnostics.'),
                            ),
                          );
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
                    color: AppColors.accent4,
                    bg:    AppColors.accent4Dim,
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
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.textTertiary, size: 18),
      const SizedBox(width: 10),
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
  );
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    ),
  );
}