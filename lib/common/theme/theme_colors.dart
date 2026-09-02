import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_colors.dart';

/// App-wide theme colors — Data Portal palette (replaces Syanko red/cream).
class ThemeColors {
  ThemeColors._();

  // ── Primary Brand ───────────────────────────────────────────────────────

  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;

  // ── Basic ───────────────────────────────────────────────────────────────

  static const Color black = AppColors.onSurface;
  static const Color white = AppColors.white;
  static const Color transparent = AppColors.transparent;

  // ── Surfaces ────────────────────────────────────────────────────────────

  static const Color pageBackGroundColor = AppColors.surface;
  static const Color cardBackGroundColor = AppColors.surfaceLowest;
  static const Color highlightBackGroundColor = AppColors.primaryFixed;
  static const Color cream = AppColors.surfaceContainerLow;

  // ── Gray / neutral scale ────────────────────────────────────────────────

  static const Color lightGrey = AppColors.outlineVariant;
  static const Color lighterGrey = AppColors.surfaceContainerLow;
  static const Color grey = AppColors.outline;
  static const Color midGrayColor = AppColors.border;
  static const Color darkGrey = AppColors.onSurfaceVariant;

  // ── Status ──────────────────────────────────────────────────────────────

  static const Color red = AppColors.destructive;
  static const Color darkRed = AppColors.secondaryContainer;
  static const Color green = AppColors.success;
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color yellow = Color(0xFFE1AD01);
  static const Color textGreenColor = Color(0xFF40826D);

  // ── Accent / legacy aliases ─────────────────────────────────────────────

  static const Color pinkColor = AppColors.secondary;
  static const Color blueShadowColor = AppColors.primaryFixed;
  static const Color greenShadowColor = AppColors.primaryFixedDim;
  static const Color lightYellow = AppColors.primaryFixed;
  static const Color lightRedColor = Color(0xFFFFEBEE);
  static const Color lightPurpleColor = AppColors.primaryFixedDim;
  static const Color primaryShadowColor = AppColors.primaryFixedDim;
  static const Color blueLight = AppColors.primaryFixed;
  static const Color skyBlue = AppColors.primaryFixed;
  static const Color primaryShade = AppColors.surface;

  static const Color shadowColor = AppColors.shadow;
  static const Color lightTextColor = AppColors.onSurfaceVariant;
  static const Color mascotBackground = AppColors.secondary;

  // ── Social ──────────────────────────────────────────────────────────────

  static const Color google = Color(0xFF4285F4);
  static const Color apple = AppColors.onSurface;
  static const Color facebook = Color(0xFF1877F2);

  static const double symmetricHozPadding = AppMetrics.screenPadding;

  static const MaterialColor primaryMaterialColor = AppColors.primarySwatch;

  static const MaterialColor primaryAccentColor =
      MaterialColor(_accentValue, <int, Color>{
        100: Color(0xFFFCE4EC),
        200: Color(_accentValue),
        400: Color(0xFFE91E63),
        700: Color(0xFFA90F2D),
      });
  static const int _accentValue = 0xFFDC143C;

  static const MaterialColor creamMaterialColor =
      MaterialColor(_creamValue, <int, Color>{
        50: Color(0xFFFBF9F5),
        100: Color(0xFFF5F3EF),
        200: Color(0xFFE4E2DE),
        300: Color(0xFFC5C8B8),
        400: Color(0xFF75796B),
        500: Color(_creamValue),
        600: Color(0xFF45483C),
        700: Color(0xFF1B1C1A),
        800: Color(0xFF121212),
        900: Color(0xFF0A0A0A),
      });
  static const int _creamValue = 0xFFFBF9F5;
}
