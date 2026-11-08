// MethodChannelLensLauncher (label-recognition FR4.3, BR5.2, NFR3.3,
// NFR4.4, NFR4.10): the `vinoozy/lens` channel answered by the test, never
// the real Google app.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/core/lens_launcher.dart';
import 'package:vinoozy/label/platform/lens_channel.dart';

/// A JPEG head with only the JFIF segment, as Bitmap.compress writes it.
final Uint8List cleanJpeg = Uint8List.fromList([
  0xFF, 0xD8, // SOI
  0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00,
  0x00, 0x01, 0x00, 0x01, 0x00, 0x00, // APP0 JFIF
  0xFF, 0xDA, 0x00, 0x02, // SOS
  0x00, 0xFF, 0xD9,
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(MethodChannelLensLauncher.channelName);
  final calls = <MethodCall>[];
  Object? answer;

  setUp(() {
    calls.clear();
    answer = 'direct';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          final reply = answer;
          if (reply is Exception) throw reply;
          return reply;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  MethodChannelLensLauncher launcher({Uint8List? head}) =>
      MethodChannelLensLauncher(readHead: (_) async => head ?? cleanJpeg);

  test('FR4.3 open sends the path of the prepared front only', () async {
    expect(await launcher().open('/cache/label/front.jpg'), LensRoute.direct);
    expect(calls.single.method, 'open');
    expect(calls.single.arguments, {'path': '/cache/label/front.jpg'});
  });

  test('BR5.2 the three answers: direct, chooser, failed', () async {
    for (final (reply, route) in [
      ('direct', LensRoute.direct),
      ('chooser', LensRoute.chooser),
      ('failed', LensRoute.failed),
      (null, LensRoute.failed),
    ]) {
      answer = reply;
      expect(await launcher().open('/cache/label/front.jpg'), route);
    }
  });

  test('NFR4.10 a platform exception, or no handler, is failed', () async {
    answer = PlatformException(code: 'boom');
    expect(await launcher().open('/cache/label/front.jpg'), LensRoute.failed);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    expect(await launcher().open('/cache/label/front.jpg'), LensRoute.failed);
  });

  test('NFR3.3 a file that cannot be read is never sent', () async {
    final failing = MethodChannelLensLauncher(
      readHead: (_) async => throw const FileSystemExceptionLike(),
    );
    expect(await failing.open('/cache/label/gone.jpg'), LensRoute.failed);
    expect(calls, isEmpty);
  });
}

class FileSystemExceptionLike implements Exception {
  const FileSystemExceptionLike();
}
