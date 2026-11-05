import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cellar/data/firestore_codec.dart';
import '../../cellar/data/retry.dart';
import '../../cellar/domain/user_profile.dart';
import '../app_user.dart';

/// Access to `users/{uid}` (logical-components.md: UserRepository).
class UserRepository {
  UserRepository({required this._db, this._sleep = realSleep});

  final FirebaseFirestore _db;
  final Sleep _sleep;

  /// Creates the profile if missing, otherwise refreshes only `displayName`
  /// and `email`, so `onboardingSeen` and `createdAt` are never reset
  /// (NFR4.11). Runs in a transaction; transient errors are retried up to 3
  /// times, other errors are thrown to the caller, which reports them without
  /// blocking the cellar.
  Future<void> ensureProfile(AppUser user) {
    final ref = _db.doc(userPath(user.uid));
    return retryTransient(
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
  }
}
