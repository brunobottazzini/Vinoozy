import 'dart:async';

import '../account/gate_state.dart';
import '../app/error_reporter.dart';
import '../dev/dev_cheats.dart';
import '../sync/ledger/key_value_store.dart';
import '../usage/cloud_usage_meter.dart';
import '../usage/usage_uploader.dart';
import 'data/entitlement_repository.dart';

/// The plan and usage state of the signed-in account across its session
/// (freemium-plus FR1.4, FR5.5, FR6.1, FR6.3, NFR3).
///
/// - A session opens when the account gate shows the cellar: the meter
///   counts for that uid and the uploader sends every 15 minutes while the
///   app is in the foreground, once more when it goes to the background.
/// - Sign-out ([endSession]) stops counting and removes the developer
///   override and the local copy of the entitlement. The usage counters of
///   the account stay on the phone, keyed by uid, so they are sent at its
///   next session: a cumulative cleared and started again from zero would be
///   refused by the backend as decreasing for the rest of the month.
/// - An account change or an account deletion goes through the local reset
///   ([clearAccountData], called by `ResetCoordinator`): the counters and the
///   upload state of the previous account are removed too.
/// - Any other state without a session (session expired, deletion running,
///   another account blocked) only stops counting.
class PlanSession {
  PlanSession({
    required this._meter,
    required this._uploader,
    required this._store,
    required this._reporter,
    this._entitlements,
    this._devOverrides,
    this._onSessionChanged,
  });

  /// The uid whose counters are on the phone, for [clearAccountData].
  static const String lastUidKey = 'plan.session.lastUid.v1';

  final CloudUsageMeter _meter;
  final UsageUploader _uploader;
  final KeyValueStore _store;
  final ErrorReporter _reporter;
  final EntitlementRepository? _entitlements;
  final DevOverrideStore? _devOverrides;

  /// Tells the providers the uid of the open session (null: none), so the
  /// plan listeners exist only during a session.
  final void Function(String? uid)? _onSessionChanged;

  String? _uid;
  Future<void> _work = Future<void>.value();
  bool _foreground = true;

  /// The uid of the open session.
  String? get uid => _uid;

  /// Follows the account gate: [next] after [previous].
  void onGateState(GateState? previous, GateState next) {
    switch (next) {
      case GateCellar(:final user) || GateEnsureCellar(:final user):
        unawaited(open(user.uid));
      case GateSignIn(notice: null) when _hadSession(previous):
        unawaited(endSession());
      case GateStarting():
        break;
      default:
        unawaited(suspend());
    }
  }

  static bool _hadSession(GateState? state) => switch (state) {
    GateCellar() || GateEnsureCellar() || GateBlocked() => true,
    GateCheckFailed() => true,
    _ => false,
  };

  /// Opens the session of [uid]; nothing when it is already open.
  Future<void> open(String uid) {
    if (_uid == uid) return _work;
    _uid = uid;
    _onSessionChanged?.call(uid);
    return _queue(() async {
      await _meter.start(uid);
      await _uploader.start();
      if (_foreground) _uploader.onResume();
      await _write(lastUidKey, uid);
    });
  }

  /// Stops counting; the counters stay saved.
  Future<void> suspend() {
    if (_uid == null) return _work;
    _uid = null;
    _onSessionChanged?.call(null);
    return _queue(() async {
      await _uploader.stop();
      await _meter.stop();
    });
  }

  /// Sign-out (FR5.5, FR1.4): the override and the entitlement copy go.
  Future<void> endSession() async {
    await suspend();
    await _queue(_clearAccountLocalState);
  }

  /// The local reset of an account change or a deletion: also the counters
  /// and the upload state of the previous account.
  Future<void> clearAccountData() async {
    await suspend();
    await _queue(() async {
      final last = await _read(lastUidKey);
      if (last != null && last.isNotEmpty) {
        await _meter.clear(last);
        await _uploader.clear(last);
      }
      await _write(lastUidKey, '');
      await _clearAccountLocalState();
    });
  }

  /// The app is back in the foreground: periodic uploads again.
  void onAppResumed() {
    _foreground = true;
    if (_uid != null) _uploader.onResume();
  }

  /// The app goes to the background: one upload now (end of the session).
  Future<void> onAppPaused() async {
    _foreground = false;
    if (_uid == null) return;
    await _uploader.onPause();
  }

  Future<void> _clearAccountLocalState() async {
    await _devOverrides?.clear();
    await _entitlements?.clear();
  }

  /// One change at a time, in order; an error never stops the next one.
  Future<void> _queue(Future<void> Function() step) {
    _work = _work.then((_) => step()).catchError((
      Object error,
      StackTrace stack,
    ) {
      return _reporter.report(error, stack, reason: 'PlanSessionFailed');
    });
    return _work;
  }

  Future<String?> _read(String key) async {
    try {
      return await _store.read(key);
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'PlanSessionFailed');
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _store.write(key, value);
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'PlanSessionFailed');
    }
  }
}
