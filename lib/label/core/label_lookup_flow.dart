import '../../catalog/core/wine_catalog.dart';
import 'barcode_filter.dart';
import 'label_line_picker.dart';
import 'label_reading.dart';
import 'vintage_parser.dart';

/// Where a reading ends after the lookup (BR1.8, BR1.11).
sealed class LookupOutcome {
  const LookupOutcome();
}

/// A wine was found: the proposal with quantity, "Correggi", "Conferma"
/// (BR1.9). [offline] adds "only the denomination without network".
class LookupProposal extends LookupOutcome {
  const LookupProposal(this.candidate, {required this.offline});

  final WineCandidate candidate;
  final bool offline;
}

/// Text read, no wine found: the U4 form with the most significant line as
/// name and the vintage read, if any (BR1.11, BR1.12).
class LookupIncomplete extends LookupOutcome {
  const LookupIncomplete({required this.name, this.vintage});

  final String name;
  final int? vintage;
}

/// A valid barcode but no wine for it (or no network), and the text has
/// fewer than 3 letters ("Chiarimenti dopo la revisione"). [barcode] stays in
/// memory only while the screen is open, never saved.
class LookupBarcodeOnly extends LookupOutcome {
  const LookupBarcodeOnly(this.barcode, {required this.needsNetwork});

  final String barcode;
  final bool needsNetwork;
}

/// Nothing readable: no valid barcode and fewer than 3 letters (BR1.11).
class LookupUnreadable extends LookupOutcome {
  const LookupUnreadable();
}

/// Called with a catalog failure other than [CatalogArgumentError]; the
/// caller reports it as `label_lookup_failed` (BR1.14).
typedef LookupFailureSink = void Function(Object error, StackTrace stack);

/// The lookup order of a reading (BR1.8, Q3 = A):
/// 1. a valid barcode and a network: `lookupBarcode`; a result is the
///    proposal;
/// 2. otherwise, or with no result: `matchLabelText` with the text read and
///    the app language;
/// 3. the vintage read in the text replaces the candidate's;
/// 4. a catalog error never blocks: it counts as "no result" for that step.
///
/// At most two catalog calls per photo, one per step (NFR5.1). Only the
/// normalised barcode and the text read reach the catalog, never the image
/// or its path (NFR4.1).
class LabelLookupFlow {
  LabelLookupFlow({
    required this._catalog,
    required this._currentYear,
    this._onFailure,
    this._barcodes = const BarcodeFilter(),
    this._vintages = const VintageParser(),
    this._lines = const LabelLinePicker(),
  });

  final WineCatalog _catalog;
  final int Function() _currentYear;
  final LookupFailureSink? _onFailure;
  final BarcodeFilter _barcodes;
  final VintageParser _vintages;
  final LabelLinePicker _lines;

  Future<LookupOutcome> run(
    LabelReading reading, {
    required bool online,
    required CatalogLocale locale,
  }) async {
    final code = _barcodes.firstValid(reading.barcodes);
    final text = LabelReading.clampText(reading.text);
    final readable = hasLetters(text);
    if (code == null && !readable) return const LookupUnreadable();
    final vintage = readable
        ? _vintages.parse(text, currentYear: _currentYear())
        : null;
    if (code != null && online) {
      final found = await _lookupBarcode(code);
      if (found != null) {
        return LookupProposal(_withVintage(found, vintage), offline: false);
      }
    }
    if (!readable) return LookupBarcodeOnly(code!, needsNetwork: !online);
    final matched = await _matchText(text, locale);
    if (matched != null) {
      return LookupProposal(_withVintage(matched, vintage), offline: !online);
    }
    return LookupIncomplete(name: _lines.pick(text), vintage: vintage);
  }

  /// "Riprova quando torna la rete": the barcode lookup again, without a new
  /// photo.
  Future<LookupOutcome> retryBarcode(
    String barcode, {
    required bool online,
  }) async {
    if (!online) return LookupBarcodeOnly(barcode, needsNetwork: true);
    final found = await _lookupBarcode(barcode);
    if (found == null) return LookupBarcodeOnly(barcode, needsNetwork: false);
    return LookupProposal(found, offline: false);
  }

  Future<WineCandidate?> _lookupBarcode(String code) =>
      _guard(() => _catalog.lookupBarcode(code));

  Future<WineCandidate?> _matchText(String text, CatalogLocale locale) =>
      _guard(() async {
        final match = await _catalog.matchLabelText(text, locale: locale);
        return match.matched ? match.candidate : null;
      });

  /// A catalog error is "no result" for the step (BR1.8 step 4, NFR6.3);
  /// only errors other than an invalid input are reported.
  Future<WineCandidate?> _guard(Future<WineCandidate?> Function() call) async {
    try {
      return await call();
    } on CatalogArgumentError {
      return null;
    } catch (error, stack) {
      _onFailure?.call(error, stack);
      return null;
    }
  }

  static WineCandidate _withVintage(WineCandidate candidate, int? vintage) =>
      vintage == null ? candidate : candidate.copyWith(vintage: vintage);
}
