// splash_screen.dart
//
// Stunning, orchestrated splash screen for FitCoach.
//
// Design language: keeps the existing dark "solder-and-schematic" navy
// backdrop (AppColors.bg) and the dual-ring blue/orange identity already
// used across the app, but elevates it into one cohesive, single-controller
// boot sequence:
//
//   1. Ambient field fades in (glow blobs + particle drift)
//   2. Dual rings hand-draw themselves in (stroke-by-stroke, not a fade)
//   3. A center glow "ignition" burst settles the mark
//   4. A signature pulse/ECG line sweeps through the rings — the one bold,
//      memorable motif: "your AI is alive and reading your vitals"
//   5. "FitCoach" cascades in letter by letter (Fit = white, Coach = warm
//      tint, echoing the two ring colors)
//   6. Tagline rises in
//   7. A progress bar fills with a live percentage + cycling status copy
//
// Everything after step 1 is driven by ONE AnimationController (_intro) via
// a small `_phase()` helper, so timing is easy to retune in one place. A
// second, looping controller (_ambient) drives idle-state breathing,
// particle drift, and the progress-bar shimmer so the screen never looks
// static while it waits on auth/router state.
//
// Usage: drop this file in, then in your router replace the old
// `_SplashScreen` route with:
//
//   import 'splash_screen.dart'; // adjust path
//   GoRoute(path: "/splash", builder: (_, __) => const SplashScreen()),
//
// and delete the old `_SplashScreen`, `_DotGridPainter`, and
// `FitCoachLogoPainter` classes from router.dart (superseded by this file).

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  /// Optional hook fired once the intro sequence finishes playing.
  /// Safe to leave null — your router's redirect logic can keep driving
  /// navigation exactly as it does today.
  final VoidCallback? onIntroComplete;

  const SplashScreen({super.key, this.onIntroComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _introDuration = Duration(milliseconds: 2600);
  static const _title = 'FitCoach';
  static const _statusMessages = [
    'Calibrating sensors',
    'Loading your protocol',
    'Syncing AI coach',
    'Ready',
  ];

  late final AnimationController _intro;
  late final AnimationController _ambient;
  late final List<_Particle> _particles;

  bool _firedHaptic1 = false;
  bool _firedHaptic2 = false;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(26, _Particle.random);

    _intro = AnimationController(vsync: this, duration: _introDuration)
      ..addListener(_maybeFireHaptics)
      ..forward();

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();

    _intro.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onIntroComplete?.call();
      }
    });
  }

  void _maybeFireHaptics() {
    final v = _intro.value;
    if (!_firedHaptic1 && v >= 0.42) {
      _firedHaptic1 = true;
      HapticFeedback.lightImpact();
    }
    if (!_firedHaptic2 && v >= 0.99) {
      _firedHaptic2 = true;
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  /// Maps controller value [v] onto an eased 0..1 progress within
  /// [start, end] of the overall timeline.
  static double _phase(double v, double start, double end) {
    if (end <= start) return v >= start ? 1.0 : 0.0;
    final t = ((v - start) / (end - start)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }

  double _charPhase(double v, int index, int total,
      {double start = 0.46, double end = 0.80}) {
    final span = end - start;
    final staggerStep = (span * 0.55) / total;
    final localStart = start + staggerStep * index;
    final localEnd = localStart + span * 0.45;
    return _phase(v, localStart, localEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _ambient]),
        builder: (context, _) {
          final v = _intro.value;
          final a = _ambient.value; // 0..1 looping

          final bgFade = _phase(v, 0.0, 0.22);
          final ring1 = _phase(v, 0.05, 0.40);
          final ring2 = _phase(v, 0.13, 0.48);
          final logoPop = _phase(v, 0.05, 0.36);
          final glow = _phase(v, 0.30, 0.55) * (1 - _phase(v, 0.85, 1.0) * 0.15);
          final pulse = _phase(v, 0.40, 0.68);
          final taglinePhase = _phase(v, 0.68, 0.90);
          final loaderPhase = _phase(v, 0.78, 1.0);
          final breathe = _phase(v, 0.5, 0.7) *
              math.sin(a * 2 * math.pi) *
              0.015;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Base ambient glow blobs ─────────────────────────────
              Opacity(
                opacity: bgFade,
                child: Stack(
                  children: [
                    Positioned(
                      top: -120 + math.sin(a * 2 * math.pi) * 18,
                      left: -80 + math.cos(a * 2 * math.pi) * 10,
                      child: _glowBlob(AppColors.primary, 360),
                    ),
                    Positioned(
                      bottom: -100 - math.cos(a * 2 * math.pi) * 14,
                      right: -60 + math.sin(a * 2 * math.pi) * 10,
                      child: _glowBlob(AppColors.coach, 320),
                    ),
                  ],
                ),
              ),

              // ── Dot grid texture ─────────────────────────────────────
              Opacity(
                opacity: bgFade,
                child: CustomPaint(painter: _DotGridPainter()),
              ),

              // ── Drifting particle field ─────────────────────────────
              Opacity(
                opacity: bgFade,
                child: CustomPaint(
                  painter: _ParticleFieldPainter(_particles, a),
                ),
              ),

              // ── Vignette to focus the eye on center ─────────────────
              const _Vignette(),

              // ── Center content ──────────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: (0.7 + logoPop * 0.3) * (1 + breathe),
                      child: Opacity(
                        opacity: logoPop,
                        child: CustomPaint(
                          size: const Size(168, 168),
                          painter: _LogoPainter(
                            ring1Progress: ring1,
                            ring2Progress: ring2,
                            pulseProgress: pulse,
                            glowIntensity: glow,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    _AnimatedTitle(
                      text: _title,
                      charPhase: (i, total) =>
                          _charPhase(v, i, total),
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: taglinePhase,
                      child: Transform.translate(
                        offset: Offset(0, 8 * (1 - taglinePhase)),
                        child: const Text(
                          'YOUR AI FITNESS PROTOCOL',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: Colors.white30,
                            letterSpacing: 3.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 52),
                    Opacity(
                      opacity: loaderPhase == 0 ? 0 : 1,
                      child: _Loader(
                        progress: loaderPhase,
                        shimmerT: a,
                        status: _statusFor(loaderPhase),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _statusFor(double loaderPhase) {
    if (loaderPhase < 0.30) return _statusMessages[0];
    if (loaderPhase < 0.62) return _statusMessages[1];
    if (loaderPhase < 0.94) return _statusMessages[2];
    return _statusMessages[3];
  }

  Widget _glowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(26),
            blurRadius: 120,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

// ── Animated per-character title ────────────────────────────────────────
class _AnimatedTitle extends StatelessWidget {
  final String text;
  final double Function(int index, int total) charPhase;

  const _AnimatedTitle({required this.text, required this.charPhase});

  @override
  Widget build(BuildContext context) {
    final total = text.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final p = charPhase(i, total);
        // "Fit" (first 3 chars) stays pure white; "Coach" picks up a warm
        // tint that echoes the orange ring — ties the wordmark back to
        // the logo without needing a heavier gradient shader.
        final color = i < 3
            ? Colors.white
            : Color.lerp(Colors.white, AppColors.accent2, 0.55);
        return Opacity(
          opacity: p,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - p)),
            child: Transform.scale(
              scale: 0.85 + p * 0.15,
              child: Text(
                text[i],
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -1.5,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Loader: progress bar + shimmer + percentage + status ─────────────────
class _Loader extends StatelessWidget {
  final double progress; // 0..1
  final double shimmerT; // 0..1 looping
  final String status;

  const _Loader({
    required this.progress,
    required this.shimmerT,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: Colors.white24,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: Colors.white38,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent2],
                        ),
                      ),
                    ),
                  ),
                  // Shimmer sweep for a "live" feel while filling
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Align(
                      alignment: Alignment(-1 + 2 * shimmerT, 0),
                      child: FractionallySizedBox(
                        widthFactor: 0.25,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withAlpha(0),
                                Colors.white.withAlpha(90),
                                Colors.white.withAlpha(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo painter: hand-drawn dual rings + signature pulse line ───────────
class _LogoPainter extends CustomPainter {
  final double ring1Progress;
  final double ring2Progress;
  final double pulseProgress;
  final double glowIntensity;

  _LogoPainter({
    required this.ring1Progress,
    required this.ring2Progress,
    required this.pulseProgress,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.22;
    final shift = size.width * 0.10;
    const strokeWidth = 6.0;

    if (glowIntensity > 0) {
      canvas.drawCircle(
        center,
        radius * 1.5,
        Paint()
          ..color = AppColors.primary.withAlpha((110 * glowIntensity).toInt())
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 34 * glowIntensity),
      );
    }

    _drawRing(
      canvas,
      center: center.translate(-shift, 0),
      radius: radius,
      progress: ring1Progress,
      strokeWidth: strokeWidth,
      colors: const [AppColors.primary, Color(0xFF6B8EFF)],
    );

    _drawRing(
      canvas,
      center: center.translate(shift, 0),
      radius: radius,
      progress: ring2Progress,
      strokeWidth: strokeWidth,
      colors: const [AppColors.accent2, Color(0xFFFF9E7C)],
    );

    if (pulseProgress > 0) {
      _drawPulseLine(canvas, center, radius * 2.5, pulseProgress);
    }
  }

  void _drawRing(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double progress,
    required double strokeWidth,
    required List<Color> colors,
  }) {
    if (progress <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final fullPath = Path()..addOval(rect);
    final metric = fullPath.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );
  }

  void _drawPulseLine(Canvas canvas, Offset center, double width, double progress) {
    final startX = center.dx - width / 2;
    final y = center.dy;
    final path = Path()
      ..moveTo(startX, y)
      ..lineTo(startX + width * 0.32, y)
      ..lineTo(startX + width * 0.40, y - 18)
      ..lineTo(startX + width * 0.48, y + 24)
      ..lineTo(startX + width * 0.56, y - 10)
      ..lineTo(startX + width * 0.64, y)
      ..lineTo(startX + width, y);

    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withAlpha(210),
    );

    if (progress < 1.0) {
      final tangent = metric.getTangentForOffset(metric.length * progress);
      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          3.4,
          Paint()
            ..color = Colors.white
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) {
    return old.ring1Progress != ring1Progress ||
        old.ring2Progress != ring2Progress ||
        old.pulseProgress != pulseProgress ||
        old.glowIntensity != glowIntensity;
  }
}

// ── Ambient particle field ────────────────────────────────────────────────
class _Particle {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final double phase;

  _Particle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.phase,
  });

  factory _Particle.random(int seed) {
    final rnd = math.Random(seed * 977 + 13);
    return _Particle(
      x: rnd.nextDouble(),
      startY: rnd.nextDouble(),
      speed: 0.35 + rnd.nextDouble() * 0.6,
      size: 1.0 + rnd.nextDouble() * 1.8,
      phase: rnd.nextDouble() * math.pi * 2,
    );
  }
}

class _ParticleFieldPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  _ParticleFieldPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final travel = (t * p.speed + p.startY) % 1.0;
      final y = size.height * (1.0 - travel);
      final x = size.width * p.x + math.sin((t * 2 * math.pi) + p.phase) * 8;
      final fade = math.sin(travel * math.pi).clamp(0.0, 1.0);
      final opacity = (fade * 80).toInt();
      canvas.drawCircle(
        Offset(x, y),
        p.size,
        Paint()..color = Colors.white.withAlpha(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleFieldPainter oldDelegate) => true;
}

// ── Subtle dot grid texture ───────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(10);
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

// ── Edge vignette so the eye settles on center ────────────────────────────
class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [
              Colors.transparent,
              AppColors.bg.withAlpha(140),
            ],
            stops: const [0.55, 1.0],
          ),
        ),
      ),
    );
  }
}