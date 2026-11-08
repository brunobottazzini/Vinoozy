import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../catalog/platform/catalog_providers.dart';
import 'core/lens_session.dart';
import 'core/text_autofill.dart';
import 'label_providers.dart';
import 'platform/label_error_reporter.dart';
import 'platform/lens_channel.dart';

// Providers of label-autofill-windows (F2-F4, BR2.2-BR2.7): Google Lens
// opened directly, the clipboard, the trip to Lens, the text flow and the
// add form open now. The adapters have real defaults; tests override them.

/// "From Google Lens" and the clipboard description (BR2.5, BR2.6): the
/// native channel in the app, a fake in tests (never the real Google app).
final lensCameraProvider = Provider<LensCamera>((ref) {
  final camera = MethodChannelLensCamera();
  ref.onDispose(camera.dispose);
  return camera;
});

/// The clipboard text, read only on "Paste from Lens" or once on the way
/// back from Lens (NFR3.1).
final clipboardReaderProvider = Provider<ClipboardReader>(
  (ref) => const FlutterClipboardReader(),
);

/// The trip to Lens of "From Google Lens" (ENT-006): in memory only.
final lensSessionProvider = NotifierProvider<LensSessionHolder, LensSession?>(
  LensSessionHolder.new,
);

class LensSessionHolder extends Notifier<LensSession?> {
  @override
  LensSession? build() => null;

  /// Lens opened at [openedAt] (system milliseconds).
  void start(int openedAt) => state = LensSession(openedAt: openedAt);

  /// The text of [clipTimestamp] was pasted: never again by itself.
  void consume(int clipTimestamp) =>
      state?.consumedClipTimestamp = clipTimestamp;

  void clear() => state = null;
}

/// The steps of BR2.2 on a text, with the catalog of the app.
final textAutofillFlowProvider = Provider<TextAutofillFlow>((ref) {
  final reporter = ref.watch(labelErrorReporterProvider);
  final clock = ref.watch(clockProvider);
  return TextAutofillFlow(
    catalog: ref.watch(catalogProvider),
    currentYear: () => clock.now().year,
    onLookupFailure: (error, stack) =>
        unawaited(reporter.report(LabelFailure.lookupFailed, error, stack)),
    onExtractFailure: (error, stack) => unawaited(
      reporter.report(LabelFailure.appellationsIndexFailed, error, stack),
    ),
  );
});

/// The add form open now, as the shell sees it for a text shared while it
/// is open (BR2.4).
abstract interface class AutofillFormHandle {
  /// True when the person wrote or changed a field, or touched the level.
  bool get isDirty;

  /// Fills the empty fields with [text] (FR2.4).
  Future<void> applySharedText(String text);
}

/// The add form open now, or `null`.
final openAutofillFormProvider =
    NotifierProvider<OpenAutofillForm, AutofillFormHandle?>(
      OpenAutofillForm.new,
    );

class OpenAutofillForm extends Notifier<AutofillFormHandle?> {
  @override
  AutofillFormHandle? build() => null;

  void open(AutofillFormHandle form) => state = form;

  /// Only the form that registered can leave (a replaced form closing late
  /// leaves the new one).
  void close(AutofillFormHandle form) {
    if (!ref.mounted || !identical(state, form)) return;
    state = null;
  }
}
