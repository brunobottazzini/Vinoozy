// "Level" of a wine (label-autofill-windows ENT-005, FR4, BR4.1, BR4.2).
//
// Oenology choice of the team (project.md correction: wine-domain values are
// decided autonomously, with their reason, and can be corrected):
// - `everyday` brings the window to about 60%: the basic versions of a
//   denomination are made to be drunk early (start x0.5, peak x0.6,
//   end x0.6);
// - `aging` brings it to about 140%: selections, crus and great vintages
//   have more structure (start x1.25, peak x1.3, end x1.4);
// - the start moves less than the end, because even a great wine can be
//   opened relatively early.

import 'tables.dart' show YearOffsets;

/// The three levels of FR4.1; "not chosen" is `null` and estimates as
/// [good].
enum WineLevel {
  everyday(50, 60, 60),
  good(100, 100, 100),
  aging(125, 130, 140);

  const WineLevel(this.startPercent, this.peakPercent, this.endPercent);

  /// Factors of BR4.1 in percent, so the arithmetic stays on integers.
  final int startPercent;
  final int peakPercent;
  final int endPercent;

  /// The level stored as [value] (`everyday`, `good`, `aging`), or `null`
  /// for anything else: an unknown value reads as "not chosen" (NFR1.1).
  static WineLevel? tryParse(Object? value) {
    if (value is! String) return null;
    for (final level in values) {
      if (level.name == value) return level;
    }
    return null;
  }

  /// [offsets] with this level applied (BR4.1): each offset multiplied by its
  /// factor and rounded to the nearest integer (0.5 up), then ordered so that
  /// start <= peak <= end and end >= start + 1. [qualifierUsed] is true when
  /// the offsets already are those of a qualifier: `aging` does not multiply
  /// them again, `everyday` does (BR4.2).
  YearOffsets apply(YearOffsets offsets, {bool qualifierUsed = false}) {
    if (this == good || (this == aging && qualifierUsed)) return offsets;
    final start = _scaled(offsets.start, startPercent);
    var peak = _scaled(offsets.peak, peakPercent);
    var end = _scaled(offsets.end, endPercent);
    if (peak < start) peak = start;
    if (end < peak) end = peak;
    if (end < start + 1) end = start + 1;
    return YearOffsets(start, peak, end);
  }

  static int _scaled(int offset, int percent) => (offset * percent + 50) ~/ 100;
}
