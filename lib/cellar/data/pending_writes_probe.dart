import 'dart:async';

import '../../app/error_reporter.dart';
import 'cellar_errors.dart';

/// Tells the sync banner when drinks are waiting to reach the server
/// (security-design.md §4, NFR6.6), with no read of its own.
///
/// No open listener covers every drink: the History reads pages and a
/// finished wine leaves the `quantity > 0` list. So after each drink write
/// the probe marks `SyncSource.drinkingRecords` pending, waits for
/// `FirebaseFirestore.waitForPendingWrites()` and clears it when the wait
/// completes. Only the latest wait clears it: an earlier one finishing
/// while a later write is still queued changes nothing.
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
  int _token = 0;
  bool _pending = false;

  bool get isPending => _pending;

  /// Called after every drink write (drink, undo, rating and notes, delete):
  /// pending at once, cleared when the queue is confirmed.
  Future<void> trackWrite() {
    final token = ++_token;
    _set(true);
    return _waitFor(token);
  }

  /// At app start, the writes queued by an earlier session count too. A wait
  /// that completes within [_startupGrace] never shows the banner.
  Future<void> checkAtStartup() async {
    final token = ++_token;
    var done = false;
    final timer = Timer(_startupGrace, () {
      if (!done && token == _token) _set(true);
    });
    await _waitFor(token);
    done = true;
    timer.cancel();
  }

  Future<void> _waitFor(int token) async {
    try {
      await _wait();
      if (token == _token) _set(false);
    } catch (error, stack) {
      // E.g. at sign-out: the banner must not stay "pending" for ever.
      if (token == _token) _set(false);
      await _reporter.report(
        error,
        stack,
        reason: CellarErrorReasons.pendingProbeFailed,
      );
    }
  }

  void _set(bool pending) {
    if (pending == _pending) return;
    _pending = pending;
    _onPendingChanged(pending);
  }
}
