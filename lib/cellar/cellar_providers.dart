import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account/app_user.dart';
import '../app/providers.dart';
import '../catalog/core/wine_catalog.dart';
import '../catalog/platform/catalog_providers.dart';
import '../sharing/sharing_providers.dart';
import 'data/wine_repository.dart' show WinesSnapshot;
import 'cellar_actions.dart';
import 'cellar_maintenance.dart';
import 'data/cellar_errors.dart';
import 'data/drinking_record_repository.dart';
import 'data/match_key_backfill.dart';
import 'data/record_reconciler.dart';
import 'domain/cellar_filter.dart';
import 'domain/drinking_record.dart';
import 'domain/wine.dart';
import 'estimate_refresher.dart';

// Providers of u4-cellar (logical-components.md). `winesStreamProvider`, the
// single listener of the wines with `quantity > 0` shared with the Dashboard
// and the sharing, stays in lib/app/providers.dart where U1 put it.

Never _injected(String name) =>
    throw UnimplementedError('$name must be overridden at start-up');

/// Drinks of the cellars; created at start-up (lib/app/bootstrap.dart).
final drinkingRecordRepositoryProvider = Provider<DrinkingRecordRepository>(
  (ref) => _injected('drinkingRecordRepositoryProvider'),
);

/// The one-off `matchKey` backfill; created at start-up.
final matchKeyBackfillProvider = Provider<MatchKeyBackfill>(
  (ref) => _injected('matchKeyBackfillProvider'),
);

/// The operations to complete when the network is back; created at start-up.
final recordReconcilerProvider = Provider<RecordReconciler>(
  (ref) => _injected('recordReconcilerProvider'),
);

/// The catalog refinement of the estimates (BR1.5, BR1.6). U3 asks that
/// its catalog is used with `ref.watch`.
final estimateRefresherProvider = Provider<EstimateRefresher>(
  (ref) => EstimateRefresher(
    wines: ref.watch(wineRepositoryProvider),
    catalog: ref.watch(catalogProvider),
    network: ref.watch(networkStatusProvider),
    reporter: ref.watch(errorReporterProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// The cellar operations behind the screens.
final cellarActionsProvider = Provider<CellarActions>(
  (ref) => CellarActions(
    wines: ref.watch(wineRepositoryProvider),
    records: ref.watch(drinkingRecordRepositoryProvider),
    reconciler: ref.watch(recordReconcilerProvider),
    refresher: ref.watch(estimateRefresherProvider),
    bus: ref.watch(syncErrorBusProvider),
    reporter: ref.watch(errorReporterProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Backfill, recovery and estimates at the opening of the cellar and when
/// the network is back (NFR6.6).
final cellarMaintenanceProvider = Provider<CellarMaintenance>(
  (ref) => CellarMaintenance(
    backfill: ref.watch(matchKeyBackfillProvider),
    reconciler: ref.watch(recordReconcilerProvider),
    refresher: ref.watch(estimateRefresherProvider),
    actions: ref.watch(cellarActionsProvider),
    wines: ref.watch(wineRepositoryProvider),
    network: ref.watch(networkStatusProvider),
    reporter: ref.watch(errorReporterProvider),
  ),
);

/// Starts [CellarMaintenance] for the active cellar of [AppUser] (NFR6.6):
/// once when its wines are first loaded (the opening of the cellar), and
/// every time `NetworkStatus.onChanged` reports the network back. Watched by
/// the HomeShell while the cellar is ready; the value counts the runs.
final cellarMaintenanceTriggerProvider = Provider.autoDispose
    .family<int, AppUser>((ref, user) {
      final cellar = ref.watch(activeCellarProvider(user));
      final maintenance = ref.watch(cellarMaintenanceProvider);
      var runs = 0;
      List<Wine>? loaded;
      var ranWithServerData = false;
      void start() {
        final wines = loaded;
        if (wines == null) return;
        runs++;
        unawaited(maintenance.run(cellar, user, wines));
      }

      // The first snapshot opens the cellar; when it came from the cache
      // (maybe empty: new phone, reinstall), the first server snapshot runs
      // the work again with the real wines (review R-04). CellarMaintenance
      // never runs twice at the same time.
      ref.listen<AsyncValue<WinesSnapshot>>(
        winesStreamProvider(cellar.cellarId),
        (previous, next) {
          final snapshot = next.value;
          if (snapshot == null) return;
          final first = loaded == null;
          loaded = snapshot.wines;
          final fromServer = !snapshot.meta.isFromCache;
          if (first || (fromServer && !ranWithServerData)) {
            if (fromServer) ranWithServerData = true;
            start();
          }
        },
        fireImmediately: true,
      );
      final subscription = ref.watch(networkStatusProvider).onChanged.listen(
        (online) {
          if (online) start();
        },
        // An unreadable connectivity state is not a network return.
        onError: (Object _) {},
      );
      ref.onDispose(subscription.cancel);
      return runs;
    });

/// A wine of a cellar.
typedef WineKey = ({String cellarId, String wineId});

/// Refreshes the one-shot reads of the drinks after a write on them (review
/// R-01, R-02; BR1.16, US6.2): the History of [cellarId] reloads its first
/// page and the last drinks of [wineIds] (or of every wine) are read again.
/// Called after a drink, "Undo", a rating or notes change, a delete and a
/// merge. It takes the [ProviderContainer], read before any wait, so it
/// still works when the screen that started the write is closed.
void invalidateDrinkReads(
  ProviderContainer container, {
  required String cellarId,
  Iterable<String>? wineIds,
}) {
  container.invalidate(historyPagerProvider(cellarId));
  if (wineIds == null) {
    container.invalidate(recentDrinksProvider);
    return;
  }
  for (final wineId in wineIds) {
    container.invalidate(
      recentDrinksProvider((cellarId: cellarId, wineId: wineId)),
    );
  }
}

/// One wine, present or finished (BR1.7 archive, BR1.16; NFR2.2): one
/// document listener, used for a finished wine or a wine opened from the
/// Dashboard or the History. `null` while it does not exist.
final wineProvider = StreamProvider.autoDispose.family<Wine?, WineKey>(
  (ref, key) =>
      ref.watch(wineRepositoryProvider).watchWine(key.cellarId, key.wineId),
);

/// The finished wines ("Drunk", BR1.7), read only when the archive opens.
final archivedWinesProvider = FutureProvider.autoDispose
    .family<List<Wine>, String>(
      (ref, cellarId) =>
          ref.watch(wineRepositoryProvider).fetchArchived(cellarId),
    );

/// The last 3 drinks of a wine for the detail, from the cache
/// (performance-design.md §3): no read on the server.
final recentDrinksProvider = FutureProvider.autoDispose
    .family<List<DrinkingRecord>, WineKey>((ref, key) async {
      final read = await ref
          .watch(drinkingRecordRepositoryProvider)
          .recordsOfWine(key.cellarId, key.wineId, source: RecordsSource.cache);
      return read.records.take(3).toList();
    });

/// Search and filters of the cellar list (BR1.8). Not disposed, so the
/// Dashboard can set a status before switching to the Cellar tab (BR1.17).
final cellarFilterProvider =
    NotifierProvider<CellarFilterNotifier, CellarFilter>(
      CellarFilterNotifier.new,
    );

class CellarFilterNotifier extends Notifier<CellarFilter> {
  @override
  CellarFilter build() => CellarFilter.none;

  void setQuery(String query) => state = state.copyWith(query: query);

  void toggleStatus(StatusFilter status) {
    final next = {...state.statuses};
    if (!next.remove(status)) next.add(status);
    state = state.copyWith(statuses: next);
  }

  void toggleType(TypeFilter type) {
    final next = {...state.types};
    if (!next.remove(type)) next.add(type);
    state = state.copyWith(types: next);
  }

  /// The Cellar filtered by one status, from the Dashboard (BR1.17).
  void showOnly(StatusFilter status) =>
      state = CellarFilter(statuses: {status});

  /// "Clear filters" (BR1.8).
  void clear() => state = CellarFilter.none;
}

/// The History of one cellar, page by page (BR1.16; NFR5.2).
class HistoryState {
  const HistoryState({
    this.records = const [],
    this.loading = false,
    this.hasMore = true,
    this.failed = false,
  });

  final List<DrinkingRecord> records;
  final bool loading;
  final bool hasMore;

  /// The last page read failed (e.g. the index is not ready yet): the screen
  /// shows the error with "Try again".
  final bool failed;

  HistoryState copyWith({
    List<DrinkingRecord>? records,
    bool? loading,
    bool? hasMore,
    bool? failed,
  }) => HistoryState(
    records: records ?? this.records,
    loading: loading ?? this.loading,
    hasMore: hasMore ?? this.hasMore,
    failed: failed ?? this.failed,
  );
}

final historyPagerProvider = NotifierProvider.autoDispose
    .family<HistoryPager, HistoryState, String>(HistoryPager.new);

/// Loads the History 30 drinks at a time, with a cursor on `drankOn` and
/// `createdAt` (BR1.16); the next page only when asked (the list asks when
/// 5 rows are left, performance-design.md §3).
class HistoryPager extends Notifier<HistoryState> {
  HistoryPager(this.cellarId);

  static const int pageSize = 30;

  final String cellarId;
  HistoryCursor? _cursor;
  int _generation = 0;

  @override
  HistoryState build() {
    _cursor = null;
    final generation = ++_generation;
    unawaited(Future<void>.microtask(() => _load(generation)));
    return const HistoryState(loading: true);
  }

  /// The next page; nothing while one is loading or when none is left.
  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    state = state.copyWith(loading: true, failed: false);
    await _load(_generation);
  }

  /// From the first page again (after an edit, or "Try again").
  Future<void> reload() async {
    _cursor = null;
    final generation = ++_generation;
    state = const HistoryState(loading: true);
    await _load(generation);
  }

  Future<void> _load(int generation) async {
    try {
      final page = await ref
          .read(drinkingRecordRepositoryProvider)
          .pageHistory(cellarId, after: _cursor, limit: pageSize);
      if (!ref.mounted || generation != _generation) return;
      _cursor = page.cursor ?? _cursor;
      state = HistoryState(
        records: [...state.records, ...page.records],
        hasMore: page.hasMore,
      );
    } catch (error, stack) {
      if (!ref.mounted || generation != _generation) return;
      state = state.copyWith(loading: false, failed: true);
      await ref
          .read(errorReporterProvider)
          .report(error, stack, reason: CellarErrorReasons.historyFailed);
    }
  }
}

/// Suggestions while typing the name (BR1.1; NFR1.2).
class SuggestionsState {
  const SuggestionsState({this.query = '', this.suggestions = const []});

  static const SuggestionsState empty = SuggestionsState();

  final String query;
  final List<WineCandidate> suggestions;
}

final wineSuggestionsProvider =
    NotifierProvider.autoDispose<WineSuggestions, SuggestionsState>(
      WineSuggestions.new,
    );

/// From the third character, 250 ms after the last key (NFR1.2): the
/// internal and cellar suggestions of U3 at once; the Open Food Facts ones
/// after the 600 ms pause U3 asks for, added when they arrive. A catalog
/// error gives no suggestion, never an error on screen.
class WineSuggestions extends Notifier<SuggestionsState> {
  static const Duration internalDelay = Duration(milliseconds: 250);
  static const Duration externalDelay = Duration(milliseconds: 600);
  static const int minLength = 3;

  Timer? _internal;
  Timer? _external;
  int _generation = 0;
  late WineCatalog _catalog;

  @override
  SuggestionsState build() {
    _catalog = ref.watch(catalogProvider);
    ref.onDispose(_cancel);
    return SuggestionsState.empty;
  }

  void update(
    String query, {
    List<CellarWineRef> cellarWines = const [],
    CatalogLocale locale = CatalogLocale.en,
  }) {
    _cancel();
    final generation = ++_generation;
    if (query.trim().length < minLength) {
      state = SuggestionsState.empty;
      return;
    }
    _internal = Timer(internalDelay, () {
      if (generation != _generation) return;
      state = SuggestionsState(
        query: query,
        suggestions: _internalOf(query, locale, cellarWines),
      );
    });
    _external = Timer(externalDelay, () async {
      final result = await _externalOf(query, locale);
      if (!ref.mounted || generation != _generation || result.isEmpty) return;
      final known = state.suggestions;
      state = SuggestionsState(
        query: query,
        suggestions: [
          ...known,
          for (final candidate in result)
            if (!known.any((k) => _same(k, candidate))) candidate,
        ].take(10).toList(),
      );
    });
  }

  /// Forget the suggestions (a proposal was chosen).
  void clear() {
    _cancel();
    _generation++;
    state = SuggestionsState.empty;
  }

  List<WineCandidate> _internalOf(
    String query,
    CatalogLocale locale,
    List<CellarWineRef> cellarWines,
  ) {
    try {
      return _catalog
          .suggestWines(query, locale: locale, cellarWines: cellarWines)
          .suggestions;
    } on CatalogArgumentError {
      return const [];
    }
  }

  Future<List<WineCandidate>> _externalOf(
    String query,
    CatalogLocale locale,
  ) async {
    try {
      return (await _catalog.suggestExternal(
        query,
        locale: locale,
      )).suggestions;
    } on CatalogArgumentError {
      return const [];
    }
  }

  static bool _same(WineCandidate a, WineCandidate b) =>
      a.name.toLowerCase() == b.name.toLowerCase() &&
      (a.producer ?? '').toLowerCase() == (b.producer ?? '').toLowerCase() &&
      a.vintage == b.vintage;

  void _cancel() {
    _internal?.cancel();
    _external?.cancel();
  }
}
