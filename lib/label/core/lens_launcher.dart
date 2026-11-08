// "Apri in Google Lens" as the label module sees it (label-recognition
// FR4.1-FR4.4, BR5.1-BR5.3, D4). Pure Dart: the native channel is in
// platform/lens_channel.dart.

import '../../catalog/core/catalog_event_logger.dart' show LensRoute;

export '../../catalog/core/catalog_event_logger.dart' show LensRoute;

/// Hands the prepared front photo to the Google app, or to the share menu
/// when the Google app is missing (BR5.2). Called only after the user's
/// confirmation (BR5.1, NFR3.1). Vinoozy never reads what Google finds
/// (BR5.3, NFR3.5). Never throws: a failure is [LensRoute.failed].
abstract interface class LensLauncher {
  Future<LensRoute> open(String path);
}
