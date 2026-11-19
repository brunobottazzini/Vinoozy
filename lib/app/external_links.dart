import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_info.dart';
import 'error_reporter.dart';
import 'providers.dart' show errorReporterProvider;

/// The links channel (MainActivity.kt, LinksChannelHandler.kt). It opens
/// only an `https` page, the email app towards the fixed support address and
/// reads the phone model; no other scheme (tester-feedback NFR7).
const MethodChannel _links = MethodChannel('com.vinoozy.app/links');

/// Called with a platform failure, so it is reported and never silent.
typedef PlatformErrorHandler = void Function(Object error, StackTrace stack);

/// Opens a public HTTPS page in the system browser, outside the app.
final externalLinkOpenerProvider = Provider<Future<bool> Function(String)>(
  (ref) => openExternalLink,
);

/// Opens the feedback email (FR6.1); false when no email app handles it.
typedef SupportEmailOpener = Future<bool> Function({
  required String subject,
  required String body,
});

final supportEmailOpenerProvider = Provider<SupportEmailOpener>(
  (ref) =>
      ({required subject, required body}) => openSupportEmail(
        subject: subject,
        body: body,
        onError: (error, stack) => reportPlatformError(
          () => ref.read(errorReporterProvider),
          error,
          stack,
          'SupportEmailFailed',
        ),
      ),
);

/// Reads the phone model and Android version (FR6.1); null when unknown.
final deviceInfoReaderProvider = Provider<Future<DeviceInfo?> Function()>(
  (ref) =>
      () => readDeviceInfo(
        onError: (error, stack) => reportPlatformError(
          () => ref.read(errorReporterProvider),
          error,
          stack,
          'DeviceInfoFailed',
        ),
      ),
);

Future<bool> openExternalLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return false;
  try {
    return await _links.invokeMethod<bool>('open', {'url': url}) ?? false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}

/// The email app with the support address (set on the Android side, never
/// passed from here), [subject] and [body]. The person reviews and sends it
/// (FR6.2). False when no email app exists (FR6.3) or the platform failed;
/// a failure goes to [onError].
Future<bool> openSupportEmail({
  required String subject,
  required String body,
  PlatformErrorHandler? onError,
}) async {
  try {
    return await _links.invokeMethod<bool>('email', {
          'subject': subject,
          'body': body,
        }) ??
        false;
  } on PlatformException catch (error, stack) {
    onError?.call(error, stack);
    return false;
  } on MissingPluginException catch (error, stack) {
    onError?.call(error, stack);
    return false;
  }
}

/// The phone model and Android version, or null (the feedback email then
/// leaves those lines out); a failure goes to [onError].
Future<DeviceInfo?> readDeviceInfo({PlatformErrorHandler? onError}) async {
  try {
    return DeviceInfo.fromChannel(
      await _links.invokeMethod<Object?>('deviceInfo'),
    );
  } on PlatformException catch (error, stack) {
    onError?.call(error, stack);
    return null;
  } on MissingPluginException catch (error, stack) {
    onError?.call(error, stack);
    return null;
  }
}

/// Reports through the app's [errorReporterProvider], read by [readReporter]
/// (`() => ref.read(errorReporterProvider)` from a provider or a widget);
/// where none is injected (a widget test of another unit) the failure is
/// printed instead.
void reportPlatformError(
  ErrorReporter Function() readReporter,
  Object error,
  StackTrace stack,
  String reason,
) {
  final ErrorReporter reporter;
  try {
    reporter = readReporter();
  } on Object {
    // Not injected (Riverpod wraps the UnimplementedError of providers.dart).
    debugPrint('$reason: ${error.runtimeType}');
    return;
  }
  unawaited(reporter.report(error, stack, reason: reason));
}
