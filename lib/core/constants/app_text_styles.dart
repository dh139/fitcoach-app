import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Outfit for display/UI labels (reminds of the reference's clean geometric feel)
  // PlusJakartaSans for body — already in your codebase.
  static final _headingBase = GoogleFonts.outfit(
    color: AppColors.textPrimary,
  );

  static final _base = GoogleFonts.plusJakartaSans(
    color: AppColors.textPrimary,
  );

  // ── Display (used in stat values, hero metrics) ────────────────────────────
  static final display = _headingBase.copyWith(
    fontSize:      44,
    fontWeight:    FontWeight.w700,
    letterSpacing: -1.5,
    height:        1.0,
  );

  static final displayMd = _headingBase.copyWith(
    fontSize:      32,
    fontWeight:    FontWeight.w700,
    letterSpacing: -1.0,
    height:        1.05,
  );

  static final displaySm = _headingBase.copyWith(
    fontSize:      26,
    fontWeight:    FontWeight.w700,
    letterSpacing: -0.6,
    height:        1.1,
  );

  // ── Headings ───────────────────────────────────────────────────────────────
  static final h1 = _headingBase.copyWith(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4);
  static final h2 = _headingBase.copyWith(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3);
  static final h3 = _headingBase.copyWith(fontSize: 15, fontWeight: FontWeight.w700);
  static final h4 = _headingBase.copyWith(fontSize: 13, fontWeight: FontWeight.w700);

  // ── Body ───────────────────────────────────────────────────────────────────
  static final bodyLg = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w400, height: 1.55, color: AppColors.textSecondary);
  static final body   = _base.copyWith(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5,  color: AppColors.textSecondary);
  static final bodySm = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.45, color: AppColors.textSecondary);

  // ── Labels (uppercase, tracked — overline, nav, tag) ──────────────────────
  static final label = _base.copyWith(
    fontSize:      10,
    fontWeight:    FontWeight.w600,
    letterSpacing: 1.0,
    color:         AppColors.textTertiary,
  );

  static final mono = GoogleFonts.firaCode(
    fontSize:   14,
    color:      AppColors.primary,
    fontWeight: FontWeight.w600,
  );

  // ── Stat values on cards ───────────────────────────────────────────────────
  static final statValue = _headingBase.copyWith(
    fontSize:      28,
    fontWeight:    FontWeight.w700,
    letterSpacing: -0.8,
    height:        1.0,
  );

  static final statLabel = _base.copyWith(
    fontSize:      10,
    fontWeight:    FontWeight.w600,
    letterSpacing: 0.8,
    color:         AppColors.textSecondary,
  );

  // ── Backward-compat alias used in some screens ─────────────────────────────
  static Shader get primaryGradient => const LinearGradient(
    colors: [AppColors.primary, AppColors.accent2],
  ).createShader(Rect.fromLTWH(0, 0, 200, 70));
}
