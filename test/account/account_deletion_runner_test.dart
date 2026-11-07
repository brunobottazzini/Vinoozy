import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/auth_service.dart';
import 'package:vinoozy/account/deletion/account_deletion_runner.dart';
import 'package:vinoozy/account/deletion/deletion_plan.dart';
import 'package:vinoozy/account/reset_coordinator.dart';
import 'package:vinoozy/sharing/domain/membership.dart';

import 'account_harness.dart';

FirebaseException rulesError(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code, message: code);

/// Mario's cellar of the sequence test (unit-test-instructions.md, "Dati di
/// test"): 2 invitations given, one pending and one closed invitation in
/// other people's cellars, 50 wines and 100 drinks.
FakeDeletionBackend sequenceCloud() {
  final backend = FakeDeletionBackend(drinks: 100, wines: 50);
  backend.given
    ..add(
      FakeInvitation(
        'uid-mario-0001',
        'giulia@example.com',
        MemberStatus.active,
      ),
    )
    ..add(
      FakeInvitation(
        'uid-mario-0001',
        'luca@example.com',
        MemberStatus.invited,
      ),
    );
  backend.received
    ..add(
      FakeInvitation('cellar-anna', 'mario@example.com', MemberStatus.invited),
    )
    ..add(
      FakeInvitation('cellar-paolo', 'mario@example.com', MemberStatus.revoked),
    )
    ..add(
      FakeInvitation('cellar-zoe', 'mario@example.com', MemberStatus.active),
    );
  return backend;
}

/// The operation each cloud step starts with: failing it interrupts the run
/// right at that step.
const Map<DeletionStep, String> firstOperation = {
  DeletionStep.markStarted: 'markStarted',
  DeletionStep.leaveOtherCellars: 'invitationsReceived',
  DeletionStep.closeOwnInvitations: 'invitationsGiven',
  DeletionStep.deleteWinesAndRecords: 'deletePage',
  DeletionStep.deleteCellar: 'deleteCellar',
  DeletionStep.deleteProfileAndUser: 'deleteProfile',
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AccountDeletionRunner', () {
    test('BR1.7 the whole sequence runs in order and leaves the cloud empty '
        '(NFR4.4)', () async {
      final h = DeletionHarness(backend: sequenceCloud());
      final events = <String>[];

      final result = await h.runner.run(
        mario,
        onProgress: (p) => events.add(p.step.name),
        beforeDeleteUser: () => events.add('beforeDeleteUser'),
      );

      expect(result, isA<DeletionCompleted>());
      expect(h.backend.isEmpty, isTrue);
      expect(h.auth.userDeleted, isTrue);
      expect(h.device.log, [
        'stopSync',
        'waitForPendingWrites',
        'clearLedger',
        'resetPhone',
        'clearLabelFiles',
      ]);
      expect(h.deadline.limits, [const Duration(seconds: 30)]);
      // The order of BR1.7: profile flag, other cellars, own invitations,
      // drinks before wines, cellar, profile.
      final ops = [
        for (final entry in h.backend.log)
          if (!entry.startsWith('cellarExists')) entry,
      ];
      expect(ops.first, 'markStarted');
      expect(
        ops.indexOf('invitationsReceived'),
        lessThan(ops.indexOf('invitationsGiven')),
      );
      expect(
        ops.indexOf('deletePage:drinkingRecords'),
        lessThan(ops.indexOf('deletePage:wines')),
      );
      expect(ops.sublist(ops.length - 2), ['deleteCellar', 'deleteProfile']);
      expect(events.indexOf('beforeDeleteUser'), greaterThan(-1));
      expect(events.last, 'cleanUpPhone');
      expect(await h.signal.read(mario.uid), isNull);
    });

    test('BR1.9 a pending invitation is activated, then left, then deleted; '
        'a closed one is only deleted', () async {
      final h = DeletionHarness(backend: sequenceCloud());
      await h.runner.run(mario);

      final log = h.backend.log;
      expect(
        log,
        containsAllInOrder([
          'activate:cellar-anna',
          'leave:cellar-anna',
          'deleteInvitation:cellar-anna/mario@example.com',
        ]),
      );
      expect(log, isNot(contains('leave:cellar-paolo')));
      expect(log, contains('deleteInvitation:cellar-paolo/mario@example.com'));
      expect(
        log,
        containsAllInOrder([
          'leave:cellar-zoe',
          'deleteInvitation:cellar-zoe/mario@example.com',
        ]),
      );
      expect(log.where((e) => e.startsWith('activate')), hasLength(1));
    });

    test(
      'BR1.7 own invitations: every open one revoked, then all deleted',
      () async {
        final backend = FakeDeletionBackend()
          ..given.addAll([
            FakeInvitation(
              mario.uid,
              'giulia@example.com',
              MemberStatus.active,
            ),
            FakeInvitation(mario.uid, 'old@example.com', MemberStatus.revoked),
          ]);
        final h = DeletionHarness(backend: backend);
        await h.runner.run(mario);

        expect(
          h.backend.log,
          containsAllInOrder([
            'revoke:giulia@example.com',
            'deleteInvitation:${mario.uid}/giulia@example.com',
          ]),
        );
        expect(h.backend.log, isNot(contains('revoke:old@example.com')));
        expect(h.backend.given, isEmpty);
      },
    );

    test(
      'BR1.7 step 4 deletes in confirmed batches of 400 until both '
      'collections are empty, reporting the count (NFR1.2, NFR5.1)',
      () async {
        final h = DeletionHarness(
          backend: FakeDeletionBackend(drinks: 2000, wines: 1500),
        );
        final counts = <int>[];
        await h.runner.run(
          mario,
          from: DeletionStep.deleteWinesAndRecords,
          onProgress: (p) {
            if (p.deletedDocuments > 0) counts.add(p.deletedDocuments);
          },
        );

        expect(h.backend.drinkCount, 0);
        expect(h.backend.wineCount, 0);
        // 5 pages of drinks + 4 of wines, one batch each.
        expect(counts, hasLength(9));
        expect(counts.last, 3500);
        expect(counts, orderedEquals([...counts]..sort()));
      },
    );

    test('BR1.8 a missing cellar skips steps 3-5 (a new account)', () async {
      final h = DeletionHarness(
        backend: FakeDeletionBackend(cellarExistsValue: false),
      );
      final result = await h.runner.run(mario);

      expect(result, isA<DeletionCompleted>());
      expect(h.backend.log, isNot(contains('invitationsGiven')));
      expect(h.backend.log.where((e) => e.startsWith('deletePage')), isEmpty);
    });

    group('NFR6.1 interruption after every step and resume', () {
      for (final entry in firstOperation.entries) {
        test('BR1.8 stopped at step ${entry.key.index}, resumed from the '
            'signal, the cloud ends empty', () async {
          final h = DeletionHarness(backend: sequenceCloud());
          h.backend.failOnce[entry.value] = rulesError('unavailable');

          final first = await h.runner.run(mario);

          expect(first, isA<DeletionStopped>());
          first as DeletionStopped;
          expect(first.step, entry.key);
          expect(first.failure, DeletionFailure.network);
          expect(await h.signal.read(mario.uid), entry.key.index);
          expect(h.auth.userDeleted, isFalse);

          final resumed = await h.runner.run(
            mario,
            from: DeletionPlan.resumeFrom(
              localStep: await h.signal.read(mario.uid),
              startedInCloud: true,
            )!,
          );
          expect(resumed, isA<DeletionCompleted>());
          expect(h.backend.isEmpty, isTrue);
          expect(await h.signal.read(mario.uid), isNull);
        });
      }

      test(
        'every step repeated after it already succeeded does not fail',
        () async {
          final h = DeletionHarness(backend: sequenceCloud());
          await h.runner.run(mario, beforeDeleteUser: () {});
          h.auth.userDeleted = false;
          // The same run again from step 1: nothing left, nothing fails.
          final again = await h.runner.run(
            mario,
            from: DeletionStep.markStarted,
          );
          expect(again, isA<DeletionCompleted>());
        },
      );
    });

    group('step 0 (BR1.13, NFR1.3)', () {
      test('BR1.13 queued writes that do not arrive in 30 s stop the deletion '
          'before it starts', () async {
        final h = DeletionHarness(backend: sequenceCloud());
        h.device.pendingWrites = () => Completer<void>().future;

        final result = await h.runner.run(mario);

        expect(result, isA<DeletionStopped>());
        result as DeletionStopped;
        expect(result.step, DeletionStep.preparePhone);
        expect(result.failure, DeletionFailure.pendingWrites);
        expect(h.deadline.limits, [DeletionPlan.pendingWritesTimeout]);
        expect(h.device.log, isNot(contains('clearLedger')));
        expect(h.backend.log, isEmpty);
        expect(
          await h.signal.read(mario.uid),
          isNull,
          reason: 'the deletion did not start: no signal is left',
        );
      });

      test('BR1.13 a failing queued write stops it the same way', () async {
        final h = DeletionHarness();
        h.device.pendingWrites = () async => throw rulesError('aborted');
        final result = await h.runner.run(mario) as DeletionStopped;
        expect(result.failure, DeletionFailure.pendingWrites);
      });

      test('BR1.13 sync stops before the wait and the ledger is cleared '
          'only after it', () async {
        final h = DeletionHarness();
        await h.runner.run(mario);
        expect(h.device.log.take(3), [
          'stopSync',
          'waitForPendingWrites',
          'clearLedger',
        ]);
      });
    });

    group('step 6 and 7', () {
      test('NFR4.6 deleteUser asking for a recent sign-in stops at step 6 '
          'for a new sign-in', () async {
        final h = DeletionHarness();
        h.auth.deleteUserErrors.add(
          const DeleteUserException(DeleteUserFailure.requiresRecentLogin),
        );
        final result = await h.runner.run(mario) as DeletionStopped;

        expect(result.step, DeletionStep.deleteProfileAndUser);
        expect(result.failure, DeletionFailure.reauthRequired);
        expect(await h.signal.read(mario.uid), 6);

        final again = await h.runner.run(mario, from: result.step);
        expect(again, isA<DeletionCompleted>());
        expect(h.auth.deleteUserCount, 2);
        expect(h.auth.userDeleted, isTrue);
      });

      test('another deleteUser error is a network failure', () async {
        final h = DeletionHarness();
        h.auth.deleteUserErrors.add(
          const DeleteUserException(DeleteUserFailure.failed),
        );
        final result = await h.runner.run(mario) as DeletionStopped;
        expect(result.failure, DeletionFailure.network);
      });

      test('NFR8.3 a failed local reset keeps the signal: only step 7 is '
          'repeated', () async {
        final h = DeletionHarness();
        h.device.resetOutcome = ResetOutcome.failed;
        final result = await h.runner.run(mario) as DeletionStopped;

        expect(result.step, DeletionStep.cleanUpPhone);
        expect(await h.signal.read(mario.uid), 7);
        expect(h.device.log, isNot(contains('clearLabelFiles')));
        expect(await h.runner.pendingCleanups(), {mario.uid: 7});

        h.device.resetOutcome = ResetOutcome.completed;
        final finished = await h.runner.finishCleanup(mario.uid);
        expect(finished, isA<DeletionCompleted>());
        expect(h.device.log, contains('clearLabelFiles'));
        expect(await h.signal.read(mario.uid), isNull);
        expect(await h.runner.pendingCleanups(), isEmpty);
      });

      test('finishCleanup reports a reset that fails again', () async {
        final h = DeletionHarness();
        h.device.resetOutcome = ResetOutcome.failed;
        final result = await h.runner.finishCleanup(mario.uid);
        expect(result, isA<DeletionStopped>());
      });

      test('plan B of the reset completes with a restart', () async {
        final h = DeletionHarness();
        h.device.resetOutcome = ResetOutcome.restartRequired;
        final result = await h.runner.run(mario) as DeletionCompleted;
        expect(result.restartRequired, isTrue);
        expect(await h.signal.read(mario.uid), isNull);
      });
    });

    group('errors (NFR8.2)', () {
      test('the rules refusing a step is reported as account_delete_failed '
          'with the step and no personal data', () async {
        final h = DeletionHarness();
        h.backend.failOnce['deleteCellar'] = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message:
              'denied for ${mario.email} at cellars/${mario.uid} '
              '(${mario.displayName})',
        );
        final result = await h.runner.run(mario) as DeletionStopped;

        expect(result.failure, DeletionFailure.rejected);
        expect(h.sink.reasons, ['account_delete_failed']);
        final reported = h.sink.recorded.single.error.toString();
        expect(reported, contains('step 5'));
        for (final marker in [mario.email, mario.uid, 'Mario', 'cellars/']) {
          expect(reported, isNot(contains(marker)));
        }
      });

      test('a timeout is a network failure, anything else a failure', () async {
        final h = DeletionHarness();
        h.backend.failOnce['markStarted'] = TimeoutException('slow');
        expect(
          (await h.runner.run(mario) as DeletionStopped).failure,
          DeletionFailure.network,
        );
        h.backend.failOnce['markStarted'] = StateError('boom');
        expect(
          (await h.runner.run(
            mario,
            from: DeletionStep.markStarted,
          ) as DeletionStopped).failure,
          DeletionFailure.failed,
        );
      });

      test('BR1.8 the signal stays on the failed step', () async {
        final h = DeletionHarness();
        h.backend.failOnce['deleteProfile'] = StateError('x');
        await h.runner.run(mario);
        expect(await h.signal.read(mario.uid), 6);
      });
    });
  });
}
