import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand strategy: Restrained (warm tinted neutrals + soft accent) ──────────
  // Backgrounds sit on a soft warm-grey so whites feel intentional, not stark.
  // Saturation lives in pastel cards, not in chrome.

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const bg            = Color(0xFFE2E6EE); // soft grey-blue background from mockup
  static const surface1      = Colors.white;
  static const surface2      = Color(0xFFF7F8FC);
  static const surface3      = Color(0xFFECEFF5);
  static const surface4      = Color(0xFFD6DBE4);
  static const surface5      = Color(0xFFC4CAD5);
  static const slate         = Color(0xFFE5E9F0);
  static const mist          = Color(0xFFB4BDCB);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFF1E202B);
  static const textSecondary = Color(0xFF5F6275);
  static const textTertiary  = Color(0xFF9EA3BA);
  static const textHint      = Color(0xFFC2C7DA);

  // ── Pastel accents (the colour of each card on dashboard) ──────────────────
  static const primary       = Color(0xFF8E7CFF); // brand purple/lavender
  static const primaryLight  = Color(0xFFE5DFFF);
  static const primaryDim    = Color(0xFFF1ECFF);

  static const accent2       = Color(0xFFFF7A8A); // pink (heart)
  static const accent2Light  = Color(0xFFFFE0E5);
  static const accent2Dim    = Color(0xFFFFF2F4);

  static const accent3       = Color(0xFF34C7A8); // mint (weight)
  static const accent3Light  = Color(0xFFD4F5EC);
  static const accent3Dim    = Color(0xFFE9FBF5);

  static const accent4       = Color(0xFFFFB547); // amber (sleep)
  static const accent4Light  = Color(0xFFFFEACB);
  static const accent4Dim    = Color(0xFFFFF6E7);

  static const accent5       = Color(0xFF6BB5FF); // blue (blood pressure)
  static const accent5Light  = Color(0xFFD8EBFF);
  static const accent5Dim    = Color(0xFFEEF6FF);

  // ── Borders & dividers ─────────────────────────────────────────────────────
  static const border1       = Color(0xFFECEDF1);
  static const border2       = Color(0xFFE3E5EB);
  static const border3       = Color(0xFFD8DAE1);
  static const primaryBorder = primaryLight;
  static const accent4Border = accent4Light;
  static const accent5Border = accent5Light;

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const danger        = Color(0xFFFF5C7A);
  static const dangerDim     = Color(0xFFFFE5EB);
  static const dangerBorder  = Color(0xFFFFCCD7);

  static const warn          = Color(0xFFFFB547);
  static const warnDim       = Color(0xFFFFF1DA);

  static const success       = Color(0xFF2EBE9B);
  static const successDim    = Color(0xFFDFF8F1);
  static const info          = Color(0xFF6BB5FF);
  static const infoDim       = Color(0xFFE3F0FF);

  static const coach         = accent5;
  static const coachDim      = accent5Dim;
  static const coachBorder   = accent5Light;

  // ── Levels ─────────────────────────────────────────────────────────────────
  static const beginner      = Color(0xFF34C7A8);
  static const beginnerDim   = accent3Dim;
  static const beginnerBorder = accent3Light;

  static const intermediate  = Color(0xFF8E7CFF);
  static const intermediateDim = primaryDim;
  static const intermediateBorder = primaryLight;

  static const advanced      = Color(0xFFFF7A8A);
  static const advancedDim   = accent2Dim;
  static const advancedBorder = accent2Light;

  static const elite         = Color(0xFFFFB547);
  static const eliteDim      = accent4Dim;
  static const eliteBorder   = accent4Light;

  // ── Gradients (used sparingly on hero / CTA) ───────────────────────────────
  static const gradientHero     = [Color(0xFF8E7CFF), Color(0xFFFF7A8A)];
  static const gradientCard     = [Colors.white, Color(0xFFF7F6F9)];
  static const gradientWarm     = [Color(0xFFFFB547), Color(0xFFFF7A8A)];
  static const gradientCool     = [Color(0xFF8E7CFF), Color(0xFF6BB5FF)];
  static const gradientPrimary  = [Color(0xFF8E7CFF), Color(0xFFFF7A8A)];
  static const gradientPremium  = [Color(0xFF8E7CFF), Color(0xFFFFB547)];

  // ── Body part colours ──────────────────────────────────────────────────────
  static const bodyChest       = accent2;
  static const bodyBack        = primary;
  static const bodyShoulders   = accent4;
  static const bodyUpperArms   = accent2;
  static const bodyUpperLegs   = accent3;
  static const bodyWaist       = accent4;
  static const bodyCardio      = accent5;

  // ── Backward-compatible aliases (existing code keeps working) ──────────────
  static const kineticGreen   = Color(0xFF34C7A8);
  static const electricLime   = Color(0xFF8E7CFF);
  static const warningAccent  = accent2;
  static const premiumAccent  = primary;

  static const lime           = primary;
  static const limeHover      = primary;
  static const limeLight      = primaryLight;
  static const limeDim        = primaryDim;
  static const limeBorder     = primaryLight;
  static const brandPurple    = primary;
  static const brandOrange    = accent2;
  static const brandBlue      = info;
  static const brandMint      = accent3;
}
