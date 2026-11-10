// freemium-plus FR6.2, plan decision D3: the estimated cost in exact integer
// arithmetic and the strict threshold, on every boundary of study §7.4 and
// §7.11.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/usage/domain/usage_counters.dart';
import 'package:vinoozy/usage/usage_cost.dart';

void main() {
  const budget = '0.005';

  bool above(int reads, int writes, int bytes) => UsageCost.isAboveBudget(
    UsageCounters(reads: reads, writes: writes, egressBytes: bytes),
    budget,
  );

  UsageCounters times(UsageCounters unit, int n) => UsageCounters(
    reads: unit.reads * n,
    writes: unit.writes * n,
    egressBytes: unit.egressBytes * n,
  );

  test('14,285 reads are below, 14,286 above', () {
    expect(above(14285, 0, 0), isFalse);
    expect(above(14286, 0, 0), isTrue);
  });

  test('4,807 writes are below, 4,808 above', () {
    expect(above(0, 4807, 0), isFalse);
    expect(above(0, 4808, 0), isTrue);
  });

  test('44,739,242 bytes are below, 44,739,243 above', () {
    expect(above(0, 0, 44739242), isFalse);
    expect(above(0, 0, 44739243), isTrue);
  });

  test('14,256 reads + 10 writes are exactly the threshold: not above', () {
    final cost = UsageCost.scaledCost(
      const UsageCounters(reads: 14256, writes: 10),
    );
    // C_hat == 0.005 EUR exactly: 0.005 · 10^8 · 2^30.
    expect(cost * BigInt.from(1000), BigInt.from(5) * UsageCost.euroUnits);
    expect(above(14256, 10, 0), isFalse);
    expect(above(14256, 11, 0), isTrue);
  });

  test('479 loads of 20 reads + 30 KiB are below, 480 above', () {
    const load = UsageCounters(reads: 20, egressBytes: 30 * 1024);
    expect(UsageCost.isAboveBudget(times(load, 479), budget), isFalse);
    expect(UsageCost.isAboveBudget(times(load, 480), budget), isTrue);
  });

  test('427 cycles of 20 reads + 1 write + 32 KiB are below, 428 above', () {
    const cycle = UsageCounters(reads: 20, writes: 1, egressBytes: 32 * 1024);
    expect(UsageCost.isAboveBudget(times(cycle, 427), budget), isFalse);
    expect(UsageCost.isAboveBudget(times(cycle, 428), budget), isTrue);
  });

  test('no usage is below any positive budget; a zero budget needs usage', () {
    expect(UsageCost.isAboveBudget(UsageCounters.zero, budget), isFalse);
    expect(UsageCost.isAboveBudget(UsageCounters.zero, '0'), isFalse);
    expect(UsageCost.isAboveBudget(const UsageCounters(reads: 1), '0'), isTrue);
  });

  test('other budgets are read exactly ("0.01", "1")', () {
    expect(
      UsageCost.isAboveBudget(const UsageCounters(reads: 28571), '0.01'),
      isFalse,
    );
    expect(
      UsageCost.isAboveBudget(const UsageCounters(reads: 28572), '0.01'),
      isTrue,
    );
    expect(
      UsageCost.isAboveBudget(const UsageCounters(reads: 2857142), '1'),
      isFalse,
    );
  });

  test('a budget that is not a plain decimal is refused', () {
    expect(
      () => UsageCost.isAboveBudget(UsageCounters.zero, '-1'),
      throwsFormatException,
    );
    expect(
      () => UsageCost.isAboveBudget(UsageCounters.zero, '5e-3'),
      throwsFormatException,
    );
  });

  test('very large counters do not overflow', () {
    const huge = UsageCounters(
      reads: 9000000000000000,
      writes: 9000000000000000,
      egressBytes: 9000000000000000,
    );
    expect(UsageCost.isAboveBudget(huge, budget), isTrue);
  });
}
