import 'package:flutter/material.dart';

/// Color tokens of the ux-redesign design-system-mapping.md: bordeaux as
/// primary, gold as accent, cream as the light background. Widgets never
/// use colors directly: they read them from the theme (NFR3.1). Every
/// text/background pair keeps at least 4.5:1 (FR3.1, A1, A8), checked by
/// test/app/status_colors_test.dart.
abstract final class AppColors {
  static const lightPrimary = Color(0xFF7A1F32);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFF3D9DE);
  static const lightOnPrimaryContainer = Color(0xFF4A0F1D);
  static const lightSecondary = Color(0xFF9A6B12);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightSecondaryContainer = Color(0xFFF3E3BF);
  static const lightOnSecondaryContainer = Color(0xFF2A1D20);
  static const lightTertiary = Color(0xFF55642A);
  static const lightSurface = Color(0xFFFBF6EE);
  static const lightSurfaceContainer = Color(0xFFFFFFFF);
  static const lightSurfaceContainerHigh = Color(0xFFF3EBE1);
  static const lightSurfaceContainerHighest = Color(0xFFEDE3D8);
  static const lightOnSurface = Color(0xFF2A1D20);
  static const lightOnSurfaceVariant = Color(0xFF6B5A5D);
  static const lightOutline = Color(0xFF8C7A7D);
  static const lightOutlineVariant = Color(0xFFD8CCC6);
  static const lightInversePrimary = Color(0xFFF2B8C6);
  static const lightError = Color(0xFFB3261E);

  static const darkPrimary = Color(0xFFD9768A);
  static const darkOnPrimary = Color(0xFF2A1015);
  static const darkPrimaryContainer = Color(0xFF5A1A28);
  static const darkOnPrimaryContainer = Color(0xFFF7D9DF);
  static const darkSecondary = Color(0xFFE3B95C);
  static const darkOnSecondary = Color(0xFF2A1D20);
  static const darkSecondaryContainer = Color(0xFF4A3A1C);
  static const darkOnSecondaryContainer = Color(0xFFF2E8E4);
  static const darkTertiary = Color(0xFFB5C47F);
  static const darkSurface = Color(0xFF1D1517);
  static const darkSurfaceContainerLow = Color(0xFF241A1D);
  static const darkSurfaceContainer = Color(0xFF2A1F22);
  static const darkSurfaceContainerHigh = Color(0xFF33262A);
  static const darkSurfaceContainerHighest = Color(0xFF3D2F33);
  static const darkOnSurface = Color(0xFFF2E8E4);
  static const darkOnSurfaceVariant = Color(0xFFBFAEAE);
  static const darkOutline = Color(0xFFA08C90);
  static const darkOutlineVariant = Color(0xFF3A2C30);
  static const darkInversePrimary = Color(0xFF7A1F32);
  static const darkError = Color(0xFFF2B8B5);
}

/// Bar colors of the wine statuses and of the neutral chart bars
/// (u5-dashboard security-design.md §3, NFR3.2), and since ux-redesign the
/// background and text of the status chips (design-system-mapping.md).
/// Each bar has at least 3:1 contrast with the cards in both themes; chip
/// text has at least 4.5:1 on its chip. The status is never shown by color
/// only: every bar and chip also has its icon and label.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.waiting,
    required this.ready,
    required this.drinkSoon,
    required this.pastWindow,
    required this.neutral,
    required this.waitingChip,
    required this.onWaitingChip,
    required this.readyChip,
    required this.onReadyChip,
    required this.drinkSoonChip,
    required this.onDrinkSoonChip,
    required this.pastWindowChip,
    required this.onPastWindowChip,
  });

  static const light = StatusColors(
    waiting: Color(0xFF1F5F99),
    ready: Color(0xFF2E7D32),
    drinkSoon: Color(0xFFB45309),
    pastWindow: Color(0xFF6D6467),
    neutral: AppColors.lightPrimary,
    waitingChip: Color(0xFFF6E7C4),
    onWaitingChip: Color(0xFF7A5A0F),
    readyChip: Color(0xFFDCEFDC),
    onReadyChip: Color(0xFF2F6B3A),
    drinkSoonChip: Color(0xFFFBE1CC),
    onDrinkSoonChip: Color(0xFF8A4510),
    pastWindowChip: Color(0xFFF7DADA),
    onPastWindowChip: Color(0xFF8E2B2B),
  );

  static const dark = StatusColors(
    waiting: Color(0xFF8CC4F2),
    ready: Color(0xFF8FD694),
    drinkSoon: Color(0xFFF5B66B),
    pastWindow: Color(0xFFB8AEB1),
    neutral: AppColors.darkPrimary,
    waitingChip: Color(0xFF46391A),
    onWaitingChip: Color(0xFFF0D48A),
    readyChip: Color(0xFF1F3A24),
    onReadyChip: Color(0xFFA9DCAE),
    drinkSoonChip: Color(0xFF4A2E16),
    onDrinkSoonChip: Color(0xFFF6C08E),
    pastWindowChip: Color(0xFF4A2223),
    onPastWindowChip: Color(0xFFF3B2B2),
  );

  final Color waiting;
  final Color ready;
  final Color drinkSoon;
  final Color pastWindow;

  /// Bars of the peak and type/region charts.
  final Color neutral;

  /// Status chips ("Da bere ora", "Aspettare"...): background and text.
  final Color waitingChip;
  final Color onWaitingChip;
  final Color readyChip;
  final Color onReadyChip;
  final Color drinkSoonChip;
  final Color onDrinkSoonChip;
  final Color pastWindowChip;
  final Color onPastWindowChip;

  /// The extension of [context]'s theme, falling back to the light tokens.
  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>() ?? light;

  List<Color> get _all => [
    waiting,
    ready,
    drinkSoon,
    pastWindow,
    neutral,
    waitingChip,
    onWaitingChip,
    readyChip,
    onReadyChip,
    drinkSoonChip,
    onDrinkSoonChip,
    pastWindowChip,
    onPastWindowChip,
  ];

  static StatusColors _fromList(List<Color> c) => StatusColors(
    waiting: c[0],
    ready: c[1],
    drinkSoon: c[2],
    pastWindow: c[3],
    neutral: c[4],
    waitingChip: c[5],
    onWaitingChip: c[6],
    readyChip: c[7],
    onReadyChip: c[8],
    drinkSoonChip: c[9],
    onDrinkSoonChip: c[10],
    pastWindowChip: c[11],
    onPastWindowChip: c[12],
  );

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
    waitingChip: waitingChip,
    onWaitingChip: onWaitingChip,
    readyChip: readyChip,
    onReadyChip: onReadyChip,
    drinkSoonChip: drinkSoonChip,
    onDrinkSoonChip: onDrinkSoonChip,
    pastWindowChip: pastWindowChip,
    onPastWindowChip: onPastWindowChip,
  );

  @override
  bool operator ==(Object other) {
    if (other is! StatusColors) return false;
    final mine = _all;
    final theirs = other._all;
    for (var i = 0; i < mine.length; i++) {
      if (mine[i] != theirs[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_all);

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    final from = _all;
    final to = other._all;
    return _fromList([
      for (var i = 0; i < from.length; i++) Color.lerp(from[i], to[i], t)!,
    ]);
  }
}

/// Colors of the five graphic families of the wine types (ux-redesign
/// FR3.2, review Major 1): the band of a card, the dot beside the type
/// name, the bar of the type chart. They are never the only signal: the
/// family name is always written beside them (NFR1, A2). The dark values
/// are lighter, as the dark mockup (review R-10).
@immutable
class WineTypeColors extends ThemeExtension<WineTypeColors> {
  const WineTypeColors({
    required this.red,
    required this.white,
    required this.rose,
    required this.sparkling,
    required this.sweet,
    required this.unknown,
  });

  static const light = WineTypeColors(
    red: Color(0xFF8E1B2C),
    white: Color(0xFFC9A227),
    rose: Color(0xFFD4687C),
    sparkling: Color(0xFF7F8F3A),
    sweet: Color(0xFFA8642A),
    unknown: Color(0xFF8C7A7D),
  );

  static const dark = WineTypeColors(
    red: Color(0xFFC75A6C),
    white: Color(0xFFE0C25A),
    rose: Color(0xFFE58A9C),
    sparkling: Color(0xFF86A35A),
    sweet: Color(0xFFD08A4E),
    unknown: Color(0xFF8C7C7F),
  );

  final Color red;
  final Color white;
  final Color rose;
  final Color sparkling;
  final Color sweet;

  /// A wine without type ("neutral").
  final Color unknown;

  /// The extension of [context]'s theme, falling back to the light tokens.
  static WineTypeColors of(BuildContext context) =>
      Theme.of(context).extension<WineTypeColors>() ?? light;

  @override
  WineTypeColors copyWith({
    Color? red,
    Color? white,
    Color? rose,
    Color? sparkling,
    Color? sweet,
    Color? unknown,
  }) => WineTypeColors(
    red: red ?? this.red,
    white: white ?? this.white,
    rose: rose ?? this.rose,
    sparkling: sparkling ?? this.sparkling,
    sweet: sweet ?? this.sweet,
    unknown: unknown ?? this.unknown,
  );

  @override
  bool operator ==(Object other) =>
      other is WineTypeColors &&
      other.red == red &&
      other.white == white &&
      other.rose == rose &&
      other.sparkling == sparkling &&
      other.sweet == sweet &&
      other.unknown == unknown;

  @override
  int get hashCode => Object.hash(red, white, rose, sparkling, sweet, unknown);

  @override
  WineTypeColors lerp(WineTypeColors? other, double t) {
    if (other == null) return this;
    return WineTypeColors(
      red: Color.lerp(red, other.red, t)!,
      white: Color.lerp(white, other.white, t)!,
      rose: Color.lerp(rose, other.rose, t)!,
      sparkling: Color.lerp(sparkling, other.sparkling, t)!,
      sweet: Color.lerp(sweet, other.sweet, t)!,
      unknown: Color.lerp(unknown, other.unknown, t)!,
    );
  }
}

/// The Android system serif (Noto Serif) for the titles: already on the
/// phone, no font file or package (NFR3, plan decision on review Major 2).
const String titleFontFamily = 'serif';

/// The Material 3 color scheme of [brightness] from the tokens.
ColorScheme buildColorScheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final onSurface = isLight
      ? AppColors.lightOnSurface
      : AppColors.darkOnSurface;
  final surface = isLight ? AppColors.lightSurface : AppColors.darkSurface;
  final error = isLight ? AppColors.lightError : AppColors.darkError;
  final onError = isLight ? AppColors.lightOnPrimary : AppColors.darkOnPrimary;
  return ColorScheme(
    brightness: brightness,
    primary: isLight ? AppColors.lightPrimary : AppColors.darkPrimary,
    onPrimary: isLight ? AppColors.lightOnPrimary : AppColors.darkOnPrimary,
    primaryContainer: isLight
        ? AppColors.lightPrimaryContainer
        : AppColors.darkPrimaryContainer,
    onPrimaryContainer: isLight
        ? AppColors.lightOnPrimaryContainer
        : AppColors.darkOnPrimaryContainer,
    secondary: isLight ? AppColors.lightSecondary : AppColors.darkSecondary,
    onSecondary: isLight
        ? AppColors.lightOnSecondary
        : AppColors.darkOnSecondary,
    secondaryContainer: isLight
        ? AppColors.lightSecondaryContainer
        : AppColors.darkSecondaryContainer,
    onSecondaryContainer: isLight
        ? AppColors.lightOnSecondaryContainer
        : AppColors.darkOnSecondaryContainer,
    tertiary: isLight ? AppColors.lightTertiary : AppColors.darkTertiary,
    onTertiary: isLight ? AppColors.lightOnPrimary : AppColors.darkSurface,
    error: error,
    onError: onError,
    errorContainer: error,
    onErrorContainer: onError,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: isLight
        ? AppColors.lightOnSurfaceVariant
        : AppColors.darkOnSurfaceVariant,
    surfaceContainerLowest: isLight
        ? AppColors.lightSurfaceContainer
        : AppColors.darkSurface,
    surfaceContainerLow: isLight
        ? AppColors.lightSurfaceContainer
        : AppColors.darkSurfaceContainerLow,
    surfaceContainer: isLight
        ? AppColors.lightSurfaceContainer
        : AppColors.darkSurfaceContainer,
    surfaceContainerHigh: isLight
        ? AppColors.lightSurfaceContainerHigh
        : AppColors.darkSurfaceContainerHigh,
    surfaceContainerHighest: isLight
        ? AppColors.lightSurfaceContainerHighest
        : AppColors.darkSurfaceContainerHighest,
    outline: isLight ? AppColors.lightOutline : AppColors.darkOutline,
    outlineVariant: isLight
        ? AppColors.lightOutlineVariant
        : AppColors.darkOutlineVariant,
    inverseSurface: onSurface,
    onInverseSurface: surface,
    inversePrimary: isLight
        ? AppColors.lightInversePrimary
        : AppColors.darkInversePrimary,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
  );
}

/// Material 3 theme built only from the tokens.
ThemeData buildAppTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final scheme = buildColorScheme(brightness);
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
  );
  final text = base.textTheme;
  TextStyle? serif(TextStyle? style) =>
      style?.copyWith(fontFamily: titleFontFamily, fontWeight: FontWeight.w700);
  final textTheme = text.copyWith(
    displaySmall: serif(text.displaySmall),
    headlineMedium: serif(text.headlineMedium),
    headlineSmall: serif(text.headlineSmall),
    titleLarge: serif(text.titleLarge),
  );
  const cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
  );
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    extensions: [
      isLight ? StatusColors.light : StatusColors.dark,
      isLight ? WineTypeColors.light : WineTypeColors.dark,
    ],
    // Minimum touch targets of 48x48 dp (NFR3.2, A4).
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.primary),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: cardShape.copyWith(side: BorderSide(color: scheme.outlineVariant)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: scheme.surfaceContainer,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
    ),
    // Selected chips keep the M3 secondaryContainer / onSecondaryContainer
    // pair (gold), which has the text contrast in both themes.
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: scheme.outline),
      backgroundColor: scheme.surfaceContainer,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.secondaryContainer,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.onSurface,
      contentTextStyle: TextStyle(color: scheme.surface),
      actionTextColor: scheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: scheme.outline),
      ),
      filled: true,
      fillColor: scheme.surfaceContainer,
      // Labels sit above the field (design-system-mapping.md).
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        side: BorderSide(color: scheme.primary),
        foregroundColor: scheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
  );
}
