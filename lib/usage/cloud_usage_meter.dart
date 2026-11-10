import 'dart:async';
import 'dart:convert';

import '../app/error_reporter.dart';
import '../core/clock.dart';
import '../core/id_generator.dart';
import '../sync/ledger/key_value_store.dart';
import 'domain/usage_counters.dart';

/// Who a Firestore operation is attributed to (study §7.3, freemium-plus
/// FR6.4).
enum UsageScope {
  /// An operation of the person's ordinary use: it counts towards the
  /// personal monthly threshold.
  personal,

  /// Deletions, account deletion, export, migrations, automatic estimate
  /// updates, recoveries from errors: counted apart, never in the personal
  /// threshold.
  system,
}

/// The counters of one UTC month, personal and system apart.
class PeriodUsage {
  const PeriodUsage({
    this.personal = UsageCounters.zero,
    this.system = UsageCounters.zero,
  });

  final UsageCounters personal;
  final UsageCounters system;

  PeriodUsage add(UsageScope scope, UsageCounters usage) =>
      scope == UsageScope.personal
      ? PeriodUsage(personal: personal + usage, system: system)
      : PeriodUsage(personal: personal, system: system + usage);

  @override
  bool operator ==(Object other) =>
      other is PeriodUsage &&
      other.personal == personal &&
      other.system == system;

  @override
  int get hashCode => Object.hash(personal, system);
}

/// Estimated Firestore usage of the signed-in account on this installation
/// (freemium-plus FR6.1, study §7.5): reads, confirmed writes and bytes
/// received, per account, UTC month and installation, cumulative.
///
/// The repositories call it once where an operation starts or is confirmed,
/// before mapping to domain models, so the consumers never multiply it.
/// It never touches the network: the counters are saved on the phone and the
/// uploader sends them. Only numbers are kept, never content (NFR6).
class CloudUsageMeter {
  CloudUsageMeter({
    required this._store,
    required this._reporter,
    this._clock = const SystemClock(),
    IdGenerator? ids,
  }) : _ids = ids ?? RandomIdGenerator();

  static const String storagePrefix = 'usage.meter.v1/';
  static const String installationKey = 'usage.installation.v1';

  /// B_hat fallback of study §7.5: 2 KiB per document received from the
  /// server; an empty query adds a read but no bytes.
  static const int bytesPerDocument = 2048;

  final KeyValueStore _store;
  final ErrorReporter _reporter;
  final Clock _clock;
  final IdGenerator _ids;

  String? _uid;
  String? _installationId;
  Map<String, PeriodUsage> _periods = {};
  final Map<String, _SharedListen> _shared = {};
  final StreamController<UsagePeriod> _changes =
      StreamController<UsagePeriod>.broadcast();

  bool _saving = false;
  bool _dirty = false;
  Future<void> _saved = Future<void>.value();

  /// Difference between the server time (from the last upload answer) and
  /// the phone clock, so the period follows the server (study §7.6).
  Duration serverOffset = Duration.zero;

  /// The account counted now; null before sign-in.
  String? get uid => _uid;

  /// This installation: a new id after a reinstall, the account stays.
  String? get installationId => _installationId;

  /// Every period with usage of [uid], by `YYYY-MM` id.
  Map<String, PeriodUsage> get periods => Map.unmodifiable(_periods);

  /// The period of every change, when it happens (the uploader listens).
  Stream<UsagePeriod> get changes => _changes.stream;

  /// The current UTC month by the estimated server time.
  UsagePeriod get currentPeriod =>
      UsagePeriod.containing(_clock.now().toUtc().add(serverOffset));

  /// Starts counting for [uid], with its saved counters. Operations before
  /// this (or after [stop]) are not counted: they belong to no account.
  Future<void> start(String uid) async {
    _uid = uid;
    _installationId = await _installation();
    _periods = await _load(uid);
    _shared.clear();
  }

  /// Stops counting (sign-out); the saved counters stay for the uploader.
  Future<void> stop() async {
    await flush();
    _uid = null;
    _periods = {};
    _shared.clear();
  }

  /// Forgets the saved counters of [uid] (account change, deletion).
  Future<void> clear(String uid) async {
    if (_uid == uid) _periods = {};
    await _write('$storagePrefix$uid', '');
  }

  /// Drops [periodId] once the server acknowledged all of it and the month
  /// is over (the uploader decides).
  Future<void> forget(String periodId) async {
    if (_periods.remove(periodId) != null) await _persist();
  }

  /// A query answered by the server: `max(1, documents)` reads and 2 KiB per
  /// document (study §7.5). A query answered by the cache is not counted.
  void recordQuery({
    required int documents,
    UsageScope scope = UsageScope.personal,
  }) => _add(
    scope,
    UsageCounters(
      reads: documents < 1 ? 1 : documents,
      egressBytes: documents * bytesPerDocument,
    ),
  );

  /// A single document read from the server.
  void recordDocument({
    required bool exists,
    UsageScope scope = UsageScope.personal,
  }) => _add(
    scope,
    UsageCounters(reads: 1, egressBytes: exists ? bytesPerDocument : 0),
  );

  /// [documents] `set`/`update` confirmed by the server (study §7.5): called
  /// on the confirmation, never when the write is only queued offline.
  void recordWrites(int documents, {UsageScope scope = UsageScope.personal}) {
    if (documents <= 0) return;
    _add(scope, UsageCounters(writes: documents));
  }

  /// A listener to count. Listeners with the same [key] are one Firestore
  /// listen (the SDK shares identical queries), so only one of them counts
  /// however many screens use it (study §7.5, §7.11).
  MeteredSubscription subscription(UsageScope scope, {String? key}) {
    final shared = key == null
        ? _SharedListen()
        : _shared.putIfAbsent(key, _SharedListen.new);
    final subscription = MeteredSubscription._(this, scope, shared, key);
    shared.refs++;
    return subscription;
  }

  /// Saves the counters now (before an upload, on pause).
  Future<void> flush() async {
    if (_dirty || _saving) await _persist();
    await _saved;
  }

  void _add(UsageScope scope, UsageCounters usage) {
    final uid = _uid;
    if (uid == null || usage.isZero) return;
    final period = currentPeriod;
    final current = _periods[period.id] ?? const PeriodUsage();
    _periods[period.id] = current.add(scope, usage);
    _changes.add(period);
    unawaited(_persist());
  }

  void _release(_SharedListen shared, String? key) {
    shared.refs--;
    if (shared.refs > 0) return;
    if (key != null && identical(_shared[key], shared)) _shared.remove(key);
  }

  /// One save at a time; a change during a save is saved right after it.
  Future<void> _persist() {
    _dirty = true;
    if (_saving) return _saved;
    _saving = true;
    return _saved = _saveLoop().whenComplete(() => _saving = false);
  }

  Future<void> _saveLoop() async {
    while (_dirty) {
      _dirty = false;
      final uid = _uid;
      if (uid == null) return;
      await _write('$storagePrefix$uid', _encode(_periods));
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _store.write(key, value);
    } catch (error, stack) {
      // The counters are an estimate: a failed save loses at most the last
      // changes, never blocks the app (NFR4).
      await _reporter.report(error, stack, reason: 'UsageMeterSaveFailed');
    }
  }

  Future<String> _installation() async {
    try {
      final saved = await _store.read(installationKey);
      if (saved != null && saved.isNotEmpty) return saved;
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'UsageMeterLoadFailed');
    }
    final created = _ids.newId();
    await _write(installationKey, created);
    return created;
  }

  Future<Map<String, PeriodUsage>> _load(String uid) async {
    try {
      final raw = await _store.read('$storagePrefix$uid');
      if (raw == null || raw.isEmpty) return {};
      return _decode(raw);
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'UsageMeterLoadFailed');
      return {};
    }
  }

  static String _encode(Map<String, PeriodUsage> periods) => jsonEncode({
    for (final entry in periods.entries)
      entry.key: {
        'p': _countersToList(entry.value.personal),
        's': _countersToList(entry.value.system),
      },
  });

  static List<int> _countersToList(UsageCounters c) => [
    c.reads,
    c.writes,
    c.egressBytes,
  ];

  /// A damaged value reads as no usage: the meter never invents usage.
  static Map<String, PeriodUsage> _decode(String raw) {
    final json = jsonDecode(raw);
    if (json is! Map<String, Object?>) return {};
    final periods = <String, PeriodUsage>{};
    for (final entry in json.entries) {
      final value = entry.value;
      if (UsagePeriod.tryParse(entry.key) == null || value is! Map) continue;
      periods[entry.key] = PeriodUsage(
        personal: _countersFrom(value['p']),
        system: _countersFrom(value['s']),
      );
    }
    return periods;
  }

  static UsageCounters _countersFrom(Object? value) {
    if (value is! List || value.length != 3) return UsageCounters.zero;
    int at(int i) {
      final v = value[i];
      return v is int && v >= 0 ? v : 0;
    }

    return UsageCounters(reads: at(0), writes: at(1), egressBytes: at(2));
  }
}

class _SharedListen {
  int refs = 0;
  bool serverSeen = false;
  MeteredSubscription? leader;
}

/// The counting side of one Firestore listener (study §7.5): the first
/// snapshot from the server counts `max(1, documents)`; later ones count
/// only the documents added, modified or that left the query. Snapshots
/// from the cache and metadata-only snapshots add nothing.
class MeteredSubscription {
  MeteredSubscription._(this._meter, this._scope, this._shared, this._key);

  final CloudUsageMeter _meter;
  final UsageScope _scope;
  final _SharedListen _shared;
  final String? _key;
  bool _closed = false;

  /// Whether this listener is the one that counts for its key.
  bool _counts() {
    if (_closed) return false;
    _shared.leader ??= this;
    return identical(_shared.leader, this);
  }

  /// A query snapshot: [documents] in the result, and the changes from the
  /// server since the previous snapshot ([changed] added or modified,
  /// [removed] that left the result). The adapter leaves out changes with
  /// pending local writes.
  void onQuerySnapshot({
    required bool fromCache,
    required int documents,
    required int changed,
    required int removed,
  }) {
    if (fromCache || !_counts()) return;
    if (!_shared.serverSeen) {
      _shared.serverSeen = true;
      _meter.recordQuery(documents: documents, scope: _scope);
      return;
    }
    // A document leaving a filtered query is billed as a read with no data;
    // a deletion cannot be told apart in the snapshot and is counted the
    // same way (an over-estimate of at most one read per deleted wine).
    final reads = changed + removed;
    if (reads == 0) return;
    _meter._add(
      _scope,
      UsageCounters(
        reads: reads,
        egressBytes: changed * CloudUsageMeter.bytesPerDocument,
      ),
    );
  }

  /// A document snapshot. One read per snapshot from the server without
  /// pending local writes.
  void onDocumentSnapshot({
    required bool exists,
    required bool fromCache,
    bool pending = false,
  }) {
    if (fromCache || pending || !_counts()) return;
    _shared.serverSeen = true;
    _meter.recordDocument(exists: exists, scope: _scope);
  }

  /// The listener was cancelled.
  void close() {
    if (_closed) return;
    _closed = true;
    if (identical(_shared.leader, this)) _shared.leader = null;
    _meter._release(_shared, _key);
  }
}
