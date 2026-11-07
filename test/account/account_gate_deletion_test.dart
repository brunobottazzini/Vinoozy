// AccountGate with the u8-account deletion (BR1.8, BR1.13, NFR4.6, NFR6.2):
// the check after _admit and before ensureProfile, the new states
// GateDeleting and GateDeleted, the profile actions.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/account_gate.dart';
import 'package:vinoozy/account/auth_service.dart';
import 'package:vinoozy/account/deletion/deletion_plan.dart';
import 'package:vinoozy/account/reset_coordinator.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../helpers/fakes.dart';
import '../helpers/service_mocks.dart';
import 'account_harness.dart';

void main() {
  late DeletionHarness h;
  late FakeNetworkStatus network;
  late LocalLedger ledger;
  late MockCellarRepository cellars;
  late MockUserRepository users;
  late MockSyncWatcher watcher;
  late MockResetCoordinator resets;
  late RecordingErrorSink gateSink;
  late int onboardingMarks;
  late AccountGate gate;

  setUpAll(() => registerFallbackValue(mario));

  AccountGate buildGate() => AccountGate(
    auth: h.auth,
    ledger: ledger,
    resetCoordinator: resets,
    cellars: cellars,
    users: users,
    watcher: watcher,
    bus: SyncErrorBus(),
    reporter: recordingReporter(gateSink),
    defaultCellarName: () => 'La mia cantina',
    reopenCellarListeners: () {},
    deletion: h.runner,
    network: network,
    markOnboardingSeen: () async => onboardingMarks++,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    h = DeletionHarness(backend: FakeDeletionBackend(drinks: 3, wines: 2));
    network = FakeNetworkStatus();
    ledger = LocalLedger(
      store: InMemoryKeyValueStore(),
      reporter: recordingReporter(RecordingErrorSink()),
    );
    cellars = MockCellarRepository();
    users = MockUserRepository();
    watcher = MockSyncWatcher();
    resets = MockResetCoordinator();
    gateSink = RecordingErrorSink();
    onboardingMarks = 0;
    when(() => cellars.isCached(any())).thenAnswer((_) async => true);
    when(
      () => cellars.ensurePersonalCellar(
        uid: any(named: 'uid'),
        defaultName: any(named: 'defaultName'),
      ),
    ).thenAnswer((_) async {});
    when(() => users.ensureProfile(any())).thenAnswer((_) async {});
    when(() => users.isDeletionStarted(any())).thenAnswer((_) async => false);
    when(() => watcher.start(any())).thenAnswer((_) async {});
    when(() => watcher.trigger()).thenAnswer((_) async {});
    gate = buildGate();
  });

  tearDown(() => h.auth.changes.close());

  Future<void> settle() => pumpEventQueue(times: 50);

  group('resume check (BR1.8, NFR6.2)', () {
    test(
      'BR1.8 a missing profile without any signal opens the app normally',
      () async {
        await gate.start();

        expect(gate.current, isA<GateCellar>());
        verify(() => users.ensureProfile(mario)).called(1);
        expect(onboardingMarks, 1, reason: 'BR1.1 a saved session skips it');
      },
    );

    test('BR1.8 the local signal, offline, shows the deletion and never '
        'recreates profile or cellar', () async {
      await h.signal.write(mario.uid, DeletionStep.deleteWinesAndRecords);
      network.online = false;

      await gate.start();

      final state = gate.current as GateDeleting;
      expect(state.step, DeletionStep.deleteWinesAndRecords);
      expect(state.notice, DeletionNotice.offline);
      expect(state.needsReauth, isTrue);
      verifyNever(() => users.ensureProfile(any()));
      verifyNever(() => users.isDeletionStarted(any()));
      verifyNever(
        () => cellars.ensurePersonalCellar(
          uid: any(named: 'uid'),
          defaultName: any(named: 'defaultName'),
        ),
      );
      verifyNever(() => watcher.start(any()));

      await gate.resumeDeletion();
      expect((gate.current as GateDeleting).notice, DeletionNotice.offline);
      expect(h.auth.reauthCount, 0);
    });

    test('BR1.8 deletionStartedAt seen from another phone resumes at step 1 '
        'after a new Google sign-in (NFR4.6)', () async {
      when(() => users.isDeletionStarted(mario.uid))
          .thenAnswer((_) async => true);
      await gate.start();
      expect((gate.current as GateDeleting).step, DeletionStep.markStarted);

      await gate.resumeDeletion();
      await settle();

      expect(h.auth.reauthCount, 1);
      expect(gate.current, isA<GateDeleted>());
      expect(h.backend.isEmpty, isTrue);
      expect(
        h.device.log,
        isNot(contains('waitForPendingWrites')),
        reason: 'step 0 belongs to the phone that started the deletion',
      );
      verifyNever(() => users.ensureProfile(any()));
    });

    test('BR1.8 an unreadable deletionStartedAt without a local signal opens '
        'the app normally', () async {
      when(() => users.isDeletionStarted(any()))
          .thenThrow(StateError('offline, no cache'));
      await gate.start();
      expect(gate.current, isA<GateCellar>());
    });

    test(
      'NFR4.6 resuming with another Google account deletes nothing',
      () async {
        await h.signal.write(mario.uid, DeletionStep.markStarted);
        h.auth.reauthResult = ReauthResult.differentAccount;
        await gate.start();

        await gate.resumeDeletion();

        final state = gate.current as GateDeleting;
        expect(state.notice, DeletionNotice.sameAccountRequired);
        expect(state.running, isFalse);
        expect(h.backend.log, isEmpty);
      },
    );

    test(
      'BR1.8 a signal at step 7 finishes the phone clean-up at once',
      () async {
        await h.signal.write(mario.uid, DeletionStep.cleanUpPhone);
        await gate.start();
        await settle();
        expect(gate.current, isA<GateDeleted>());
        expect(h.auth.reauthCount, 0);
        expect(await h.signal.read(mario.uid), isNull);
      },
    );
  });

  group('deleteAccount (BR1.6, BR1.7, BR1.13)', () {
    test('BR1.13 the whole deletion ends on "Account deleted", not on '
        '"Session expired"', () async {
      await gate.start();
      final states = <GateState>[];
      gate.state.addListener(() => states.add(gate.current));

      expect(await gate.deleteAccount(), ReauthResult.confirmed);
      await settle();

      expect(states.first, isA<GateDeleting>());
      expect(gate.current, isA<GateDeleted>());
      expect(h.auth.userDeleted, isTrue);
      expect(
        states.whereType<GateSignIn>(),
        isEmpty,
        reason: 'the user going away after deleteUser is not a revocation',
      );
      expect(
        states.whereType<GateDeleting>().map((s) => s.deletedDocuments).last,
        5,
      );
    });

    test(
      'BR1.6 a cancelled or different Google sign-in changes nothing',
      () async {
        await gate.start();
        h.auth.reauthResult = ReauthResult.cancelled;
        expect(await gate.deleteAccount(), ReauthResult.cancelled);
        h.auth.reauthResult = ReauthResult.differentAccount;
        expect(await gate.deleteAccount(), ReauthResult.differentAccount);
        expect(gate.current, isA<GateCellar>());
        expect(h.device.log, isEmpty);
        expect(gateSink.reasons, isEmpty);
      },
    );

    test(
      'NFR8.2 a failed sign-in is reported as account_reauth_failed',
      () async {
        await gate.start();
        h.auth.reauthResult = ReauthResult.failed;
        expect(await gate.deleteAccount(), ReauthResult.failed);
        expect(gateSink.reasons, ['account_reauth_failed']);
      },
    );

    test('without a session nothing starts', () async {
      h.auth.currentUser = null;
      await gate.start();
      expect(await gate.deleteAccount(), ReauthResult.failed);
    });

    test('BR1.13 unsaved writes at step 0: "Try again" or "Cancel" reopens '
        'the app', () async {
      await gate.start();
      h.device.pendingWrites = () => Completer<void>().future;
      await gate.deleteAccount();
      await settle();

      final stopped = gate.current as GateDeleting;
      expect(stopped.notice, DeletionNotice.pendingWrites);
      expect(stopped.canCancel, isTrue);

      await gate.cancelDeletion();
      expect(gate.current, isA<GateCellar>());
      verify(() => watcher.start(mario.uid)).called(2);
    });

    test('NFR6.4 a failed step shows "Try again", which goes on without a '
        'new sign-in', () async {
      await gate.start();
      h.backend.failOnce['deleteCellar'] = StateError('rules');
      await gate.deleteAccount();
      await settle();

      final stopped = gate.current as GateDeleting;
      expect(stopped.step, DeletionStep.deleteCellar);
      expect(stopped.notice, DeletionNotice.failed);
      expect(stopped.canCancel, isFalse);

      await gate.cancelDeletion();
      expect(gate.current, same(stopped), reason: 'past step 0: no cancel');

      await gate.resumeDeletion();
      await settle();
      expect(gate.current, isA<GateDeleted>());
      expect(h.auth.reauthCount, 1);
    });

    test('NFR4.6 requires-recent-login asks for the Google sign-in and '
        'repeats step 6', () async {
      await gate.start();
      h.auth.deleteUserErrors.add(
        const DeleteUserException(DeleteUserFailure.requiresRecentLogin),
      );
      await gate.deleteAccount();
      await settle();

      final stopped = gate.current as GateDeleting;
      expect(stopped.step, DeletionStep.deleteProfileAndUser);
      expect(stopped.needsReauth, isTrue);

      await gate.resumeDeletion();
      await settle();
      expect(h.auth.reauthCount, 2);
      expect(gate.current, isA<GateDeleted>());
    });

    test('review R-02: after a failed deleteUser a revoked session leads to '
        '"Session expired" again', () async {
      await gate.start();
      h.auth.deleteUserErrors.add(
        const DeleteUserException(DeleteUserFailure.failed),
      );
      await gate.deleteAccount();
      await settle();
      expect(gate.current, isA<GateDeleting>());

      h.auth.changes.add(null);
      await settle();

      final state = gate.current as GateSignIn;
      expect(state.notice, SignInNotice.sessionExpired);
    });

    test(
      'BR1.8 review R-03: a deletion interrupted at step 0 and resumed '
      'offline can be cancelled; the app opens and the signal is gone',
      () async {
        await h.signal.write(mario.uid, DeletionStep.preparePhone);
        network.online = false;
        await gate.start();

        final resumed = gate.current as GateDeleting;
        expect(resumed.step, DeletionStep.preparePhone);
        expect(resumed.notice, DeletionNotice.offline);
        expect(resumed.canCancel, isTrue);

        await gate.cancelDeletion();

        expect(gate.current, isA<GateCellar>());
        expect(await h.signal.read(mario.uid), isNull);
        expect(h.backend.log, isEmpty);
        verify(() => users.ensureProfile(mario)).called(1);
      },
    );

    test(
      'review R-03: past step 0 the signal is never dropped by a cancel',
      () async {
        await h.signal.write(mario.uid, DeletionStep.deleteCellar);
        await expectLater(
          h.runner.abandonBeforeStart(mario.uid),
          throwsStateError,
        );
        expect(await h.signal.read(mario.uid), DeletionStep.deleteCellar.index);
      },
    );

    test('plan B of the reset ends on the restart screen', () async {
      await gate.start();
      h.device.resetOutcome = ResetOutcome.restartRequired;
      await gate.deleteAccount();
      await settle();
      expect(gate.current, isA<GateRestartRequired>());
    });
  });

  group('start without a session', () {
    test('BR1.8 a clean-up left after deleteUser is finished: "Account '
        'deleted"', () async {
      h.auth.currentUser = null;
      await h.signal.write(mario.uid, DeletionStep.cleanUpPhone);
      await gate.start();
      expect(gate.current, isA<GateDeleted>());
      expect(await h.signal.read(mario.uid), isNull);
      expect(onboardingMarks, 0);
    });

    test('without pending clean-up it is the usual sign-in', () async {
      h.auth.currentUser = null;
      await gate.start();
      expect(gate.current, isA<GateSignIn>());
    });
  });

  group('profile actions (BR1.3, BR1.4)', () {
    test(
      'BR1.4 the pending changes come from the ledger of the account',
      () async {
        await gate.start();
        expect(await gate.pendingChanges(), 0);
        await ledger.beginWrite(
          uid: mario.uid,
          email: mario.email,
          entry: JournalEntry(
            wineId: 'w1',
            cellarId: mario.uid,
            name: 'Barolo',
            ownerUid: mario.uid,
          ),
        );
        expect(await gate.pendingChanges(), 1);
        expect(await gate.syncNow(), 1);
        verify(() => watcher.trigger()).called(1);
      },
    );

    test('BR1.3 sign-out goes back to sign-in and keeps the ledger', () async {
      await gate.start();
      await gate.signOut();
      expect(gate.current, isA<GateSignIn>());
      expect(h.auth.signOutCount, 1);
    });

    test('NFR8.2 a failed sign-out is reported as account_signout_failed '
        'without the message', () async {
      await gate.start();
      h.auth.signOutError = StateError('cannot reach ${mario.email}');
      await gate.signOut();
      expect(gateSink.reasons, ['account_signout_failed']);
      expect(
        gateSink.recorded.single.error.toString(),
        isNot(contains('mario')),
      );
    });

    test('without a session there is nothing pending', () async {
      h.auth.currentUser = null;
      await gate.start();
      expect(await gate.pendingChanges(), 0);
    });
  });
}
