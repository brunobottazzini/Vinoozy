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

/// Address of the privacy policy linked from the profile (BR1.2), for the
/// language tag of the interface (`it`, `pt-BR`, `fr`, ...). Public; see
/// [privacyPolicyUrlFor]. Publishing the notice is a release gate.
final privacyPolicyUrlProvider = Provider.family<String, String>(
  (ref, languageTag) => privacyPolicyUrlFor(languageTag),
);

/// The Italian privacy notice, the base page; the other languages are
/// folders under it (`docs/privacy/`).
const String defaultPrivacyPolicyUrl =
    'https://brunobottazzini.github.io/Vinoozy/privacy/';

/// Set at build time with `--dart-define=PRIVACY_POLICY_URL=...`.
const String _configuredPrivacyPolicyUrl = String.fromEnvironment(
  'PRIVACY_POLICY_URL',
);

/// The privacy notice for [languageTag] (wine-culture-languages FR5.1): the
/// notice is published in Italian (the base page), English (`en/`) and
/// Brazilian Portuguese (`pt-BR/`); every other interface language opens the
/// English one. An address [configured] at build time is used as it is,
/// whatever the language.
String privacyPolicyUrlFor(
  String languageTag, {
  String configured = _configuredPrivacyPolicyUrl,
}) {
  if (configured.isNotEmpty) return configured;
  final parts = languageTag.split(RegExp('[-_]'));
  final language = parts.first.toLowerCase();
  final isBrazilian = parts.skip(1).any((part) => part.toUpperCase() == 'BR');
  return switch (language) {
    'it' => defaultPrivacyPolicyUrl,
    'pt' when isBrazilian => '${defaultPrivacyPolicyUrl}pt-BR/',
    _ => '${defaultPrivacyPolicyUrl}en/',
  };
}
