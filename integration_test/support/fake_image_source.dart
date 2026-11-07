// The system camera replaced in the label end-to-end test: it hands the
// images drawn by the test to the app, which then sends them through the
// real channel to LabelImagePreparer and reads them with the real ML Kit.
import 'package:vinoozy/label/core/label_session.dart';
import 'package:vinoozy/label/platform/picker_image_source.dart';

class FakeImageSource implements ImageSource {
  /// The path the next pick returns; `null` is "back without a photo".
  String? nextPath;
  final List<PhotoOrigin> origins = [];

  @override
  Future<PickOutcome> pick(PhotoOrigin origin) async {
    origins.add(origin);
    final path = nextPath;
    nextPath = null;
    return path == null ? const PickCancelled() : PickedImage(path);
  }

  @override
  Future<void> discardLostData() async {}
}
