import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/quantity_delta.dart';
import '../domain/wine.dart';

/// "Already in the cellar" (BR1.4): the existing entry and its current
/// quantity; "Add N bottles" adds them to it (BR1.15), "Cancel" goes back to
/// the form. Returns true when confirmed.
///
/// N never takes the entry over 99 bottles (BR1.3 cap, review R-05): it is
/// [addableFor]; with no room left the dialog says so and "Add" is off.
class DuplicateDialog extends StatelessWidget {
  const DuplicateDialog({
    super.key,
    required this.existing,
    required this.bottles,
  });

  final Wine existing;

  /// The bottles of the form, to add.
  final int bottles;

  /// The bottles that can be added to [existing]: [bottles], at most up to
  /// 99 in all.
  static int addableFor(Wine existing, int bottles) =>
      QuantityDelta.room(existing.storedQuantity).clamp(0, bottles);

  static Future<bool> show(
    BuildContext context, {
    required Wine existing,
    required int bottles,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => DuplicateDialog(existing: existing, bottles: bottles),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vintage = existing.vintage?.toString() ?? l10n.noVintage;
    final addable = addableFor(existing, bottles);
    return AlertDialog(
      key: const Key('duplicate-dialog'),
      title: Text(l10n.duplicateTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.duplicateBody(
                '${existing.name} $vintage',
                existing.quantity,
              ),
            ),
            if (addable == 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.duplicateFull,
                  key: const Key('duplicate-full'),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('duplicate-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('duplicate-confirm'),
          onPressed: addable == 0
              ? null
              : () => Navigator.of(context).pop(true),
          child: Text(l10n.duplicateAdd(addable == 0 ? bottles : addable)),
        ),
      ],
    );
  }
}

/// "Delete «name»?" (BR1.14): the wine and all its drinks. Returns true
/// when confirmed.
class DeleteWineDialog extends StatelessWidget {
  const DeleteWineDialog({super.key, required this.wineName});

  final String wineName;

  static Future<bool> show(BuildContext context, String wineName) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => DeleteWineDialog(wineName: wineName),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      key: const Key('delete-dialog'),
      title: Text(l10n.deleteWineTitle(wineName)),
      content: SingleChildScrollView(child: Text(l10n.deleteWineBody)),
      actions: [
        TextButton(
          key: const Key('delete-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('delete-confirm'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.wineDelete),
        ),
      ],
    );
  }
}

/// "Merge the two entries?" (BR1.20). Returns true when confirmed.
class MergeDialog extends StatelessWidget {
  const MergeDialog({super.key});

  static Future<bool> show(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => const MergeDialog(),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      key: const Key('merge-dialog'),
      title: Text(l10n.mergeTitle),
      content: SingleChildScrollView(child: Text(l10n.mergeBody)),
      actions: [
        TextButton(
          key: const Key('merge-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('merge-confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.duplicateMerge),
        ),
      ],
    );
  }
}
