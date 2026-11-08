// Fakes of label-autofill-windows for widget tests: Google Lens opened
// directly, the clipboard (never the real one) and the informative events.
// No real Google app, no real clipboard, no network.
import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:vinoozy/app/app_event_logger.dart';
import 'package:vinoozy/label/autofill_providers.dart';
import 'package:vinoozy/label/core/lens_session.dart';

/// "From Google Lens" and the clipboard description, driven by the test.
class FakeLensCamera implements LensCamera {
  /// What the next opening answers.
  LensCameraOpening opening = LensCameraOpening.unavailable;

  /// The clipboard description; `null` is "nothing to say".
  ClipInfo? clip;
  int openCalls = 0;
  int clipCalls = 0;
  final StreamController<void> focus = StreamController<void>.broadcast();

  @override
  Future<LensCameraOpening> openLensCamera() async {
    openCalls++;
    return opening;
  }

  @override
  Future<ClipInfo?> clipTimestamp() async {
    clipCalls++;
    return clip;
  }

  @override
  Stream<void> get windowFocused => focus.stream;
}

/// The clipboard text; [reads] counts every read (NFR3.1).
class FakeClipboard implements ClipboardReader {
  String? text;
  int reads = 0;

  @override
  Future<String?> readText() async {
    reads++;
    return text;
  }
}

/// The events of NFR4.15, as plain strings.
class RecordingEventLogger implements AppEventLogger {
  final List<String> events = [];

  @override
  void autofillResult(
    AutofillOrigin origin,
    AutofillOutcome outcome,
    int fieldCount,
  ) => events.add('autofill ${origin.name} ${outcome.name} $fieldCount');

  @override
  void lensOpen(LensOpenResult result) => events.add('lens ${result.name}');

  @override
  void estimatesMigrated(int wineCount, int durationMs) =>
      events.add('migrated $wineCount');
}

/// The three fakes, ready for a ProviderScope.
class AutofillFakes {
  final camera = FakeLensCamera();
  final clipboard = FakeClipboard();
  final events = RecordingEventLogger();

  List<Override> get overrides => [
    lensCameraProvider.overrideWithValue(camera),
    clipboardReaderProvider.overrideWithValue(clipboard),
    appEventLoggerProvider.overrideWithValue(events),
  ];
}
