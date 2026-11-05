import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../gate_state.dart';

/// "Bloccato" (BR1.4, NFR4.9): another account has changes queued on this
/// phone. Two ways out: sign in with that account, or delete its unsaved
/// changes after a confirmation that shows the email and the count of wines,
/// never their names (security-design.md §1).
class BlockedAccountScreen extends StatelessWidget {
  const BlockedAccountScreen({
    super.key,
    required this.state,
    required this.onSignInWithOwner,
    required this.onDiscard,
  });

  final GateBlocked state;
  final Future<void> Function() onSignInWithOwner;

  /// Runs the reset; called after the confirmation, or directly by "Try
  /// again" when a previous reset failed.
  final Future<void> Function() onDiscard;

  Future<void> _confirmDiscard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('discard-dialog'),
        title: Text(l10n.discardDialogTitle),
        content: Text(
          l10n.discardDialogBody(state.unsavedCount, state.ownerEmail),
        ),
        actions: [
          TextButton(
            key: const Key('discard-dialog-cancel-button'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('discard-dialog-confirm-button'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.discardConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await onDiscard();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasOwner = state.ownerEmail.isNotEmpty;

    return Scaffold(
      key: const Key('blocked-account-screen'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                if (hasOwner)
                  Text(
                    l10n.blockedMessage(state.ownerEmail),
                    key: const Key('blocked-message'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                if (state.resetFailed) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.resetFailed,
                      key: const Key('blocked-reset-failed'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const Key('blocked-retry-button'),
                    onPressed: onDiscard,
                    child: Text(l10n.retry),
                  ),
                ],
                if (hasOwner) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('blocked-sign-in-with-owner-button'),
                    onPressed: onSignInWithOwner,
                    child: Text(l10n.blockedSignInWith(state.ownerEmail)),
                  ),
                  if (!state.resetFailed) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      key: const Key('blocked-discard-button'),
                      onPressed: () => _confirmDiscard(context),
                      child: Text(l10n.blockedDiscard(state.ownerEmail)),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
