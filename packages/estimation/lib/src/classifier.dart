// classifyWine of wine-style-profiles (F2, BR3, BR4.3-BR4.5, BR5.3,
// ENT-111): the Type, Level and Style proposed for a wine from its name,
// producer, denomination and the type of the offline database. One function
// for the offline database tool, the form and the migration (D3).
//
// Precedence of the Type (BR3.1): a qualifier that decides the category >
// the denomination's profile > words of the name > grape > database type >
// the Château rule; nothing gives an empty Type. A dosage word never beats a
// denomination, a method word or a colour (BR3.2).

import 'grapes.dart';
import 'models.dart';
import 'profile_map.dart';
import 'qualifiers.dart';
import 'recognizer.dart';
import 'style_resolver.dart';
import 'style_words.dart';
import 'tables.dart';
import 'world_tables.dart' show TemplateKeys;

/// Why a value was proposed (ENT-111 `reasons`).
enum PreselectionReason {
  qualifier,
  categoryWord,
  denomination,
  nameWord,
  grape,
  dbType,
  chateau,
  genericTable,
  none,
}

/// Result of [classifyWine] (ENT-111): the proposed values, in memory.
class Preselection {
  const Preselection({
    this.wineType,
    this.level = WineLevel.good,
    this.style,
    this.styleToConfirm = false,
    this.reasons = const [PreselectionReason.none],
    this.denominationKey,
    this.nonWine = false,
  });

  /// `null` when nothing says what the wine is (BR3.9).
  final WineType? wineType;
  final WineLevel level;

  /// `null` without a Type, or when the style must be chosen (Sherry
  /// without a style word, BR2.8; a sweet wine without a style word).
  final WineStyle? style;

  /// True when the style is a hypothesis to confirm (BR5.4).
  final bool styleToConfirm;
  final List<PreselectionReason> reasons;

  /// The denomination recognised, if any.
  final String? denominationKey;

  /// True for a product that is not a wine (BR3.9, BR9.4).
  final bool nonWine;

  @override
  bool operator ==(Object other) =>
      other is Preselection &&
      other.wineType == wineType &&
      other.level == level &&
      other.style == style &&
      other.styleToConfirm == styleToConfirm;

  @override
  int get hashCode => Object.hash(wineType, level, style, styleToConfirm);

  @override
  String toString() =>
      'Preselection(${wineType?.name}, ${level.name}, ${style?.name}'
      '${styleToConfirm ? ', to confirm' : ''}, reasons: '
      '${reasons.map((r) => r.name).join(',')})';
}

/// BR3.6: grapes that give only a colour, besides the grapes of the
/// estimate's table.
const Map<String, WineType> extraGrapeTypes = {
  'mondeuse': WineType.redLight,
  'dornfelder': WineType.redLight,
  'spatburgunder': WineType.redLight,
  'trollinger': WineType.redLight,
  'lemberger': WineType.redLight,
  'bonarda': WineType.redLight,
  'cannonau': WineType.redLight,
  'carignan': WineType.redLight,
  'cinsault': WineType.redLight,
  'corvina': WineType.redLight,
  'refosco': WineType.redLight,
  'lagrein': WineType.redLight,
  'teroldego': WineType.redLight,
  'dolcetto': WineType.redLight,
  'negroamaro': WineType.redLight,
  'nero d avola': WineType.redLight,
  'monastrell': WineType.redLight,
  'bobal': WineType.redLight,
  'garnacha tinta': WineType.redLight,
  'garnacha': WineType.redLight,
  'castelao': WineType.redLight,
  'baga': WineType.redLight,
  'agiorgitiko': WineType.redLight,
  'saperavi': WineType.redLight,
  'plavac mali': WineType.redLight,
  'kadarka': WineType.redLight,
  'gamaret': WineType.redLight,
  'cornalin': WineType.redLight,
  'humagne rouge': WineType.redLight,
  'trebbiano': WineType.white,
  'verdicchio': WineType.white,
  'arneis': WineType.white,
  'cortese': WineType.white,
  'garganega': WineType.white,
  'grillo': WineType.white,
  'inzolia': WineType.white,
  'fiano': WineType.white,
  'greco': WineType.white,
  'falanghina': WineType.white,
  'friulano': WineType.white,
  'ribolla': WineType.white,
  'macabeo': WineType.white,
  'viura': WineType.white,
  'airen': WineType.white,
  'picpoul': WineType.white,
  'colombard': WineType.white,
  'ugni blanc': WineType.white,
  'melon de bourgogne': WineType.white,
  'muscadet': WineType.white,
  'savagnin': WineType.white,
  'chasselas': WineType.white,
  'fendant': WineType.white,
  'petite arvine': WineType.white,
  'muller thurgau': WineType.white,
  'silvaner': WineType.white,
  'sylvaner': WineType.white,
  'kerner': WineType.white,
  'grauburgunder': WineType.white,
  'weissburgunder': WineType.white,
  'pinot blanc': WineType.white,
  'pinot bianco': WineType.white,
  'pinot gris': WineType.white,
  'malvasia bianca': WineType.white,
  'loureiro': WineType.white,
  'encruzado': WineType.white,
  'moschofilero': WineType.white,
  'roditis': WineType.white,
  'muscat': WineType.sweet,
  'moscatel': WineType.sweet,
};

/// A grape found in a name: its type and, for the grapes of the table, its
/// window.
class _GrapeHit {
  const _GrapeHit(this.type, this.profile);

  final WineType type;
  final GrapeProfile? profile;
}

/// The longest grape of [words] outside [skip] (the denomination's words,
/// BR3.1): the table's grapes, then the colour-only grapes (BR3.6). A
/// Muscat with a dry word is a white (BR3.6).
_GrapeHit? _grapeOf(List<String> words, AliasMatch? skip) {
  final kept = [
    for (var i = 0; i < words.length; i++)
      if (skip == null || !skip.covers(i)) words[i],
  ];
  final table = findGrape(kept);
  final tableWords = table?.wordCount ?? 0;
  String? extra;
  for (final phrase in extraGrapeTypes.keys) {
    final length = phrase.split(' ').length;
    if (length <= tableWords) continue;
    if (extra != null && length <= extra.split(' ').length) continue;
    if (hasPhrase(kept, phrase)) extra = phrase;
  }
  final dry = firstPhrase(kept, dryWords) != null;
  if (extra != null) {
    final type = extraGrapeTypes[extra]!;
    return _GrapeHit(
      type == WineType.sweet && dry ? WineType.white : type,
      null,
    );
  }
  if (table == null) return null;
  final grape = grapeTable[table.denominationKey]!;
  if (grape.wineType == WineType.sweet && dry) {
    return const _GrapeHit(WineType.white, null);
  }
  return _GrapeHit(grape.wineType, grape);
}

/// The combinations of each denomination key, built once.
final Map<String, List<ProfileMapEntry>> _entriesByKey = () {
  final map = <String, List<ProfileMapEntry>>{};
  for (final entry in profileMap.values) {
    map.putIfAbsent(entry.id.split(':').first, () => []).add(entry);
  }
  return map;
}();

/// The first qualifier phrase of [words] (BR4.4 reads the phrase, not the
/// row's offsets).
Qualifier? _qualifierOf(List<String> words) {
  final found = qualifiersOf(qualifierMaskOf(words));
  return found.isEmpty ? null : found.first;
}

const Set<Qualifier> _sweetQualifiers = {
  Qualifier.auslese,
  Qualifier.beerenauslese,
  Qualifier.trockenbeerenauslese,
  Qualifier.eiswein,
};

const Set<Qualifier> _structuredQualifiers = {
  Qualifier.riserva,
  Qualifier.reserva,
  Qualifier.granReserva,
  Qualifier.crianza,
  Qualifier.grandCru,
};

/// Proposes the Type, Level and Style of a wine (F2, BR3.1-BR5.3).
///
/// [dbType] is the type of the offline database (the category tags);
/// [country] an ISO 3166-1 code; [vintage] the vintage, which makes a
/// traditional-method sparkling wine a vintage one (BR2.3).
Preselection classifyWine(
  String name, {
  String? producer,
  String? denomination,
  WineType? dbType,
  String? country,
  int? vintage,
}) {
  final n = tokenizeAll(name);
  final p = producer == null ? const <String>[] : tokenizeAll(producer);
  final d = denomination == null ? const <String>[] : tokenizeAll(denomination);
  if (isNonWine(n)) {
    return const Preselection(nonWine: true);
  }
  final full = [...n, ...p];
  final reasons = <PreselectionReason>[];
  final qualifier = _qualifierOf(n);

  // Denomination: in the name, then in the denomination field, then in the
  // producer (BR3.1 step 2).
  final nameMatch = findAlias(n);
  final match = nameMatch ?? findAlias(d) ?? findAlias(p);
  final key = match?.denominationKey;
  final row = key == null ? null : denominationTable[key];
  final template = row?.templateKey;

  // Colour words of the name, else of the producer (BR3.2).
  final colour = colourOf(hasColourWord(n) ? n : full);
  final grape = _grapeOf(n, nameMatch);

  WineType? type;
  StyleProfile? profile;
  var confirm = false;
  ProfileMapEntry? entry;

  // 1. A qualifier that decides the category.
  if (_sweetQualifiers.contains(qualifier)) {
    final dryAuslese =
        qualifier == Qualifier.auslese && firstPhrase(n, dryWords) != null;
    type = dryAuslese ? WineType.white : WineType.sweet;
    reasons.add(PreselectionReason.qualifier);
  }

  // 2. The denomination's types (BR3.3) and profile.
  if (type == null && key != null) {
    final entries = _entriesByKey[key] ?? const <ProfileMapEntry>[];
    final types = <WineType>[];
    for (final e in entries) {
      final t = e.wineType;
      if (!e.id.contains(':qualifier:') &&
          e.rowMakesType &&
          t != null &&
          !types.contains(t)) {
        types.add(t);
      }
    }
    final fallbackRow = entries.any(
      (e) => e.id.contains(':base:') && e.wineType == null,
    );
    if (types.isNotEmpty || fallbackRow) {
      WineType? pick;
      if (colour != null) {
        for (final t in types) {
          if (_isColour(t, colour)) {
            pick = t;
            break;
          }
        }
      }
      if (pick == null && grape != null && types.contains(grape.type)) {
        pick = grape.type;
      }
      final colourOut = colour != null && pick == null;
      final grapeOut =
          grape != null &&
          pick == null &&
          colour == null &&
          !types.contains(grape.type);
      if (pick == null &&
          dbType != null &&
          types.contains(dbType) &&
          !fallbackRow) {
        pick = dbType;
      }
      if (!(fallbackRow && pick == null) && !colourOut && !grapeOut) {
        type = pick ?? types.first;
        reasons.add(PreselectionReason.denomination);
        entry = _entryFor(entries, type, qualifier);
        if (entry != null && !(fallbackRow && entry.styleToConfirm)) {
          profile = entry.profile;
          confirm = entry.styleToConfirm;
        }
        // BR2.7, BR2.8, BR2.16: the style words of the name decide the
        // Porto and Sherry categories.
        final words = key == 'porto' && qualifier == null
            ? portProfileOf(n)
            : (key == 'jerez' || key == 'montillaMoriles')
            ? sherryProfileOf(n)
            : null;
        if (words != null) {
          profile = words;
          confirm = false;
        }
      }
    }
  }

  // 3. Words of the name (BR3.2).
  if (type == null) {
    if (firstPhrase(n, fortifiedWords) != null) {
      type = WineType.fortified;
    } else if (firstPhrase(n, classicMethodWords) != null) {
      type = WineType.sparklingClassic;
    } else if (firstPhrase(n, tankMethodWords) != null) {
      type = WineType.sparklingTank;
    } else if (firstPhrase(n, sweetCategoryWords) != null ||
        (hasDosageWord(n) && colour == null)) {
      type = WineType.sweet;
    } else if (colour == 'rose') {
      type = WineType.rose;
    } else if (colour == 'white') {
      type = WineType.white;
    }
    if (type != null) reasons.add(PreselectionReason.nameWord);
  }

  // BR3.8: a generic table wine.
  final generic =
      key == null &&
      grape == null &&
      firstPhrase(n, [
            ...fortifiedWords,
            ...sweetCategoryWords,
            ...classicMethodWords,
            ...tankMethodWords,
          ]) ==
          null &&
      n.isNotEmpty &&
      genericDesignations.contains(n.first);
  final regional =
      firstPhrase(full, regionalWineWords) != null ||
      template == TemplateKeys.italyIgt ||
      template == TemplateKeys.franceIgp;

  if (type == null && colour == 'red') {
    if (generic || regional) {
      type = WineType.redLight;
    } else if (grape != null) {
      type = _isColour(grape.type, 'red') ? grape.type : WineType.redLight;
    } else if (dbType != null && _isColour(dbType, 'red')) {
      type = dbType;
    } else {
      type = WineType.redLight;
    }
    reasons.add(PreselectionReason.nameWord);
  }
  // 4. Grape; 5. database type.
  if (type == null && grape != null) {
    type = grape.type;
    reasons.add(PreselectionReason.grape);
  }
  if (type == null && dbType != null) {
    type = dbType;
    reasons.add(PreselectionReason.dbType);
  }
  // 6. BR3.7: a French Château without any other clue.
  if (type == null &&
      n.isNotEmpty &&
      (n.first == 'chateau' || n.first == 'ch') &&
      (country == null || country == 'FR')) {
    return const Preselection(
      wineType: WineType.redStructured,
      style: WineStyle.redMedium,
      styleToConfirm: true,
      reasons: [PreselectionReason.chateau],
    );
  }
  // 7. Nothing (BR3.9).
  if (type == null) return const Preselection();

  if (generic) {
    if (type == WineType.redStructured) type = WineType.redLight;
    reasons.add(PreselectionReason.genericTable);
  }
  // BR3.4: light or structured red.
  if (type == WineType.redLight &&
      (profile == StyleProfile.rAge ||
          profile == StyleProfile.rLong ||
          _structuredQualifiers.contains(qualifier))) {
    type = WineType.redStructured;
  }

  // Style (BR5.3).
  if (profile == null) {
    final chosen = _styleProfile(type, n, grape, generic);
    profile = chosen.profile;
    confirm = chosen.confirm;
  } else if (profile == StyleProfile.unknown) {
    confirm = true;
  }
  if (type == WineType.sparklingClassic &&
      (vintage != null ||
          qualifier == Qualifier.riserva ||
          qualifier == Qualifier.granReserva ||
          qualifier == Qualifier.vintage ||
          firstPhrase(n, vintageSparklingWords) != null)) {
    profile = StyleProfile.spClassicAge;
  }
  final style = _styleFor(profile, type, key);

  // Level (BR4.3).
  final level = _levelOf(
    profile: profile,
    type: type,
    qualifier: qualifier,
    confirm: confirm,
    generic: generic,
    regional: regional,
    words: n,
  );
  return Preselection(
    wineType: type,
    level: level,
    style: style,
    styleToConfirm: confirm || profile.isUnclear,
    reasons: List.unmodifiable(reasons),
    denominationKey: key,
  );
}

bool _isColour(WineType type, String colour) => switch (colour) {
  'red' => type == WineType.redLight || type == WineType.redStructured,
  'white' => type == WineType.white,
  'rose' => type == WineType.rose,
  _ => false,
};

ProfileMapEntry? _entryFor(
  List<ProfileMapEntry> entries,
  WineType type,
  Qualifier? qualifier,
) {
  if (qualifier != null) {
    for (final e in entries) {
      if (e.wineType == type && e.id.endsWith(':qualifier:${qualifier.name}')) {
        return e;
      }
    }
  }
  for (final e in entries) {
    if (e.wineType == type && !e.id.contains(':qualifier:')) return e;
  }
  return null;
}

/// The style of a type without a denomination profile (BR5.3, BR5.6,
/// BR2.16): the generic table wine is fresh; a fortified wine or a sweet
/// wine takes the profile of its words; a grape with a window takes the
/// nearest profile of its family; otherwise the type's profile, to confirm.
({StyleProfile profile, bool confirm}) _styleProfile(
  WineType type,
  List<String> words,
  _GrapeHit? grape,
  bool generic,
) {
  if (generic) {
    return (
      profile: switch (type) {
        WineType.redLight || WineType.redStructured => StyleProfile.rFresh,
        WineType.white => StyleProfile.wFresh,
        _ => typeDefaultProfiles[type]!,
      },
      confirm: false,
    );
  }
  if (type == WineType.white &&
      firstPhrase(words, const ['bag in box', 'bib', 'fontaine']) != null) {
    return (profile: StyleProfile.wFresh, confirm: false);
  }
  if (type == WineType.fortified) {
    final fortified = portProfileOf(words) ?? sherryProfileOf(words);
    return (
      profile: fortified ?? StyleProfile.fortUnknown,
      confirm: fortified == null,
    );
  }
  if (type == WineType.sweet) {
    final sweet = sweetProfileOf(words);
    if (sweet != null) return (profile: sweet, confirm: false);
    if (hasDosageWord(words)) {
      return (profile: StyleProfile.swAromatic, confirm: false);
    }
    return (profile: StyleProfile.unknown, confirm: true);
  }
  final grapeProfile = grape?.profile;
  final family = familyProfilesOf(type);
  if (grapeProfile != null && grape!.type == type && family != null) {
    return (
      profile: nearestProfile(family, grapeProfile.offsets),
      confirm: false,
    );
  }
  if (type == WineType.sparklingTank && hasPhrase(words, 'lambrusco')) {
    return (profile: StyleProfile.lamFresh, confirm: false);
  }
  return (profile: typeDefaultProfiles[type]!, confirm: hasSeveralStyles(type));
}

WineStyle? _styleFor(StyleProfile profile, WineType type, String? key) {
  if (profile == StyleProfile.unknown) {
    final byType = typeDefaultProfiles[type]!;
    return byType == StyleProfile.unknown ? null : WineStyle.ofProfile(byType);
  }
  if (profile == StyleProfile.fortUnknown &&
      (key == 'jerez' || key == 'montillaMoriles')) {
    return null;
  }
  return WineStyle.ofProfile(profile, madeiraDenomination: key == 'madeira');
}

/// The level proposed for [name] with the Type and the profile the form
/// shows now (BR4.3, BR4.6): used when the user changes the Type or the
/// Style and the level is still automatic.
WineLevel suggestedLevel(
  String name, {
  String? producer,
  String? denomination,
  required WineType? type,
  required StyleProfile? profile,
  bool styleToConfirm = false,
}) {
  final n = tokenizeAll(name);
  final full = [...n, if (producer != null) ...tokenizeAll(producer)];
  final match =
      findAlias(n) ??
      (denomination == null ? null : findAlias(tokenizeAll(denomination)));
  final template = match == null
      ? null
      : denominationTable[match.denominationKey]?.templateKey;
  final generic =
      match == null &&
      n.isNotEmpty &&
      genericDesignations.contains(n.first) &&
      _grapeOf(n, null) == null;
  return _levelOf(
    profile: profile ?? StyleProfile.unknown,
    type: type ?? WineType.redLight,
    qualifier: _qualifierOf(n),
    confirm: styleToConfirm,
    generic: generic,
    regional:
        firstPhrase(full, regionalWineWords) != null ||
        template == TemplateKeys.italyIgt ||
        template == TemplateKeys.franceIgp,
    words: n,
  );
}

/// BR4.3, BR4.4, BR4.5: the level proposed.
WineLevel _levelOf({
  required StyleProfile profile,
  required WineType type,
  required Qualifier? qualifier,
  required bool confirm,
  required bool generic,
  required bool regional,
  required List<String> words,
}) {
  final agingQualifier =
      qualifier != null &&
      agingQualifiers.contains(qualifier) &&
      (qualifier != Qualifier.vintage || type == WineType.fortified);
  if (agingQualifier) return WineLevel.aging;
  if (profile == StyleProfile.spTank || profile == StyleProfile.lamFresh) {
    return WineLevel.everyday;
  }
  if (profile.freshForLevel &&
      qualifier == null &&
      (!confirm || type == WineType.rose || generic)) {
    return WineLevel.everyday;
  }
  if (regional || generic || firstPhrase(words, tableWineWords) != null) {
    return WineLevel.everyday;
  }
  return WineLevel.good;
}
