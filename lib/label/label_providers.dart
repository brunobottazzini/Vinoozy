import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account/gate_state.dart';
import '../app/providers.dart';
import '../catalog/core/catalog_event_logger.dart';
import '../catalog/core/wine_catalog.dart';
import '../catalog/platform/catalog_providers.dart';
import 'core/label_lookup_flow.dart';
import 'core/label_merge.dart';
import 'core/label_reading.dart';
import 'core/label_session.dart';
import 'core/lens_launcher.dart';
import 'core/shared_image_policy.dart';
import 'platform/label_error_reporter.dart';
import 'platform/lens_channel.dart';
import 'platform/mlkit_label_reader.dart';
import 'platform/picker_image_source.dart';
import 'platform/shared_image_channel.dart';
import 'platform/temp_label_store.dart';

// Providers of the label photo (u6-label-recognition logical-components.md).
// The adapters have real defaults; tests override them with fakes.

final sharedImageChannelProvider = Provider<SharedImageChannel>((ref) {
  final channel = SharedImageChannel();
  ref.onDispose(channel.dispose);
  return channel;
});

final imageSourceProvider = Provider<ImageSource>((ref) => PickerImageSource());

/// A new reader for each reading session, closed at its end.
final labelReaderFactoryProvider = Provider<LabelReader Function()>(
  (ref) => MlKitLabelReader.new,
);

final labelErrorReporterProvider = Provider<LabelErrorReporter>(
  (ref) => LabelErrorReporter(ref.watch(errorReporterProvider)),
);

/// "Apri in Google Lens" (label-recognition FR4): the native channel in the
/// app, a fake in tests (NFR4.4: never the real Google app in a test).
final lensLauncherProvider = Provider<LensLauncher>(
  (ref) => const MethodChannelLensLauncher(),
);

final labelFileSystemProvider = Provider<LabelFileSystem>(
  (ref) => IoLabelFileSystem(),
);

/// One store for the whole app: it keeps the start-up cleanup that every
/// reading waits for (NFR8.1).
final tempLabelStoreProvider = Provider<TempLabelStore>(
  (ref) => TempLabelStore(
    files: ref.watch(labelFileSystemProvider),
    clock: ref.watch(clockProvider),
    reporter: ref.watch(labelErrorReporterProvider),
  ),
);

/// Empties `label/` and discards image_picker's lost data after the first
/// frame, in the background (security-design.md §4). Called by
/// `AppBootstrap.start`.
void scheduleLabelCleanup(ProviderContainer container) {
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => startLabelCleanup(container),
  );
}

/// The cleanup itself, without waiting for a frame.
void startLabelCleanup(ProviderContainer container) {
  final source = container.read(imageSourceProvider);
  container
      .read(tempLabelStoreProvider)
      .startCleanup(alsoDiscard: source.discardLostData);
}

// ---------------------------------------------------------------------------
// One reading.

/// What starts a reading screen.
sealed class LabelInput {
  const LabelInput();
}

/// A photo from the camera or the gallery, still as image_picker wrote it.
class PickedLabelInput extends LabelInput {
  const PickedLabelInput(this.path);

  final String path;
}

/// The image shared to the app, held natively until now (BR1.4).
class SharedLabelInput extends LabelInput {
  const SharedLabelInput();
}

/// The picker ended with a refused access (BR1.5).
class DeniedLabelInput extends LabelInput {
  const DeniedLabelInput(this.origin);

  final PhotoOrigin origin;
}

/// No camera app (BR1.5, "Chiarimenti dopo la revisione").
class CameraUnavailableLabelInput extends LabelInput {
  const CameraUnavailableLabelInput();
}

/// The picker failed for another reason: "unreadable" with
/// `label_pick_failed`.
class FailedPickLabelInput extends LabelInput {
  const FailedPickLabelInput(this.error, this.stack);

  final Object error;
  final StackTrace stack;
}

/// A refusal of the native preparer, reported with its code only.
class LabelImageRejected implements Exception {
  const LabelImageRejected(this.code);

  final String code;

  @override
  String toString() => 'LabelImageRejected($code)';
}

/// The services a reading talks to beyond the phone's own storage: the
/// camera or gallery, Google Lens and the wine catalog. They are taken from
/// the scope of the screen that started the reading and carried through it,
/// because the reading screens are pushed on the app Navigator, above any
/// nested ProviderScope that overrides them (the end-to-end tests replace
/// them there), and [labelSessionProvider] lives in the root container. In
/// the app nothing is scoped, so these are the root services.
class LabelServices {
  const LabelServices({
    required this.source,
    required this.lens,
    required this.catalog,
  });

  /// The services seen by [ref], the ref of the screen starting a reading.
  factory LabelServices.of(WidgetRef ref) => LabelServices(
    source: ref.read(imageSourceProvider),
    lens: ref.read(lensLauncherProvider),
    catalog: ref.read(catalogProvider),
  );

  final ImageSource source;
  final LensLauncher lens;
  final WineCatalog catalog;
}

/// One reading session per reading screen, keyed by a token of the screen
/// so a replaced screen never sees the state of the new one (BR1.4).
final labelSessionProvider = NotifierProvider.autoDispose
    .family<LabelSessionController, LabelState, int>(
      LabelSessionController.new,
    );

/// Runs a reading (BR1.6-BR1.8, BR1.11, BR1.13, BR1.14; label-recognition
/// F1, BR1.1-BR1.6): waits for the start-up cleanup, prepares the front
/// natively, asks for the back ("Ora il retro"), prepares and reads both,
/// merges them and looks the wine up. The prepared copies are held while
/// the outcome is open (Google Lens needs the front) and deleted when the
/// screen closes, on cancel and on a replaced reading (BR1.4). Every error
/// is caught here and becomes a fixed reason; none reaches the global
/// handlers (NFR8.2). "Annulla" and closing the screen leave the running
/// work to finish in the background, its result ignored through the read
/// id and its copies deleted.
class LabelSessionController extends Notifier<LabelState> {
  LabelSessionController(this.token);

  final int token;
  final LabelSession _session = LabelSession();
  LabelReader? _reader;
  Future<void> _work = Future<void>.value();
  _Capture? _capture;

  @override
  LabelState build() {
    // Keeps the catalog session listening while the screen is open.
    ref.listen<WineCatalog>(catalogProvider, (_, _) {});
    ref.onDispose(_onDispose);
    return const LabelIdle();
  }

  /// The prepared front of the open outcome, for Google Lens; `null` when
  /// there is none (label-recognition BR5.2).
  String? get frontPath => _capture?.front;

  void _emit() {
    if (ref.mounted) state = _session.state;
  }

  void _onDispose() {
    _session.cancel();
    final capture = _capture;
    _capture = null;
    // Released and closed once the work still running has finished with
    // them; a copy or a reader the work creates after this point goes the
    // same way.
    unawaited(
      _work
          .then((_) => capture?.release())
          .then((_) => _reader?.close())
          .catchError((Object _) {})
          .whenComplete(() => _reader = null),
    );
  }

  /// Everything a reading uses, taken while the screen is open: the work
  /// may finish after the screen closed, when `ref` can no longer be read.
  /// The image source, Google Lens and the catalog come from [services],
  /// those of the screen that started the reading, never from this
  /// provider's own container.
  _ReadingDeps _deps(LabelServices services) {
    final reporter = ref.read(labelErrorReporterProvider);
    final clock = ref.read(clockProvider);
    final newReader = ref.read(labelReaderFactoryProvider);
    return _ReadingDeps(
      reporter: reporter,
      store: ref.read(tempLabelStoreProvider),
      channel: ref.read(sharedImageChannelProvider),
      source: services.source,
      logger: ref.read(catalogEventLoggerProvider),
      lens: services.lens,
      // Created on first use, once per session, closed in _onDispose.
      reader: () => _reader ??= newReader(),
      flow: LabelLookupFlow(
        catalog: services.catalog,
        currentYear: () => clock.now().year,
        onFailure: (error, stack) =>
            unawaited(reporter.report(LabelFailure.lookupFailed, error, stack)),
        onExtractFailure: (error, stack) => unawaited(
          reporter.report(LabelFailure.appellationsIndexFailed, error, stack),
        ),
      ),
    );
  }

  /// Starts the reading of [input] with the [services] of the screen that
  /// started it: the front is prepared, then "Ora il retro" waits for
  /// [takeBack] or [skipBack], which use the same [services]. Completes when
  /// the front has settled. Never throws.
  Future<void> start(
    LabelInput input, {
    required CatalogLocale locale,
    required LabelServices services,
  }) {
    switch (input) {
      case DeniedLabelInput(:final origin):
        _session.denied(origin);
        _emit();
        return Future<void>.value();
      case CameraUnavailableLabelInput():
        _session.cameraUnavailable();
        _emit();
        return Future<void>.value();
      case FailedPickLabelInput(:final error, :final stack):
        final id = _session.begin();
        _session.fail(id);
        _emit();
        return _deps(services).reporter
            .report(LabelFailure.pickFailed, error, stack);
      case PickedLabelInput() || SharedLabelInput():
        _replaceCapture();
        final id = _session.begin();
        _emit();
        final work = _prepareFront(_deps(services), input, id, locale);
        _work = work;
        return work;
    }
  }

  /// "Scatta il retro" or "Scegli dalla galleria" (BR1.1): cancelled,
  /// denied or failed is the same as "Salta" (BR1.6).
  Future<void> takeBack(PhotoOrigin origin) async {
    final capture = _capture;
    if (capture == null || _session.state is! LabelBackPromptState) return;
    final outcome = await capture.deps.source.pick(origin);
    if (outcome case PickFailed(:final error, :final stack)) {
      await capture.deps.reporter.report(LabelFailure.pickFailed, error, stack);
    }
    return _continue(
      capture,
      outcome is PickedImage ? PickedLabelInput(outcome.path) : null,
    );
  }

  /// "Salta" (BR1.1): the outcome with the front only.
  Future<void> skipBack() async {
    final capture = _capture;
    if (capture == null || _session.state is! LabelBackPromptState) return;
    return _continue(capture, null);
  }

  /// "Annulla" (BR1.13, BR1.6): immediate, the late result is ignored, the
  /// copies are deleted when the screen closes.
  void cancel() {
    _session.cancel();
    _emit();
  }

  /// "Non è questo" (BR3.5).
  void notThis() {
    _session.notThis();
    _emit();
  }

  /// "Nessuno di questi".
  void noneOfThese() {
    _session.noneOfThese();
    _emit();
  }

  /// "Apri Google Lens", after the confirmation (BR5.1, BR5.2): only the
  /// prepared front leaves, to the Google app or the share menu.
  Future<LensRoute> openLens() async {
    final capture = _capture;
    if (capture == null) return LensRoute.failed;
    final route = await capture.deps.lens.open(capture.front);
    capture.deps.logger.lensOpened(route);
    return route;
  }

  /// A new reading on this screen: the copies of the old one are deleted
  /// once its work has finished.
  void _replaceCapture() {
    final old = _capture;
    _capture = null;
    if (old == null) return;
    unawaited(_work.then((_) => old.release()).catchError((Object _) {}));
  }

  Future<void> _prepareFront(
    _ReadingDeps deps,
    LabelInput input,
    int id,
    CatalogLocale locale,
  ) async {
    await deps.store.beforeRead();
    final prepared = await deps.prepare(input);
    if (prepared is! PreparedImage) {
      if (ref.mounted && _session.fail(id)) _emit();
      return;
    }
    deps.store.hold(prepared.path);
    final capture = _Capture(id, prepared.path, locale, deps);
    if (!ref.mounted || !_session.isCurrent(id)) {
      await capture.release();
      return;
    }
    _capture = capture;
    if (_session.askBack(id)) _emit();
  }

  Future<void> _continue(_Capture capture, LabelInput? back) {
    var progress = ReadingProgress({
      ReadingStep.front: StepStatus.running,
      ReadingStep.back: back == null ? StepStatus.skipped : StepStatus.pending,
    });
    if (!_session.resume(capture.id, progress)) return Future<void>.value();
    _emit();
    void step(ReadingStep step, StepStatus status) {
      progress = progress.withStep(step, status);
      if (ref.mounted && _session.resume(capture.id, progress)) _emit();
    }

    final work = _read(capture, back, step);
    _work = work;
    return work;
  }

  Future<void> _read(
    _Capture capture,
    LabelInput? back,
    void Function(ReadingStep step, StepStatus status) step,
  ) async {
    final deps = capture.deps;
    final front = await deps.read(capture.front);
    step(
      ReadingStep.front,
      front == null ? StepStatus.failed : StepStatus.done,
    );
    LabelReading? backReading;
    if (back != null) {
      step(ReadingStep.back, StepStatus.running);
      final prepared = await deps.prepare(back);
      if (prepared is PreparedImage) {
        deps.store.hold(prepared.path);
        capture.back = prepared.path;
        backReading = await deps.read(prepared.path);
      }
      step(
        ReadingStep.back,
        backReading == null ? StepStatus.failed : StepStatus.done,
      );
    }
    final merged = mergeLabelReadings(
      front: front,
      back: backReading,
      backTaken: back != null,
    );
    step(
      ReadingStep.barcode,
      merged.barcode == null ? StepStatus.skipped : StepStatus.done,
    );
    step(ReadingStep.database, StepStatus.running);
    final outcome = await deps.lookUp(merged, capture.locale);
    if (ref.mounted &&
        _session.complete(capture.id, outcome, backStatus: merged.backStatus)) {
      _emit();
    }
    deps.logger.labelOutcome(_kindOf(outcome), _stepOf(outcome));
  }

  static LabelOutcomeKind _kindOf(LookupOutcome outcome) => switch (outcome) {
    LookupSure() => LabelOutcomeKind.sure,
    LookupCandidates() => LabelOutcomeKind.candidates,
    LookupNotFound(kind: NotFoundKind.unreadable) =>
      LabelOutcomeKind.unreadable,
    LookupNotFound(kind: NotFoundKind.barcodeNotFound) =>
      LabelOutcomeKind.barcodeNotFound,
    LookupNotFound(kind: NotFoundKind.noMatch) => LabelOutcomeKind.noMatch,
  };

  static LabelMatchStep _stepOf(LookupOutcome outcome) => switch (outcome) {
    LookupSure(:final step) || LookupCandidates(:final step) => step,
    LookupNotFound() => LabelMatchStep.none,
  };
}

/// The photos of one reading while its outcome is open (entities.md
/// `LabelCapture`).
class _Capture {
  _Capture(this.id, this.front, this.locale, this.deps);

  final int id;
  final String front;
  final CatalogLocale locale;
  final _ReadingDeps deps;
  String? back;

  /// Deletes the front and the back (BR1.4).
  Future<void> release() => deps.store.releaseCapture([front, ?back]);
}

class _ReadingDeps {
  _ReadingDeps({
    required this.reporter,
    required this.store,
    required this.channel,
    required this.source,
    required this.logger,
    required this.lens,
    required this.reader,
    required this.flow,
  });

  final LabelErrorReporter reporter;
  final TempLabelStore store;
  final SharedImageChannel channel;
  final ImageSource source;
  final CatalogEventLogger logger;
  final LensLauncher lens;
  final LabelReader Function() reader;
  final LabelLookupFlow flow;

  /// The prepared image, or `null` after a refusal (reported as
  /// `label_pick_failed` with its code only).
  Future<PrepareResult?> prepare(LabelInput input) async {
    try {
      final result = switch (input) {
        PickedLabelInput(:final path) => await channel.prepare(path),
        _ => await channel.readShare(),
      };
      if (result is! PreparedImage) {
        final code = result is RejectedImage ? result.code : 'missing';
        await reporter.report(
          LabelFailure.pickFailed,
          LabelImageRejected(code),
          StackTrace.current,
        );
      }
      return result;
    } catch (error, stack) {
      await reporter.report(LabelFailure.pickFailed, error, stack);
      return null;
    }
  }

  /// The reading of one prepared photo, or `null` when it failed (reported
  /// as `label_read_failed`).
  Future<LabelReading?> read(String path) async {
    try {
      return await reader().read(path);
    } catch (error, stack) {
      await reporter.report(LabelFailure.readFailed, error, stack);
      return null;
    }
  }

  Future<LookupOutcome> lookUp(
    MergedReading reading,
    CatalogLocale locale,
  ) async {
    try {
      return await flow.run(reading, locale: locale);
    } catch (error, stack) {
      await reporter.report(LabelFailure.lookupFailed, error, stack);
      return const LookupNotFound(NotFoundKind.unreadable);
    }
  }
}

// ---------------------------------------------------------------------------
// The label screens open right now, for "replace with the new photo?"
// (BR1.4, "Chiarimenti dopo la revisione").

/// Whether a label screen is open and holds unsaved data.
enum LabelFlowStatus { none, reading, unsaved }

final labelFlowProvider = NotifierProvider<LabelFlow, LabelFlowStatus>(
  LabelFlow.new,
);

class LabelFlow extends Notifier<LabelFlowStatus> {
  Object? _owner;

  @override
  LabelFlowStatus build() => LabelFlowStatus.none;

  void set(Object owner, LabelFlowStatus status) {
    _owner = owner;
    state = status;
  }

  /// Only the screen that set the status can clear it: a replaced screen
  /// disposed after the new one opened leaves the new status alone.
  void release(Object owner) {
    if (!ref.mounted || !identical(_owner, owner)) return;
    _owner = null;
    state = LabelFlowStatus.none;
  }
}

// ---------------------------------------------------------------------------
// The shared image before it is read (BR1.4, NFR4.5).

/// What the shell must do with a shared image.
sealed class SharedImageEvent {
  const SharedImageEvent(this.serial);

  /// Increases with every event, so two equal events are both seen.
  final int serial;
}

/// Open the reading of the shared image now.
class SharedImageReadNow extends SharedImageEvent {
  const SharedImageReadNow(
    super.serial, {
    required this.multiple,
    this.isText = false,
  });

  final bool multiple;

  /// A text shared by Google Lens: it fills the add form
  /// (label-autofill-windows FR2.1, BR2.4).
  final bool isText;
}

/// "Non puoi aggiungere vini a questa cantina".
class SharedImageNotAllowed extends SharedImageEvent {
  const SharedImageNotAllowed(super.serial);
}

/// "Non è stato possibile leggere la foto condivisa: riprova a condividerla".
class SharedImageExpired extends SharedImageEvent {
  const SharedImageExpired(super.serial);
}

final sharedImageProvider =
    NotifierProvider<SharedImageNotifier, SharedImageEvent?>(
      SharedImageNotifier.new,
    );

/// Holds a shared image (natively, as a URI) until the policy decides
/// (SharedImagePolicy): the gate tells the account ([attachGate], wired by
/// AppBootstrap with [checkColdStart]), the shell tells the cellar and its
/// permission ([updateShell], [shellGone]).
class SharedImageNotifier extends Notifier<SharedImageEvent?> {
  static const SharedImagePolicy _policy = SharedImagePolicy();

  bool _pending = false;
  bool _multiple = false;
  bool _isText = false;
  ShareAccount _account = ShareAccount.unknown;
  bool _signInAttempted = false;
  bool _cellarReady = false;
  bool? _canEdit;
  bool _canEditWaitOver = false;
  bool _readWindowOver = false;
  Timer? _canEditTimer;
  Timer? _readWindowTimer;
  int _serial = 0;

  ValueListenable<GateState>? _gate;

  @override
  SharedImageEvent? build() {
    final channel = ref.watch(sharedImageChannelProvider);
    final subscription = channel.arrivals.listen(_arrived);
    ref.onDispose(() {
      unawaited(subscription.cancel());
      _gate?.removeListener(_onGateChanged);
      _stopTimers();
    });
    return null;
  }

  /// Follows the account gate from start-up (AppBootstrap), so a share can
  /// wait through the sign-in and be dropped when it is cancelled.
  void attachGate(ValueListenable<GateState> gate) {
    _gate?.removeListener(_onGateChanged);
    _gate = gate..addListener(_onGateChanged);
    _onGate(gate.value);
  }

  /// The share that started the app, if any (AppBootstrap, cold start).
  Future<void> checkColdStart() async {
    final channel = ref.read(sharedImageChannelProvider);
    final reporter = ref.read(labelErrorReporterProvider);
    try {
      final notice = await channel.pendingShare();
      if (notice != null && ref.mounted) _arrived(notice);
    } catch (error, stack) {
      await reporter.report(LabelFailure.pickFailed, error, stack);
    }
  }

  void _onGateChanged() {
    final gate = _gate;
    if (gate != null && ref.mounted) _onGate(gate.value);
  }

  void _arrived(SharedImageNotice notice) {
    // A new share replaces the old one and starts its waits again.
    _pending = true;
    _multiple = notice.multiple;
    _isText = notice.isText;
    _canEditWaitOver = false;
    _readWindowOver = false;
    _stopTimers();
    if (_account == ShareAccount.signedIn) _startReadWindow();
    if (_cellarReady) _startCanEditWait();
    _decide();
  }

  void _onGate(GateState gate) {
    final account = switch (gate) {
      GateStarting() => ShareAccount.unknown,
      GateSignIn(busy: true) => ShareAccount.signingIn,
      GateSignIn() =>
        _signInAttempted ? ShareAccount.signInCancelled : ShareAccount.unknown,
      GateEnsureCellar() || GateCellar() => ShareAccount.signedIn,
      _ => ShareAccount.unavailable,
    };
    if (account == ShareAccount.signingIn) _signInAttempted = true;
    if (account == ShareAccount.signedIn) _signInAttempted = false;
    _setAccount(account);
    _decide();
  }

  void _setAccount(ShareAccount account) {
    if (account == ShareAccount.signedIn && _account != account) {
      _startReadWindow();
    }
    _account = account;
  }

  /// The shell is shown, so the person is signed in: whether the cellar is
  /// ready and the permission on the active cellar (`null` while it loads).
  void updateShell({required bool cellarReady, required bool? canEdit}) {
    _setAccount(ShareAccount.signedIn);
    if (cellarReady && !_cellarReady) _startCanEditWait();
    _cellarReady = cellarReady;
    _canEdit = canEdit;
    _decide();
  }

  /// The shell left (signed out, reset).
  void shellGone() {
    _cellarReady = false;
    _canEdit = null;
  }

  /// "Continua con quello aperto": the new photo is dropped.
  Future<void> decline() => _discard();

  void _startReadWindow() {
    _readWindowTimer?.cancel();
    if (!_pending) return;
    _readWindowTimer = Timer(SharedImagePolicy.readWindow, () {
      _readWindowOver = true;
      _decide();
    });
  }

  void _startCanEditWait() {
    _canEditTimer?.cancel();
    if (!_pending) return;
    _canEditTimer = Timer(SharedImagePolicy.canEditWait, () {
      _canEditWaitOver = true;
      _decide();
    });
  }

  void _stopTimers() {
    _canEditTimer?.cancel();
    _readWindowTimer?.cancel();
  }

  void _decide() {
    if (!_pending || !ref.mounted) return;
    final decision = _policy.decide(
      account: _account,
      cellarReady: _cellarReady,
      canEdit: _canEdit,
      canEditWaitOver: _canEditWaitOver,
      readWindowOver: _readWindowOver,
    );
    switch (decision) {
      case ShareDecision.wait:
        return;
      case ShareDecision.read:
        _pending = false;
        _stopTimers();
        state = SharedImageReadNow(
          ++_serial,
          multiple: _multiple,
          isText: _isText,
        );
      case ShareDecision.notAllowed:
        unawaited(_discard());
        state = SharedImageNotAllowed(++_serial);
      case ShareDecision.expired:
        unawaited(_discard());
        state = SharedImageExpired(++_serial);
      case ShareDecision.discard:
        unawaited(_discard());
    }
  }

  Future<void> _discard() async {
    _pending = false;
    _stopTimers();
    if (!ref.mounted) return;
    final channel = ref.read(sharedImageChannelProvider);
    final reporter = ref.read(labelErrorReporterProvider);
    try {
      await channel.discardShare();
    } catch (error, stack) {
      await reporter.report(LabelFailure.pickFailed, error, stack);
    }
  }
}
