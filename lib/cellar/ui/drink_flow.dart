import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/domain/membership.dart';
import '../cellar_providers.dart';
import '../data/drinking_record_repository.dart';
import '../domain/drinking_record.dart';
import '../domain/wine.dart';
import 'drink_snack_bar.dart';
import 'drinking_record_sheet.dart';

/// "Drunk" from a row or from the detail (BR1.10): the drink is saved on the
/// phone, then the message offers "Undo" and "Add rating and notes". The
/// services are read before any wait, so the message keeps working after
/// the screen that started it is closed (a wine at 0 leaves the list).
Future<void> drinkWithUndo(
  BuildContext context,
  WidgetRef ref, {
  required AppUser user,
  required AccessibleCellar cellar,
  required Wine wine,
}) async {
  final actions = ref.read(cellarActionsProvider);
  final clock = ref.read(clockProvider);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final l10n = AppLocalizations.of(context);
  final duration = DrinkSnackBar.durationFor(context);
  final container = ProviderScope.containerOf(context, listen: false);
  void refreshReads() => invalidateDrinkReads(
    container,
    cellarId: cellar.cellarId,
    wineIds: [wine.id],
  );
  final outcome = await actions.drink(cellar: cellar, user: user, wine: wine);
  if (outcome is! DrinkAccepted) {
    messenger.showSnackBar(
      SnackBar(key: const Key('drink-failed'), content: Text(l10n.saveFailed)),
    );
    return;
  }
  refreshReads();
  final record = DrinkingRecord(
    id: outcome.recordId,
    wineId: wine.id,
    wineName: wine.name,
    vintage: wine.vintage,
    drankOn: dateOnly(clock.now()),
    recordedBy: user.uid,
  );
  DrinkSnackBar.showWith(
    messenger,
    l10n: l10n,
    duration: duration,
    wineName: wine.name,
    onUndo: () async {
      final result = await actions.undoDrink(
        cellar: cellar,
        user: user,
        wine: wine,
        recordId: outcome.recordId,
      );
      refreshReads();
      if (result == UndoResult.nothingToUndo) {
        messenger.showSnackBar(
          SnackBar(
            key: const Key('nothing-to-undo'),
            content: Text(l10n.nothingToUndo),
          ),
        );
      }
    },
    onAddNotes: () {
      if (!navigator.mounted) return;
      DrinkingRecordSheet.show(
        navigator.context,
        user: user,
        cellar: cellar,
        record: record,
        wine: wine,
      );
    },
  );
}
