import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/fc_button.dart';
import '../../../shared/widgets/fc_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(authProvider.notifier).clearError();
    await ref.read(authProvider.notifier).login(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth      = ref.watch(authProvider);
    final isLoading = auth.isLoading;
    final error     = auth.status == AuthStatus.error ? auth.error : null;
    final size      = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ── Gradient hero backdrop ────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.46,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1B2E), Color(0xFF0F1629)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── Animated ambient glow orbs ────────────────────────────────────
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              final scale = 0.9 + _pulseCtrl.value * 0.12;
              return Positioned(
                top: -80 + _floatCtrl.value * 20,
                left: -60,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 280, height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha((0.22 * 255).toInt()),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, __) {
              final scale = 0.85 + _floatCtrl.value * 0.15;
              return Positioned(
                top: 60 - _floatCtrl.value * 15,
                right: -80,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 220, height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent5.withAlpha((0.18 * 255).toInt()),
                          blurRadius: 70,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Decorative floating ring ──────────────────────────────────────
          Positioned(
            top: size.height * 0.05,
            left: size.width / 2 - 130,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha(12),
                  width: 1,
                ),
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.05, 1.05),
              duration: 3000.ms,
              curve: Curves.easeInOut,
            ),
          ),

          // ── Hero logo + title ─────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.46,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo mark
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => CustomPaint(
                      size: const Size(80, 80),
                      painter: _LoginLogoPainter(_pulseCtrl.value),
                    ),
                  )
                  .animate()
                  .fade(duration: 700.ms)
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'FitCoach',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1.5,
                    ),
                  )
                  .animate()
                  .fade(duration: 600.ms, delay: 150.ms)
                  .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 6),

                  const Text(
                    'YOUR AI FITNESS PROTOCOL',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Colors.white38,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                  .animate()
                  .fade(duration: 800.ms, delay: 300.ms),
                ],
              ),
            ),
          ),

          // ── Main bottom sheet form ────────────────────────────────────────
          Positioned(
            top: size.height * 0.38,
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pageHPad, 32,
                  AppConstants.pageHPad, 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back 👋',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    )
                    .animate()
                    .fade(duration: 500.ms, delay: 200.ms)
                    .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 6),

                    const Text(
                      'Sign in to continue your fitness journey',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    )
                    .animate()
                    .fade(duration: 500.ms, delay: 250.ms),

                    const SizedBox(height: 28),

                    if (error != null) ...[
                      _ErrorBanner(message: error),
                      const SizedBox(height: 16),
                    ],

                    // Form card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface1,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.slate, width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Email address'),
                            const SizedBox(height: 8),
                            FCTextField(
                              hint: 'you@example.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.mail_outline_rounded,
                                  color: AppColors.textTertiary, size: 20),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email required';
                                if (!v.contains('@')) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            _FieldLabel('Password'),
                            const SizedBox(height: 8),
                            FCTextField(
                              hint: '••••••••',
                              controller: _passCtrl,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              prefixIcon: const Icon(Icons.lock_outline_rounded,
                                  color: AppColors.textTertiary, size: 20),
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() => _obscure = !_obscure),
                                child: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textTertiary, size: 20,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password required';
                                if (v.length < 6) return 'Min 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            FCButton(
                              label: isLoading ? 'Signing in...' : 'Sign in',
                              loading: isLoading,
                              fullWidth: true,
                              size: FCButtonSize.lg,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 24),

                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/auth/register'),
                            child: const Text(
                              'Create one',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fade(duration: 600.ms, delay: 450.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginLogoPainter extends CustomPainter {
  final double t;
  _LoginLogoPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.22;
    final shift  = 13.0 + math.sin(t * math.pi) * 3.0;

    paint.shader = const LinearGradient(
      colors: [AppColors.primary, Color(0xFF6BB5FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center.translate(-shift, 0), radius: radius));
    canvas.drawCircle(center.translate(-shift, 0), radius, paint);

    paint.shader = const LinearGradient(
      colors: [AppColors.accent2, Color(0xFFFF9E7C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center.translate(shift, 0), radius: radius));
    canvas.drawCircle(center.translate(shift, 0), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _LoginLogoPainter old) => old.t != t;
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
  );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.dangerDim,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.dangerBorder, width: 0.5),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 16),
      const SizedBox(width: 10),
      Expanded(child: Text(message, style: const TextStyle(
        fontFamily: 'Inter', fontSize: 12,
        color: Color(0xFFFF8888), height: 1.4,
      ))),
    ]),
  );
}