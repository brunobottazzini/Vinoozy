import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account/gate_state.dart';
import '../account/network_status.dart';
import '../app/providers.dart';
import '../catalog/core/wine_catalog.dart';
import '../catalog/platform/catalog_providers.dart';
import 'core/label_lookup_flow.dart';
import 'core/label_reading.dart';
import 'core/label_session.dart';
import 'core/shared_image_policy.dart';
import 'platform/label_error_reporter.dart';
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

/// One reading session per reading screen, keyed by a token of the screen
/// so a replaced screen never sees the state of the new one (BR1.4).
final labelSessionProvider = NotifierProvider.autoDispose
    .family<LabelSessionController, LabelState, int>(
      LabelSessionController.new,
    );

/// Runs a reading (BR1.6-BR1.8, BR1.11, BR1.13, BR1.14): waits for the
/// start-up cleanup, prepares the image natively, reads it, looks the wine
/// up, and always deletes the copy. Every error is caught here and becomes a
/// fixed reason; none reaches the global handlers (NFR8.2). "Annulla" and
/// closing the screen leave the running work to finish in the background,
/// its result ignored through the read id and its copy deleted.
class LabelSessionController extends Notifier<LabelState> {
  LabelSessionController(this.token);

  final int token;
  final LabelSession _session = LabelSession();
  LabelReader? _reader;
  Future<void> _work = Future<void>.value();

  @override
  LabelState build() {
    // Keeps the catalog session listening while the screen is open.
    ref.listen<WineCatalog>(catalogProvider, (_, _) {});
    ref.onDispose(_onDispose);
    return const LabelIdle();
  }

  void _emit() {
    if (ref.mounted) state = _session.state;
  }

  void _onDispose() {
    _session.cancel();
    // Closed once the work still running has finished with it; a reader the
    // work creates after this point is closed the same way.
    unawaited(
      _work
          .then((_) => _reader?.close())
          .catchError((Object _) {})
          .whenComplete(() => _reader = null),
    );
  }

  /// Everything a reading uses, taken while the screen is open: the work
  /// may finish after the screen closed, when `ref` can no longer be read.
  _ReadingDeps _deps() {
    final reporter = ref.read(labelErrorReporterProvider);
    final clock = ref.read(clockProvider);
    final newReader = ref.read(labelReaderFactoryProvider);
    return _ReadingDeps(
      reporter: reporter,
      store: ref.read(tempLabelStoreProvider),
      channel: ref.read(sharedImageChannelProvider),
      network: ref.read(networkStatusProvider),
      // Created on first use, once per session, closed in _onDispose.
      reader: () => _reader ??= newReader(),
      flow: LabelLookupFlow(
        catalog: ref.read(catalogProvider),
        currentYear: () => clock.now().year,
        onFailure: (error, stack) =>
            unawaited(reporter.report(LabelFailure.lookupFailed, error, stack)),
      ),
    );
  }

  /// Starts the reading of [input]; completes when it has settled. Never
  /// throws.
  Future<void> start(LabelInput input, {required CatalogLocale locale}) {
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
        return _deps().reporter.report(LabelFailure.pickFailed, error, stack);
      case PickedLabelInput() || SharedLabelInput():
        final id = _session.begin();
        _emit();
        final work = _read(_deps(), input, id, locale);
        _work = work;
        return work;
    }
  }

  /// "Annulla" (BR1.13): immediate, the late result is ignored.
  void cancel() {
    _session.cancel();
    _emit();
  }

  /// "Riprova quando torna la rete": the barcode lookup again, with the code
  /// kept in memory only.
  Future<void> retryBarcode() async {
    final current = _session.state;
    if (current is! LabelBarcodeOnlyState) return;
    final deps = _deps();
    final id = _session.begin();
    _emit();
    final outcome = await deps.flow.retryBarcode(
      current.barcode,
      online: await deps.online(),
    );
    if (ref.mounted && _session.complete(id, outcome)) _emit();
  }

  Future<void> _read(
    _ReadingDeps deps,
    LabelInput input,
    int id,
    CatalogLocale locale,
  ) async {
    String? path;
    LookupOutcome outcome = const LookupUnreadable();
    try {
      await deps.store.beforeRead();
      final prepared = await deps.prepare(input);
      if (prepared is PreparedImage) {
        path = prepared.path;
        outcome = await deps.lookUp(prepared.path, locale);
      }
    } finally {
      await deps.store.release(path);
    }
    if (ref.mounted && _session.complete(id, outcome)) _emit();
  }
}

class _ReadingDeps {
  _ReadingDeps({
    required this.reporter,
    required this.store,
    required this.channel,
    required this.network,
    required this.reader,
    required this.flow,
  });

  final LabelErrorReporter reporter;
  final TempLabelStore store;
  final SharedImageChannel channel;
  final NetworkStatus network;
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

  Future<LookupOutcome> lookUp(String path, CatalogLocale locale) async {
    final LabelReading reading;
    try {
      reading = await reader().read(path);
    } catch (error, stack) {
      await reporter.report(LabelFailure.readFailed, error, stack);
      return const LookupUnreadable();
    }
    try {
      return await flow.run(reading, online: await online(), locale: locale);
    } catch (error, stack) {
      await reporter.report(LabelFailure.lookupFailed, error, stack);
      return const LookupUnreadable();
    }
  }

  Future<bool> online() async {
    try {
      return await network.hasNetwork();
    } catch (_) {
      return false;
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
  const SharedImageReadNow(super.serial, {required this.multiple});

  final bool multiple;
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
        state = SharedImageReadNow(++_serial, multiple: _multiple);
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
