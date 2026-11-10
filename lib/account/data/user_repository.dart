import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cellar/data/firestore_codec.dart';
import '../../cellar/data/retry.dart';
import '../../cellar/domain/user_profile.dart';
import '../../usage/cloud_usage_meter.dart';
import '../app_user.dart';

/// Field of `users/{uid}` added by u8-account (C3): the account deletion
/// started; the account is not used until it ends (BR1.7, BR1.10).
const String deletionStartedAtField = 'deletionStartedAt';

/// Access to `users/{uid}` (logical-components.md: UserRepository).
class UserRepository {
  UserRepository({required this._db, this._sleep = realSleep, this._meter});

  final FirebaseFirestore _db;
  final Sleep _sleep;

  /// freemium-plus FR6.1 (study §7.5): the profile read and write of the
  /// account; the account deletion steps are system usage (FR6.4).
  final CloudUsageMeter? _meter;

  /// Creates the profile if missing, otherwise refreshes only `displayName`
  /// and `email`, so `onboardingSeen` and `createdAt` are never reset
  /// (NFR4.11). Runs in a transaction; transient errors are retried up to 3
  /// times, other errors are thrown to the caller, which reports them without
  /// blocking the cellar.
  Future<void> ensureProfile(AppUser user) async {
    final ref = _db.doc(userPath(user.uid));
    await retryTransient(
      () => _db.runTransaction<void>((transaction) async {
        final snapshot = await transaction.get(ref);
        if (snapshot.exists) {
          transaction.update(
            ref,
            UserProfile.refreshFields(
              displayName: user.displayName,
              email: user.email,
            ),
          );
        } else {
          transaction.set<Map<String, dynamic>>(ref, {
            ...UserProfile.createFields(
              displayName: user.displayName,
              email: user.email,
            ),
            UserProfileFields.createdAt: FieldValue.serverTimestamp(),
          });
        }
      }),
      sleep: _sleep,
    );
    // One profile read and one write, once the transaction committed.
    _meter?.recordDocument(exists: true);
    _meter?.recordWrites(1);
  }

  /// u8-account BR1.7 step 1: sets `deletionStartedAt` to the server time.
  ///
  /// The profile may be missing (U1 creates it in the background): it is then
  /// created with the U1 fields plus `deletionStartedAt`. A value already
  /// present is never rewritten (the rules forbid it, NFR4.2), so the step
  /// can be repeated (NFR6.1). Errors are thrown to the runner.
  Future<void> markDeletionStarted(AppUser user) {
    final ref = _db.doc(userPath(user.uid));
    return _db.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        transaction.set<Map<String, dynamic>>(ref, {
          ...UserProfile.createFields(
            displayName: user.displayName,
            email: user.email,
          ),
          UserProfileFields.createdAt: FieldValue.serverTimestamp(),
          deletionStartedAtField: FieldValue.serverTimestamp(),
        });
      } else if (snapshot.data()?[deletionStartedAtField] == null) {
        transaction.update(ref, {
          deletionStartedAtField: FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Whether `users/{uid}.deletionStartedAt` is set (BR1.8), read from the
  /// server or, without network, from the cache. Throws when neither can
  /// answer: the gate then decides from the local signal only.
  Future<bool> isDeletionStarted(String uid) async {
    final snapshot = await _db.doc(userPath(uid)).get();
    return snapshot.exists && snapshot.data()?[deletionStartedAtField] != null;
  }

  /// u8-account BR1.7 step 6: deletes `users/{uid}` if it still exists.
  Future<void> deleteProfile(String uid) async {
    final ref = _db.doc(userPath(uid));
    final snapshot = await ref.get(const GetOptions(source: Source.server));
    if (snapshot.exists) await ref.delete();
  }
}
