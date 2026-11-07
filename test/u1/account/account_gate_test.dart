import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/account_gate.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/auth_service.dart';
import 'package:vinoozy/account/reset_coordinator.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../../helpers/fakes.dart';
import '../../helpers/service_mocks.dart';

void main() {
  const userA = AppUser(
    uid: 'user-a',
    email: 'user-a@example.com',
    displayName: 'A',
  );
  const userB = AppUser(
    uid: 'user-b',
    email: 'user-b@example.com',
    displayName: 'B',
  );

  late MockAuthService auth;
  late LocalLedger ledger;
  late MockResetCoordinator resets;
  late MockCellarRepository cellars;
  late MockUserRepository users;
  late MockSyncWatcher watcher;
  late SyncErrorBus bus;
  late RecordingErrorSink sink;
  late StreamController<AppUser?> userChanges;
  late AccountGate gate;
  late int reopened;

  setUpAll(() => registerFallbackValue(userA));

  setUp(() {
    reopened = 0;
    auth = MockAuthService();
    sink = RecordingErrorSink();
    ledger = LocalLedger(
      store: InMemoryKeyValueStore(),
      reporter: recordingReporter(sink),
    );
    resets = MockResetCoordinator();
    cellars = MockCellarRepository();
    users = MockUserRepository();
    watcher = MockSyncWatcher();
    bus = SyncErrorBus();
    userChanges = StreamController<AppUser?>.broadcast();
    when(() => auth.userChanges()).thenAnswer((_) => userChanges.stream);
    when(() => auth.signOut()).thenAnswer((_) async {});
    when(() => cellars.isCached(any())).thenAnswer((_) async => true);
    when(
      () => cellars.ensurePersonalCellar(
        uid: any(named: 'uid'),
        defaultName: any(named: 'defaultName'),
      ),
    ).thenAnswer((_) async {});
    when(() => users.ensureProfile(any())).thenAnswer((_) async {});
    when(() => watcher.start(any())).thenAnswer((_) async {});
    gate = AccountGate(
      auth: auth,
      ledger: ledger,
      resetCoordinator: resets,
      cellars: cellars,
      users: users,
      watcher: watcher,
      bus: bus,
      reporter: recordingReporter(sink),
      defaultCellarName: () => 'La mia cantina',
      reopenCellarListeners: () => reopened++,
    );
  });

  tearDown(() => userChanges.close());

  /// Stubs `ensurePersonalCellar` for userA with [answer].
  void stubEnsure(Future<void> Function() answer) => when(
    () => cellars.ensurePersonalCellar(
      uid: 'user-a',
      defaultName: 'La mia cantina',
    ),
  ).thenAnswer((_) => answer());

  group('retryCellar (BR1.3 violation, security-design.md §6, §8)', () {
    test('after a listener error with the cellar ready, "Riprova" checks the '
        'cellar first and only then reopens the listeners', () async {
      when(() => auth.currentUser).thenReturn(userA);
      await gate.start();
      expect((gate.current as GateCellar).setupFailed, isFalse);
      expect(reopened, 0);

      final ensure = Completer<void>();
      stubEnsure(() => ensure.future);
      final retry = gate.retryCellar();
      await pumpEventQueue();

      expect(gate.current, isA<GateEnsureCellar>());
      expect(reopened, 0, reason: 'listeners reopen only after the check');

      ensure.complete();
      await retry;
      expect(reopened, 1);
      expect((gate.current as GateCellar).setupFailed, isFalse);
      verify(() => watcher.start('user-a')).called(2);
    });

    test('a rules rejection at first, then access restored: "Riprova" opens '
        'the cellar and reopens the listeners', () async {
      when(() => auth.currentUser).thenReturn(userA);
      when(() => cellars.isCached('user-a')).thenAnswer((_) async => false);
      stubEnsure(
        () async => throw CellarSetupException(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
      );
      await gate.start();
      expect((gate.current as GateCellar).setupFailed, isTrue);

      stubEnsure(() async {});
      await gate.retryCellar();

      expect((gate.current as GateCellar).setupFailed, isFalse);
      expect(reopened, 1);
    });

    test('a failed retry keeps the error and reopens nothing', () async {
      when(() => auth.currentUser).thenReturn(userA);
      await gate.start();

      stubEnsure(() async => throw CellarSetupException(StateError('denied')));
      await gate.retryCellar();

      expect((gate.current as GateCellar).setupFailed, isTrue);
      expect(reopened, 0);
      expect(sink.reasons, contains('CellarSetupFailed'));
    });

    test('an uncached cellar that fails, then fails again on "Riprova": the '
        'error stays, no listener is reopened, a later success reopens '
        'them once', () async {
      when(() => auth.currentUser).thenReturn(userA);
      when(() => cellars.isCached('user-a')).thenAnswer((_) async => false);
      stubEnsure(() async => throw CellarSetupException(StateError('offline')));
      await gate.start();
      expect((gate.current as GateCellar).setupFailed, isTrue);

      final ensure = Completer<void>();
      stubEnsure(() => ensure.future);
      final retry = gate.retryCellar();
      await pumpEventQueue();
      expect(gate.current, isA<GateEnsureCellar>());
      ensure.completeError(CellarSetupException(StateError('offline')));
      await retry;

      expect((gate.current as GateCellar).setupFailed, isTrue);
      expect(reopened, 0);
      expect(
        sink.reasons.where((reason) => reason == 'CellarSetupFailed'),
        hasLength(2),
      );

      stubEnsure(() async {});
      await gate.retryCellar();
      expect((gate.current as GateCellar).setupFailed, isFalse);
      expect(reopened, 1);
    });

    test('the first sign-in without a cached cellar opens the cellar after '
        'the check and reopens nothing (no listener existed)', () async {
      when(() => auth.currentUser).thenReturn(userA);
      when(() => cellars.isCached('user-a')).thenAnswer((_) async => false);
      final ensure = Completer<void>();
      stubEnsure(() => ensure.future);

      final start = gate.start();
      await pumpEventQueue();
      expect(gate.current, isA<GateEnsureCellar>());
      verifyNever(() => watcher.start(any()));

      ensure.complete();
      await start;
      expect((gate.current as GateCellar).setupFailed, isFalse);
      expect(reopened, 0);
      verify(() => watcher.start('user-a')).called(1);
    });

    test('outside the cellar it does nothing', () async {
      when(() => auth.currentUser).thenReturn(null);
      await gate.start();

      await gate.retryCellar();

      expect(gate.current, isA<GateSignIn>());
      expect(reopened, 0);
      verifyNever(
        () => cellars.ensurePersonalCellar(
          uid: any(named: 'uid'),
          defaultName: any(named: 'defaultName'),
        ),
      );
    });

    test('a session revoked during the check leaves the sign-in screen and '
        'reopens nothing', () async {
      when(() => auth.currentUser).thenReturn(userA);
      await gate.start();

      final ensure = Completer<void>();
      stubEnsure(() => ensure.future);
      final retry = gate.retryCellar();
      await pumpEventQueue();
      userChanges.add(null);
      await pumpEventQueue();
      ensure.complete();
      await retry;

      expect(gate.current, isA<GateSignIn>());
      expect(reopened, 0);
    });
  });

  Future<void> leavePendingWritesOf(AppUser owner, {int wines = 1}) async {
    for (var i = 0; i < wines; i++) {
      await ledger.beginWrite(
        uid: owner.uid,
        email: owner.email,
        entry: JournalEntry(
          wineId: 'w$i',
          cellarId: owner.uid,
          name: 'Secret wine $i',
          ownerUid: owner.uid,
        ),
      );
    }
    await ledger.setLastUid(owner.uid);
  }

  test('without a session the gate shows sign-in', () async {
    when(() => auth.currentUser).thenReturn(null);

    await gate.start();

    expect(gate.current, isA<GateSignIn>());
    verifyNever(() => cellars.isCached(any()));
  });

  test(
    'a saved session of the same user opens the cellar, checked at start',
    () async {
      when(() => auth.currentUser).thenReturn(userA);
      await leavePendingWritesOf(userA);

      await gate.start();

      expect(gate.current, isA<GateCellar>());
      expect((gate.current as GateCellar).setupFailed, isFalse);
      verify(() => watcher.start('user-a')).called(1);
      verify(() => users.ensureProfile(userA)).called(1);
      verifyNever(() => resets.reset(any()));
    },
  );

  test(
    'another account with queued writes is blocked before any data opens',
    () async {
      await leavePendingWritesOf(userA, wines: 2);
      when(() => auth.currentUser).thenReturn(null);
      when(() => auth.signIn()).thenAnswer((_) async => userB);
      await gate.start();

      await gate.signIn();

      final blocked = gate.current as GateBlocked;
      expect(blocked.ownerEmail, 'user-a@example.com');
      expect(blocked.unsavedCount, 2);
      expect(blocked.resetFailed, isFalse);
      verifyNever(() => cellars.isCached(any()));
      verifyNever(() => watcher.start(any()));
    },
  );

  test(
    'a different uid without queued writes resets, then opens the cellar',
    () async {
      await ledger.setLastUid('user-a');
      when(() => auth.currentUser).thenReturn(userB);
      when(() => resets.reset('user-b'))
          .thenAnswer((_) async => ResetOutcome.completed);

      await gate.start();

      verify(() => resets.reset('user-b')).called(1);
      expect(gate.current, isA<GateCellar>());
    },
  );

  test(
    'confirmed discard resets; a failed reset stays blocked with retry',
    () async {
      await leavePendingWritesOf(userA);
      when(() => auth.currentUser).thenReturn(userB);
      when(() => resets.reset('user-b'))
          .thenAnswer((_) async => ResetOutcome.failed);
      await gate.start();

      await gate.discardAndContinue();

      final blocked = gate.current as GateBlocked;
      expect(blocked.resetFailed, isTrue);
      expect(blocked.ownerEmail, 'user-a@example.com');

      when(() => resets.reset('user-b'))
          .thenAnswer((_) async => ResetOutcome.restartRequired);
      await gate.discardAndContinue();
      expect(gate.current, isA<GateRestartRequired>());
    },
  );

  group('u7-sharing NFR6.4: the chosen cellar is forgotten', () {
    late List<String> calls;
    late AccountGate sharingGate;

    setUp(() {
      calls = [];
      sharingGate = AccountGate(
        auth: auth,
        ledger: ledger,
        resetCoordinator: resets,
        cellars: cellars,
        users: users,
        watcher: watcher,
        bus: bus,
        reporter: recordingReporter(sink),
        defaultCellarName: () => 'La mia cantina',
        reopenCellarListeners: () => reopened++,
        clearSharingChoice: () async => calls.add('clear'),
      );
    });

    tearDown(() => sharingGate.dispose());

    test('before the reset invalidates the listeners', () async {
      await ledger.setLastUid('user-a');
      when(() => auth.currentUser).thenReturn(userB);
      when(() => resets.reset('user-b')).thenAnswer((_) async {
        calls.add('reset');
        return ResetOutcome.completed;
      });

      await sharingGate.start();

      expect(calls, ['clear', 'reset']);
      expect(sharingGate.current, isA<GateCellar>());
    });

    test('at sign-out', () async {
      await leavePendingWritesOf(userA);
      when(() => auth.currentUser).thenReturn(userB);
      await sharingGate.start();

      await sharingGate.signInWithOwner();

      expect(calls, ['clear']);
      expect(sharingGate.current, isA<GateSignIn>());
    });

    test('"Riprova" on the cellar reopens the listeners, the sharing ones '
        'included (reopenCellarListeners)', () async {
      when(() => auth.currentUser).thenReturn(userA);
      await sharingGate.start();

      await sharingGate.retryCellar();

      expect(reopened, 1);
      expect(calls, isEmpty, reason: 'a retry keeps the choice');
    });
  });

  test('"Sign in with <email>" signs out and returns to sign-in', () async {
    await leavePendingWritesOf(userA);
    when(() => auth.currentUser).thenReturn(userB);
    await gate.start();

    await gate.signInWithOwner();

    verify(() => auth.signOut()).called(1);
    expect(gate.current, isA<GateSignIn>());
    expect((await ledger.read()).owner!.uid, 'user-a', reason: 'ledger kept');
  });

  test(
    'a session revoked by the cloud goes to sign-in, ledger untouched',
    () async {
      when(() => auth.currentUser).thenReturn(userA);
      await leavePendingWritesOf(userA);
      await gate.start();

      userChanges.add(null);
      await pumpEventQueue();

      final signIn = gate.current as GateSignIn;
      expect(signIn.notice, SignInNotice.sessionExpired);
      verify(() => watcher.stop()).called(1);
      expect((await ledger.read()).openEntriesOf('user-a'), hasLength(1));
    },
  );

  test('an unauthenticated write signs out with the expired notice', () async {
    when(() => auth.currentUser).thenReturn(userA);
    await gate.start();

    bus.publish(const SessionExpired());
    await pumpEventQueue();

    verify(() => auth.signOut()).called(1);
    expect((gate.current as GateSignIn).notice, SignInNotice.sessionExpired);
  });

  test('sign-in failure shows the notice; a cancel is not reported', () async {
    when(() => auth.currentUser).thenReturn(null);
    await gate.start();

    when(() => auth.signIn())
        .thenThrow(const SignInException(SignInFailureKind.cancelled));
    await gate.signIn();
    expect((gate.current as GateSignIn).notice, SignInNotice.failed);
    expect(sink.reasons, isEmpty);

    when(() => auth.signIn())
        .thenThrow(const SignInException(SignInFailureKind.network));
    await gate.signIn();
    expect(sink.reasons, ['SignInFailed']);
  });

  test(
    'an uncached cellar that cannot be created shows the error and retry',
    () async {
      when(() => auth.currentUser).thenReturn(userA);
      when(() => cellars.isCached('user-a')).thenAnswer((_) async => false);
      when(
        () => cellars.ensurePersonalCellar(
          uid: 'user-a',
          defaultName: 'La mia cantina',
        ),
      ).thenThrow(CellarSetupException(StateError('offline')));

      await gate.start();
      expect((gate.current as GateCellar).setupFailed, isTrue);
      expect(sink.reasons, contains('CellarSetupFailed'));

      when(
        () => cellars.ensurePersonalCellar(
          uid: 'user-a',
          defaultName: 'La mia cantina',
        ),
      ).thenAnswer((_) async {});
      await gate.retryCellar();
      expect((gate.current as GateCellar).setupFailed, isFalse);
    },
  );

  test('the first sign-in on a phone records lastUid; profile errors do not '
      'block', () async {
    when(() => auth.currentUser).thenReturn(userA);
    when(() => users.ensureProfile(any())).thenThrow(StateError('offline'));

    await gate.start();
    await pumpEventQueue();

    expect((await ledger.read()).lastUid, 'user-a');
    expect(gate.current, isA<GateCellar>());
    expect(sink.reasons, contains('ProfileSetupFailed'));
  });

  test('an unreadable ledger blocks with retry', () async {
    final store = InMemoryKeyValueStore()..failReads = Exception('io');
    final brokenLedger = LocalLedger(
      store: store,
      reporter: recordingReporter(sink),
    );
    final brokenGate = AccountGate(
      auth: auth,
      ledger: brokenLedger,
      resetCoordinator: resets,
      cellars: cellars,
      users: users,
      watcher: watcher,
      bus: bus,
      reporter: recordingReporter(sink),
      defaultCellarName: () => 'La mia cantina',
      reopenCellarListeners: () => reopened++,
    );
    when(() => auth.currentUser).thenReturn(userA);

    await brokenGate.start();
    expect(brokenGate.current, isA<GateCheckFailed>());

    store.failReads = null;
    await brokenGate.retryCheck();
    expect(brokenGate.current, isA<GateCellar>());
    brokenGate.dispose();
  });
}
