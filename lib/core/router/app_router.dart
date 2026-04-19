import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import 'package:flutter/services.dart';

// Auth
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

// Features — all 10 phases
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/workout/screens/workout_screen.dart';
import '../../features/exercises/screens/exercises_screen.dart';
import '../../features/calories/screens/calorie_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/coach/screens/coach_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/challenges/screens/challenges_screen.dart';
import '../../features/rivals/screens/rivals_screen.dart';

// Shared
import '../../shared/widgets/fc_loader.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = RouterNotifierListenable(ref);

  return GoRouter(
    refreshListenable: authListenable,
    initialLocation:   '/splash',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.status == AuthStatus.initial ||
                        authState.status == AuthStatus.loading;
      final isAuthed  = authState.isAuthenticated;
      final loc       = state.matchedLocation;

      if (isLoading)                         return '/splash';
      if (!isAuthed && loc == '/splash')     return '/auth/login';
      if (isAuthed  && loc == '/splash')     return '/dashboard';
      if (!isAuthed && !loc.startsWith('/auth')) return '/auth/login';
      if (isAuthed  && loc.startsWith('/auth'))  return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path:    '/splash',
        builder: (_, __) => const _SplashScreen(),
      ),

      // ── Auth ────────────────────────────────────────────────────────
      GoRoute(
        path:    '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path:    '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Main shell with bottom nav ───────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path:    '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path:    '/workout',
            builder: (_, __) => const WorkoutScreen(),       // ✅ FIXED
          ),
          GoRoute(
            path:    '/calories',
            builder: (_, __) => const CalorieScreen(),
          ),
          GoRoute(
            path:    '/leaderboard',
            builder: (_, __) => const LeaderboardScreen(),
          ),
          GoRoute(
            path:    '/coach',
            builder: (_, __) => const CoachScreen(),          // ✅ FIXED
          ),
          GoRoute(
            path:    '/exercises',
            builder: (_, __) => const ExercisesScreen(),
          ),
          GoRoute(
            path:    '/reports',
            builder: (_, __) => const ReportsScreen(),
          ),
          GoRoute(
            path:    '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path:    '/history',
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path:    '/challenges',
            builder: (_, __) => const ChallengesScreen(),
          ),
          GoRoute(
            path:    '/rivals',
            builder: (_, __) => const RivalsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Text(
          'Page not found: ${state.error}',
          style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
      ),
    ),
  );
});

// ── Makes GoRouter react to Riverpod auth state changes ────────────────────────
class RouterNotifierListenable extends ChangeNotifier {
  RouterNotifierListenable(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

// ── Splash screen ──────────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), AppColors.bg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Abstract floating rings
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: -50,
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brandPurple.withOpacity(0.1), width: 1.5),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1,
              right: -50,
              child: Container(
                width: 350, height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lime.withOpacity(0.05), width: 1.5),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(begin: 0, end: 0.1, duration: 3.seconds),
            ),
            
            // Central Elements
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Liquid Core
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(color: AppColors.lime.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 10))
                    ],
                  ),
                  child: const Icon(Icons.bolt_rounded, size: 50, color: AppColors.bg),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.05, 1.05), duration: 1500.ms, curve: Curves.easeInOutBack)
                .shimmer(delay: 800.ms, duration: 1500.ms, color: Colors.white),

                const SizedBox(height: 32),

                // Typographic Reveal
                Text(
                  'FitCoach',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -1.5,
                  ),
                )
                .animate()
                .fade(duration: 800.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 8),

                const Text(
                  'Your AI Fitness Protocol',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fade(duration: 1000.ms, delay: 600.ms),

                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                const FCLoader(color: AppColors.brandPurple).animate().fade(delay: 500.ms),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav shell ───────────────────────────────────────────────────────────
// ── Bottom nav shell ───────────────────────────────────────────────────────────
class _MainShell extends ConsumerWidget {
  final Widget child;
  const _MainShell({required this.child});

  // Only 5 tabs shown in bottom nav — others accessed via navigation inside app
  static const _items = [
    (path: '/dashboard', label: 'Home', icon: Icons.home_rounded),
    (path: '/workout', label: 'Workout', icon: Icons.grid_view_rounded),
    (path: '/calories', label: 'Stats', icon: Icons.bar_chart_rounded),
    (path: '/profile', label: 'Profile', icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;

    // Find active tab index — default 0 if on a sub-route not in nav
    int idx = _items.indexWhere((n) => loc.startsWith(n.path));
    if (idx < 0) idx = 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity > 300 && idx > 0) {
              context.go(_items[idx - 1].path);
            } else if (velocity < -300 && idx < _items.length - 1) {
              context.go(_items[idx + 1].path);
            }
          },
          child: child,
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: FloatingActionButton(
            onPressed: () => context.go('/coach'),
            backgroundColor: AppColors.coach,
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_items.length, (i) {
                final isSelected = i == idx;
                return GestureDetector(
                  onTap: () => context.go(_items[i].path),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    decoration: isSelected
                        ? const BoxDecoration(
                            color: AppColors.surface1,
                            shape: BoxShape.circle,
                          )
                        : null,
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _items[i].icon,
                      color: isSelected ? AppColors.lime : Colors.white70,
                      size: 26,
                    )
                        .animate(target: isSelected ? 1 : 0)
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.3, 1.3),
                          curve: Curves.elasticOut,
                          duration: 800.ms,
                        )
                        .shimmer(
                          delay: 100.ms,
                          duration: 800.ms,
                          color: Colors.white.withOpacity(0.5),
                        ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
