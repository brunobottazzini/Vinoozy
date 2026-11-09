import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/dashboard_summary.dart';

/// "To confirm" of the Dashboard (wine-style-profiles BR6.7, S6): how many
/// wines have "Style to confirm" or wait for their style, and the list;
/// a tap opens the wine. Hidden when empty.
class ToConfirmCard extends StatelessWidget {
  const ToConfirmCard({super.key, required this.rows, this.onOpenWine});

  final List<ToConfirmRow> rows;
  final ValueChanged<String>? onOpenWine;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: const Key('dashboard-to-confirm'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.dashboardToConfirmTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text(
              l10n.dashboardToConfirmCount(rows.length),
              key: const Key('dashboard-to-confirm-count'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            for (final row in rows)
              ListTile(
                key: Key('to-confirm-${row.wineId}'),
                contentPadding: EdgeInsets.zero,
                minTileHeight: 48,
                leading: const Icon(Icons.help_outline),
                title: Text(row.name),
                subtitle: Text(row.vintage?.toString() ?? l10n.noVintage),
                onTap: onOpenWine == null
                    ? null
                    : () => onOpenWine!(row.wineId),
              ),
          ],
        ),
      ),
    );
  }
}
