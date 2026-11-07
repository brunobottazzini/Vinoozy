import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/error_reporter.dart';
import '../../core/clock.dart';
import 'cellar_errors.dart';

/// What a pending entry completes when the network is back (NFR6.6).
enum PendingOpKind {
  /// Read the drinks of the wine from the server and apply the feedback
  /// that counts (BR1.12). Anyone with `canEdit`.
  reapplyAdjustment,

  /// Delete the drinks of a deleted wine that this phone had not downloaded,
  /// then the wine (BR1.14). The owner only.
  purgeRecords,
}

/// One operation left half done offline.
class PendingOp {
  const PendingOp({
    required this.kind,
    required this.cellarId,
    required this.wineId,
    required this.createdAt,
  });

  final PendingOpKind kind;
  final String cellarId;
  final String wineId;
  final DateTime createdAt;

  /// Same operation on the same wine: entries are idempotent, one is enough.
  bool sameTarget(PendingOp other) =>
      other.kind == kind &&
      other.cellarId == cellarId &&
      other.wineId == wineId;

  Map<String, Object> toJson() => {
    'op': kind.name,
    'cellarId': cellarId,
    'wineId': wineId,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  /// Reads one stored entry, or `null` when it is not one.
  static PendingOp? fromJson(Object? json) {
    if (json is! Map) return null;
    final kind = PendingOpKind.values
        .where((value) => value.name == json['op'])
        .firstOrNull;
    final cellarId = json['cellarId'];
    final wineId = json['wineId'];
    final createdAt = json['createdAt'];
    if (kind == null ||
        cellarId is! String ||
        wineId is! String ||
        createdAt is! int) {
      return null;
    }
    return PendingOp(
      kind: kind,
      cellarId: cellarId,
      wineId: wineId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PendingOp && sameTarget(other) && other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(kind, cellarId, wineId, createdAt);

  @override
  String toString() => 'PendingOp(${kind.name})';
}

/// Thrown by a `perform` callback to keep an entry for a later run without
/// reporting it (e.g. an entry of a cellar that is not the active one).
class ReconcileLater implements Exception {
  const ReconcileLater();
}

/// Outcome of one [RecordReconciler.run].
class ReconcileSummary {
  const ReconcileSummary({
    required this.done,
    required this.refused,
    required this.kept,
  });

  final int done;
  final int refused;
  final int kept;
}

/// Prefix of the stored entries, one key per user (infrastructure-spec §1).
const String pendingOpsKeyPrefix = 'cellar.pending.';

/// Operations to complete when the network is back (logical-components.md:
/// RecordReconciler; NFR6.6, BR1.12, BR1.14).
///
/// Entries live in `shared_preferences` under `cellar.pending.<uid>` as a
/// JSON list, so they survive a restart. They are idempotent and removed when
/// they succeed, when the rules refuse them (`cellar_reconcile_failed`,
/// never a lost access) or after [maxAge]. At most [maxEntries], the oldest
/// dropped first. Without `shared_preferences` the entries stay in memory
/// until the app closes; that case is reported once.
class RecordReconciler {
  RecordReconciler({
    required this._preferences,
    required this._clock,
    required this._reporter,
    this.maxEntries = 50,
    this.maxAge = const Duration(days: 7),
  });

  final Future<SharedPreferences> Function() _preferences;
  final Clock _clock;
  final ErrorReporter _reporter;
  final int maxEntries;
  final Duration maxAge;
  final Map<String, List<PendingOp>> _memory = {};
  bool _fallbackReported = false;

  static String keyOf(String uid) => '$pendingOpsKeyPrefix$uid';

  /// Adds [op] for [uid]; an entry for the same target is kept once.
  Future<void> add(String uid, PendingOp op) async {
    final ops = await pending(uid);
    if (ops.any(op.sameTarget)) return;
    final next = [...ops, op];
    while (next.length > maxEntries) {
      next.removeAt(0);
    }
    await _save(uid, next);
  }

  /// The entries of [uid] still valid, oldest first; expired ones are
  /// dropped.
  Future<List<PendingOp>> pending(String uid) async {
    final ops = await _load(uid);
    final now = _clock.now();
    final valid = [
      for (final op in ops)
        if (now.difference(op.createdAt) < maxAge) op,
    ];
    if (valid.length != ops.length) await _save(uid, valid);
    return valid;
  }

  /// Runs every entry of [uid] with [perform], one at a time.
  Future<ReconcileSummary> run(
    String uid,
    Future<void> Function(PendingOp op) perform,
  ) async {
    final ops = await pending(uid);
    final kept = <PendingOp>[];
    var done = 0;
    var refused = 0;
    for (final op in ops) {
      try {
        await perform(op);
        done++;
      } on ReconcileLater {
        kept.add(op);
      } on FirebaseException catch (error, stack) {
        if (_isRefusal(error)) {
          refused++;
          await _reporter.report(
            error,
            stack,
            reason: CellarErrorReasons.reconcileFailed,
          );
        } else {
          kept.add(op);
        }
      } catch (error, stack) {
        kept.add(op);
        await _reporter.report(
          error,
          stack,
          reason: CellarErrorReasons.reconcileFailed,
        );
      }
    }
    // Entries added while running are kept as well.
    final latest = await _load(uid);
    await _save(uid, [
      ...kept,
      for (final op in latest)
        if (!ops.any(op.sameTarget)) op,
    ]);
    return ReconcileSummary(done: done, refused: refused, kept: kept.length);
  }

  static bool _isRefusal(FirebaseException error) => const {
    'permission-denied',
    'invalid-argument',
    'failed-precondition',
    'not-found',
  }.contains(error.code);

  Future<List<PendingOp>> _load(String uid) async {
    try {
      final prefs = await _preferences();
      final raw = prefs.getString(keyOf(uid));
      if (raw == null) return [...?_memory[uid]];
      final decoded = jsonDecode(raw);
      return [
        if (decoded is List)
          for (final item in decoded) ?PendingOp.fromJson(item),
      ];
    } on FormatException {
      return const [];
    } catch (error, stack) {
      await _reportFallback(error, stack);
      return [...?_memory[uid]];
    }
  }

  Future<void> _save(String uid, List<PendingOp> ops) async {
    _memory[uid] = ops;
    try {
      final prefs = await _preferences();
      if (ops.isEmpty) {
        await prefs.remove(keyOf(uid));
      } else {
        await prefs.setString(
          keyOf(uid),
          jsonEncode([for (final op in ops) op.toJson()]),
        );
      }
    } catch (error, stack) {
      await _reportFallback(error, stack);
    }
  }

  Future<void> _reportFallback(Object error, StackTrace stack) async {
    if (_fallbackReported) return;
    _fallbackReported = true;
    await _reporter.report(
      error,
      stack,
      reason: CellarErrorReasons.reconcileFailed,
    );
  }
}
