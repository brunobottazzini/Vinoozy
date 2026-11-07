import 'dart:async';

import '../account/app_user.dart';
import '../app/error_reporter.dart';
import '../core/clock.dart';
import '../sharing/domain/membership.dart';
import '../sync/sync_error_bus.dart';
import 'data/cellar_errors.dart';
import 'data/drinking_record_repository.dart';
import 'data/record_reconciler.dart';
import 'data/wine_repository.dart';
import 'domain/drinking_record.dart';
import 'domain/match_key.dart';
import 'domain/window_adjuster.dart';
import 'domain/wine.dart';
import 'domain/wine_draft.dart';
import 'domain/wine_estimate.dart';
import 'estimate_refresher.dart';
import 'wine_estimator.dart';

/// Result of [CellarActions.saveNewWine] (BR1.4).
sealed class AddResult {
  const AddResult();
}

/// Saved on the phone; [wine] is the entry as written.
class AddSaved extends AddResult {
  const AddSaved(this.wine);

  final Wine wine;
}

/// The wine already exists in the cellar, finished ones included: the form
/// shows [existing] and its current quantity.
class AddDuplicate extends AddResult {
  const AddDuplicate(this.existing);

  final Wine existing;
}

/// The local save failed: the form keeps its data (NFR6.4).
class AddFailed extends AddResult {
  const AddFailed();
}

/// Result of [CellarActions.saveEdit] (BR1.13).
enum EditResult { saved, duplicate, failed }

/// Result of [CellarActions.merge] (BR1.20).
enum MergeResult { merged, newerHasDrinks, notOwner, failed }

/// The cellar operations behind the screens (logical-components.md): they
/// combine the repositories, the estimate and the recovery queue, and they
/// apply the permissions (BR1.19, u7 BR1.6).
class CellarActions {
  CellarActions({
    required this._wines,
    required this._records,
    required this._reconciler,
    required this._refresher,
    required this._bus,
    required this._reporter,
    required this._clock,
    this._estimator = const WineEstimator(),
  });

  final WineRepository _wines;
  final DrinkingRecordRepository _records;
  final RecordReconciler _reconciler;
  final EstimateRefresher _refresher;
  final SyncErrorBus _bus;
  final ErrorReporter _reporter;
  final Clock _clock;
  final WineEstimator _estimator;

  int get _year => _clock.now().year;

  /// The entries of [cellarId] with the key of [draft] (BR1.4), oldest first;
  /// empty when the query fails (reported): the duplicate check never blocks
  /// a save.
  Future<List<Wine>> duplicatesOf(String cellarId, WineDraft draft) =>
      _findByKey(
        cellarId,
        matchKeyOf(draft.name, draft.producer, draft.vintage),
        sensitive: [draft.name, ?draft.producer],
      );

  /// The other entries with the key of [wine], for "Possible duplicate"
  /// (BR1.20); oldest first, [wine] included.
  Future<List<Wine>> entriesLike(String cellarId, Wine wine) => _findByKey(
    cellarId,
    wine.matchKey ?? matchKeyOf(wine.name, wine.producer, wine.vintage),
    sensitive: sensitiveOfWine(wine),
  );

  Future<List<Wine>> _findByKey(
    String cellarId,
    String key, {
    required List<String> sensitive,
  }) async {
    try {
      return await _wines.findByMatchKey(cellarId, key);
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: CellarErrorReasons.saveFailed,
        sensitive: sensitive,
      );
      return const [];
    }
  }

  /// "Save" in the add form (BR1.4, BR1.5, BR1.18): the duplicate check,
  /// then the internal estimate and the local write; the catalog is asked
  /// afterwards without delaying the return to the list.
  Future<AddResult> saveNewWine({
    required AccessibleCellar cellar,
    required AppUser user,
    required WineDraft draft,
  }) async {
    final duplicates = await duplicatesOf(cellar.cellarId, draft);
    if (duplicates.isNotEmpty) return AddDuplicate(duplicates.first);
    final estimate = _estimator.estimate(
      WineFactsInput(
        name: draft.name,
        producer: draft.producer,
        vintage: draft.vintage,
        wineType: draft.wineType,
        region: draft.region,
        denomination: draft.denomination,
        referenceYear: _year,
      ),
    );
    final outcome = await _wines.addWine(
      cellarId: cellar.cellarId,
      user: user,
      draft: draft,
      estimate: estimate,
    );
    if (outcome is! SaveAccepted) return const AddFailed();
    final wine = Wine(
      id: draft.id,
      name: draft.name,
      vintage: draft.vintage,
      storedQuantity: draft.quantity,
      producer: draft.producer,
      wineType: draft.wineType,
      region: draft.region,
      denomination: draft.denomination,
      window: estimate.window,
      baseWindow: estimate.baseWindow,
      pairings: estimate.pairings,
      matchKey: matchKeyOf(draft.name, draft.producer, draft.vintage),
    );
    unawaited(_refresher.refreshWine(cellar, user, wine));
    return AddSaved(wine);
  }

  /// "Add N bottles" of the duplicate dialog (BR1.4, BR1.15): a finished
  /// wine comes back to the cellar.
  Future<SaveOutcome> addBottles({
    required AccessibleCellar cellar,
    required AppUser user,
    required Wine wine,
    required int n,
  }) => _wines.addBottles(
    cellarId: cellar.cellarId,
    user: user,
    wine: wine,
    n: n,
  );

  /// "−" in the detail (BR1.15).
  Future<SaveOutcome> removeBottle({
    required AccessibleCellar cellar,
    required AppUser user,
    required Wine wine,
  }) => _wines.removeBottle(cellarId: cellar.cellarId, user: user, wine: wine);

  /// "Save" in the edit form (BR1.13): refused when another wine has the new
  /// key; otherwise the texts, the key, the estimate (the feedback kept) and
  /// the quantity change.
  Future<EditResult> saveEdit({
    required AccessibleCellar cellar,
    required AppUser user,
    required Wine before,
    required WineDraft draft,
    required int targetQuantity,
  }) async {
    final others = await duplicatesOf(cellar.cellarId, draft);
    if (others.any((wine) => wine.id != before.id)) return EditResult.duplicate;
    final estimate = _estimator.estimate(
      WineFactsInput(
        name: draft.name,
        producer: draft.producer,
        vintage: draft.vintage,
        wineType: draft.wineType,
        region: draft.region,
        denomination: draft.denomination,
        referenceYear: before.createdAt?.toLocal().year ?? _year,
      ),
      adjustment: before.windowAdjustment,
    );
    final outcome = await _wines.updateWine(
      cellarId: cellar.cellarId,
      user: user,
      before: before,
      draft: draft,
      targetQuantity: targetQuantity,
      estimate: estimate,
    );
    return outcome is SaveAccepted ? EditResult.saved : EditResult.failed;
  }

  /// "Drunk" (BR1.10), dated today on the phone.
  Future<DrinkOutcome> drink({
    required AccessibleCellar cellar,
    required AppUser user,
    required Wine wine,
  }) => _records.drink(
    cellarId: cellar.cellarId,
    user: user,
    wine: wine,
    today: _clock.now(),
  );

  /// "Undo" (BR1.10): when the undone drink gave the feedback in use, the
  /// window is computed again (BR1.12).
  Future<UndoResult> undoDrink({
    required AccessibleCellar cellar,
    required AppUser user,
    required Wine wine,
    required String recordId,
  }) async {
    final result = await _records.undo(
      cellarId: cellar.cellarId,
      user: user,
      wine: wine,
      recordId: recordId,
    );
    if (result == UndoResult.undone &&
        wine.windowAdjustment?.recordId == recordId) {
      await recomputeAdjustment(cellar: cellar, user: user, wine: wine);
    }
    return result;
  }

  /// Rating, notes, date and "How was it?" (BR1.11); a change of condition
  /// or date computes the window again (BR1.12).
  Future<SaveOutcome> updateRecord({
    required AccessibleCellar cellar,
    required AppUser user,
    required DrinkingRecord record,
    required Wine? wine,
    required int? rating,
    required String? notes,
    required DateTime drankOn,
    required DrinkCondition? condition,
  }) async {
    final outcome = await _records.updateRecord(
      cellarId: cellar.cellarId,
      user: user,
      record: record,
      rating: rating,
      notes: notes,
      drankOn: drankOn,
      condition: condition,
    );
    final feedbackChanged =
        record.condition != condition ||
        (condition != null && dateOnly(record.drankOn) != dateOnly(drankOn));
    if (outcome is SaveAccepted && feedbackChanged && wine != null) {
      await recomputeAdjustment(cellar: cellar, user: user, wine: wine);
    }
    return outcome;
  }

  /// Applies the feedback that counts to [wine] (BR1.12): reads its drinks
  /// (server, else cache), picks the most recent with a condition and writes
  /// the effective window when it changed. Only with `canEdit` (BR1.19).
  /// Offline, the result may miss drinks not downloaded yet, so a
  /// `reapplyAdjustment` entry repeats it from the server later (NFR6.6).
  Future<void> recomputeAdjustment({
    required AccessibleCellar cellar,
    required AppUser user,
    required Wine wine,
    bool serverOnly = false,
  }) async {
    if (!cellar.canEdit) return;
    final WineRecords read;
    try {
      read = await _records.recordsOfWine(
        cellar.cellarId,
        wine.id,
        source: serverOnly ? RecordsSource.server : RecordsSource.serverOrCache,
      );
    } catch (error, stack) {
      if (serverOnly) rethrow;
      await _queue(user, PendingOpKind.reapplyAdjustment, cellar, wine.id);
      await _reporter.report(
        error,
        stack,
        reason: CellarErrorReasons.reconcileFailed,
        sensitive: sensitiveOfWine(wine),
      );
      return;
    }
    if (!read.fromServer) {
      await _queue(user, PendingOpKind.reapplyAdjustment, cellar, wine.id);
    }
    final adjustment = WindowAdjuster.pick(read.records);
    final base =
        wine.baseWindow ?? (wine.windowAdjustment == null ? wine.window : null);
    final next = base == null
        ? WineEstimate(adjustment: adjustment, pairings: wine.pairings)
        : _estimator.withAdjustment(base, adjustment, wine.pairings);
    if (base == null || next == WineEstimate.of(wine)) return;
    await _wines.setEstimate(
      cellarId: cellar.cellarId,
      user: user,
      wine: wine,
      estimate: next,
    );
  }

  /// Wines without an estimate (created by U1) get the internal one, once,
  /// by someone with `canEdit` (functional-spec "Vini senza stima").
  Future<int> ensureEstimates({
    required AccessibleCellar cellar,
    required AppUser user,
    required Iterable<Wine> wines,
  }) async {
    if (!cellar.canEdit) return 0;
    var written = 0;
    for (final wine in wines) {
      if (wine.window != null || wine.baseWindow != null) continue;
      final estimate = _estimator.estimate(
        WineFactsInput.ofWine(wine, fallbackYear: _year),
        adjustment: wine.windowAdjustment,
      );
      if (estimate.window == null) continue;
      final outcome = await _wines.setEstimate(
        cellarId: cellar.cellarId,
        user: user,
        wine: wine,
        estimate: estimate,
      );
      if (outcome is SaveAccepted) written++;
    }
    return written;
  }

  /// "Delete" (BR1.14): the owner only. Offline or after a part refused
  /// twice, a `purgeRecords` entry completes the deletion the user asked for
  /// when the network is back: it deletes the drinks left and the wine only
  /// once no drink remains (security-design.md §4). After two refusals the
  /// notice says so ("not complete yet, it will finish"), never "try again"
  /// (review R-06).
  Future<DeleteOutcome> deleteWine({
    required AccessibleCellar cellar,
    required AppUser user,
    required Wine wine,
  }) async {
    if (!cellar.isOwner) return DeleteOutcome.failed;
    final outcome = await _wines.deleteWineWithRecords(
      cellarId: cellar.cellarId,
      user: user,
      wine: wine,
    );
    switch (outcome) {
      case DeleteOutcome.deleted:
        break;
      case DeleteOutcome.queued:
        await _queue(user, PendingOpKind.purgeRecords, cellar, wine.id);
      case DeleteOutcome.failed:
        await _queue(user, PendingOpKind.purgeRecords, cellar, wine.id);
        _bus.publish(const CellarNotice(CellarNoticeKind.deleteFailed));
    }
    return outcome;
  }

  /// "Merge" of a possible duplicate (BR1.20): the owner only, and only when
  /// the newer entry has no drinks (their `wineId` cannot move).
  Future<MergeResult> merge({
    required AccessibleCellar cellar,
    required AppUser user,
    required Wine older,
    required Wine newer,
  }) async {
    if (!cellar.isOwner) return MergeResult.notOwner;
    try {
      final drinks = await _records.recordsOfWine(cellar.cellarId, newer.id);
      if (drinks.records.isNotEmpty) return MergeResult.newerHasDrinks;
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: CellarErrorReasons.mergeFailed,
        sensitive: [...sensitiveOfWine(older), ...sensitiveOfWine(newer)],
      );
      return MergeResult.failed;
    }
    final outcome = await _wines.mergeInto(
      cellarId: cellar.cellarId,
      user: user,
      older: older,
      newer: newer,
    );
    return outcome is SaveAccepted ? MergeResult.merged : MergeResult.failed;
  }

  /// Whether the newer of two entries has drinks (the banner hides "Merge").
  Future<bool> hasDrinks(String cellarId, Wine wine) async {
    try {
      final read = await _records.recordsOfWine(
        cellarId,
        wine.id,
        source: RecordsSource.cache,
      );
      return read.records.isNotEmpty;
    } catch (_) {
      // Unknown: keep the safe answer, "Merge" stays hidden.
      return true;
    }
  }

  Future<void> _queue(
    AppUser user,
    PendingOpKind kind,
    AccessibleCellar cellar,
    String wineId,
  ) => _reconciler.add(
    user.uid,
    PendingOp(
      kind: kind,
      cellarId: cellar.cellarId,
      wineId: wineId,
      createdAt: _clock.now(),
    ),
  );
}
