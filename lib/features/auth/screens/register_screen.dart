import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/fc_button.dart';
import '../../../shared/widgets/fc_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import 'widgets/auth_header.dart';
import 'dart:ui';
import 'widgets/step_indicator.dart';

// Fitness goal options
const _goals = [
  (value: 'lose_weight', label: 'Lose weight'),
  (value: 'build_muscle', label: 'Build muscle'),
  (value: 'improve_endurance', label: 'Improve endurance'),
  (value: 'stay_fit', label: 'Stay fit'),
  (value: 'gain_weight', label: 'Gain weight'),
];

const _genders = ['male', 'female', 'other'];

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  int _step = 0;
  bool _obscure = true;
  String _gender = 'male';
  String _fitnessGoal = 'stay_fit';
  String _activityLevel = 'moderate';

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!(_formKey1.currentState?.validate() ?? false)) return;

    setState(() => _step = 1);
    _animCtrl
      ..reset()
      ..forward();
  }

  Future<void> _submit() async {
    if (!(_formKey2.currentState?.validate() ?? false)) return;

    await ref.read(authProvider.notifier).register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      age: int.tryParse(_ageCtrl.text),
      weight: double.tryParse(_weightCtrl.text),
      height: double.tryParse(_heightCtrl.text),
      gender: _gender,
      fitnessGoal: _fitnessGoal,
      activityLevel: _activityLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isLoading = auth.isLoading;
    final error = auth.status == AuthStatus.error ? auth.error : null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.network(
                'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=600&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: AppColors.bg.withOpacity(0.4), // Dark tint overlay
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHPad, 16, AppConstants.pageHPad, 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button + logo
                        Row(
                          children: [
                            if (_step == 1)
                              GestureDetector(
                                onTap: () {
                                  setState(() => _step = 0);
                                  _animCtrl..reset()..forward();
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface2,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.border3, width: 0.5),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                ),
                              )
                            else
                              const AuthHeader(),
                            const Spacer(),
                            if (_step == 1) const AuthHeader(),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Step indicator
                        StepIndicator(total: 2, current: _step),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          _step == 0 ? 'Create account' : 'Your fitness profile',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _step == 0
                              ? 'Step 1 of 2 — account details'
                              : 'Step 2 of 2 — personalise your plan',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error banner
                        if (error != null) ...[
                          _ErrorBanner(message: error),
                          const SizedBox(height: 14),
                        ],
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.pageHPad),
                      child: _step == 0 ? _Step1Form() : _Step2Form(),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.pageHPad, 20, AppConstants.pageHPad, 32,
                    ),
                    child: Column(
                      children: [
                        FCButton(
                          label: _step == 0
                              ? 'Continue'
                              : (isLoading ? 'Creating account...' : 'Create account'),
                          loading: isLoading && _step == 1,
                          fullWidth: true,
                          size: FCButtonSize.lg,
                          onPressed: _step == 0 ? _nextStep : _submit,
                        ),
                        const SizedBox(height: 16),
                        if (_step == 0)
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.go('/auth/login'),
                                  child: const Text(
                                    'Sign in',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.lime,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1 Form ─────────────────────────────────────────────────────────────
  Widget _Step1Form() => Form(
        key: _formKey1,
        child: Column(
          children: [
            _FieldLabel('Full name'),
            const SizedBox(height: 6),
            FCTextField(
              hint: 'Alex Johnson',
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.person_outline_rounded,
                  color: AppColors.textTertiary, size: 18),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 14),

            _FieldLabel('Email'),
            const SizedBox(height: 6),
            FCTextField(
              hint: 'you@example.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.mail_outline_rounded,
                  color: AppColors.textTertiary, size: 18),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),

            _FieldLabel('Password'),
            const SizedBox(height: 6),
            FCTextField(
              hint: 'Min 6 characters',
              controller: _passCtrl,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.textTertiary, size: 18),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password required';
                if (v.length < 6) return 'Min 6 characters';
                return null;
              },
            ),
          ],
        ),
      );

  // ── Step 2 Form ─────────────────────────────────────────────────────────────
  Widget _Step2Form() => Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Age, Weight, Height
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Age (yrs)'),
                      const SizedBox(height: 6),
                      FCTextField(
                        hint: '—',
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Weight (kg)'),
                      const SizedBox(height: 6),
                      FCTextField(
                        hint: '—',
                        controller: _weightCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Height (cm)'),
                      const SizedBox(height: 6),
                      FCTextField(
                        hint: '—',
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Gender
            _FieldLabel('Gender'),
            const SizedBox(height: 8),
            Row(
              children: _genders.map((g) {
                final selected = _gender == g;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = g),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: g != _genders.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.lime : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              selected ? AppColors.lime : AppColors.border3,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '${g[0].toUpperCase()}${g.substring(1)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.bg
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Fitness Goal
            _FieldLabel('Fitness goal'),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3.0,
              children: _goals.map((g) {
                final selected = _fitnessGoal == g.value;
                return GestureDetector(
                  onTap: () => setState(() => _fitnessGoal = g.value),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.limeDim
                          : AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.limeBorder
                            : AppColors.border3,
                        width: selected ? 1 : 0.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      g.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.lime
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Activity Level
            _FieldLabel('Activity level'),
            const SizedBox(height: 8),
            ..._activityOptions.map((opt) {
              final selected = _activityLevel == opt.value;
              return GestureDetector(
                onTap: () => setState(() => _activityLevel = opt.value),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.limeDim : AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.limeBorder
                          : AppColors.border3,
                      width: selected ? 1 : 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.label,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.lime
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              opt.sub,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: AppColors.lime,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.bg,
                            size: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
}

// Activity level options
const _activityOptions = [
  (value: 'sedentary', label: 'Sedentary', sub: 'Little or no exercise'),
  (value: 'light', label: 'Light', sub: '1–3 days/week'),
  (value: 'moderate', label: 'Moderate', sub: '3–5 days/week'),
  (value: 'active', label: 'Active', sub: '6–7 days/week'),
  (value: 'very_active', label: 'Very active', sub: 'Twice a day'),
];

// ── Reusable Widgets ────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 0.9,
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dangerBorder, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.danger, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFFFF8888),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
}