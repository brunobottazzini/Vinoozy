import 'package:estimation/estimation.dart';

import 'drinking_record.dart';
import 'firestore_values.dart';

/// Field names of the `windowAdjustment` map of a wine (C3, u4-cellar).
abstract final class AdjustmentFields {
  static const String kind = 'kind';
  static const String year = 'year';
  static const String recordId = 'recordId';
}

/// The feedback of one drink applied to the base estimate (BR1.12).
class WindowAdjustment {
  const WindowAdjustment({
    required this.kind,
    required this.year,
    required this.recordId,
  });

  /// Reads a stored `windowAdjustment`, or `null` when it is not a map with
  /// a known `kind`, an integer `year` and a non-empty `recordId`.
  static WindowAdjustment? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final kind = DrinkCondition.tryParse(raw[AdjustmentFields.kind]);
    final year = FirestoreValues.integer(raw[AdjustmentFields.year]);
    final recordId = FirestoreValues.string(raw[AdjustmentFields.recordId]);
    if (kind == null || year == null || recordId == null || recordId.isEmpty) {
      return null;
    }
    return WindowAdjustment(kind: kind, year: year, recordId: recordId);
  }

  /// The adjustment given by [record], or `null` without a condition.
  static WindowAdjustment? ofRecord(DrinkingRecord record) {
    final condition = record.condition;
    if (condition == null) return null;
    return WindowAdjustment(
      kind: condition,
      year: record.drankOn.year,
      recordId: record.id,
    );
  }

  final DrinkCondition kind;

  /// Year of the drink.
  final int year;

  /// The drinking record the feedback comes from.
  final String recordId;

  Map<String, Object> toMap() => {
    AdjustmentFields.kind: kind.name,
    AdjustmentFields.year: year,
    AdjustmentFields.recordId: recordId,
  };

  @override
  bool operator ==(Object other) =>
      other is WindowAdjustment &&
      other.kind == kind &&
      other.year == year &&
      other.recordId == recordId;

  @override
  int get hashCode => Object.hash(kind, year, recordId);

  @override
  String toString() => 'WindowAdjustment(${kind.name}, $year)';
}

/// Source label of the estimate shown in the detail (BR1.9).
enum EstimateLabel {
  /// "Wine database": the window comes from the catalog.
  catalog,

  /// "Estimate for the type": the internal rules.
  typeEstimate,

  /// "Estimate corrected by your drinks": a feedback changed the window.
  correctedByDrinks,
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
  static DrinkingWindow effective(
    DrinkingWindow base,
    WindowAdjustment? adjustment,
  ) {
    if (adjustment == null) return base;
    final y = adjustment.year;
    final (start, peak, end) = switch (adjustment.kind) {
      DrinkCondition.justRight when y > base.endYear => (
        base.startYear,
        base.peakYear,
        y + 1,
      ),
      DrinkCondition.pastPeak when y < base.endYear && y >= base.startYear => (
        base.startYear,
        base.peakYear < y ? base.peakYear : y,
        y,
      ),
      DrinkCondition.pastPeak when y < base.startYear => _shift(
        base,
        y - base.endYear,
      ),
      DrinkCondition.tooYoung when y >= base.startYear => _shift(
        base,
        y + 1 - base.startYear,
      ),
      _ => (base.startYear, base.peakYear, base.endYear),
    };
    if (start == base.startYear &&
        peak == base.peakYear &&
        end == base.endYear) {
      return base;
    }
    if (start < minYear || end > maxYear) return base;
    return DrinkingWindow(
      startYear: start,
      peakYear: peak,
      endYear: end,
      confidence: lowered(base.confidence),
      source: base.source,
      basis: base.basis,
      qualifier: base.qualifier,
    );
  }

  static (int, int, int) _shift(DrinkingWindow base, int years) =>
      (base.startYear + years, base.peakYear + years, base.endYear + years);

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

  /// The source label of a wine's estimate (functional-spec "Fonte
  /// mostrata"): corrected only when an adjustment exists and the window
  /// differs from the base; otherwise the source of the window.
  static EstimateLabel labelOf({
    required DrinkingWindow window,
    DrinkingWindow? base,
    WindowAdjustment? adjustment,
  }) {
    if (adjustment != null && base != null && !_sameYears(window, base)) {
      return EstimateLabel.correctedByDrinks;
    }
    return (base ?? window).source == WindowSource.catalog
        ? EstimateLabel.catalog
        : EstimateLabel.typeEstimate;
  }

  static bool _sameYears(DrinkingWindow a, DrinkingWindow b) =>
      a.startYear == b.startYear &&
      a.peakYear == b.peakYear &&
      a.endYear == b.endYear;
}
