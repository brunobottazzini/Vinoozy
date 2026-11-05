import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sync/ui/offline_banner.dart';
import '../../sync/ui/rejected_wine_notice.dart';
import '../data/wine_repository.dart';
import '../domain/cellar.dart';
import 'add_wine_screen.dart';
import 'wine_list_tile.dart';

/// Whether the personal cellar is ready (BR1.3).
enum CellarSetup { preparing, ready, failed }

/// M3 simplified — the cellar (US2.1, US9.1; BR1.3, BR2.4, BR3.2).
///
/// States: loading, "Could not prepare the cellar" with "Try again", empty,
/// list. "Add" stays disabled until the cellar document exists.
class CellarScreen extends ConsumerWidget {
  const CellarScreen({
    super.key,
    required this.user,
    required this.setup,
    required this.onRetrySetup,
  });

  final AppUser user;
  final CellarSetup setup;
  final Future<void> Function() onRetrySetup;

  String get _cellarId => Cellar.personalCellarId(user.uid);

  void _openForm(BuildContext context, {String? name}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            AddWineScreen(user: user, cellarId: _cellarId, initialName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cellarExists =
        ref.watch(cellarStreamProvider(user.uid)).value?.cellar != null;
    final canAdd = setup == CellarSetup.ready && cellarExists;

    return Scaffold(
      key: const Key('cellar-screen'),
      appBar: AppBar(title: Text(l10n.cellarTitle)),
      body: Column(
        children: [
          OfflineBanner(uid: user.uid),
          RejectedWineNotices(
            uid: user.uid,
            onAddAgain: (name) => _openForm(context, name: name),
          ),
          Expanded(child: _content(context, ref, l10n, canAdd)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            key: const Key('cellar-add-button'),
            onPressed: canAdd ? () => _openForm(context) : null,
            icon: const Icon(Icons.add),
            label: Text(l10n.addWine),
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool canAdd,
  ) {
    switch (setup) {
      case CellarSetup.preparing:
        return _Loading(label: l10n.cellarLoading);
      case CellarSetup.failed:
        return _CellarError(
          message: l10n.cellarSetupFailed,
          onRetry: onRetrySetup,
        );
      case CellarSetup.ready:
        break;
    }
    final wines = ref.watch(winesStreamProvider(_cellarId));
    return wines.when(
      loading: () => _Loading(label: l10n.cellarLoading),
      error: (_, _) => _CellarError(
        message: l10n.cellarSetupFailed,
        onRetry: () async => ref.invalidate(winesStreamProvider(_cellarId)),
      ),
      data: (snapshot) => _WineList(snapshot: snapshot, l10n: l10n),
    );
  }
}

class _WineList extends StatelessWidget {
  const _WineList({required this.snapshot, required this.l10n});

  final WinesSnapshot snapshot;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (snapshot.wines.isEmpty) {
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
    // Lazy list (NFR2.2); rows rebuild only when their wine changes.
    return ListView.builder(
      key: const Key('cellar-wine-list'),
      itemCount: snapshot.wines.length,
      itemBuilder: (context, index) {
        final wine = snapshot.wines[index];
        return WineListTile(key: ValueKey(wine.id), wine: wine);
      },
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
