import '../../catalog/core/catalog_coordinator.dart' show labelSearchWords;
import '../../catalog/core/wine_catalog.dart';
import 'label_line_picker.dart';
import 'label_merge.dart';
import 'label_reading.dart';
import 'vintage_parser.dart';

import 'package:estimation/estimation.dart'
    show
        LabelAnalysis,
        LabelFields,
        analyzeLabelText,
        extractLabelFields,
        normalizeWineText;

/// The three "not found" outcomes (label-recognition BR3.4).
enum NotFoundKind {
  /// No text and no barcode.
  unreadable,

  /// A barcode read, no wine for it.
  barcodeNotFound,

  /// Text read, no candidate.
  noMatch,
}

/// Where a reading ends after the lookup (label-recognition BR3.1-BR3.5).
sealed class LookupOutcome {
  const LookupOutcome();
}

/// "Non trovato" with what "Scrivi a mano" and "Cerca online" start from
/// (BR3.4, BR4.1): [name] is the most significant line (BR1.12), [query]
/// the most significant words with the vintage, or the barcode.
class LookupNotFound extends LookupOutcome {
  const LookupNotFound(
    this.kind, {
    this.name = '',
    this.vintage,
    this.query = '',
    this.fields = LabelFields.empty,
    this.analysis = LabelAnalysis.empty,
  });

  final NotFoundKind kind;
  final String name;
  final int? vintage;
  final String query;

  /// The fields read in the text by the reader of BR1 (label-autofill-windows
  /// BR2.1, F1).
  final LabelFields fields;

  /// The analysis of the guided check (D9, F1): the form fills its certain
  /// fields and asks the uncertain ones. Kept in memory only (FR7.9).
  final LabelAnalysis analysis;

  /// Whether the form opens filled instead of "Not found" (BR2.1, BR7.10):
  /// at least one certain field or one question. Without an analysis (a
  /// reader failure), the fields of BR1 decide as before.
  bool get opensForm {
    if (identical(analysis, LabelAnalysis.empty)) return !fields.isEmpty;
    return !analysis.certainFields.isEmpty ||
        (analysis.hasClues && analysis.uncertainFields.isNotEmpty);
  }
}

/// One wine is certain (BR3.2): the proposal with quantity, "Correggi",
/// "Conferma" and "Non è questo" (BR3.5), which leads to [alternatives] or,
/// without any, to [notFound].
class LookupSure extends LookupOutcome {
  const LookupSure(
    this.candidate, {
    required this.step,
    required this.notFound,
    this.alternatives = const [],
  });

  final WineCandidate candidate;
  final LabelMatchStep step;
  final List<WineCandidate> alternatives;
  final LookupNotFound notFound;
}

/// Similar wines to choose from (BR3.2), best first; "Nessuno di questi"
/// leads to [notFound].
class LookupCandidates extends LookupOutcome {
  const LookupCandidates(
    this.candidates, {
    required this.step,
    required this.notFound,
  });

  final List<WineCandidate> candidates;
  final LabelMatchStep step;
  final LookupNotFound notFound;
}

/// Called with a catalog failure other than [CatalogArgumentError]; the
/// caller reports it as `label_lookup_failed` (BR1.14).
typedef LookupFailureSink = void Function(Object error, StackTrace stack);

/// The lookup of a merged reading (label-recognition FR2.4): one call to
/// `matchLabel` with the merged text and barcode, which follows the order
/// of BR3.1; then:
/// - the vintage read in the text replaces the sure candidate's, and fills
///   the candidates that have none (BR1.11);
/// - a catalog error never blocks: it counts as "nothing found".
///
/// Only the normalised barcode and the text read reach the catalog, never
/// the images or their paths (NFR4.1).
class LabelLookupFlow {
  LabelLookupFlow({
    required this._catalog,
    required this._currentYear,
    this._onFailure,
    this._onExtractFailure,
    this._vintages = const VintageParser(),
    this._lines = const LabelLinePicker(),
  });

  /// Called when the label-text reader fails (label-autofill-windows
  /// NFR4.16); the caller reports `appellations_index_failed`.
  final LookupFailureSink? _onExtractFailure;

  /// Longest "Cerca online" query (BR4.1, the field limit).
  static const int maxQueryLength = 120;

  final WineCatalog _catalog;
  final int Function() _currentYear;
  final LookupFailureSink? _onFailure;
  final VintageParser _vintages;
  final LabelLinePicker _lines;

  Future<LookupOutcome> run(
    MergedReading reading, {
    required CatalogLocale locale,
  }) async {
    if (reading.isUnreadable) {
      return const LookupNotFound(NotFoundKind.unreadable);
    }
    final text = reading.text;
    final readable = hasLetters(text);
    final vintage = readable
        ? _vintages.parse(text, currentYear: _currentYear())
        : null;
    final (fields, analysis) = readable
        ? _fieldsOf(text)
        : (LabelFields.empty, LabelAnalysis.empty);
    final notFound = LookupNotFound(
      readable ? NotFoundKind.noMatch : NotFoundKind.barcodeNotFound,
      name: readable ? _lines.pick(text) : '',
      vintage: vintage,
      query: searchQueryOf(text, vintage: vintage, barcode: reading.barcode),
      fields: fields,
      analysis: analysis,
    );
    final result = await _match(text, reading.barcode, locale);
    switch (result.kind) {
      case LabelMatchKind.sure:
        return LookupSure(
          _withVintage(result.candidate!, vintage),
          step: result.step,
          alternatives: [
            for (final c in result.candidates) _fillVintage(c, vintage),
          ],
          notFound: notFound,
        );
      case LabelMatchKind.candidates:
        return LookupCandidates(
          [for (final c in result.candidates) _fillVintage(c, vintage)],
          step: result.step,
          notFound: notFound,
        );
      case LabelMatchKind.none:
        return notFound;
    }
  }

  /// The label fields of [text] (label-autofill-windows BR1) and its
  /// analysis for the guided check (D9); both empty when the reader fails,
  /// which is reported once, without the text.
  (LabelFields, LabelAnalysis) _fieldsOf(String text) {
    try {
      final year = _currentYear();
      return (
        extractLabelFields(text, currentYear: year),
        analyzeLabelText(text, currentYear: year),
      );
    } catch (error, stack) {
      _onExtractFailure?.call(error, stack);
      return (LabelFields.empty, LabelAnalysis.empty);
    }
  }

  /// BR4.1: the most significant words of the text (the longest, in text
  /// order) and the vintage; the barcode when there are no words.
  static String searchQueryOf(String text, {int? vintage, String? barcode}) {
    final words = labelSearchWords(normalizeWineText(text).split(' '));
    final query = [...words, ?vintage?.toString()].join(' ');
    if (words.isEmpty) return barcode ?? query;
    return query.length <= maxQueryLength
        ? query
        : query.substring(0, maxQueryLength).trimRight();
  }

  /// A catalog error is "nothing found" (NFR6.3); only errors other than an
  /// invalid input are reported.
  Future<LabelMatchResult> _match(
    String text,
    String? barcode,
    CatalogLocale locale,
  ) async {
    try {
      return await _catalog.matchLabel(text, barcode: barcode, locale: locale);
    } on CatalogArgumentError {
      return const LabelMatchResult.none();
    } catch (error, stack) {
      _onFailure?.call(error, stack);
      return const LabelMatchResult.none();
    }
  }

  static WineCandidate _withVintage(WineCandidate candidate, int? vintage) =>
      vintage == null ? candidate : candidate.copyWith(vintage: vintage);

  static WineCandidate _fillVintage(WineCandidate candidate, int? vintage) =>
      candidate.vintage != null ? candidate : _withVintage(candidate, vintage);
}
