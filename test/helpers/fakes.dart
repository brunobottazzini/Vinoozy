import 'dart:async';

import 'package:vinoozy/app/error_reporter.dart';
import 'package:vinoozy/core/clock.dart';
import 'package:vinoozy/core/id_generator.dart';
import 'package:vinoozy/sync/ledger/key_value_store.dart';

/// In-memory [KeyValueStore] with optional latency and failure injection.
///
/// The latency makes concurrent read-modify-write races observable, so a test
/// of the ledger's serial queue would fail if the queue were removed.
class InMemoryKeyValueStore implements KeyValueStore {
  InMemoryKeyValueStore({Map<String, String>? initial, this.latency})
    : values = {...?initial};

  final Map<String, String> values;
  final Duration? latency;

  /// When set, the next [write] throws it once.
  Object? failNextWrite;

  /// When set, every [read] throws it.
  Object? failReads;

  int writeCount = 0;

  Future<void> _delay() async {
    if (latency != null) await Future<void>.delayed(latency!);
  }

  @override
  Future<String?> read(String key) async {
    await _delay();
    if (failReads != null) throw failReads!;
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    await _delay();
    final failure = failNextWrite;
    if (failure != null) {
      failNextWrite = null;
      throw failure;
    }
    writeCount++;
    values[key] = value;
  }
}

/// [Clock] whose time is set by the test.
class FakeClock implements Clock {
  FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

/// One error recorded by [RecordingErrorSink].
class RecordedError {
  RecordedError(this.error, this.reason, {required this.fatal});

  final SanitizedError error;
  final String reason;
  final bool fatal;
}

/// [ErrorSink] that keeps what it receives, optionally failing.
class RecordingErrorSink implements ErrorSink {
  final List<RecordedError> recorded = [];
  bool fail = false;

  List<String> get reasons => [for (final r in recorded) r.reason];

  @override
  Future<void> record(
    SanitizedError error,
    StackTrace? stack, {
    required String reason,
    required bool fatal,
  }) async {
    if (fail) throw StateError('sink down');
    recorded.add(RecordedError(error, reason, fatal: fatal));
  }
}

/// [ErrorReporter] wired to a [RecordingErrorSink] with a silent log.
ErrorReporter recordingReporter(
  RecordingErrorSink sink, {
  List<String>? logs,
}) => ErrorReporter(sink, log: (message) => logs?.add(message));

/// [IdGenerator] returning predictable ids: `wine-1`, `wine-2`, ...
class SequenceIdGenerator implements IdGenerator {
  SequenceIdGenerator({this.prefix = 'wine'});

  final String prefix;
  int _next = 1;

  @override
  String newId() => '$prefix-${_next++}';
}
