import '../domain/wine.dart';

/// Fixed, data-free reasons of the u4-cellar errors sent to the
/// [ErrorReporter] (security-design.md §2, monitoring-design.md §1). The
/// reported message never carries the wine name, producer, denomination or
/// notes: they are passed as sensitive values and stripped (NFR8.2).
abstract final class CellarErrorReasons {
  static const String saveFailed = 'cellar_save_failed';
  static const String drinkFailed = 'cellar_drink_failed';
  static const String undoFailed = 'cellar_undo_failed';
  static const String recordUpdateFailed = 'cellar_record_update_failed';
  static const String deleteFailed = 'cellar_delete_failed';
  static const String mergeFailed = 'cellar_merge_failed';
  static const String estimateRefreshFailed = 'estimate_refresh_failed';
  static const String backfillFailed = 'match_key_backfill_failed';
  static const String reconcileFailed = 'cellar_reconcile_failed';
  static const String pendingProbeFailed = 'pending_probe_failed';

  /// A History page could not be read (e.g. the index is not "Enabled" yet,
  /// infrastructure-specification.md §4): the screen offers "Try again".
  static const String historyFailed = 'cellar_history_failed';

  /// label-autofill-windows NFR4.16: the one-off estimate of the cellar
  /// with the new tables stopped (`permissionDenied`, `localWriteFailed`).
  static const String estimatesMigrationFailed = 'estimates_migration_failed';

  /// label-autofill-windows NFR4.16: the appellation table or the label
  /// text could not be read (an internal error, never a text).
  static const String appellationsIndexFailed = 'appellations_index_failed';
}

/// The values of [wine] that must never leave the phone in a report.
List<String> sensitiveOfWine(Wine wine) => [
  wine.name,
  ?wine.producer,
  ?wine.denomination,
];
