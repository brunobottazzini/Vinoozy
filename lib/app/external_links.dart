import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens a public HTTPS page in the system browser, outside the app.
final externalLinkOpenerProvider = Provider<Future<bool> Function(String)>(
  (ref) => openExternalLink,
);

Future<bool> openExternalLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return false;
  try {
    return await const MethodChannel('com.vinoozy.app/links')
            .invokeMethod<bool>('open', {'url': url}) ??
        false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}
