// Cache of the Open Food Facts answers and index of profile hints (BR2.1,
// entities.md CachedResponse and ProfileHint). Everything lives in memory and
// is read from the file once per session; reads never touch the disk
// (NFR1.4). Saves are grouped (at most one every 2 s), serialised, and
// written to a temporary file then renamed (reliability-design.md).
//
// An epoch protects the data of the previous user: [clear] increments it, a
// save that sees it change before the rename deletes its temporary file, and
// the coordinator drops Open Food Facts answers that started in an older
// epoch (NFR8.1).

import 'dart:async';
import 'dart:convert';

import '../../core/clock.dart';
import 'catalog_config.dart';
import 'catalog_event_logger.dart';
import 'off_circuit_breaker.dart';
import 'wine_catalog.dart';

/// Storage of `catalog_cache.json` behind an interface, so the pure core
/// never touches the file system (in-memory fake in tests, the app support
/// directory in production).
abstract interface class CacheFile {
  /// Contents of the cache file, or `null` when there is none.
  Future<String?> read();

  /// Writes [contents] to the temporary file `catalog_cache.json.tmp`.
  Future<void> writeTemp(String contents);

  /// Renames the temporary file over the cache file (atomic on one disk).
  Future<void> commitTemp();

  /// Deletes the temporary file, if any.
  Future<void> deleteTemp();

  /// Deletes the cache file and the temporary file.
  Future<void> deleteAll();
}

/// Profile data learnt from Open Food Facts answers for one wine name
/// (BR3.1), keyed by the normalised name.
class ProfileHint {
  const ProfileHint({this.wineType, this.region, this.denomination});

  final CatalogWineType? wineType;
  final String? region;
  final String? denomination;

  bool get isEmpty =>
      wineType == null && region == null && denomination == null;

  @override
  bool operator ==(Object other) =>
      other is ProfileHint &&
      other.wineType == wineType &&
      other.region == region &&
      other.denomination == denomination;

  @override
  int get hashCode => Object.hash(wineType, region, denomination);
}

class _Entry<T> {
  _Entry(this.value, this.storedAt);

  final T value;
  final DateTime storedAt;
}

/// In-memory cache and hint index with their limits, expiry and saves.
class CatalogCacheStore {
  CatalogCacheStore({
    required this._file,
    required this._clock,
    required this._health,
    required this._logger,
    this._timerFactory = Timer.new,
  });

  /// Answers and hints older than this are ignored and dropped (C5).
  static const Duration maxAge = Duration(days: 30);

  /// Most cached answers kept; the oldest go first (NFR2.3).
  static const int maxEntries = 200;

  /// Most proposals kept per answer (NFR2.3).
  static const int maxCandidatesPerEntry = 10;

  /// Most profile hints kept; the oldest go first (NFR2.3).
  static const int maxHints = 500;

  /// At most one save per window (NFR2.3).
  static const Duration saveDelay = Duration(seconds: 2);

  static const int _formatVersion = 1;

  final CacheFile _file;
  final Clock _clock;
  final CatalogHealth _health;
  final CatalogEventLogger _logger;
  final CatalogTimerFactory _timerFactory;

  final Map<String, _Entry<List<WineCandidate>>> _entries = {};
  final Map<String, _Entry<ProfileHint>> _hints = {};

  int _epoch = 0;
  String? _owner;
  bool _dirty = false;
  Timer? _saveTimer;
  Future<void> _saves = Future<void>.value();
  Future<void> _ready = Future<void>.value();

  /// Incremented by every [clear].
  int get epoch => _epoch;

  /// Completes when the last [open] or [clear] has finished; every cache
  /// operation of the coordinator waits for it.
  Future<void> get ready => _ready;

  /// Number of cached answers, for tests and diagnostics.
  int get entryCount => _entries.length;

  /// Number of profile hints, for tests and diagnostics.
  int get hintCount => _hints.length;

  /// Loads the cache file of [ownerHash] (SHA-256 of the signed-in uid).
  /// A file of another owner, without owner, unreadable or invalid is
  /// deleted and the cache starts empty (NFR6.4, NFR8.1). With no user
  /// ([ownerHash] `null`) nothing is loaded and nothing is saved.
  Future<void> open(String? ownerHash) {
    final epochAtCall = _epoch;
    _ready = _ready.then((_) => _load(ownerHash, epochAtCall));
    return _ready;
  }

  /// Forgets everything of the current user: increments the epoch, empties
  /// memory, cancels the pending save, waits for a save in progress, then
  /// deletes the file and its temporary file (reliability-design.md).
  Future<void> clear() {
    _epoch++;
    _entries.clear();
    _hints.clear();
    _owner = null;
    _dirty = false;
    _saveTimer?.cancel();
    _saveTimer = null;
    _ready = _ready.then((_) => _wipe());
    return _ready;
  }

  /// Cached answer for [key], or `null` when absent or older than 30 days.
  List<WineCandidate>? lookup(String key) {
    var entry = _entries[key];
    if (entry != null && _isExpired(entry.storedAt)) {
      _entries.remove(key);
      _markDirty();
      entry = null;
    }
    final value = entry?.value;
    _health.recordCacheLookup(hit: value != null);
    if (value != null) _logger.debug(CatalogDebugEvent.cacheHit);
    return value;
  }

  /// Hint for the normalised wine [name], or `null`.
  ProfileHint? hint(String name) {
    final entry = _hints[name];
    if (entry == null) return null;
    if (_isExpired(entry.storedAt)) {
      _hints.remove(name);
      _markDirty();
      return null;
    }
    return entry.value;
  }

  /// Stores a successful answer (an empty list means "nothing found") and
  /// updates the hint of every proposal, keyed by [hintKeyOf] its name.
  void put(
    String key,
    List<WineCandidate> candidates, {
    required String Function(String name) hintKeyOf,
  }) {
    final now = _clock.now();
    final kept = List<WineCandidate>.unmodifiable(
      candidates.take(maxCandidatesPerEntry),
    );
    _entries.remove(key);
    _entries[key] = _Entry(kept, now);
    _evictOldest(_entries, maxEntries);
    for (final candidate in kept) {
      final hint = ProfileHint(
        wineType: candidate.wineType,
        region: candidate.region,
        denomination: candidate.denomination,
      );
      final hintKey = hintKeyOf(candidate.name);
      if (hint.isEmpty || hintKey.isEmpty) continue;
      _hints.remove(hintKey);
      _hints[hintKey] = _Entry(hint, now);
    }
    _evictOldest(_hints, maxHints);
    _markDirty();
  }

  /// The cache as written to the file (UTF-8 JSON).
  String serialize() => jsonEncode({
    'version': _formatVersion,
    'owner': _owner,
    'entries': [
      for (final MapEntry(:key, :value) in _entries.entries)
        {
          'k': key,
          'at': value.storedAt.millisecondsSinceEpoch,
          'c': [for (final candidate in value.value) candidate.toJson()],
        },
    ],
    'hints': [
      for (final MapEntry(:key, :value) in _hints.entries)
        {
          'k': key,
          'at': value.storedAt.millisecondsSinceEpoch,
          if (value.value.wineType != null) 't': value.value.wineType!.name,
          if (value.value.region != null) 'r': value.value.region,
          if (value.value.denomination != null) 'd': value.value.denomination,
        },
    ],
  });

  /// Saves now, if anything changed, after any save in progress. Used when
  /// the catalog is disposed and by tests.
  Future<void> flush() {
    _saveTimer?.cancel();
    _saveTimer = null;
    _saves = _saves.then((_) => _save());
    return _saves;
  }

  /// Cancels the pending save timer.
  void dispose() {
    _saveTimer?.cancel();
    _saveTimer = null;
  }

  bool _isExpired(DateTime storedAt) =>
      _clock.now().difference(storedAt) >= maxAge;

  void _evictOldest<T>(Map<String, _Entry<T>> map, int limit) {
    if (map.length <= limit) return;
    final byAge = map.entries.toList()
      ..sort((a, b) => a.value.storedAt.compareTo(b.value.storedAt));
    for (final entry in byAge.take(map.length - limit)) {
      map.remove(entry.key);
    }
  }

  void _markDirty() {
    if (_owner == null) return;
    _dirty = true;
    _saveTimer ??= _timerFactory(saveDelay, () {
      _saveTimer = null;
      _saves = _saves.then((_) => _save());
    });
  }

  Future<void> _save() async {
    if (!_dirty || _owner == null) return;
    final epochAtStart = _epoch;
    _dirty = false;
    try {
      await _file.writeTemp(serialize());
      if (_epoch != epochAtStart) {
        await _file.deleteTemp();
        return;
      }
      await _file.commitTemp();
    } on Object {
      // The in-memory cache stays valid; the next change saves again.
      if (_epoch == epochAtStart) _dirty = true;
      _logger.debug(CatalogDebugEvent.cacheWriteFailed);
    }
  }

  Future<void> _wipe() async {
    await _saves;
    try {
      await _file.deleteAll();
    } on Object {
      _logger.debug(CatalogDebugEvent.cacheWriteFailed);
    }
    _logger.debug(CatalogDebugEvent.cacheCleared);
  }

  /// A [clear] after the [open] call ([epochAtCall] changed) wins: nothing
  /// of the opened file is kept.
  Future<void> _load(String? ownerHash, int epochAtCall) async {
    if (_epoch != epochAtCall) return;
    _entries.clear();
    _hints.clear();
    _owner = ownerHash;
    if (ownerHash == null) return;
    final String? contents;
    try {
      contents = await _file.read();
    } on Object {
      await _reset(CatalogDebugEvent.cacheReset);
      return;
    }
    if (_epoch != epochAtCall || contents == null) return;
    final decoded = _decode(contents);
    if (decoded == null) {
      await _reset(CatalogDebugEvent.cacheReset);
      return;
    }
    if (decoded['owner'] != ownerHash) {
      await _reset(CatalogDebugEvent.cacheOwnerMismatch);
      return;
    }
    _readEntries(decoded['entries']);
    _readHints(decoded['hints']);
  }

  Map<String, Object?>? _decode(String contents) {
    try {
      final json = jsonDecode(contents);
      if (json is! Map<String, Object?>) return null;
      if (json['version'] != _formatVersion) return null;
      if (json['entries'] is! List || json['hints'] is! List) return null;
      return json;
    } on FormatException {
      return null;
    }
  }

  void _readEntries(Object? raw) {
    for (final item in raw as List) {
      if (item is! Map) continue;
      final key = item['k'];
      final storedAt = _readTime(item['at']);
      final list = item['c'];
      if (key is! String || storedAt == null || list is! List) continue;
      if (_isExpired(storedAt)) continue;
      final candidates = <WineCandidate>[
        for (final json in list.take(maxCandidatesPerEntry))
          ?WineCandidate.fromJson(json),
      ];
      _entries[key] = _Entry(List.unmodifiable(candidates), storedAt);
    }
    _evictOldest(_entries, maxEntries);
  }

  void _readHints(Object? raw) {
    for (final item in raw as List) {
      if (item is! Map) continue;
      final key = item['k'];
      final storedAt = _readTime(item['at']);
      if (key is! String || storedAt == null || _isExpired(storedAt)) continue;
      final hint = ProfileHint(
        wineType: CatalogWineType.values
            .where((type) => type.name == item['t'])
            .firstOrNull,
        region: item['r'] is String ? item['r'] as String : null,
        denomination: item['d'] is String ? item['d'] as String : null,
      );
      if (!hint.isEmpty) _hints[key] = _Entry(hint, storedAt);
    }
    _evictOldest(_hints, maxHints);
  }

  DateTime? _readTime(Object? millis) =>
      millis is int ? DateTime.fromMillisecondsSinceEpoch(millis) : null;

  Future<void> _reset(CatalogDebugEvent event) async {
    if (event == CatalogDebugEvent.cacheReset) _health.recordCacheReset();
    _logger.debug(event);
    try {
      await _file.deleteAll();
    } on Object {
      _logger.debug(CatalogDebugEvent.cacheWriteFailed);
    }
  }
}
