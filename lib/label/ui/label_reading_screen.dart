import 'dart:async';

import 'package:estimation/estimation.dart' show LabelAnalysis;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../catalog/core/wine_catalog.dart';
import '../../catalog/platform/catalog_providers.dart';
import '../../cellar/cellar_actions.dart';
import '../../cellar/cellar_providers.dart';
import '../../cellar/data/wine_repository.dart';
import '../../cellar/domain/wine.dart';
import '../../cellar/domain/wine_validator.dart';
import '../../cellar/ui/add_wine_screen.dart';
import '../../cellar/ui/cellar_dialogs.dart';
import '../../l10n/app_localizations.dart';
import '../../catalog/core/catalog_event_logger.dart' show LensRoute;
import '../core/label_lookup_flow.dart';
import '../core/label_merge.dart';
import '../core/label_session.dart';
import '../label_providers.dart';
import 'add_choice_screen.dart';
import 'back_photo_prompt.dart';
import 'candidate_list.dart';
import 'label_capture_flow.dart';
import 'label_proposal_sheet.dart';
import 'lens_confirm_sheet.dart';
import 'not_found_view.dart';
import 'online_search_screen.dart';
import 'permission_denied_view.dart';
import 'reading_progress.dart';

/// "Leggo l'etichetta…" with "Annulla" (u6-label-recognition BR1.6-BR1.13,
/// frontend-components.md), then the outcome of the reading.
///
/// label-recognition (F1, F2, BR1.1, BR3.2-BR3.5, BR4.4, BR5.1-BR5.3):
/// - "Ora il retro" after the front ([BackPhotoPrompt]), then the reading
///   step by step ([ReadingProgressView]);
/// - a sure proposal ([LabelProposalSheet]): "Conferma" saves with U4,
///   duplicates included, and goes back to the cellar; "Correggi" opens the
///   U4 form filled (BR1.10, BR1.15); "Non è questo" shows the candidates
///   or "not found";
/// - candidates ([CandidateList]): one opens the U4 form filled, above this
///   screen; "Nessuno di questi" shows "not found";
/// - not found ([NotFoundView], three kinds): "Cerca online", "Scrivi a mano"
///   with the text read, and last "Apri in Google Lens" after a
///   confirmation at every tap;
/// - access refused, no camera: their views (NFR6.2).
///
/// "Annulla" goes back to "Aggiungi" at once (NFR1.4); the photos are
/// deleted when this screen closes (BR1.4).
class LabelReadingScreen extends ConsumerStatefulWidget {
  const LabelReadingScreen({
    super.key,
    required this.target,
    required this.input,
    required this.origin,
    this.services,
  });

  final LabelTarget target;
  final LabelInput input;
  final PhotoOrigin origin;

  /// The image source, Google Lens and catalog of the screen that started
  /// the reading ([LabelCaptureFlow]); `null` uses those of this screen.
  final LabelServices? services;

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
  late final LabelServices _services;
  bool _saving = false;
  bool _saveFailed = false;

  LabelTarget get _target => widget.target;

  @override
  void initState() {
    super.initState();
    _flow = ref.read(labelFlowProvider.notifier);
    _wineId = ref.read(idGeneratorProvider).newId();
    _services = widget.services ?? LabelServices.of(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _flow.set(this, LabelFlowStatus.reading);
      final locale = CatalogLocale.fromLanguageTag(
        Localizations.localeOf(context).toLanguageTag(),
      );
      ref
          .read(labelSessionProvider(_token).notifier)
          .start(widget.input, locale: locale, services: _services);
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
      case LabelCandidatesState():
        _flow.set(this, LabelFlowStatus.unsaved);
        _announce(l10n.labelCandidatesTitle);
      case LabelBackPromptState():
        _announce(l10n.labelBackTitle);
      case LabelNotFoundState(:final outcome)
          when outcome.kind == NotFoundKind.noMatch && outcome.opensForm:
        _openFilledForm(outcome);
      case LabelNotFoundState(:final kind):
        _announce(switch (kind) {
          NotFoundKind.unreadable => l10n.labelUnreadable,
          NotFoundKind.barcodeNotFound => l10n.labelBarcodeNotFound,
          NotFoundKind.noMatch => l10n.labelNoMatch,
        });
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

  /// "Scrivi a mano" from "not found" (F2): the form with the most
  /// significant line read, its vintage and "Non ho trovato il vino:
  /// controlla i dati" (u6 BR1.11); empty when nothing was read.
  void _writeFromText(LookupNotFound outcome) {
    if (outcome.name.isEmpty) return _writeByHand();
    LabelCaptureFlow.openForm(
      context,
      _target,
      initialValues: AddWineInitialValues(
        name: outcome.name,
        vintage: outcome.vintage,
        notice: AppLocalizations.of(context).labelNotFound,
      ),
    );
  }

  /// label-autofill-windows BR2.1, F1: no wine found but fields read in the
  /// text: the form filled with them, above this screen ("not found" stays
  /// below it), with "Lens" for the front photo and "Search online".
  void _openFilledForm(LookupNotFound outcome) {
    _flow.set(this, LabelFlowStatus.unsaved);
    final l10n = AppLocalizations.of(context);
    _announce(l10n.autofillFilledNotice);
    final controller = ref.read(labelSessionProvider(_token).notifier);
    unawaited(
      LabelCaptureFlow.openFilledForm(
        context,
        _target,
        identical(outcome.analysis, LabelAnalysis.empty)
            ? AddWineInitialValues.fromLabelFields(
                outcome.fields,
                notice: l10n.autofillFilledNotice,
              )
            : AddWineInitialValues.fromAnalysis(
                outcome.analysis,
                notice: l10n.autofillFilledNotice,
              ),
        onLens: controller.frontPath != null ? _openLens : null,
        onSearchOnline: (_, query) =>
            _searchOnline(outcome, query: query.isEmpty ? null : query),
      ),
    );
  }

  /// "Cerca online" (FR3.1, BR4.1): above this screen, with the words read.
  static String _limitQuery(String query) =>
      query.length > OnlineSearchScreen.maxQueryLength
      ? query.substring(0, OnlineSearchScreen.maxQueryLength)
      : query;

  void _searchOnline(LookupNotFound outcome, {String? query}) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OnlineSearchScreen(
            target: _target,
            initialQuery: _limitQuery(query ?? outcome.query),
            catalog: _services.catalog,
          ),
        ),
      );

  /// "Apri in Google Lens" (BR5.1, BR5.2): the confirmation at every tap;
  /// only then the front leaves. A failure keeps the outcome with a message
  /// (NFR4.10).
  Future<void> _openLens() async {
    final controller = ref.read(labelSessionProvider(_token).notifier);
    if (!await LensConfirmSheet.show(context) || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).labelLensFailed;
    final route = await controller.openLens();
    if (route == LensRoute.failed) {
      messenger.showSnackBar(
        SnackBar(key: const Key('label-lens-failed'), content: Text(failed)),
      );
    }
  }

  void _pickCandidate(WineCandidate candidate) =>
      LabelCaptureFlow.openCandidateForm(context, _target, candidate);

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
    // ux-redesign FR1.3: country and region recognised from the proposal.
    final origin = guessOrigin(candidate);
    final validation = WineValidator.validate(
      WineInput(
        id: _wineId,
        name: candidate.name,
        producer: candidate.producer ?? '',
        vintage: candidate.vintage?.toString() ?? '',
        noVintage: candidate.vintage == null,
        quantity: quantity,
        wineType: wineFamilyOf(candidate.wineType),
        region: origin.region,
        denomination: candidate.denomination,
        country: origin.country,
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
    // Read at each build, never opening the database: the offline results
    // shown below exist only once it is open (review R-02).
    final offlineIsSample = ref.watch(wineDbLoaderProvider).isSample;
    return Scaffold(
      key: const Key('label-reading-screen'),
      appBar: AppBar(title: Text(l10n.addChoiceTitle)),
      body: SafeArea(
        child: switch (state) {
          LabelBackPromptState() => BackPhotoPrompt(
            onTake: () => controller.takeBack(PhotoOrigin.camera),
            onPick: () => controller.takeBack(PhotoOrigin.gallery),
            onSkip: controller.skipBack,
          ),
          LabelProposalState(:final candidate, :final backStatus) =>
            LabelProposalSheet(
              candidate: candidate,
              saving: _saving,
              saveFailed: _saveFailed,
              backUnreadable: backStatus == BackStatus.unreadable,
              offlineIsSample: offlineIsSample,
              onConfirm: (quantity) => _confirm(candidate, quantity),
              onCorrect: (quantity) => _correct(candidate, quantity),
              onNotThis: controller.notThis,
            ),
          LabelCandidatesState(:final candidates, :final backStatus) =>
            _CandidatesView(
              candidates: candidates,
              backUnreadable: backStatus == BackStatus.unreadable,
              offlineIsSample: offlineIsSample,
              onPick: _pickCandidate,
              onNone: controller.noneOfThese,
            ),
          LabelNotFoundState(:final outcome, :final backStatus) => NotFoundView(
            kind: outcome.kind,
            readText: outcome.name,
            photosAvailable: controller.frontPath != null,
            backUnreadable: backStatus == BackStatus.unreadable,
            onRetry: _retry,
            onSearchOnline: () => _searchOnline(outcome),
            onWriteByHand: () => _writeFromText(outcome),
            onLens: _openLens,
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
          LabelReadingState(:final progress) => ReadingProgressView(
            progress: progress,
            onCancel: controller.cancel,
          ),
          _ => ReadingProgressView(
            progress: const ReadingProgress(),
            onCancel: controller.cancel,
          ),
        },
      ),
    );
  }
}

/// "Quale di questi?" (label-recognition FR3.2, F2): the candidates, the
/// count, "Nessuno di questi" and the attribution.
class _CandidatesView extends StatelessWidget {
  const _CandidatesView({
    required this.candidates,
    required this.backUnreadable,
    required this.offlineIsSample,
    required this.onPick,
    required this.onNone,
  });

  final List<WineCandidate> candidates;
  final bool backUnreadable;
  final bool offlineIsSample;
  final ValueChanged<WineCandidate> onPick;
  final VoidCallback onNone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const Key('label-candidates'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (backUnreadable) ...[
            const BackUnreadableNotice(),
            const SizedBox(height: 12),
          ],
          Semantics(
            liveRegion: true,
            header: true,
            child: Text(
              l10n.labelCandidatesTitle,
              key: const Key('label-candidates-title'),
              style: theme.textTheme.titleLarge,
            ),
          ),
          Text(
            l10n.labelCandidatesCount(candidates.length),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          CandidateList(
            candidates: candidates,
            onPick: onPick,
            onNone: onNone,
            offlineIsSample: offlineIsSample,
          ),
        ],
      ),
    );
  }
}
