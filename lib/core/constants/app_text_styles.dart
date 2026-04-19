import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static final _base = GoogleFonts.inter(
    color: AppColors.textPrimary,
  );

  static final _headingBase = GoogleFonts.syne(
    color: AppColors.textPrimary,
  );

  // Display — hero headlines (Syne)
  static final display = _headingBase.copyWith(
    fontSize:      48,
    fontWeight:    FontWeight.w800,
    letterSpacing: -1.5,
    height:        1.0,
  );

  static final displayMd = _headingBase.copyWith(
    fontSize:      36,
    fontWeight:    FontWeight.w800,
    letterSpacing: -1.0,
    height:        1.05,
  );

  static final displaySm = _headingBase.copyWith(
    fontSize:      28,
    fontWeight:    FontWeight.w700,
    letterSpacing: -0.8,
    height:        1.1,
  );

  // Headings (Syne)
  static final h1 = _headingBase.copyWith(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static final h2 = _headingBase.copyWith(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3);
  static final h3 = _headingBase.copyWith(fontSize: 16, fontWeight: FontWeight.w700);
  static final h4 = _headingBase.copyWith(fontSize: 14, fontWeight: FontWeight.w700);

  // Body (Inter)
  static final bodyLg = _base.copyWith(fontSize: 15, fontWeight: FontWeight.w400, height: 1.6, color: AppColors.textSecondary);
  static final body   = _base.copyWith(fontSize: 13, fontWeight: FontWeight.w400, height: 1.6, color: AppColors.textSecondary);
  static final bodySm = _base.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary);

  // Label
  static final label = _base.copyWith(
    fontSize: 10, fontWeight: FontWeight.w600,
    letterSpacing: 1.0, color: AppColors.textTertiary,
  );

  // Mono / numbers
  static final mono = GoogleFonts.firaCode(
    fontSize:   14,
    color:      AppColors.lime,
    fontWeight: FontWeight.w600,
  );

  // Stats
  static final statValue = _headingBase.copyWith(
    fontSize:   26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static final statLabel = _base.copyWith(
    fontSize:      10,
    fontWeight:    FontWeight.w600,
    letterSpacing: 0.8,
    color:         AppColors.textTertiary,
  );
}