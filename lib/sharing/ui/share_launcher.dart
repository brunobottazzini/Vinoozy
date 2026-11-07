import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Opens the Android share sheet with a ready-made message (BR1.3). Behind an
/// interface so the tests replace it (unit-test-instructions.md).
abstract interface class ShareLauncher {
  Future<void> share({required String text, required String subject});
}

/// [ShareLauncher] on `share_plus`: the system share sheet, no permission.
class SharePlusLauncher implements ShareLauncher {
  const SharePlusLauncher();

  @override
  Future<void> share({required String text, required String subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }
}

final shareLauncherProvider = Provider<ShareLauncher>(
  (ref) => const SharePlusLauncher(),
);

/// The app on Google Play, put in the invitation message (BR1.3).
const String playStoreLink =
    'https://play.google.com/store/apps/details?id=com.vinoozy.app';
