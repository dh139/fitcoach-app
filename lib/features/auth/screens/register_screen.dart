import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/fc_button.dart';
import '../../../shared/widgets/fc_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

const _goals = [
  (value: 'lose_weight',       label: 'Lose weight',         icon: Icons.trending_down_rounded),
  (value: 'build_muscle',      label: 'Build muscle',         icon: Icons.fitness_center_rounded),
  (value: 'improve_endurance', label: 'Improve endurance',    icon: Icons.directions_run_rounded),
  (value: 'stay_fit',          label: 'Stay fit',             icon: Icons.favorite_rounded),
  (value: 'gain_weight',       label: 'Gain weight',          icon: Icons.trending_up_rounded),
];

const _genders = [
  (value: 'male',   label: 'Male',   icon: Icons.male_rounded),
  (value: 'female', label: 'Female', icon: Icons.female_rounded),
  (value: 'other',  label: 'Other',  icon: Icons.person_rounded),
];

const _activityOptions = [
  (value: 'sedentary',   label: 'Sedentary',   sub: 'Little or no exercise',  emoji: '🛋️'),
  (value: 'light',       label: 'Light',       sub: '1–3 days/week',          emoji: '🚶'),
  (value: 'moderate',    label: 'Moderate',    sub: '3–5 days/week',          emoji: '🏃'),
  (value: 'active',      label: 'Active',      sub: '6–7 days/week',          emoji: '💪'),
  (value: 'very_active', label: 'Very Active', sub: 'Twice a day',            emoji: '🔥'),
];

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey1   = GlobalKey<FormState>();
  final _formKey2   = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _ageCtrl    = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  int    _step          = 0;
  bool   _obscure       = true;
  String _gender        = 'male';
  String _fitnessGoal   = 'stay_fit';
  String _activityLevel = 'moderate';

  late final AnimationController _pulseCtrl;
  late final AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    for (final c in [_nameCtrl, _emailCtrl, _passCtrl, _ageCtrl, _weightCtrl, _heightCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (!(_formKey1.currentState?.validate() ?? false)) return;
    setState(() => _step = 1);
    _slideCtrl..reset()..forward();
  }

  Future<void> _submit() async {
    if (!(_formKey2.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).register(
      name:          _nameCtrl.text.trim(),
      email:         _emailCtrl.text.trim(),
      password:      _passCtrl.text,
      age:           int.tryParse(_ageCtrl.text),
      weight:        double.tryParse(_weightCtrl.text),
      height:        double.tryParse(_heightCtrl.text),
      gender:        _gender,
      fitnessGoal:   _fitnessGoal,
      activityLevel: _activityLevel,
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
          // ── Dark hero backdrop ───────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.30,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientHero,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Glow orbs ────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Positioned(
              top: -60 + _pulseCtrl.value * 15,
              left: -50,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withAlpha((0.25 * 255).toInt()),
                    blurRadius: 80, spreadRadius: 20,
                  )],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Positioned(
              top: 20 - _pulseCtrl.value * 10,
              right: -60,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: AppColors.coach.withAlpha((0.20 * 255).toInt()),
                    blurRadius: 70, spreadRadius: 15,
                  )],
                ),
              ),
            ),
          ),

          // ── Hero content ─────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.30,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.pageHPad),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button row
                    Row(children: [
                      if (_step == 1)
                        GestureDetector(
                          onTap: () {
                            setState(() => _step = 0);
                            _slideCtrl..reset()..forward();
                          },
                          child: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withAlpha(30), width: 0.5),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 18),
                          ),
                        )
                      else
                        const SizedBox(width: 38),
                      const Spacer(),
                      // Mini logo
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) => CustomPaint(
                          size: const Size(36, 36),
                          painter: _RegisterLogoPainter(_pulseCtrl.value),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    Text(
                      _step == 0 ? 'Create account' : 'Your fitness profile',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _step == 0
                          ? 'Step 1 of 2 — enter your account details'
                          : 'Step 2 of 2 — personalise your plan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white.withAlpha(120),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Step progress bar
                    _StepBar(current: _step),
                  ],
                ),
              ),
            ),
          ),

          // ── Main content body ─────────────────────────────────────────────
          Positioned(
            top: size.height * 0.24,
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: AnimatedBuilder(
                animation: _slideCtrl,
                builder: (_, child) => FadeTransition(
                  opacity: _slideCtrl,
                  child: child,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pageHPad, 28,
                    AppConstants.pageHPad, 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error != null) ...[
                        _ErrorBanner(message: error),
                        const SizedBox(height: 16),
                      ],

                      // Form content
                      _step == 0 ? _buildStep1() : _buildStep2(),

                      const SizedBox(height: 24),

                      // Action button
                      FCButton(
                        label: _step == 0
                            ? 'Continue →'
                            : (isLoading ? 'Creating account...' : 'Create account'),
                        loading: isLoading && _step == 1,
                        fullWidth: true,
                        size: FCButtonSize.lg,
                        onPressed: _step == 0 ? _nextStep : _submit,
                      ),

                      if (_step == 0) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Already have an account? ', style: TextStyle(
                                fontFamily: 'Inter', fontSize: 14,
                                color: AppColors.textSecondary,
                              )),
                              GestureDetector(
                                onTap: () => context.go('/auth/login'),
                                child: const Text('Sign in', style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 14,
                                  fontWeight: FontWeight.w700, color: AppColors.primary,
                                )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1 ──────────────────────────────────────────────────────────────────
  Widget _buildStep1() => Form(
    key: _formKey1,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FieldLabel('Full name'),
      const SizedBox(height: 8),
      FCTextField(
        hint: 'Alex Johnson',
        controller: _nameCtrl,
        textInputAction: TextInputAction.next,
        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textTertiary, size: 20),
        validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
      ),
      const SizedBox(height: 16),

      _FieldLabel('Email address'),
      const SizedBox(height: 8),
      FCTextField(
        hint: 'you@example.com',
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textTertiary, size: 20),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Email required';
          if (!v.contains('@')) return 'Enter a valid email';
          return null;
        },
      ),
      const SizedBox(height: 16),

      _FieldLabel('Password'),
      const SizedBox(height: 8),
      FCTextField(
        hint: 'Min 6 characters',
        controller: _passCtrl,
        obscureText: _obscure,
        textInputAction: TextInputAction.done,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 20),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textTertiary, size: 20,
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Password required';
          if (v.length < 6) return 'Min 6 characters';
          return null;
        },
      ),
    ]),
  );

  // ── Step 2 ──────────────────────────────────────────────────────────────────
  Widget _buildStep2() => Form(
    key: _formKey2,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Age / Weight / Height row
      Row(children: [
        Expanded(child: _compactField('Age (yrs)', _ageCtrl, TextInputType.number)),
        const SizedBox(width: 10),
        Expanded(child: _compactField('Weight (kg)', _weightCtrl,
            const TextInputType.numberWithOptions(decimal: true))),
        const SizedBox(width: 10),
        Expanded(child: _compactField('Height (cm)', _heightCtrl, TextInputType.number)),
      ]),
      const SizedBox(height: 20),

      // Gender picker
      _FieldLabel('Gender'),
      const SizedBox(height: 10),
      Row(children: _genders.map((g) {
        final sel = _gender == g.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _gender = g.value),
            child: Container(
              margin: EdgeInsets.only(right: g.value != _genders.last.value ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.surface1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? AppColors.primary : AppColors.border2,
                  width: sel ? 1.5 : 0.5,
                ),
                boxShadow: sel ? [BoxShadow(
                  color: AppColors.primary.withAlpha(60),
                  blurRadius: 10, offset: const Offset(0, 3),
                )] : null,
              ),
              child: Column(children: [
                Icon(g.icon, size: 20,
                    color: sel ? Colors.white : AppColors.textTertiary),
                const SizedBox(height: 4),
                Text(g.label, style: TextStyle(
                  fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppColors.textSecondary,
                )),
              ]),
            ),
          ),
        );
      }).toList()),
      const SizedBox(height: 20),

      // Fitness goal
      _FieldLabel('Fitness goal'),
      const SizedBox(height: 10),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.6,
        children: _goals.map((g) {
          final sel = _fitnessGoal == g.value;
          return GestureDetector(
            onTap: () => setState(() => _fitnessGoal = g.value),
            child: Container(
              decoration: BoxDecoration(
                color: sel ? AppColors.primaryDim : AppColors.surface1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? AppColors.primaryBorder : AppColors.border2,
                  width: sel ? 1 : 0.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(children: [
                Icon(g.icon, size: 14,
                    color: sel ? AppColors.primary : AppColors.textTertiary),
                const SizedBox(width: 6),
                Flexible(child: Text(g.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? AppColors.primary : AppColors.textSecondary,
                  ),
                )),
              ]),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),

      // Activity level
      _FieldLabel('Activity level'),
      const SizedBox(height: 10),
      ..._activityOptions.map((opt) {
        final sel = _activityLevel == opt.value;
        return GestureDetector(
          onTap: () => setState(() => _activityLevel = opt.value),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: sel ? AppColors.primaryDim : AppColors.surface1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? AppColors.primaryBorder : AppColors.border2,
                width: sel ? 1 : 0.5,
              ),
            ),
            child: Row(children: [
              Text(opt.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(opt.label, style: TextStyle(
                  fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700,
                  color: sel ? AppColors.primary : AppColors.textPrimary,
                )),
                Text(opt.sub, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary,
                )),
              ])),
              if (sel)
                Container(
                  width: 22, height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
                ),
            ]),
          ),
        );
      }),
    ]),
  );

  Widget _compactField(String label, TextEditingController ctrl, TextInputType type) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: const TextStyle(
        fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
        color: AppColors.textTertiary, letterSpacing: 0.8,
      )),
      const SizedBox(height: 6),
      FCTextField(
        hint: '—',
        controller: ctrl,
        keyboardType: type,
        textInputAction: TextInputAction.next,
      ),
    ]);
}

// ── Step progress bar ─────────────────────────────────────────────────────────
class _StepBar extends StatelessWidget {
  final int current;
  const _StepBar({required this.current});

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(2, (i) {
      final active = i <= current;
      return Expanded(
        child: Container(
          height: 3,
          margin: EdgeInsets.only(right: i < 1 ? 6 : 0),
          decoration: BoxDecoration(
            color: active ? Colors.white.withAlpha(200) : Colors.white.withAlpha(40),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }),
  );
}

// ── Logo painter for register hero ─────────────────────────────────────────────
class _RegisterLogoPainter extends CustomPainter {
  final double t;
  _RegisterLogoPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.22;
    final shift  = 6.0 + math.sin(t * math.pi) * 2.0;

    paint.shader = const LinearGradient(
      colors: [AppColors.limeBright, AppColors.lime],
    ).createShader(Rect.fromCircle(center: center.translate(-shift, 0), radius: radius));
    canvas.drawCircle(center.translate(-shift, 0), radius, paint);

    paint.shader = const LinearGradient(
      colors: [Color(0xFF6FE3A4), AppColors.primary],
    ).createShader(Rect.fromCircle(center: center.translate(shift, 0), radius: radius));
    canvas.drawCircle(center.translate(shift, 0), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RegisterLogoPainter old) => old.t != t;
}

// ── Helper widgets ─────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontFamily: 'Inter', fontSize: 13,
    fontWeight: FontWeight.w600, color: AppColors.textSecondary,
  ));
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
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