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

/// Bar colors of the wine statuses and of the neutral chart bars
/// (u5-dashboard security-design.md §3, NFR3.2). Each bar has at least 3:1
/// contrast with the card (the theme surface) in both themes; the numbers
/// are written beside the bars in `onSurface`, so text keeps 4.5:1. The
/// status is never shown by color only: every status bar also has its icon
/// and label. U4 reuses the same colors for the statuses.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.waiting,
    required this.ready,
    required this.drinkSoon,
    required this.pastWindow,
    required this.neutral,
  });

  static const light = StatusColors(
    waiting: Color(0xFF1F5F99),
    ready: Color(0xFF2E7D32),
    drinkSoon: Color(0xFFB45309),
    pastWindow: Color(0xFF6D6467),
    neutral: Color(0xFF7B1E3A),
  );

  static const dark = StatusColors(
    waiting: Color(0xFF8CC4F2),
    ready: Color(0xFF8FD694),
    drinkSoon: Color(0xFFF5B66B),
    pastWindow: Color(0xFFB8AEB1),
    neutral: Color(0xFFE8A0B4),
  );

  final Color waiting;
  final Color ready;
  final Color drinkSoon;
  final Color pastWindow;

  /// Bars of the peak and type/region charts.
  final Color neutral;

  /// The extension of [context]'s theme, falling back to the light tokens.
  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>() ?? light;

  @override
  StatusColors copyWith({
    Color? waiting,
    Color? ready,
    Color? drinkSoon,
    Color? pastWindow,
    Color? neutral,
  }) => StatusColors(
    waiting: waiting ?? this.waiting,
    ready: ready ?? this.ready,
    drinkSoon: drinkSoon ?? this.drinkSoon,
    pastWindow: pastWindow ?? this.pastWindow,
    neutral: neutral ?? this.neutral,
  );

  @override
  bool operator ==(Object other) =>
      other is StatusColors &&
      other.waiting == waiting &&
      other.ready == ready &&
      other.drinkSoon == drinkSoon &&
      other.pastWindow == pastWindow &&
      other.neutral == neutral;

  @override
  int get hashCode =>
      Object.hash(waiting, ready, drinkSoon, pastWindow, neutral);

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      waiting: Color.lerp(waiting, other.waiting, t)!,
      ready: Color.lerp(ready, other.ready, t)!,
      drinkSoon: Color.lerp(drinkSoon, other.drinkSoon, t)!,
      pastWindow: Color.lerp(pastWindow, other.pastWindow, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }
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
    extensions: [isLight ? StatusColors.light : StatusColors.dark],
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
