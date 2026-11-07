import 'package:flutter/widgets.dart';

import '../firebase/firebase_env.dart';

/// Language of the end-to-end builds (`--dart-define=E2E=true` only,
/// cicd-pipeline.md §1; u8-account review R-01).
///
/// The end-to-end tests look for Italian texts, while the Android emulator of
/// CI (and of a developer machine) is usually en-US. These builds therefore
/// show the app in Italian whatever the device language. Release builds have
/// `kIsE2EBuild == false`: the override is null and the production language
/// resolution (resolveAppLocale, BR5.1) is unchanged. The announcement below
/// is the marker tool/check_release_build.sh looks for: absent from the
/// release build, present in the E2E control build.
const Locale e2eLocale = Locale('it');

/// The language every screen uses in an E2E build, or null in every other
/// build (then the phone's languages decide).
Locale? get appLocaleOverride => kIsE2EBuild ? e2eLocale : null;

/// Logs once at start-up that the E2E build forces its language.
void announceE2ELocale() {
  if (!kIsE2EBuild) return;
  debugPrint('VINOOZY_E2E_LOCALE=${e2eLocale.toLanguageTag()}');
}
