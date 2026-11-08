// A text pasted from Lens, shared by Lens or pasted by itself on the way
// back (label-autofill-windows F2-F4, BR2.2, BR2.3, NFR3.2, NFR3.4). Pure
// Dart: the form applies the result.

import 'dart:async';

import 'package:estimation/estimation.dart';

import '../../catalog/core/wine_catalog.dart';
import 'label_lookup_flow.dart' show LookupFailureSink;

/// What a text gives (BR2.2).
sealed class TextAutofill {
  const TextAutofill();
}

/// One wine is certain in the catalog: the form proposes it (FR2.5).
class TextSureMatch extends TextAutofill {
  const TextSureMatch(this.candidate);

  final WineCandidate candidate;
}

/// No certain wine: the fields read in the text (BR1), maybe none, and the
/// analysis of the guided check (label-autofill-windows D9, BR7.8).
///
/// [fields] stays the reader of BR1 (`extractLabelFields`), as the flow
/// tests of today read it; the form fills only [filled], the certain fields
/// of [analysis], and asks the uncertain ones (FR7.1).
class TextFields extends TextAutofill {
  const TextFields(this.fields, {this.analysis = LabelAnalysis.empty});

  final LabelFields fields;

  /// Candidates, certainty and words; [LabelAnalysis.empty] when the text
  /// is blank or the reader failed. Kept in memory only (FR7.9).
  final LabelAnalysis analysis;

  /// What the form fills without the guide (BR7.8): the certain fields of
  /// [analysis], or [fields] when there is no analysis.
  LabelFields get filled => identical(analysis, LabelAnalysis.empty)
      ? fields
      : analysis.certainFields;
}

/// Called when reading the text fails inside (never with the text): the
/// caller reports `appellations_index_failed` (NFR4.16).
typedef ExtractFailureSink = void Function(Object error, StackTrace stack);

/// The steps of BR2.2: the catalog lookup of today (offline database,
/// internal catalog, Open Food Facts only with a network), then the label
/// fields of BR1.
///
/// The text is cut to 4000 characters and cleaned first; it lives only in
/// this call and is never logged nor stored (BR2.3). A catalog error or a
/// failure of the reader counts as "nothing found".
///
/// The catalog lookup is bounded by [lookupBudget]: the first lookup opens
/// the offline database (about 2 s on a phone) and the Open Food Facts
/// search may wait up to its own 5 s deadline on a slow network. Past the
/// budget the person gets the fields of the text at once, so a paste always
/// shows a result; the lookup goes on in the background and warms the
/// database and the cache for the next text.
class TextAutofillFlow {
  TextAutofillFlow({
    required this._catalog,
    required this._currentYear,
    this._onLookupFailure,
    this._onExtractFailure,
    this.lookupBudget = defaultLookupBudget,
  });

  /// Longest wait for the catalog before the text fields are used.
  static const Duration defaultLookupBudget = Duration(milliseconds: 1500);

  final WineCatalog _catalog;
  final int Function() _currentYear;
  final LookupFailureSink? _onLookupFailure;
  final ExtractFailureSink? _onExtractFailure;

  /// See [defaultLookupBudget].
  final Duration lookupBudget;

  Future<TextAutofill> run(String raw, {required CatalogLocale locale}) async {
    final text = sanitizeLabelText(raw);
    if (text.trim().isEmpty) return const TextFields(LabelFields.empty);
    final match = await _match(text, locale);
    final candidate = match.candidate;
    if (match.kind == LabelMatchKind.sure && candidate != null) {
      return TextSureMatch(candidate);
    }
    final (fields, failed) = _read(text);
    // A failure of the reader is reported once, by [_read].
    final analysis = failed ? LabelAnalysis.empty : analyze(text);
    return TextFields(fields, analysis: analysis);
  }

  /// The fields of [text] (BR1); empty when the reader fails.
  LabelFields extract(String text) => _read(text).$1;

  (LabelFields, bool) _read(String text) {
    try {
      return (extractLabelFields(text, currentYear: _currentYear()), false);
    } catch (error, stack) {
      _onExtractFailure?.call(error, stack);
      return (LabelFields.empty, true);
    }
  }

  /// The analysis of [text] for the guided check (BR7.1-BR7.8, D9);
  /// [LabelAnalysis.empty] when the reader fails, reported as [extract]
  /// does, never with the text.
  LabelAnalysis analyze(String text) {
    try {
      return analyzeLabelText(text, currentYear: _currentYear());
    } catch (error, stack) {
      _onExtractFailure?.call(error, stack);
      return LabelAnalysis.empty;
    }
  }

  /// The catalog answer within [lookupBudget]; `none` past it. A timeout
  /// is the expected answer of a slow network, not a failure: it is not
  /// reported.
  Future<LabelMatchResult> _match(String text, CatalogLocale locale) => _lookup(
    text,
    locale,
  ).timeout(lookupBudget, onTimeout: () => const LabelMatchResult.none());

  /// Never throws: every failure is reported and counts as "nothing".
  Future<LabelMatchResult> _lookup(String text, CatalogLocale locale) async {
    try {
      return await _catalog.matchLabel(text, locale: locale);
    } on CatalogArgumentError {
      return const LabelMatchResult.none();
    } catch (error, stack) {
      _onLookupFailure?.call(error, stack);
      return const LabelMatchResult.none();
    }
  }
}
