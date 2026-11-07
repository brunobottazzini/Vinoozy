import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/account_operation_error.dart';
import 'package:vinoozy/account/deletion/deletion_plan.dart';
import 'package:vinoozy/account/deletion/deletion_signal.dart';
import 'package:vinoozy/account/onboarding_flag.dart';

void main() {
  group('DeletionPlan', () {
    test('BR1.7 the steps run in the order of the functional spec', () {
      expect(DeletionPlan.steps, [
        DeletionStep.preparePhone,
        DeletionStep.markStarted,
        DeletionStep.leaveOtherCellars,
        DeletionStep.closeOwnInvitations,
        DeletionStep.deleteWinesAndRecords,
        DeletionStep.deleteCellar,
        DeletionStep.deleteProfileAndUser,
        DeletionStep.cleanUpPhone,
      ]);
      expect(
        [for (final step in DeletionPlan.steps) step.index],
        [0, 1, 2, 3, 4, 5, 6, 7],
      );
    });

    test('BR1.7 pages and batches of 400, wait of 30 s (NFR1.3)', () {
      expect(DeletionPlan.pageSize, 400);
      expect(DeletionPlan.pendingWritesTimeout, const Duration(seconds: 30));
    });

    test('BR1.11 only steps 0 and 7 are phone-only, the web page runs 1-6', () {
      expect(
        [
          for (final step in DeletionPlan.steps)
            if (!step.isPhoneOnly) step.index,
        ],
        [1, 2, 3, 4, 5, 6],
      );
    });

    test('BR1.8 the local signal decides where the deletion resumes', () {
      expect(
        DeletionPlan.resumeFrom(localStep: 4, startedInCloud: true),
        DeletionStep.deleteWinesAndRecords,
      );
      expect(
        DeletionPlan.resumeFrom(localStep: 0, startedInCloud: false),
        DeletionStep.preparePhone,
      );
    });

    test('BR1.8 only deletionStartedAt resumes at step 1', () {
      expect(
        DeletionPlan.resumeFrom(localStep: null, startedInCloud: true),
        DeletionStep.markStarted,
      );
    });

    test('BR1.8 without an explicit signal nothing resumes (NFR6.2)', () {
      expect(
        DeletionPlan.resumeFrom(localStep: null, startedInCloud: false),
        isNull,
      );
    });

    test('an unknown stored step resumes safely at step 1', () {
      expect(
        DeletionPlan.resumeFrom(localStep: 42, startedInCloud: false),
        DeletionStep.markStarted,
      );
      expect(DeletionStep.fromIndex(-1), isNull);
      expect(DeletionStep.fromIndex(8), isNull);
    });

    test('remaining lists the steps from the given one', () {
      expect(DeletionPlan.remaining(DeletionStep.deleteCellar), [
        DeletionStep.deleteCellar,
        DeletionStep.deleteProfileAndUser,
        DeletionStep.cleanUpPhone,
      ]);
    });
  });

  group('DeletionSignal (BR1.8, NFR8.3)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('BR1.8 the signal is written, read, advanced and removed', () async {
      final signal = DeletionSignal(SharedPreferences.getInstance);
      expect(await signal.read('user-a'), isNull);

      await signal.write('user-a', DeletionStep.preparePhone);
      expect(await signal.read('user-a'), 0);
      await signal.write('user-a', DeletionStep.deleteCellar);
      expect(await signal.read('user-a'), 5);
      expect(
        (await SharedPreferences.getInstance()).getInt(
          'account.deletion.user-a',
        ),
        5,
      );

      await signal.clear('user-a');
      expect(await signal.read('user-a'), isNull);
    });

    test('signals are per account', () async {
      final signal = DeletionSignal(SharedPreferences.getInstance);
      await signal.write('user-a', DeletionStep.markStarted);
      expect(await signal.read('user-b'), isNull);
    });

    test('pendingFrom lists only the accounts at or after the step', () async {
      SharedPreferences.setMockInitialValues({
        'account.deletion.user-a': 7,
        'account.deletion.user-b': 3,
        'account.deletion.user-c': 6,
        'onboarding.seen': true,
        'other.key': 9,
      });
      final signal = DeletionSignal(SharedPreferences.getInstance);
      expect(await signal.pendingFrom(DeletionStep.deleteProfileAndUser), {
        'user-a': 7,
        'user-c': 6,
      });
    });

    test('an empty store has no pending deletion', () async {
      final signal = DeletionSignal(SharedPreferences.getInstance);
      expect(await signal.pendingFrom(DeletionStep.preparePhone), isEmpty);
    });
  });

  group('OnboardingFlag (BR1.1)', () {
    test('BR1.1 the presentation is not seen on a new phone', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await OnboardingFlag(SharedPreferences.getInstance).read(), false);
    });

    test('BR1.1 markSeen persists onboarding.seen = true', () async {
      SharedPreferences.setMockInitialValues({});
      final flag = OnboardingFlag(SharedPreferences.getInstance);
      expect(await flag.markSeen(), isTrue);
      expect(await flag.read(), isTrue);
      expect(
        (await SharedPreferences.getInstance()).getBool('onboarding.seen'),
        isTrue,
      );
    });

    test(
      'an unreadable store counts as seen and a failed write is false',
      () async {
        final flag = OnboardingFlag(() async => throw StateError('no store'));
        expect(await flag.read(), isTrue);
        expect(await flag.markSeen(), isFalse);
      },
    );
  });

  group('AccountOperationError (NFR8.2)', () {
    const marker = 'mario.rossi@example.com users/UID0123456789abcdefghijk';

    test('toString carries reason, step and type, never the message', () {
      final error = AccountOperationError(
        AccountErrorReason.deleteFailed,
        step: 4,
        cause: StateError(marker),
      );
      expect(
        error.toString(),
        'AccountOperationError(account_delete_failed, step 4, StateError)',
      );
      expect(error.toString(), isNot(contains('mario')));
      expect(error.toString(), isNot(contains('UID0123')));
    });

    test('without a step or a cause the text stays fixed', () {
      expect(
        AccountOperationError(AccountErrorReason.signOutFailed).toString(),
        'AccountOperationError(account_signout_failed, none)',
      );
    });

    test('generic type arguments are dropped from the cause type', () {
      final error = AccountOperationError(
        AccountErrorReason.reauthFailed,
        cause: <String>[marker],
      );
      expect(error.causeType, isNot(contains('<')));
      expect(error.toString(), isNot(contains('mario')));
    });

    test('only the three fixed reasons are accepted', () {
      expect(
        () => AccountOperationError('account_failed_for mario@example.com'),
        throwsArgumentError,
      );
    });
  });
}
