import 'dart:async';

import 'package:flutter/foundation.dart';

import '../app/error_reporter.dart';
import '../cellar/data/cellar_repository.dart';
import '../sync/ledger/local_ledger.dart';
import '../sync/sync_error_bus.dart';
import '../sync/sync_watcher.dart';
import 'app_user.dart';
import 'auth_service.dart';
import 'data/user_repository.dart';
import 'gate_state.dart';
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

  final ValueNotifier<GateState> _state = ValueNotifier(const GateStarting());
  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _signingOut = false;

  ValueListenable<GateState> get state => _state;
  GateState get current => _state.value;

  /// Reads the saved session (BR1.2) and listens for revocations (W2).
  Future<void> start() async {
    _subscriptions
      ..add(_auth.userChanges().listen(_onUserChanged))
      ..add(_bus.events.listen(_onSyncEvent));
    final user = _auth.currentUser;
    if (user == null) {
      _state.value = const GateSignIn();
      return;
    }
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

  /// "Try again" on "Could not prepare the cellar".
  Future<void> retryCellar() async {
    if (current case GateCellar(:final user, setupFailed: true)) {
      await _openCellar(user);
    }
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
  Future<void> _openCellar(AppUser user) async {
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

  Future<void> _signOut({SignInNotice? notice}) async {
    _signingOut = true;
    _watcher.stop();
    try {
      await _auth.signOut();
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'SignOutFailed');
    } finally {
      _signingOut = false;
    }
    _state.value = GateSignIn(notice: notice);
  }

  bool get _hasSession => switch (current) {
    GateEnsureCellar() || GateCellar() || GateBlocked() => true,
    GateCheckFailed() => true,
    _ => false,
  };

  /// W2: the cloud revoked the session. Back to sign-in; the ledger and the
  /// queued writes are left untouched.
  void _onUserChanged(AppUser? user) {
    if (user != null || _signingOut || !_hasSession) return;
    _watcher.stop();
    _state.value = const GateSignIn(notice: SignInNotice.sessionExpired);
  }

  void _onSyncEvent(SyncEvent event) {
    if (event is SessionExpired && _hasSession) {
      unawaited(_signOut(notice: SignInNotice.sessionExpired));
    }
  }
}
