import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// The sharing notices with "OK" (frontend-components.md,
/// SharedCellarNotice): "Mario shared their cellar with you" once per new
/// cellar (BR1.4), "You no longer have access to the cellar of Mario" once
/// per lost cellar and session (BR1.8, NFR6.3).
class SharedCellarNotice extends StatelessWidget {
  const SharedCellarNotice({super.key, required this.message});

  final String message;

  /// Shows [message] over the current screen.
  static Future<void> show(BuildContext context, String message) =>
      showDialog<void>(
        context: context,
        builder: (_) => SharedCellarNotice(message: message),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      key: const Key('shared-cellar-notice'),
      content: Semantics(liveRegion: true, child: Text(message)),
      actions: [
        TextButton(
          key: const Key('shared-cellar-notice-ok'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}
