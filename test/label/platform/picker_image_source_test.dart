import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/label/core/label_session.dart';
import 'package:vinoozy/label/platform/picker_image_source.dart';

class _MockImagePicker extends Mock implements picker.ImagePicker {}

void main() {
  late _MockImagePicker imagePicker;
  late PickerImageSource source;

  setUpAll(() => registerFallbackValue(picker.ImageSource.camera));

  setUp(() {
    imagePicker = _MockImagePicker();
    source = PickerImageSource(imagePicker: imagePicker);
  });

  void answer(Future<picker.XFile?> Function() result) => when(
    () => imagePicker.pickImage(
      source: any(named: 'source'),
      requestFullMetadata: any(named: 'requestFullMetadata'),
    ),
  ).thenAnswer((_) => result());

  group('BR1.2 BR1.3 system camera and photo picker', () {
    test('BR1.2 the camera with no resizing and no metadata request', () async {
      answer(() async => picker.XFile('/cache/1/photo.jpg'));
      final outcome = await source.pick(PhotoOrigin.camera);
      expect((outcome as PickedImage).path, '/cache/1/photo.jpg');
      verify(
        () => imagePicker.pickImage(
          source: picker.ImageSource.camera,
          requestFullMetadata: false,
        ),
      ).called(1);
      expect(outcome.toString(), isNot(contains('/cache')));
    });

    test(
      'BR1.3 the gallery; back without a photo is a silent cancel',
      () async {
        answer(() async => null);
        expect(await source.pick(PhotoOrigin.gallery), isA<PickCancelled>());
        verify(
          () => imagePicker.pickImage(
            source: picker.ImageSource.gallery,
            requestFullMetadata: false,
          ),
        ).called(1);
      },
    );

    test('BR1.5 a denied access, no camera and other errors', () async {
      answer(() async => throw PlatformException(code: 'camera_access_denied'));
      expect(await source.pick(PhotoOrigin.camera), isA<PickDenied>());
      answer(() async => throw PlatformException(code: 'photo_access_denied'));
      expect(await source.pick(PhotoOrigin.gallery), isA<PickDenied>());
      answer(() async => throw PlatformException(code: 'no_available_camera'));
      expect(
        await source.pick(PhotoOrigin.camera),
        isA<PickCameraUnavailable>(),
      );
      answer(() async => throw PlatformException(code: 'already_active'));
      expect(await source.pick(PhotoOrigin.camera), isA<PickFailed>());
      answer(() async => throw StateError('plugin'));
      final failed = await source.pick(PhotoOrigin.camera) as PickFailed;
      expect(failed.error, isA<StateError>());
    });
  });

  group('BR1.6 lost data of image_picker', () {
    test('BR1.6 nothing lost does nothing', () async {
      when(() => imagePicker.retrieveLostData())
          .thenAnswer((_) async => picker.LostDataResponse.empty());
      await source.discardLostData();
    });

    test('BR1.6 lost files are read and deleted', () async {
      final dir = await Directory.systemTemp.createTemp('vinoozy_lost');
      addTearDown(() => dir.delete(recursive: true));
      final lost = File('${dir.path}/lost.jpg')..writeAsStringSync('x');
      when(() => imagePicker.retrieveLostData()).thenAnswer(
        (_) async => picker.LostDataResponse(
          files: [
            picker.XFile(lost.path),
            picker.XFile('${dir.path}/gone.jpg'),
          ],
        ),
      );
      await source.discardLostData();
      expect(lost.existsSync(), isFalse);
    });
  });
}
