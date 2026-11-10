import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_flag.dart';

/// u8-account BR1.1: the phone flag `onboarding.seen`, injected at start-up
/// (lib/app/bootstrap.dart). Without it, as in the tests of the other units,
/// the presentation counts as seen and sign-in shows directly.
final onboardingFlagProvider = Provider<OnboardingFlag?>((ref) => null);

/// Whether the first-start presentation was seen on this phone (BR1.1).
final onboardingSeenProvider = AsyncNotifierProvider<OnboardingSeen, bool>(
  OnboardingSeen.new,
);

class OnboardingSeen extends AsyncNotifier<bool> {
  /// Synchronous without a flag, so sign-in shows on the first frame.
  @override
  FutureOr<bool> build() {
    final flag = ref.watch(onboardingFlagProvider);
    return flag == null ? true : flag.read();
  }

  /// "Skip", "Start", or a saved session at start-up: the presentation is not
  /// shown again, also after a sign-out or an account deletion.
  Future<void> markSeen() async {
    state = const AsyncData(true);
    await ref.read(onboardingFlagProvider)?.markSeen();
  }
}

/// Address of the privacy policy linked from the profile (BR1.2). Public;
/// set at build time with `--dart-define=PRIVACY_POLICY_URL=...`, otherwise
/// the dedicated public privacy notice. Publishing it is a release gate.
final privacyPolicyUrlProvider = Provider<String>((ref) {
  const configured = String.fromEnvironment('PRIVACY_POLICY_URL');
  return configured.isEmpty ? defaultPrivacyPolicyUrl : configured;
});

const String defaultPrivacyPolicyUrl =
    'https://brunobottazzini.github.io/Vinoozy/privacy/';
