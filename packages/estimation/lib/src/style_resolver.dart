// resolveStyle of wine-style-profiles (F1, BR2.1-BR2.16, BR5.6, ENT-105):
// which profile, window and type estimate a wine.
//
// 1. A style chosen by the user wins (BR2.15).
// 2. A recognised denomination reads its combination in the generated map
//    (BR2.1-BR2.14), refined by the style words of the name (BR2.16): BA,
//    TBA and ice wine, Porto and Sherry categories, vintage traditional
//    method, traditional-method Lambrusco.
// 3. A grape keeps today's grape window, style to confirm (F1).
// 4. A type uses the type's profile (BR5.6) with the style words.
// 5. Nothing: the generic indicative estimate 1/3/6 (BR2.14).

import 'grapes.dart';
import 'models.dart';
import 'profile_map.dart';
import 'recognizer.dart';
import 'style_words.dart';
import 'tables.dart';

/// Where the window of a resolution comes from (ENT-105).
enum ResolutionSource {
  /// The profile's numbers.
  profile,

  /// Today's values of a row, kept (step 2 of BR2.1, or a grape).
  legacy,

  /// Today's values of a row, as an indicative estimate (BR2.14).
  indicativeRow,

  /// Today's values of the type, as an indicative estimate (BR2.14).
  indicativeType,

  /// The generic 1/3/6 indicative estimate (BR2.14).
  generic,

  /// "To estimate": no window (BR2.9).
  none,
}

/// Result of [resolveStyle] (ENT-105): the profile, the type and the window
/// offsets an estimate uses. Not saved; the window carries its outcome.
class StyleResolution {
  const StyleResolution({
    required this.profile,
    required this.wineType,
    required this.step,
    required this.source,
    required this.styleToConfirm,
    required this.basis,
    this.style,
    this.denominationKey,
    this.qualifier,
    this.dedicated = false,
    this.anchor,
    this.unit,
    this.start,
    this.peak,
    this.end,
  });

  final StyleProfile profile;

  /// The style shown (BR5.3); `null` when there is none to propose.
  final WineStyle? style;

  /// Type after the corrections (BR2.12); `null` for a generic estimate.
  final WineType? wineType;

  /// Step of the precedence (1-4, BR2.1).
  final int step;
  final ResolutionSource source;

  /// True when the style is a hypothesis to confirm (BR5.4).
  final bool styleToConfirm;
  final EstimationBasis basis;

  /// The denomination or grape row used.
  final String? denominationKey;

  /// Qualifier whose own offsets were used.
  final Qualifier? qualifier;

  /// True for a row whose values were decided one by one.
  final bool dedicated;
  final AgingAnchor? anchor;
  final WindowUnit? unit;
  final int? start;
  final int? peak;
  final int? end;

  /// True when the estimate is only indicative (BR2.14).
  bool get indicative =>
      source == ResolutionSource.indicativeRow ||
      source == ResolutionSource.indicativeType ||
      source == ResolutionSource.generic;

  /// True when there is no window ("To estimate").
  bool get hasNoWindow => source == ResolutionSource.none || start == null;

  @override
  String toString() =>
      'StyleResolution(${profile.id}, type: ${wineType?.name}, '
      'step: $step, source: ${source.name}, '
      'window: $start/$peak/$end ${unit?.name}, '
      'toConfirm: $styleToConfirm, key: $denominationKey)';
}

/// The style keys of a profile resolution of [profile] for [key].
WineStyle? _styleOf(StyleProfile profile, WineType? type, String? key) {
  if (profile == StyleProfile.unknown) {
    final typeProfile = type == null ? null : typeDefaultProfiles[type];
    return typeProfile == null ? null : WineStyle.ofProfile(typeProfile);
  }
  if (profile == StyleProfile.fortUnknown && _sherryKeys.contains(key)) {
    // BR2.8, BR5.3: a Sherry without a style word has no style preselected.
    return null;
  }
  return WineStyle.ofProfile(profile, madeiraDenomination: key == 'madeira');
}

/// BR5.6: the profile of a type when the style is not known.
const Map<WineType, StyleProfile> typeDefaultProfiles = {
  WineType.redLight: StyleProfile.rFresh,
  WineType.redStructured: StyleProfile.rMedium,
  WineType.white: StyleProfile.wMedium,
  WineType.rose: StyleProfile.roseFresh,
  WineType.sparklingClassic: StyleProfile.spClassic,
  WineType.sparklingTank: StyleProfile.spTank,
  WineType.sweet: StyleProfile.unknown,
  WineType.fortified: StyleProfile.fortUnknown,
};

const Set<String> _sherryKeys = {'jerez', 'montillaMoriles'};

/// True when the type has more than one style of its colour (red, white):
/// a style taken from the type alone stays to confirm (BR2.11).
bool hasSeveralStyles(WineType type) =>
    type == WineType.redLight ||
    type == WineType.redStructured ||
    type == WineType.white;

/// Resolves the profile and window of [wine] (F1).
StyleResolution resolveStyle(WineFacts wine, [ExternalProfile? external]) {
  final nameWords = tokenizeAll(wine.name);
  final words = [
    ...nameWords,
    if (wine.denomination case final d?) ...tokenizeAll(d),
    if (external?.denomination case final d?) ...tokenizeAll(d),
  ];
  final resolved = resolveWine(wine, external);
  final chosen = wine.style;
  if (chosen != null && wine.styleChosen) {
    return _chosenStyle(wine, chosen, resolved);
  }
  final row = resolved.denomination;
  if (row != null) {
    final entry =
        profileMap[profileMapIdOf(
          resolved.key!,
          row.wineType,
          resolved.wineType!,
          resolved.qualifier,
        )];
    if (entry != null) {
      return _refined(
        _fromEntry(entry, resolved, row, wine),
        words,
        wine,
        resolved,
      );
    }
  }
  final grape = resolved.grape;
  if (grape != null) return _fromGrape(grape, resolved, words, wine);
  final type = resolved.wineType;
  if (type != null) return _fromType(type, words, wine);
  return _generic();
}

StyleResolution _generic() {
  final values = genericTypeProfile.offsets;
  return StyleResolution(
    profile: StyleProfile.unknown,
    wineType: null,
    step: 4,
    source: ResolutionSource.generic,
    styleToConfirm: true,
    basis: EstimationBasis.generic,
    anchor: AgingAnchor.vintage,
    unit: WindowUnit.years,
    start: values.start,
    peak: values.peak,
    end: values.end,
  );
}

/// BR2.15: the profile of the style the user chose.
StyleResolution _chosenStyle(
  WineFacts wine,
  WineStyle style,
  ResolvedWine resolved,
) {
  final type = style.wineTypes.contains(wine.wineType)
      ? wine.wineType!
      : style.wineTypes.first;
  final row = resolved.denomination;
  final basis = row != null
      ? EstimationBasis.denomination
      : EstimationBasis.wineType;
  final profile = style.profile;
  if (profile.isUnclear) {
    // Madeira and "Other": indicative, today's values of the dedicated row
    // when there is one, else of the fortified type.
    final rowValues = row != null && row.hasType(WineType.fortified)
        ? row.offsetsFor(WineType.fortified)
        : null;
    final values = rowValues ?? typeTable[WineType.fortified]!.offsets;
    return StyleResolution(
      profile: profile,
      style: style,
      wineType: type,
      step: 2,
      source: rowValues != null
          ? ResolutionSource.indicativeRow
          : ResolutionSource.indicativeType,
      styleToConfirm: true,
      basis: basis,
      denominationKey: resolved.key,
      dedicated: row?.dedicated ?? false,
      anchor: AgingAnchor.vintage,
      unit: WindowUnit.years,
      start: values.start,
      peak: values.peak,
      end: values.end,
    );
  }
  return _ofProfile(
    profile,
    type: type,
    style: style,
    step: 3,
    basis: basis,
    key: resolved.key,
    dedicated: row?.dedicated ?? false,
  );
}

StyleResolution _ofProfile(
  StyleProfile profile, {
  required WineType? type,
  required int step,
  required EstimationBasis basis,
  WineStyle? style,
  String? key,
  bool dedicated = false,
  bool toConfirm = false,
  Qualifier? qualifier,
}) => StyleResolution(
  profile: profile,
  style: style ?? _styleOf(profile, type, key),
  wineType: type,
  step: step,
  source: ResolutionSource.profile,
  styleToConfirm: toConfirm,
  basis: basis,
  denominationKey: key,
  dedicated: dedicated,
  qualifier: qualifier,
  anchor: profile.anchor,
  unit: profile.unit,
  start: profile.start,
  peak: profile.peak,
  end: profile.end,
);

StyleResolution _fromEntry(
  ProfileMapEntry entry,
  ResolvedWine resolved,
  DenominationProfile row,
  WineFacts wine,
) {
  final key = resolved.key!;
  final chosenType = wine.wineType;
  if (entry.wineType == null && chosenType != null) {
    // BR2.11: a generated row without a real type and a type chosen: the
    // type's profile.
    return _fromType(chosenType, const [], wine, key: key, step: 4);
  }
  final source = switch (entry.estimate) {
    MapEstimate.none => ResolutionSource.none,
    MapEstimate.indicative =>
      entry.wineType == null
          ? ResolutionSource.generic
          : ResolutionSource.indicativeRow,
    MapEstimate.profiled =>
      entry.keepsLegacyWindow
          ? ResolutionSource.legacy
          : ResolutionSource.profile,
  };
  final usesQualifier = entry.id.contains(':qualifier:') && entry.rowMakesType;
  return StyleResolution(
    profile: entry.profile,
    style: _styleOf(entry.profile, entry.wineType, key),
    wineType: entry.wineType,
    step: entry.step,
    source: source,
    styleToConfirm: entry.styleToConfirm,
    basis: EstimationBasis.denomination,
    denominationKey: key,
    qualifier: usesQualifier ? resolved.qualifier : null,
    dedicated: row.dedicated,
    anchor: entry.anchor,
    unit: entry.unit,
    start: entry.start,
    peak: entry.peak,
    end: entry.end,
  );
}

/// The style words of the name refine a denomination's combination
/// (BR2.3, BR2.4, BR2.6-BR2.8, BR2.16).
StyleResolution _refined(
  StyleResolution base,
  List<String> words,
  WineFacts wine,
  ResolvedWine resolved,
) {
  final key = base.denominationKey;
  StyleResolution category(StyleProfile profile, WineType type) => _ofProfile(
    profile,
    type: type,
    step: 1,
    basis: base.basis,
    key: key,
    dedicated: base.dedicated,
  );

  // BR2.6: BA, TBA and ice wine are their own sweet categories.
  final dry = firstPhrase(words, dryWords) != null;
  if (hasPhrase(words, 'trockenbeerenauslese') ||
      hasPhrase(words, 'beerenauslese')) {
    return category(StyleProfile.swBotrytis, WineType.sweet);
  }
  if (hasPhrase(words, 'eiswein') ||
      hasPhrase(words, 'icewine') ||
      hasPhrase(words, 'ice wine')) {
    return category(StyleProfile.swPassito, WineType.sweet);
  }
  if (base.qualifier == Qualifier.auslese && dry) {
    return category(StyleProfile.wAge, WineType.white);
  }
  // BR2.7: Porto categories by the words of the name.
  if (key == 'porto' && base.qualifier == null) {
    if (hasPhrase(words, 'ruby') ||
        hasPhrase(words, 'white port') ||
        hasPhrase(words, 'rose port')) {
      return category(StyleProfile.portLbv, WineType.fortified);
    }
    if (hasPhrase(words, 'tawny')) {
      return category(StyleProfile.portOx, WineType.fortified);
    }
  }
  // BR2.8: Sherry and Montilla-Moriles with a style word.
  if (_sherryKeys.contains(key)) {
    final sherry = sherryProfileOf(words);
    if (sherry != null) return category(sherry, WineType.fortified);
  }
  // BR2.4: a traditional-method Lambrusco.
  if (base.profile == StyleProfile.lamFresh &&
      firstPhrase(words, lambruscoClassicWords) != null) {
    return category(_classicProfile(words, wine), WineType.sparklingClassic);
  }
  // BR2.3: a vintage traditional-method wine.
  if (base.profile == StyleProfile.spClassic &&
      _classicProfile(words, wine) == StyleProfile.spClassicAge) {
    return category(StyleProfile.spClassicAge, WineType.sparklingClassic);
  }
  return base;
}

/// BR2.3: SP_CLASSIC_AGE with a vintage (field or word), else SP_CLASSIC.
StyleProfile _classicProfile(List<String> words, WineFacts wine) =>
    wine.vintage != null ||
        firstPhrase(words, vintageSparklingWords) != null ||
        hasPhrase(words, 'riserva') ||
        hasPhrase(words, 'gran reserva')
    ? StyleProfile.spClassicAge
    : StyleProfile.spClassic;

/// BR2.8: the Sherry profile of the style words, or `null` without one.
StyleProfile? sherryProfileOf(List<String> words) {
  if (hasPhrase(words, 'pale cream')) return StyleProfile.shFino;
  if (hasPhrase(words, 'pedro ximenez') || hasPhrase(words, 'px')) {
    return StyleProfile.shPx;
  }
  if (hasPhrase(words, 'fino') || hasPhrase(words, 'manzanilla')) {
    return StyleProfile.shFino;
  }
  if (hasPhrase(words, 'amontillado') || hasPhrase(words, 'medium')) {
    return StyleProfile.shAmont;
  }
  if (hasPhrase(words, 'oloroso') ||
      hasPhrase(words, 'cream') ||
      hasPhrase(words, 'palo cortado')) {
    return StyleProfile.shOloroso;
  }
  return null;
}

/// BR2.7: the Porto profile of the words, or `null` without a category.
StyleProfile? portProfileOf(List<String> words) {
  if (hasPhrase(words, 'late bottled vintage') || hasPhrase(words, 'lbv')) {
    return StyleProfile.portLbv;
  }
  if (hasPhrase(words, 'vintage')) return StyleProfile.portVintage;
  if (hasPhrase(words, 'ruby') ||
      hasPhrase(words, 'white port') ||
      hasPhrase(words, 'rose port')) {
    return StyleProfile.portLbv;
  }
  if (hasPhrase(words, 'tawny') || hasPhrase(words, 'colheita')) {
    return StyleProfile.portOx;
  }
  return null;
}

/// BR2.16: the sweet profile of the words, or `null` without one.
StyleProfile? sweetProfileOf(List<String> words) {
  if (firstPhrase(words, botrytisWords) != null) {
    return StyleProfile.swBotrytis;
  }
  if (firstPhrase(words, passitoWords) != null) return StyleProfile.swPassito;
  final aromatic = firstPhrase(words, aromaticSweetWords) != null;
  if (aromatic && firstPhrase(words, dryWords) == null) {
    return StyleProfile.swAromatic;
  }
  return null;
}

/// F1: a grape keeps today's grape window, with the style that describes
/// it, to confirm; a sparkling or sweet grape uses its type's profile.
StyleResolution _fromGrape(
  GrapeProfile grape,
  ResolvedWine resolved,
  List<String> words,
  WineFacts wine,
) {
  final type = grape.wineType;
  final family = _familyOf(type);
  if (family == null) {
    final byType = _fromType(type, words, wine);
    return StyleResolution(
      profile: byType.profile,
      style: byType.style,
      wineType: byType.wineType,
      step: byType.step,
      source: byType.source,
      styleToConfirm: byType.styleToConfirm,
      basis: EstimationBasis.grape,
      denominationKey: resolved.key,
      anchor: byType.anchor,
      unit: byType.unit,
      start: byType.start,
      peak: byType.peak,
      end: byType.end,
    );
  }
  final values = grape.offsets;
  final profile = nearestProfile(family, values);
  return StyleResolution(
    profile: profile,
    style: WineStyle.ofProfile(profile),
    wineType: type,
    step: 4,
    source: ResolutionSource.legacy,
    styleToConfirm: true,
    basis: EstimationBasis.grape,
    denominationKey: resolved.key,
    anchor: AgingAnchor.vintage,
    unit: WindowUnit.years,
    start: values.start,
    peak: values.peak,
    end: values.end,
  );
}

/// The red or white profiles, from the shortest; `null` for other types.
List<StyleProfile>? _familyOf(WineType type) => switch (type) {
  WineType.redLight || WineType.redStructured => const [
    StyleProfile.rFresh,
    StyleProfile.rMedium,
    StyleProfile.rAge,
    StyleProfile.rLong,
  ],
  WineType.white => const [
    StyleProfile.wFresh,
    StyleProfile.wMedium,
    StyleProfile.wAge,
  ],
  WineType.sweet => const [
    StyleProfile.swAromatic,
    StyleProfile.swPassito,
    StyleProfile.swBotrytis,
  ],
  _ => null,
};

/// BR2.2: the profile of [family] nearest to [values]; on a tie the shorter.
StyleProfile nearestProfile(List<StyleProfile> family, YearOffsets values) {
  StyleProfile? best;
  var bestDistance = 0;
  for (final profile in family) {
    final distance =
        (profile.start! - values.start).abs() +
        (profile.peak! - values.peak).abs() +
        (profile.end! - values.end).abs();
    if (best == null || distance < bestDistance) {
      best = profile;
      bestDistance = distance;
    }
  }
  return best!;
}

/// The profiles of the type of a grape (red, white, sweet), for the
/// classification (BR3.6).
List<StyleProfile>? familyProfilesOf(WineType type) => _familyOf(type);

/// BR5.6 with the style words (BR2.16): the profile of a type.
StyleResolution _fromType(
  WineType type,
  List<String> words,
  WineFacts wine, {
  String? key,
  int step = 4,
}) {
  final basis = key != null
      ? EstimationBasis.denomination
      : EstimationBasis.wineType;
  StyleResolution profiled(StyleProfile profile, {bool toConfirm = false}) =>
      _ofProfile(
        profile,
        type: type,
        step: step,
        basis: basis,
        key: key,
        toConfirm: toConfirm,
      );

  switch (type) {
    case WineType.sparklingClassic:
      return profiled(_classicProfile(words, wine));
    case WineType.sparklingTank:
      return profiled(
        hasPhrase(words, 'lambrusco')
            ? StyleProfile.lamFresh
            : StyleProfile.spTank,
      );
    case WineType.sweet:
      final sweet = sweetProfileOf(words);
      if (sweet != null) return profiled(sweet);
      final values = typeTable[WineType.sweet]!.offsets;
      return StyleResolution(
        profile: StyleProfile.unknown,
        wineType: type,
        step: step,
        source: ResolutionSource.indicativeType,
        styleToConfirm: true,
        basis: basis,
        denominationKey: key,
        anchor: AgingAnchor.vintage,
        unit: WindowUnit.years,
        start: values.start,
        peak: values.peak,
        end: values.end,
      );
    case WineType.fortified:
      final fortified = portProfileOf(words) ?? sherryProfileOf(words);
      if (fortified != null) return profiled(fortified);
      return StyleResolution(
        profile: StyleProfile.fortUnknown,
        style: WineStyle.fortifiedOther,
        wineType: type,
        step: step,
        source: ResolutionSource.none,
        styleToConfirm: true,
        basis: basis,
        denominationKey: key,
      );
    case WineType.redLight:
    case WineType.redStructured:
    case WineType.white:
    case WineType.rose:
      return profiled(
        typeDefaultProfiles[type]!,
        toConfirm: hasSeveralStyles(type),
      );
  }
}
