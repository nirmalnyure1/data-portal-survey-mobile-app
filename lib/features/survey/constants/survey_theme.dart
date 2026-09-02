import 'package:data_portal_survey/common/theme/app_colors.dart';

export 'package:data_portal_survey/common/theme/app_colors.dart'
    show AppColors, AppMetrics;

/// Survey UI tokens — aliases over [AppColors] / [AppMetrics] for backward compatibility.
abstract final class SurveyTheme {
  static const primary = AppColors.primary;
  static const primaryContainer = AppColors.primaryContainer;
  static const primarySoft = AppColors.primaryFixed;
  static const primaryFixedDim = AppColors.primaryFixedDim;
  static const secondary = AppColors.secondary;
  static const secondaryContainer = AppColors.secondaryContainer;
  static const destructive = AppColors.destructive;

  static const surface = AppColors.surface;
  static const surfaceLowest = AppColors.surfaceLowest;
  static const surfaceLow = AppColors.surfaceContainerLow;
  static const surfaceContainer = AppColors.surfaceContainerHighest;

  static const onSurface = AppColors.onSurface;
  static const onSurfaceVariant = AppColors.onSurfaceVariant;

  static const border = AppColors.border;
  static const input = AppColors.input;
  static const outline = AppColors.outline;
  static const outlineVariant = AppColors.outlineVariant;

  static const errorBorder = AppColors.destructive;
  static const defaultBorder = AppColors.outlineVariant;

  static const radius = AppMetrics.cardRadius;
  static const radiusSm = AppMetrics.controlRadius;
}
