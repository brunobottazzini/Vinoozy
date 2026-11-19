import 'package:flutter/foundation.dart';

/// The phone model and Android version put at the end of the feedback email
/// (tester-feedback FR6.1, review R-01), read through the links channel
/// (`deviceInfo`, MainActivity.kt) without any new dependency. Only what the
/// person sees in the email before sending it; nothing is stored or sent by
/// the app (NFR3).
@immutable
class DeviceInfo {
  const DeviceInfo({
    required this.manufacturer,
    required this.model,
    required this.release,
  });

  /// Reads the channel answer; null when it is missing or malformed.
  static DeviceInfo? fromChannel(Object? value) {
    if (value is! Map) return null;
    final manufacturer = value['manufacturer'];
    final model = value['model'];
    final release = value['release'];
    if (manufacturer is! String || model is! String || release is! String) {
      return null;
    }
    return DeviceInfo(
      manufacturer: manufacturer,
      model: model,
      release: release,
    );
  }

  /// `Build.MANUFACTURER`, e.g. `Google`.
  final String manufacturer;

  /// `Build.MODEL`, e.g. `Pixel 8`.
  final String model;

  /// `Build.VERSION.RELEASE`, e.g. `15`.
  final String release;

  /// `Google Pixel 8`; the manufacturer is not repeated when the model
  /// already starts with it (`samsung SM-S911B` stays as is).
  String get displayModel =>
      model.toLowerCase().startsWith(manufacturer.toLowerCase())
      ? model
      : '$manufacturer $model';

  @override
  bool operator ==(Object other) =>
      other is DeviceInfo &&
      other.manufacturer == manufacturer &&
      other.model == model &&
      other.release == release;

  @override
  int get hashCode => Object.hash(manufacturer, model, release);
}
