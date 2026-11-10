import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/external_links.dart';

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
