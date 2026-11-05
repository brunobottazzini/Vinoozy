import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../cellar/ui/cellar_screen.dart';
import '../../l10n/app_localizations.dart';
import '../account_gate.dart';
import 'blocked_account_screen.dart';
import 'sign_in_screen.dart';
import 'status_screens.dart';

/// AuthGate of frontend-components.md: shows the screen of the current
/// [AccountGate] state.
class AccountGateView extends ConsumerWidget {
  const AccountGateView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(accountGateProvider);
    return ValueListenableBuilder<GateState>(
      valueListenable: gate.state,
      builder: (context, state, _) => switch (state) {
        GateStarting() || GateResetting() => const GateLoadingScreen(),
        GateSignIn(:final notice, :final busy) => SignInScreen(
          onSignIn: gate.signIn,
          notice: notice,
          busy: busy,
        ),
        GateBlocked() => BlockedAccountScreen(
          state: state,
          onSignInWithOwner: gate.signInWithOwner,
          onDiscard: gate.discardAndContinue,
        ),
        GateCheckFailed() => GateErrorScreen(
          message: AppLocalizations.of(context).startupFailed,
          onRetry: gate.retryCheck,
        ),
        GateRestartRequired() => const RestartRequiredScreen(),
        GateEnsureCellar(:final user) => CellarScreen(
          user: user,
          setup: CellarSetup.preparing,
          onRetrySetup: gate.retryCellar,
        ),
        GateCellar(:final user, :final setupFailed) => CellarScreen(
          user: user,
          setup: setupFailed ? CellarSetup.failed : CellarSetup.ready,
          onRetrySetup: gate.retryCellar,
        ),
      },
    );
  }
}
