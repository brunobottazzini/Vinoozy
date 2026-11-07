import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// The message after "Drunk" (BR1.10, NFR3.3): "Undo" and "Add rating and
/// notes" for 6 seconds, or 10 seconds when a screen reader is on or the
/// system asks for reduced animations, so TalkBack can reach "Undo".
abstract final class DrinkSnackBar {
  static const Duration standard = Duration(seconds: 6);
  static const Duration accessible = Duration(seconds: 10);

  /// The duration for the current [MediaQuery].
  static Duration durationFor(BuildContext context) {
    final media = MediaQuery.of(context);
    return media.accessibleNavigation || media.disableAnimations
        ? accessible
        : standard;
  }

  /// Shows the message from [context].
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String wineName,
    required VoidCallback onUndo,
    required VoidCallback onAddNotes,
  }) => showWith(
    ScaffoldMessenger.of(context),
    l10n: AppLocalizations.of(context),
    duration: durationFor(context),
    wineName: wineName,
    onUndo: onUndo,
    onAddNotes: onAddNotes,
  );

  /// Shows the message on [messenger], with values read beforehand: the
  /// screen that asked may be gone by now.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showWith(
    ScaffoldMessengerState messenger, {
    required AppLocalizations l10n,
    required Duration duration,
    required String wineName,
    required VoidCallback onUndo,
    required VoidCallback onAddNotes,
  }) {
    messenger.hideCurrentSnackBar();
    void close() => messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        key: const Key('drink-snackbar'),
        duration: duration,
        // The two actions are buttons of the content: SnackBar has one.
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.drinkDone(wineName)),
            Wrap(
              spacing: 8,
              children: [
                _SnackAction(
                  key: const Key('drink-undo'),
                  label: l10n.drinkUndo,
                  onPressed: () {
                    close();
                    onUndo();
                  },
                ),
                _SnackAction(
                  key: const Key('drink-add-notes'),
                  label: l10n.drinkAddNotes,
                  onPressed: () {
                    close();
                    onAddNotes();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SnackAction extends StatelessWidget {
  const _SnackAction({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: scheme.inversePrimary,
        minimumSize: const Size(48, 48),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
