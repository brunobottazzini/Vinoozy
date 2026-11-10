import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/error_reporter.dart';
import '../../cellar/data/firestore_codec.dart';
import '../../core/clock.dart';
import '../../sync/ledger/key_value_store.dart';
import '../../usage/cloud_usage_meter.dart';
import '../domain/entitlement.dart';

/// Path of the entitlement document of [uid] (freemium-plus FR1.1).
String entitlementPath(String uid) => 'entitlements/$uid';

/// The local copy of the last entitlement the server confirmed (FR1.4).
///
/// It holds only the entitlement fields (plan, source, status, dates and
/// reason: no purchase token, NFR6) and when the server last confirmed them.
class EntitlementCopy {
  const EntitlementCopy({
    required this.uid,
    required this.confirmedAt,
    this.data,
  });

  /// Null when [raw] is not a copy written by this version: the copy is then
  /// simply ignored, never trusted.
  static EntitlementCopy? tryParse(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, Object?>) return null;
      final uid = json['uid'];
      final confirmed = json['confirmedAt'];
      final data = json['data'];
      if (uid is! String || confirmed is! int) return null;
      if (data != null && data is! Map<String, Object?>) return null;
      return EntitlementCopy(
        uid: uid,
        confirmedAt: DateTime.fromMillisecondsSinceEpoch(
          confirmed,
          isUtc: true,
        ),
        data: data == null ? null : _decodeDates(data as Map<String, Object?>),
      );
    } on FormatException {
      return null;
    }
  }

  final String uid;

  /// When the server last confirmed this entitlement (or its absence).
  final DateTime confirmedAt;

  /// The entitlement fields with dates as [DateTime]; null when the server
  /// confirmed that the user has no entitlement document.
  final Map<String, Object?>? data;

  Entitlement? get entitlement {
    final fields = data;
    return fields == null ? null : Entitlement.fromMap(uid, fields);
  }

  /// FR1.4: the copy stands for at most [maxAge] after its last confirmation.
  /// A confirmation in the future (a clock moved back) is not trusted.
  bool isValidAt(DateTime now, Duration maxAge) {
    final age = now.toUtc().difference(confirmedAt);
    return !age.isNegative && age <= maxAge;
  }

  String encode() => jsonEncode({
    'uid': uid,
    'confirmedAt': confirmedAt.toUtc().millisecondsSinceEpoch,
    'data': data == null ? null : _encodeDates(data!),
  });

  static const List<String> _dateFields = [
    EntitlementFields.expiresAt,
    EntitlementFields.startedAt,
    EntitlementFields.updatedAt,
  ];

  static const List<String> _textFields = [
    EntitlementFields.plan,
    EntitlementFields.source,
    EntitlementFields.status,
    EntitlementFields.reason,
  ];

  /// Only the known entitlement fields enter the copy.
  static Map<String, Object?> fieldsOf(Map<String, Object?> document) => {
    for (final key in [..._textFields, ..._dateFields])
      if (document[key] != null) key: document[key],
  };

  static Map<String, Object?> _encodeDates(Map<String, Object?> data) => {
    for (final entry in data.entries)
      entry.key: entry.value is DateTime
          ? (entry.value! as DateTime).toUtc().millisecondsSinceEpoch
          : entry.value,
  };

  static Map<String, Object?> _decodeDates(Map<String, Object?> data) => {
    for (final entry in data.entries)
      entry.key: _dateFields.contains(entry.key) && entry.value is int
          ? DateTime.fromMillisecondsSinceEpoch(
              entry.value! as int,
              isUtc: true,
            )
          : entry.value,
  };
}

/// The single source of the user's Plus entitlement (freemium-plus FR1.1,
/// FR1.4, FR4.3).
///
/// One listener on `entitlements/{uid}`: a gift or a purchase written by the
/// backend reaches the app without any action of the person (FR4.3). Every
/// snapshot confirmed by the server is saved as a local copy with the time of
/// the confirmation; offline, the copy keeps the plan for at most 7 days
/// after that (FR1.4) and `Entitlement.isPlusValidAt` never lets it pass
/// `expiresAt`. A snapshot only from the Firestore cache never refreshes the
/// copy. When the listener fails, the last valid value stays: an unknown
/// state is never worse than the free plan, and no data is hidden (NFR4).
class EntitlementRepository {
  EntitlementRepository({
    required this._db,
    required this._store,
    required this._reporter,
    this._clock = const SystemClock(),
    this._maxCopyAge = const Duration(days: 7),
    this._meter,
  });

  static const String storageKey = 'entitlement.v1';

  final FirebaseFirestore _db;
  final KeyValueStore _store;
  final ErrorReporter _reporter;
  final Clock _clock;
  final Duration _maxCopyAge;

  /// freemium-plus FR6.1: the entitlement listener is an account read
  /// ("profilo e sync" of study §7.5).
  final CloudUsageMeter? _meter;

  /// The entitlement of [uid]: first the local copy when still valid (null
  /// otherwise), then every change. Null means "no Plus entitlement known".
  Stream<Entitlement?> watch(String uid) {
    late final StreamController<Entitlement?> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? subscription;
    final source = _meter?.subscription(
      UsageScope.personal,
      key: entitlementPath(uid),
    );
    controller = StreamController<Entitlement?>(
      onListen: () async {
        controller.add(await _validCopy(uid));
        if (controller.isClosed) return;
        subscription = _db
            .doc(entitlementPath(uid))
            .snapshots(includeMetadataChanges: true)
            .listen(
              (snapshot) async {
                source?.onDocumentSnapshot(
                  exists: snapshot.exists,
                  fromCache: snapshot.metadata.isFromCache,
                  pending: snapshot.metadata.hasPendingWrites,
                );
                final value = await _onSnapshot(uid, snapshot);
                if (!controller.isClosed) controller.add(value);
              },
              onError: (Object error, StackTrace stack) =>
                  _reporter.report(error, stack, reason: 'EntitlementFailed'),
            );
      },
      onCancel: () async {
        source?.close();
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  /// Forgets the local copy (sign-out, account change; FR1.4).
  Future<void> clear() async {
    try {
      await _store.write(storageKey, '');
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'EntitlementCopyFailed');
    }
  }

  Future<Entitlement?> _onSnapshot(
    String uid,
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) async {
    // Only the server confirms an entitlement; the Firestore cache could hold
    // a value older than the 7 days of FR1.4.
    if (snapshot.metadata.isFromCache) return _validCopy(uid);
    final data = snapshot.exists
        ? EntitlementCopy.fieldsOf(decodeDocument(snapshot.data()))
        : null;
    final copy = EntitlementCopy(
      uid: uid,
      confirmedAt: _clock.now().toUtc(),
      data: data,
    );
    try {
      await _store.write(storageKey, copy.encode());
    } catch (error, stack) {
      // The plan in force does not depend on the copy: only the offline
      // days after this session do.
      await _reporter.report(error, stack, reason: 'EntitlementCopyFailed');
    }
    return copy.entitlement;
  }

  /// The local copy of [uid] while valid; null when missing, of another
  /// account, unreadable or older than 7 days.
  Future<Entitlement?> _validCopy(String uid) async {
    try {
      final raw = await _store.read(storageKey);
      if (raw == null || raw.isEmpty) return null;
      final copy = EntitlementCopy.tryParse(raw);
      if (copy == null || copy.uid != uid) return null;
      if (!copy.isValidAt(_clock.now(), _maxCopyAge)) return null;
      return copy.entitlement;
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'EntitlementCopyFailed');
      return null;
    }
  }
}
