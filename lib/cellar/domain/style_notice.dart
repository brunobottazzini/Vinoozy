import 'package:estimation/estimation.dart';

import 'wine.dart';

/// "Style to confirm" of a wine (wine-style-profiles BR5.4, BR6.7): its
/// estimate is indicative, its profile is not clear, or its style is a
/// hypothesis the user has not confirmed. A style chosen by the user removes
/// the notice, except Madeira and "Other" (FORT_UNKNOWN), whose estimate
/// stays indicative.
bool styleToConfirmOf(Wine wine, {DrinkingWindow? window, int? fallbackYear}) {
  final shown = window ?? wine.window;
  if (shown != null && shown.source == WindowSource.catalog) return false;
  if (shown != null && shown.indicative) return true;
  final profile = shown?.profile;
  if (profile != null && profile.isUnclear) return true;
  if (wine.styleSource == FieldSource.user && wine.style != null) {
    return wine.style!.profile.isUnclear;
  }
  if (shown == null) return false;
  final year = wine.createdAt?.year ?? fallbackYear ?? shown.startYear;
  try {
    return resolveStyle(
      WineFacts(
        name: wine.name.trim().isEmpty ? '-' : wine.name,
        producer: wine.producer,
        vintage: wine.vintage,
        wineType: WineType.tryParse(wine.wineType),
        denomination: wine.denomination,
        referenceYear: year,
      ),
    ).styleToConfirm;
  } on EstimationArgumentError {
    return false;
  }
}

/// "To estimate" because the style is missing (BR2.9, BR6.7): a fortified
/// wine without a window.
bool needsStyleToEstimate(Wine wine) =>
    wine.window == null &&
    WineType.tryParse(wine.wineType) == WineType.fortified;
