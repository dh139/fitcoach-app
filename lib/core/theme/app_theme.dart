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
    canvasColor:     AppColors.bg,

    colorScheme: const ColorScheme.light(
      primary:      AppColors.primary,
      secondary:    AppColors.lime,
      tertiary:     AppColors.accent3,
      surface:      AppColors.surface1,
      onPrimary:    Colors.white,
      onSecondary:  AppColors.onLime,
      onSurface:    AppColors.textPrimary,
      surfaceTint:  Colors.transparent,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor:     AppColors.bg,
      foregroundColor:     AppColors.textPrimary,
      elevation:           0,
      scrolledUnderElevation: 0,
      centerTitle:         false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor:           Colors.transparent,
        statusBarIconBrightness:  Brightness.dark,
        statusBarBrightness:      Brightness.light,
      ),
      titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:      Colors.transparent,
      selectedItemColor:    AppColors.textPrimary,
      unselectedItemColor:  AppColors.textTertiary,
      elevation:            0,
      type:                 BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedLabelStyle:   AppTextStyles.label.copyWith(color: AppColors.textPrimary),
      unselectedLabelStyle: AppTextStyles.label,
    ),

    dividerTheme: const DividerThemeData(
      color:     AppColors.border1,
      thickness: 1,
      space:     0,
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface1,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:        true,
      fillColor:     AppColors.surface2,
      hintStyle:     AppTextStyles.body.copyWith(color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.btnRadius), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.btnRadius), borderSide: const BorderSide(color: AppColors.border2, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.btnRadius), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.btnRadius), borderSide: const BorderSide(color: AppColors.danger, width: 1)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:   AppColors.textPrimary,
        foregroundColor:   Colors.white,
        elevation:         0,
        padding:           const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape:              RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.btnRadius)),
        textStyle: AppTextStyles.h4.copyWith(color: Colors.white),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side:             const BorderSide(color: AppColors.border2, width: 1.5),
        padding:          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape:             RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.btnRadius)),
        textStyle: AppTextStyles.h4,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.h4,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor:    AppColors.surface1,
      selectedColor:      AppColors.limeSoft,
      labelStyle:         AppTextStyles.bodySm,
      side:               const BorderSide(color: AppColors.border2),
      shape:              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      padding:            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color:            AppColors.primary,
      linearTrackColor: AppColors.surface3,
      circularTrackColor: AppColors.surface3,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor:  AppColors.textPrimary,
      contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
      shape:             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior:          SnackBarBehavior.floating,
      elevation:         4,
    ),

    splashFactory: NoSplash.splashFactory,
  );
}
