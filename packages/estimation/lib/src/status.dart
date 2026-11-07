// W2, status of a wine on a given day (BR3.2, BR3.3), with integer month
// arithmetic only: no intermediate dates besides `today`.

import 'models.dart';
import 'validation.dart';

/// Share of the window, in percent, used as the "drink soon" notice.
const int _noticePercent = 25;
const int _minNoticeMonths = 3;
const int _maxNoticeMonths = 12;

/// Status of [window] on [today], a local calendar date whose time is
/// ignored (C2 `statusOf`). Throws [EstimationArgumentError] with
/// `invalidWindow` when start > peak or peak > end.
WineStatus statusOf(DrinkingWindow window, DateTime today) {
  validateWindow(window);
  final year = today.year;
  if (year < window.startYear) return WineStatus.waiting;
  if (year > window.endYear) return WineStatus.pastWindow;

  final durationMonths = (window.endYear - window.startYear + 1) * 12;
  final noticeMonths = ((durationMonths * _noticePercent + 50) ~/ 100).clamp(
    _minNoticeMonths,
    _maxNoticeMonths,
  );
  // Calendar months from the first day of today's month to 1 January of
  // endYear + 1: 12 on 1 January of the last year, 4 on 1 September.
  final remainingMonths = (window.endYear + 1 - year) * 12 - (today.month - 1);
  return remainingMonths <= noticeMonths
      ? WineStatus.drinkSoon
      : WineStatus.ready;
}
