// UsageCounters and UsagePeriod (freemium-plus FR6.1, FR6.3, FR6.5): numbers
// only, monotonic cumulative values, UTC calendar months.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/usage/domain/usage_counters.dart';

void main() {
  group('UsageCounters', () {
    test('reads a period total and a device cumulative', () {
      final total = UsageCounters.fromPeriodMap({
        UsageFields.estimatedReadCount: 120,
        UsageFields.estimatedWriteCount: 4,
        UsageFields.estimatedEgressBytes: 245760,
      });
      final device = UsageCounters.fromDeviceMap({
        UsageFields.lastSequence: 3,
        UsageFields.cumulativeReadCount: 20,
        UsageFields.cumulativeWriteCount: 1.0,
        UsageFields.cumulativeEgressBytes: 2048,
      });

      expect(
        total,
        const UsageCounters(reads: 120, writes: 4, egressBytes: 245760),
      );
      expect(
        device,
        const UsageCounters(reads: 20, writes: 1, egressBytes: 2048),
      );
    });

    test('missing, negative or mistyped values read as 0', () {
      final counters = UsageCounters.fromPeriodMap({
        UsageFields.estimatedReadCount: -5,
        UsageFields.estimatedWriteCount: 'many',
      });
      expect(counters, UsageCounters.zero);
      expect(counters.isZero, isTrue);
    });

    test('adds and serializes the cumulative payload', () {
      const a = UsageCounters(reads: 1, writes: 2, egressBytes: 3);
      const b = UsageCounters(reads: 10, writes: 20, egressBytes: 30);

      expect(
        a + b,
        const UsageCounters(reads: 11, writes: 22, egressBytes: 33),
      );
      expect((a + b).toCumulativeMap(), {
        UsageFields.cumulativeReadCount: 11,
        UsageFields.cumulativeWriteCount: 22,
        UsageFields.cumulativeEgressBytes: 33,
      });
      expect((a + b).isZero, isFalse);
      expect(a.toString(), 'UsageCounters(reads: 1, writes: 2, bytes: 3)');
      expect(
        a.hashCode,
        const UsageCounters(reads: 1, writes: 2, egressBytes: 3).hashCode,
      );
    });

    test('the delta of growing cumulative values', () {
      const before = UsageCounters(reads: 10, writes: 1, egressBytes: 2048);
      const after = UsageCounters(reads: 15, writes: 1, egressBytes: 4096);

      expect(
        after.deltaSince(before),
        const UsageCounters(reads: 5, egressBytes: 2048),
      );
      expect(after.deltaSince(after), UsageCounters.zero);
    });

    test('no delta when any cumulative value went down', () {
      const before = UsageCounters(reads: 10, writes: 2, egressBytes: 2048);

      expect(
        const UsageCounters(
          reads: 9,
          writes: 2,
          egressBytes: 2048,
        ).deltaSince(before),
        isNull,
      );
      expect(
        const UsageCounters(
          reads: 10,
          writes: 1,
          egressBytes: 2048,
        ).deltaSince(before),
        isNull,
      );
      expect(
        const UsageCounters(
          reads: 10,
          writes: 2,
          egressBytes: 0,
        ).deltaSince(before),
        isNull,
      );
    });
  });

  group('UsagePeriod', () {
    test('the UTC month of an instant, whatever its zone', () {
      // 23:30 on 31 October in UTC-2 is already November in UTC.
      final instant = DateTime.parse('2026-10-31T23:30:00-02:00');
      final period = UsagePeriod.containing(instant);

      expect(period.id, '2026-11');
      expect(period.startUtc, DateTime.utc(2026, 11));
      expect(period.nextResetUtc, DateTime.utc(2026, 12));
      expect(period.toString(), '2026-11');
    });

    test('December resets on 1 January of the next year', () {
      final period = UsagePeriod.containing(DateTime.utc(2026, 12, 31, 23, 59));
      expect(period.nextResetUtc, DateTime.utc(2027));
    });

    test('parses a period id and refuses anything else', () {
      expect(
        UsagePeriod.tryParse('2026-03'),
        UsagePeriod.containing(DateTime.utc(2026, 3, 15)),
      );
      expect(
        UsagePeriod.tryParse('2026-03').hashCode,
        UsagePeriod.containing(DateTime.utc(2026, 3)).hashCode,
      );
      for (final id in [
        '2026-13',
        '2026-00',
        '2026-3',
        '26-03',
        '2026-03-01',
      ]) {
        expect(UsagePeriod.tryParse(id), isNull, reason: id);
      }
    });
  });
}
