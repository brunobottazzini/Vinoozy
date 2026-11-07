import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/sharing_providers.dart';
import '../cellar_providers.dart';
import 'drinking_record_sheet.dart';
import 'wine_detail_screen.dart';

/// The History tab (BR1.16, FR6.3, AC6.2.1, AC6.2.2): the drinks of the
/// active cellar from the most recent, 30 at a time; the next page is read
/// when 5 rows are left (performance-design.md §3). A row opens the wine,
/// finished ones included, with "Add again"; its author or the owner can
/// change rating and notes. Read-only people see it all and change nothing.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key, required this.user});

  final AppUser user;

  static const int prefetchRows = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cellar = ref.watch(activeCellarProvider(user));
    final provider = historyPagerProvider(cellar.cellarId);
    final history = ref.watch(provider);
    final pager = ref.read(provider.notifier);
    Widget body;
    if (history.records.isEmpty && history.loading) {
      body = const Center(
        child: CircularProgressIndicator(key: Key('history-loading')),
      );
    } else if (history.records.isEmpty && history.failed) {
      body = _HistoryError(onRetry: pager.reload);
    } else if (history.records.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.historyEmpty,
            key: const Key('history-empty'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    } else {
      final records = history.records;
      body = ListView.builder(
        key: const Key('history-list'),
        itemCount: records.length + (history.failed ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= records.length) {
            return _HistoryError(onRetry: pager.loadMore);
          }
          if (index >= records.length - prefetchRows &&
              history.hasMore &&
              !history.loading &&
              !history.failed) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => pager.loadMore(),
            );
          }
          final record = records[index];
          final canChange = DrinkingRecordSheet.canChange(cellar, user, record);
          return DrinkRecordTile(
            key: Key('history-tile-${record.id}'),
            record: record,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WineDetailScreen(
                  user: user,
                  cellar: cellar,
                  wineId: record.wineId,
                ),
              ),
            ),
            trailing: canChange
                ? IconButton(
                    key: Key('history-edit-${record.id}'),
                    tooltip: l10n.recordSheetTitle,
                    icon: const Icon(Icons.edit_note),
                    // A save refreshes the History itself
                    // (invalidateDrinkReads).
                    onPressed: () => DrinkingRecordSheet.show(
                      context,
                      user: user,
                      cellar: cellar,
                      record: record,
                    ),
                  )
                : null,
          );
        },
      );
    }
    return Scaffold(
      key: const Key('history-screen'),
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: body,
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.historyLoadFailed,
              key: const Key('history-error'),
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('history-retry'),
              onPressed: onRetry,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
