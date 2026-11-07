import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/domain/membership.dart';
import '../cellar_actions.dart';
import '../cellar_providers.dart';
import '../domain/wine.dart';
import 'cellar_dialogs.dart';

/// Two entries of the same wine (BR1.20).
class DuplicatePair {
  const DuplicatePair({
    required this.older,
    required this.newer,
    required this.newerHasDrinks,
  });

  final Wine older;
  final Wine newer;
  final bool newerHasDrinks;
}

typedef _DuplicateKey = ({String cellarId, String wineId, String matchKey});

/// The other entry with the same `matchKey`, or `null` when there is none.
final _duplicateProvider = FutureProvider.autoDispose
    .family<DuplicatePair?, _DuplicateKey>((ref, key) async {
      final actions = ref.watch(cellarActionsProvider);
      final probe = Wine(
        id: key.wineId,
        name: '',
        vintage: null,
        storedQuantity: 0,
        matchKey: key.matchKey,
      );
      final entries = await actions.entriesLike(key.cellarId, probe);
      if (entries.length < 2) return null;
      final older = entries.first;
      final newer = older.id == key.wineId
          ? entries[1]
          : entries.firstWhere((wine) => wine.id == key.wineId);
      return DuplicatePair(
        older: older,
        newer: newer,
        newerHasDrinks: await actions.hasDrinks(key.cellarId, newer),
      );
    });

/// "Possible duplicate" in the detail (BR1.20, BR1.4 accepted limit): when
/// two entries of the cellar share the `matchKey`. "Merge" moves the bottles
/// of the newer entry to the older one and deletes it; only the owner can,
/// and only when the newer entry has no drinks. Otherwise the banner says
/// to delete the entry if it is a duplicate.
class DuplicateBanner extends ConsumerWidget {
  const DuplicateBanner({
    super.key,
    required this.user,
    required this.cellar,
    required this.wine,
    this.onMerged,
  });

  final AppUser user;
  final AccessibleCellar cellar;
  final Wine wine;

  /// Called after a merge, e.g. to close the detail of a deleted entry.
  final void Function(Wine kept)? onMerged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchKey = wine.matchKey;
    if (matchKey == null) return const SizedBox.shrink();
    final pair = ref
        .watch(
          _duplicateProvider((
            cellarId: cellar.cellarId,
            wineId: wine.id,
            matchKey: matchKey,
          )),
        )
        .value;
    if (pair == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final canMerge = cellar.isOwner && !pair.newerHasDrinks;
    return Card(
      key: const Key('duplicate-banner'),
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.content_copy, color: scheme.onSecondaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.duplicateBanner,
                    style: TextStyle(color: scheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
            if (canMerge)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  key: const Key('duplicate-merge'),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSecondaryContainer,
                  ),
                  onPressed: () => _merge(context, ref, pair),
                  child: Text(l10n.duplicateMerge),
                ),
              )
            else if (pair.newerHasDrinks)
              Text(
                l10n.duplicateDeleteHint,
                key: const Key('duplicate-delete-hint'),
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _merge(
    BuildContext context,
    WidgetRef ref,
    DuplicatePair pair,
  ) async {
    if (!await MergeDialog.show(context)) return;
    if (!context.mounted) return;
    final container = ProviderScope.containerOf(context, listen: false);
    final result = await ref
        .read(cellarActionsProvider)
        .merge(
          cellar: cellar,
          user: user,
          older: pair.older,
          newer: pair.newer,
        );
    if (result != MergeResult.merged) return;
    // The two entries changed: the History and their last drinks (R-01).
    invalidateDrinkReads(
      container,
      cellarId: cellar.cellarId,
      wineIds: [pair.older.id, pair.newer.id],
    );
    onMerged?.call(pair.older);
  }
}
