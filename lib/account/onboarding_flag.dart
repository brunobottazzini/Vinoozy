import 'deletion/deletion_signal.dart';

/// The local flag `onboarding.seen` (u8-account BR1.1).
///
/// The first-start presentation comes before sign-in, so the cloud profile
/// cannot decide it: this phone flag does. It becomes true with "Skip" or
/// "Start", and at start-up when a saved session already exists (an update
/// of the app). Signing out or deleting the account never resets it.
class OnboardingFlag {
  OnboardingFlag(this._open);

  static const String key = 'onboarding.seen';

  final PreferencesOpener _open;

  /// Whether the presentation was already seen on this phone. An unreadable
  /// store counts as seen: the presentation is never worth blocking sign-in.
  Future<bool> read() async {
    try {
      return (await _open()).getBool(key) ?? false;
    } catch (_) {
      return true;
    }
  }

  /// Marks the presentation as seen. Returns false when the store refused the
  /// write; the presentation then shows again at the next start.
  Future<bool> markSeen() async {
    try {
      return await (await _open()).setBool(key, true);
    } catch (_) {
      return false;
    }
  }
}
