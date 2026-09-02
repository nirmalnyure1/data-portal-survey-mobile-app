import 'package:flutter/material.dart';

/// Data Portal palette — mirrors `frontend/src/app/globals.css` `:root`.
/// Change globals.css first, then mirror values here.
abstract final class AppColors {
  // ── Brand ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF003893);
  static const Color primaryContainer = Color(0xFF002B6E);
  static const Color primaryFixed = Color(0xFFD6E2FF);
  static const Color primaryFixedDim = Color(0xFFA9C2FF);

  static const Color secondary = Color(0xFFDC143C);
  static const Color secondaryContainer = Color(0xFFA90F2D);

  static const Color destructive = Color(0xFFDF2225);
  static const Color destructiveDark = Color(0xFFFF6467);

  // ── Surfaces (light) ────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFBF9F5);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3EF);
  static const Color surfaceContainerHighest = Color(0xFFE4E2DE);

  // ── On-surface ──────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF1B1C1A);
  static const Color onSurfaceVariant = Color(0xFF45483C);

  // ── Outlines ────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E5E5);
  static const Color input = Color(0xFFE5E5E5);
  static const Color outline = Color(0xFF75796B);
  static const Color outlineVariant = Color(0xFFC5C8B8);

  // ── Dark mode ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkCard = Color(0xFF171717);
  static const Color darkBorder = Color(0x1AFFFFFF); // white @ 10%
  static const Color darkInput = Color(0x26FFFFFF); // white @ 15%

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ── Status / utility ────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color shadow = Color(0x1A000000);

  static const MaterialColor primarySwatch =
      MaterialColor(_primaryValue, <int, Color>{
        50: Color(0xFFE6EEF9),
        100: Color(0xFFC2D4F0),
        200: Color(0xFF9AB8E6),
        300: Color(0xFF729CDC),
        400: Color(0xFF5287D4),
        500: Color(_primaryValue),
        600: Color(0xFF00327B),
        700: Color(0xFF002B6E),
        800: Color(0xFF002461),
        900: Color(0xFF001747),
      });
  static const int _primaryValue = 0xFF003893;
}

/// Layout tokens from the survey UI spec.
abstract final class AppMetrics {
  static const double controlHeight = 48;
  static const double controlRadius = 9;
  static const double cardRadius = 14;
  static const double screenPadding = 16;
  static const double fieldGap = 16;
  static const double bottomBarInset = 96;
}
