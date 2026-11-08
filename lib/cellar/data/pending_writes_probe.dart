import 'dart:async';

import '../../app/error_reporter.dart';
import 'cellar_errors.dart';

/// Tells the sync banner when drinks are waiting to reach the server
/// (security-design.md §4, NFR6.6), with no read of its own.
///
/// No open listener covers every drink: the History reads pages and a
/// finished wine leaves the `quantity > 0` list. So each drink write (drink,
/// undo, rating and notes) hands its own commit future to [trackWrite]: the
/// probe counts the writes still open and stays pending until every one of
/// them has completed, confirmed by the server or failed. A commit future
/// stays open while offline, so the state never depends on the order in
/// which the platform channel runs `waitForPendingWrites()` and the commit.
///
/// [checkAtStartup] alone still uses `FirebaseFirestore.waitForPendingWrites()`
/// for the writes queued by an earlier session, with its own state: the
/// probe is pending while a write is open or the start-up wait is showing.
class PendingWritesProbe {
  PendingWritesProbe({
    required Future<void> Function() waitForPendingWrites,
    required this._onPendingChanged,
    required this._reporter,
    this._startupGrace = const Duration(milliseconds: 300),
  }) : _wait = waitForPendingWrites;

  final Future<void> Function() _wait;
  final void Function(bool pending) _onPendingChanged;
  final ErrorReporter _reporter;
  final Duration _startupGrace;
  int _openWrites = 0;
  bool _startupPending = false;
  bool _pending = false;

  bool get isPending => _pending;

  /// Called with the commit future of every drink write: pending at once,
  /// cleared when no tracked write is open any more. A failed [write] only
  /// closes its share here: the writer (`DrinkingRecordRepository._commit`)
  /// already handles and reports that same error, once.
  Future<void> trackWrite(Future<void> write) async {
    _openWrites++;
    _refresh();
    try {
      await write;
    } catch (_) {
      // Reported by the writer; a second report would duplicate it.
    } finally {
      _openWrites--;
      _refresh();
    }
  }

  /// At app start, the writes queued by an earlier session count too. A wait
  /// that completes within [_startupGrace] never shows the banner. Called
  /// once, at app start.
  Future<void> checkAtStartup() async {
    final timer = Timer(_startupGrace, () {
      _startupPending = true;
      _refresh();
    });
    try {
      await _wait();
    } catch (error, stack) {
      // E.g. at sign-out: the banner must not stay "pending" for ever.
      _endStartup(timer);
      await _reporter.report(
        error,
        stack,
        reason: CellarErrorReasons.pendingProbeFailed,
      );
      return;
    }
    _endStartup(timer);
  }

  void _endStartup(Timer timer) {
    timer.cancel();
    _startupPending = false;
    _refresh();
  }

  void _refresh() => _set(_openWrites > 0 || _startupPending);

  void _set(bool pending) {
    if (pending == _pending) return;
    _pending = pending;
    _onPendingChanged(pending);
  }
}
