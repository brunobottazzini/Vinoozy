import 'dart:async';

import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/app_event_logger.dart';
import '../../app/providers.dart';
import '../../catalog/core/wine_catalog.dart';
import '../../catalog/platform/catalog_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../label/autofill_providers.dart';
import '../../label/core/guided_session.dart';
import '../../label/core/lens_session.dart';
import '../../label/core/text_autofill.dart';
import '../../label/ui/lens_instructions_sheet.dart';
import '../../sharing/domain/membership.dart';
import '../cellar_actions.dart';
import '../wine_estimator.dart';
import 'autofill_widgets.dart';
import 'guided_confirm_controller.dart';
import 'guided_confirm_sheet.dart';
import 'level_section.dart';
import '../cellar_providers.dart';
import '../data/wine_repository.dart';
import '../domain/producer_options.dart';
import '../domain/quantity.dart';
import '../domain/wine.dart';
import '../domain/wine_draft.dart';
import '../domain/wine_validator.dart';
import '../../app/theme.dart';
import '../domain/wine_origins.dart';
import 'cellar_dialogs.dart';
import 'classification_state.dart';
import 'style_widgets.dart';
import 'origin_pickers.dart';
import 'quantity_stepper.dart';
import 'wine_badges.dart';
import 'wine_labels.dart';

/// The U4 type family of a catalog type: the conversion used both when a
/// suggestion is picked (BR1.1) and when the label photo fills the form
/// (u6-label-recognition BR1.15).
String? wineFamilyOf(CatalogWineType? type) =>
    WineType.tryParse(type?.name)?.name;

/// The values the form opens with when the label photo fills it
/// (u6-label-recognition BR1.10, BR1.11, BR1.15). Absent values stay empty,
/// as for a new wine; [notice] is a localized text shown on top.
class AddWineInitialValues {
  const AddWineInitialValues({
    this.name,
    this.producer,
    this.vintage,
    this.noVintage = false,
    this.quantity = QuantityLimits.initial,
    this.wineType,
    this.region,
    this.denomination,
    this.country,
    this.notice,
    this.filledKeys = const {},
    this.qualifier,
    this.analysis,
  });

  /// The fields read in a label text (label-autofill-windows BR2.1, F1):
  /// each one is marked "✦ from the text" ([filledKeys]) and the form shows
  /// the autofill bar.
  factory AddWineInitialValues.fromLabelFields(
    LabelFields fields, {
    String? notice,
  }) => AddWineInitialValues(
    name: fields.name,
    producer: fields.producer,
    vintage: fields.vintage,
    wineType: fields.wineType?.name,
    region: fields.region,
    denomination: fields.denomination,
    country: fields.country,
    notice: notice,
    filledKeys: fields.sourceKeys,
    qualifier: fields.qualifier,
  );

  /// The form of a label photo with the guided check (FR7.1, D9, F1): the
  /// certain fields of [analysis] filled, the uncertain ones asked once the
  /// form shows.
  factory AddWineInitialValues.fromAnalysis(
    LabelAnalysis analysis, {
    String? notice,
  }) {
    final fields = analysis.certainFields;
    return AddWineInitialValues(
      name: fields.name,
      producer: fields.producer,
      vintage: fields.vintage,
      wineType: fields.wineType?.name,
      region: fields.region,
      denomination: fields.denomination,
      country: fields.country,
      notice: notice,
      filledKeys: fields.sourceKeys,
      qualifier: analysis.qualifier,
      analysis: analysis,
    );
  }

  /// A catalog proposal with the chosen quantity ("Correggi"): its type is
  /// converted with [wineFamilyOf]; no vintage means "no vintage", as the
  /// proposal showed it. Country and region come from [guessOrigin]
  /// (ux-redesign FR1.3).
  factory AddWineInitialValues.fromCandidate(
    WineCandidate candidate, {
    int quantity = QuantityLimits.initial,
    String? notice,
  }) {
    final origin = guessOrigin(candidate);
    return AddWineInitialValues(
      name: candidate.name,
      producer: candidate.producer,
      vintage: candidate.vintage,
      noVintage: candidate.vintage == null,
      quantity: quantity,
      wineType: candidate.exactType?.name ?? wineFamilyOf(candidate.wineType),
      region: origin.region,
      denomination: candidate.denomination,
      country: origin.country,
      notice: notice,
    );
  }

  final String? name;
  final String? producer;
  final int? vintage;
  final bool noVintage;

  /// Kept within 1-99 (FR2.4).
  final int quantity;

  /// A U4 [WineType] name.
  final String? wineType;
  final String? region;
  final String? denomination;

  /// ISO code recognised from the catalog or the label (FR1.3), or `null`.
  final String? country;
  final String? notice;

  /// The fields filled from a label text, named as [LabelFieldKeys]; not
  /// empty means the form was filled from a text.
  final Set<String> filledKeys;

  /// The qualifier read in the text, for the level suggestion (FR4.3).
  final Qualifier? qualifier;

  /// The analysis of the text (D9): with uncertain fields the guide opens
  /// after the first frame (FR7.1). In memory only (FR7.9).
  final LabelAnalysis? analysis;
}

/// Country and region of a catalog, Open Food Facts or label proposal
/// (ux-redesign FR1.3, review R-06): from its denomination, its name or its
/// region text (`origins` for Open Food Facts).
///
/// label-recognition FR2.1: when nothing in the texts names a country, the
/// country of the offline database (an ISO code) is used.
OriginGuess guessOrigin(WineCandidate candidate) {
  final guess = WineOrigins.guess(
    region: candidate.region,
    denomination: candidate.denomination,
    name: candidate.name,
  );
  final known = WineOrigins.country(candidate.country);
  if (guess.country != null || known == null) return guess;
  return OriginGuess(country: known.code, region: guess.region);
}

/// M4b — add a wine (US2.1, US2.3; BR1.1-BR1.5, BR1.15, BR1.18), the full
/// version of u4-cellar that replaces the U1 form.
///
/// - The name field is active at opening (BR1.18). From the third character
///   the catalog of U3 proposes wines (BR1.1); a proposal fills name,
///   producer, vintage, type, denomination and region.
/// - The producer field proposes the known producers and, last, "Add «text»
///   as a new producer" (BR1.2).
/// - "Save" validates every field (BR1.3), looks for the same wine in the
///   cellar, finished ones included (BR1.4): if it exists, the dialog adds
///   the bottles to it; otherwise the wine is saved on the phone with the
///   internal estimate and the form closes at once (BR1.5, BR1.18).
///
/// The wine id is generated once when the form opens (U1 BR2.4), and Save is
/// disabled while saving, so a double tap cannot create two wines. The U1
/// test keys are kept (stable across versions).
class AddWineScreen extends ConsumerStatefulWidget {
  const AddWineScreen({
    super.key,
    required this.user,
    required this.cellarId,
    this.initialName,
    this.cellar,
    this.prefill,
    this.cellarWines = const [],
    this.initialValues,
    this.returnToRootOnSave = false,
    this.onLens,
    this.onSearchOnline,
    this.sharedText,
    this.openLensOnStart = false,
  });

  final AppUser user;
  final String cellarId;

  /// "Add again" after a rejected wine reopens the form with the name only.
  final String? initialName;

  /// The active cellar; when absent, the form only knows it can edit it.
  final AccessibleCellar? cellar;

  /// "Add again" from the History (BR1.16): the form filled with this wine.
  final Wine? prefill;

  /// The wines loaded in the cellar, for suggestions and producers.
  final List<Wine> cellarWines;

  /// The form filled from the label photo (u6 BR1.15).
  final AddWineInitialValues? initialValues;

  /// label-recognition BR4.4: opened above the candidate list (so back
  /// returns to it), a save goes back to the cellar, not to the list.
  final bool returnToRootOnSave;

  /// "Lens" of the autofill bar: only with the front photo of a reading
  /// (interaction-spec "La barra"); `null` hides it.
  final VoidCallback? onLens;

  /// "Search online" of the autofill bar, with the words of the form.
  final void Function(BuildContext context, String query)? onSearchOnline;

  /// A text shared to the app with no form open (BR2.4): applied once the
  /// form is shown.
  final String? sharedText;

  /// "From Google Lens" (BR2.5): the empty form opens first, then Lens.
  final bool openLensOnStart;

  void _closeAfterSave(BuildContext context) {
    final navigator = Navigator.of(context);
    if (returnToRootOnSave) {
      navigator.popUntil((route) => route.isFirst);
    } else {
      navigator.pop();
    }
  }

  @override
  ConsumerState<AddWineScreen> createState() => _AddWineScreenState();
}

class _AddWineScreenState extends ConsumerState<AddWineScreen>
    with WidgetsBindingObserver
    implements AutofillFormHandle {
  late final String _wineId;
  late final TextEditingController _name;
  late final TextEditingController _producer;
  final TextEditingController _vintage = TextEditingController();
  final TextEditingController _denomination = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _producerFocus = FocusNode();
  final FocusNode _vintageFocus = FocusNode();
  bool _noVintage = false;
  int _quantity = QuantityLimits.initial;
  String? _wineType;
  OriginSelection _origin = const OriginSelection();
  NameError? _nameError;
  ProducerError? _producerError;
  VintageError? _vintageError;
  DenominationError? _denominationError;
  bool _saving = false;
  bool _saveFailed = false;

  // label-autofill-windows (F1-F4, BR2.7, BR4.3).

  /// The fields marked "✦ from the text" ([LabelFieldKeys]).
  final Set<String> _filled = {};

  /// True once a descriptive field was written or changed by hand.
  bool _manual = false;

  /// The autofill bar: from the first text received, until the form closes.
  bool _toolbar = false;

  /// A wine certain in the catalog for a pasted or shared text (FR2.5).
  WineCandidate? _sureMatch;
  final LevelChoice _level = LevelChoice();

  /// wine-style-profiles (F2): Type, Style, date and their sources.
  ClassificationState _class = ClassificationState();
  final TextEditingController _agingYear = TextEditingController();
  AgingStartError? _agingError;
  bool _autoPasting = false;
  StreamSubscription<void>? _focusEvents;
  late final OpenAutofillForm _openForms;

  // The guided check (FR7, D10, D11) and the visible wait (FR2.8).

  /// The memory of the guide of this form: in the `State` only, never
  /// restored by Android (BR7.19, FR7.9).
  late final GuidedConfirmController _guide = GuidedConfirmController(
    onApply: _applyGuideEffect,
    contextOf: _guideContext,
  );

  /// From the tap on "Paste from Lens" (or the automatic paste) to the
  /// result (BR7.24).
  bool _reading = false;

  /// The qualifier of the last text suggests the level although its name
  /// was not filled (BR7.8 c).
  bool _qualifierWithoutName = false;
  final FocusNode _pasteFocus = FocusNode();
  final FocusNode _guideFocus = FocusNode();

  /// Where the focus goes when the guide closes (A16); `null` is the first
  /// filled field.
  FocusNode? _returnFocus;

  /// "Filled from the text" shown on top of the guide opened by the same
  /// text, instead of a SnackBar over its answers.
  String? _guideMessage;

  int get _currentYear => ref.read(clockProvider).now().year;

  AccessibleCellar get _cellar =>
      widget.cellar ??
      AccessibleCellar(
        cellarId: widget.cellarId,
        ownerId: widget.cellarId,
        ownerName: '',
        role: widget.cellarId == widget.user.uid
            ? CellarRole.owner
            : CellarRole.edit,
      );

  @override
  void initState() {
    super.initState();
    _wineId = ref.read(idGeneratorProvider).newId();
    final prefill = widget.prefill;
    final initial = widget.initialValues;
    _name = TextEditingController(
      text: prefill?.name ?? initial?.name ?? widget.initialName ?? '',
    );
    _producer = TextEditingController(
      text: prefill?.producer ?? initial?.producer ?? '',
    );
    if (prefill != null) {
      _vintage.text = prefill.vintage?.toString() ?? '';
      _noVintage = prefill.vintage == null;
      _wineType = WineType.tryParse(prefill.wineType)?.name;
      _class = ClassificationState.ofWine(prefill);
      _agingYear.text = prefill.agingStart?.year.toString() ?? '';
      _origin = OriginSelection(
        country: prefill.displayCountry,
        region: prefill.region,
      );
      _denomination.text = prefill.denomination ?? '';
    } else if (initial != null) {
      _vintage.text = initial.vintage?.toString() ?? '';
      _noVintage = initial.vintage == null && initial.noVintage;
      _quantity = initial.quantity.clamp(
        QuantityLimits.min,
        QuantityLimits.max,
      );
      _wineType = WineType.tryParse(initial.wineType)?.name;
      _origin = OriginSelection(
        country: WineOrigins.effectiveCountry(initial.country, initial.region),
        region: initial.region,
      );
      _denomination.text = initial.denomination ?? '';
      _filled.addAll(initial.filledKeys);
      _toolbar = initial.filledKeys.isNotEmpty;
      _level.textQualifier = initial.qualifier;
      if (initial.analysis case final analysis?) {
        _guide.receiveText(analysis);
        _qualifierWithoutName =
            analysis.qualifier != null &&
            !initial.filledKeys.contains(LabelFieldKeys.name);
        if (_guide.pending(_emptyKeyFields).isNotEmpty) _toolbar = true;
      }
    }
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) {
        setState(() => _nameError = WineRules.validateName(_name.text));
      }
    });
    _producerFocus.addListener(() => setState(() {}));
    _vintageFocus.addListener(() {
      if (!_vintageFocus.hasFocus) setState(_validateVintageField);
    });
    WidgetsBinding.instance.addObserver(this);
    _focusEvents = ref
        .read(lensCameraProvider)
        .windowFocused
        .listen((_) => unawaited(_autoPaste()));
    _openForms = ref.read(openAutofillFormProvider.notifier);
    // Not while the tree builds: providers cannot change then.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openForms.open(this);
      // FR7.1, F1: the form of a label photo asks its uncertain fields.
      if (widget.initialValues?.analysis != null) _openGuide(null);
      if (widget.sharedText case final text?) {
        unawaited(_applyText(text, AutofillOrigin.share));
      }
      if (widget.openLensOnStart) unawaited(_openLens());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // BR2.6: on the way back from Lens, and again at the first focus.
    if (state == AppLifecycleState.resumed) unawaited(_autoPaste());
    // The person is in Lens (or elsewhere) with the form open: the offline
    // database opens now, in the background, so the text pasted on the way
    // back is looked up at once instead of waiting for that opening.
    if (state == AppLifecycleState.hidden) {
      unawaited(ref.read(wineDbLoaderProvider).open());
    }
  }

  void _validateVintageField() {
    _vintageError = WineRules.validateVintage(
      _vintage.text,
      noVintage: _noVintage,
      currentYear: _currentYear,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_focusEvents?.cancel());
    final forms = _openForms;
    final form = this;
    WidgetsBinding.instance.addPostFrameCallback((_) => forms.close(form));
    _name.dispose();
    _producer.dispose();
    _vintage.dispose();
    _denomination.dispose();
    _agingYear.dispose();
    _nameFocus.dispose();
    _producerFocus.dispose();
    _vintageFocus.dispose();
    _pasteFocus.dispose();
    _guideFocus.dispose();
    _guide.dispose();
    super.dispose();
  }

  void _onNameChanged(String text) {
    ref
        .read(wineSuggestionsProvider.notifier)
        .update(
          text,
          cellarWines: [
            for (final wine in widget.cellarWines)
              CellarWineRef(
                name: wine.name,
                producer: wine.producer,
                vintage: wine.vintage,
              ),
          ],
          locale: CatalogLocale.fromLanguageTag(
            Localizations.localeOf(context).toLanguageTag(),
          ),
        );
  }

  /// A proposal fills the form (BR1.1).
  void _pick(WineCandidate candidate) {
    ref.read(wineSuggestionsProvider.notifier).clear();
    setState(() {
      _name.text = candidate.name;
      _producer.text = candidate.producer ?? _producer.text;
      final vintage = candidate.vintage;
      if (vintage != null) {
        _vintage.text = '$vintage';
        _noVintage = false;
      }
      // wine-style-profiles BR3.5: the Type of the 8 values when known.
      _wineType =
          candidate.exactType?.name ??
          wineFamilyOf(candidate.wineType) ??
          _wineType;
      // FR1.3: country and region filled in, still editable.
      final origin = guessOrigin(candidate);
      if (origin.country != null) {
        _origin = OriginSelection(
          country: origin.country,
          region: origin.region,
        );
      } else if (origin.region != null) {
        _origin = _origin.withRegion(origin.region);
      }
      if (candidate.denomination case final denomination?) {
        _denomination.text = denomination;
      }
      _nameError = null;
    });
    _nameFocus.unfocus();
  }

  void _pickProducer(ProducerOption option) {
    setState(() {
      _producer.text = option.name;
      _edited(LabelFieldKeys.producer);
    });
    _producerFocus.unfocus();
  }

  // label-autofill-windows -------------------------------------------------

  /// A descriptive field changed by hand: its "✦" goes, and "Clear" asks
  /// first (FR1.3, BR2.7). Call inside setState.
  void _edited(String key) {
    _filled.remove(key);
    _manual = true;
    // BR7.19: a key field written by hand is never asked again.
    if (_keyFieldOf(key) case final field?) _guide.markManual(field);
  }

  static KeyField? _keyFieldOf(String key) => switch (key) {
    LabelFieldKeys.denomination => KeyField.denomination,
    LabelFieldKeys.producer => KeyField.producer,
    LabelFieldKeys.name => KeyField.name,
    LabelFieldKeys.vintage => KeyField.vintage,
    _ => null,
  };

  /// The key fields empty in the form now (BR7.10).
  Set<KeyField> get _emptyKeyFields => {
    if (_denomination.text.trim().isEmpty) KeyField.denomination,
    if (_producer.text.trim().isEmpty) KeyField.producer,
    if (_name.text.trim().isEmpty) KeyField.name,
    if (_vintage.text.trim().isEmpty && !_noVintage) KeyField.vintage,
  };

  GuidedContext _guideContext() => GuidedContext(
    currentYear: _currentYear,
    wineType: WineType.tryParse(_wineType),
    country: _origin.country,
  );

  /// Opens the guide when a question is left (FR7.1, BR7.17); the focus
  /// comes back to [returnFocus] at the end (A16).
  bool _openGuide(FocusNode? returnFocus) {
    if (!mounted || _guide.isOpen) return false;
    _returnFocus = returnFocus;
    final opened = _guide.open(_emptyKeyFields);
    if (opened) setState(() => _toolbar = true);
    return opened;
  }

  /// The effects of an answer on the form (BR7.12, BR7.13, BR7.20).
  void _applyGuideEffect(GuidedEffect effect) {
    if (!mounted) return;
    switch (effect) {
      case FillEffect():
        setState(() => _fillFromGuide(effect));
      case NoVintageEffect():
        setState(() {
          _noVintage = true;
          _vintage.clear();
          _vintageError = null;
          _filled.remove(LabelFieldKeys.vintage);
        });
      case AnnounceProposalEffect(:final value):
        final l10n = AppLocalizations.of(context);
        SemanticsService.sendAnnouncement(
          View.of(context),
          l10n.guideProposalAnnounce(value),
          Directionality.of(context),
        );
      case ClosedEffect(:final completed, :final skipped):
        setState(() => _guideMessage = null);
        _focusAfterGuide();
        if (completed && skipped.isNotEmpty) {
          final l10n = AppLocalizations.of(context);
          _snack(
            skipped.length == 1
                ? l10n.guideSkippedNotice(skipped.single.name)
                : l10n.guideSkippedMany(skipped.length),
          );
        }
    }
  }

  void _focusAfterGuide() {
    final target = _returnFocus;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (target != null && target.context != null && target.canRequestFocus) {
        target.requestFocus();
      } else {
        _nameFocus.requestFocus();
      }
    });
  }

  /// An answer of the guide in its field (BR7.12); a denomination of the
  /// tables also gives type, country and region, replacing only empty
  /// fields or values read from the text (BR7.20). Call inside setState.
  void _fillFromGuide(FillEffect effect) {
    final key = effect.field.labelFieldKey;
    final value = effect.value;
    switch (effect.field) {
      case KeyField.name:
        _name.text = value;
        _nameError = null;
      case KeyField.producer:
        _producer.text = value;
        _producerError = null;
      case KeyField.denomination:
        _denomination.text = value;
        _denominationError = null;
      case KeyField.vintage:
        _vintage.text = value;
        _noVintage = false;
        _vintageError = null;
    }
    if (effect.fromText && value.isNotEmpty) {
      _filled.add(key);
    } else {
      _filled.remove(key);
      if (value.isNotEmpty) _manual = true;
    }
    final row = effect.denominationKey;
    final analysis = _guide.memory.analysis;
    if (row == null || analysis == null) return;
    final derived = analysis.fieldsForDenomination(row);
    if (derived.wineType case final type?
        when _wineType == null || _filled.contains(LabelFieldKeys.wineType)) {
      _wineType = type.name;
      _filled.add(LabelFieldKeys.wineType);
    }
    if (derived.country case final country?
        when _origin.country == null ||
            _filled.contains(LabelFieldKeys.country)) {
      if (_origin.country != country) {
        _origin = _origin.withCountry(country);
        _filled.remove(LabelFieldKeys.region);
      }
      _filled.add(LabelFieldKeys.country);
    }
    if (derived.region case final region?
        when (_origin.region == null ||
                _filled.contains(LabelFieldKeys.region)) &&
            _origin.country == derived.country) {
      _origin = _origin.withRegion(region);
      if (_origin.region != null) _filled.add(LabelFieldKeys.region);
    }
    // FR4.3: the suggestion follows the qualifier read with the row.
    if (derived.qualifier != null) _level.textQualifier = derived.qualifier;
  }

  bool get _hasEmptyField =>
      _name.text.trim().isEmpty ||
      _producer.text.trim().isEmpty ||
      _denomination.text.trim().isEmpty ||
      (_vintage.text.trim().isEmpty && !_noVintage) ||
      _wineType == null ||
      _origin.country == null ||
      _origin.region == null;

  @override
  bool get isDirty => _manual || _level.touched;

  @override
  Future<void> applySharedText(String text) =>
      _applyText(text, AutofillOrigin.share);

  CatalogLocale get _locale => CatalogLocale.fromLanguageTag(
    Localizations.localeOf(context).toLanguageTag(),
  );

  /// BR2.2: a sure wine is proposed above the form; otherwise the fields
  /// read fill only the empty fields (FR2.4). The text is never kept.
  Future<void> _applyText(String raw, AutofillOrigin origin) async {
    final flow = ref.read(textAutofillFlowProvider);
    final events = ref.read(appEventLoggerProvider);
    final result = await flow.run(raw, locale: _locale);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    switch (result) {
      case TextSureMatch(:final candidate):
        setState(() {
          _sureMatch = candidate;
          _toolbar = true;
        });
        events.autofillResult(origin, AutofillOutcome.sureMatch, 0);
      case TextFields(:final analysis):
        // BR7.18: a new text closes the guide open, keeping its answers.
        final guided = !identical(analysis, LabelAnalysis.empty);
        if (guided) _guide.receiveText(analysis);
        final added = <String>{};
        setState(() {
          added.addAll(_fillEmpty(result.filled));
          if (guided) _takeQualifier(analysis, added);
          if (added.isNotEmpty) _toolbar = true;
        });
        final questions = _guide.pending(_emptyKeyFields);
        if (added.isEmpty && questions.isEmpty) {
          events.autofillResult(origin, AutofillOutcome.noFields, 0);
          _snack(l10n.autofillNoNewFields);
          return;
        }
        events.autofillResult(origin, AutofillOutcome.filled, added.length);
        final filledMessage = added.isEmpty
            ? null
            : origin == AutofillOrigin.auto
            ? l10n.autofillFromLens
            : l10n.autofillPastedNotice;
        if (questions.isNotEmpty) {
          // The message goes on top of the sheet: a SnackBar would cover
          // its answers (A18).
          _guideMessage = filledMessage;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _openGuide(origin == AutofillOrigin.share ? null : _pasteFocus);
        } else if (filledMessage != null) {
          _snack(filledMessage);
        }
    }
  }

  /// BR7.8 (c): the qualifier of the analysis goes to the level suggestion
  /// with every text, even when the name stays empty. Call inside setState.
  void _takeQualifier(LabelAnalysis analysis, Set<String> added) {
    if (analysis.qualifier == null) return;
    _level.textQualifier = analysis.qualifier;
    _qualifierWithoutName = !added.contains(LabelFieldKeys.name);
  }

  /// FR2.4: [fields] go only into the empty fields, each marked "✦"; a
  /// field answered in the guide never fills by itself (BR7.18).
  Set<String> _fillEmpty(LabelFields fields) {
    final added = <String>{};
    final answered = _guide.memory.answers;
    if (fields.name case final name?
        when _name.text.trim().isEmpty &&
            !answered.containsKey(KeyField.name)) {
      _name.text = name;
      _nameError = null;
      added.add(LabelFieldKeys.name);
      _level.textQualifier = fields.qualifier;
    }
    if (fields.producer case final producer?
        when _producer.text.trim().isEmpty &&
            !answered.containsKey(KeyField.producer)) {
      _producer.text = producer;
      added.add(LabelFieldKeys.producer);
    }
    if (fields.denomination case final denomination?
        when _denomination.text.trim().isEmpty &&
            !answered.containsKey(KeyField.denomination)) {
      _denomination.text = denomination;
      added.add(LabelFieldKeys.denomination);
    }
    if (fields.vintage case final vintage?
        when _vintage.text.trim().isEmpty &&
            !_noVintage &&
            !answered.containsKey(KeyField.vintage)) {
      _vintage.text = '$vintage';
      _vintageError = null;
      added.add(LabelFieldKeys.vintage);
    }
    if (fields.wineType case final type? when _wineType == null) {
      _wineType = type.name;
      added.add(LabelFieldKeys.wineType);
    }
    if (fields.country case final country? when _origin.country == null) {
      _origin = _origin.withCountry(country);
      added.add(LabelFieldKeys.country);
    }
    if (fields.region case final region?
        when _origin.region == null &&
            (fields.country == null || fields.country == _origin.country)) {
      _origin = _origin.withRegion(region);
      if (_origin.region != null) added.add(LabelFieldKeys.region);
    }
    _filled.addAll(added);
    return added;
  }

  /// "Use" on the sure wine of a text (FR2.5): it fills the form.
  void _useSureMatch(WineCandidate candidate) {
    _pick(candidate);
    setState(() {
      _sureMatch = null;
      _filled.addAll({
        LabelFieldKeys.name,
        if (candidate.producer != null) LabelFieldKeys.producer,
        if (candidate.denomination != null) LabelFieldKeys.denomination,
        if (candidate.vintage != null) LabelFieldKeys.vintage,
        if (_wineType != null) LabelFieldKeys.wineType,
        if (_origin.country != null) LabelFieldKeys.country,
        if (_origin.region != null) LabelFieldKeys.region,
      });
    });
  }

  /// "Paste from Lens" (FR2.2, NFR3.1): the clipboard is read once, here.
  Future<void> _paste() async {
    if (_reading) return;
    // BR7.24: the button waits visibly from the tap to the result.
    setState(() => _reading = true);
    try {
      final text = await ref.read(clipboardReaderProvider).readText();
      if (!mounted) return;
      if (text == null || text.trim().isEmpty) {
        _snack(AppLocalizations.of(context).autofillClipboardEmpty);
        return;
      }
      await _applyText(text, AutofillOrigin.paste);
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  /// "From Google Lens" (BR2.5): the Lens app, else Lens in the Google app,
  /// else the three steps. An opening starts the trip for the paste.
  Future<void> _openLens() async {
    final opening = await ref.read(lensCameraProvider).openLensCamera();
    ref.read(appEventLoggerProvider).lensOpen(switch (opening.route) {
      LensCameraRoute.lensApp => LensOpenResult.lensApp,
      LensCameraRoute.googleApp => LensOpenResult.googleApp,
      LensCameraRoute.unavailable => LensOpenResult.unavailable,
    });
    if (!mounted) return;
    final openedAt = opening.openedAt;
    if (opening.opened && openedAt != null) {
      ref.read(lensSessionProvider.notifier).start(openedAt);
    } else {
      await LensInstructionsSheet.show(context);
    }
  }

  /// BR2.6: the text copied in Lens after it opened, read by itself once.
  Future<void> _autoPaste() async {
    if (_autoPasting || !mounted) return;
    final session = ref.read(lensSessionProvider);
    if (session == null) return;
    _autoPasting = true;
    try {
      final clock = ref.read(clockProvider);
      final text = await LensAutoPaste(
        camera: ref.read(lensCameraProvider),
        clipboard: ref.read(clipboardReaderProvider),
        nowMillis: () => clock.now().millisecondsSinceEpoch,
      ).take(session);
      if (!mounted || text == null || text.trim().isEmpty) return;
      setState(() => _reading = true);
      await _applyText(text, AutofillOrigin.auto);
    } finally {
      _autoPasting = false;
      if (mounted && _reading) setState(() => _reading = false);
    }
  }

  /// "Clear" (FR1.4, BR2.7): asks first only after changes by hand or a
  /// level touched.
  Future<void> _clear() async {
    if (isDirty && !await ClearFormDialog.show(context)) return;
    if (!mounted) return;
    // BR7.21: the guide closes and its memory empties.
    _guide.clear();
    setState(() {
      _qualifierWithoutName = false;
      _name.clear();
      _producer.clear();
      _denomination.clear();
      _vintage.clear();
      _noVintage = false;
      _wineType = null;
      _class = ClassificationState();
      _agingYear.clear();
      _agingError = null;
      _origin = const OriginSelection();
      _level.reset();
      _filled.clear();
      _manual = false;
      _sureMatch = null;
      _nameError = null;
      _producerError = null;
      _vintageError = null;
      _denominationError = null;
    });
    ref.read(wineSuggestionsProvider.notifier).clear();
    _nameFocus.requestFocus();
    _snack(AppLocalizations.of(context).autofillCleared);
  }

  String get _searchQuery => [
    _name.text,
    _producer.text,
    _denomination.text,
    _vintage.text,
  ].map((part) => part.trim()).where((part) => part.isNotEmpty).join(' ');

  /// The newest message replaces the one on screen, so the result of the
  /// last action is the one read.
  void _snack(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(key: const Key('autofill-snackbar'), content: Text(message)),
    );

  Qualifier? get _suggestion => _level.suggestionFor(
    _name.text,
    _denomination.text,
    // BR7.8 (c): the qualifier of an analysis counts while the name is the
    // one read from the text, or still empty.
    nameFromText:
        _filled.contains(LabelFieldKeys.name) ||
        (_qualifierWithoutName && _name.text.trim().isEmpty),
  );

  WineFactsInput? get _facts {
    final name = _name.text.trim();
    if (name.isEmpty) return null;
    final denomination = _denomination.text.trim();
    final now = ref.read(clockProvider).now();
    return WineFactsInput(
      name: name,
      producer: _producer.text.trim().isEmpty ? null : _producer.text.trim(),
      vintage: _noVintage ? null : int.tryParse(_vintage.text),
      wineType: _class.type?.name,
      region: _origin.region,
      denomination: denomination.isEmpty ? null : denomination,
      referenceYear: _currentYear,
      referenceMonth: now.month,
      style: _class.style,
      styleChosen: _class.styleIsUser,
      agingStart: _validAgingStart,
    );
  }

  /// The date when it is valid now (the estimate preview uses it).
  AgingStart? get _validAgingStart {
    final start = _class.agingStart;
    if (start == null) return null;
    final now = ref.read(clockProvider).now();
    return WineValidator.validateAgingStart(
              start.year,
              start.month,
              vintage: _noVintage ? null : int.tryParse(_vintage.text.trim()),
              now: now,
            ) ==
            null
        ? start
        : null;
  }

  /// wine-style-profiles (F2, BR7.2, BR4.6): the preselection of the fields
  /// still automatic, recomputed from the form at every build.
  void _refreshClassification() {
    final denomination = _denomination.text.trim();
    final producer = _producer.text.trim();
    _class.refresh(
      name: _name.text,
      producer: producer.isEmpty ? null : producer,
      denomination: denomination.isEmpty ? null : denomination,
      vintage: _noVintage ? null : int.tryParse(_vintage.text.trim()),
      country: _origin.country,
      dbType: WineType.tryParse(_wineType),
      referenceYear: _currentYear,
    );
    _level.preselected = _name.text.trim().isEmpty
        ? null
        : suggestedLevel(
            _name.text,
            producer: producer.isEmpty ? null : producer,
            denomination: denomination.isEmpty ? null : denomination,
            type: _class.type,
            profile: _class.style?.profile ?? _class.resolution?.profile,
            styleToConfirm: _class.styleToConfirm,
          );
  }

  Future<void> _save() async {
    if (_saving) return;
    final validation = WineValidator.validate(
      WineInput(
        id: _wineId,
        name: _name.text,
        producer: _producer.text,
        vintage: _vintage.text,
        noVintage: _noVintage,
        quantity: _quantity,
        wineType: _class.type?.name,
        region: _origin.region,
        denomination: _denomination.text,
        country: _origin.country,
        // BR4.3: the level chosen, or the suggestion visible (accepted).
        level: _level.effective(_suggestion),
        // wine-style-profiles BR7.1, BR8.1.
        typeSource: _class.typeSource,
        levelSource: _level.sourceFor(_suggestion),
        style: _class.style,
        styleSource: _class.styleSource,
        agingStartYear: _class.agingStartVisible ? _class.agingYear : null,
        agingStartMonth: _class.agingStartVisible ? _class.agingMonth : null,
      ),
      currentYear: _currentYear,
      currentMonth: ref.read(clockProvider).now().month,
    );
    final draft = validation.draft;
    setState(() {
      _agingError = validation.agingStartError;
      _nameError = validation.nameError;
      _producerError = validation.producerError;
      _vintageError = validation.vintageError;
      _denominationError = validation.denominationError;
    });
    if (draft == null) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    final actions = ref.read(cellarActionsProvider);
    final result = await actions.saveNewWine(
      cellar: _cellar,
      user: widget.user,
      draft: draft,
    );
    if (!mounted) return;
    switch (result) {
      case AddSaved():
        widget._closeAfterSave(context);
      case AddDuplicate(:final existing):
        await _confirmDuplicate(actions, existing, draft);
      case AddFailed():
        setState(() {
          _saving = false;
          _saveFailed = true;
        });
    }
  }

  /// BR1.4: the existing entry with its quantity; confirming adds the
  /// bottles (a finished wine comes back), cancelling goes back to the form.
  Future<void> _confirmDuplicate(
    CellarActions actions,
    Wine existing,
    WineDraft draft,
  ) async {
    final confirmed = await DuplicateDialog.show(
      context,
      existing: existing,
      bottles: draft.quantity,
    );
    if (!mounted) return;
    if (!confirmed) {
      setState(() => _saving = false);
      return;
    }
    // At most up to 99 bottles in all (BR1.3 cap, review R-05).
    final outcome = await actions.addBottles(
      cellar: _cellar,
      user: widget.user,
      wine: existing,
      n: DuplicateDialog.addableFor(existing, draft.quantity),
    );
    if (!mounted) return;
    if (outcome is SaveAccepted) {
      widget._closeAfterSave(context);
    } else {
      setState(() {
        _saving = false;
        _saveFailed = true;
      });
    }
  }

  String? _nameErrorText(AppLocalizations l10n) => switch (_nameError) {
    NameError.empty => l10n.nameRequired,
    NameError.tooLong => l10n.nameTooLong,
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    _refreshClassification();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final suggestions = ref.watch(wineSuggestionsProvider).suggestions;
    // D10: the guide is a layer of this form, not a route; Back closes it
    // before the form (A19).
    return ListenableBuilder(
      listenable: _guide,
      builder: (context, _) => PopScope(
        canPop: !_guide.isOpen,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _guide.dispatch(const BackAction());
        },
        child: _scaffold(context, l10n, theme, suggestions),
      ),
    );
  }

  Widget _scaffold(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    List<WineCandidate> suggestions,
  ) {
    final guideOpen = _guide.isOpen;
    final pending = guideOpen
        ? const <KeyField>[]
        : _guide.pending(_emptyKeyFields);
    return Scaffold(
      key: const Key('add-wine-screen'),
      appBar: AppBar(title: Text(l10n.addWineTitle)),
      body: Stack(
        children: [
          _form(context, l10n, theme, suggestions, pending),
          if (guideOpen) ...[
            // The form under the sheet is covered: the screen reader does
            // not reach it (D10).
            const Positioned.fill(child: BlockSemantics(child: SizedBox())),
            Positioned.fill(
              child: Semantics(
                key: const Key('guide-barrier'),
                label: l10n.guideClose,
                button: true,
                excludeSemantics: true,
                onTap: () => _guide.dispatch(const TapOutsideAction()),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _guide.dispatch(const TapOutsideAction()),
                  child: ColoredBox(
                    color: theme.colorScheme.scrim.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      // D10: the sheet of the guide, above the dimmed form.
      bottomSheet: guideOpen
          ? GuidedConfirmSheet(controller: _guide, message: _guideMessage)
          : null,
      bottomNavigationBar: guideOpen
          ? _coveredSaveBar(l10n, theme)
          : _saveBar(l10n, theme),
    );
  }

  /// "Save" under the open guide (BR7.19): covered by the barrier, so it is
  /// neither tapped nor reached by the screen reader; a tap there is a tap
  /// outside the sheet.
  ///
  /// The bar is excluded from the semantics tree rather than blocked with
  /// `BlockSemantics`: the bar paints after the sheet, so a blocking node
  /// here would hide the sheet itself from the screen reader.
  Widget _coveredSaveBar(AppLocalizations l10n, ThemeData theme) =>
      ExcludeSemantics(
        child: Stack(
          children: [
            _saveBar(l10n, theme),
            Positioned.fill(
              child: GestureDetector(
                key: const Key('guide-save-barrier'),
                behavior: HitTestBehavior.opaque,
                onTap: () => _guide.dispatch(const TapOutsideAction()),
                child: ColoredBox(
                  color: theme.colorScheme.scrim.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _form(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    List<WineCandidate> suggestions,
    List<KeyField> pending,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.initialValues?.notice case final notice?) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  notice,
                  key: const Key('add-wine-notice'),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_toolbar) ...[
              AutofillToolbar(
                onClear: _clear,
                onSearchOnline: widget.onSearchOnline == null
                    ? null
                    : () => widget.onSearchOnline!(context, _searchQuery),
                onLens: widget.onLens,
                onGuide: pending.isEmpty ? null : () => _openGuide(_guideFocus),
                guideFocus: _guideFocus,
              ),
              const SizedBox(height: 12),
            ],
            if (_sureMatch case final candidate?) ...[
              _SureMatchCard(
                candidate: candidate,
                onUse: () => _useSureMatch(candidate),
                onDismiss: () => setState(() => _sureMatch = null),
              ),
              const SizedBox(height: 12),
            ],
            if (_hasEmptyField) ...[
              PasteFromLensCard(
                onPaste: _paste,
                onOpenLens: _openLens,
                busy: _reading,
                pasteFocus: _pasteFocus,
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              key: const Key('add-wine-name-field'),
              controller: _name,
              focusNode: _nameFocus,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onChanged: (text) {
                setState(() => _edited(LabelFieldKeys.name));
                _onNameChanged(text);
              },
              decoration: InputDecoration(
                labelText: l10n.wineNameLabel,
                errorText: _nameErrorText(l10n),
                errorMaxLines: 3,
              ),
            ),
            FilledFromTextBadge(
              key: const Key('filled-name'),
              visible: _filled.contains(LabelFieldKeys.name),
            ),
            if (suggestions.isNotEmpty)
              _SuggestionList(suggestions: suggestions, onPick: _pick),
            const SizedBox(height: 16),
            TextField(
              key: const Key('add-wine-producer'),
              controller: _producer,
              focusNode: _producerFocus,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onChanged: (_) =>
                  setState(() => _edited(LabelFieldKeys.producer)),
              decoration: InputDecoration(
                labelText: l10n.producerLabel,
                errorText: _producerError == null ? null : l10n.producerTooLong,
                errorMaxLines: 3,
              ),
            ),
            FilledFromTextBadge(
              key: const Key('filled-producer'),
              visible: _filled.contains(LabelFieldKeys.producer),
            ),
            if (_producerFocus.hasFocus)
              _ProducerList(
                options: producerOptions(
                  _producer.text,
                  catalogProducers: [
                    for (final candidate in suggestions) candidate.producer,
                  ],
                  cellarProducers: [
                    for (final wine in widget.cellarWines) wine.producer,
                  ],
                ),
                onPick: _pickProducer,
              ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('add-wine-denomination'),
              controller: _denomination,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onChanged: (_) =>
                  setState(() => _edited(LabelFieldKeys.denomination)),
              decoration: InputDecoration(
                labelText: l10n.denominationLabel,
                errorText: _denominationError == null
                    ? null
                    : l10n.denominationTooLong,
                errorMaxLines: 3,
              ),
            ),
            FilledFromTextBadge(
              key: const Key('filled-denomination'),
              visible: _filled.contains(LabelFieldKeys.denomination),
            ),
            const SizedBox(height: 16),
            CountryPicker(
              selected: _origin.country,
              enabled: !_saving,
              onChanged: (code) => setState(() {
                _origin = _origin.withCountry(code);
                _edited(LabelFieldKeys.country);
                _filled.remove(LabelFieldKeys.region);
              }),
            ),
            FilledFromTextBadge(
              key: const Key('filled-country'),
              visible: _filled.contains(LabelFieldKeys.country),
            ),
            const SizedBox(height: 12),
            RegionPicker(
              country: _origin.country,
              selected: _origin.region,
              enabled: !_saving,
              onChanged: (region) => setState(() {
                _origin = _origin.withRegion(region);
                _edited(LabelFieldKeys.region);
              }),
            ),
            FilledFromTextBadge(
              key: const Key('filled-region'),
              visible: _filled.contains(LabelFieldKeys.region),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('add-wine-vintage-field'),
              controller: _vintage,
              focusNode: _vintageFocus,
              enabled: !_noVintage,
              onChanged: (_) => setState(() => _edited(LabelFieldKeys.vintage)),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                labelText: l10n.vintageLabel,
                errorText: _vintageError == null
                    ? null
                    : l10n.vintageRange('$_currentYear'),
                errorMaxLines: 3,
              ),
            ),
            FilledFromTextBadge(
              key: const Key('filled-vintage'),
              visible: _filled.contains(LabelFieldKeys.vintage),
            ),
            SwitchListTile(
              key: const Key('add-wine-no-vintage-switch'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.noVintage),
              value: _noVintage,
              onChanged: (value) => setState(() {
                _noVintage = value;
                _edited(LabelFieldKeys.vintage);
                if (value) _vintageError = null;
              }),
            ),
            WineTypeField(
              // A new key when the type changes: the field shows its
              // initial value only.
              key: ValueKey('add-wine-type-${_class.type?.name}'),
              value: _class.type?.name,
              onChanged: (value) => setState(() {
                _wineType = value;
                _class.chooseType(WineType.tryParse(value));
                _edited(LabelFieldKeys.wineType);
              }),
            ),
            FilledFromTextBadge(
              key: const Key('filled-wineType'),
              visible: _filled.contains(LabelFieldKeys.wineType),
            ),
            SuggestedMark(
              key: const Key('type-suggested'),
              visible:
                  _class.typeSource == FieldSource.auto &&
                  !_filled.contains(LabelFieldKeys.wineType),
            ),
            RestoreSuggestionLink(
              key: const Key('type-restore'),
              visible: _class.canRestoreType,
              onRestore: () => setState(_class.restoreType),
            ),
            ..._styleParts(),
            const SizedBox(height: 16),
            LevelSection(
              choice: _level,
              suggestion: _suggestion,
              facts: _facts,
              onChanged: (level) => setState(() => _level.choose(level)),
              onRestore: () => setState(_level.restore),
            ),
            const SizedBox(height: 8),
            Text(l10n.quantityLabel, style: theme.textTheme.titleSmall),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: QuantityStepper(
                value: _quantity,
                onChanged: (value) => setState(() => _quantity = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// wine-style-profiles (BR5.1, BR8.1): the Style chips and the date.
  List<Widget> _styleParts() {
    final type = _class.type;
    return [
      if (type != null && _class.styleVisible) ...[
        StyleField(
          wineType: type,
          selected: _class.style,
          suggested: _class.styleSource == FieldSource.auto,
          onChanged: (style) => setState(() {
            _class.chooseStyle(style);
            _manual = true;
          }),
        ),
        RestoreSuggestionLink(
          key: const Key('style-restore'),
          visible: _class.canRestoreStyle,
          onRestore: () => setState(_class.restoreStyle),
        ),
      ],
      if (_class.agingStartAnchor case final anchor?)
        AgingStartField(
          anchor: anchor,
          month: _class.agingMonth,
          yearController: _agingYear,
          error: _agingError,
          onMonthChanged: (month) => setState(() {
            _class.agingMonth = month;
            _agingError = null;
          }),
          onYearChanged: (text) => setState(() {
            _class.agingYear = int.tryParse(text);
            _agingError = null;
          }),
        ),
    ];
  }

  /// ux-redesign mockups 2 and 3: "Save" stays at the bottom, outside the
  /// scrolling form, with the save error right above it.
  Widget _saveBar(AppLocalizations l10n, ThemeData theme) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_saveFailed) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.saveFailed,
                key: const Key('add-wine-save-failed'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          FilledButton(
            key: const Key('add-wine-save-button'),
            onPressed: _saving ? null : _save,
            child: Text(l10n.save),
          ),
        ],
      ),
    ),
  );
}

/// The type of a wine (BR1.13, FR2.4): the 8 C2 types, which change the
/// estimate, or "not specified"; since ux-redesign each with the colored
/// icon of its graphic family (review Major 1).
class WineTypeField extends StatelessWidget {
  const WineTypeField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String?>(
      key: const Key('add-wine-type'),
      initialValue: WineType.tryParse(value)?.name,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.wineTypeLabel),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(l10n.filterTypeUnspecified),
        ),
        for (final type in WineType.values)
          DropdownMenuItem<String?>(
            value: type.name,
            child: Row(
              children: [
                Icon(
                  wineFamilyIcon(WineTypeFamily.ofType(type)),
                  size: 18,
                  color: wineFamilyColor(
                    WineTypeColors.of(context),
                    WineTypeFamily.ofType(type),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(wineTypeLabel(l10n, type))),
              ],
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.suggestions, required this.onPick});

  final List<WineCandidate> suggestions;
  final ValueChanged<WineCandidate> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showAttribution = suggestions.any(
      (s) => s.source == CandidateSource.openFoodFacts,
    );
    return Semantics(
      label: l10n.suggestionsLabel,
      container: true,
      child: Card(
        key: const Key('add-wine-suggestions'),
        child: Column(
          children: [
            for (final (index, candidate) in suggestions.indexed)
              ListTile(
                key: Key('add-wine-suggestion-$index'),
                title: Text(candidate.name),
                subtitle: Text(
                  [
                    ?candidate.producer,
                    ?candidate.vintage?.toString(),
                    ?candidate.denomination,
                    if (candidate.source == CandidateSource.cellar)
                      l10n.suggestionFromCellar,
                  ].join(' · '),
                ),
                onTap: () => onPick(candidate),
              ),
            if (showAttribution)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  l10n.offAttribution,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A wine certain in the catalog for a pasted or shared text (FR2.5): shown
/// above the form; "Use" fills it, "Ignore" keeps the form as it is.
class _SureMatchCard extends StatelessWidget {
  const _SureMatchCard({
    required this.candidate,
    required this.onUse,
    required this.onDismiss,
  });

  final WineCandidate candidate;
  final VoidCallback onUse;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final details = [
      ?candidate.producer,
      ?candidate.vintage?.toString(),
      ?candidate.denomination,
    ].join(' · ');
    return Semantics(
      liveRegion: true,
      container: true,
      child: Card(
        key: const Key('autofill-sure-match'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.labelRecognized, style: theme.textTheme.labelLarge),
              Text(candidate.name, style: theme.textTheme.titleMedium),
              if (details.isNotEmpty)
                Text(details, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton(
                    key: const Key('autofill-sure-use'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: onUse,
                    child: Text(l10n.autofillShareUse),
                  ),
                  TextButton(
                    key: const Key('autofill-sure-ignore'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: onDismiss,
                    child: Text(l10n.autofillShareIgnore),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProducerList extends StatelessWidget {
  const _ProducerList({required this.options, required this.onPick});

  final List<ProducerOption> options;
  final ValueChanged<ProducerOption> onPick;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Card(
      key: const Key('add-wine-producers'),
      child: Column(
        children: [
          for (final (index, option) in options.indexed)
            ListTile(
              key: option.isNew
                  ? const Key('add-wine-new-producer')
                  : Key('add-wine-producer-option-$index'),
              leading: option.isNew ? const Icon(Icons.add) : null,
              title: Text(
                option.isNew ? l10n.producerAddNew(option.name) : option.name,
              ),
              onTap: () => onPick(option),
            ),
        ],
      ),
    );
  }
}
