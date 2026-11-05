import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../data/wine_repository.dart';
import '../domain/quantity.dart';
import '../domain/wine_draft.dart';
import 'quantity_stepper.dart';

/// M4b simplified — write a wine (US2.1; BR2.1-BR2.5).
///
/// The wine id is generated once when the form opens (BR2.4). Name and
/// vintage are checked when the field loses focus and on Save; on the first
/// valid tap Save is disabled until the form closes, so a double tap cannot
/// create two wines. A local failure keeps the data, re-enables Save and
/// shows "Could not save, try again" (NFR6.4).
class AddWineScreen extends ConsumerStatefulWidget {
  const AddWineScreen({
    super.key,
    required this.user,
    required this.cellarId,
    this.initialName,
  });

  final AppUser user;
  final String cellarId;

  /// "Add again" after a rejected wine reopens the form with the name only.
  final String? initialName;

  @override
  ConsumerState<AddWineScreen> createState() => _AddWineScreenState();
}

class _AddWineScreenState extends ConsumerState<AddWineScreen> {
  late final String _wineId;
  late final TextEditingController _name;
  final TextEditingController _vintage = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _vintageFocus = FocusNode();
  bool _noVintage = false;
  int _quantity = QuantityLimits.initial;
  NameError? _nameError;
  VintageError? _vintageError;
  bool _saving = false;
  bool _saveFailed = false;

  int get _currentYear => ref.read(clockProvider).now().year;

  @override
  void initState() {
    super.initState();
    _wineId = ref.read(idGeneratorProvider).newId();
    _name = TextEditingController(text: widget.initialName ?? '');
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) {
        setState(() => _nameError = WineRules.validateName(_name.text));
      }
    });
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
    _vintage.dispose();
    _nameFocus.dispose();
    _vintageFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final validation = WineDraft.validate(
      id: _wineId,
      rawName: _name.text,
      rawVintage: _vintage.text,
      noVintage: _noVintage,
      quantity: _quantity,
      currentYear: _currentYear,
    );
    final draft = validation.draft;
    if (draft == null) {
      setState(() {
        _nameError = validation.nameError;
        _vintageError = validation.vintageError;
      });
      return;
    }
    setState(() {
      _nameError = null;
      _vintageError = null;
      _saving = true;
      _saveFailed = false;
    });
    final outcome = await ref
        .read(wineRepositoryProvider)
        .create(cellarId: widget.cellarId, user: widget.user, draft: draft);
    if (!mounted) return;
    switch (outcome) {
      case SaveAccepted():
        Navigator.of(context).pop();
      case SaveFailure():
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
    return Scaffold(
      key: const Key('add-wine-screen'),
      appBar: AppBar(title: Text(l10n.addWineTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('add-wine-name-field'),
                controller: _name,
                focusNode: _nameFocus,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.wineNameLabel,
                  errorText: _nameErrorText(l10n),
                  errorMaxLines: 3,
                ),
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
