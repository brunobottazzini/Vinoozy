import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/platform/shared_image_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(SharedImageChannel.name);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  late Map<String, Object?> answers;
  late SharedImageChannel subject;

  setUp(() {
    calls = [];
    answers = {};
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return answers[call.method];
    });
    subject = SharedImageChannel();
  });

  tearDown(() {
    subject.dispose();
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('BR1.4 label channel', () {
    test('BR1.4 prepare sends the path and reads the prepared one', () async {
      answers['prepare'] = {'path': '/cache/label/a.jpg'};
      final result = await subject.prepare('/cache/pick.jpg');
      expect((result as PreparedImage).path, '/cache/label/a.jpg');
      expect(calls.single.arguments, {'path': '/cache/pick.jpg'});
      expect(result.toString(), isNot(contains('/cache')));
    });

    test(
      'BR1.4 a refusal carries only its code; anything else is decode',
      () async {
        answers['prepare'] = {'rejected': 'size'};
        expect(((await subject.prepare('p')) as RejectedImage).code, 'size');
        answers['prepare'] = {'path': ''};
        expect(((await subject.prepare('p')) as RejectedImage).code, 'decode');
        answers['prepare'] = 'odd';
        expect(((await subject.prepare('p')) as RejectedImage).code, 'decode');
        expect(const RejectedImage('type').toString(), 'RejectedImage(type)');
      },
    );

    test('BR1.4 pending and read share, then discard and settings', () async {
      expect(await subject.pendingShare(), isNull);
      answers['pendingShare'] = {'multiple': true};
      expect((await subject.pendingShare())!.multiple, isTrue);
      expect(await subject.readShare(), isNull);
      answers['readShare'] = {'path': '/cache/label/s.jpg'};
      expect(await subject.readShare(), isA<PreparedImage>());
      await subject.discardShare();
      expect(await subject.openSettings(), isFalse);
      answers['openSettings'] = true;
      expect(await subject.openSettings(), isTrue);
      expect(calls.map((call) => call.method), [
        'pendingShare',
        'pendingShare',
        'readShare',
        'readShare',
        'discardShare',
        'openSettings',
        'openSettings',
      ]);
    });

    test('BR1.4 a share arriving while the app runs is announced', () async {
      final notices = <SharedImageNotice>[];
      final subscription = subject.arrivals.listen(notices.add);
      Future<void> nativeSays(String method, Object? arguments) =>
          messenger.handlePlatformMessage(
            SharedImageChannel.name,
            const StandardMethodCodec().encodeMethodCall(
              MethodCall(method, arguments),
            ),
            (_) {},
          );
      await nativeSays('shareArrived', {'multiple': true});
      await nativeSays('shareArrived', null);
      await nativeSays('somethingElse', null);
      await Future<void>.delayed(Duration.zero);
      expect(notices.map((notice) => notice.multiple), [true, false]);
      await subscription.cancel();
    });
  });
}
