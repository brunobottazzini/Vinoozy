import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/wine.dart';

/// A wine row of the cellar (M3 simplified): name, vintage, quantity and
/// "Estimate coming" until the estimate arrives with u2/u4. Long names wrap
/// instead of being cut (NFR3.4).
class WineListTile extends StatelessWidget {
  const WineListTile({super.key, required this.wine});

  final Wine wine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final vintage = wine.vintage?.toString() ?? l10n.noVintage;
    return ListTile(
      title: Text(wine.name, style: theme.textTheme.bodyLarge),
      subtitle: Text('$vintage · ${l10n.estimatePending}'),
      trailing: Semantics(
        label: l10n.bottleCount(wine.quantity),
        excludeSemantics: true,
        child: Text('x${wine.quantity}', style: theme.textTheme.titleMedium),
      ),
    );
  }
}
