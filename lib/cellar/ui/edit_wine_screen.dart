import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/domain/membership.dart';
import '../cellar_actions.dart';
import '../cellar_providers.dart';
import '../domain/wine.dart';
import '../domain/wine_draft.dart';
import '../domain/wine_validator.dart';
import 'add_wine_screen.dart' show WineTypeField;
import 'quantity_stepper.dart';

/// Edit a wine (BR1.13, FR3.3, AC3.3.1): name, producer, vintage, type and
/// quantity. The quantity is saved as a change, never below 0; `matchKey`,
/// estimate and pairings are computed again (the drink feedback is kept).
/// The same name, producer and vintage as another wine is refused.
class EditWineScreen extends ConsumerStatefulWidget {
  const EditWineScreen({
    super.key,
    required this.user,
    required this.cellar,
    required this.wine,
  });

  final AppUser user;
  final AccessibleCellar cellar;
  final Wine wine;

  @override
  ConsumerState<EditWineScreen> createState() => _EditWineScreenState();
}

class _EditWineScreenState extends ConsumerState<EditWineScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.wine.name,
  );
  late final TextEditingController _producer = TextEditingController(
    text: widget.wine.producer ?? '',
  );
  late final TextEditingController _vintage = TextEditingController(
    text: widget.wine.vintage?.toString() ?? '',
  );
  late bool _noVintage = widget.wine.vintage == null;
  late int _quantity = widget.wine.quantity;
  late String? _wineType = WineType.tryParse(widget.wine.wineType)?.name;
  WineValidation _validation = const WineValidation();
  bool _saving = false;
  EditResult? _result;

  @override
  void dispose() {
    _name.dispose();
    _producer.dispose();
    _vintage.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final validation = WineValidator.validate(
      WineInput(
        id: widget.wine.id,
        name: _name.text,
        producer: _producer.text,
        vintage: _vintage.text,
        noVintage: _noVintage,
        quantity: _quantity,
        wineType: _wineType,
        region: widget.wine.region,
        denomination: widget.wine.denomination,
      ),
      currentYear: ref.read(clockProvider).now().year,
      minQuantity: 0,
    );
    setState(() {
      _validation = validation;
      _result = null;
    });
    final draft = validation.draft;
    if (draft == null) return;
    setState(() => _saving = true);
    final result = await ref
        .read(cellarActionsProvider)
        .saveEdit(
          cellar: widget.cellar,
          user: widget.user,
          before: widget.wine,
          draft: draft,
          targetQuantity: _quantity,
        );
    if (!mounted) return;
    if (result == EditResult.saved) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _saving = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final year = ref.read(clockProvider).now().year;
    final error = switch (_result) {
      EditResult.duplicate => l10n.editDuplicate,
      EditResult.failed => l10n.saveFailed,
      _ => null,
    };
    return Scaffold(
      key: const Key('edit-wine-screen'),
      appBar: AppBar(title: Text(l10n.editWineTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('edit-wine-name'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.wineNameLabel,
                  errorText: switch (_validation.nameError) {
                    NameError.empty => l10n.nameRequired,
                    NameError.tooLong => l10n.nameTooLong,
                    null => null,
                  },
                  errorMaxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('edit-wine-producer'),
                controller: _producer,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.producerLabel,
                  errorText: _validation.producerError == null
                      ? null
                      : l10n.producerTooLong,
                  errorMaxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('edit-wine-vintage'),
                controller: _vintage,
                enabled: !_noVintage,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  labelText: l10n.vintageLabel,
                  errorText: _validation.vintageError == null
                      ? null
                      : l10n.vintageRange('$year'),
                  errorMaxLines: 3,
                ),
              ),
              SwitchListTile(
                key: const Key('edit-wine-no-vintage'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.noVintage),
                value: _noVintage,
                onChanged: (value) => setState(() => _noVintage = value),
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
                  min: 0,
                  onChanged: (value) => setState(() => _quantity = value),
                ),
              ),
              if (error != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    error,
                    key: const Key('edit-wine-error'),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('edit-wine-save'),
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
