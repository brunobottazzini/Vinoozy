// W2, status of a wine on a given day (BR3.2, BR3.3), with integer month
// arithmetic only: no intermediate dates besides `today`.
// wine-style-profiles (BR6.3) compares month indexes (BR6.1), so windows in
// years give today's result and windows in months, without a peak or
// without an end, use the same rule.

import 'models.dart';
import 'validation.dart';

/// Share of the window, in percent, used as the "drink soon" notice.
const int _noticePercent = 25;
const int _minNoticeMonths = 3;
const int _maxNoticeMonths = 12;

/// Notice of a window without a peak (BR6.3): the last 3 months.
const int _noPeakNoticeMonths = 3;

/// Status of [window] on [today], a local calendar date whose time is
/// ignored (C2 `statusOf`). Throws [EstimationArgumentError] with
/// `invalidWindow` when the window is not ordered (BR6.10).
///
/// BR6.3: T, S and E are the month indexes of today, of the start and of the
/// end. Before the start the wine is waiting; after the end its window has
/// passed; without an end it is always ready. The notice is 25% of the
/// window (3 to 12 months), or 3 months without a peak; the wine is "drink
/// soon" when the months left (E - T + 1) are within the notice.
WineStatus statusOf(DrinkingWindow window, DateTime today) {
  validateWindow(window);
  final now = monthIndex(today.year, today.month);
  final start = window.startIndex;
  final end = window.endIndex;
  if (now < start) return WineStatus.waiting;
  if (end == null) return WineStatus.ready;
  if (now > end) return WineStatus.pastWindow;

  final noticeMonths = window.peakYear == null
      ? _noPeakNoticeMonths
      : (((end - start + 1) * _noticePercent + 50) ~/ 100).clamp(
          _minNoticeMonths,
          _maxNoticeMonths,
        );
  final remainingMonths = end - now + 1;
  return remainingMonths <= noticeMonths
      ? WineStatus.drinkSoon
      : WineStatus.ready;
}
