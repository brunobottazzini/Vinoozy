import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import '../cellar/domain/cellar.dart';

/// Events about writes that already left the form (NFR6.2): a single stream,
/// listened to at the app root, so the message appears even after the form
/// has closed.
sealed class SyncEvent {
  const SyncEvent();
}

/// The cloud refused a write (permission-denied and similar): "Change not
/// allowed: `name`".
class WriteRejected extends SyncEvent {
  const WriteRejected({required this.wineId, required this.wineName});

  final String wineId;
  final String wineName;
}

/// A write failed for a transient reason: "Could not save, try again".
class WriteFailed extends SyncEvent {
  const WriteFailed({required this.wineId});

  final String wineId;
}

/// The cloud reported the session as no longer valid (W2): back to sign-in;
/// the queued writes stay on the phone.
class SessionExpired extends SyncEvent {
  const SessionExpired();
}

/// The user lost access to a shared cellar (u7-sharing BR1.8, BR1.14,
/// NFR6.3): revoked by the owner, or a listener or queued write refused by
/// the rules. Never published for the personal cellar.
///
/// The app root shows one notice per cellar and session, and the active
/// cellar goes back to the personal one.
class CellarAccessLost extends SyncEvent {
  const CellarAccessLost({
    required this.cellarId,
    this.ownerName,
    this.fromQueuedWrite = false,
  });

  final String cellarId;

  /// Known from the invitation; null when the refusal came from a write, and
  /// the root then uses the last name it saw for [cellarId].
  final String? ownerName;

  /// A queued change was refused: "Some changes to Mario's cellar were not
  /// saved because you no longer have access".
  final bool fromQueuedWrite;
}

/// What a [CellarNotice] reports (u4-cellar security-design.md §4).
enum CellarNoticeKind {
  /// A queued "Undo" reached the server after 10 minutes or after the drink
  /// was deleted: "Undo failed: the bottle stays marked as drunk".
  undoRejected,

  /// A part of a wine deletion was refused twice: the wine is still there,
  /// and the queued `purgeRecords` completes the deletion the user asked for
  /// when the network allows it (u4-cellar security-design.md §4, R-06).
  deleteFailed,
}

/// A cellar operation that failed after its screen closed (u4-cellar). It
/// is never a lost access: the rules refusing an "Undo" are expected.
class CellarNotice extends SyncEvent {
  const CellarNotice(this.kind);

  final CellarNoticeKind kind;
}

/// Routes a write refused by the cloud (u7-sharing security-design.md §4):
/// [WriteRejected] as in U1 when the wine is known and, for a
/// `permission-denied` on a cellar that is not the personal cellar of
/// [uid], also [CellarAccessLost] with the [cellarId] of the written path.
/// u4-cellar uses it for the drinking records too.
void reportWriteRejected(
  SyncErrorBus bus, {
  required String cellarId,
  required String uid,
  required Object error,
  String? wineId,
  String? wineName,
}) {
  if (wineId != null && wineName != null) {
    bus.publish(WriteRejected(wineId: wineId, wineName: wineName));
  }
  final personal = Cellar.personalCellarId(uid);
  if (cellarId != personal &&
      error is FirebaseException &&
      error.code == 'permission-denied') {
    bus.publish(CellarAccessLost(cellarId: cellarId, fromQueuedWrite: true));
  }
}

/// Broadcast bus of [SyncEvent]s.
class SyncErrorBus {
  final StreamController<SyncEvent> _controller =
      StreamController<SyncEvent>.broadcast();

  Stream<SyncEvent> get events => _controller.stream;

  void publish(SyncEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  Future<void> close() => _controller.close();
}
