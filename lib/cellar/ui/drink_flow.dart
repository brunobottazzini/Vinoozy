import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../guide/guide_providers.dart';
import '../../guide/review_prompter.dart';
import '../../l10n/app_localizations.dart';
import '../../settings/app_review.dart';
import '../../sharing/domain/membership.dart';
import '../cellar_providers.dart';
import '../data/drinking_record_repository.dart';
import '../domain/drinking_record.dart';
import '../domain/wine.dart';
import 'drink_confirm_sheet.dart';
import 'drink_snack_bar.dart';
import 'drinking_record_sheet.dart';

/// "I drank one" from a card or from the detail (BR1.10; ux-redesign FR2.2,
/// FR2.3): the confirmation sheet opens first and nothing is written until
/// "Yes, I drank it"; then the drink, with the optional rating, is saved on
/// the phone in one write and the message offers "Undo" and "Add rating and
/// notes". The services are read before any wait, so the message keeps
/// working after the screen that started it is closed (a wine at 0 leaves
/// the list).
Future<void> drinkWithUndo(
  BuildContext context,
  WidgetRef ref, {
  required AppUser user,
  required AccessibleCellar cellar,
  required Wine wine,
}) async {
  final actions = ref.read(cellarActionsProvider);
  final clock = ref.read(clockProvider);
  final navigator = Navigator.of(context);
  // The Cellar has a local messenger for its FAB. Undo belongs to the
  // session and must also remain visible after switching to History or
  // popping the detail route, so use the navigator's shared messenger.
  final outerScaffold = context.findRootAncestorStateOfType<ScaffoldState>();
  final messenger = ScaffoldMessenger.of(outerScaffold?.context ?? context);
  final l10n = AppLocalizations.of(context);
  final duration = DrinkSnackBar.durationFor(context);
  final container = ProviderScope.containerOf(context, listen: false);
  void refreshReads() => invalidateDrinkReads(
    container,
    cellarId: cellar.cellarId,
    wineIds: [wine.id],
  );
  final confirmation = await DrinkConfirmSheet.show(context, wine);
  // "Cancel", back or a tap outside: no write at all (FR2.2).
  if (confirmation == null) return;
  // tester-feedback FR5.2.1, review R-05: the active wines of the cellar
  // before the drink, from the list already in memory (no Firestore read,
  // NFR6); a list nobody listens to counts as unknown, so no prompt.
  final activeWineCount = _loadedWineCount(container, cellar.cellarId);
  final outcome = await actions.drink(
    cellar: cellar,
    user: user,
    wine: wine,
    rating: confirmation.rating,
  );
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
    rating: confirmation.rating,
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
  // tester-feedback FR5.2: a positive moment, after the "Drunk" message.
  await maybeAskForReview(
    store: container.read(guideStateStoreProvider),
    launcher: container.read(appReviewLauncherProvider),
    rating: confirmation.rating,
    activeWineCount: activeWineCount,
    now: clock.now(),
    enabled: container.read(autoReviewEnabledProvider),
  );
}

/// The wines of [cellarId] already loaded by the Cellar and the Dashboard
/// (quantity > 0, archived ones excluded), or 0 when the list is not open.
int _loadedWineCount(ProviderContainer container, String cellarId) {
  final wines = winesStreamProvider(cellarId);
  if (!container.exists(wines)) return 0;
  return container.read(wines).value?.wines.length ?? 0;
}
