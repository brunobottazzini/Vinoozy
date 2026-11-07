import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../dashboard/today_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/domain/membership.dart';
import '../cellar_providers.dart';
import '../domain/drinking_record.dart';
import '../domain/quantity_delta.dart';
import '../domain/wine.dart';
import '../wine_estimator.dart';
import 'add_wine_screen.dart';
import 'cellar_dialogs.dart';
import 'drink_flow.dart';
import 'drinking_record_sheet.dart';
import 'duplicate_banner.dart';
import 'edit_wine_screen.dart';
import 'window_card.dart';
import 'wine_labels.dart';

/// The detail of a wine (BR1.9-BR1.11, BR1.14, BR1.19, BR1.20; NFR2.2).
///
/// A wine still in the cellar comes from the list already loaded (no read);
/// a finished one, or one opened from the Dashboard or the History, from one
/// document listener. Commands follow the permission: "read" sees only;
/// "edit" drinks, changes the quantity and edits; the owner also deletes.
/// A wine without a stored estimate shows one computed in memory, never
/// written by a reader (BR1.19).
class WineDetailScreen extends ConsumerStatefulWidget {
  const WineDetailScreen({
    super.key,
    required this.user,
    required this.cellar,
    required this.wineId,
  });

  final AppUser user;
  final AccessibleCellar cellar;
  final String wineId;

  @override
  ConsumerState<WineDetailScreen> createState() => _WineDetailScreenState();
}

class _WineDetailScreenState extends ConsumerState<WineDetailScreen> {
  Wine? _last;

  WineKey get _key => (cellarId: widget.cellar.cellarId, wineId: widget.wineId);

  /// The listed wine, else the single document; the last known one while
  /// switching between the two (a wine drunk to 0 leaves the list).
  ({Wine? wine, bool loading, bool failed}) _watchWine() {
    final list = ref.watch(winesStreamProvider(widget.cellar.cellarId));
    final listed = list.value?.wines
        .where((wine) => wine.id == widget.wineId)
        .firstOrNull;
    if (listed != null) {
      return (wine: _last = listed, loading: false, failed: false);
    }
    // The list is still loading: no document read until it says the wine
    // is not there (NFR2.2, NFR5.1).
    if (!list.hasValue && !list.hasError) {
      return (wine: _last, loading: _last == null, failed: false);
    }
    final single = ref.watch(wineProvider(_key));
    return switch (single) {
      AsyncData(:final value) => (
        wine: _last = value,
        loading: false,
        failed: false,
      ),
      AsyncError() => (wine: _last, loading: false, failed: _last == null),
      _ => (wine: _last, loading: _last == null, failed: false),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = _watchWine();
    final wine = state.wine;
    return Scaffold(
      key: const Key('wine-detail'),
      appBar: AppBar(title: Text(wine?.name ?? '')),
      body: switch (state) {
        (loading: true, wine: _, failed: _) => const Center(
          child: CircularProgressIndicator(key: Key('wine-detail-loading')),
        ),
        (failed: true, wine: _, loading: _) => Center(
          child: Text(l10n.wineLoadFailed, key: const Key('wine-detail-error')),
        ),
        (wine: null, loading: _, failed: _) => Center(
          child: Text(l10n.wineNotFound, key: const Key('wine-detail-gone')),
        ),
        (wine: final Wine wine, loading: _, failed: _) => _body(context, wine),
      },
    );
  }

  Widget _body(BuildContext context, Wine wine) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cellar = widget.cellar;
    final today = ref.watch(todayProvider);
    final estimate = const WineEstimator().displayed(
      wine,
      fallbackYear: today.year,
    );
    final details = [
      ?wine.producer,
      vintageText(l10n, wine.vintage),
      ?wine.denomination,
      ?wine.region,
    ].join(' · ');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(details, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        DuplicateBanner(
          user: widget.user,
          cellar: cellar,
          wine: wine,
          onMerged: (kept) {
            if (kept.id != wine.id && mounted) Navigator.of(context).pop();
          },
        ),
        WindowCard(estimate: estimate, today: today),
        if (estimate.pairings != null)
          PairingsCard(pairings: estimate.pairings!),
        const SizedBox(height: 8),
        _QuantityRow(wine: wine, cellar: cellar, user: widget.user),
        if (wine.quantity == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.wineFinished, key: const Key('wine-finished')),
          ),
        const SizedBox(height: 8),
        _Commands(
          wine: wine,
          cellar: cellar,
          user: widget.user,
          onDelete: () => _delete(wine),
        ),
        const SizedBox(height: 16),
        Text(l10n.recentDrinksTitle, style: theme.textTheme.titleMedium),
        _RecentDrinks(user: widget.user, cellar: cellar, wine: wine),
      ],
    );
  }

  Future<void> _delete(Wine wine) async {
    if (!await DeleteWineDialog.show(context, wine.name)) return;
    if (!mounted) return;
    final actions = ref.read(cellarActionsProvider);
    final container = ProviderScope.containerOf(context, listen: false);
    final cellarId = widget.cellar.cellarId;
    Navigator.of(context).pop();
    // The wine leaves the list at once on the phone; a failure later shows
    // its notice from the app root (CellarNotice). Then the History drops
    // the drinks of the deleted wine (R-01).
    unawaited(
      actions
          .deleteWine(cellar: widget.cellar, user: widget.user, wine: wine)
          .then(
            (_) => invalidateDrinkReads(
              container,
              cellarId: cellarId,
              wineIds: [wine.id],
            ),
          ),
    );
  }
}

class _QuantityRow extends ConsumerWidget {
  const _QuantityRow({
    required this.wine,
    required this.cellar,
    required this.user,
  });

  final Wine wine;
  final AccessibleCellar cellar;
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canDrink =
        cellar.canEdit && QuantityDelta.canDecrease(wine.storedQuantity);
    final actions = ref.read(cellarActionsProvider);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (cellar.canEdit)
          IconButton(
            key: const Key('wine-minus'),
            tooltip: l10n.decreaseQuantity,
            onPressed: canDrink
                ? () => actions.removeBottle(
                    cellar: cellar,
                    user: user,
                    wine: wine,
                  )
                : null,
            icon: const Icon(Icons.remove),
          ),
        Semantics(
          label: l10n.bottleCount(wine.quantity),
          excludeSemantics: true,
          child: Text(
            '${wine.quantity}',
            key: const Key('wine-quantity'),
            style: theme.textTheme.headlineSmall,
          ),
        ),
        if (cellar.canEdit)
          IconButton(
            key: const Key('wine-plus'),
            tooltip: l10n.increaseQuantity,
            // Off at 99 bottles (BR1.3 cap, review R-05).
            onPressed: QuantityDelta.canIncrease(wine.storedQuantity, 1)
                ? () => actions.addBottles(
                    cellar: cellar,
                    user: user,
                    wine: wine,
                    n: 1,
                  )
                : null,
            icon: const Icon(Icons.add),
          ),
        if (cellar.canEdit)
          FilledButton.icon(
            key: const Key('wine-drink'),
            onPressed: canDrink
                ? () => drinkWithUndo(
                    context,
                    ref,
                    user: user,
                    cellar: cellar,
                    wine: wine,
                  )
                : null,
            icon: const Icon(Icons.wine_bar),
            label: Text(l10n.wineDrink),
          ),
      ],
    );
  }
}

class _Commands extends StatelessWidget {
  const _Commands({
    required this.wine,
    required this.cellar,
    required this.user,
    required this.onDelete,
  });

  final Wine wine;
  final AccessibleCellar cellar;
  final AppUser user;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!cellar.canEdit) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (wine.quantity == 0)
          OutlinedButton.icon(
            key: const Key('wine-add-again'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddWineScreen(
                  user: user,
                  cellarId: cellar.cellarId,
                  cellar: cellar,
                  prefill: wine,
                ),
              ),
            ),
            icon: const Icon(Icons.replay),
            label: Text(l10n.addAgain),
          ),
        OutlinedButton.icon(
          key: const Key('wine-edit'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  EditWineScreen(user: user, cellar: cellar, wine: wine),
            ),
          ),
          icon: const Icon(Icons.edit),
          label: Text(l10n.wineEdit),
        ),
        if (cellar.isOwner)
          OutlinedButton.icon(
            key: const Key('wine-delete'),
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.wineDelete),
          ),
      ],
    );
  }
}

class _RecentDrinks extends ConsumerWidget {
  const _RecentDrinks({
    required this.user,
    required this.cellar,
    required this.wine,
  });

  final AppUser user;
  final AccessibleCellar cellar;
  final Wine wine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final drinks =
        ref
            .watch(
              recentDrinksProvider((
                cellarId: cellar.cellarId,
                wineId: wine.id,
              )),
            )
            .value ??
        const <DrinkingRecord>[];
    if (drinks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(l10n.noDrinksYet, key: const Key('wine-no-drinks')),
      );
    }
    return Column(
      key: const Key('wine-recent-drinks'),
      children: [
        for (final record in drinks)
          DrinkRecordTile(
            key: Key('wine-drink-${record.id}'),
            record: record,
            onTap: DrinkingRecordSheet.canChange(cellar, user, record)
                ? () => DrinkingRecordSheet.show(
                    context,
                    user: user,
                    cellar: cellar,
                    record: record,
                    wine: wine,
                  )
                : null,
          ),
      ],
    );
  }
}

/// A drink: name and vintage of the time, date, rating, notes and "How was
/// it?" (BR1.16).
class DrinkRecordTile extends StatelessWidget {
  const DrinkRecordTile({
    super.key,
    required this.record,
    this.onTap,
    this.trailing,
  });

  final DrinkingRecord record;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rating = record.rating;
    final condition = record.condition;
    final lines = [
      l10n.drankOnLabel(formatDay(context, record.drankOn)),
      if (rating != null) l10n.ratingStar(rating),
      if (condition != null) conditionLabel(l10n, condition),
      ?record.notes,
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${record.wineName} ${vintageText(l10n, record.vintage)}'),
      subtitle: Text(lines.join('\n')),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
