// The native side of "Apri in Google Lens" (label-recognition FR4.3,
// BR5.2, D4, NFR3.3, NFR4.10): the `vinoozy/lens` channel of MainActivity,
// which shares the prepared front through the FileProvider of `cache/label/`
// with the Google app, or with the share menu when it is missing.
//
// Before anything leaves, the file is checked once more: the prepared copy
// is a JPEG re-encoded on the phone without EXIF; a file that still carries
// an EXIF/XMP segment (GPS, phone model, date) is never shared (NFR3.3).

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../core/lens_launcher.dart';
import '../core/lens_session.dart';

/// Reads the head of a file; the real file in the app, bytes in tests.
typedef FileHeadReader = Future<Uint8List> Function(String path);

/// Bytes read to look for the metadata segments, which come first.
const int _headBytes = 64 * 1024;

Future<Uint8List> _readFileHead(String path) async {
  final file = await File(path).open();
  try {
    return await file.read(_headBytes);
  } finally {
    await file.close();
  }
}

/// [LensLauncher] over the `vinoozy/lens` method channel.
class MethodChannelLensLauncher implements LensLauncher {
  const MethodChannelLensLauncher({
    this._channel = const MethodChannel(channelName),
    this._readHead = _readFileHead,
  });

  /// Same name as `MainActivity.LENS_CHANNEL` in Kotlin.
  static const String channelName = 'vinoozy/lens';

  final MethodChannel _channel;
  final FileHeadReader _readHead;

  @override
  Future<LensRoute> open(String path) async {
    try {
      if (jpegHasMetadata(await _readHead(path))) return LensRoute.failed;
      final route = await _channel.invokeMethod<String>('open', {'path': path});
      return switch (route) {
        'direct' => LensRoute.direct,
        'chooser' => LensRoute.chooser,
        _ => LensRoute.failed,
      };
    } catch (_) {
      // A missing file, a platform error or no handler: the outcome stays
      // open with its message (NFR4.10).
      return LensRoute.failed;
    }
  }
}

/// "From Google Lens" and the clipboard description over the same
/// `vinoozy/lens` channel (label-autofill-windows BR2.5, BR2.6, D5): the
/// native side never returns the clipboard content, only its copy time and
/// MIME type. Listens to `windowFocused` from MainActivity.
class MethodChannelLensCamera implements LensCamera {
  MethodChannelLensCamera({
    this._channel = const MethodChannel(MethodChannelLensLauncher.channelName),
  }) {
    _channel.setMethodCallHandler(_onCall);
  }

  final MethodChannel _channel;
  final StreamController<void> _focus = StreamController<void>.broadcast();

  @override
  Stream<void> get windowFocused => _focus.stream;

  Future<Object?> _onCall(MethodCall call) async {
    if (call.method == 'windowFocused') _focus.add(null);
    return null;
  }

  @override
  Future<LensCameraOpening> openLensCamera() async {
    try {
      final answer = await _channel.invokeMethod<Object?>('openLensCamera');
      if (answer is! Map) return LensCameraOpening.unavailable;
      final openedAt = answer['openedAt'];
      final route = switch (answer['route']) {
        'lensApp' => LensCameraRoute.lensApp,
        'googleApp' => LensCameraRoute.googleApp,
        _ => LensCameraRoute.unavailable,
      };
      if (route == LensCameraRoute.unavailable || openedAt is! int) {
        return LensCameraOpening.unavailable;
      }
      return LensCameraOpening(route, openedAt: openedAt);
    } catch (_) {
      // No handler, a platform error: the instructions appear (NFR4.9).
      return LensCameraOpening.unavailable;
    }
  }

  @override
  Future<ClipInfo?> clipTimestamp() async {
    try {
      final answer = await _channel.invokeMethod<Object?>('clipTimestamp');
      if (answer is! Map) return null;
      final timestamp = answer['timestamp'];
      final mime = answer['mime'];
      if (timestamp is! int || mime is! String) return null;
      return ClipInfo(timestamp: timestamp, mime: mime);
    } catch (_) {
      // The button stays (NFR4.10).
      return null;
    }
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
    unawaited(_focus.close());
  }
}

/// The clipboard through Flutter's `Clipboard` (label-autofill-windows D4).
class FlutterClipboardReader implements ClipboardReader {
  const FlutterClipboardReader();

  @override
  Future<String?> readText() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      return text == null || text.trim().isEmpty ? null : text;
    } catch (_) {
      // Refused by the system: no error, the button stays (NFR4.10).
      return null;
    }
  }
}

/// True when the JPEG [bytes] carry an APP1 segment (EXIF or XMP, where the
/// GPS position, the phone model and the date live) before the image data,
/// or are not a JPEG at all.
bool jpegHasMetadata(Uint8List bytes) {
  if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) return true;
  var offset = 2;
  while (offset + 4 <= bytes.length) {
    if (bytes[offset] != 0xFF) return true;
    final marker = bytes[offset + 1];
    // Start of scan or end of image: no metadata before the pixels.
    if (marker == 0xDA || marker == 0xD9) return false;
    if (marker == 0xE1) return true;
    final length = (bytes[offset + 2] << 8) | bytes[offset + 3];
    if (length < 2) return true;
    offset += 2 + length;
  }
  return false;
}
