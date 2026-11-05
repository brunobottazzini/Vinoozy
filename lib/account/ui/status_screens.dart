import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

/// Shown while the session and the ledger are read, or while a reset runs.
class GateLoadingScreen extends StatelessWidget {
  const GateLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('gate-loading-screen'),
      body: Center(
        child: CircularProgressIndicator(semanticsLabel: l10n.appTitle),
      ),
    );
  }
}

/// A blocking error with a single "Try again" (ledger unreadable, start-up
/// failure).
class GateErrorScreen extends StatelessWidget {
  const GateErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      key: const Key('gate-error-screen'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('gate-error-retry-button'),
                  onPressed: onRetry,
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Plan B of the local reset (security-design.md §5): Firestore cannot be
/// reused in this process, so the user closes the app; the next start clears
/// the local data before anything else.
class RestartRequiredScreen extends StatelessWidget {
  const RestartRequiredScreen({super.key, this.closeApp = _systemPop});

  final Future<void> Function() closeApp;

  static Future<void> _systemPop() => SystemNavigator.pop();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      key: const Key('restart-required-screen'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.restartRequired,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('restart-close-app-button'),
                  onPressed: closeApp,
                  child: Text(l10n.restartCloseApp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
