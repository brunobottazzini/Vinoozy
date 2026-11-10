// freemium-plus FR6.3, NFR3, NFR4 (study §7.6): the uploader sends
// cumulatives with a sequence; a retry is idempotent; the app decides on the
// server total plus only the local delta not yet acknowledged; a late
// upload of last month goes to last month; at most 5 uploads in one hour.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/usage/cloud_usage_meter.dart';
import 'package:vinoozy/usage/domain/usage_counters.dart';
import 'package:vinoozy/usage/usage_uploader.dart';

import '../helpers/fakes.dart';

/// A backend that keeps, per installation and period, the last accepted
/// cumulative and adds only the delta, like `reportUsage` (FR6.3).
class _FakeBackend implements UsageReportClient {
  _FakeBackend(this.clock);

  final FakeClock clock;
  final List<UsageReport> reports = [];
  final Map<String, UsageCounters> accepted = {};
  final Map<String, int> sequences = {};

  /// Usage of other devices of the account, per period.
  final Map<String, UsageCounters> others = {};
  Object? failWith;
  bool refuse = false;

  /// The `reason` of a refusal (functions/README.md).
  String? refuseReason;

  @override
  Future<UsageReportResult> report(UsageReport report) async {
    reports.add(report);
    final failure = failWith;
    if (failure != null) throw failure;
    final key = '${report.installationId}/${report.periodId}';
    final period = UsagePeriod.tryParse(report.periodId)!;
    if (refuse) {
      return UsageReportResult(
        accepted: false,
        reason: refuseReason,
        accountTotal: total(report.periodId),
        serverTime: clock.now(),
        nextResetUtc: period.nextResetUtc,
      );
    }
    if ((sequences[key] ?? 0) <= report.sequence) {
      accepted[key] = report.cumulative;
      sequences[key] = report.sequence;
    }
    return UsageReportResult(
      accepted: true,
      accountTotal: total(report.periodId),
      serverTime: clock.now(),
      nextResetUtc: period.nextResetUtc,
    );
  }

  UsageCounters total(String periodId) {
    var sum = others[periodId] ?? UsageCounters.zero;
    for (final entry in accepted.entries) {
      if (entry.key.endsWith('/$periodId')) sum = sum + entry.value;
    }
    return sum;
  }
}

void main() {
  late InMemoryKeyValueStore store;
  late RecordingErrorSink sink;
  late FakeClock clock;
  late CloudUsageMeter meter;
  late _FakeBackend backend;
  late UsageUploader uploader;
  late List<void Function(Timer)> timers;

  final november = UsagePeriod.tryParse('2026-11')!;

  UsageUploader newUploader() => UsageUploader(
    meter: meter,
    client: backend,
    store: store,
    reporter: recordingReporter(sink),
    clock: clock,
    periodic: (interval, callback) {
      timers.add(callback);
      return Timer(const Duration(days: 365), () {});
    },
  );

  setUp(() async {
    store = InMemoryKeyValueStore();
    sink = RecordingErrorSink();
    clock = FakeClock(DateTime.utc(2026, 11, 10, 12));
    meter = CloudUsageMeter(
      store: store,
      reporter: recordingReporter(sink),
      clock: clock,
      ids: SequenceIdGenerator(prefix: 'install'),
    );
    await meter.start('user-a');
    backend = _FakeBackend(clock);
    timers = [];
    uploader = newUploader();
    await uploader.start();
  });

  tearDown(() => uploader.stop());

  group('refusals by reason', () {
    Future<void> countInSeptember() async {
      clock.current = DateTime.utc(2026, 9, 20, 12);
      meter.recordQuery(documents: 6);
      clock.current = DateTime.utc(2026, 11, 10, 12);
    }

    test('PERIOD_CLOSED drops that month instead of retrying it', () async {
      await countInSeptember();
      backend
        ..refuse = true
        ..refuseReason = UsageReportResult.periodClosed;

      await uploader.uploadNow();
      expect(backend.reports.single.periodId, '2026-09');
      expect(meter.periods.containsKey('2026-09'), isFalse);

      clock.current = clock.current.add(const Duration(minutes: 20));
      await uploader.uploadNow();
      expect(backend.reports, hasLength(1), reason: 'never sent again');
    });

    test(
      'STALE_SEQUENCE keeps the month and retries with a new sequence',
      () async {
        await countInSeptember();
        backend
          ..refuse = true
          ..refuseReason = 'STALE_SEQUENCE';

        await uploader.uploadNow();
        backend.refuse = false;
        await uploader.uploadNow();

        expect(backend.reports.map((r) => r.periodId), ['2026-09', '2026-09']);
        expect(backend.reports.map((r) => r.sequence), [1, 2]);
      },
    );

    test(
      'PERIOD_CLOSED for a past month never drops the current one',
      () async {
        meter.recordQuery(documents: 2);
        backend
          ..refuse = true
          ..refuseReason = UsageReportResult.periodClosed;

        await uploader.uploadNow();

        expect(meter.periods.containsKey('2026-11'), isTrue);
      },
    );
  });

  test('FR6.3 a retry of the same cumulative is idempotent', () async {
    meter.recordQuery(documents: 10);

    await uploader.uploadNow();
    clock.current = clock.current.add(const Duration(minutes: 20));
    await uploader.uploadNow();

    expect(backend.reports, hasLength(1), reason: 'nothing new to send');
    expect(backend.reports.single.sequence, 1);
    expect(uploader.estimatedTotal(november).reads, 10);
  });

  test('FR6.3 a failed upload is sent again with the same sequence', () async {
    meter.recordQuery(documents: 4);
    backend.failWith = StateError('offline');

    await uploader.uploadNow();
    expect(sink.reasons, contains('UsageUploadFailed'));
    expect(uploader.isVerified(november), isFalse);

    backend.failWith = null;
    await uploader.uploadNow();

    expect(backend.reports.map((r) => r.sequence), [1, 1]);
    expect(uploader.isVerified(november), isTrue);
  });

  test('a new cumulative gets a new sequence', () async {
    meter.recordQuery(documents: 4);
    await uploader.uploadNow();
    meter.recordWrites(2);
    await uploader.uploadNow();

    expect(backend.reports.map((r) => r.sequence), [1, 2]);
    expect(
      backend.reports.last.cumulative,
      const UsageCounters(reads: 4, writes: 2, egressBytes: 8192),
    );
  });

  test('a refused report is sent next time with a new sequence', () async {
    meter.recordWrites(1);
    backend.refuse = true;
    await uploader.uploadNow();
    backend.refuse = false;
    await uploader.uploadNow();

    expect(backend.reports.map((r) => r.sequence), [1, 2]);
  });

  test('FR6.3 the total is the server total plus only the unacknowledged '
      'local delta', () async {
    backend.others['2026-11'] = const UsageCounters(reads: 100);
    meter.recordWrites(5);
    await uploader.uploadNow();
    expect(
      uploader.estimatedTotal(november),
      const UsageCounters(reads: 100, writes: 5),
    );

    meter.recordWrites(3);

    // 100 reads of another device + 5 acknowledged + 3 local, never 5 twice.
    expect(
      uploader.estimatedTotal(november),
      const UsageCounters(reads: 100, writes: 8),
    );
  });

  test(
    'two devices add up and a reinstall does not reset the account',
    () async {
      meter.recordWrites(5);
      await uploader.uploadNow();

      // A reinstall: a new installation id, the account total stays.
      store.values.remove(CloudUsageMeter.installationKey);
      store.values.remove('${UsageUploader.storagePrefix}user-a');
      store.values.remove('${CloudUsageMeter.storagePrefix}user-a');
      meter = CloudUsageMeter(
        store: store,
        reporter: recordingReporter(sink),
        clock: clock,
        ids: SequenceIdGenerator(prefix: 'reinstalled'),
      );
      await meter.start('user-a');
      uploader = newUploader();
      await uploader.start();
      meter.recordWrites(2);
      await uploader.uploadNow();

      expect(backend.reports.last.installationId, isNot('install-1'));
      expect(uploader.estimatedTotal(november).writes, 7);
    },
  );

  test('FR6.5 a new month: last month is uploaded to last month, then '
      'forgotten', () async {
    clock.current = DateTime.utc(2026, 11, 30, 23, 50);
    meter.recordWrites(3);
    clock.current = DateTime.utc(2026, 12, 1, 0, 10);
    meter.recordWrites(1);

    await uploader.uploadNow();

    final byPeriod = {for (final r in backend.reports) r.periodId: r};
    expect(byPeriod['2026-11']!.cumulative.writes, 3);
    expect(byPeriod['2026-12']!.cumulative.writes, 1);
    expect(meter.periods.keys, ['2026-12'], reason: 'November is done');
  });

  test('FR6.2 the first local crossing uploads at once, once', () async {
    meter.recordWrites(4808);
    await pumpEventQueue();

    expect(backend.reports, hasLength(1));
    expect(uploader.isAboveBudget(november), isTrue);

    meter.recordWrites(1);
    await pumpEventQueue();
    expect(backend.reports, hasLength(1), reason: 'only the first crossing');
  });

  test('NFR3 a one-hour session makes at most 5 uploads', () async {
    uploader.onResume();
    final start = clock.current;
    // Usage all the time, the threshold crossed at minute 5, a tick every
    // minute of the timer.
    for (var minute = 1; minute <= 60; minute++) {
      clock.current = start.add(Duration(minutes: minute));
      meter.recordQuery(documents: minute == 5 ? 20000 : 3);
      await pumpEventQueue();
      if (minute % 15 == 0) await uploader.tick();
      // An extra tick of a timer restarted by the crossing upload.
      if (minute == 20) await uploader.tick();
    }
    await uploader.onPause();

    expect(backend.reports.length, lessThanOrEqualTo(5));
    expect(backend.reports.length, greaterThanOrEqualTo(4));
    expect(uploader.uploads, backend.reports.length);
  });

  test('NFR4 no answer from the server: not verified', () async {
    meter.recordQuery(documents: 30000);
    backend.failWith = StateError('unreachable');
    await uploader.uploadNow();

    expect(uploader.isVerified(november), isFalse);
    // The local estimate still knows the usage; ads also need verification.
    expect(uploader.isAboveBudget(november), isTrue);
  });

  test('the state survives a restart', () async {
    meter.recordWrites(5);
    await uploader.uploadNow();
    await uploader.stop();

    final restarted = newUploader();
    await restarted.start();
    meter.recordWrites(1);

    expect(restarted.isVerified(november), isTrue);
    expect(restarted.estimatedTotal(november).writes, 6);
    await restarted.stop();
  });

  test('the server time sets the period of the meter (study §7.6)', () async {
    // The phone clock is 5 minutes behind the server.
    backend = _FakeBackend(
      FakeClock(clock.current.add(const Duration(minutes: 5))),
    );
    await uploader.stop();
    uploader = newUploader();
    await uploader.start();
    meter.recordWrites(1);

    await uploader.uploadNow();

    expect(meter.serverOffset, const Duration(minutes: 5));
  });

  test('clear forgets the saved state', () async {
    meter.recordWrites(1);
    await uploader.uploadNow();
    await uploader.clear('user-a');

    expect(store.values['${UsageUploader.storagePrefix}user-a'], '');
    expect(uploader.isVerified(november), isFalse);
  });
}
