import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' as picker;

import '../core/label_session.dart';

/// What the system camera or photo picker gave back (BR1.2, BR1.3, BR1.5).
sealed class PickOutcome {
  const PickOutcome();
}

/// A photo, still where image_picker wrote it (inside the cache folder);
/// the native preparer moves it into `label/` (NFR8.1).
class PickedImage extends PickOutcome {
  const PickedImage(this.path);

  final String path;

  @override
  String toString() => 'PickedImage()';
}

/// Back without a photo: "Aggiungi" with no message.
class PickCancelled extends PickOutcome {
  const PickCancelled();
}

/// The system denied the camera or the photos.
class PickDenied extends PickOutcome {
  const PickDenied();
}

/// No camera app on the phone.
class PickCameraUnavailable extends PickOutcome {
  const PickCameraUnavailable();
}

/// Any other failure of the picker; reported as `label_pick_failed`.
class PickFailed extends PickOutcome {
  const PickFailed(this.error, this.stack);

  final Object error;
  final StackTrace stack;
}

/// The system camera and photo picker (logical-components.md, ImageSource).
abstract interface class ImageSource {
  /// Opens the camera ([PhotoOrigin.camera]) or the photo picker
  /// ([PhotoOrigin.gallery]) for one image. Never throws.
  Future<PickOutcome> pick(PhotoOrigin origin);

  /// Reads and deletes what image_picker kept from a process killed while
  /// the camera was open (NFR8.1). Throws when a file cannot be deleted.
  Future<void> discardLostData();
}

/// [ImageSource] with image_picker: no resizing here (`maxWidth` and
/// `maxHeight` stay unset), the native preparer reduces every image
/// (security-design.md §3). On Android neither the camera intent nor the
/// photo picker needs a permission (NFR4.2).
class PickerImageSource implements ImageSource {
  PickerImageSource({picker.ImagePicker? imagePicker})
    : _picker = imagePicker ?? picker.ImagePicker();

  final picker.ImagePicker _picker;

  /// image_picker error codes for a refused access, on Android and iOS.
  static const Set<String> deniedCodes = {
    'camera_access_denied',
    'photo_access_denied',
  };
  static const String noCameraCode = 'no_available_camera';

  @override
  Future<PickOutcome> pick(PhotoOrigin origin) async {
    try {
      final file = await _picker.pickImage(
        source: origin == PhotoOrigin.camera
            ? picker.ImageSource.camera
            : picker.ImageSource.gallery,
        requestFullMetadata: false,
      );
      return file == null ? const PickCancelled() : PickedImage(file.path);
    } on PlatformException catch (error, stack) {
      if (deniedCodes.contains(error.code)) return const PickDenied();
      if (error.code == noCameraCode) return const PickCameraUnavailable();
      return PickFailed(error, stack);
    } catch (error, stack) {
      return PickFailed(error, stack);
    }
  }

  @override
  Future<void> discardLostData() async {
    final lost = await _picker.retrieveLostData();
    if (lost.isEmpty) return;
    for (final file in lost.files ?? const <picker.XFile>[]) {
      final orphan = File(file.path);
      if (orphan.existsSync()) await orphan.delete();
    }
  }
}
