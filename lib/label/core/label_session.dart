import '../../catalog/core/wine_catalog.dart';
import 'label_lookup_flow.dart';
import 'label_merge.dart';

/// Where the photo comes from (BR1.2-BR1.4).
enum PhotoOrigin { camera, gallery, shared }

/// The steps of a reading shown by `ReadingProgress` (label-recognition F1,
/// mockup "Lettura in corso").
enum ReadingStep { front, back, barcode, database }

/// How far one [ReadingStep] is.
enum StepStatus { pending, running, done, skipped, failed }

/// The progress of a reading, announced step by step (accessibility L3).
class ReadingProgress {
  const ReadingProgress([this.steps = const {}]);

  final Map<ReadingStep, StepStatus> steps;

  StepStatus of(ReadingStep step) => steps[step] ?? StepStatus.pending;

  ReadingProgress withStep(ReadingStep step, StepStatus status) =>
      ReadingProgress({...steps, step: status});
}

/// The states of one label reading (logical-components.md, LabelSession;
/// label-recognition functional-spec.md "Ciclo di vita di LabelCapture").
sealed class LabelState {
  const LabelState();

  /// A final state shows a way out (NFR6.2); [LabelIdle],
  /// [LabelReadingState], [LabelBackPromptState] and [LabelCancelledState]
  /// are not final.
  bool get isFinal => false;
}

/// Nothing started yet.
class LabelIdle extends LabelState {
  const LabelIdle();
}

/// "Leggo l'etichetta…" with the steps and "Annulla" (BR1.13, F1).
/// [readId] tells the result of this reading from the result of a
/// cancelled or replaced one.
class LabelReadingState extends LabelState {
  const LabelReadingState(
    this.readId, {
    this.progress = const ReadingProgress(),
  });

  final int readId;
  final ReadingProgress progress;
}

/// "Ora il retro" with "Scatta il retro", "Scegli dalla galleria" and
/// "Salta" (label-recognition BR1.1).
class LabelBackPromptState extends LabelState {
  const LabelBackPromptState(this.readId);

  final int readId;
}

/// "Ho riconosciuto:" (BR1.9): a sure proposal (label-recognition BR3.2),
/// with "Non è questo" (BR3.5).
class LabelProposalState extends LabelState {
  const LabelProposalState(
    this.candidate, {
    this.alternatives = const [],
    this.notFound = const LookupNotFound(NotFoundKind.noMatch),
    this.backStatus = BackStatus.skipped,
  });

  final WineCandidate candidate;
  final List<WineCandidate> alternatives;
  final LookupNotFound notFound;
  final BackStatus backStatus;

  @override
  bool get isFinal => true;
}

/// "Quale di questi?": up to 10 candidates (label-recognition BR3.2), with
/// "Nessuno di questi".
class LabelCandidatesState extends LabelState {
  const LabelCandidatesState(
    this.candidates, {
    required this.notFound,
    this.backStatus = BackStatus.skipped,
  });

  final List<WineCandidate> candidates;
  final LookupNotFound notFound;
  final BackStatus backStatus;

  @override
  bool get isFinal => true;
}

/// "Non trovato" of one of the three kinds (label-recognition BR3.4), with
/// "Cerca online", "Scrivi a mano" and "Apri in Google Lens".
class LabelNotFoundState extends LabelState {
  const LabelNotFoundState(
    this.outcome, {
    this.backStatus = BackStatus.skipped,
  });

  final LookupNotFound outcome;
  final BackStatus backStatus;

  NotFoundKind get kind => outcome.kind;

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
  BackStatus _backStatus = BackStatus.skipped;

  LabelState get state => _state;

  /// Starts a reading (the front is being prepared) and returns its id.
  int begin() {
    _lastReadId++;
    _backStatus = BackStatus.skipped;
    _state = LabelReadingState(
      _lastReadId,
      progress: const ReadingProgress({ReadingStep.front: StepStatus.running}),
    );
    return _lastReadId;
  }

  /// Whether [readId] is the reading still running or waiting for the back.
  bool isCurrent(int readId) => switch (_state) {
    LabelReadingState(readId: final id) => id == readId,
    LabelBackPromptState(readId: final id) => id == readId,
    _ => false,
  };

  /// The front is ready: "Ora il retro" (BR1.1).
  bool askBack(int readId) {
    if (!isCurrent(readId)) return false;
    _state = LabelBackPromptState(readId);
    return true;
  }

  /// The back was taken or skipped: the reading goes on (F1).
  bool resume(int readId, ReadingProgress progress) {
    if (!isCurrent(readId)) return false;
    _state = LabelReadingState(readId, progress: progress);
    return true;
  }

  /// Applies the lookup [outcome] of [readId] read with [backStatus]; false
  /// (and no change) when that reading was cancelled or replaced.
  bool complete(
    int readId,
    LookupOutcome outcome, {
    BackStatus backStatus = BackStatus.skipped,
  }) {
    if (!isCurrent(readId)) return false;
    _backStatus = backStatus;
    _state = switch (outcome) {
      LookupSure(:final candidate, :final alternatives, :final notFound) =>
        LabelProposalState(
          candidate,
          alternatives: alternatives,
          notFound: notFound,
          backStatus: backStatus,
        ),
      LookupCandidates(:final candidates, :final notFound) =>
        LabelCandidatesState(
          candidates,
          notFound: notFound,
          backStatus: backStatus,
        ),
      LookupNotFound() => LabelNotFoundState(outcome, backStatus: backStatus),
    };
    return true;
  }

  /// The image could not be prepared or read (BR1.11): "unreadable".
  bool fail(int readId) =>
      complete(readId, const LookupNotFound(NotFoundKind.unreadable));

  /// "Non è questo" (BR3.5): the other candidates, or "not found".
  void notThis() {
    final current = _state;
    if (current is! LabelProposalState) return;
    _state = current.alternatives.isEmpty
        ? LabelNotFoundState(current.notFound, backStatus: _backStatus)
        : LabelCandidatesState(
            current.alternatives,
            notFound: current.notFound,
            backStatus: _backStatus,
          );
  }

  /// "Nessuno di questi": "not found" (F2).
  void noneOfThese() {
    final current = _state;
    if (current is! LabelCandidatesState) return;
    _state = LabelNotFoundState(current.notFound, backStatus: _backStatus);
  }

  /// The picker ended with a denied access (BR1.5) or no camera.
  void denied(PhotoOrigin origin) {
    _lastReadId++;
    _state = LabelPermissionDeniedState(origin);
  }

  void cameraUnavailable() {
    _lastReadId++;
    _state = const LabelCameraUnavailableState();
  }

  /// "Annulla" (BR1.13, BR1.6): while reading or waiting for the back.
  void cancel() {
    if (_state is! LabelReadingState && _state is! LabelBackPromptState) {
      return;
    }
    _state = const LabelCancelledState();
  }
}
