import '../../cellar/domain/firestore_values.dart';

/// Field names of `usage/{uid}/periods/{YYYY-MM}` and of its
/// `devices/{installationId}` documents (study §7.6, freemium-plus FR6.5).
/// Both are written only by the backend (`reportUsage`); the client reads
/// only its own.
abstract final class UsageFields {
  static const String policyVersion = 'policyVersion';
  static const String estimatedReadCount = 'estimatedReadCount';
  static const String estimatedWriteCount = 'estimatedWriteCount';
  static const String estimatedEgressBytes = 'estimatedEgressBytes';
  static const String updatedAt = 'updatedAt';

  static const String lastSequence = 'lastSequence';
  static const String cumulativeReadCount = 'cumulativeReadCount';
  static const String cumulativeWriteCount = 'cumulativeWriteCount';
  static const String cumulativeEgressBytes = 'cumulativeEgressBytes';
}

/// Estimated reads, confirmed writes and bytes received from Firestore
/// (`R_hat`, `W_hat`, `B_hat` of study §7.3). Only numbers, never content
/// (NFR6). Every value is a non-negative integer.
class UsageCounters {
  const UsageCounters({this.reads = 0, this.writes = 0, this.egressBytes = 0})
    : assert(reads >= 0 && writes >= 0 && egressBytes >= 0);

  static const UsageCounters zero = UsageCounters();

  /// The account total of a period document. A missing, mistyped or negative
  /// value reads as 0, so a damaged document never invents usage.
  factory UsageCounters.fromPeriodMap(Map<String, Object?> data) =>
      UsageCounters(
        reads: _count(data[UsageFields.estimatedReadCount]),
        writes: _count(data[UsageFields.estimatedWriteCount]),
        egressBytes: _count(data[UsageFields.estimatedEgressBytes]),
      );

  /// The last cumulative values accepted for one installation.
  factory UsageCounters.fromDeviceMap(Map<String, Object?> data) =>
      UsageCounters(
        reads: _count(data[UsageFields.cumulativeReadCount]),
        writes: _count(data[UsageFields.cumulativeWriteCount]),
        egressBytes: _count(data[UsageFields.cumulativeEgressBytes]),
      );

  static int _count(Object? value) {
    final count = FirestoreValues.integer(value);
    return count == null || count < 0 ? 0 : count;
  }

  final int reads;
  final int writes;
  final int egressBytes;

  bool get isZero => reads == 0 && writes == 0 && egressBytes == 0;

  UsageCounters operator +(UsageCounters other) => UsageCounters(
    reads: reads + other.reads,
    writes: writes + other.writes,
    egressBytes: egressBytes + other.egressBytes,
  );

  /// The usage added since [previous], for cumulative counters that may only
  /// grow (study §7.6). Null when any value went down: the caller must not
  /// apply it (a reset or a forged upload).
  UsageCounters? deltaSince(UsageCounters previous) {
    if (reads < previous.reads ||
        writes < previous.writes ||
        egressBytes < previous.egressBytes) {
      return null;
    }
    return UsageCounters(
      reads: reads - previous.reads,
      writes: writes - previous.writes,
      egressBytes: egressBytes - previous.egressBytes,
    );
  }

  /// Fields of a cumulative device report (the upload payload, FR6.3).
  Map<String, Object?> toCumulativeMap() => {
    UsageFields.cumulativeReadCount: reads,
    UsageFields.cumulativeWriteCount: writes,
    UsageFields.cumulativeEgressBytes: egressBytes,
  };

  @override
  bool operator ==(Object other) =>
      other is UsageCounters &&
      other.reads == reads &&
      other.writes == writes &&
      other.egressBytes == egressBytes;

  @override
  int get hashCode => Object.hash(reads, writes, egressBytes);

  @override
  String toString() =>
      'UsageCounters(reads: $reads, writes: $writes, bytes: $egressBytes)';
}

/// A usage period: one UTC calendar month (study §7.1 `usagePeriodTimeZone`).
class UsagePeriod {
  const UsagePeriod._(this.year, this.month);

  /// The period that contains [instant], read in UTC whatever its zone.
  factory UsagePeriod.containing(DateTime instant) {
    final utc = instant.toUtc();
    return UsagePeriod._(utc.year, utc.month);
  }

  /// Parses a `YYYY-MM` id; null when it is not one.
  static UsagePeriod? tryParse(String id) {
    final match = _idPattern.firstMatch(id);
    if (match == null) return null;
    final month = int.parse(match.group(2)!);
    if (month < 1 || month > 12) return null;
    return UsagePeriod._(int.parse(match.group(1)!), month);
  }

  static final RegExp _idPattern = RegExp(r'^([0-9]{4})-([0-9]{2})$');

  final int year;
  final int month;

  /// Document id of `usage/{uid}/periods/{id}`.
  String get id =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}';

  /// First instant of the period, 00:00 UTC of day 1.
  DateTime get startUtc => DateTime.utc(year, month);

  /// First instant of the next period: when the counters start again
  /// (FR6.5). The UI shows it in the device's local time (FR7.5).
  DateTime get nextResetUtc => DateTime.utc(year, month + 1);

  @override
  bool operator ==(Object other) =>
      other is UsagePeriod && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => id;
}
