// NFR3.3 (label-recognition): only a copy without EXIF leaves for Google
// Lens. A JPEG with an EXIF segment holding a GPS position is generated in
// the test; the prepared copy (as Bitmap.compress writes it: JFIF only) has
// no metadata, and a file that still has it is never sent on the channel.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/core/lens_launcher.dart';
import 'package:vinoozy/label/platform/lens_channel.dart';

import 'lens_channel_test.dart' show cleanJpeg;

/// A JPEG whose APP1 segment is EXIF with a GPS IFD (latitude 45.0 N).
Uint8List exifJpegWithGps() {
  final tiff = <int>[
    0x4D, 0x4D, 0x00, 0x2A, 0x00, 0x00, 0x00, 0x08, // big-endian TIFF
    0x00, 0x01, // one entry in IFD0
    0x88, 0x25, 0x00, 0x04, 0x00, 0x00, 0x00, 0x01, // GPSInfo pointer
    0x00, 0x00, 0x00, 0x1A,
    0x00, 0x00, 0x00, 0x00, // no next IFD
    0x00, 0x01, // one entry in the GPS IFD
    0x00, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x02, // GPSLatitudeRef
    0x4E, 0x00, 0x00, 0x00, // "N"
    0x00, 0x00, 0x00, 0x00,
  ];
  final payload = [...ascii.encode('Exif'), 0x00, 0x00, ...tiff];
  final length = payload.length + 2;
  return Uint8List.fromList([
    0xFF, 0xD8, // SOI
    0xFF, 0xE1, length >> 8, length & 0xFF, ...payload, // APP1 EXIF
    0xFF, 0xDA, 0x00, 0x02, 0x00, 0xFF, 0xD9,
  ]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('NFR3.3 a photo with EXIF and GPS has metadata', () {
    final original = exifJpegWithGps();
    expect(utf8.decode(original, allowMalformed: true), contains('Exif'));
    expect(jpegHasMetadata(original), isTrue);
  });

  test('NFR3.3 the prepared copy (JFIF only) has no metadata', () {
    expect(jpegHasMetadata(cleanJpeg), isFalse);
  });

  test('a file that is not a JPEG, or a broken segment, counts as unsafe', () {
    expect(
      jpegHasMetadata(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47])),
      isTrue,
    );
    expect(
      jpegHasMetadata(Uint8List.fromList([0xFF, 0xD8, 0x12, 0x34, 0, 0])),
      isTrue,
    );
    expect(
      jpegHasMetadata(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0, 1])),
      isTrue,
    );
  });

  test('NFR3.3 a file with EXIF is never sent on the channel; the clean '
      'one is', () async {
    const channel = MethodChannel(MethodChannelLensLauncher.channelName);
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return 'direct';
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final dir = Directory.systemTemp.createTempSync('vinoozy_lens_exif');
    addTearDown(() => dir.deleteSync(recursive: true));
    final withGps = File('${dir.path}/gps.jpg')
      ..writeAsBytesSync(exifJpegWithGps());
    final clean = File('${dir.path}/clean.jpg')..writeAsBytesSync(cleanJpeg);
    const launcher = MethodChannelLensLauncher();
    expect(await launcher.open(withGps.path), LensRoute.failed);
    expect(calls, isEmpty);
    expect(await launcher.open(clean.path), LensRoute.direct);
    expect(calls.single.arguments, {'path': clean.path});
  });
}
