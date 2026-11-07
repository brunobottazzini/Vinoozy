import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/domain/membership.dart';
import '../cellar_providers.dart';
import 'wine_detail_screen.dart';
import 'wine_labels.dart';

/// "Drunk" (BR1.7 archive): the finished wines of the cellar, read once when
/// this screen opens and never in daily use (NFR5.1). A row opens the wine,
/// with "Add again".
class ArchivedWinesScreen extends ConsumerWidget {
  const ArchivedWinesScreen({
    super.key,
    required this.user,
    required this.cellar,
  });

  final AppUser user;
  final AccessibleCellar cellar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final archived = ref.watch(archivedWinesProvider(cellar.cellarId));
    return Scaffold(
      key: const Key('archive-screen'),
      appBar: AppBar(title: Text(l10n.cellarArchiveTitle)),
      body: switch (archived) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.cellarArchiveEmpty,
              key: const Key('archive-empty'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        AsyncData(:final value) => ListView.builder(
          key: const Key('archive-list'),
          itemCount: value.length,
          itemBuilder: (context, index) {
            final wine = value[index];
            return ListTile(
              key: Key('archive-tile-${wine.id}'),
              title: Text(wine.name),
              subtitle: Text(
                [?wine.producer, vintageText(l10n, wine.vintage)].join(' · '),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WineDetailScreen(
                    user: user,
                    cellar: cellar,
                    wineId: wine.id,
                  ),
                ),
              ),
            );
          },
        ),
        AsyncError() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.cellarArchiveFailed, key: const Key('archive-error')),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('archive-retry'),
                onPressed: () =>
                    ref.invalidate(archivedWinesProvider(cellar.cellarId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        _ => const Center(
          child: CircularProgressIndicator(key: Key('archive-loading')),
        ),
      },
    );
  }
}
