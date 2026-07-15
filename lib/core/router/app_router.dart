
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_animate/flutter_animate.dart";
import "../constants/app_colors.dart";
import "package:flutter/services.dart";

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
        builder: (_, __) => const _SplashScreen(),
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

// -- Splash Screen --------------------------------------------------------------
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;   // logo breathing
  late final AnimationController _ring1Ctrl;  // inner pulse ring
  late final AnimationController _ring2Ctrl;  // outer pulse ring
  late final AnimationController _glowCtrl;   // ambient glow

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _ring1Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
    _ring2Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C16),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ── Animated ambient glow top-left ────────────────────────────────
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => Positioned(
              top: -120 + _glowCtrl.value * 30,
              left: -80,
              child: Container(
                width: 360, height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withAlpha((0.10 * 255 * (0.7 + _glowCtrl.value * 0.3)).toInt()),
                    blurRadius: 120,
                    spreadRadius: 40,
                  )],
                ),
              ),
            ),
          ),

          // ── Animated ambient glow bottom-right ────────────────────────────
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => Positioned(
              bottom: -100 - _glowCtrl.value * 20,
              right: -60,
              child: Container(
                width: 320, height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: AppColors.coach.withAlpha((0.10 * 255 * (0.6 + _glowCtrl.value * 0.4)).toInt()),
                    blurRadius: 110,
                    spreadRadius: 30,
                  )],
                ),
              ),
            ),
          ),

          // ── Grid dot overlay (subtle texture) ────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(),
            ),
          ),

          // ── Outer pulse ring ─────────────────────────────────────────────
          AnimatedBuilder(
            animation: _ring2Ctrl,
            builder: (_, __) {
              final t = _ring2Ctrl.value;
              final scale = 1.0 + t * 1.6;
              final opacity = (1.0 - t).clamp(0.0, 1.0);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withAlpha((opacity * 60).toInt()),
                      width: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Inner pulse ring ─────────────────────────────────────────────
          AnimatedBuilder(
            animation: _ring1Ctrl,
            builder: (_, __) {
              final t = _ring1Ctrl.value;
              final scale = 1.0 + t * 1.0;
              final opacity = (1.0 - t).clamp(0.0, 1.0);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent5.withAlpha((opacity * 80).toInt()),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Central logo + text ───────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with glow shadow
              AnimatedBuilder(
                animation: _logoCtrl,
                builder: (context, child) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha((0.25 * 255 * (0.6 + _logoCtrl.value * 0.4)).toInt()),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    size: const Size(120, 120),
                    painter: FitCoachLogoPainter(_logoCtrl.value),
                  ),
                ),
              )
              .animate()
              .fade(duration: 800.ms)
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 900.ms,
                curve: Curves.easeOutBack,
              ),

              const SizedBox(height: 36),

              const Text(
                'FitCoach',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -2.0,
                ),
              )
              .animate()
              .fade(duration: 700.ms, delay: 250.ms)
              .slideY(begin: 0.2, end: 0, duration: 700.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 10),

              const Text(
                'YOUR AI FITNESS PROTOCOL',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: Colors.white30,
                  letterSpacing: 3.5,
                  fontWeight: FontWeight.w700,
                ),
              )
              .animate()
              .fade(duration: 900.ms, delay: 500.ms),

              const SizedBox(height: 52),

              // Progress indicator
              SizedBox(
                width: 160,
                child: Column(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const LinearProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Initialising your protocol...', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 10,
                    color: Colors.white24, letterSpacing: 0.5,
                  )),
                ]),
              )
              .animate()
              .fade(delay: 700.ms),
            ],
          ),
        ],
      ),
    );
  }
}

// Subtle dot grid texture for the splash background
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) => false;
}

// ── Custom Logo Painter ───────────────────────────────────────────────────────
class FitCoachLogoPainter extends CustomPainter {
  final double animValue;
  FitCoachLogoPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.22;
    
    // Shift distance oscillates slightly based on animValue
    final shift = 12.0 + (animValue * 4.0);

    // Left Ring (Athlete Loop)
    paint.shader = const LinearGradient(
      colors: [AppColors.primary, Color(0xFF6B8EFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center.translate(-shift, 0), radius: radius));

    canvas.drawCircle(center.translate(-shift, 0), radius, paint);

    // Right Ring (Coach Loop)
    paint.shader = const LinearGradient(
      colors: [AppColors.accent2, Color(0xFFFF9E7C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center.translate(shift, 0), radius: radius));

    canvas.drawCircle(center.translate(shift, 0), radius, paint);
  }

  @override
  bool shouldRepaint(covariant FitCoachLogoPainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
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
