import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../gate_state.dart';

/// M1 — Sign-in (US1.1, BR1.1): logo, tagline and the only button
/// "Continue with Google". States: loading in the button, failure with
/// "Try again", no network on first sign-in.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({
    super.key,
    required this.onSignIn,
    this.notice,
    this.busy = false,
  });

  final Future<void> Function() onSignIn;
  final SignInNotice? notice;
  final bool busy;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _noNetwork = false;

  @override
  void initState() {
    super.initState();
    _checkNetwork();
  }

  Future<bool> _checkNetwork() async {
    final hasNetwork = await ref.read(networkStatusProvider).hasNetwork();
    if (mounted) setState(() => _noNetwork = !hasNetwork);
    return hasNetwork;
  }

  Future<void> _signIn() async {
    // The first sign-in needs the network (BR1.1, NFR2.5).
    if (!await _checkNetwork()) return;
    await widget.onSignIn();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final message = _noNetwork
        ? l10n.signInNeedsNetwork
        : switch (widget.notice) {
            SignInNotice.failed => l10n.signInFailed,
            SignInNotice.sessionExpired => l10n.signInSessionExpired,
            null => null,
          };
    final showRetry =
        !_noNetwork && widget.notice == SignInNotice.failed && !widget.busy;

    return Scaffold(
      key: const Key('sign-in-screen'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.wine_bar,
                  size: 72,
                  color: theme.colorScheme.primary,
                  semanticLabel: l10n.appTitle,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signInTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                if (message != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      message,
                      key: const Key('sign-in-message'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  key: const Key('sign-in-google-button'),
                  onPressed: widget.busy ? null : _signIn,
                  icon: widget.busy
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            semanticsLabel: l10n.signInInProgress,
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(l10n.signInWithGoogle),
                ),
                if (showRetry) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('sign-in-retry-button'),
                    onPressed: _signIn,
                    child: Text(l10n.retry),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
