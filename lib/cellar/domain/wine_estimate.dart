import 'package:estimation/estimation.dart';

import 'wine.dart';
import 'window_adjuster.dart';

/// The estimate stored with a wine (BR1.5, BR1.12): the base window, the
/// effective window after the drink feedback, the feedback itself and the
/// pairings. A `null` part is written as `null`, which clears it.
class WineEstimate {
  const WineEstimate({
    this.baseWindow,
    this.window,
    this.adjustment,
    this.pairings,
  });

  /// "To estimate": nothing known.
  static const WineEstimate none = WineEstimate();

  final DrinkingWindow? baseWindow;
  final DrinkingWindow? window;
  final WindowAdjustment? adjustment;
  final Pairings? pairings;

  /// The estimate as [wine] stores it now.
  factory WineEstimate.of(Wine wine) => WineEstimate(
    baseWindow: wine.baseWindow,
    window: wine.window,
    adjustment: wine.windowAdjustment,
    pairings: wine.pairings,
  );

  /// The four C3 fields, ready for a write.
  Map<String, Object?> toFields() => {
    WineFields.baseWindow: baseWindow == null
        ? null
        : Wine.windowToMap(baseWindow!),
    WineFields.window: window == null ? null : Wine.windowToMap(window!),
    WineFields.windowAdjustment: adjustment?.toMap(),
    WineFields.pairings: pairings == null
        ? null
        : Wine.pairingsToMap(pairings!),
  };

  @override
  bool operator ==(Object other) =>
      other is WineEstimate &&
      other.baseWindow == baseWindow &&
      other.window == window &&
      other.adjustment == adjustment &&
      other.pairings == pairings;

  @override
  int get hashCode => Object.hash(baseWindow, window, adjustment, pairings);

  @override
  String toString() =>
      'WineEstimate(base: $baseWindow, window: $window, $adjustment)';
}
