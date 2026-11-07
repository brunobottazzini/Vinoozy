import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../catalog/core/wine_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/domain/membership.dart';
import '../cellar_actions.dart';
import '../cellar_providers.dart';
import '../data/wine_repository.dart';
import '../domain/producer_options.dart';
import '../domain/quantity.dart';
import '../domain/wine.dart';
import '../domain/wine_draft.dart';
import '../domain/wine_validator.dart';
import 'cellar_dialogs.dart';
import 'quantity_stepper.dart';
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
    this.notice,
  });

  /// A catalog proposal with the chosen quantity ("Correggi"): its type is
  /// converted with [wineFamilyOf]; no vintage means "no vintage", as the
  /// proposal showed it.
  factory AddWineInitialValues.fromCandidate(
    WineCandidate candidate, {
    int quantity = QuantityLimits.initial,
    String? notice,
  }) => AddWineInitialValues(
    name: candidate.name,
    producer: candidate.producer,
    vintage: candidate.vintage,
    noVintage: candidate.vintage == null,
    quantity: quantity,
    wineType: wineFamilyOf(candidate.wineType),
    region: candidate.region,
    denomination: candidate.denomination,
    notice: notice,
  );

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
  final String? notice;
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

  @override
  ConsumerState<AddWineScreen> createState() => _AddWineScreenState();
}

class _AddWineScreenState extends ConsumerState<AddWineScreen> {
  late final String _wineId;
  late final TextEditingController _name;
  late final TextEditingController _producer;
  final TextEditingController _vintage = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _producerFocus = FocusNode();
  final FocusNode _vintageFocus = FocusNode();
  bool _noVintage = false;
  int _quantity = QuantityLimits.initial;
  String? _wineType;
  String? _region;
  String? _denomination;
  NameError? _nameError;
  ProducerError? _producerError;
  VintageError? _vintageError;
  bool _saving = false;
  bool _saveFailed = false;

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
      _region = prefill.region;
      _denomination = prefill.denomination;
    } else if (initial != null) {
      _vintage.text = initial.vintage?.toString() ?? '';
      _noVintage = initial.vintage == null && initial.noVintage;
      _quantity = initial.quantity.clamp(
        QuantityLimits.min,
        QuantityLimits.max,
      );
      _wineType = WineType.tryParse(initial.wineType)?.name;
      _region = initial.region;
      _denomination = initial.denomination;
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
    _name.dispose();
    _producer.dispose();
    _vintage.dispose();
    _nameFocus.dispose();
    _producerFocus.dispose();
    _vintageFocus.dispose();
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
      _wineType = wineFamilyOf(candidate.wineType) ?? _wineType;
      _region = candidate.region ?? _region;
      _denomination = candidate.denomination ?? _denomination;
      _nameError = null;
    });
    _nameFocus.unfocus();
  }

  void _pickProducer(ProducerOption option) {
    setState(() => _producer.text = option.name);
    _producerFocus.unfocus();
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
        wineType: _wineType,
        region: _region,
        denomination: _denomination,
      ),
      currentYear: _currentYear,
    );
    final draft = validation.draft;
    setState(() {
      _nameError = validation.nameError;
      _producerError = validation.producerError;
      _vintageError = validation.vintageError;
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
        Navigator.of(context).pop();
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
      Navigator.of(context).pop();
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final suggestions = ref.watch(wineSuggestionsProvider).suggestions;
    return Scaffold(
      key: const Key('add-wine-screen'),
      appBar: AppBar(title: Text(l10n.addWineTitle)),
      body: SafeArea(
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
              TextField(
                key: const Key('add-wine-name-field'),
                controller: _name,
                focusNode: _nameFocus,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: _onNameChanged,
                decoration: InputDecoration(
                  labelText: l10n.wineNameLabel,
                  errorText: _nameErrorText(l10n),
                  errorMaxLines: 3,
                ),
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
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.producerLabel,
                  errorText: _producerError == null
                      ? null
                      : l10n.producerTooLong,
                  errorMaxLines: 3,
                ),
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
                key: const Key('add-wine-vintage-field'),
                controller: _vintage,
                focusNode: _vintageFocus,
                enabled: !_noVintage,
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
              SwitchListTile(
                key: const Key('add-wine-no-vintage-switch'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.noVintage),
                value: _noVintage,
                onChanged: (value) => setState(() {
                  _noVintage = value;
                  if (value) _vintageError = null;
                }),
              ),
              WineTypeField(
                value: _wineType,
                onChanged: (value) => setState(() => _wineType = value),
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
              if (_saveFailed) ...[
                const SizedBox(height: 8),
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
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('add-wine-save-button'),
                onPressed: _saving ? null : _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The type of a wine (BR1.13, FR2.4): the C2 types or "not specified".
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
            child: Text(wineTypeLabel(l10n, type)),
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
