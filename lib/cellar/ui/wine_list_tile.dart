import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/cellar_filter.dart';
import '../domain/quantity_delta.dart';
import '../domain/wine.dart';
import 'wine_labels.dart';

/// A wine row of the cellar (BR1.7, FR4.5): name, vintage or "no vintage",
/// quantity, status with icon and text and the confidence, as text. Long
/// names wrap instead of being cut (NFR3.4). With `canEdit` the row has the
/// quick "Drunk" action (BR1.10). The status of the day is computed once per
/// list by the caller (performance-design.md §2).
class WineListTile extends StatelessWidget {
  const WineListTile({
    super.key,
    required this.wine,
    this.status,
    this.onTap,
    this.onDrink,
  });

  final Wine wine;

  /// The status of the day; without it only vintage and quantity show (U1).
  final StatusFilter? status;
  final VoidCallback? onTap;

  /// Present only with `canEdit`.
  final VoidCallback? onDrink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final vintage = vintageText(l10n, wine.vintage);
    final status = this.status;
    final window = wine.window;
    final drink = onDrink;
    return ListTile(
      key: Key('wine-tile-${wine.id}'),
      onTap: onTap,
      title: Text(wine.name, style: theme.textTheme.bodyLarge),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status == null ? '$vintage · ${l10n.estimatePending}' : vintage),
          if (status != null) StatusLabel(status: status),
          if (status != null && window != null)
            Text(confidenceText(l10n, window.confidence)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: l10n.bottleCount(wine.quantity),
            excludeSemantics: true,
            child: Text(
              'x${wine.quantity}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (drink != null)
            IconButton(
              key: Key('wine-tile-drink-${wine.id}'),
              tooltip: l10n.wineDrinkTooltip(wine.name),
              onPressed: QuantityDelta.canDecrease(wine.storedQuantity)
                  ? drink
                  : null,
              icon: const Icon(Icons.wine_bar),
            ),
        ],
      ),
    );
  }
}
