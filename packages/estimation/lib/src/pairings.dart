// W3, food pairings (BR4.1, BR4.2, NFR4.3).

import 'models.dart';
import 'recognizer.dart';
import 'validation.dart';

/// Most catalog pairings returned (BR4.2).
const int maxCatalogPairings = 5;

/// Pairings for [wine] (C2 `pairingsFor`).
///
/// Catalog pairings in [external] win and are returned as they are, the
/// first [maxCatalogPairings] only; otherwise the category keys of the
/// denomination, type or generic row. Throws [EstimationArgumentError] for
/// the invalid inputs of BR4.5 and nothing else.
Pairings pairingsFor(WineFacts wine, [ExternalProfile? external]) {
  validateWineFacts(wine);
  final catalogPairings = external?.pairings;
  if (catalogPairings != null && catalogPairings.isNotEmpty) {
    return Pairings(
      items: List<String>.unmodifiable(
        catalogPairings.take(maxCatalogPairings),
      ),
      categoryKeys: const [],
      source: WindowSource.catalog,
    );
  }

  final resolved = resolveWine(wine, external);
  return Pairings(
    items: const [],
    categoryKeys: resolved.pairingCategories,
    source: WindowSource.internalRules,
  );
}
