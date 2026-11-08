// Shared fakes of the catalog tests: simulated clock and timers (no test
// waits on real time), in-memory cache file, recording event logger and the
// recorded Open Food Facts answers of test/catalog/fixtures/.
import 'dart:async';
import 'dart:io';

import 'package:vinoozy/catalog/core/catalog_cache_store.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/core/clock.dart';

/// Contents of a recorded answer.
String fixture(String name) =>
    File('test/catalog/fixtures/$name').readAsStringSync();

/// Clock moved by hand.
class FakeClock implements Clock {
  FakeClock([DateTime? start]) : current = start ?? DateTime.utc(2026, 11, 5);

  DateTime current;

  @override
  DateTime now() => current;

  void advance(Duration duration) => current = current.add(duration);
}

/// Timer fired by hand through [FakeTimers].
class FakeTimer implements Timer {
  FakeTimer(this.duration, this._callback);

  final Duration duration;
  final void Function() _callback;
  bool _active = true;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;

  @override
  void cancel() => _active = false;

  void fire() {
    if (!_active) return;
    _active = false;
    _callback();
  }
}

/// Timer factory that records every timer instead of scheduling it.
class FakeTimers {
  final List<FakeTimer> created = [];

  Timer call(Duration duration, void Function() callback) {
    final timer = FakeTimer(duration, callback);
    created.add(timer);
    return timer;
  }

  List<FakeTimer> get active => created.where((t) => t.isActive).toList();

  /// Fires every active timer of [duration].
  void fireAll([Duration? duration]) {
    for (final timer in active) {
      if (duration == null || timer.duration == duration) timer.fire();
    }
  }
}

/// `CacheFile` kept in memory, with switches to simulate failures and a gate
/// to hold a write in progress.
class InMemoryCacheFile implements CacheFile {
  InMemoryCacheFile([this.contents]);

  String? contents;
  String? temp;
  bool failReads = false;
  bool failWrites = false;
  bool failDeletes = false;
  Completer<void>? writeGate;
  int commits = 0;
  int deletes = 0;

  @override
  Future<String?> read() async {
    if (failReads) throw const FileSystemException('read failed');
    return contents;
  }

  @override
  Future<void> writeTemp(String value) async {
    if (failWrites) throw const FileSystemException('write failed');
    temp = value;
    final gate = writeGate;
    if (gate != null) await gate.future;
  }

  @override
  Future<void> commitTemp() async {
    contents = temp;
    temp = null;
    commits++;
  }

  @override
  Future<void> deleteTemp() async => temp = null;

  @override
  Future<void> deleteAll() async {
    if (failDeletes) throw const FileSystemException('delete failed');
    deletes++;
    contents = null;
    temp = null;
  }
}

/// Event logger that keeps everything it receives.
class RecordingLogger implements CatalogEventLogger {
  final List<(OffFailure, CatalogHealthSnapshot)> suspensions = [];
  final List<CatalogDebugEvent> debugEvents = [];
  final List<OffFailure?> debugFailures = [];

  @override
  void offSuspended(OffFailure lastFailure, CatalogHealthSnapshot health) {
    suspensions.add((lastFailure, health));
  }

  @override
  void debug(CatalogDebugEvent event, {OffFailure? failure}) {
    debugEvents.add(event);
    debugFailures.add(failure);
  }

  // label-recognition events (NFR4.13-NFR4.15).
  final List<(int, int)> wineDbOpenings = [];
  final List<(WineDbFailure, int)> wineDbFailures = [];
  final List<(LabelOutcomeKind, LabelMatchStep)> labelOutcomes = [];
  final List<(int, int, bool)> onlineSearches = [];
  final List<LensRoute> lensRoutes = [];

  @override
  void wineDbOpened(int wineCount, int durationMs) =>
      wineDbOpenings.add((wineCount, durationMs));

  @override
  void wineDbUnavailable(WineDbFailure reason, int skippedRows) =>
      wineDbFailures.add((reason, skippedRows));

  @override
  void labelOutcome(LabelOutcomeKind kind, LabelMatchStep step) =>
      labelOutcomes.add((kind, step));

  @override
  void onlineSearch(
    int offlineCount,
    int onlineCount, {
    required bool limited,
  }) => onlineSearches.add((offlineCount, onlineCount, limited));

  @override
  void lensOpened(LensRoute route) => lensRoutes.add(route);

  /// Everything recorded, as text, to look for marker values (NFR8.3).
  String get everything => [
    for (final (failure, health) in suspensions)
      '${failure.label} ${health.offOk} ${health.offFailed} '
          '${health.cacheHitRatio} ${health.cacheResets}',
    for (final event in debugEvents) event.name,
    for (final failure in debugFailures) '${failure?.label}',
    for (final (count, ms) in wineDbOpenings) 'opened $count $ms',
    for (final (reason, skipped) in wineDbFailures) '${reason.name} $skipped',
    for (final (kind, step) in labelOutcomes) '${kind.name} ${step.name}',
    for (final (off, on, limited) in onlineSearches) '$off $on $limited',
    for (final route in lensRoutes) route.name,
  ].join('\n');
}

/// Lets pending microtasks and future callbacks run.
Future<void> settle() => Future<void>.delayed(Duration.zero);
