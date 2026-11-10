import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/error_reporter.dart';
import '../../cellar/data/firestore_codec.dart';
import '../../sync/ledger/key_value_store.dart';
import '../../usage/cloud_usage_meter.dart';
import '../domain/plan_policy.dart';

/// Path of the product switches (freemium-plus FR2.4, FR3.5, FR7.1).
const String policyPath = 'config/policy';

/// The product switches of `config/policy`, with a local copy and safe
/// defaults (freemium-plus NFR4).
///
/// One listener, so a switch turned off by the owner (ads, purchases) takes
/// effect at once (FR7.1). Until the server answers, the last copy saved on
/// the phone is used, and without one [PlanPolicy.safeDefaults]: no ads, no
/// capacity limit, no purchases. A failed listener keeps the last value.
class PolicyRepository {
  PolicyRepository({
    required this._db,
    required this._store,
    required this._reporter,
    this._meter,
  });

  static const String storageKey = 'policy.v1';

  final FirebaseFirestore _db;
  final KeyValueStore _store;
  final ErrorReporter _reporter;

  /// freemium-plus FR6.1: the policy listener is an account read.
  final CloudUsageMeter? _meter;

  PlanPolicy _current = PlanPolicy.safeDefaults;

  /// The policy as last known; [PlanPolicy.safeDefaults] before any read.
  /// Synchronous, for the write paths (ActiveWineCounter) and the guards.
  PlanPolicy get current => _current;

  /// The policy: the local copy (or the safe defaults) first, then every
  /// change from the server. Never an error.
  Stream<PlanPolicy> watch() {
    late final StreamController<PlanPolicy> controller;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? subscription;
    final source = _meter?.subscription(UsageScope.personal, key: policyPath);
    controller = StreamController<PlanPolicy>(
      onListen: () async {
        _current = await _readCopy() ?? _current;
        if (controller.isClosed) return;
        controller.add(_current);
        subscription = _db.doc(policyPath).snapshots().listen(
          (snapshot) async {
            source?.onDocumentSnapshot(
              exists: snapshot.exists,
              fromCache: snapshot.metadata.isFromCache,
            );
            final policy = await _onSnapshot(snapshot);
            if (policy != null && !controller.isClosed) {
              controller.add(policy);
            }
          },
          onError: (Object error, StackTrace stack) =>
              _reporter.report(error, stack, reason: 'PolicyFailed'),
        );
      },
      onCancel: () async {
        source?.close();
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  /// Null for a snapshot from the cache that has no document: the copy or
  /// the defaults stay.
  Future<PlanPolicy?> _onSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) async {
    if (!snapshot.exists && snapshot.metadata.isFromCache) return null;
    // A policy missing on the server is the safe one.
    final data = snapshot.exists
        ? decodeDocument(snapshot.data())
        : const <String, Object?>{};
    _current = PlanPolicy.fromMap(data);
    if (!snapshot.metadata.isFromCache) await _saveCopy(_current);
    return _current;
  }

  Future<PlanPolicy?> _readCopy() async {
    try {
      final raw = await _store.read(storageKey);
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw);
      return json is Map<String, Object?> ? PlanPolicy.fromMap(json) : null;
    } on FormatException {
      return null;
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'PolicyCopyFailed');
      return null;
    }
  }

  Future<void> _saveCopy(PlanPolicy policy) async {
    try {
      await _store.write(
        storageKey,
        jsonEncode({
          PlanPolicyFields.adsEnabled: policy.adsEnabled,
          PlanPolicyFields.capacityLimitEnabled: policy.capacityLimitEnabled,
          PlanPolicyFields.purchasesEnabled: policy.purchasesEnabled,
          PlanPolicyFields.policyVersion: policy.policyVersion,
          PlanPolicyFields.usageBudgetEuro: policy.usageBudgetEuro,
          PlanPolicyFields.freeActiveWineLimit: policy.freeActiveWineLimit,
        }),
      );
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'PolicyCopyFailed');
    }
  }
}
