import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

// The app on Google Play, put in the invitation message (BR1.3). Since
// tester-feedback FR4.2 it lives in one place, shared with "Share the app";
// re-exported here for the invitation code that already imports it.
export '../../app/store_links.dart' show playStoreLink;

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
