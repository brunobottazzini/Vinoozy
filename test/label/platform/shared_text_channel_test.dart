// The text shared by Google Lens on the label channel (label-autofill-windows
// FR2.1, BR2.3): the notice says it is a text, the text is taken once.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/platform/shared_image_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const name = SharedImageChannel.name;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(
    () => messenger.setMockMethodCallHandler(const MethodChannel(name), null),
  );

  test(
    'a pending text share is a text notice; the text is read once',
    () async {
      final calls = <String>[];
      var text = 'Barolo\n2016';
      messenger.setMockMethodCallHandler(const MethodChannel(name), (
        call,
      ) async {
        calls.add(call.method);
        return switch (call.method) {
          'pendingShare' => {'multiple': false, 'kind': 'text'},
          'readSharedText' => text,
          _ => null,
        };
      });
      final channel = SharedImageChannel();

      final notice = await channel.pendingShare();
      expect(notice!.isText, isTrue);
      expect(notice.multiple, isFalse);
      expect(await channel.readSharedText(), 'Barolo\n2016');
      text = '';
      expect(await channel.readSharedText(), '');
      expect(calls, ['pendingShare', 'readSharedText', 'readSharedText']);
      channel.dispose();
    },
  );

  test('an image share is not a text', () async {
    messenger.setMockMethodCallHandler(
      const MethodChannel(name),
      (call) async => {'multiple': true, 'kind': 'image'},
    );
    final channel = SharedImageChannel();
    final notice = await channel.pendingShare();
    expect(notice!.isText, isFalse);
    expect(notice.multiple, isTrue);
    channel.dispose();
  });

  test('a text arriving while the app runs is a text notice', () async {
    final channel = SharedImageChannel();
    final arrived = expectLater(
      channel.arrivals.map((n) => n.isText),
      emits(true),
    );
    await messenger.handlePlatformMessage(
      name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('shareArrived', {'multiple': false, 'kind': 'text'}),
      ),
      (_) {},
    );
    await arrived;
    channel.dispose();
  });
}
