// "From Google Lens", the clipboard description and the automatic paste
// (label-autofill-windows FR2.6, FR2.7, BR2.5, BR2.6, NFR3.1, NFR3.7,
// NFR4.9, NFR4.10): the `vinoozy/lens` channel faked with
// TestDefaultBinaryMessengerBinding, a fake clock. Never the real Lens.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/core/lens_session.dart';
import 'package:vinoozy/label/platform/lens_channel.dart';

const _channel = MethodChannel('vinoozy/lens');

class _FakeCamera implements LensCamera {
  ClipInfo? clip;
  int clipCalls = 0;

  @override
  Future<ClipInfo?> clipTimestamp() async {
    clipCalls++;
    return clip;
  }

  @override
  Future<LensCameraOpening> openLensCamera() async =>
      LensCameraOpening.unavailable;

  @override
  Stream<void> get windowFocused => const Stream.empty();
}

class _FakeClipboard implements ClipboardReader {
  String? text = 'Barolo 2016';
  int reads = 0;

  @override
  Future<String?> readText() async {
    reads++;
    return text;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void answer(Object? Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(_channel, (call) async => handler(call));
  }

  tearDown(() => messenger.setMockMethodCallHandler(_channel, null));

  group('BR2.5 openLensCamera', () {
    test('the Lens app and the Google app open with their time', () async {
      final camera = MethodChannelLensCamera();
      answer((_) => {'route': 'lensApp', 'openedAt': 1000});
      var opening = await camera.openLensCamera();
      expect(opening.route, LensCameraRoute.lensApp);
      expect(opening.openedAt, 1000);
      expect(opening.opened, isTrue);
      answer((_) => {'route': 'googleApp', 'openedAt': 2000});
      opening = await camera.openLensCamera();
      expect(opening.route, LensCameraRoute.googleApp);
      camera.dispose();
    });

    test(
      'NFR4.9 unavailable, a malformed answer or an error: unavailable',
      () async {
        final camera = MethodChannelLensCamera();
        for (final reply in <Object? Function(MethodCall)>[
          (_) => {'route': 'unavailable'},
          (_) => {'route': 'lensApp'},
          (_) => 'lensApp',
          (_) => throw PlatformException(code: 'boom'),
        ]) {
          answer(reply);
          final opening = await camera.openLensCamera();
          expect(opening.route, LensCameraRoute.unavailable);
          expect(opening.opened, isFalse);
        }
        camera.dispose();
      },
    );
  });

  group('BR2.6 clipTimestamp: the description, never the content', () {
    test('timestamp and MIME type', () async {
      final camera = MethodChannelLensCamera();
      final calls = <String>[];
      answer((call) {
        calls.add(call.method);
        return {'timestamp': 5000, 'mime': 'text/plain'};
      });
      final clip = await camera.clipTimestamp();
      expect(clip, const ClipInfo(timestamp: 5000, mime: 'text/plain'));
      expect(clip!.isText, isTrue);
      expect(calls, ['clipTimestamp']);
      camera.dispose();
    });

    test('NFR4.10 below Android 8.0, no clip or an error: null', () async {
      final camera = MethodChannelLensCamera();
      for (final reply in <Object? Function(MethodCall)>[
        (_) => null,
        (_) => {'timestamp': '5000', 'mime': 'text/plain'},
        (_) => throw PlatformException(code: 'denied'),
      ]) {
        answer(reply);
        expect(await camera.clipTimestamp(), isNull);
      }
      camera.dispose();
    });

    test('the window focus comes from MainActivity', () async {
      final camera = MethodChannelLensCamera();
      final focused = expectLater(camera.windowFocused, emits(null));
      await messenger.handlePlatformMessage(
        _channel.name,
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('windowFocused'),
        ),
        (_) {},
      );
      await focused;
      camera.dispose();
    });
  });

  group('FlutterClipboardReader (NFR4.10)', () {
    test('the text, nothing for blank text, nothing on a refusal', () async {
      const reader = FlutterClipboardReader();
      Object? reply = {'text': 'Barolo'};
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.getData') {
          final answer = reply;
          if (answer is Exception) throw answer;
          return answer;
        }
        return null;
      });
      expect(await reader.readText(), 'Barolo');
      reply = {'text': '   '};
      expect(await reader.readText(), isNull);
      reply = null;
      expect(await reader.readText(), isNull);
      reply = PlatformException(code: 'denied');
      expect(await reader.readText(), isNull);
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });
  });

  group('BR2.6 NFR3.1 LensSession and the automatic paste', () {
    late _FakeCamera camera;
    late _FakeClipboard clipboard;
    late int now;
    late LensAutoPaste autoPaste;

    setUp(() {
      camera = _FakeCamera();
      clipboard = _FakeClipboard();
      now = 1000;
      autoPaste = LensAutoPaste(
        camera: camera,
        clipboard: clipboard,
        nowMillis: () => now,
      );
    });

    test(
      'a text copied after Lens opened, within 5 minutes: read once',
      () async {
        final session = LensSession(openedAt: 1000);
        now = 61000;
        camera.clip = const ClipInfo(timestamp: 30000, mime: 'text/plain');

        expect(await autoPaste.take(session), 'Barolo 2016');
        expect(session.consumedClipTimestamp, 30000);
        expect(await autoPaste.take(session), isNull);
        expect(clipboard.reads, 1);
      },
    );

    test('a text copied before Lens opened is never read', () async {
      final session = LensSession(openedAt: 1000);
      camera.clip = const ClipInfo(timestamp: 999, mime: 'text/plain');
      expect(await autoPaste.take(session), isNull);
      expect(clipboard.reads, 0);
    });

    test('after 5 minutes nothing is read, not even the description', () async {
      final session = LensSession(openedAt: 1000);
      now = 1000 + LensSession.maxAge.inMilliseconds;
      camera.clip = const ClipInfo(timestamp: 2000, mime: 'text/plain');
      expect(await autoPaste.take(session), isNull);
      expect(camera.clipCalls, 0);
      expect(clipboard.reads, 0);
    });

    test(
      'another MIME type, no clip (API < 26) or no session: nothing',
      () async {
        final session = LensSession(openedAt: 1000);
        now = 5000;
        camera.clip = const ClipInfo(timestamp: 2000, mime: 'image/png');
        expect(await autoPaste.take(session), isNull);
        camera.clip = null;
        expect(await autoPaste.take(session), isNull);
        expect(await autoPaste.take(null), isNull);
        expect(clipboard.reads, 0);
      },
    );

    test(
      'NFR3.7 a text that gives nothing is consumed and not tried again',
      () async {
        final session = LensSession(openedAt: 1000);
        now = 5000;
        camera.clip = const ClipInfo(timestamp: 2000, mime: 'text/plain');
        clipboard.text = null;
        expect(await autoPaste.take(session), isNull);
        expect(await autoPaste.take(session), isNull);
        expect(clipboard.reads, 1);
      },
    );

    test('a clock behind the opening is not fresh', () {
      final session = LensSession(openedAt: 1000);
      expect(session.isFresh(999), isFalse);
      expect(session.isFresh(1000), isTrue);
    });
  });
}
