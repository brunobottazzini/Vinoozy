// freemium-plus plan Step 15 (FR1.4, FR5.5, FR6.1, FR6.3, NFR3): the plan
// session follows the account gate and the app lifecycle; sign-out removes
// the developer override but keeps the usage counters; the local reset of an
// account change also removes the counters of the previous account; the
// reset coordinator runs that cleanup before invalidating the listeners.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/gate_state.dart';
import 'package:vinoozy/account/reset_coordinator.dart';
import 'package:vinoozy/dev/dev_cheats.dart';
import 'package:vinoozy/plan/plan_session.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/usage/cloud_usage_meter.dart';
import 'package:vinoozy/usage/domain/usage_counters.dart';
import 'package:vinoozy/usage/usage_uploader.dart';

import '../helpers/fakes.dart';
import '../helpers/service_mocks.dart';

const AppUser _mario = AppUser(
  uid: 'uid-mario',
  email: 'mario@example.com',
  displayName: 'Mario',
);
const AppUser _giulia = AppUser(
  uid: 'uid-giulia',
  email: 'giulia@example.com',
  displayName: 'Giulia',
);

class _Backend implements UsageReportClient {
  _Backend(this.clock);

  final FakeClock clock;
  final List<UsageReport> reports = [];

  @override
  Future<UsageReportResult> report(UsageReport report) async {
    reports.add(report);
    final period = UsagePeriod.tryParse(report.periodId)!;
    return UsageReportResult(
      accepted: true,
      accountTotal: report.cumulative,
      serverTime: clock.now(),
      nextResetUtc: period.nextResetUtc,
    );
  }
}

void main() {
  late InMemoryKeyValueStore store;
  late RecordingErrorSink sink;
  late FakeClock clock;
  late CloudUsageMeter meter;
  late UsageUploader uploader;
  late DevOverrideStore overrides;
  late _Backend backend;
  late List<String?> sessions;
  late PlanSession session;

  setUp(() {
    store = InMemoryKeyValueStore();
    sink = RecordingErrorSink();
    clock = FakeClock(DateTime.utc(2026, 11, 10, 12));
    meter = CloudUsageMeter(
      store: store,
      reporter: recordingReporter(sink),
      clock: clock,
      ids: SequenceIdGenerator(prefix: 'install'),
    );
    backend = _Backend(clock);
    uploader = UsageUploader(
      meter: meter,
      client: backend,
      store: store,
      reporter: recordingReporter(sink),
      clock: clock,
      periodic: (_, _) => Timer(const Duration(days: 365), () {}),
    );
    overrides = DevOverrideStore(
      store: store,
      reporter: recordingReporter(sink),
    );
    sessions = [];
    session = PlanSession(
      meter: meter,
      uploader: uploader,
      store: store,
      reporter: recordingReporter(sink),
      devOverrides: overrides,
      onSessionChanged: sessions.add,
    );
  });

  tearDown(() => uploader.stop());

  Future<void> settle() => session.suspend().then((_) {});

  test('the cellar of the gate opens the session of its account', () async {
    session.onGateState(const GateStarting(), const GateCellar(_mario));
    await session.open(_mario.uid);

    expect(session.uid, _mario.uid);
    expect(meter.uid, _mario.uid);
    expect(sessions, [_mario.uid]);
    meter.recordQuery(documents: 3);
    expect(meter.periods['2026-11']!.personal.reads, 3);
  });

  test('FR5.5 sign-out removes the override and keeps the counters', () async {
    await session.open(_mario.uid);
    await overrides.write(
      DevOverride(scenario: DevScenario.unlockAll, uid: _mario.uid),
    );
    meter.recordQuery(documents: 2);
    await meter.flush();

    session.onGateState(const GateCellar(_mario), const GateSignIn());
    await session.endSession();

    expect(session.uid, isNull);
    expect(meter.uid, isNull, reason: 'nothing counted without a session');
    expect(sessions, [_mario.uid, null]);
    expect(
      await overrides.read(uid: _mario.uid, projectId: devCheatsProjectId),
      isNull,
    );
    expect(
      store.values['${CloudUsageMeter.storagePrefix}${_mario.uid}'],
      isNotEmpty,
      reason: 'sent at the next session of the same account',
    );
  });

  test('an expired session only stops counting: the override stays', () async {
    await session.open(_mario.uid);
    await overrides.write(
      DevOverride(scenario: DevScenario.simulateFree, uid: _mario.uid),
    );

    session.onGateState(
      const GateCellar(_mario),
      const GateSignIn(notice: SignInNotice.sessionExpired),
    );
    await settle();

    expect(meter.uid, isNull);
    expect(
      await overrides.read(uid: _mario.uid, projectId: devCheatsProjectId),
      isNotNull,
    );
  });

  test(
    'an account change clears the counters of the previous account',
    () async {
      await session.open(_mario.uid);
      meter.recordQuery(documents: 5);
      await meter.flush();

      await session.clearAccountData();
      await session.open(_giulia.uid);

      expect(store.values['${CloudUsageMeter.storagePrefix}${_mario.uid}'], '');
      expect(store.values['${UsageUploader.storagePrefix}${_mario.uid}'], '');
      expect(meter.periods, isEmpty, reason: 'Giulia starts from zero');
    },
  );

  test(
    'NFR3 going to the background uploads once; not without a session',
    () async {
      await session.open(_mario.uid);
      meter.recordQuery(documents: 1);

      await session.onAppPaused();
      expect(backend.reports, hasLength(1));

      await settle();
      meter.recordQuery(documents: 1);
      await session.onAppPaused();
      expect(backend.reports, hasLength(1), reason: 'no session, no upload');
    },
  );

  group('ResetCoordinator', () {
    late LocalLedger ledger;
    late MockFirestoreBootstrap bootstrap;
    late MockSyncWatcher watcher;
    late List<String> calls;

    setUp(() {
      ledger = LocalLedger(store: store, reporter: recordingReporter(sink));
      bootstrap = MockFirestoreBootstrap();
      watcher = MockSyncWatcher();
      calls = [];
      when(() => watcher.stop()).thenAnswer((_) => calls.add('stop'));
      when(() => bootstrap.resetPersistence()).thenAnswer((_) async {
        calls.add('clear');
      });
    });

    ResetCoordinator coordinator(Future<void> Function() clear) =>
        ResetCoordinator(
          ledger: ledger,
          bootstrap: bootstrap,
          watcher: watcher,
          reporter: recordingReporter(sink),
          invalidateListeners: () => calls.add('invalidate'),
          clearAccountState: clear,
        );

    test('clears the plan state before invalidating the listeners', () async {
      final outcome = await coordinator(() async {
        calls.add('plan');
      }).reset('user-b');

      expect(outcome, ResetOutcome.completed);
      expect(calls, ['stop', 'plan', 'invalidate', 'clear']);
    });

    test(
      'a failed plan cleanup is reported and never stops the reset',
      () async {
        final outcome = await coordinator(() async => throw StateError('disk'))
            .reset('user-b');

        expect(outcome, ResetOutcome.completed);
        expect(sink.reasons, contains('ResetPlanStateFailed'));
        expect(calls, ['stop', 'invalidate', 'clear']);
      },
    );
  });
}
