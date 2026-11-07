import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/home_shell.dart';
import '../../app/providers.dart';
import '../../cellar/ui/cellar_screen.dart' show CellarSetup;
import '../../l10n/app_localizations.dart';
import '../account_gate.dart';
import '../account_providers.dart';
import 'blocked_account_screen.dart';
import 'delete_account_screen.dart';
import 'onboarding_screen.dart';
import 'sign_in_screen.dart';
import 'status_screens.dart';

/// AuthGate of frontend-components.md: shows the screen of the current
/// [AccountGate] state. Since u8-account the first-start presentation comes
/// before sign-in (BR1.1) and a deletion shows only its progress (BR1.5).
class AccountGateView extends ConsumerWidget {
  const AccountGateView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gate = ref.watch(accountGateProvider);
    return ValueListenableBuilder<GateState>(
      valueListenable: gate.state,
      builder: (context, state, _) => switch (state) {
        GateStarting() || GateResetting() => const GateLoadingScreen(),
        GateSignIn(:final notice, :final busy) => _SignInOrOnboarding(
          child: SignInScreen(
            onSignIn: gate.signIn,
            notice: notice,
            busy: busy,
          ),
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
        GateDeleting() => DeletionProgressView(
          state: state,
          onContinue: gate.resumeDeletion,
          onCancel: gate.cancelDeletion,
        ),
        GateDeleted() => SignInScreen(
          onSignIn: gate.signIn,
          notice: SignInNotice.accountDeleted,
        ),
        // The shell opens on the Dashboard, with the Cellar as second tab
        // (u5-dashboard FR5.1); both tabs get the same setup and retry.
        GateEnsureCellar(:final user) => HomeShell(
          user: user,
          setup: CellarSetup.preparing,
          onRetrySetup: gate.retryCellar,
        ),
        GateCellar(:final user, :final setupFailed) => HomeShell(
          user: user,
          setup: setupFailed ? CellarSetup.failed : CellarSetup.ready,
          onRetrySetup: gate.retryCellar,
        ),
      },
    );
  }
}

/// u8-account BR1.1: the presentation until `onboarding.seen`, then
/// [child], the sign-in.
class _SignInOrOnboarding extends ConsumerWidget {
  const _SignInOrOnboarding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(onboardingSeenProvider)) {
      AsyncData(value: false) => OnboardingScreen(
        onDone: ref.read(onboardingSeenProvider.notifier).markSeen,
      ),
      AsyncLoading() => const GateLoadingScreen(),
      _ => child,
    };
  }
}
