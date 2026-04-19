import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3:    true,
    brightness:      Brightness.light,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.light(
      primary:    AppColors.lime, // Now black/dark-gray
      secondary:  AppColors.coach,
      surface:    AppColors.surface1,
      background: AppColors.bg,
      error:      AppColors.danger,
      onPrimary:  AppColors.surface1,
      onSurface:  AppColors.textPrimary,
    ),

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor:    AppColors.bg,
      foregroundColor:    AppColors.textPrimary,
      elevation:          0,
      scrolledUnderElevation: 0,
      centerTitle:        false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor:           Colors.transparent,
        statusBarIconBrightness:  Brightness.dark,
        statusBarBrightness:      Brightness.light,
      ),
      titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
    ),

    // Bottom nav (Will be replaced by custom floating pill, but keeping structured)
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:      AppColors.surface1,
      selectedItemColor:    AppColors.lime,
      unselectedItemColor:  AppColors.textTertiary,
      elevation:            0,
      type:                 BottomNavigationBarType.fixed,
      selectedLabelStyle:   AppTextStyles.label.copyWith(color: AppColors.lime),
      unselectedLabelStyle: AppTextStyles.label,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color:     AppColors.border1,
      thickness: 1,
      space:     0,
    ),

    // Card (very soft shadows and large radius for pastel UI)
    cardTheme: CardThemeData(
      color: AppColors.surface1,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled:      true,
      fillColor:   AppColors.surface2,
      border:      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.btnRadius),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.btnRadius),
        borderSide:   BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.btnRadius),
        borderSide:   const BorderSide(color: AppColors.lime, width: 2),
      ),
      hintStyle:   AppTextStyles.body.copyWith(color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal:16, vertical:14),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:   AppColors.lime,
        foregroundColor:   AppColors.surface1,
        elevation:         0,
        padding:           const EdgeInsets.symmetric(horizontal:24, vertical:16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.btnRadius),
        ),
        textStyle: AppTextStyles.h4.copyWith(color: AppColors.surface1),
      ),
    ),

    // OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side:            const BorderSide(color: AppColors.border2, width: 1.5),
        padding:         const EdgeInsets.symmetric(horizontal:20, vertical:16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.btnRadius),
        ),
        textStyle: AppTextStyles.h4,
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTextStyles.h4,
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor:    AppColors.surface2,
      selectedColor:      AppColors.limeDim,
      labelStyle:         AppTextStyles.bodySm,
      side:               BorderSide.none,
      shape:              RoundedRectangleBorder(borderRadius:BorderRadius.circular(100)),
      padding:            const EdgeInsets.symmetric(horizontal:12, vertical:6),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor:  AppColors.lime, // primary black inverted
      contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.surface1),
      shape:            RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),
      behavior:         SnackBarBehavior.floating,
      elevation:        4,
    ),
  );
}