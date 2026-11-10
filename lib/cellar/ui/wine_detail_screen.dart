import 'dart:async';

import 'package:estimation/estimation.dart'
    show DrinkingWindow, WineStyle, WineType, statusOf;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../dashboard/today_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/ui/capacity_limit_sheet.dart';
import '../../sharing/domain/membership.dart';
import '../../app/theme.dart';
import '../../app/ui/country_flag.dart';
import '../cellar_providers.dart';
import '../domain/cellar_filter.dart';
import '../domain/drinking_record.dart';
import '../domain/quantity_delta.dart';
import '../domain/style_notice.dart';
import '../domain/window_adjuster.dart';
import '../domain/wine.dart';
import '../domain/wine_estimate.dart';
import '../domain/wine_origins.dart';
import '../wine_estimator.dart';
import 'add_wine_screen.dart';
import 'cellar_dialogs.dart';
import 'drink_flow.dart';
import 'drinking_record_sheet.dart';
import 'duplicate_banner.dart';
import 'edit_wine_screen.dart';
import 'ideal_moment_card.dart';
import 'style_widgets.dart';
import 'window_card.dart';
import 'window_override_widgets.dart';
import 'wine_badges.dart';
import 'wine_card.dart' show drinkActionIcon;
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
    // A short page: every part is built, so its commands always exist.
    return SingleChildScrollView(
      key: const Key('wine-detail-scroll'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailHero(wine: wine, status: _statusOf(estimate, today)),
          const SizedBox(height: 8),
          DuplicateBanner(
            user: widget.user,
            cellar: cellar,
            wine: wine,
            onMerged: (kept) {
              if (kept.id != wine.id && mounted) Navigator.of(context).pop();
            },
          ),
          if (styleToConfirmOf(
                wine,
                window: estimate.window,
                fallbackYear: today.year,
              ) ||
              needsStyleToEstimate(wine)) ...[
            const StyleToConfirmBanner(),
            if (cellar.canEdit) _styleChooser(context, wine),
            const SizedBox(height: 8),
          ],
          IdealMomentCard(
            estimate: estimate,
            today: today,
            windowOverride: wine.windowOverride,
            level: wine.level,
            onCorrect: cellar.canEdit && estimate.window != null
                ? () => _correct(wine, estimate)
                : null,
            onRestore: cellar.canEdit ? () => _restore(wine, estimate) : null,
          ),
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
      ),
    );
  }

  /// S4 (F5): the type when it is missing, else the style chips; a tap
  /// saves at once and the new estimate is announced (R-08).
  Widget _styleChooser(BuildContext context, Wine wine) {
    final l10n = AppLocalizations.of(context);
    final type = WineType.tryParse(wine.wineType);
    if (type == null) {
      return Padding(
        key: const Key('detail-type-chooser'),
        padding: const EdgeInsets.only(top: 8),
        child: DropdownButtonFormField<WineType>(
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.chooseTypePrompt),
          items: [
            for (final value in WineType.values)
              DropdownMenuItem(
                value: value,
                child: Text(wineTypeLabel(l10n, value)),
              ),
          ],
          onChanged: (value) {
            if (value != null) _saveStyle(wine, wineType: value);
          },
        ),
      );
    }
    return StyleField(
      wineType: type,
      selected: wine.style,
      suggested: wine.styleSource == FieldSource.auto,
      onChanged: (style) => _saveStyle(wine, style: style),
    );
  }

  Future<void> _saveStyle(
    Wine wine, {
    WineType? wineType,
    WineStyle? style,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final view = View.of(context);
    final direction = Directionality.of(context);
    final saved = await ref
        .read(cellarActionsProvider)
        .chooseStyle(
          cellar: widget.cellar,
          user: widget.user,
          wine: wine,
          wineType: wineType,
          style: style,
        );
    if (!mounted) return;
    if (!saved) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      return;
    }
    SemanticsService.sendAnnouncement(
      view,
      l10n.estimateUpdatedAnnouncement(
        style == null
            ? wineTypeLabel(l10n, wineType!)
            : styleLabel(l10n, style),
      ),
      direction,
    );
  }

  static StatusFilter _statusOf(WineEstimate estimate, DateTime today) {
    final window = estimate.window;
    if (window == null) return StatusFilter.toEstimate;
    try {
      return StatusFilter.of(statusOf(window, today));
    } on Object {
      return StatusFilter.toEstimate;
    }
  }

  /// The window with the drink feedback and without the owner's correction.
  static DrinkingWindow? _estimatedOf(WineEstimate estimate) {
    final base = estimate.baseWindow;
    if (base == null) return estimate.window;
    return WindowAdjuster.effective(base, estimate.adjustment);
  }

  /// "Correct" (FR5.1, BR4.6): the sheet of years, then one write.
  Future<void> _correct(Wine wine, WineEstimate estimate) async {
    final window = estimate.window;
    final estimated = _estimatedOf(estimate) ?? window;
    if (window == null || estimated == null) return;
    final picked = await CorrectEndYearSheet.show(
      context,
      startYear: estimated.startYear,
      peakYear: estimated.peakYear,
      currentEnd: window.endYear,
      inMonths: estimated.inMonths,
      startMonth: estimated.startMonth,
      currentEndMonth: window.endMonth,
    );
    if (picked == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final saved = await ref
        .read(cellarActionsProvider)
        .setOverride(
          cellar: widget.cellar,
          user: widget.user,
          wine: wine,
          endYear: picked.year,
          endMonth: picked.month,
        );
    messenger.showSnackBar(
      SnackBar(content: Text(saved ? l10n.overrideSaved : l10n.saveFailed)),
    );
  }

  /// "Restore the estimate" (FR5.4): confirmation, then one write.
  Future<void> _restore(Wine wine, WineEstimate estimate) async {
    final estimated = _estimatedOf(estimate);
    if (estimated == null) return;
    final l10nBefore = AppLocalizations.of(context);
    final end =
        windowDates(context, estimated).end ?? l10nBefore.windowNoEndShort;
    if (!await RestoreEstimateDialog.show(context, end)) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final restored = await ref
        .read(cellarActionsProvider)
        .restoreEstimate(cellar: widget.cellar, user: widget.user, wine: wine);
    messenger.showSnackBar(
      SnackBar(
        content: Text(restored ? l10n.overrideRestored : l10n.saveFailed),
      ),
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

  /// FR2.4: "Remove a bottle without a drink" asks first, then removes it.
  Future<void> _removeWithoutDrink(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(cellarActionsProvider);
    if (!await RemoveBottleDialog.show(context, wine.name)) return;
    await actions.removeBottle(cellar: cellar, user: user, wine: wine);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canDrink =
        cellar.canEdit && QuantityDelta.canDecrease(wine.storedQuantity);
    final actions = ref.read(cellarActionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(l10n.quantityLabel, style: theme.textTheme.titleSmall),
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
                    ? () async {
                        // freemium-plus FR2.5: a finished wine coming back
                        // takes a place of the free plan.
                        if (wine.storedQuantity <= 0 &&
                            !await ensureCapacity(
                              context,
                              ref,
                              user: user,
                              cellar: cellar,
                            )) {
                          return;
                        }
                        await actions.addBottles(
                          cellar: cellar,
                          user: user,
                          wine: wine,
                          n: 1,
                        );
                      }
                    : null,
                icon: const Icon(Icons.add),
              ),
          ],
        ),
        if (cellar.canEdit) ...[
          const SizedBox(height: 8),
          // FR2.1: the main button, with the verb and the glasses icon.
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
            icon: const Icon(drinkActionIcon),
            label: Text(l10n.uxDrinkActionDetail),
          ),
          const SizedBox(height: 8),
          // FR2.4: explicit label, and a confirmation.
          OutlinedButton(
            key: const Key('wine-minus'),
            onPressed: canDrink
                ? () => _removeWithoutDrink(context, ref)
                : null,
            child: Text(l10n.uxRemoveBottle, textAlign: TextAlign.center),
          ),
        ],
      ],
    );
  }
}

/// The top of the detail (FR1.4): the band of the type color, the big flag,
/// name and vintage, "producer · region, country · type", the status chip
/// and the bottles.
class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.wine, required this.status});

  final Wine wine;
  final StatusFilter status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final country = WineOrigins.country(wine.displayCountry);
    final region = wine.region;
    final family = WineTypeFamily.of(wine.wineType);
    final place = [
      if (region != null)
        WineOrigins.regionDisplayName(country?.code, region, language),
      ?country?.nameIn(language),
    ].join(', ');
    final meta = [
      ?wine.producer,
      ?wine.denomination,
      if (place.isNotEmpty) place,
      if (family != null) wineFamilyLabel(l10n, family),
    ].join(' · ');
    return Card(
      key: const Key('wine-detail-hero'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 10,
            color: wineFamilyColor(WineTypeColors.of(context), family),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (country != null)
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: CountryFlag(code: country.code, size: 30),
                  ),
                const SizedBox(height: 6),
                Text(
                  '${wine.name} ${vintageText(l10n, wine.vintage)}',
                  key: const Key('wine-detail-name'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                if (meta.isNotEmpty)
                  Text(
                    meta,
                    key: const Key('wine-detail-meta'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StateChip(status: status),
                    Semantics(
                      label: l10n.bottleCount(wine.quantity),
                      excludeSemantics: true,
                      child: Text(
                        '× ${wine.quantity}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
/// it?" (BR1.16). With the [wine] still in the cellar (ux-redesign plan,
/// review Major 3) also its flag and type family; a drink stores neither,
/// so without it the row stays as before.
class DrinkRecordTile extends StatelessWidget {
  const DrinkRecordTile({
    super.key,
    required this.record,
    this.onTap,
    this.trailing,
    this.wine,
  });

  final DrinkingRecord record;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Wine? wine;

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
    final wine = this.wine;
    final country = wine?.displayCountry;
    final hasFamily = WineTypeFamily.of(wine?.wineType) != null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: country == null ? null : CountryFlag(code: country, size: 24),
      title: Text('${record.wineName} ${vintageText(l10n, record.vintage)}'),
      subtitle: hasFamily
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lines.join('\n')),
                const SizedBox(height: 2),
                WineTypeBadge(wineType: wine!.wineType),
              ],
            )
          : Text(lines.join('\n')),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
