import 'package:estimation/estimation.dart';

import 'drinking_record.dart';
import 'firestore_values.dart';
import 'window_override.dart';

/// Field names of the `windowAdjustment` map of a wine (C3, u4-cellar).
abstract final class AdjustmentFields {
  static const String kind = 'kind';
  static const String year = 'year';
  static const String recordId = 'recordId';

  /// wine-style-profiles BR6.9: the month (1-12) of the drink.
  static const String month = 'month';
}

/// The feedback of one drink applied to the base estimate (BR1.12).
class WindowAdjustment {
  const WindowAdjustment({
    required this.kind,
    required this.year,
    required this.recordId,
    this.month,
  });

  /// Reads a stored `windowAdjustment`, or `null` when it is not a map with
  /// a known `kind`, an integer `year` and a non-empty `recordId`. A
  /// `month` outside 1-12 reads as missing.
  static WindowAdjustment? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final kind = DrinkCondition.tryParse(raw[AdjustmentFields.kind]);
    final year = FirestoreValues.integer(raw[AdjustmentFields.year]);
    final recordId = FirestoreValues.string(raw[AdjustmentFields.recordId]);
    if (kind == null || year == null || recordId == null || recordId.isEmpty) {
      return null;
    }
    final month = FirestoreValues.integer(raw[AdjustmentFields.month]);
    return WindowAdjustment(
      kind: kind,
      year: year,
      recordId: recordId,
      month: month != null && month >= 1 && month <= 12 ? month : null,
    );
  }

  /// The adjustment given by [record], or `null` without a condition.
  static WindowAdjustment? ofRecord(DrinkingRecord record) {
    final condition = record.condition;
    if (condition == null) return null;
    return WindowAdjustment(
      kind: condition,
      year: record.drankOn.year,
      month: record.drankOn.month,
      recordId: record.id,
    );
  }

  final DrinkCondition kind;

  /// Year of the drink.
  final int year;

  /// Month of the drink (BR6.9); `null` for adjustments saved before it,
  /// read as December on a window in months.
  final int? month;

  /// The drinking record the feedback comes from.
  final String recordId;

  Map<String, Object> toMap() => {
    AdjustmentFields.kind: kind.name,
    AdjustmentFields.year: year,
    AdjustmentFields.recordId: recordId,
    AdjustmentFields.month: ?month,
  };

  @override
  bool operator ==(Object other) =>
      other is WindowAdjustment &&
      other.kind == kind &&
      other.year == year &&
      other.month == month &&
      other.recordId == recordId;

  @override
  int get hashCode => Object.hash(kind, year, month, recordId);

  @override
  String toString() =>
      'WindowAdjustment(${kind.name}, $year${month == null ? '' : '-$month'})';
}

/// Source label of the estimate shown in the detail (BR1.9).
enum EstimateLabel {
  /// "Wine database": the window comes from the catalog.
  catalog,

  /// "Estimate for the type": the internal rules.
  typeEstimate,

  /// "Estimate corrected by your drinks": a feedback changed the window.
  correctedByDrinks,

  /// "Corrected by you" (label-autofill-windows FR5.2, BR4.7): the owner set
  /// "Recommended until"; it comes before every other label.
  correctedByYou,
}

/// Applies the drink feedback to the base estimate (BR1.12). Pure: no
/// Flutter, no Firebase, so the benchmark runs it with `dart run`.
///
/// Oenology choice of u4-cellar (Q1), with Y the year of the drink:
/// - `justRight` with Y after the end: the end moves to Y + 1, the peak stays;
/// - `pastPeak` with Y before the end: from the start on, the end becomes Y
///   and the peak never exceeds it; before the start, the whole window moves
///   back by (end − Y) years, keeping its length;
/// - `tooYoung` with Y from the start on: the whole window moves forward by
///   (Y + 1 − start) years;
/// - otherwise the base window stays.
///
/// One tasting is weak evidence, so a changed window loses one confidence
/// level, never below `low`.
abstract final class WindowAdjuster {
  /// Smallest and largest years the rules accept in a window.
  static const int minYear = 1900;
  static const int maxYear = 2200;

  /// The effective window of [base] with [adjustment]. A result outside the
  /// years accepted by the rules falls back to [base].
  ///
  /// wine-style-profiles BR6.9: the rules work on the window's own unit. On
  /// a window in years, Y is the year of the drink, as before; on a window
  /// in months, Y is the month index of the drink (December of its year
  /// when the adjustment has no month) and "Y + 1" is the next month.
  /// Without an end, `justRight` and `pastPeak` change nothing and
  /// `tooYoung` moves the start (and the peak).
  static DrinkingWindow effective(
    DrinkingWindow base,
    WindowAdjustment? adjustment,
  ) {
    if (adjustment == null) return base;
    final months = base.inMonths;
    final y = months
        ? monthIndex(adjustment.year, adjustment.month ?? 12)
        : adjustment.year;
    final s = months ? base.startIndex : base.startYear;
    final p = months ? base.peakIndex : base.peakYear;
    final e = months ? base.endIndex : base.endYear;
    final (start, peak, end) = switch (adjustment.kind) {
      DrinkCondition.justRight when e != null && y > e => (s, p, y + 1),
      DrinkCondition.pastPeak when e != null && y < e && y >= s => (
        s,
        p == null ? null : (p < y ? p : y),
        y,
      ),
      DrinkCondition.pastPeak when e != null && y < s => _shift(s, p, e, y - e),
      DrinkCondition.tooYoung when y >= s => _shift(s, p, e, y + 1 - s),
      _ => (s, p, e),
    };
    if (start == s && peak == p && end == e) return base;
    final moved = months
        ? base.withIndexes(start, peak, end)
        : base.withYears(start, peak, end);
    if (moved.startYear < minYear || (moved.endYear ?? minYear) > maxYear) {
      return base;
    }
    return DrinkingWindow(
      startYear: moved.startYear,
      peakYear: moved.peakYear,
      endYear: moved.endYear,
      confidence: lowered(base.confidence),
      source: base.source,
      basis: base.basis,
      qualifier: base.qualifier,
      // wine-style-profiles: the effective window keeps the row and the
      // version of its base, so the two differ only in dates and confidence
      // (validBaseWindow of firestore.rules).
      denominationKey: base.denominationKey,
      tablesVersion: base.tablesVersion,
      unit: base.unit,
      startMonth: moved.startMonth,
      peakMonth: moved.peakMonth,
      endMonth: moved.endMonth,
      profile: base.profile,
      anchor: base.anchor,
      anchorFallback: base.anchorFallback,
      indicative: base.indicative,
    );
  }

  static (int, int?, int?) _shift(int s, int? p, int? e, int by) =>
      (s + by, p == null ? null : p + by, e == null ? null : e + by);

  /// One confidence level lower, at least `low`.
  static Confidence lowered(Confidence confidence) => switch (confidence) {
    Confidence.high => Confidence.medium,
    Confidence.medium || Confidence.low => Confidence.low,
  };

  /// The feedback that counts (BR1.12): the record with a condition that is
  /// the most recent by `drankOn`, then `createdAt`; `null` when none has one.
  static WindowAdjustment? pick(Iterable<DrinkingRecord> records) {
    DrinkingRecord? latest;
    for (final record in records) {
      if (record.condition == null) continue;
      if (latest == null ||
          DrinkingRecord.compareRecentFirst(record, latest) < 0) {
        latest = record;
      }
    }
    return latest == null ? null : WindowAdjustment.ofRecord(latest);
  }

  /// The effective window of a wine (label-autofill-windows BR4.4, BR4.5):
  /// [base] (the estimate, level included) with the drink feedback, then
  /// the owner's end year. The one function every place that writes or
  /// shows a window uses.
  static DrinkingWindow effectiveOf(
    DrinkingWindow base,
    WindowAdjustment? adjustment,
    WindowOverride? override,
  ) => effectiveWindow(
    effective(base, adjustment),
    overrideEndYear: override?.endYear,
    overrideEndMonth: override?.endMonth,
  );

  /// The source label of a wine's estimate (functional-spec "Fonte
  /// mostrata", label-autofill-windows BR4.7): "corrected by you" with an
  /// override; "corrected by your drinks" when an adjustment changes the
  /// base (the base already holds the level, so a level is never taken for
  /// a feedback); otherwise the source of the window.
  static EstimateLabel labelOf({
    required DrinkingWindow window,
    DrinkingWindow? base,
    WindowAdjustment? adjustment,
    WindowOverride? override,
  }) {
    if (override != null) return EstimateLabel.correctedByYou;
    if (adjustment != null &&
        base != null &&
        !_sameYears(effective(base, adjustment), base)) {
      return EstimateLabel.correctedByDrinks;
    }
    return (base ?? window).source == WindowSource.catalog
        ? EstimateLabel.catalog
        : EstimateLabel.typeEstimate;
  }

  static bool _sameYears(DrinkingWindow a, DrinkingWindow b) =>
      a.startIndex == b.startIndex &&
      a.peakIndex == b.peakIndex &&
      a.endIndex == b.endIndex;
}
