import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

import '../../app/ui/country_flag.dart';
import '../../cellar/ui/wine_labels.dart' show formatMonthShort;
import '../../l10n/app_localizations.dart';
import '../domain/dashboard_summary.dart';
import 'status_icons.dart';

/// "Drink soon": up to 10 wines, or "No bottles due soon" (BR1.3).
///
/// A row opens the wine ([onOpenWine]); "See all (N)" opens the cellar on
/// the drink-soon status when there are more wines than rows.
class DrinkSoonSection extends StatelessWidget {
  const DrinkSoonSection({
    super.key,
    required this.rows,
    required this.total,
    required this.onOpenWine,
    required this.onOpenStatus,
  });

  final List<DrinkSoonRow> rows;
  final int total;
  final void Function(String wineId) onOpenWine;
  final void Function(WineStatus status) onOpenStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      key: const Key('dashboard-drink-soon'),
      container: true,
      label: l10n.drinkSoonTitle,
      // ux-redesign mockup 6: "Drink soon" is a card of compact rows with
      // the flags (review R-06 of the mockups).
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: _content(l10n, theme),
        ),
      ),
    );
  }

  Widget _content(AppLocalizations l10n, ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(l10n.drinkSoonTitle, style: theme.textTheme.titleLarge),
        ),
      ),
      if (rows.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            l10n.drinkSoonEmpty,
            key: const Key('drink-soon-empty'),
            style: theme.textTheme.bodyLarge,
          ),
        ),
      for (final row in rows)
        _DrinkSoonTile(row: row, onTap: () => onOpenWine(row.wineId)),
      if (total > rows.length)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            key: const Key('drink-soon-all'),
            onPressed: () => onOpenStatus(WineStatus.drinkSoon),
            child: Text(l10n.drinkSoonSeeAll(total)),
          ),
        ),
    ],
  );
}

class _DrinkSoonTile extends StatelessWidget {
  const _DrinkSoonTile({required this.row, required this.onTap});

  final DrinkSoonRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final details = [
      row.vintage?.toString() ?? l10n.noVintage,
      ?row.producer,
      l10n.bottleCount(row.quantity),
      // wine-style-profiles BR6.7: "by Mar 2027" for a window in months.
      if (row.endMonth case final month?)
        l10n.windowDrinkWithin(formatMonthShort(context, row.endYear, month))
      else
        l10n.drinkSoonUntil('${row.endYear}'),
    ];
    final country = row.country;
    return ListTile(
      key: Key('drink-soon-${row.wineId}'),
      contentPadding: EdgeInsets.zero,
      // ux-redesign FR1.4, FR3.3: the flag of the wine; the status icon
      // when it has no country.
      leading: country == null
          ? Icon(statusIcons[WineStatus.drinkSoon])
          : CountryFlag(code: country, size: 24),
      title: Text(row.name),
      subtitle: Text(details.join(' · ')),
      onTap: onTap,
    );
  }
}
