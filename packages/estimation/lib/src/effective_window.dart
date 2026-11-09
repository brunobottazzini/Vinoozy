// The effective window of label-autofill-windows (D3, BR4.4, BR4.6,
// FR5.1, FR5.6): the base window (level included) after the drink feedback,
// then the manual "Recommended until" of the owner.
//
// The drink feedback is applied by the app (WindowAdjuster), which owns the
// drink conditions; this function adds the manual correction, the last
// step, so every place that writes or shows a window (BR4.5) ends the same
// way. wine-style-profiles (BR6.8, BR7.5) adds the month of the correction
// for the windows in months.

import 'dart:math' as math;

import 'models.dart';

/// Most years the manual end may go past the start (BR4.6).
const int maxOverrideSpan = 60;

/// Most months the manual end may go past the start of a window in months
/// (BR6.8).
const int maxOverrideMonths = 120;

/// [adjusted], the window after the drink feedback, with the manual end
/// year [overrideEndYear] (BR4.4) and, for a window in months, its month
/// [overrideEndMonth] (December when missing, BR7.5): the end becomes the
/// correction; when the feedback had moved the peak or the start past it,
/// they stop there (FR5.6). `null` leaves [adjusted] as it is.
DrinkingWindow effectiveWindow(
  DrinkingWindow adjusted, {
  int? overrideEndYear,
  int? overrideEndMonth,
}) {
  final endYear = overrideEndYear;
  if (endYear == null) return adjusted;
  if (!adjusted.inMonths) {
    final peak = adjusted.peakYear;
    return adjusted.withYears(
      math.min(adjusted.startYear, endYear),
      peak == null ? null : math.min(peak, endYear),
      endYear,
    );
  }
  final end = monthIndex(endYear, overrideEndMonth ?? 12);
  final peak = adjusted.peakIndex;
  return adjusted.withIndexes(
    math.min(adjusted.startIndex, end),
    peak == null ? null : math.min(peak, end),
    end,
  );
}

/// The years the owner may choose as "Recommended until" for a wine whose
/// window without correction is [window] (BR4.6): from its start to the
/// start plus [maxOverrideSpan].
({int first, int last}) overrideYearRange(DrinkingWindow window) =>
    window.inMonths
    ? (
        first: window.startYear,
        last: monthOfIndex(window.startIndex + maxOverrideMonths).year,
      )
    : (first: window.startYear, last: window.startYear + maxOverrideSpan);

/// The month indexes the owner may choose for a window in months (BR6.8):
/// from its start to the start plus [maxOverrideMonths].
({int first, int last}) overrideMonthRange(DrinkingWindow window) =>
    (first: window.startIndex, last: window.startIndex + maxOverrideMonths);

/// Whether [endYear] (and [endMonth] for a window in months, December when
/// missing) is a valid manual end for [window] (BR4.6, BR6.8).
bool isValidOverrideYear(DrinkingWindow window, int endYear, [int? endMonth]) {
  if (window.inMonths) {
    if (endMonth != null && (endMonth < 1 || endMonth > 12)) return false;
    final range = overrideMonthRange(window);
    final index = monthIndex(endYear, endMonth ?? 12);
    return index >= range.first && index <= range.last;
  }
  final range = overrideYearRange(window);
  return endYear >= range.first && endYear <= range.last;
}
