import 'dart:async';

import 'package:flutter/services.dart';

/// Result of a native preparation (u6 security-design.md §3).
sealed class PrepareResult {
  const PrepareResult();
}

/// A prepared JPEG in `<temporary folder>/label/`.
class PreparedImage extends PrepareResult {
  const PreparedImage(this.path);

  final String path;

  @override
  String toString() => 'PreparedImage()';
}

/// Refused by the native preparer; [code] is `scheme`, `type`, `size`,
/// `format` or `decode`, never a message or a path.
class RejectedImage extends PrepareResult {
  const RejectedImage(this.code);

  final String code;

  @override
  String toString() => 'RejectedImage($code)';
}

/// A share waiting to be read ("Condividi -> Vinoozy", BR1.4).
class SharedImageNotice {
  const SharedImageNotice({required this.multiple, this.isText = false});

  /// Several images were shared: only the first one is used.
  final bool multiple;

  /// A text shared by Google Lens (label-autofill-windows FR2.1), read with
  /// [SharedImageChannel.readSharedText].
  final bool isText;
}

/// The label channel with `MainActivity` (logical-components.md).
///
/// - [prepare]: an image_picker file, checked, reduced and oriented by
///   `LabelImagePreparer`, moved into `label/`;
/// - [pendingShare], [readShare], [discardShare]: the shared image, kept
///   natively as a URI only until [readShare] copies and prepares it
///   (NFR4.5);
/// - [arrivals]: a share received while the app runs;
/// - [openSettings]: the app page of the system settings (BR1.5).
class SharedImageChannel {
  SharedImageChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(name) {
    _channel.setMethodCallHandler(_onCall);
  }

  static const String name = 'com.vinoozy.app/label';

  final MethodChannel _channel;
  final StreamController<SharedImageNotice> _arrivals =
      StreamController<SharedImageNotice>.broadcast();

  Stream<SharedImageNotice> get arrivals => _arrivals.stream;

  Future<Object?> _onCall(MethodCall call) async {
    if (call.method == 'shareArrived') {
      _arrivals.add(
        _noticeOf(call.arguments) ?? const SharedImageNotice(multiple: false),
      );
    }
    return null;
  }

  Future<PrepareResult> prepare(String path) async => _resultOf(
    await _channel.invokeMethod<Object?>('prepare', {'path': path}),
  );

  Future<SharedImageNotice?> pendingShare() async =>
      _noticeOf(await _channel.invokeMethod<Object?>('pendingShare'));

  /// `null` when no share is pending.
  Future<PrepareResult?> readShare() async {
    final result = await _channel.invokeMethod<Object?>('readShare');
    return result == null ? null : _resultOf(result);
  }

  Future<void> discardShare() => _channel.invokeMethod<void>('discardShare');

  /// The shared text, taken out once (label-autofill-windows FR2.1); `null`
  /// when the pending share is not a text. Kept in memory only (BR2.3).
  Future<String?> readSharedText() =>
      _channel.invokeMethod<String>('readSharedText');

  Future<bool> openSettings() async =>
      await _channel.invokeMethod<bool>('openSettings') ?? false;

  void dispose() {
    _channel.setMethodCallHandler(null);
    unawaited(_arrivals.close());
  }

  static SharedImageNotice? _noticeOf(Object? value) {
    if (value is! Map) return null;
    return SharedImageNotice(
      multiple: value['multiple'] == true,
      isText: value['kind'] == 'text',
    );
  }

  static PrepareResult _resultOf(Object? value) {
    if (value is Map) {
      final path = value['path'];
      if (path is String && path.isNotEmpty) return PreparedImage(path);
      final code = value['rejected'];
      if (code is String) return RejectedImage(code);
    }
    return const RejectedImage('decode');
  }
}
