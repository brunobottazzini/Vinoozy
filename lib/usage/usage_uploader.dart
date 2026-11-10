import 'dart:async';
import 'dart:convert';

import '../app/error_reporter.dart';
import '../core/clock.dart';
import '../sync/ledger/key_value_store.dart';
import 'cloud_usage_meter.dart';
import 'domain/usage_counters.dart';
import 'usage_cost.dart';

/// One upload to the backend `reportUsage` (study §7.6, freemium-plus
/// FR6.3): the cumulative personal counters of this installation for one
/// UTC month. The uid comes from the authentication on the server; only
/// numbers and identifiers travel (NFR6).
class UsageReport {
  const UsageReport({
    required this.installationId,
    required this.periodId,
    required this.sequence,
    required this.cumulative,
    required this.policyVersion,
  });

  final String installationId;
  final String periodId;

  /// Grows by one for every new cumulative; a retry of the same cumulative
  /// keeps it, so the server can tell a retry from a new report.
  final int sequence;
  final UsageCounters cumulative;
  final String policyVersion;
}

/// The backend's answer (FR6.3): the account total of the period, the
/// server time and the next reset.
class UsageReportResult {
  const UsageReportResult({
    required this.accepted,
    required this.accountTotal,
    required this.serverTime,
    required this.nextResetUtc,
    this.reason,
  });

  /// `reportUsage` refuses a month older than the previous one for good
  /// (functions/README.md): its counters can be forgotten.
  static const String periodClosed = 'PERIOD_CLOSED';

  /// False when the server refused the report (a repeated sequence with
  /// other values, decreasing cumulatives): the next report uses a new
  /// sequence, except for [periodClosed].
  final bool accepted;

  /// The server's reason of a refusal (`SEQUENCE_CONFLICT`,
  /// `STALE_SEQUENCE`, `DECREASING_CUMULATIVE`, `TOO_FREQUENT`,
  /// `PERIOD_CLOSED`, `PERIOD_NOT_STARTED`); null when accepted.
  final String? reason;

  /// What the server counts for the account in that period, every device.
  final UsageCounters accountTotal;
  final DateTime serverTime;
  final DateTime nextResetUtc;
}

/// The call to `reportUsage` (authenticated, with App Check). Injected, so
/// the uploader is tested without the network.
abstract interface class UsageReportClient {
  Future<UsageReportResult> report(UsageReport report);
}

/// What the uploader knows of one period.
class _PeriodState {
  _PeriodState({
    this.sequence = 0,
    this.sent = UsageCounters.zero,
    this.acknowledged = UsageCounters.zero,
    this.serverTotal = UsageCounters.zero,
    this.verified = false,
  });

  /// The sequence and cumulative of the last report sent.
  int sequence;
  UsageCounters sent;

  /// The last cumulative the server accepted for this installation.
  UsageCounters acknowledged;

  /// The account total the server answered with.
  UsageCounters serverTotal;

  /// Whether the server answered for this period at least once.
  bool verified;

  Map<String, Object?> toJson() => {
    'q': sequence,
    's': _list(sent),
    'a': _list(acknowledged),
    't': _list(serverTotal),
    'v': verified,
  };

  static List<int> _list(UsageCounters c) => [c.reads, c.writes, c.egressBytes];

  static _PeriodState? fromJson(Object? json) {
    if (json is! Map) return null;
    final sequence = json['q'];
    final verified = json['v'];
    if (sequence is! int || verified is! bool) return null;
    return _PeriodState(
      sequence: sequence,
      sent: _counters(json['s']),
      acknowledged: _counters(json['a']),
      serverTotal: _counters(json['t']),
      verified: verified,
    );
  }

  static UsageCounters _counters(Object? value) {
    if (value is! List || value.length != 3) return UsageCounters.zero;
    int at(int i) =>
        value[i] is int && (value[i] as int) >= 0 ? value[i] as int : 0;
    return UsageCounters(reads: at(0), writes: at(1), egressBytes: at(2));
  }
}

/// Sends the meter's cumulative counters to the backend (freemium-plus
/// FR6.3, NFR3, study §7.6) and gives the account total the app decides on.
///
/// - When: at the end of a session ([onPause]), every 15 minutes while the
///   app is open, and at the first local crossing of the threshold; never
///   more often than every 15 minutes except at the end of a session, so a
///   one-hour session makes at most 5 uploads.
/// - What: cumulatives, so a retry with the same values is idempotent; the
///   sequence grows only with new values. A late upload of last month goes to
///   last month.
/// - The total used to decide is the server total plus only the local delta
///   after the last cumulative the server acknowledged: never the server
///   total plus all of the local one.
class UsageUploader {
  UsageUploader({
    required this._meter,
    required this._client,
    required this._store,
    required this._reporter,
    this._clock = const SystemClock(),
    this._interval = const Duration(minutes: 15),
    String Function()? budgetEuro,
    String Function()? policyVersion,
    Timer Function(Duration, void Function(Timer))? periodic,
  }) : _budgetEuro = budgetEuro ?? _defaultBudget,
       _policyVersion = policyVersion ?? _defaultVersion,
       _periodic = periodic ?? Timer.periodic;

  static String _defaultBudget() => '0.005';
  static String _defaultVersion() => 'freemium-v1';

  static const String storagePrefix = 'usage.upload.v1/';

  final CloudUsageMeter _meter;
  final UsageReportClient _client;
  final KeyValueStore _store;
  final ErrorReporter _reporter;
  final Clock _clock;
  final Duration _interval;
  final String Function() _budgetEuro;
  final String Function() _policyVersion;
  final Timer Function(Duration, void Function(Timer)) _periodic;

  Map<String, _PeriodState> _periods = {};
  String? _uid;
  Timer? _timer;
  StreamSubscription<UsagePeriod>? _changes;
  DateTime? _lastUpload;
  bool _uploading = false;
  final Set<String> _crossingSent = {};

  /// Months the server closed in this upload round (PERIOD_CLOSED).
  final Set<String> _closed = {};
  final StreamController<void> _updates = StreamController<void>.broadcast();

  /// How many uploads ran (NFR3).
  int uploads = 0;

  /// Fires after every upload round, so the screens read [isVerified] and
  /// [isAboveBudget] again (freemium-plus FR7.5).
  Stream<void> get updates => _updates.stream;

  /// Starts for the account the meter counts now, with its saved state.
  Future<void> start() async {
    final uid = _meter.uid;
    if (uid == null) return;
    _uid = uid;
    _periods = await _load(uid);
    await _changes?.cancel();
    _changes = _meter.changes.listen(_onMeterChange);
  }

  /// Stops (sign-out); the state stays saved.
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await _changes?.cancel();
    _changes = null;
    _uid = null;
    _periods = {};
    _crossingSent.clear();
  }

  /// The app is in the foreground: uploads every [_interval].
  void onResume() {
    _timer?.cancel();
    _timer = _periodic(_interval, (_) => unawaited(tick()));
  }

  /// The app goes to the background or the session ends: one upload now.
  Future<void> onPause() async {
    _timer?.cancel();
    _timer = null;
    await uploadNow();
  }

  /// The periodic upload, at most every [_interval].
  Future<void> tick() async {
    if (!_due()) return;
    await uploadNow();
  }

  /// The total the app decides on for [period]: server total + the local
  /// delta after the last acknowledged cumulative (study §7.6).
  UsageCounters estimatedTotal(UsagePeriod period) {
    final state = _periods[period.id];
    final local = _meter.periods[period.id]?.personal ?? UsageCounters.zero;
    if (state == null) return local;
    final delta = local.deltaSince(state.acknowledged) ?? UsageCounters.zero;
    return state.serverTotal + delta;
  }

  /// Whether the server answered for [period]: without it the state is not
  /// verified and no ad is ever shown (NFR4).
  bool isVerified(UsagePeriod period) => _periods[period.id]?.verified ?? false;

  /// `C_hat` of [period] strictly above the budget (FR6.2).
  bool isAboveBudget(UsagePeriod period) =>
      UsageCost.isAboveBudget(estimatedTotal(period), _budgetEuro());

  /// Sends every period with counters the server has not acknowledged.
  /// Errors are reported and the same cumulative is sent again later.
  Future<void> uploadNow() async {
    final uid = _uid;
    if (uid == null || _uploading) return;
    _uploading = true;
    try {
      await _meter.flush();
      final installation = _meter.installationId;
      if (installation == null) return;
      for (final entry in _meter.periods.entries.toList()) {
        await _upload(installation, entry.key, entry.value.personal);
      }
      _lastUpload = _clock.now();
      await _save(uid);
      await _forgetDone();
    } finally {
      _uploading = false;
      if (!_updates.isClosed) _updates.add(null);
    }
  }

  Future<void> _upload(
    String installation,
    String periodId,
    UsageCounters cumulative,
  ) async {
    final state = _periods.putIfAbsent(periodId, _PeriodState.new);
    if (state.verified && cumulative == state.acknowledged) return;
    if (cumulative != state.sent || state.sequence == 0) {
      state
        ..sequence += 1
        ..sent = cumulative;
    }
    try {
      uploads++;
      final result = await _client.report(
        UsageReport(
          installationId: installation,
          periodId: periodId,
          sequence: state.sequence,
          cumulative: cumulative,
          policyVersion: _policyVersion(),
        ),
      );
      _meter.serverOffset = result.serverTime.toUtc().difference(
        _clock.now().toUtc(),
      );
      if (!result.accepted && result.reason == UsageReportResult.periodClosed) {
        // The month will never be accepted again: drop its pending
        // cumulatives instead of retrying them with a new sequence.
        _closed.add(periodId);
        return;
      }
      if (!result.accepted) {
        // The next report gets a new sequence with the same values.
        state.sent = UsageCounters.zero;
        return;
      }
      state
        ..acknowledged = cumulative
        ..serverTotal = result.accountTotal
        ..verified = true;
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'UsageUploadFailed');
    }
  }

  /// A period before the current one, fully acknowledged, is done: the
  /// meter and the uploader forget it.
  Future<void> _forgetDone() async {
    final current = _meter.currentPeriod.id;
    for (final id in _closed.toList()) {
      if (id.compareTo(current) >= 0) continue;
      await _meter.forget(id);
      _periods.remove(id);
    }
    _closed.clear();
    for (final id in _periods.keys.toList()) {
      final local = _meter.periods[id]?.personal;
      final state = _periods[id]!;
      if (id.compareTo(current) >= 0) continue;
      if (local != null && local != state.acknowledged) continue;
      await _meter.forget(id);
      _periods.remove(id);
    }
    final uid = _uid;
    if (uid != null) await _save(uid);
  }

  void _onMeterChange(UsagePeriod period) {
    if (_crossingSent.contains(period.id) || !isAboveBudget(period)) return;
    // The first local crossing: sent at once unless an upload just ran; the
    // next tick sends it then (NFR3).
    _crossingSent.add(period.id);
    if (_due()) {
      unawaited(uploadNow());
      _restartTimer();
    }
  }

  /// Restarts the periodic timer after an off-schedule upload, so the next
  /// one comes a full interval later.
  void _restartTimer() {
    if (_timer != null) onResume();
  }

  bool _due() {
    final last = _lastUpload;
    return last == null || _clock.now().difference(last) >= _interval;
  }

  Future<Map<String, _PeriodState>> _load(String uid) async {
    try {
      final raw = await _store.read('$storagePrefix$uid');
      if (raw == null || raw.isEmpty) return {};
      final json = jsonDecode(raw);
      if (json is! Map) return {};
      return {
        for (final entry in json.entries)
          if (UsagePeriod.tryParse('${entry.key}') != null &&
              _PeriodState.fromJson(entry.value) != null)
            '${entry.key}': _PeriodState.fromJson(entry.value)!,
      };
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'UsageUploadLoadFailed');
      return {};
    }
  }

  Future<void> _save(String uid) async {
    try {
      await _store.write(
        '$storagePrefix$uid',
        jsonEncode({
          for (final entry in _periods.entries) entry.key: entry.value.toJson(),
        }),
      );
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'UsageUploadSaveFailed');
    }
  }

  /// Forgets the saved state of [uid] (account change, deletion).
  Future<void> clear(String uid) async {
    if (_uid == uid) _periods = {};
    try {
      await _store.write('$storagePrefix$uid', '');
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'UsageUploadSaveFailed');
    }
  }
}
