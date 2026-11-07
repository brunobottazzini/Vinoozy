import 'package:shared_preferences/shared_preferences.dart';

import 'deletion_plan.dart';

/// Opens the phone preferences (`SharedPreferences.getInstance` in the app).
typedef PreferencesOpener = Future<SharedPreferences> Function();

/// The local deletion signal `account.deletion.<uid>` (BR1.7, BR1.8): the
/// index of the next step to run. It is written before step 0, advances after
/// every successful step and is removed only after the local reset of step 7
/// succeeded (NFR8.3).
///
/// It lives in `shared_preferences`, so it is readable before sign-in and
/// without network; the cloud signal is `users/{uid}.deletionStartedAt`.
class DeletionSignal {
  DeletionSignal(this._open);

  static const String keyPrefix = 'account.deletion.';

  final PreferencesOpener _open;

  static String keyOf(String uid) => '$keyPrefix$uid';

  /// The next step of the deletion of [uid], or null when none is in progress.
  Future<int?> read(String uid) async => (await _open()).getInt(keyOf(uid));

  /// Records that [next] is the next step to run for [uid].
  Future<void> write(String uid, DeletionStep next) async {
    final saved = await (await _open()).setInt(keyOf(uid), next.index);
    if (!saved) throw StateError('deletion signal not saved');
  }

  /// Removes the signal of [uid]: the deletion is over on this phone.
  Future<void> clear(String uid) async {
    await (await _open()).remove(keyOf(uid));
  }

  /// Accounts whose deletion reached [from] or a later step, with that step.
  /// Used at start-up without a session: after `deleteUser` only the phone
  /// clean-up may be left (BR1.8, "Fine della cancellazione").
  Future<Map<String, int>> pendingFrom(DeletionStep from) async {
    final preferences = await _open();
    return {
      for (final key in preferences.getKeys())
        if (key.startsWith(keyPrefix))
          if (preferences.getInt(key) case final step? when step >= from.index)
            key.substring(keyPrefix.length): step,
    };
  }
}
