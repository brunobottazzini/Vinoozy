import 'dart:convert';

import 'package:flutter/foundation.dart' show kReleaseMode;

import '../app/error_reporter.dart';
import '../core/clock.dart';
import '../firebase/options_demo.dart';
import '../sync/ledger/key_value_store.dart';

/// The developer-tools flag (`--dart-define=ENABLE_DEV_CHEATS=true`), false
/// by default. It is not a password: it only lets a development build compile
/// the tools in (study §9.3).
const bool kEnableDevCheatsFlag = bool.fromEnvironment('ENABLE_DEV_CHEATS');

/// Whether the hidden developer tools exist in this build (freemium-plus
/// FR5.1, study §9.3):
///
/// `NOT kReleaseMode AND ENABLE_DEV_CHEATS AND usesEmulators AND
/// projectId == "demo-vinoozy"`.
///
/// A compile-time constant, so every `if (kDevCheatsAvailable)` branch is
/// removed from a release build, even one built with the flag by mistake
/// (FR5.7). `usesEmulators` is the demo environment of
/// `FirebaseEnvConfig`; here only the exact value `demo` counts, which is
/// stricter than `FirebaseEnv.parse` (an odd spelling turns the tools off,
/// never on).
const bool kDevCheatsAvailable =
    !kReleaseMode &&
    kEnableDevCheatsFlag &&
    String.fromEnvironment('FIREBASE_ENV', defaultValue: 'demo') == 'demo' &&
    demoProjectId == devCheatsProjectId;

/// The only project the developer tools may touch.
const String devCheatsProjectId = 'demo-vinoozy';

/// The same rule as [kDevCheatsAvailable] for given values (FR5.1), so it can
/// be checked at run time against the configuration in use, and tested.
bool devCheatsAvailableFor({
  required bool releaseMode,
  required bool flag,
  required bool usesEmulators,
  required String projectId,
}) => !releaseMode && flag && usesEmulators && projectId == devCheatsProjectId;

/// The scenarios of the developer panel (FR5.3). None of them opens a
/// payment, creates a token or a receipt.
enum DevScenario {
  /// "Unlock everything — test Plus": every Plus capability, no limit, no
  /// ads.
  unlockAll('unlockAll'),

  /// "Simulate free plan".
  simulateFree('simulateFree'),

  /// "Simulate expired Plus": the free plan after a Plus, data kept.
  simulateExpired('simulateExpired');

  const DevScenario(this.wireValue);

  final String wireValue;

  static DevScenario? fromWire(Object? value) {
    for (final scenario in values) {
      if (scenario.wireValue == value) return scenario;
    }
    return null;
  }
}

/// A developer scenario in force for one account of the demo project
/// (FR5.5).
class DevOverride {
  const DevOverride({
    required this.scenario,
    required this.uid,
    this.projectId = devCheatsProjectId,
  });

  final DevScenario scenario;
  final String uid;
  final String projectId;

  @override
  bool operator ==(Object other) =>
      other is DevOverride &&
      other.scenario == scenario &&
      other.uid == uid &&
      other.projectId == projectId;

  @override
  int get hashCode => Object.hash(scenario, uid, projectId);
}

/// The developer override saved on the phone only, tied to the account and
/// the demo project (FR5.5, study §9.2). It survives restarts with the same
/// account and project; another account, another project, sign-out and
/// "Restore normal state" remove it. Never shared between accounts or
/// between demo and production.
class DevOverrideStore {
  DevOverrideStore({required this._store, required this._reporter});

  static const String storageKey = 'dev.override.v1';

  final KeyValueStore _store;
  final ErrorReporter _reporter;

  /// The override of [uid] in [projectId]; null when there is none, or when
  /// the saved one belongs to another account or project (it is then
  /// removed).
  Future<DevOverride?> read({
    required String uid,
    required String projectId,
  }) async {
    if (projectId != devCheatsProjectId) return null;
    final saved = await _readRaw();
    if (saved == null) return null;
    if (saved.uid != uid || saved.projectId != projectId) {
      await clear();
      return null;
    }
    return saved;
  }

  /// Saves [override]; only for the demo project.
  Future<void> write(DevOverride override) async {
    if (override.projectId != devCheatsProjectId) {
      throw ArgumentError.value(override.projectId, 'projectId');
    }
    await _store.write(
      storageKey,
      jsonEncode({
        'scenario': override.scenario.wireValue,
        'uid': override.uid,
        'projectId': override.projectId,
      }),
    );
  }

  /// "Restore normal state", sign-out, account or environment change.
  Future<void> clear() async {
    try {
      await _store.write(storageKey, '');
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'DevOverrideFailed');
    }
  }

  Future<DevOverride?> _readRaw() async {
    try {
      final raw = await _store.read(storageKey);
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw);
      if (json is! Map<String, Object?>) return null;
      final scenario = DevScenario.fromWire(json['scenario']);
      final uid = json['uid'];
      final projectId = json['projectId'];
      if (scenario == null || uid is! String || projectId is! String) {
        return null;
      }
      return DevOverride(scenario: scenario, uid: uid, projectId: projectId);
    } on FormatException {
      return null;
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'DevOverrideFailed');
      return null;
    }
  }
}

/// One step of the hidden sequence (FR5.2).
enum DevGestureStep {
  /// A tap on the Bottazzini logo at the bottom of the Dashboard.
  logo,

  /// A tap on "Cellar" in the navigation bar.
  cellar,

  /// A tap on "History" in the navigation bar.
  history,

  /// A tap on "Dashboard" in the navigation bar.
  dashboard,
}

/// Recognises the owner's hidden sequence that opens the developer panel
/// (freemium-plus FR5.2): two taps on the logo, then in the navigation bar
/// Cellar ×3, History ×3, Cellar, History, Dashboard, all within 20 seconds
/// of the first tap. A wrong step, the time running out or leaving the app
/// ([reset]) start it again. The detector only listens; the screens report
/// the steps, and only inside `if (kDevCheatsAvailable)`.
class SecretSequenceDetector {
  SecretSequenceDetector({
    this._clock = const SystemClock(),
    this._window = const Duration(seconds: 20),
  });

  static const List<DevGestureStep> sequence = [
    DevGestureStep.logo,
    DevGestureStep.logo,
    DevGestureStep.cellar,
    DevGestureStep.cellar,
    DevGestureStep.cellar,
    DevGestureStep.history,
    DevGestureStep.history,
    DevGestureStep.history,
    DevGestureStep.cellar,
    DevGestureStep.history,
    DevGestureStep.dashboard,
  ];

  final Clock _clock;
  final Duration _window;

  int _matched = 0;
  DateTime? _startedAt;

  /// How many steps of the sequence are matched so far.
  int get progress => _matched;

  /// Registers [step]; true only when it completes the sequence in time (the
  /// detector then starts again).
  bool register(DevGestureStep step) {
    final now = _clock.now();
    final started = _startedAt;
    if (started != null && now.difference(started) > _window) reset();
    if (sequence[_matched] != step) {
      reset();
      // A wrong step may be the first step of a new attempt.
      if (sequence.first != step) return false;
    }
    if (_matched == 0) _startedAt = now;
    _matched++;
    if (_matched < sequence.length) return false;
    reset();
    return true;
  }

  /// Starts again (leaving the app, a timeout, a wrong step).
  void reset() {
    _matched = 0;
    _startedAt = null;
  }
}
