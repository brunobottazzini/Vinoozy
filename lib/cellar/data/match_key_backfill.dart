import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/error_reporter.dart';
import '../domain/match_key.dart';
import '../domain/wine.dart';
import 'cellar_errors.dart';
import 'firestore_codec.dart';

/// Field of the cellar document that marks the backfill as done (C3,
/// u4-cellar; NFR4.9).
const String matchKeyBackfillField = 'matchKeyBackfill';

/// Outcome of [MatchKeyBackfill.run].
enum BackfillOutcome {
  /// The flag was already on the cellar (or set earlier in this session).
  alreadyDone,

  /// Every wine without a key got one, then the flag was written.
  completed,

  /// A read or a part failed: reported, retried at the next opening.
  failed,
}

/// Writes `matchKey` once per cellar on the wines created before u4-cellar
/// (BR1.4, NFR5.3, NFR4.2), so the duplicate query finds them.
///
/// The caller runs it only with `canEdit` and a network (BR1.19). It reads
/// the whole collection from the server once, finished wines included,
/// updates only the wines without a key in batches of 400 (each awaited),
/// and writes `matchKeyBackfill: true` only after the last part. Each update
/// changes `matchKey` only, as the backfill case of the rules requires.
/// An interrupted run starts again at the next opening and skips the wines
/// that already have the key.
class MatchKeyBackfill {
  MatchKeyBackfill({
    required this._db,
    required this._reporter,
    this._maxBatchWrites = 400,
  });

  final FirebaseFirestore _db;
  final ErrorReporter _reporter;
  final int _maxBatchWrites;
  final Set<String> _done = {};

  Future<BackfillOutcome> run(String cellarId) async {
    if (_done.contains(cellarId)) return BackfillOutcome.alreadyDone;
    try {
      final cellar = await _db.doc(cellarPath(cellarId)).get();
      if (cellar.data()?[matchKeyBackfillField] == true) {
        _done.add(cellarId);
        return BackfillOutcome.alreadyDone;
      }
      final snapshot = await _db
          .collection(winesPath(cellarId))
          .get(const GetOptions(source: Source.server));
      final missing = [
        for (final doc in snapshot.docs)
          if (doc.data()[WineFields.matchKey] is! String)
            Wine.fromMap(doc.id, decodeDocument(doc.data())),
      ];
      for (var start = 0; start < missing.length; start += _maxBatchWrites) {
        final batch = _db.batch();
        for (final wine in missing.skip(start).take(_maxBatchWrites)) {
          _addKey(batch, cellarId, wine);
        }
        await batch.commit();
      }
      await _db.doc(cellarPath(cellarId)).update({matchKeyBackfillField: true});
      _done.add(cellarId);
      return BackfillOutcome.completed;
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: CellarErrorReasons.backfillFailed,
      );
      return BackfillOutcome.failed;
    }
  }

  /// After the backfill, a loaded wine still without a key (created by an
  /// old app version) gets it with no extra read (functional-spec "Backfill
  /// di matchKey"). Queued without waiting; a failure is only reported.
  Future<void> keyLoaded(String cellarId, Iterable<Wine> wines) async {
    final missing = [
      for (final wine in wines)
        if (wine.matchKey == null && wine.name.isNotEmpty) wine,
    ];
    if (missing.isEmpty) return;
    try {
      for (var start = 0; start < missing.length; start += _maxBatchWrites) {
        final batch = _db.batch();
        for (final wine in missing.skip(start).take(_maxBatchWrites)) {
          _addKey(batch, cellarId, wine);
        }
        await batch.commit();
      }
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: CellarErrorReasons.backfillFailed,
      );
    }
  }

  void _addKey(WriteBatch batch, String cellarId, Wine wine) => batch.update(
    _db.doc(winePath(cellarId, wine.id)),
    {WineFields.matchKey: matchKeyOf(wine.name, wine.producer, wine.vintage)},
  );
}
