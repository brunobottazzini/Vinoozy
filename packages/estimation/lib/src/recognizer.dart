// Name recognition (BR1.1) and resolution of what an estimate is based on
// (BR1.2, BR1.7). Matching works on whole words of a normalised copy of the
// text, so "castiglione" never contains "asti". The alias index below is the
// only structure built at runtime, once (NFR2.2, security-design.md §3).

import 'models.dart';
import 'tables.dart';

/// Longest text examined, as the 60-character name limit of C3.
const int maxNameLength = 60;

/// Accented Latin-1 letters folded to their lowercase base letter.
const Map<int, int> _accentFolding = {
  0xC0: 0x61, 0xC1: 0x61, 0xC2: 0x61, 0xC3: 0x61, 0xC4: 0x61, 0xC5: 0x61, //
  0xC7: 0x63, //
  0xC8: 0x65, 0xC9: 0x65, 0xCA: 0x65, 0xCB: 0x65, //
  0xCC: 0x69, 0xCD: 0x69, 0xCE: 0x69, 0xCF: 0x69, //
  0xD1: 0x6E, //
  0xD2: 0x6F, 0xD3: 0x6F, 0xD4: 0x6F, 0xD5: 0x6F, 0xD6: 0x6F, 0xD8: 0x6F, //
  0xD9: 0x75, 0xDA: 0x75, 0xDB: 0x75, 0xDC: 0x75, //
  0xDD: 0x79, //
  0xE0: 0x61, 0xE1: 0x61, 0xE2: 0x61, 0xE3: 0x61, 0xE4: 0x61, 0xE5: 0x61, //
  0xE7: 0x63, //
  0xE8: 0x65, 0xE9: 0x65, 0xEA: 0x65, 0xEB: 0x65, //
  0xEC: 0x69, 0xED: 0x69, 0xEE: 0x69, 0xEF: 0x69, //
  0xF1: 0x6E, //
  0xF2: 0x6F, 0xF3: 0x6F, 0xF4: 0x6F, 0xF5: 0x6F, 0xF6: 0x6F, 0xF8: 0x6F, //
  0xF9: 0x75, 0xFA: 0x75, 0xFB: 0x75, 0xFC: 0x75, //
  0xFD: 0x79, 0xFF: 0x79,
};

/// Qualifiers tried from the most specific to the least specific.
const List<Qualifier> _qualifierPriority = [
  Qualifier.granSelezione,
  Qualifier.riserva,
  Qualifier.superiore,
];

/// Splits [text] into normalised words: lowercase, accents removed,
/// apostrophes and punctuation turned into separators, at most
/// [maxNameLength] characters of the trimmed text examined. The original
/// text is never changed.
List<String> tokenize(String text) {
  final trimmed = text.trim();
  final limited = trimmed.length > maxNameLength
      ? trimmed.substring(0, maxNameLength)
      : trimmed;
  return tokenizeAll(limited);
}

/// Splits the whole of [text] into normalised words, as [tokenize] does but
/// with no length limit. Used by the catalog functions of C2, which read
/// label texts and search queries longer than a wine name.
List<String> tokenizeAll(String text) {
  final words = <String>[];
  final current = StringBuffer();
  for (final unit in text.codeUnits) {
    final folded = _foldCodeUnit(unit);
    if (folded != 0) {
      current.writeCharCode(folded);
    } else if (current.isNotEmpty) {
      words.add(current.toString());
      current.clear();
    }
  }
  if (current.isNotEmpty) words.add(current.toString());
  return words;
}

/// The normalised form of [text], words joined by single spaces.
String normalizeName(String text) => tokenize(text).join(' ');

/// Lowercase letter or digit for [unit], or 0 for a separator.
int _foldCodeUnit(int unit) {
  if (unit >= 0x61 && unit <= 0x7A) return unit;
  if (unit >= 0x30 && unit <= 0x39) return unit;
  if (unit >= 0x41 && unit <= 0x5A) return unit + 0x20;
  return _accentFolding[unit] ?? 0;
}

/// One alias of the denomination table, split into words.
class AliasEntry {
  const AliasEntry(this.words, this.denominationKey);

  final List<String> words;
  final String denominationKey;
}

/// Builds the index from first word to aliases starting with it, longest
/// alias first. Called once, by the top-level [aliasIndex] initialiser.
Map<String, List<AliasEntry>> buildAliasIndex() {
  final index = <String, List<AliasEntry>>{};
  denominationTable.forEach((key, profile) {
    for (final alias in profile.aliases) {
      final words = tokenize(alias);
      if (words.isEmpty) continue;
      index
          .putIfAbsent(words.first, () => <AliasEntry>[])
          .add(AliasEntry(List.unmodifiable(words), key));
    }
  });
  return Map.unmodifiable({
    for (final entry in index.entries)
      entry.key: List<AliasEntry>.unmodifiable(
        entry.value..sort((a, b) => b.words.length.compareTo(a.words.length)),
      ),
  });
}

/// Alias index, built once when the library is first used.
final Map<String, List<AliasEntry>> aliasIndex = buildAliasIndex();

/// A denomination alias found in a list of words.
class AliasMatch {
  const AliasMatch(this.denominationKey, this.start, this.wordCount);

  final String denominationKey;
  final int start;
  final int wordCount;
}

/// Finds the alias with the most words in [words]; on a tie, the first one
/// in the text wins (BR1.1). Returns `null` when no alias matches.
AliasMatch? findAlias(List<String> words) {
  AliasMatch? best;
  for (var i = 0; i < words.length; i++) {
    final candidates = aliasIndex[words[i]];
    if (candidates == null) continue;
    for (final candidate in candidates) {
      final length = candidate.words.length;
      if (best != null && length <= best.wordCount) break;
      if (_matchesAt(words, i, candidate.words)) {
        best = AliasMatch(candidate.denominationKey, i, length);
        break;
      }
    }
  }
  return best;
}

bool _matchesAt(List<String> words, int start, List<String> alias) {
  if (start + alias.length > words.length) return false;
  for (var j = 1; j < alias.length; j++) {
    if (words[start + j] != alias[j]) return false;
  }
  return true;
}

/// Internal result of recognising a name (entities.md `RecognizedWine`).
class RecognizedWine {
  const RecognizedWine({
    required this.denominationKey,
    required this.wineType,
    this.qualifier,
  });

  final String denominationKey;
  final WineType wineType;
  final Qualifier? qualifier;
}

/// Recognises the denomination, qualifier and type of [name] alone (BR1.1).
RecognizedWine? recognize(String name) => recognizeWords(tokenize(name));

/// Recognises the denomination, qualifier and type in already normalised
/// [words]; `null` when no alias matches.
RecognizedWine? recognizeWords(List<String> words) {
  final match = findAlias(words);
  if (match == null) return null;
  final profile = denominationTable[match.denominationKey];
  if (profile == null) return null;
  return RecognizedWine(
    denominationKey: match.denominationKey,
    wineType: profile.wineType,
    qualifier: _qualifierFor(profile, _qualifierMask(words, match)),
  );
}

/// What an internal estimate is based on, after the precedences of BR1.2.
class ResolvedWine {
  const ResolvedWine.denomination(
    DenominationProfile this.denomination,
    this.qualifier,
  ) : basis = EstimationBasis.denomination,
      wineType = null;

  const ResolvedWine.wineType(WineType this.wineType)
    : basis = EstimationBasis.wineType,
      denomination = null,
      qualifier = null;

  const ResolvedWine.generic()
    : basis = EstimationBasis.generic,
      denomination = null,
      wineType = null,
      qualifier = null;

  final EstimationBasis basis;
  final DenominationProfile? denomination;
  final Qualifier? qualifier;
  final WineType? wineType;

  /// Type used for the base year (BR1.3); `null` for a generic estimate.
  WineType? get effectiveType => denomination?.wineType ?? wineType;

  /// Offsets of the qualifier when it has its own, else of the row.
  YearOffsets get offsets {
    final row = denomination;
    if (row != null) {
      return row.qualifierOffsets[qualifier] ?? row.offsets;
    }
    return _typeRow.offsets;
  }

  /// Internal pairing categories (BR4.1).
  List<PairingCategory> get pairingCategories {
    final row = denomination;
    if (row != null && row.pairingCategories.isNotEmpty) {
      return row.pairingCategories;
    }
    return _typeRow.pairingCategories;
  }

  TypeProfile get _typeRow {
    final type = effectiveType;
    if (type == null) return genericTypeProfile;
    return typeTable[type] ?? genericTypeProfile;
  }
}

/// Resolves the basis of an internal estimate (BR1.2, BR1.7):
/// 1. the user's denomination, when it is in the table;
/// 2. else the type (user's, then catalog's): a denomination from the catalog
///    or from the name is kept only when it has that same type, otherwise
///    the type table is used;
/// 3. without a type, the catalog denomination, then the name's;
/// 4. else the generic row.
ResolvedWine resolveWine(WineFacts wine, ExternalProfile? external) {
  final nameWords = tokenize(wine.name);
  final userDenomination = wine.denomination;
  final userWords = userDenomination == null
      ? const <String>[]
      : tokenize(userDenomination);

  final userMatch = findAlias(userWords);
  if (userMatch != null) {
    return _resolvedDenomination(userMatch, nameWords, userWords, userWords);
  }

  final type = wine.wineType ?? WineType.tryParse(external?.wineType);
  final catalogDenomination = external?.denomination;
  if (catalogDenomination != null) {
    final catalogWords = tokenize(catalogDenomination);
    final catalogMatch = findAlias(catalogWords);
    if (catalogMatch != null && _hasType(catalogMatch, type)) {
      return _resolvedDenomination(
        catalogMatch,
        nameWords,
        userWords,
        catalogWords,
      );
    }
  }

  final nameMatch = findAlias(nameWords);
  if (nameMatch != null && _hasType(nameMatch, type)) {
    return _resolvedDenomination(nameMatch, nameWords, userWords, nameWords);
  }

  if (type != null) return ResolvedWine.wineType(type);
  return const ResolvedWine.generic();
}

bool _hasType(AliasMatch match, WineType? type) {
  if (type == null) return true;
  return denominationTable[match.denominationKey]?.wineType == type;
}

ResolvedWine _resolvedDenomination(
  AliasMatch match,
  List<String> nameWords,
  List<String> userWords,
  List<String> matchedWords,
) {
  final profile = denominationTable[match.denominationKey];
  if (profile == null) return const ResolvedWine.generic();
  final mask =
      _qualifierMask(
        nameWords,
        identical(matchedWords, nameWords) ? match : null,
      ) |
      _qualifierMask(
        userWords,
        identical(matchedWords, userWords) ? match : null,
      );
  return ResolvedWine.denomination(profile, _qualifierFor(profile, mask));
}

/// Bit mask (bit = [Qualifier.index]) of the qualifier words in [words],
/// skipping the words of [skip], the alias itself.
int _qualifierMask(List<String> words, AliasMatch? skip) {
  var mask = 0;
  for (var i = 0; i < words.length; i++) {
    if (skip != null && i >= skip.start && i < skip.start + skip.wordCount) {
      continue;
    }
    final word = words[i];
    if (word == 'riserva') {
      mask |= 1 << Qualifier.riserva.index;
    } else if (word == 'superiore') {
      mask |= 1 << Qualifier.superiore.index;
    } else if (word == 'gran' &&
        i + 1 < words.length &&
        words[i + 1] == 'selezione') {
      mask |= 1 << Qualifier.granSelezione.index;
    }
  }
  return mask;
}

/// The most specific qualifier found that has its own offsets in [profile];
/// a qualifier without offsets is ignored (BR1.1).
Qualifier? _qualifierFor(DenominationProfile profile, int mask) {
  if (mask == 0) return null;
  for (final qualifier in _qualifierPriority) {
    if (mask & (1 << qualifier.index) == 0) continue;
    if (profile.qualifierOffsets.containsKey(qualifier)) return qualifier;
  }
  return null;
}
