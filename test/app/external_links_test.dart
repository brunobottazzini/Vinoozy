import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/external_links.dart';
import 'package:vinoozy/app/providers.dart';

import '../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.vinoozy.app/links');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('opens the HTTPS notice through Android', () async {
    MethodCall? received;
    messenger.setMockMethodCallHandler(channel, (call) async {
      received = call;
      return true;
    });
    expect(await openExternalLink('https://example.com/privacy/'), isTrue);
    expect(received!.method, 'open');
    expect(received!.arguments, {'url': 'https://example.com/privacy/'});
  });

  test('refuses non-HTTPS URLs before contacting Android', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (_) async {
      calls++;
      return true;
    });
    for (final url in [
      'javascript:alert(1)',
      'file:///data/private',
      'https:',
      'http://example.com',
    ]) {
      expect(await openExternalLink(url), isFalse);
    }
    expect(calls, 0);
  });

  group('feedback email and device data (tester-feedback FR6, NFR7)', () {
    test('opens the email app with subject and body, no recipient', () async {
      MethodCall? received;
      messenger.setMockMethodCallHandler(channel, (call) async {
        received = call;
        return true;
      });
      expect(
        await openSupportEmail(subject: 'Feedback su Vinoozy', body: 'Ciao'),
        isTrue,
      );
      expect(received!.method, 'email');
      // The recipient is fixed on the Android side (LinksChannelHandler).
      expect(received!.arguments, {
        'subject': 'Feedback su Vinoozy',
        'body': 'Ciao',
      });
    });

    test('no email app is false; a platform failure is reported', () async {
      messenger.setMockMethodCallHandler(channel, (_) async => false);
      expect(await openSupportEmail(subject: 's', body: 'b'), isFalse);

      final errors = <Object>[];
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'boom'),
      );
      expect(
        await openSupportEmail(
          subject: 's',
          body: 'b',
          onError: (error, _) => errors.add(error),
        ),
        isFalse,
      );
      messenger.setMockMethodCallHandler(channel, null);
      expect(
        await openSupportEmail(
          subject: 's',
          body: 'b',
          onError: (error, _) => errors.add(error),
        ),
        isFalse,
      );
      expect(errors, [isA<PlatformException>(), isA<MissingPluginException>()]);
    });

    test('reads the phone model and Android version', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'deviceInfo');
        return {'manufacturer': 'Google', 'model': 'Pixel 8', 'release': '15'};
      });
      final info = await readDeviceInfo();
      expect(info!.displayModel, 'Google Pixel 8');
      expect(info.release, '15');
    });

    test('device data unavailable is null and reported', () async {
      final errors = <Object>[];
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'boom'),
      );
      expect(
        await readDeviceInfo(onError: (error, _) => errors.add(error)),
        isNull,
      );
      messenger.setMockMethodCallHandler(channel, null);
      expect(
        await readDeviceInfo(onError: (error, _) => errors.add(error)),
        isNull,
      );
      expect(errors, hasLength(2));
    });

    test('reads the support address from the Android side', () async {
      MethodCall? received;
      messenger.setMockMethodCallHandler(channel, (call) async {
        received = call;
        return 'support@example.com';
      });
      final errors = <Object>[];
      expect(
        await readSupportEmail(onError: (error, _) => errors.add(error)),
        'support@example.com',
      );
      expect(received!.method, 'supportEmail');
      expect(received!.arguments, isNull);
      expect(errors, isEmpty);
    });

    test('support address unavailable is null and reported', () async {
      final errors = <Object>[];
      Future<String?> read() =>
          readSupportEmail(onError: (error, _) => errors.add(error));

      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'boom'),
      );
      expect(await read(), isNull);
      messenger.setMockMethodCallHandler(channel, null);
      expect(await read(), isNull);
      messenger.setMockMethodCallHandler(channel, (_) async => 42);
      expect(await read(), isNull);
      messenger.setMockMethodCallHandler(channel, (_) async => '');
      expect(await read(), isNull);
      expect(errors, [
        isA<PlatformException>(),
        isA<MissingPluginException>(),
        isA<FormatException>(),
        isA<FormatException>(),
      ]);
      // Without a handler a failure still ends in null.
      expect(await readSupportEmail(), isNull);
    });

    test('open still refuses mailto: and market:', () async {
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (_) async {
        calls++;
        return true;
      });
      expect(
        await openExternalLink('mailto:bottazzinibruno@gmail.com'),
        isFalse,
      );
      expect(
        await openExternalLink('market://details?id=com.vinoozy.app'),
        isFalse,
      );
      expect(calls, 0);
    });

    test('the providers report failures through the error reporter', () async {
      final sink = RecordingErrorSink();
      final container = ProviderContainer(
        overrides: [
          errorReporterProvider.overrideWithValue(recordingReporter(sink)),
        ],
      );
      addTearDown(container.dispose);
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'boom'),
      );
      expect(
        await container.read(supportEmailOpenerProvider)(
          subject: 's',
          body: 'b',
        ),
        isFalse,
      );
      expect(await container.read(deviceInfoReaderProvider)(), isNull);
      expect(await container.read(supportEmailReaderProvider)(), isNull);
      await pumpEventQueue();
      expect(sink.reasons, [
        'SupportEmailFailed',
        'DeviceInfoFailed',
        'SupportEmailReadFailed',
      ]);
    });

    test('without an injected reporter a failure is still handled', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'boom'),
      );
      expect(await container.read(deviceInfoReaderProvider)(), isNull);
      expect(await container.read(supportEmailReaderProvider)(), isNull);
    });
  });

  test('a missing browser or plugin is a recoverable failure', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'no_browser'),
    );
    expect(await openExternalLink('https://example.com'), isFalse);
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw MissingPluginException(),
    );
    expect(await openExternalLink('https://example.com'), isFalse);
  });
}
