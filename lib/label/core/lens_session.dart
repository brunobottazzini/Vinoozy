// "From Google Lens" and the automatic paste when coming back from it
// (label-autofill-windows FR2.6, FR2.7, BR2.5, BR2.6, ENT-006, NFR3.1).
// Pure Dart: the native side is in platform/lens_channel.dart.

/// What "From Google Lens" opened (BR2.5).
enum LensCameraRoute { lensApp, googleApp, unavailable }

/// The answer of [LensCamera.openLensCamera]: the route and, when Lens
/// opened, the system time it opened in milliseconds (review R-08).
class LensCameraOpening {
  const LensCameraOpening(this.route, {this.openedAt});

  static const LensCameraOpening unavailable = LensCameraOpening(
    LensCameraRoute.unavailable,
  );

  final LensCameraRoute route;
  final int? openedAt;

  bool get opened => route != LensCameraRoute.unavailable && openedAt != null;
}

/// The description of the clipboard, never its content: the copy time
/// (system milliseconds) and the first MIME type (BR2.6).
class ClipInfo {
  const ClipInfo({required this.timestamp, required this.mime});

  final int timestamp;
  final String mime;

  bool get isText => mime.startsWith('text/');

  @override
  bool operator ==(Object other) =>
      other is ClipInfo && other.timestamp == timestamp && other.mime == mime;

  @override
  int get hashCode => Object.hash(timestamp, mime);
}

/// Google Lens and the clipboard description on the phone; a fake in tests.
abstract interface class LensCamera {
  /// Opens Lens (BR2.5). Never throws: a failure is
  /// [LensCameraOpening.unavailable].
  Future<LensCameraOpening> openLensCamera();

  /// The clipboard description; `null` below Android 8.0, without a clip
  /// or when the system refuses. Never throws.
  Future<ClipInfo?> clipTimestamp();

  /// The window got the focus (Android 10+ reads the clipboard only then).
  Stream<void> get windowFocused;
}

/// Reads the text of the clipboard (Flutter `Clipboard` in the app, a fake
/// in tests). Called only on a tap of "Paste from Lens" or once by the
/// automatic paste (NFR3.1). Never throws: `null` when there is no text or
/// it cannot be read (NFR4.10).
abstract interface class ClipboardReader {
  Future<String?> readText();
}

/// One trip to Lens started by "From Google Lens" (ENT-006): in memory
/// only, valid [maxAge] from [openedAt].
class LensSession {
  LensSession({required this.openedAt});

  /// The automatic paste works within 5 minutes of the opening (FR2.7).
  static const Duration maxAge = Duration(minutes: 5);

  /// System milliseconds when Lens was opened.
  final int openedAt;

  /// The copy time of the text already pasted, so the same text is never
  /// pasted twice by itself (FR2.7).
  int? consumedClipTimestamp;

  /// Whether the session is still valid at [nowMillis].
  bool isFresh(int nowMillis) =>
      nowMillis >= openedAt && nowMillis - openedAt < maxAge.inMilliseconds;

  /// BR2.6: read the clipboard by itself only when the session is fresh and
  /// [clip] is a text copied after Lens opened and not pasted yet.
  bool shouldPaste(ClipInfo? clip, int nowMillis) =>
      clip != null &&
      clip.isText &&
      isFresh(nowMillis) &&
      clip.timestamp > openedAt &&
      clip.timestamp != consumedClipTimestamp;
}

/// The automatic paste on the way back from Lens (FR2.7, BR2.6, NFR3.1,
/// NFR3.7): the clipboard description first, its content only when
/// [LensSession.shouldPaste] allows it, and then once: the text is marked
/// as consumed before it is read, so a text that gives nothing is never
/// tried again.
class LensAutoPaste {
  const LensAutoPaste({
    required this._camera,
    required this._clipboard,
    required this._nowMillis,
  });

  final LensCamera _camera;
  final ClipboardReader _clipboard;
  final int Function() _nowMillis;

  /// The text to paste for [session], or `null` (nothing is read then).
  Future<String?> take(LensSession? session) async {
    if (session == null || !session.isFresh(_nowMillis())) return null;
    final clip = await _camera.clipTimestamp();
    if (!session.shouldPaste(clip, _nowMillis())) return null;
    session.consumedClipTimestamp = clip!.timestamp;
    return _clipboard.readText();
  }
}
