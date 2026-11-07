// Input checks of the C2 functions, run before any computation (BR4.5,
// BR1.6, NFR4.2, security-design.md §2). Unknown types or denominations are
// not errors (BR1.7): only the cases below throw.

import 'errors.dart';
import 'models.dart';

/// Smallest year accepted for a vintage, a reference year or a window.
const int minSupportedYear = 1900;

/// Largest year accepted for a vintage, a reference year or a window.
const int maxSupportedYear = 2200;

bool isSupportedYear(int year) =>
    year >= minSupportedYear && year <= maxSupportedYear;

/// Throws [EstimationArgumentError] when [wine] cannot be estimated (BR4.5).
void validateWineFacts(WineFacts wine) {
  if (wine.name.trim().isEmpty) {
    throw EstimationArgumentError(
      EstimationErrorCode.emptyName,
      'wine.name',
      wine.name,
    );
  }
  final vintage = wine.vintage;
  if (vintage != null && !isSupportedYear(vintage)) {
    throw EstimationArgumentError(
      EstimationErrorCode.vintageOutOfRange,
      'wine.vintage',
      vintage,
    );
  }
  final referenceYear = wine.referenceYear;
  if (referenceYear != null && !isSupportedYear(referenceYear)) {
    throw EstimationArgumentError(
      EstimationErrorCode.referenceYearOutOfRange,
      'wine.referenceYear',
      referenceYear,
    );
  }
  if (vintage == null && referenceYear == null) {
    throw EstimationArgumentError(
      EstimationErrorCode.missingReferenceYear,
      'wine.referenceYear',
    );
  }
}

/// Throws [EstimationArgumentError] when [window] is not ordered (NFR4.2).
void validateWindow(DrinkingWindow window) {
  if (window.startYear > window.peakYear || window.peakYear > window.endYear) {
    throw EstimationArgumentError(
      EstimationErrorCode.invalidWindow,
      'window',
      '${window.startYear}/${window.peakYear}/${window.endYear}',
    );
  }
}

/// True when the catalog window of [profile] can be used (BR1.6): all three
/// years present, within the supported range and ordered.
bool hasUsableCatalogWindow(ExternalProfile profile) {
  final start = profile.startYear;
  final peak = profile.peakYear;
  final end = profile.endYear;
  if (start == null || peak == null || end == null) return false;
  if (!isSupportedYear(start) || !isSupportedYear(end)) return false;
  return start <= peak && peak <= end;
}
