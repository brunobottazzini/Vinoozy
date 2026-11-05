import 'dart:async';

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
