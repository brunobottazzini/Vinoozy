import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;

import '../../app/error_reporter.dart';
import '../../sharing/domain/membership.dart' show MemberStatus;
import '../account_operation_error.dart';
import '../app_user.dart';
import '../auth_service.dart';
import '../reset_coordinator.dart';
import 'deletion_backend.dart';
import 'deletion_device.dart';
import 'deletion_plan.dart';
import 'deletion_signal.dart';

/// Why a deletion stopped (functional-spec.md, "Errori e casi limite").
enum DeletionFailure {
  /// Step 0: the queued writes did not reach the server within 30 s, or one
  /// failed: the deletion did not start ("Could not save the pending
  /// changes. Try again").
  pendingWrites,

  /// The network or the server did not answer: "Try again".
  network,

  /// The rules refused a step: "Could not complete the deletion. Try again".
  rejected,

  /// Step 6: Firebase wants a recent sign-in before `deleteUser`.
  reauthRequired,

  /// Anything else.
  failed,
}

/// Progress of a running deletion, emitted at every step and after every
/// batch of step 4 (performance-design.md §2).
class DeletionProgress {
  const DeletionProgress(this.step, {this.deletedDocuments = 0});

  final DeletionStep step;

  /// Drinks and wines deleted so far in step 4.
  final int deletedDocuments;
}

/// How [AccountDeletionRunner.run] ended.
sealed class DeletionResult {
  const DeletionResult();
}

/// Every step succeeded and the local signal is gone.
class DeletionCompleted extends DeletionResult {
  const DeletionCompleted({this.restartRequired = false});

  /// Plan B of the local reset: the app must be restarted to clear Firestore.
  final bool restartRequired;
}

/// The deletion stopped at [step]; repeating from there is safe (NFR6.1).
class DeletionStopped extends DeletionResult {
  const DeletionStopped(this.step, this.failure);

  final DeletionStep step;
  final DeletionFailure failure;
}

/// Bounds a future in time; injected so tests use a fake clock and never
/// wait 30 s for real.
typedef Deadline = Future<void> Function(Future<void> work, Duration limit);

Future<void> realDeadline(Future<void> work, Duration limit) =>
    work.timeout(limit);

/// Runs the account deletion one step at a time (logical-components.md:
/// AccountDeletionRunner; BR1.7, BR1.8, BR1.13, NFR6.1).
///
/// It stops at the first error, reports it as `account_delete_failed` with
/// the step only (NFR8.2) and keeps the local signal on the step to repeat.
/// The signal advances after every successful step and is removed only once
/// the phone is clean (step 7).
class AccountDeletionRunner {
  AccountDeletionRunner({
    required this._backend,
    required this._device,
    required this._signal,
    required this._auth,
    required this._reporter,
    this._deadline = realDeadline,
  });

  final DeletionBackend _backend;
  final DeletionDevice _device;
  final DeletionSignal _signal;
  final AuthService _auth;
  final ErrorReporter _reporter;
  final Deadline _deadline;

  /// The local signal of [uid] (BR1.8).
  Future<int?> localStep(String uid) => _signal.read(uid);

  /// "Cancel" at step 0 (review R-03): removes the signal of [uid] when the
  /// deletion has not gone past step 0, i.e. nothing was deleted in the
  /// cloud. Throws [StateError] when it already went further.
  Future<void> abandonBeforeStart(String uid) async {
    final step = await _signal.read(uid);
    if (step != null && step > DeletionStep.preparePhone.index) {
      throw StateError('the deletion already started in the cloud');
    }
    await _signal.clear(uid);
  }

  /// Accounts whose deletion only needs the phone clean-up: the session is
  /// gone after `deleteUser` (BR1.8, "Fine della cancellazione").
  Future<Map<String, int>> pendingCleanups() =>
      _signal.pendingFrom(DeletionStep.deleteProfileAndUser);

  /// Runs the deletion of [user] from [from] to the end.
  ///
  /// [beforeDeleteUser] runs right before `deleteUser`, so the gate shows
  /// "Account deleted" instead of "Session expired" when the user goes away
  /// (BR1.13).
  Future<DeletionResult> run(
    AppUser user, {
    DeletionStep from = DeletionStep.preparePhone,
    void Function(DeletionProgress progress)? onProgress,
    void Function()? beforeDeleteUser,
  }) async {
    for (final step in DeletionPlan.remaining(from)) {
      onProgress?.call(DeletionProgress(step));
      final failure = await _attempt(
        user,
        step,
        () => _execute(user, step, onProgress, beforeDeleteUser),
      );
      if (failure != null) return DeletionStopped(step, failure);
      if (step == DeletionStep.cleanUpPhone) break;
      final saved = await _attempt(
        user,
        step,
        () => _signal.write(user.uid, DeletionStep.values[step.index + 1]),
      );
      if (saved != null) return DeletionStopped(step, saved);
    }
    return DeletionCompleted(restartRequired: _restartRequired);
  }

  /// Step 7 only, for an account whose session is already gone.
  Future<DeletionResult> finishCleanup(String uid) async {
    final failure = await _attempt(null, DeletionStep.cleanUpPhone, () async {
      await _cleanUpPhone(uid);
    });
    return failure == null
        ? DeletionCompleted(restartRequired: _restartRequired)
        : DeletionStopped(DeletionStep.cleanUpPhone, failure);
  }

  bool _restartRequired = false;

  Future<void> _execute(
    AppUser user,
    DeletionStep step,
    void Function(DeletionProgress progress)? onProgress,
    void Function()? beforeDeleteUser,
  ) async {
    switch (step) {
      case DeletionStep.preparePhone:
        await _preparePhone(user.uid);
      case DeletionStep.markStarted:
        await _backend.markStarted(user);
      case DeletionStep.leaveOtherCellars:
        await _leaveOtherCellars(user);
      case DeletionStep.closeOwnInvitations:
        await _closeOwnInvitations(user.uid);
      case DeletionStep.deleteWinesAndRecords:
        await _deleteWinesAndRecords(user.uid, onProgress);
      case DeletionStep.deleteCellar:
        await _backend.deleteCellar(user.uid);
      case DeletionStep.deleteProfileAndUser:
        await _backend.deleteProfile(user.uid);
        beforeDeleteUser?.call();
        await _auth.deleteUser();
      case DeletionStep.cleanUpPhone:
        await _cleanUpPhone(user.uid);
    }
  }

  /// Step 0 (clarifications of the second review): the signal first, then
  /// sync stopped, the queued writes awaited for 30 s at most, and only then
  /// the ledger cleared. If the wait fails the deletion has not started: the
  /// signal is removed again and nothing else changed.
  Future<void> _preparePhone(String uid) async {
    await _signal.write(uid, DeletionStep.preparePhone);
    _device.stopSyncAndListeners();
    try {
      await _deadline(
        _device.waitForPendingWrites(),
        DeletionPlan.pendingWritesTimeout,
      );
    } catch (error) {
      await _signal.clear(uid);
      throw _PendingWritesNotSaved(error);
    }
    await _device.clearLedger(uid);
  }

  /// Step 2 (BR1.9): an `invited` invitation is activated and then left, an
  /// `active` one is left, then every own `members` document is deleted.
  Future<void> _leaveOtherCellars(AppUser user) async {
    for (final invitation in await _backend.invitationsReceived(user)) {
      // The own cellar is never in this list (the rules refuse inviting
      // oneself); step 3 handles it anyway.
      if (invitation.cellarId == user.uid) continue;
      if (invitation.status == MemberStatus.invited) {
        await _backend.activate(invitation.cellarId, user);
      }
      if (invitation.isOpen) await _backend.leave(invitation.cellarId, user);
      await _backend.deleteInvitation(
        invitation.cellarId,
        invitation.memberKey,
      );
    }
  }

  /// Step 3: every open invitation revoked, then every invitation deleted.
  Future<void> _closeOwnInvitations(String uid) async {
    if (!await _backend.cellarExists(uid)) return;
    for (final invitation in await _backend.invitationsGiven(uid)) {
      if (invitation.isOpen) {
        await _backend.revoke(invitation.cellarId, invitation.memberKey);
      }
      await _backend.deleteInvitation(
        invitation.cellarId,
        invitation.memberKey,
      );
    }
  }

  static const String _drinks = 'drinkingRecords';
  static const String _wines = 'wines';

  /// Step 4: drinks then wines, page after page, until both are empty; the
  /// finished wines and the drinks of deleted wines included.
  Future<void> _deleteWinesAndRecords(
    String uid,
    void Function(DeletionProgress progress)? onProgress,
  ) async {
    if (!await _backend.cellarExists(uid)) return;
    var deleted = 0;
    while (true) {
      var round = 0;
      for (final collection in const [_drinks, _wines]) {
        int page;
        do {
          page = await _backend.deletePage(uid, collection);
          round += page;
          deleted += page;
          if (page > 0) {
            onProgress?.call(
              DeletionProgress(
                DeletionStep.deleteWinesAndRecords,
                deletedDocuments: deleted,
              ),
            );
          }
        } while (page > 0);
      }
      if (round == 0) return;
    }
  }

  /// Step 7: local reset, label files, and only then the signal removed.
  Future<void> _cleanUpPhone(String uid) async {
    final outcome = await _device.resetPhone(uid);
    if (outcome == ResetOutcome.failed) throw const _ResetFailed();
    _restartRequired = outcome == ResetOutcome.restartRequired;
    await _device.clearLabelFiles();
    await _signal.clear(uid);
  }

  /// Runs [work]; on error reports `account_delete_failed` with the step and
  /// returns the failure kind.
  Future<DeletionFailure?> _attempt(
    AppUser? user,
    DeletionStep step,
    Future<void> Function() work,
  ) async {
    try {
      await work();
      return null;
    } catch (error, stack) {
      final cause = error is _PendingWritesNotSaved ? error.cause : error;
      await _reporter.report(
        AccountOperationError(
          AccountErrorReason.deleteFailed,
          step: step.index,
          cause: cause,
        ),
        stack,
        reason: AccountErrorReason.deleteFailed,
        sensitive: [?user?.uid, ?user?.email, ?user?.displayName],
      );
      return _classify(error);
    }
  }

  static DeletionFailure _classify(Object error) => switch (error) {
    _PendingWritesNotSaved() => DeletionFailure.pendingWrites,
    DeleteUserException(failure: DeleteUserFailure.requiresRecentLogin) =>
      DeletionFailure.reauthRequired,
    DeleteUserException() => DeletionFailure.network,
    TimeoutException() => DeletionFailure.network,
    FirebaseException(code: 'permission-denied') => DeletionFailure.rejected,
    FirebaseException(
      code: 'unavailable' || 'deadline-exceeded' || 'network-request-failed',
    ) =>
      DeletionFailure.network,
    _ => DeletionFailure.failed,
  };
}

/// Step 0 could not save the queued writes in time.
class _PendingWritesNotSaved implements Exception {
  const _PendingWritesNotSaved(this.cause);

  final Object cause;
}

/// Step 7: the local reset of U1 failed; the signal stays and only step 7 is
/// repeated at the next start.
class _ResetFailed implements Exception {
  const _ResetFailed();
}
