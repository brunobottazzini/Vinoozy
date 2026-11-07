import 'dart:async';

import 'package:flutter/foundation.dart';

import '../app/error_reporter.dart';
import '../cellar/data/cellar_repository.dart';
import '../sync/ledger/local_ledger.dart';
import '../sync/sync_error_bus.dart';
import '../sync/sync_watcher.dart';
import 'account_operation_error.dart';
import 'app_user.dart';
import 'auth_service.dart';
import 'data/user_repository.dart';
import 'deletion/account_deletion_runner.dart';
import 'deletion/deletion_plan.dart';
import 'gate_state.dart';
import 'network_status.dart';
import 'reset_coordinator.dart';

export 'gate_state.dart';

/// Session state and account switching (security-design.md §1, BR1.1-BR1.4,
/// NFR4.9, NFR4.10).
///
/// The ledger is checked after every sign-in and on every start with a saved
/// session, before any Firestore listener exists. A different account is
/// blocked while the previous owner has queued or rejected writes; with no
/// owner, a different account first clears the local data.
class AccountGate {
  AccountGate({
    required this._auth,
    required this._ledger,
    required this._resetCoordinator,
    required this._cellars,
    required this._users,
    required this._watcher,
    required this._bus,
    required this._reporter,
    required this._defaultCellarName,
    required this._reopenCellarListeners,
    this._clearSharingChoice,
    this._deletion,
    this._network,
    this._markOnboardingSeen,
  });

  final AuthService _auth;
  final LocalLedger _ledger;
  final ResetCoordinator _resetCoordinator;
  final CellarRepository _cellars;
  final UserRepository _users;
  final SyncWatcher _watcher;
  final SyncErrorBus _bus;
  final ErrorReporter _reporter;

  /// Localized "My cellar", read when the cellar is created (BR1.3).
  final String Function() _defaultCellarName;

  /// Re-subscribes the cellar and wines listeners: a listener closed by an
  /// error (e.g. permission-denied) stays in error until it is recreated.
  final void Function() _reopenCellarListeners;

  /// Forgets the cellar chosen on this phone (`sharing.activeCellar.<uid>`)
  /// after a reset and at sign-out (u7-sharing NFR6.4). The invitations
  /// listener is closed by the listener invalidation of the reset.
  final Future<void> Function()? _clearSharingChoice;

  /// u8-account: the account deletion. Without it (U1 tests) the gate never
  /// checks for a deletion in progress.
  final AccountDeletionRunner? _deletion;

  /// u8-account BR1.5: the deletion needs the network.
  final NetworkStatus? _network;

  /// u8-account BR1.1: a saved session at start-up means the app was updated,
  /// so the presentation is skipped for good.
  final Future<void> Function()? _markOnboardingSeen;

  final ValueNotifier<GateState> _state = ValueNotifier(const GateStarting());
  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _signingOut = false;

  /// Set right before `deleteUser` (BR1.13): the user going away is the
  /// deletion completing, not an expired session.
  bool _deletionCompleting = false;

  ValueListenable<GateState> get state => _state;
  GateState get current => _state.value;

  /// Reads the saved session (BR1.2) and listens for revocations (W2).
  Future<void> start() async {
    _subscriptions
      ..add(_auth.userChanges().listen(_onUserChanged))
      ..add(_bus.events.listen(_onSyncEvent));
    final user = _auth.currentUser;
    if (user == null) {
      _state.value = await _finishPendingCleanups()
          ? const GateDeleted()
          : const GateSignIn();
      return;
    }
    await _markOnboardingSeen?.call();
    await _admit(user);
  }

  /// "Continue with Google" (BR1.1).
  Future<void> signIn() async {
    if (current case GateSignIn(busy: true)) return;
    _state.value = const GateSignIn(busy: true);
    final AppUser user;
    try {
      user = await _auth.signIn();
    } on SignInException catch (error, stack) {
      if (error.kind != SignInFailureKind.cancelled) {
        await _reporter.report(error, stack, reason: 'SignInFailed');
      }
      _state.value = const GateSignIn(notice: SignInNotice.failed);
      return;
    }
    await _admit(user);
  }

  /// Blocked screen, "Sign in with `owner email`": sign out and go back.
  Future<void> signInWithOwner() => _signOut();

  /// Blocked screen, "Delete unsaved changes" confirmed; also "Try again"
  /// after a failed reset.
  Future<void> discardAndContinue() async {
    final user = switch (current) {
      GateBlocked(:final user) => user,
      _ => null,
    };
    if (user != null) await _resetThenOpen(user);
  }

  /// "Try again" when the ledger could not be read.
  Future<void> retryCheck() async {
    if (current case GateCheckFailed(:final user)) await _admit(user);
  }

  /// "Try again" on "Could not prepare the cellar" (BR1.3 violation,
  /// security-design.md §6 and §8): after a failed setup or after an error of
  /// the cellar or wines listener.
  ///
  /// Runs `ensurePersonalCellar` first and only after it succeeds reopens
  /// both listeners, so the new subscriptions find the cellar; no app
  /// restart is needed. A check that fails again keeps the error and reopens
  /// nothing: the next "Try again" repeats the whole sequence.
  Future<void> retryCellar() async {
    final user = switch (current) {
      GateCellar(:final user) => user,
      _ => null,
    };
    if (user == null) return;
    _state.value = GateEnsureCellar(user);
    unawaited(_ensureProfile(user));
    final ok = await _ensureCellar(user, reportOnly: false);
    if (current is! GateEnsureCellar) return;
    if (ok) _reopenCellarListeners();
    _state.value = GateCellar(user, setupFailed: !ok);
    unawaited(_watcher.start(user.uid));
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _watcher.stop();
    _state.dispose();
  }

  Future<void> _admit(AppUser user) async {
    _state.value = const GateStarting();
    final LedgerState ledger;
    try {
      ledger = await _ledger.read();
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'LedgerReadFailed');
      _state.value = GateCheckFailed(user);
      return;
    }
    final owner = ledger.owner;
    if (owner != null && owner.uid != user.uid) {
      _state.value = GateBlocked(
        user: user,
        ownerEmail: owner.email,
        unsavedCount: ledger.entriesOf(owner.uid).length,
      );
      return;
    }
    final lastUid = ledger.lastUid;
    if (owner == null && lastUid != null && lastUid != user.uid) {
      await _resetThenOpen(user);
      return;
    }
    if (lastUid != user.uid) {
      try {
        await _ledger.setLastUid(user.uid);
      } catch (error, stack) {
        await _reporter.report(error, stack, reason: 'LedgerWriteFailed');
        _state.value = GateCheckFailed(user);
        return;
      }
    }
    await _openCellar(user);
  }

  Future<void> _resetThenOpen(AppUser user) async {
    final previous = current;
    _state.value = const GateResetting();
    // Before the reset invalidates the listeners, so a rebuilt active cellar
    // cannot read the old choice back.
    await _clearSharingChoice?.call();
    switch (await _resetCoordinator.reset(user.uid)) {
      case ResetOutcome.completed:
        await _openCellar(user);
      case ResetOutcome.restartRequired:
        _state.value = const GateRestartRequired();
      case ResetOutcome.failed:
        _state.value = switch (previous) {
          GateBlocked(:final ownerEmail, :final unsavedCount) => GateBlocked(
            user: user,
            ownerEmail: ownerEmail,
            unsavedCount: unsavedCount,
            resetFailed: true,
          ),
          _ => GateBlocked(
            user: user,
            ownerEmail: '',
            unsavedCount: 0,
            resetFailed: true,
          ),
        };
    }
  }

  /// "AssicuraCantina" then "Cantina" (BR1.3, NFR4.11). With the cellar in
  /// the offline cache the list opens at once and the server check runs in
  /// the background; otherwise the screen waits for the transaction.
  ///
  /// u8-account BR1.8: after the checks of [_admit] and before
  /// `ensureProfile` and `ensurePersonalCellar`, a deletion in progress is
  /// resumed instead, so profile and cellar are never recreated.
  Future<void> _openCellar(AppUser user) async {
    if (await _resumeDeletionIfStarted(user)) return;
    unawaited(_ensureProfile(user));
    final cached = await _cellars.isCached(user.uid);
    if (cached) {
      _state.value = GateCellar(user);
      unawaited(_ensureCellar(user, reportOnly: true));
    } else {
      _state.value = GateEnsureCellar(user);
      final ok = await _ensureCellar(user, reportOnly: false);
      if (current is! GateEnsureCellar) return;
      _state.value = GateCellar(user, setupFailed: !ok);
    }
    unawaited(_watcher.start(user.uid));
  }

  Future<bool> _ensureCellar(AppUser user, {required bool reportOnly}) async {
    try {
      await _cellars.ensurePersonalCellar(
        uid: user.uid,
        defaultName: _defaultCellarName(),
      );
      return true;
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: reportOnly ? 'CellarCheckFailed' : 'CellarSetupFailed',
        sensitive: [user.uid, user.email],
      );
      return false;
    }
  }

  /// A profile error never blocks the cellar; it is retried on next start.
  Future<void> _ensureProfile(AppUser user) async {
    try {
      await _users.ensureProfile(user);
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'ProfileSetupFailed',
        sensitive: [user.uid, user.email, user.displayName],
      );
    }
  }

  Future<void> _signOut({
    SignInNotice? notice,
    bool fromProfile = false,
  }) async {
    _signingOut = true;
    _watcher.stop();
    await _clearSharingChoice?.call();
    try {
      await _auth.signOut();
    } catch (error, stack) {
      if (fromProfile) {
        // u8-account NFR8.2: the typed error, never the original message.
        await _reporter.report(
          AccountOperationError(AccountErrorReason.signOutFailed, cause: error),
          stack,
          reason: AccountErrorReason.signOutFailed,
        );
      } else {
        await _reporter.report(error, stack, reason: 'SignOutFailed');
      }
    } finally {
      _signingOut = false;
    }
    _state.value = GateSignIn(notice: notice);
  }

  bool get _hasSession => switch (current) {
    GateEnsureCellar() || GateCellar() || GateBlocked() => true,
    GateCheckFailed() || GateDeleting() => true,
    _ => false,
  };

  /// W2: the cloud revoked the session. Back to sign-in; the ledger and the
  /// queued writes are left untouched. After `deleteUser` the user going
  /// away is expected (BR1.13): the runner finishes step 7 and the gate shows
  /// "Account deleted".
  void _onUserChanged(AppUser? user) {
    if (user != null || _signingOut || _deletionCompleting || !_hasSession) {
      return;
    }
    _watcher.stop();
    _state.value = const GateSignIn(notice: SignInNotice.sessionExpired);
  }

  // ---- u8-account: profile -------------------------------------------------

  AppUser? get _sessionUser => switch (current) {
    GateEnsureCellar(:final user) || GateCellar(:final user) => user,
    _ => null,
  };

  /// "Sign out" of the profile (BR1.3, BR1.4). The ledger and the queued
  /// writes stay on the phone; they are lost only if another account signs
  /// in (U1, security-design.md §6).
  Future<void> signOut() => _signOut(fromProfile: true);

  /// N of "You have N changes not saved yet" (BR1.4, BR1.13): the writes of
  /// the signed-in account the server has not confirmed. Read from the
  /// ledger, never from the cloud (NFR1.1).
  Future<int> pendingChanges() async {
    final user = _sessionUser;
    if (user == null) return 0;
    try {
      return (await _ledger.read()).openEntriesOf(user.uid).length;
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'LedgerReadFailed');
      return 0;
    }
  }

  /// "Stay and sync" (BR1.4): one sync pass, then the changes still pending.
  Future<int> syncNow() async {
    await _watcher.trigger();
    return pendingChanges();
  }

  // ---- u8-account: account deletion ---------------------------------------

  Future<bool> _online() async => await _network?.hasNetwork() ?? true;

  /// "Delete forever" after the confirmation word (BR1.6): the Google sign-in
  /// again with the same account (NFR4.6), then the deletion from step 0.
  /// Returns the outcome of the sign-in; on [ReauthResult.confirmed] the
  /// gate shows the progress instead of the app.
  Future<ReauthResult> deleteAccount() async {
    final user = _sessionUser;
    if (user == null || _deletion == null) return ReauthResult.failed;
    final result = await _reauthenticate();
    if (result != ReauthResult.confirmed) return result;
    unawaited(_runDeletion(user, DeletionStep.preparePhone));
    return result;
  }

  /// "Continue" or "Try again" on the progress (BR1.8, NFR6.4): the Google
  /// sign-in first when the deletion was resumed or Firebase asked for it,
  /// then the deletion from the step to repeat.
  Future<void> resumeDeletion() async {
    final state = current;
    if (state is! GateDeleting || state.running) return;
    // Step 7 only touches the phone: no network and no sign-in needed.
    if (state.step != DeletionStep.cleanUpPhone && !await _online()) {
      _state.value = state.copyWith(notice: DeletionNotice.offline);
      return;
    }
    if (state.needsReauth && state.step != DeletionStep.cleanUpPhone) {
      _state.value = state.copyWith(running: true, clearNotice: true);
      final result = await _reauthenticate();
      if (result != ReauthResult.confirmed) {
        _state.value = state.copyWith(
          running: false,
          notice: DeletionNotice.sameAccountRequired,
        );
        return;
      }
    }
    await _runDeletion(state.user, state.step);
  }

  /// "Cancel" while the deletion is still at step 0 (BR1.13; review R-03):
  /// after the queued changes could not be saved, or when a deletion
  /// interrupted during step 0 is resumed (also offline). Nothing was
  /// deleted in the cloud yet, so the step-0 signal is removed and the app
  /// opens again; without that, the gate would find the signal and show the
  /// deletion once more.
  Future<void> cancelDeletion() async {
    final state = current;
    final runner = _deletion;
    if (state is! GateDeleting || !state.canCancel || runner == null) return;
    try {
      await runner.abandonBeforeStart(state.user.uid);
    } catch (error, stack) {
      await _reporter.report(
        AccountOperationError(
          AccountErrorReason.deleteFailed,
          step: DeletionStep.preparePhone.index,
          cause: error,
        ),
        stack,
        reason: AccountErrorReason.deleteFailed,
      );
      return;
    }
    await _openCellar(state.user);
  }

  Future<ReauthResult> _reauthenticate() async {
    final result = await _auth.reauthenticate();
    if (result == ReauthResult.failed) {
      await _reporter.report(
        AccountOperationError(AccountErrorReason.reauthFailed),
        StackTrace.current,
        reason: AccountErrorReason.reauthFailed,
      );
    }
    return result;
  }

  Future<void> _runDeletion(AppUser user, DeletionStep from) async {
    final runner = _deletion;
    if (runner == null) return;
    _state.value = GateDeleting(user: user, step: from, running: true);
    final result = await runner.run(
      user,
      from: from,
      onProgress: (progress) {
        if (current case final GateDeleting deleting) {
          _state.value = deleting.copyWith(
            step: progress.step,
            deletedDocuments: progress.deletedDocuments == 0
                ? null
                : progress.deletedDocuments,
          );
        }
      },
      beforeDeleteUser: () => _deletionCompleting = true,
    );
    _afterDeletion(user, result);
  }

  void _afterDeletion(AppUser user, DeletionResult result) {
    switch (result) {
      case DeletionCompleted(:final restartRequired):
        _deletionCompleting = false;
        _state.value = restartRequired
            ? const GateRestartRequired()
            : const GateDeleted();
      case DeletionStopped(:final step, :final failure):
        // Review R-02: when deleteUser failed the session is still there, so
        // a later revocation must lead to "Session expired" again.
        if (_auth.currentUser != null) _deletionCompleting = false;
        _state.value = GateDeleting(
          user: user,
          step: step,
          needsReauth: failure == DeletionFailure.reauthRequired,
          notice: switch (failure) {
            DeletionFailure.pendingWrites => DeletionNotice.pendingWrites,
            DeletionFailure.reauthRequired => null,
            _ => DeletionNotice.failed,
          },
        );
    }
  }

  /// BR1.8: a deletion resumes only on an explicit signal, the local one or
  /// `deletionStartedAt`; a missing profile never is one (NFR6.2). Returns
  /// true when the gate now shows the deletion.
  Future<bool> _resumeDeletionIfStarted(AppUser user) async {
    final runner = _deletion;
    if (runner == null) return false;
    int? localStep;
    try {
      localStep = await runner.localStep(user.uid);
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'LedgerReadFailed');
    }
    var startedInCloud = false;
    if (localStep == null) {
      try {
        startedInCloud = await _users.isDeletionStarted(user.uid);
      } catch (_) {
        // Unreadable without network and cache: without a local signal the
        // app opens normally, nothing is deleted without an explicit signal.
        return false;
      }
    }
    final from = DeletionPlan.resumeFrom(
      localStep: localStep,
      startedInCloud: startedInCloud,
    );
    if (from == null) return false;
    _watcher.stop();
    if (from == DeletionStep.cleanUpPhone) {
      await _runDeletion(user, from);
      return true;
    }
    _state.value = GateDeleting(
      user: user,
      step: from,
      needsReauth: true,
      notice: await _online() ? null : DeletionNotice.offline,
    );
    return true;
  }

  /// At start-up without a session: a deletion whose `deleteUser` already
  /// ran may still need the phone clean-up (step 7). Returns true when one
  /// was completed, so the sign-in says "Account deleted".
  Future<bool> _finishPendingCleanups() async {
    final runner = _deletion;
    if (runner == null) return false;
    var finished = false;
    try {
      for (final uid in (await runner.pendingCleanups()).keys) {
        final result = await runner.finishCleanup(uid);
        if (result is DeletionCompleted) finished = true;
      }
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'LedgerReadFailed');
    }
    return finished;
  }

  void _onSyncEvent(SyncEvent event) {
    if (event is SessionExpired && _hasSession) {
      unawaited(_signOut(notice: SignInNotice.sessionExpired));
    }
  }
}
