// The effective window of label-autofill-windows (D3, BR4.4, BR4.6,
// FR5.1, FR5.6): the base window (level included) after the drink feedback,
// then the manual "Recommended until" of the owner.
//
// The drink feedback is applied by the app (WindowAdjuster), which owns the
// drink conditions; this function adds the manual correction, the last
// step, so every place that writes or shows a window (BR4.5) ends the same
// way.

import 'dart:math' as math;

import 'models.dart';

/// Most years the manual end may go past the start (BR4.6).
const int maxOverrideSpan = 60;

/// [adjusted], the window after the drink feedback, with the manual end
/// year [overrideEndYear] (BR4.4): the end becomes [overrideEndYear]; when
/// the feedback had moved the peak or the start past it, they stop there
/// (FR5.6). Without a feedback the start never changes, because BR4.6
/// keeps [overrideEndYear] >= the start. `null` leaves [adjusted] as it is.
DrinkingWindow effectiveWindow(
  DrinkingWindow adjusted, {
  int? overrideEndYear,
}) {
  final end = overrideEndYear;
  if (end == null) return adjusted;
  return adjusted.withYears(
    math.min(adjusted.startYear, end),
    math.min(adjusted.peakYear, end),
    end,
  );
}

/// The years the owner may choose as "Recommended until" for a wine whose
/// window without correction is [window] (BR4.6): from its start to the
/// start plus [maxOverrideSpan].
({int first, int last}) overrideYearRange(DrinkingWindow window) =>
    (first: window.startYear, last: window.startYear + maxOverrideSpan);

/// Whether [endYear] is a valid manual end for [window] (BR4.6).
bool isValidOverrideYear(DrinkingWindow window, int endYear) {
  final range = overrideYearRange(window);
  return endYear >= range.first && endYear <= range.last;
}
