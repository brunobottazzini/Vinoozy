import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../catalog/core/wine_catalog.dart';
import '../../cellar/cellar_actions.dart';
import '../../cellar/cellar_providers.dart';
import '../../cellar/data/wine_repository.dart';
import '../../cellar/domain/wine.dart';
import '../../cellar/domain/wine_validator.dart';
import '../../cellar/ui/add_wine_screen.dart';
import '../../cellar/ui/cellar_dialogs.dart';
import '../../l10n/app_localizations.dart';
import '../core/label_session.dart';
import '../label_providers.dart';
import 'add_choice_screen.dart';
import 'barcode_only_view.dart';
import 'label_capture_flow.dart';
import 'label_message_layout.dart';
import 'label_proposal_sheet.dart';
import 'label_unreadable_view.dart';
import 'permission_denied_view.dart';

/// "Leggo l'etichetta…" with "Annulla" (u6-label-recognition BR1.6-BR1.13,
/// frontend-components.md), then the outcome of the reading:
/// - proposal ([LabelProposalSheet]): "Conferma" saves with U4, duplicates
///   included, and goes back to the cellar; "Correggi" opens the U4 form
///   filled (BR1.10, BR1.15);
/// - no wine found: the U4 form with the most significant line and "Non ho
///   trovato il vino: controlla i dati" (BR1.11);
/// - unreadable, barcode only, access refused, no camera: their views, each
///   with "Riprova" or "Scrivi a mano" (NFR6.2).
///
/// "Annulla" goes back to "Aggiungi" at once (NFR1.4); the copy of the
/// photo is deleted when the reading that was running ends.
class LabelReadingScreen extends ConsumerStatefulWidget {
  const LabelReadingScreen({
    super.key,
    required this.target,
    required this.input,
    required this.origin,
  });

  final LabelTarget target;
  final LabelInput input;
  final PhotoOrigin origin;

  @override
  ConsumerState<LabelReadingScreen> createState() => _LabelReadingScreenState();
}

class _LabelReadingScreenState extends ConsumerState<LabelReadingScreen> {
  static int _nextToken = 0;

  /// Each screen has its own session (BR1.4: a replaced screen never sees
  /// the state of the new one).
  final int _token = ++_nextToken;
  late final LabelFlow _flow;
  late final String _wineId;
  bool _saving = false;
  bool _saveFailed = false;

  LabelTarget get _target => widget.target;

  @override
  void initState() {
    super.initState();
    _flow = ref.read(labelFlowProvider.notifier);
    _wineId = ref.read(idGeneratorProvider).newId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _flow.set(this, LabelFlowStatus.reading);
      final locale = CatalogLocale.fromLanguageTag(
        Localizations.localeOf(context).toLanguageTag(),
      );
      ref
          .read(labelSessionProvider(_token).notifier)
          .start(widget.input, locale: locale);
    });
  }

  @override
  void dispose() {
    final flow = _flow;
    final owner = this;
    WidgetsBinding.instance.addPostFrameCallback((_) => flow.release(owner));
    super.dispose();
  }

  void _announce(String message) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
    );
  }

  void _onState(LabelState state) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    switch (state) {
      case LabelProposalState(:final candidate):
        _flow.set(this, LabelFlowStatus.unsaved);
        _announce('${l10n.labelRecognized} ${candidate.name}');
      case LabelIncompleteState(:final name, :final vintage):
        LabelCaptureFlow.openForm(
          context,
          _target,
          initialValues: AddWineInitialValues(
            name: name,
            vintage: vintage,
            notice: l10n.labelNotFound,
          ),
        );
      case LabelUnreadableState():
        _announce(l10n.labelUnreadable);
      case LabelBarcodeOnlyState(:final needsNetwork):
        _announce(
          needsNetwork
              ? l10n.labelBarcodeNeedsNetwork
              : l10n.labelBarcodeNotFound,
        );
      case LabelPermissionDeniedState(:final origin):
        _announce(
          origin == PhotoOrigin.camera
              ? l10n.labelCameraDenied
              : l10n.labelPhotosDenied,
        );
      case LabelCameraUnavailableState():
        _announce(l10n.labelCameraUnavailable);
      case LabelCancelledState():
        Navigator.of(context).pop();
      case LabelIdle() || LabelReadingState():
        break;
    }
  }

  /// "Riprova": the button the reading started from; after a shared photo,
  /// "Aggiungi" (where one can take or import a photo).
  void _retry([PhotoOrigin? origin]) {
    final from = origin ?? widget.origin;
    if (from == PhotoOrigin.shared) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AddChoiceScreen(target: _target),
        ),
      );
      return;
    }
    Navigator.of(context).pop(LabelRetry(from));
  }

  void _writeByHand() => LabelCaptureFlow.openForm(context, _target);

  void _correct(WineCandidate candidate, int quantity) =>
      LabelCaptureFlow.openForm(
        context,
        _target,
        initialValues: AddWineInitialValues.fromCandidate(
          candidate,
          quantity: quantity,
        ),
      );

  /// "Conferma" (BR1.10, BR1.15): the U4 save with its duplicate check; an
  /// error keeps the proposal and the quantity.
  Future<void> _confirm(WineCandidate candidate, int quantity) async {
    if (_saving) return;
    final validation = WineValidator.validate(
      WineInput(
        id: _wineId,
        name: candidate.name,
        producer: candidate.producer ?? '',
        vintage: candidate.vintage?.toString() ?? '',
        noVintage: candidate.vintage == null,
        quantity: quantity,
        wineType: wineFamilyOf(candidate.wineType),
        region: candidate.region,
        denomination: candidate.denomination,
      ),
      currentYear: ref.read(clockProvider).now().year,
    );
    final draft = validation.draft;
    // A catalog value the form would refuse: let the person correct it.
    if (draft == null) return _correct(candidate, quantity);
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    final actions = ref.read(cellarActionsProvider);
    final result = await actions.saveNewWine(
      cellar: _target.cellar,
      user: _target.user,
      draft: draft,
    );
    if (!mounted) return;
    switch (result) {
      case AddSaved():
        _done();
      case AddDuplicate(:final existing):
        await _addToDuplicate(actions, existing, quantity);
      case AddFailed():
        _failed();
    }
  }

  Future<void> _addToDuplicate(
    CellarActions actions,
    Wine existing,
    int quantity,
  ) async {
    final confirmed = await DuplicateDialog.show(
      context,
      existing: existing,
      bottles: quantity,
    );
    if (!mounted) return;
    if (!confirmed) {
      setState(() => _saving = false);
      return;
    }
    final outcome = await actions.addBottles(
      cellar: _target.cellar,
      user: _target.user,
      wine: existing,
      n: DuplicateDialog.addableFor(existing, quantity),
    );
    if (!mounted) return;
    if (outcome is SaveAccepted) {
      _done();
    } else {
      _failed();
    }
  }

  void _failed() => setState(() {
    _saving = false;
    _saveFailed = true;
  });

  /// Back to the cellar with the confirmation (BR1.10).
  void _done() {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).labelWineAdded;
    _flow.release(this);
    Navigator.of(context).popUntil((route) => route.isFirst);
    messenger.showSnackBar(
      SnackBar(key: const Key('label-added-snackbar'), content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen<LabelState>(
      labelSessionProvider(_token),
      (_, next) => _onState(next),
    );
    final state = ref.watch(labelSessionProvider(_token));
    final controller = ref.read(labelSessionProvider(_token).notifier);
    return Scaffold(
      key: const Key('label-reading-screen'),
      appBar: AppBar(title: Text(l10n.addChoiceTitle)),
      body: SafeArea(
        child: switch (state) {
          LabelProposalState(:final candidate, :final offline) =>
            LabelProposalSheet(
              candidate: candidate,
              offline: offline,
              saving: _saving,
              saveFailed: _saveFailed,
              onConfirm: (quantity) => _confirm(candidate, quantity),
              onCorrect: (quantity) => _correct(candidate, quantity),
            ),
          LabelUnreadableState() => LabelUnreadableView(
            onRetry: _retry,
            onWriteByHand: _writeByHand,
          ),
          LabelBarcodeOnlyState(:final needsNetwork) => BarcodeOnlyView(
            needsNetwork: needsNetwork,
            onRetry: _retry,
            onWriteByHand: _writeByHand,
            onRetryOnline: controller.retryBarcode,
          ),
          LabelPermissionDeniedState(:final origin) => PermissionDeniedView(
            origin: origin,
            onOpenSettings: () =>
                ref.read(sharedImageChannelProvider).openSettings(),
            onWriteByHand: _writeByHand,
            onImport: () => _retry(PhotoOrigin.gallery),
          ),
          LabelCameraUnavailableState() => PermissionDeniedView(
            origin: PhotoOrigin.camera,
            cameraUnavailable: true,
            onOpenSettings: () =>
                ref.read(sharedImageChannelProvider).openSettings(),
            onWriteByHand: _writeByHand,
            onImport: () => _retry(PhotoOrigin.gallery),
          ),
          _ => _Reading(onCancel: controller.cancel),
        },
      ),
    );
  }
}

/// "Leggo l'etichetta…", announced as progress, with "Annulla" (BR1.13,
/// NFR3.2).
class _Reading extends StatelessWidget {
  const _Reading({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 24),
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.labelReading,
              key: const Key('label-reading'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            key: const Key('label-cancel'),
            style: labelActionStyle(),
            onPressed: onCancel,
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
