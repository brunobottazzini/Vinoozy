import '../../catalog/core/wine_catalog.dart';
import 'label_lookup_flow.dart';

/// Where the photo comes from (BR1.2-BR1.4).
enum PhotoOrigin { camera, gallery, shared }

/// The states of one label reading (logical-components.md, LabelSession).
sealed class LabelState {
  const LabelState();

  /// A final state shows "Riprova" or "Scrivi a mano" (NFR6.2); [LabelIdle],
  /// [LabelReadingState] and [LabelCancelledState] are not final.
  bool get isFinal => false;
}

/// Nothing started yet.
class LabelIdle extends LabelState {
  const LabelIdle();
}

/// "Leggo l'etichetta…" with "Annulla" (BR1.13). [readId] tells the result of
/// this reading from the result of a cancelled or replaced one.
class LabelReadingState extends LabelState {
  const LabelReadingState(this.readId);

  final int readId;
}

/// "Ho riconosciuto:" (BR1.9).
class LabelProposalState extends LabelState {
  const LabelProposalState(this.candidate, {required this.offline});

  final WineCandidate candidate;
  final bool offline;

  @override
  bool get isFinal => true;
}

/// No wine found: the U4 form filled with [name] and [vintage] (BR1.11).
class LabelIncompleteState extends LabelState {
  const LabelIncompleteState({required this.name, this.vintage});

  final String name;
  final int? vintage;

  @override
  bool get isFinal => true;
}

/// "Non riesco a leggere l'etichetta" (BR1.11).
class LabelUnreadableState extends LabelState {
  const LabelUnreadableState();

  @override
  bool get isFinal => true;
}

/// A barcode with no result, or no network to look it up
/// ("Chiarimenti dopo la revisione").
class LabelBarcodeOnlyState extends LabelState {
  const LabelBarcodeOnlyState(this.barcode, {required this.needsNetwork});

  final String barcode;
  final bool needsNetwork;

  @override
  bool get isFinal => true;
}

/// The system denied the camera or the photos (BR1.5).
class LabelPermissionDeniedState extends LabelState {
  const LabelPermissionDeniedState(this.origin);

  final PhotoOrigin origin;

  @override
  bool get isFinal => true;
}

/// No camera app on the phone ("Chiarimenti dopo la revisione", BR1.5).
class LabelCameraUnavailableState extends LabelState {
  const LabelCameraUnavailableState();

  @override
  bool get isFinal => true;
}

/// "Annulla" was tapped: back to "Aggiungi" (BR1.13).
class LabelCancelledState extends LabelState {
  const LabelCancelledState();
}

/// The transitions of a reading, pure and synchronous (NFR1.4): "Annulla"
/// moves to [LabelCancelledState] at once and the result of the reading that
/// was running is ignored through its read id; a new [begin] makes every
/// older reading stale the same way (a replaced reading, BR1.4).
class LabelSession {
  LabelState _state = const LabelIdle();
  int _lastReadId = 0;

  LabelState get state => _state;

  /// Starts a reading and returns its id.
  int begin() {
    _lastReadId++;
    _state = LabelReadingState(_lastReadId);
    return _lastReadId;
  }

  /// Whether [readId] is the reading still shown.
  bool isCurrent(int readId) =>
      _state is LabelReadingState &&
      (_state as LabelReadingState).readId == readId;

  /// Applies the lookup [outcome] of [readId]; false (and no change) when
  /// that reading was cancelled or replaced.
  bool complete(int readId, LookupOutcome outcome) {
    if (!isCurrent(readId)) return false;
    _state = switch (outcome) {
      LookupProposal(:final candidate, :final offline) => LabelProposalState(
        candidate,
        offline: offline,
      ),
      LookupIncomplete(:final name, :final vintage) => LabelIncompleteState(
        name: name,
        vintage: vintage,
      ),
      LookupBarcodeOnly(:final barcode, :final needsNetwork) =>
        LabelBarcodeOnlyState(barcode, needsNetwork: needsNetwork),
      LookupUnreadable() => const LabelUnreadableState(),
    };
    return true;
  }

  /// The image could not be prepared or read (BR1.11): "unreadable".
  bool fail(int readId) => complete(readId, const LookupUnreadable());

  /// The picker ended with a denied access (BR1.5) or no camera.
  void denied(PhotoOrigin origin) {
    _lastReadId++;
    _state = LabelPermissionDeniedState(origin);
  }

  void cameraUnavailable() {
    _lastReadId++;
    _state = const LabelCameraUnavailableState();
  }

  /// "Annulla" (BR1.13): only while reading.
  void cancel() {
    if (_state is! LabelReadingState) return;
    _state = const LabelCancelledState();
  }
}
