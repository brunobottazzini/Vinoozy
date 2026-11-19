// tester-feedback FR6.1: the feedback email body ends with the technical
// data (app version, phone model, Android version, app language).
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/device_info.dart';
import 'package:vinoozy/settings/feedback_email.dart';

void main() {
  const pixel = DeviceInfo(
    manufacturer: 'Google',
    model: 'Pixel 8',
    release: '15',
  );

  test('the technical data come after room for the message', () {
    final body = buildFeedbackBody(
      techHeader: 'Dati tecnici (non cancellare)',
      appVersion: '0.4.0',
      device: pixel,
      languageTag: 'it',
    );
    final lines = body.split('\n');
    expect(lines.take(3), everyElement(isEmpty));
    expect(lines.skip(4), [
      'Dati tecnici (non cancellare)',
      'Vinoozy 0.4.0',
      'Google Pixel 8',
      'Android 15',
      'it',
    ]);
  });

  test('without device data those lines are left out', () {
    final body = buildFeedbackBody(
      techHeader: 'Technical data',
      appVersion: '0.4.0',
      device: null,
      languageTag: 'pt-BR',
    );
    expect(body, endsWith('Technical data\nVinoozy 0.4.0\npt-BR'));
    expect(body, isNot(contains('Android')));
  });

  test('a model that already names its maker is not repeated', () {
    const samsung = DeviceInfo(
      manufacturer: 'samsung',
      model: 'samsung SM-S911B',
      release: '14',
    );
    expect(samsung.displayModel, 'samsung SM-S911B');
    expect(pixel.displayModel, 'Google Pixel 8');
  });

  test('a malformed channel answer gives no device data', () {
    expect(DeviceInfo.fromChannel(null), isNull);
    expect(DeviceInfo.fromChannel('Pixel'), isNull);
    expect(DeviceInfo.fromChannel({'manufacturer': 'Google'}), isNull);
    expect(
      DeviceInfo.fromChannel({
        'manufacturer': 'Google',
        'model': 'Pixel 8',
        'release': '15',
      }),
      pixel,
    );
    expect(
      pixel.hashCode,
      DeviceInfo.fromChannel({
        'manufacturer': 'Google',
        'model': 'Pixel 8',
        'release': '15',
      }).hashCode,
    );
  });
}
