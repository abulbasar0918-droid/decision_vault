import 'package:flutter/material.dart';

/// Defines the core color palette used throughout the Decision Vault application.
class AppColorScheme {
  AppColorScheme._();

  static const Color primary = Color(0xFF0057D8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFDCE4FF);
  static const Color onPrimaryContainer = Color(0xFF001B3F);

  static const Color secondary = Color(0xFF5C5F72);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE5E3F7);
  static const Color onSecondaryContainer = Color(0xFF171B2B);

  static const Color tertiary = Color(0xFF006874);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFBDEAF0);
  static const Color onTertiaryContainer = Color(0xFF002022);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerHighest = Color(0xFFE6E2EC);
  static const Color error = Color(0xFFB00020);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1F1B29);

  static final ColorScheme light = ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: primary,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    surface: surface,
    onSurface: onSurface,
    error: error,
    onError: onError,
  );

  // Prepared dark color scheme for future use
  static final ColorScheme dark = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: primary,
    primary: Color(0xFF8EB7FF),
    onPrimary: Color(0xFF002454),
    primaryContainer: Color(0xFF003A9A),
    onPrimaryContainer: Color(0xFFDCE4FF),
    secondary: Color(0xFFBFC3D6),
    onSecondary: Color(0xFF22232A),
    secondaryContainer: Color(0xFF3A3C4A),
    onSecondaryContainer: Color(0xFFE5E3F7),
    tertiary: Color(0xFF59D6DD),
    onTertiary: Color(0xFF002022),
    tertiaryContainer: Color(0xFF004F55),
    onTertiaryContainer: Color(0xFFBDEAF0),
    surface: Color(0xFF121217),
    onSurface: Color(0xFFECECF1),
    error: error,
    onError: onError,
  );
}

