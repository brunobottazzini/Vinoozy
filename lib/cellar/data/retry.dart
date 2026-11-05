import 'package:firebase_core/firebase_core.dart';

/// Waits for [duration]; injectable so tests do not sleep.
typedef Sleep = Future<void> Function(Duration duration);

Future<void> realSleep(Duration duration) => Future<void>.delayed(duration);

/// Firestore error codes worth retrying: the server was unreachable or the
/// transaction lost a race (security-design.md §8).
const Set<String> transientFirestoreCodes = {
  'unavailable',
  'aborted',
  'deadline-exceeded',
};

bool isTransientFirestoreError(Object error) =>
    error is FirebaseException && transientFirestoreCodes.contains(error.code);

/// Runs [operation] up to [attempts] times, waiting [baseDelay], then twice
/// as long, ... between attempts, but only while the failure is transient.
/// Any other error, or the last transient one, is rethrown to the caller.
Future<T> retryTransient<T>(
  Future<T> Function() operation, {
  int attempts = 3,
  Duration baseDelay = const Duration(milliseconds: 400),
  Sleep sleep = realSleep,
}) async {
  if (attempts < 1) throw ArgumentError.value(attempts, 'attempts');
  for (var attempt = 1; ; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (attempt >= attempts || !isTransientFirestoreError(error)) rethrow;
      await sleep(baseDelay * (1 << (attempt - 1)));
    }
  }
}
