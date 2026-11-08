// Name recognition (BR1.1) and resolution of what an estimate is based on
// (BR1.2, BR1.7; label-autofill-windows BR3.1-BR3.3). Matching works on
// whole words of a normalised copy of the text, so "castiglione" never
// contains "asti". The alias indexes below are the only structures built at
// runtime, once (NFR2.2, security-design.md §3; NFR4.3 of
// label-autofill-windows: <= 150 ms).

import 'catalog.dart' show denominationLabels;
import 'grapes.dart';
import 'models.dart';
import 'qualifiers.dart';
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
  // Latin Extended-A letters of the world tables (label-autofill-windows):
  // Œ, œ, Š, š, Ž, ž, č, ć, đ, ő, ű.
  0x152: 0x6F, 0x153: 0x6F, 0x160: 0x73, 0x161: 0x73, 0x17D: 0x7A, //
  0x17E: 0x7A, 0x10D: 0x63, 0x10C: 0x63, 0x107: 0x63, 0x111: 0x64, //
  0x151: 0x6F, 0x171: 0x75,
};

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
    final folded = foldCodeUnit(unit);
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
int foldCodeUnit(int unit) {
  if (unit >= 0x61 && unit <= 0x7A) return unit;
  if (unit >= 0x30 && unit <= 0x39) return unit;
  if (unit >= 0x41 && unit <= 0x5A) return unit + 0x20;
  return _accentFolding[unit] ?? 0;
}

/// One alias of a table, split into words.
class AliasEntry {
  const AliasEntry(this.words, this.denominationKey, {this.weak = false});

  final List<String> words;
  final String denominationKey;

  /// True for a common word that counts on a label only next to an
  /// indicator (BR1.2).
  final bool weak;
}

/// The normalised forms of [row]: its display name (rows of the world
/// tables and generated rows; the 47 Italian rows have none) and its
/// aliases, each with whether it is weak (BR1.2).
List<(String, bool)> formsOf(DenominationProfile row) {
  final forms = <String>[
    if (row.name case final name?) tokenizeAll(name).join(' '),
    for (final alias in row.aliases) tokenizeAll(alias).join(' '),
  ];
  final seen = <String>{};
  return [
    for (final form in forms)
      if (form.isNotEmpty && seen.add(form))
        (form, row.weakAliases.contains(form)),
  ];
}

Map<String, List<AliasEntry>> _indexOf(
  Iterable<MapEntry<String, DenominationProfile>> rows,
) {
  final index = <String, List<AliasEntry>>{};
  for (final MapEntry(key: key, value: row) in rows) {
    for (final (form, weak) in formsOf(row)) {
      final words = form.split(' ');
      index
          .putIfAbsent(words.first, () => <AliasEntry>[])
          .add(AliasEntry(List.unmodifiable(words), key, weak: weak));
    }
  }
  return _frozen(index);
}

Map<String, List<AliasEntry>> _frozen(Map<String, List<AliasEntry>> index) =>
    Map.unmodifiable({
      for (final entry in index.entries)
        entry.key: List<AliasEntry>.unmodifiable(
          entry.value..sort((a, b) => b.words.length.compareTo(a.words.length)),
        ),
    });

/// Builds the index from first word to aliases starting with it, longest
/// alias first, over every row of [denominationTable]. Called once, by the
/// top-level [aliasIndex] initialiser.
Map<String, List<AliasEntry>> buildAliasIndex() =>
    _indexOf(denominationTable.entries);

/// Alias index, built once when the library is first used.
final Map<String, List<AliasEntry>> aliasIndex = buildAliasIndex();

/// The index of the U3 catalog functions: only the rows that have a
/// display name and region in [denominationLabels], so a world or generated
/// row never hides an Italian catalog denomination
/// (`recognizeDenomination`).
final Map<String, List<AliasEntry>> catalogAliasIndex = _indexOf(
  denominationTable.entries.where(
    (entry) => denominationLabels.containsKey(entry.key),
  ),
);

/// The grape index (FR3.2), built once like [aliasIndex].
final Map<String, List<AliasEntry>> grapeIndex = _frozen({
  for (final entry in _grapeEntries().entries) entry.key: entry.value,
});

Map<String, List<AliasEntry>> _grapeEntries() {
  final index = <String, List<AliasEntry>>{};
  grapeTable.forEach((key, grape) {
    for (final form in grapeFormsOf(grape)) {
      final words = form.split(' ');
      index
          .putIfAbsent(words.first, () => <AliasEntry>[])
          .add(AliasEntry(List.unmodifiable(words), key));
    }
  });
  return index;
}

/// The normalised forms of [grape]: its name and its aliases.
List<String> grapeFormsOf(GrapeProfile grape) => {
  tokenizeAll(grape.name).join(' '),
  for (final alias in grape.aliases) tokenizeAll(alias).join(' '),
}.toList();

/// An alias found in a list of words.
class AliasMatch {
  const AliasMatch(
    this.denominationKey,
    this.start,
    this.wordCount, {
    this.weak = false,
  });

  final String denominationKey;
  final int start;
  final int wordCount;
  final bool weak;

  /// True when the word at [index] belongs to this alias.
  bool covers(int index) => index >= start && index < start + wordCount;
}

/// Finds the alias with the most words in [words]; on a tie, the first one
/// in the text wins (BR1.1). Returns `null` when no alias matches. Weak
/// aliases count, marked, unless [includeWeak] is false: then the longest
/// alias that is not weak wins. The caller decides whether a weak one
/// counts (BR1.2: only next to an indicator, see [resolveWine]).
AliasMatch? findAlias(
  List<String> words, [
  Map<String, List<AliasEntry>>? index,
  bool includeWeak = true,
]) {
  final table = index ?? aliasIndex;
  AliasMatch? best;
  for (var i = 0; i < words.length; i++) {
    final candidates = table[words[i]];
    if (candidates == null) continue;
    for (final candidate in candidates) {
      final length = candidate.words.length;
      if (best != null && length <= best.wordCount) break;
      if (!includeWeak && candidate.weak) continue;
      if (_matchesAt(words, i, candidate.words)) {
        best = AliasMatch(
          candidate.denominationKey,
          i,
          length,
          weak: candidate.weak,
        );
        break;
      }
    }
  }
  return best;
}

/// Every alias found in [words]: at each word the longest alias starting
/// there, weak ones included and marked (label-autofill-windows BR1.2).
List<AliasMatch> findAliasMatches(List<String> words) {
  final matches = <AliasMatch>[];
  for (var i = 0; i < words.length; i++) {
    final candidates = aliasIndex[words[i]];
    if (candidates == null) continue;
    for (final candidate in candidates) {
      if (_matchesAt(words, i, candidate.words)) {
        matches.add(
          AliasMatch(
            candidate.denominationKey,
            i,
            candidate.words.length,
            weak: candidate.weak,
          ),
        );
        break;
      }
    }
  }
  return matches;
}

/// The grape with the most words in [words] whose words are all outside
/// [skip] (the denomination found in the same words, BR3.2: "Vino Nobile di
/// Montepulciano" has no grape); `null` when none.
AliasMatch? findGrape(List<String> words, {AliasMatch? skip}) {
  AliasMatch? best;
  for (var i = 0; i < words.length; i++) {
    if (skip != null && skip.covers(i)) continue;
    final candidates = grapeIndex[words[i]];
    if (candidates == null) continue;
    for (final candidate in candidates) {
      final length = candidate.words.length;
      if (best != null && length <= best.wordCount) break;
      if (skip != null && skip.covers(i + length - 1)) continue;
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
/// [words], with [index] or [aliasIndex]; `null` when no alias matches.
RecognizedWine? recognizeWords(
  List<String> words, [
  Map<String, List<AliasEntry>>? index,
]) {
  final match = findAlias(words, index);
  if (match == null) return null;
  final profile = denominationTable[match.denominationKey];
  if (profile == null) return null;
  return RecognizedWine(
    denominationKey: match.denominationKey,
    wineType: profile.wineType,
    qualifier: qualifierFor(
      profile,
      qualifierMaskOf(
        words,
        skipStart: match.start,
        skipCount: match.wordCount,
      ),
    ),
  );
}

/// What an internal estimate is based on, after the precedences of BR3.1.
class ResolvedWine {
  const ResolvedWine.denomination(
    DenominationProfile this.denomination,
    this.qualifier, {
    required WineType this.wineType,
    required String this.key,
  }) : basis = EstimationBasis.denomination,
       grape = null;

  const ResolvedWine.grape(GrapeProfile this.grape, {required String this.key})
    : basis = EstimationBasis.grape,
      denomination = null,
      qualifier = null,
      wineType = null;

  const ResolvedWine.wineType(WineType this.wineType)
    : basis = EstimationBasis.wineType,
      denomination = null,
      grape = null,
      qualifier = null,
      key = null;

  const ResolvedWine.generic()
    : basis = EstimationBasis.generic,
      denomination = null,
      grape = null,
      wineType = null,
      qualifier = null,
      key = null;

  final EstimationBasis basis;
  final DenominationProfile? denomination;
  final GrapeProfile? grape;
  final Qualifier? qualifier;

  /// The type the window is for: chosen or derived (a type of the
  /// denomination row), or the type estimate's type.
  final WineType? wineType;

  /// Key of the denomination or grape row used, for `denominationKey`.
  final String? key;

  /// Type used for the base year (BR1.3); `null` for a generic estimate.
  WineType? get effectiveType => wineType ?? grape?.wineType;

  /// Offsets of the qualifier when it has its own, else of the row and type.
  YearOffsets get offsets {
    final row = denomination;
    if (row != null) {
      final type = wineType!;
      if (type == row.wineType) {
        return row.qualifierOffsets[qualifier] ?? row.offsets;
      }
      return row.offsetsFor(type);
    }
    final grapeRow = grape;
    if (grapeRow != null) return grapeRow.offsets;
    return _typeRow.offsets;
  }

  /// True when the offsets come from a dedicated row: a denomination written
  /// one by one (BR3.4 medium confidence with a vintage).
  bool get isDedicatedDenomination => denomination?.dedicated ?? false;

  /// Internal pairing categories (BR4.1): the row's own, else its type's.
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

/// Resolves the basis of an internal estimate (BR3.1, BR3.2):
/// 1. the user's denomination, when it is in the table and makes the type
///    chosen (any type when none is chosen);
/// 2. the catalog denomination, then the one in the name, on the same
///    condition; a weak alias of the name counts only next to an
///    indicator or its country's name (BR1.2, [_nameAlias]);
/// 3. a grape of the name or of the denomination text that has the type
///    chosen (any when none);
/// 4. the type chosen (user's, then catalog's);
/// 5. the generic row.
///
/// Without a chosen type, a wide zone with several types (Napa, Bordeaux)
/// takes the type of the grape named next to it, else its main type, so
/// "Chardonnay Napa Valley" is a Napa white (review R-01).
ResolvedWine resolveWine(WineFacts wine, ExternalProfile? external) {
  final nameWords = tokenize(wine.name);
  final userDenomination = wine.denomination;
  final userWords = userDenomination == null
      ? const <String>[]
      : tokenize(userDenomination);
  final type = wine.wineType ?? WineType.tryParse(external?.wineType);

  final userMatch = findAlias(userWords);
  if (userMatch != null && _hasType(userMatch, type)) {
    return _resolvedDenomination(
      userMatch,
      matchedWords: userWords,
      nameWords: nameWords,
      userWords: userWords,
      type: type,
    );
  }

  final catalogDenomination = external?.denomination;
  if (catalogDenomination != null) {
    final catalogWords = tokenize(catalogDenomination);
    final catalogMatch = findAlias(catalogWords);
    if (catalogMatch != null && _hasType(catalogMatch, type)) {
      return _resolvedDenomination(
        catalogMatch,
        matchedWords: catalogWords,
        nameWords: nameWords,
        userWords: userWords,
        type: type,
      );
    }
  }

  final nameMatch = _nameAlias(nameWords);
  if (nameMatch != null && _hasType(nameMatch, type)) {
    return _resolvedDenomination(
      nameMatch,
      matchedWords: nameWords,
      nameWords: nameWords,
      userWords: userWords,
      type: type,
    );
  }

  final grapeMatch =
      findGrape(nameWords, skip: nameMatch) ??
      findGrape(userWords, skip: userMatch);
  final grape = grapeMatch == null
      ? null
      : grapeTable[grapeMatch.denominationKey];
  if (grape != null && (type == null || grape.wineType == type)) {
    return ResolvedWine.grape(grape, key: grapeMatch!.denominationKey);
  }

  if (type != null) return ResolvedWine.wineType(type);
  return const ResolvedWine.generic();
}

/// The denomination named in a wine name typed by hand. As on a label
/// (BR1.2), a weak alias (a common word: toro, cava, port, rioja, salta,
/// baden, napa...) counts only when the name also holds an indicator or the
/// name of the denomination's country ("Toro DO", "Rioja Spain"); otherwise
/// the longest alias that is not weak is used, if any. The denomination
/// field of the user and of the catalog names a denomination on purpose, so
/// a weak alias there always counts.
///
/// Owner decision (2026-11-08, message 0b738ea2): in a name typed by hand a
/// weak alias always counts ("Rioja", "Porto" are the wine the owner means);
/// the indicator rule of BR1.2 applies only to text read from a label, where
/// such words can be ordinary words. The country check is kept for labels.
AliasMatch? _nameAlias(List<String> words) => findAlias(words);

bool _hasType(AliasMatch match, WineType? type) {
  if (type == null) return true;
  return denominationTable[match.denominationKey]?.hasType(type) ?? false;
}

ResolvedWine _resolvedDenomination(
  AliasMatch match, {
  required List<String> matchedWords,
  required List<String> nameWords,
  required List<String> userWords,
  required WineType? type,
}) {
  final profile = denominationTable[match.denominationKey];
  if (profile == null) return const ResolvedWine.generic();
  final nameSkip = identical(matchedWords, nameWords) ? match : null;
  final userSkip = identical(matchedWords, userWords) ? match : null;
  final mask =
      qualifierMaskOf(
        nameWords,
        skipStart: nameSkip?.start ?? 0,
        skipCount: nameSkip?.wordCount ?? 0,
      ) |
      qualifierMaskOf(
        userWords,
        skipStart: userSkip?.start ?? 0,
        skipCount: userSkip?.wordCount ?? 0,
      );
  final effectiveType =
      type ?? _grapeTypeIn(profile, nameWords, nameSkip, userWords, userSkip);
  return ResolvedWine.denomination(
    profile,
    effectiveType == profile.wineType ? qualifierFor(profile, mask) : null,
    wineType: effectiveType,
    key: match.denominationKey,
  );
}

/// The type of a grape named next to the denomination when the row makes
/// it, else the row's main type.
WineType _grapeTypeIn(
  DenominationProfile row,
  List<String> nameWords,
  AliasMatch? nameSkip,
  List<String> userWords,
  AliasMatch? userSkip,
) {
  if (row.otherTypes.isEmpty) return row.wineType;
  final match =
      findGrape(nameWords, skip: nameSkip) ??
      findGrape(userWords, skip: userSkip);
  final grapeType = match == null
      ? null
      : grapeTable[match.denominationKey]?.wineType;
  return grapeType != null && row.hasType(grapeType) ? grapeType : row.wineType;
}

/// The most specific qualifier of [mask] that has its own offsets in
/// [profile]; a qualifier without offsets is ignored (BR1.1). "vintage"
/// counts only where the row has it (porto, champagne: BR1.8).
Qualifier? qualifierFor(DenominationProfile profile, int mask) {
  if (mask == 0) return null;
  for (final qualifier in qualifierPriority) {
    if (mask & (1 << qualifier.index) == 0) continue;
    if (profile.qualifierOffsets.containsKey(qualifier)) return qualifier;
  }
  return null;
}
