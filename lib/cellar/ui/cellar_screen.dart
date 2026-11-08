import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../account/ui/profile_screen.dart';
import '../../app/providers.dart';
import '../../app/ui/about_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/sharing_providers.dart';
import '../../sharing/ui/cellar_switcher.dart';
import '../../sharing/ui/sharing_screen.dart';
import '../../sync/ui/offline_banner.dart';
import '../../sync/ui/rejected_wine_notice.dart';
import '../../dashboard/today_provider.dart';
import '../../sharing/domain/membership.dart';
import '../cellar_providers.dart';
import '../data/wine_repository.dart';
import '../domain/cellar_filter.dart';
import '../domain/wine.dart';
import 'add_wine_screen.dart';
import 'archived_wines_screen.dart';
import 'drink_flow.dart';
import 'wine_detail_screen.dart';
import 'wine_card.dart';
import 'wine_labels.dart';

/// Whether the personal cellar is ready (BR1.3).
enum CellarSetup { preparing, ready, failed }

/// M3 — the cellar (US2.1, US3.1, US3.2, US9.1; U1 BR1.3, BR2.4, BR3.2;
/// u4-cellar BR1.7, BR1.8, BR1.10).
///
/// Since u4-cellar the list shows only the wines still in the cellar
/// (`quantity > 0`), with search and filters in memory, the status of each
/// wine as icon and text, the confidence and, with `canEdit`, the quick
/// "Drunk". A row opens the detail; "Drunk" in the menu opens the finished
/// wines. With no wine and data not only from the cache, the invitation to
/// add the first wine.
///
/// States: loading, "Could not prepare the cellar" with "Try again", empty,
/// list. While the cellar is prepared no Firestore listener is open. "Add"
/// stays disabled until the cellar document exists. An error of
/// the cellar or wines listener shows the same error; "Try again" checks the
/// cellar again and reopens both listeners (AccountGate.retryCellar).
class CellarScreen extends ConsumerWidget {
  const CellarScreen({
    super.key,
    required this.user,
    required this.setup,
    required this.onRetrySetup,
    this.onAdd,
  });

  final AppUser user;
  final CellarSetup setup;
  final Future<void> Function() onRetrySetup;

  /// "Aggiungi" when the shell routes it elsewhere (u6-label-recognition
  /// BR1.1: the three ways to add); without it the form opens, as before.
  final void Function(AccessibleCellar cellar, List<Wine> wines)? onAdd;

  void _openForm(
    BuildContext context,
    AccessibleCellar cellar, {
    String? name,
    List<Wine> wines = const [],
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddWineScreen(
          user: user,
          cellarId: cellar.cellarId,
          cellar: cellar,
          initialName: name,
          cellarWines: wines,
        ),
      ),
    );
  }

  void _openArchive(BuildContext context, AccessibleCellar cellar) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArchivedWinesScreen(user: user, cellar: cellar),
      ),
    );
  }

  void _openPeople(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => SharingScreen(user: user)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // The active cellar (u7-sharing BR1.5): the personal one, whose id is the
    // uid, unless the user picked a shared one. Its permission decides the
    // commands (BR1.6): "read" hides "Add".
    final active = ref.watch(activeCellarProvider(user));
    final cellarId = active.cellarId;
    // No Firestore listener while the cellar is prepared (W1.6,
    // security-design.md §6): on a first sign-in `cellars/{uid}` may not
    // exist yet, the wines rule reads it and denies, and a listener closed
    // by that error would still show it once the cellar is ready. Leaving
    // the providers unwatched also disposes listeners left over from before
    // a "Try again", so the next state opens fresh ones.
    final preparing = setup == CellarSetup.preparing;
    final cellar = preparing ? null : ref.watch(cellarStreamProvider(cellarId));
    final wines = setup == CellarSetup.ready
        ? ref.watch(winesStreamProvider(cellarId))
        : null;
    // A listener closed by an error (e.g. permission-denied) is the same
    // failure as a failed setup: error with "Try again" (BR1.3, §8).
    final listenerFailed =
        (cellar?.hasError ?? false) || (wines?.hasError ?? false);
    final canAdd =
        setup == CellarSetup.ready &&
        !listenerFailed &&
        cellar?.value?.cellar != null;

    final loaded = wines?.value?.wines ?? const <Wine>[];
    // ux-redesign: "Add" is a floating button. The cellar has its own
    // messenger, so the "Drink recorded" message is laid out above the
    // button instead of covering it (first-version feedback).
    return ScaffoldMessenger(
      child: Scaffold(
        key: const Key('cellar-screen'),
        appBar: AppBar(
          title: Text(l10n.cellarTitle),
          actions: [
            _CellarMenu(
              onProfile: () => ProfileScreen.open(context, user),
              onPeople: () => _openPeople(context),
              onArchive: setup == CellarSetup.ready
                  ? () => _openArchive(context, active)
                  : null,
              onAbout: () => AboutScreen.open(context),
            ),
          ],
        ),
        body: Column(
          children: [
            CellarSwitcher(user: user),
            // The banner derives from both listeners (syncStatusProvider).
            if (!preparing) OfflineBanner(cellarId: cellarId),
            RejectedWineNotices(
              uid: user.uid,
              onAddAgain: (name) => _openForm(context, active, name: name),
            ),
            Expanded(child: _content(l10n, wines, listenerFailed, active)),
          ],
        ),
        floatingActionButton: active.canEdit
            ? _AddButton(
                label: l10n.addWine,
                onPressed: canAdd
                    ? () => onAdd != null
                          ? onAdd!(active, loaded)
                          : _openForm(context, active, wines: loaded)
                    : null,
              )
            : null,
      ),
    );
  }

  /// "Try again" always goes through [onRetrySetup] (AccountGate.retryCellar),
  /// which checks the cellar again and then reopens both listeners.
  Widget _content(
    AppLocalizations l10n,
    AsyncValue<WinesSnapshot>? wines,
    bool listenerFailed,
    AccessibleCellar active,
  ) {
    if (setup == CellarSetup.preparing) {
      return _Loading(label: l10n.cellarLoading);
    }
    if (setup == CellarSetup.failed || listenerFailed) {
      return _CellarError(
        message: l10n.cellarSetupFailed,
        onRetry: onRetrySetup,
      );
    }
    // Ready: the wines listener is open (loading until its first snapshot).
    return switch (wines) {
      AsyncData(:final value) => _WineList(
        snapshot: value,
        user: user,
        cellar: active,
      ),
      _ => _Loading(label: l10n.cellarLoading),
    };
  }
}

/// "Add" as an extended floating button (ux-redesign interaction-spec.md);
/// disabled, in the disabled colors, until the cellar is ready.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    return FloatingActionButton.extended(
      key: const Key('cellar-add-button'),
      onPressed: onPressed,
      backgroundColor: enabled ? null : scheme.surfaceContainerHighest,
      foregroundColor: enabled ? null : scheme.onSurfaceVariant,
      icon: const Icon(Icons.add),
      label: Text(label),
    );
  }
}

/// The cellar menu (u7-sharing frontend-components.md): "People" for
/// everyone, and since u4-cellar "Drunk", the finished wines (BR1.7).
/// Renaming is the owner's only, and the app has no rename command yet.
/// Since u8-account it also opens the profile (BR1.2).
class _CellarMenu extends StatelessWidget {
  const _CellarMenu({
    required this.onProfile,
    required this.onPeople,
    required this.onAbout,
    this.onArchive,
  });

  final VoidCallback onProfile;
  final VoidCallback onPeople;
  final VoidCallback? onArchive;

  /// "Informazioni" (label-recognition BR6.3), always last.
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<void>(
      key: const Key('cellar-menu'),
      tooltip: l10n.cellarMenu,
      itemBuilder: (_) => [
        PopupMenuItem<void>(
          key: const Key('cellar-menu-profile'),
          onTap: onProfile,
          child: Text(l10n.profileTitle),
        ),
        PopupMenuItem<void>(
          key: const Key('cellar-menu-people'),
          onTap: onPeople,
          child: Text(l10n.sharingPeopleTitle),
        ),
        if (onArchive != null)
          PopupMenuItem<void>(
            key: const Key('cellar-archive'),
            onTap: onArchive,
            child: Text(l10n.cellarArchiveTitle),
          ),
        PopupMenuItem<void>(
          key: const Key('cellar-menu-about'),
          onTap: onAbout,
          child: Text(l10n.aboutTitle),
        ),
      ],
    );
  }
}

/// Search, filters and the wines still in the cellar (BR1.7, BR1.8).
class _WineList extends ConsumerStatefulWidget {
  const _WineList({
    required this.snapshot,
    required this.user,
    required this.cellar,
  });

  final WinesSnapshot snapshot;
  final AppUser user;
  final AccessibleCellar cellar;

  @override
  ConsumerState<_WineList> createState() => _WineListState();
}

class _WineListState extends ConsumerState<_WineList> {
  /// How long an empty list read only from the cache waits for the server
  /// before showing the invitation (review R-03).
  static const Duration cacheOnlyGrace = Duration(seconds: 2);

  late final TextEditingController _search;
  Timer? _cacheOnlyTimer;
  bool _cacheOnlyWaitOver = false;

  bool get _emptyFromCache =>
      widget.snapshot.wines.isEmpty && widget.snapshot.meta.isFromCache;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: ref.read(cellarFilterProvider).query);
    _followCacheOnlyEmpty();
  }

  @override
  void didUpdateWidget(_WineList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _followCacheOnlyEmpty();
  }

  /// An empty list from the cache only waits [cacheOnlyGrace] for the
  /// server; offline no server snapshot comes, so the invitation shows
  /// after the wait instead of an endless "loading".
  void _followCacheOnlyEmpty() {
    if (!_emptyFromCache) {
      _cacheOnlyTimer?.cancel();
      _cacheOnlyTimer = null;
      _cacheOnlyWaitOver = false;
      return;
    }
    if (_cacheOnlyWaitOver || _cacheOnlyTimer != null) return;
    _cacheOnlyTimer = Timer(cacheOnlyGrace, () {
      if (mounted) setState(() => _cacheOnlyWaitOver = true);
    });
  }

  @override
  void dispose() {
    _cacheOnlyTimer?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _open(Wine wine) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => WineDetailScreen(
        user: widget.user,
        cellar: widget.cellar,
        wineId: wine.id,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = widget.snapshot;
    if (snapshot.wines.isEmpty) {
      // The first snapshot from the cache may still be empty: for a short
      // while the same "syncing" text as the Dashboard (BR1.7); then, also
      // offline, the invitation (R-03). "Add" stays in the bottom bar.
      if (_emptyFromCache && !_cacheOnlyWaitOver) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.dashboardSyncing,
              key: const Key('cellar-syncing'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.cellarEmpty,
            key: const Key('cellar-empty'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }
    final filter = ref.watch(cellarFilterProvider);
    if (_search.text != filter.query) _search.text = filter.query;
    final today = ref.watch(todayProvider);
    // Statuses of the day, once per list (performance-design.md §2).
    final statuses = statusIndexOf(snapshot.wines, today);
    final shown = filter.apply(snapshot.wines, today, statusIndex: statuses);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            key: const Key('cellar-search'),
            controller: _search,
            onChanged: ref.read(cellarFilterProvider.notifier).setQuery,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.cellarSearchHint,
              labelText: l10n.cellarSearchHint,
            ),
          ),
        ),
        _FilterBar(filter: filter),
        Expanded(
          child: shown.isEmpty
              ? _NoMatches(
                  onClear: () {
                    _search.clear();
                    ref.read(cellarFilterProvider.notifier).clear();
                  },
                )
              // Lazy list (NFR2.2); rows rebuild only when their wine changes.
              : ListView.builder(
                  key: const Key('cellar-wine-list'),
                  // Room under the last card for the floating "Add".
                  padding: const EdgeInsets.only(top: 4, bottom: 96),
                  itemCount: shown.length,
                  itemBuilder: (context, index) {
                    final wine = shown[index];
                    return WineCard(
                      key: ValueKey(wine.id),
                      wine: wine,
                      status: statuses[wine.id],
                      onTap: () => _open(wine),
                      onDrink: widget.cellar.canEdit
                          ? () => drinkWithUndo(
                              context,
                              ref,
                              user: widget.user,
                              cellar: widget.cellar,
                              wine: wine,
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Status and type filters, combinable (BR1.8).
class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter});

  final CellarFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(cellarFilterProvider.notifier);
    Widget row(String title, List<Widget> chips) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: 8),
          for (final chip in chips)
            Padding(padding: const EdgeInsets.only(right: 8), child: chip),
        ],
      ),
    );
    return Column(
      children: [
        row(l10n.cellarFilterStatus, [
          for (final status in StatusFilter.values)
            FilterChip(
              key: Key('cellar-filter-status-${status.name}'),
              avatar: Icon(statusFilterIcon(status), size: 18),
              label: Text(statusFilterLabel(l10n, status)),
              selected: filter.statuses.contains(status),
              onSelected: (_) => notifier.toggleStatus(status),
            ),
        ]),
        row(l10n.cellarFilterType, [
          for (final type in TypeFilter.values)
            FilterChip(
              key: Key('cellar-filter-type-${type.name}'),
              label: Text(typeFilterLabel(l10n, type)),
              selected: filter.types.contains(type),
              onSelected: (_) => notifier.toggleType(type),
            ),
        ]),
      ],
    );
  }
}

/// "No wine with these filters" with "Clear filters" (BR1.8).
class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.cellarNoMatches,
              key: const Key('cellar-no-matches'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              key: const Key('cellar-clear-filters'),
              onPressed: onClear,
              child: Text(l10n.cellarClearFilters),
            ),
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: CircularProgressIndicator(
      key: const Key('cellar-loading'),
      semanticsLabel: label,
    ),
  );
}

class _CellarError extends StatelessWidget {
  const _CellarError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                key: const Key('cellar-error'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('cellar-retry-button'),
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}
