import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../constants/app_colors.dart";

import "../../features/auth/providers/auth_provider.dart";
import "../../features/auth/providers/auth_state.dart";
import "../../features/auth/screens/login_screen.dart";
import "../../features/auth/screens/register_screen.dart";

import "../../features/dashboard/screens/dashboard_screen.dart";
import "../../features/workout/screens/workout_screen.dart";
import "../../features/exercises/screens/exercises_screen.dart";
import "../../features/calories/screens/calorie_screen.dart";
import "../../features/leaderboard/screens/leaderboard_screen.dart";
import "../../features/reports/screens/reports_screen.dart";
import "../../features/coach/screens/coach_screen.dart";
import "../../features/profile/screens/profile_screen.dart";
import "../../features/history/screens/history_screen.dart";
import "../../features/challenges/screens/challenges_screen.dart";
import "../../features/rivals/screens/rivals_screen.dart";

import "../../shared/widgets/fc_floating_nav_bar.dart";
import "../constants/splash_screen.dart";


final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = RouterNotifierListenable(ref);

  return GoRouter(
    refreshListenable: authListenable,
    initialLocation:   "/splash",
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.status == AuthStatus.initial ||
                        authState.status == AuthStatus.loading;
      final isAuthed  = authState.isAuthenticated;
      final loc       = state.matchedLocation;
      final isOwner   = authState.user?.role == 'owner';

      if (isLoading)                         return "/splash";
      if (!isAuthed && loc == "/splash")     return "/auth/login";
      if (isAuthed  && loc == "/splash")     return isOwner ? "/owner/dashboard" : "/dashboard";
      if (!isAuthed && !loc.startsWith("/auth")) return "/auth/login";
      if (isAuthed  && loc.startsWith("/auth"))  return isOwner ? "/owner/dashboard" : "/dashboard";
      return null;
    },
    routes: [
      GoRoute(
        path:    "/splash",
        builder: (_, __) => const SplashScreen(),
      ),

      GoRoute(
        path:    "/auth/login",
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path:    "/auth/register",
        builder: (_, __) => const RegisterScreen(),
      ),

      // Top level checkin and owner routes


      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(path: "/dashboard", builder: (_, __) => const DashboardScreen()),
          GoRoute(path: "/workout", builder: (_, __) => const WorkoutScreen()),
          GoRoute(path: "/exercises", builder: (_, __) => const ExercisesScreen()),
          GoRoute(path: "/calories", builder: (_, __) => const CalorieScreen()),
          GoRoute(path: "/leaderboard", builder: (_, __) => const LeaderboardScreen()),
          GoRoute(path: "/coach", builder: (_, state) => CoachScreen(initialMessage: state.uri.queryParameters['msg'])),
          GoRoute(path: "/reports", builder: (_, __) => const ReportsScreen()),
          GoRoute(path: "/profile", builder: (_, __) => const ProfileScreen()),
          GoRoute(path: "/history", builder: (_, __) => const HistoryScreen()),
          GoRoute(path: "/challenges", builder: (_, __) => const ChallengesScreen()),
          GoRoute(path: "/rivals", builder: (_, __) => const RivalsScreen()),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Text("Page not found: ${state.error}", style: const TextStyle(color: AppColors.textTertiary, fontFamily: "Inter")),
      ),
    ),
  );
});

class RouterNotifierListenable extends ChangeNotifier {
  RouterNotifierListenable(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

// -- Bottom Nav Shell -----------------------------------------------------------
class _MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const _MainShell({required this.child, super.key});

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  bool _isVisible = true;

  // Pill nav: Home / Exercise / Statistics / Profile
  static const _items = [
    (path: "/dashboard", label: "Home", icon: Icons.home_rounded),
    (path: "/exercises", label: "Exercise", icon: Icons.fitness_center_rounded),
    (path: "/calories", label: "Statistics", icon: Icons.bar_chart_rounded),
    (path: "/profile", label: "Profile", icon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    int idx = _items.indexWhere((n) => loc.startsWith(n.path));
    if (idx < 0) idx = 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            final dy = notification.scrollDelta ?? 0;
            if (dy > 12 && _isVisible) {
              setState(() => _isVisible = false);
            } else if (dy < -12 && !_isVisible) {
              setState(() => _isVisible = true);
            }
          }
          return false;
        },
        child: Scaffold(
          backgroundColor: AppColors.bg,
          extendBody: true,
          body: widget.child,
          bottomNavigationBar: FCFloatingNavBar(
            selectedIndex: idx,
            isVisible: _isVisible,
            onTap: (i) => context.go(_items[i].path),
          ),
        ),
      ),
    );
  }
}