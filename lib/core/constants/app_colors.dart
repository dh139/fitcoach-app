import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  //  FitCoach 2026 — "Forest & Lime"
  //  Design language: deep evergreen foundations, one electric-lime signal,
  //  soft sage-mint canvas. Restrained, premium, nature-calm. Saturation lives
  //  in the lime CTA and functional data hues — never in the chrome.
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Signature ────────────────────────────────────────────────────────────────
  // Electric lime — the single loud accent. CTAs, active fills, progress.
  static const lime          = Color(0xFFB4E834);
  static const limeBright    = Color(0xFFC7F44E);
  static const limePressed   = Color(0xFF9BCF1F);
  static const limeSoft      = Color(0xFFE8F6C4); // pale lime wash
  static const onLime        = Color(0xFF12241A); // text/icons that sit on lime

  // Deep forest — the dark anchor. Nav bar, hero panels, dark badges.
  static const forest        = Color(0xFF12301F);
  static const forestDeep    = Color(0xFF0C2117);
  static const forestSoft    = Color(0xFF1C4630);

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const bg            = Color(0xFFE9F0DF); // soft sage-mint canvas
  static const surface1      = Colors.white;
  static const surface2      = Color(0xFFF3F8EC);
  static const surface3      = Color(0xFFE7EFDA);
  static const surface4      = Color(0xFFD9E4C9);
  static const surface5      = Color(0xFFC8D6B4);
  static const slate         = Color(0xFFE3EBD6); // hairline card border
  static const mist          = Color(0xFFB6C6A4);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFF12281B); // deep forest, near-black
  static const textSecondary = Color(0xFF586353);
  static const textTertiary  = Color(0xFF93A188);
  static const textHint      = Color(0xFFBECAB1);

  // ── Primary (brand green — readable as text, icon, and fill) ────────────────
  static const primary       = Color(0xFF1F7A4D); // vivid emerald-forest
  static const primaryLight  = Color(0xFFC9E9D2);
  static const primaryDim    = Color(0xFFE4F2E5);
  static const primaryBorder = Color(0xFFCDE6D4);

  // ── Functional accents (data hues — kept for legibility, harmonised) ────────
  static const accent2       = Color(0xFFFF6F7D); // coral (heart)
  static const accent2Light  = Color(0xFFFFDFE2);
  static const accent2Dim    = Color(0xFFFFF1F2);

  static const accent3       = Color(0xFF17B48C); // teal-mint (weight/hydration)
  static const accent3Light  = Color(0xFFCFF0E5);
  static const accent3Dim    = Color(0xFFE6F8F1);

  static const accent4       = Color(0xFFF2A93B); // warm amber (sleep/energy)
  static const accent4Light  = Color(0xFFFCE7C4);
  static const accent4Dim    = Color(0xFFFDF4E3);
  static const accent4Border = accent4Light;

  static const accent5       = Color(0xFF4FA9E0); // sky (running/pace)
  static const accent5Light  = Color(0xFFD3EAF8);
  static const accent5Dim    = Color(0xFFEAF5FC);
  static const accent5Border = accent5Light;

  // ── Borders & dividers ─────────────────────────────────────────────────────
  static const border1       = Color(0xFFEBF0E2);
  static const border2       = Color(0xFFE1E9D4);
  static const border3       = Color(0xFFD3DEC2);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const danger        = Color(0xFFF2586F);
  static const dangerDim     = Color(0xFFFFE5E9);
  static const dangerBorder  = Color(0xFFFFCBD3);

  static const warn          = Color(0xFFF2A93B);
  static const warnDim       = Color(0xFFFDF0DA);

  static const success       = Color(0xFF1F9E6E);
  static const successDim    = Color(0xFFDDF3E8);
  static const info          = accent5;
  static const infoDim       = accent5Dim;

  static const coach         = primary;
  static const coachDim      = primaryDim;
  static const coachBorder   = primaryLight;

  // ── Levels (progression tiers) ──────────────────────────────────────────────
  static const beginner       = Color(0xFF17B48C);
  static const beginnerDim     = accent3Dim;
  static const beginnerBorder  = accent3Light;

  static const intermediate    = primary;
  static const intermediateDim = primaryDim;
  static const intermediateBorder = primaryLight;

  static const advanced        = Color(0xFF6B9E1E); // olive-lime
  static const advancedDim     = Color(0xFFEDF6D6);
  static const advancedBorder  = Color(0xFFDCEEB8);

  static const elite           = Color(0xFFF2A93B);
  static const eliteDim        = accent4Dim;
  static const eliteBorder     = accent4Light;

  // ── Gradients (used sparingly — hero panels & CTAs) ─────────────────────────
  static const gradientHero     = [Color(0xFF1C4630), Color(0xFF0C2117)]; // deep forest
  static const gradientCard     = [Colors.white, Color(0xFFF3F8EC)];
  static const gradientWarm     = [Color(0xFFF2A93B), Color(0xFFFF6F7D)];
  static const gradientCool     = [Color(0xFF1F7A4D), Color(0xFFB4E834)]; // forest → lime
  static const gradientPrimary  = [Color(0xFF1F7A4D), Color(0xFF12301F)];
  static const gradientPremium  = [Color(0xFFB4E834), Color(0xFF1F7A4D)];
  static const gradientLime     = [Color(0xFFC7F44E), Color(0xFFB4E834)];

  // ── Body part colours ──────────────────────────────────────────────────────
  static const bodyChest       = accent2;
  static const bodyBack        = primary;
  static const bodyShoulders   = accent4;
  static const bodyUpperArms   = accent2;
  static const bodyUpperLegs   = accent3;
  static const bodyWaist       = accent4;
  static const bodyCardio      = accent5;

  // ── Backward-compatible aliases (existing code keeps working) ──────────────
  static const kineticGreen   = lime;
  static const electricLime   = lime;
  static const warningAccent  = accent2;
  static const premiumAccent  = primary;

  static const limeHover      = limePressed;
  static const limeLight      = limeSoft;
  static const limeDim        = Color(0xFFF1F8DE);
  static const limeBorder     = Color(0xFFDCEFAE);
  static const brandPurple    = primary;
  static const brandOrange    = accent2;
  static const brandBlue      = info;
  static const brandMint      = accent3;
}
