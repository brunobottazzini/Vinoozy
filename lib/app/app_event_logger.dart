import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the text that filled the add form came from (label-autofill-windows
/// NFR4.15).
enum AutofillOrigin { photo, paste, share, auto }

/// How a text ended: fields filled, nothing found, or a sure wine proposed.
enum AutofillOutcome { filled, noFields, sureMatch }

/// What "From Google Lens" opened (BR2.5).
enum LensOpenResult { lensApp, googleApp, unavailable }

/// Informative events of label-autofill-windows (NFR4.15): only enums and
/// numbers, never a text, a wine name or a denomination (NFR3.2), so a
/// call can never leak what the label said.
abstract interface class AppEventLogger {
  void autofillResult(
    AutofillOrigin origin,
    AutofillOutcome outcome,
    int fieldCount,
  );

  void lensOpen(LensOpenResult result);

  void estimatesMigrated(int wineCount, int durationMs);
}

/// Prints the events through [sink] when [debugLogging] is on (the debug
/// build), nothing otherwise: they never go to Crashlytics.
class ConsoleAppEventLogger implements AppEventLogger {
  const ConsoleAppEventLogger({
    required this.debugLogging,
    void Function(String message)? sink,
  }) : _sink = sink ?? _discard;

  final bool debugLogging;
  final void Function(String message) _sink;

  static void _discard(String message) {}

  void _print(String message) {
    if (debugLogging) _sink('app: $message');
  }

  @override
  void autofillResult(
    AutofillOrigin origin,
    AutofillOutcome outcome,
    int fieldCount,
  ) => _print(
    'autofill_result (${origin.name}, ${outcome.name}, $fieldCount fields)',
  );

  @override
  void lensOpen(LensOpenResult result) => _print('lens_open (${result.name})');

  @override
  void estimatesMigrated(int wineCount, int durationMs) =>
      _print('estimates_migrated ($wineCount wines, $durationMs ms)');
}

/// The informative event logger of the app.
final appEventLoggerProvider = Provider<AppEventLogger>(
  (ref) =>
      const ConsoleAppEventLogger(debugLogging: kDebugMode, sink: _debugPrint),
);

void _debugPrint(String message) => debugPrint(message);
