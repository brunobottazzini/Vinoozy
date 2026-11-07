import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/domain/membership.dart';
import '../cellar_providers.dart';
import '../data/wine_repository.dart';
import '../domain/drinking_record.dart';
import '../domain/wine.dart';
import 'wine_labels.dart';

/// Rating, notes, date and "How was it?" of a drink (BR1.11, BR1.12): from
/// the message after "Drunk" or later from the History. Only the author of
/// the drink or the owner may change it (the caller shows it only to them).
class DrinkingRecordSheet extends ConsumerStatefulWidget {
  const DrinkingRecordSheet({
    super.key,
    required this.user,
    required this.cellar,
    required this.record,
    this.wine,
  });

  final AppUser user;
  final AccessibleCellar cellar;
  final DrinkingRecord record;

  /// The wine of the drink, for the window feedback; `null` when unknown.
  final Wine? wine;

  /// Opens the sheet; resolves true when the drink was saved.
  static Future<bool> show(
    BuildContext context, {
    required AppUser user,
    required AccessibleCellar cellar,
    required DrinkingRecord record,
    Wine? wine,
  }) async =>
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => DrinkingRecordSheet(
          user: user,
          cellar: cellar,
          record: record,
          wine: wine,
        ),
      ) ??
      false;

  /// Whether [user] may change [record] (BR1.11, NFR4.3).
  static bool canChange(
    AccessibleCellar cellar,
    AppUser user,
    DrinkingRecord record,
  ) => cellar.canEdit && (cellar.isOwner || record.recordedBy == user.uid);

  @override
  ConsumerState<DrinkingRecordSheet> createState() =>
      _DrinkingRecordSheetState();
}

class _DrinkingRecordSheetState extends ConsumerState<DrinkingRecordSheet> {
  late int? _rating = widget.record.rating;
  late final TextEditingController _notes = TextEditingController(
    text: widget.record.notes ?? '',
  );
  late DateTime _drankOn = widget.record.drankOn;
  late DrinkCondition? _condition = widget.record.condition;
  Set<RecordFieldError> _errors = const {};
  bool _saving = false;
  bool _failed = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = ref.read(clockProvider).now();
    final vintage = widget.record.vintage;
    final picked = await showDatePicker(
      context: context,
      initialDate: _drankOn.isAfter(today) ? today : _drankOn,
      firstDate: DateTime(vintage ?? 1900),
      lastDate: today,
    );
    if (picked != null && mounted) setState(() => _drankOn = picked);
  }

  Future<void> _save() async {
    final errors = RecordRules.validate(
      rating: _rating,
      notes: _notes.text.trim(),
      drankOn: _drankOn,
      vintage: widget.record.vintage,
      today: ref.read(clockProvider).now(),
    );
    setState(() {
      _errors = errors;
      _failed = false;
    });
    if (errors.isNotEmpty) return;
    setState(() => _saving = true);
    final container = ProviderScope.containerOf(context, listen: false);
    final outcome = await ref
        .read(cellarActionsProvider)
        .updateRecord(
          cellar: widget.cellar,
          user: widget.user,
          record: widget.record,
          wine: widget.wine,
          rating: _rating,
          notes: _notes.text,
          drankOn: _drankOn,
          condition: _condition,
        );
    if (outcome is SaveAccepted) {
      // The History and the last drinks of the detail show the change (R-01,
      // R-02).
      invalidateDrinkReads(
        container,
        cellarId: widget.cellar.cellarId,
        wineIds: [widget.record.wineId],
      );
    }
    if (!mounted) return;
    if (outcome is SaveAccepted) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dateError =
        _errors.contains(RecordFieldError.dateInFuture) ||
        _errors.contains(RecordFieldError.dateBeforeVintage);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        key: const Key('record-sheet'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.recordSheetTitle, style: theme.textTheme.titleLarge),
            Text(widget.record.wineName, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(l10n.recordRatingLabel, style: theme.textTheme.titleSmall),
            Wrap(
              children: [
                for (var n = 1; n <= 5; n++)
                  Semantics(
                    button: true,
                    selected: (_rating ?? 0) >= n,
                    label: l10n.ratingStar(n),
                    excludeSemantics: true,
                    child: IconButton(
                      key: Key('record-rating-$n'),
                      tooltip: l10n.ratingStar(n),
                      onPressed: () =>
                          setState(() => _rating = _rating == n ? null : n),
                      icon: Icon(
                        (_rating ?? 0) >= n ? Icons.star : Icons.star_border,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('record-notes'),
              controller: _notes,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                labelText: l10n.recordNotesLabel,
                errorText: _errors.contains(RecordFieldError.notesTooLong)
                    ? l10n.recordNotesTooLong
                    : null,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                key: const Key('record-date'),
                onPressed: _pickDate,
                icon: const Icon(Icons.event),
                label: Text(l10n.recordDateLabel(formatDay(context, _drankOn))),
              ),
            ),
            if (dateError)
              Text(
                l10n.recordDateInvalid,
                key: const Key('record-date-error'),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            const SizedBox(height: 12),
            Text(l10n.recordConditionTitle, style: theme.textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: [
                for (final condition in DrinkCondition.values)
                  ChoiceChip(
                    key: Key('record-condition-${condition.name}'),
                    label: Text(conditionLabel(l10n, condition)),
                    selected: _condition == condition,
                    onSelected: (_) => setState(() => _condition = condition),
                  ),
                ChoiceChip(
                  key: const Key('record-condition-none'),
                  label: Text(l10n.recordNoCondition),
                  selected: _condition == null,
                  onSelected: (_) => setState(() => _condition = null),
                ),
              ],
            ),
            if (_failed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.saveFailed,
                  key: const Key('record-save-failed'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('record-save'),
              onPressed: _saving ? null : _save,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
