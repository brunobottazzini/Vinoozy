import 'package:flutter/material.dart';

/// Color tokens of design-system-mapping.md (bordeaux palette). Widgets never
/// use colors directly: they read them from the theme (NFR3.1).
abstract final class AppColors {
  static const lightPrimary = Color(0xFF7B1E3A);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFFFF8F3);
  static const lightOnSurface = Color(0xFF2B2224);
  static const lightError = Color(0xFFB3261E);

  static const darkPrimary = Color(0xFFE8A0B4);
  static const darkOnPrimary = Color(0xFF3E0A1C);
  static const darkSurface = Color(0xFF1E1A1B);
  static const darkOnSurface = Color(0xFFEDE0E2);
  static const darkError = Color(0xFFF2B8B5);
}

/// Material 3 theme built only from the tokens. Every derived role (variants,
/// containers, inverse) falls back to a token pair, so every text/background
/// combination keeps the contrast checked in the widget tests.
ThemeData buildAppTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final primary = isLight ? AppColors.lightPrimary : AppColors.darkPrimary;
  final onPrimary = isLight
      ? AppColors.lightOnPrimary
      : AppColors.darkOnPrimary;
  final surface = isLight ? AppColors.lightSurface : AppColors.darkSurface;
  final onSurface = isLight
      ? AppColors.lightOnSurface
      : AppColors.darkOnSurface;
  final error = isLight ? AppColors.lightError : AppColors.darkError;
  final onError = isLight ? AppColors.lightOnPrimary : AppColors.darkOnPrimary;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primary,
    onPrimaryContainer: onPrimary,
    secondary: primary,
    onSecondary: onPrimary,
    secondaryContainer: primary,
    onSecondaryContainer: onPrimary,
    tertiary: primary,
    onTertiary: onPrimary,
    error: error,
    onError: onError,
    errorContainer: error,
    onErrorContainer: onError,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurface,
    surfaceContainerLowest: surface,
    surfaceContainerLow: surface,
    surfaceContainer: surface,
    surfaceContainerHigh: surface,
    surfaceContainerHighest: surface,
    outline: onSurface,
    outlineVariant: onSurface,
    inverseSurface: onSurface,
    onInverseSurface: surface,
    inversePrimary: surface,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: surface,
    // Minimum touch targets of 48x48 dp (NFR3.2).
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: onSurface,
      contentTextStyle: TextStyle(color: surface),
      actionTextColor: surface,
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      // Labels sit above the field (design-system-mapping.md).
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(64, 48)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
  );
}
