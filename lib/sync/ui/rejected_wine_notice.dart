import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../capacity_rejection.dart';
import '../ledger/local_ledger.dart';

/// Wines already shown a notice in this app session: each `rejected` entry
/// counts one view per session (security-design.md §3, `noticeShown`).
final shownNoticesProvider = Provider<Set<String>>((ref) => <String>{});

/// Notices for the current user's wines that never reached the cloud
/// (NFR6.3): "The wine `name` was not saved to the cloud", with "Add again"
/// and "Ignore".
class RejectedWineNotices extends ConsumerWidget {
  const RejectedWineNotices({
    super.key,
    required this.uid,
    required this.onAddAgain,
  });

  final String uid;

  /// Opens the form with the name filled in.
  final ValueChanged<String> onAddAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledger = ref.watch(ledgerStateProvider).value;
    final rejected = ledger?.rejectedEntriesOf(uid).toList() ?? const [];
    if (rejected.isEmpty) return const SizedBox.shrink();
    _countViews(ref, rejected);
    return Column(
      key: const Key('rejected-wine-notices'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in rejected)
          RejectedWineNotice(
            key: ValueKey('rejected-${entry.wineId}'),
            entry: entry,
            onAddAgain: () async {
              // The wine may have arrived after all, or still be queued on
              // the phone: then no new wine is created (no duplicate).
              final notLost = await ref
                  .read(syncWatcherProvider)
                  .reconcileRejected(entry);
              if (notLost) return;
              await ref.read(localLedgerProvider).dismiss(entry.wineId);
              onAddAgain(entry.name);
            },
            onIgnore: () => ref.read(localLedgerProvider).dismiss(entry.wineId),
          ),
      ],
    );
  }

  void _countViews(WidgetRef ref, List<JournalEntry> rejected) {
    final shown = ref.read(shownNoticesProvider);
    final ledger = ref.read(localLedgerProvider);
    for (final entry in rejected) {
      if (shown.add(entry.wineId)) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => ledger.noticeShown(entry.wineId),
        );
      }
    }
  }
}

/// One rejected wine.
class RejectedWineNotice extends StatelessWidget {
  const RejectedWineNotice({
    super.key,
    required this.entry,
    required this.onAddAgain,
    required this.onIgnore,
  });

  final JournalEntry entry;
  final VoidCallback onAddAgain;
  final VoidCallback onIgnore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.wineNotSaved(entry.name),
                style: theme.textTheme.bodyLarge,
              ),
            ),
            // freemium-plus FR2.5: why the draft was not synced.
            if (switch (entry.reason) {
                  CapacityRejection.capacityLimit => l10n.rejectedCapacityLimit,
                  CapacityRejection.capacityConflict =>
                    l10n.rejectedCapacityConflict,
                  null => null,
                }
                case final reason?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  reason,
                  key: const Key('rejected-wine-reason'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  key: const Key('rejected-wine-ignore-button'),
                  onPressed: onIgnore,
                  child: Text(l10n.ignore),
                ),
                TextButton(
                  key: const Key('rejected-wine-add-again-button'),
                  onPressed: onAddAgain,
                  child: Text(l10n.addAgain),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
