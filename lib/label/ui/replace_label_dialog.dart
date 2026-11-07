import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// "Hai un vino non salvato. Vuoi leggere la nuova foto?" before a shared
/// photo replaces an open proposal or form (BR1.4, "Chiarimenti dopo la
/// revisione"). Returns true for "Leggi la nuova foto".
class ReplaceLabelDialog extends StatelessWidget {
  const ReplaceLabelDialog({super.key});

  static Future<bool> show(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => const ReplaceLabelDialog(),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      key: const Key('label-replace-dialog'),
      content: SingleChildScrollView(child: Text(l10n.labelReplaceTitle)),
      actions: [
        TextButton(
          key: const Key('label-replace-keep'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.labelReplaceKeep),
        ),
        FilledButton(
          key: const Key('label-replace-read'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.labelReplaceRead),
        ),
      ],
    );
  }
}
