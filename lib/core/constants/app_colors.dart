import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const lime        = Color(0xFF1E1E24); // Primary action is now extremely dark/black
  static const limeHover   = Color(0xFF3B3B42);
  static const limeLight   = Color(0xFFE5E7EB);
  static const limeDim     = Color(0x1F1E1E24);
  static const limeBorder  = Color(0x331E1E24); 

  // Pastel Brand Colors
  static const brandPurple = Color(0xFFB3A4FF);
  static const brandPurpleDim = Color(0xFFE5DFFF);
  static const brandOrange = Color(0xFFFFD166);
  static const brandOrangeDim = Color(0xFFFFF2CD);
  static const brandBlue   = Color(0xFFA2C2FF);
  static const brandBlueDim = Color(0xFFE3EDFF);
  static const brandMint   = Color(0xFFB9FBC0);
  static const brandMintDim = Color(0xFFE5FCE8);

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const bg          = Color(0xFFF9FAFC);
  static const surface1    = Color(0xFFFFFFFF);
  static const surface2    = Color(0xFFF3F4F6);
  static const surface3    = Color(0xFFE5E7EB);
  static const surface4    = Color(0xFFD1D5DB);
  static const surface5    = Color(0xFF9CA3AF);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFF111827);
  static const textSecondary = Color(0xFF4B5563);
  static const textTertiary  = Color(0xFF9CA3AF);
  static const textHint      = Color(0xFFD1D5DB);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const border1       = Color(0xFFF3F4F6);
  static const border2       = Color(0xFFE5E7EB);
  static const border3       = Color(0xFFD1D5DB);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const danger       = Color(0xFFEF4444);
  static const dangerDim    = Color(0x26EF4444);
  static const dangerBorder = Color(0x40EF4444);
  static const warn         = Color(0xFFF59E0B);
  static const warnDim      = Color(0x26F59E0B);
  static const success      = Color(0xFF10B981);
  static const successDim   = Color(0x2610B981);
  static const info         = Color(0xFF3B82F6);
  static const infoDim      = Color(0x263B82F6);
  static const coach        = Color(0xFF8B5CF6);
  static const coachDim     = Color(0xFFEDE9FE);
  static const coachBorder  = Color(0xFFDDD6FE);

  // ── Levels (Refined for light mode) ─────────────────────────────────────────────────────────────────
  static const beginner        = brandMint;
  static const beginnerDim     = brandMintDim;
  static const beginnerBorder  = brandMint;

  static const intermediate       = brandBlue;
  static const intermediateDim    = brandBlueDim;
  static const intermediateBorder = brandBlue;

  static const advanced        = brandPurple;
  static const advancedDim     = brandPurpleDim;
  static const advancedBorder  = brandPurple;

  static const elite        = brandOrange;
  static const eliteDim     = brandOrangeDim;
  static const eliteBorder  = brandOrange;

  // ── Body part colors (Pastel) ─────────────────────────────────────────────
  static const bodyChest       = Color(0xFFFFB4A2);
  static const bodyBack        = Color(0xFFA2C2FF);
  static const bodyShoulders   = Color(0xFFB3A4FF);
  static const bodyUpperArms   = Color(0xFFFFD166);
  static const bodyUpperLegs   = Color(0xFFB9FBC0);
  static const bodyWaist       = Color(0xFFFFC8DD);
  static const bodyCardio      = Color(0xFFE0BBFF);
}