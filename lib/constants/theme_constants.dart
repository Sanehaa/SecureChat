import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  static const secondary = Color(0xFF088395);
  static const accent = Color(0xFFFF0000);
  static const textDark = Color(0xFF53585A);
  static const textLight = Color(0xFFF5F5F5);
  static const textFaded = Color(0xFF9899A5);
  static const iconLight = Color(0xFFB1B4C0);
  static const iconDark = Color(0xFFB1B3C1);
  static const textHighlight = secondary;
  static const overlayLight = Color(0xFFF9FAFE);
  static const overlayDark = Color(0xFF303334);
}

abstract class _LightColors {
  static const background = Colors.white;
  static const card = AppColors.overlayLight;
}

abstract class _DarkColors {
  static const background = Color(0xFF1B1E1F);
  static const card = AppColors.overlayDark;
}

/// Reference to the application theme.
abstract class AppTheme {
  static const accentColor = AppColors.accent;
  static final visualDensity = VisualDensity.adaptivePlatformDensity;

  /// Light theme and its settings.
  static ThemeData light(ThemeData theme) => ThemeData(
    brightness: Brightness.light,
    hintColor: accentColor,
    visualDensity: visualDensity,
    textTheme: GoogleFonts.poppinsTextTheme(theme.textTheme)
        .apply(bodyColor: AppColors.textDark),
    scaffoldBackgroundColor: _LightColors.background,
    cardColor: _LightColors.card,
    primaryTextTheme: const TextTheme(
      titleLarge: TextStyle(color: AppColors.textDark),
    ),
    iconTheme: const IconThemeData(color: AppColors.iconDark),
  );

  /// Dark theme and its settings.
  static ThemeData dark(ThemeData theme) => ThemeData(
    brightness: Brightness.dark,
    hintColor: accentColor,
    visualDensity: visualDensity,
    textTheme: GoogleFonts.poppinsTextTheme(theme.textTheme)
        .apply(bodyColor: AppColors.textLight),
    scaffoldBackgroundColor: _DarkColors.background,
    cardColor: _DarkColors.card,
    primaryTextTheme: const TextTheme(
      titleLarge: TextStyle(color: AppColors.textLight),
    ),
    iconTheme: const IconThemeData(color: AppColors.iconLight),
  );
}