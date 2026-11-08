// Wine tables of rules.md (BR2.1, BR2.2, BR4.1) as compile-time constants:
// they are never built at runtime (NFR2.2, security-design.md §3). A
// correction is a code change: it goes through the generated per-row tests
// (test/tables_test.dart, NFR7.2) and ships with the next app version.
//
// Year offsets count from the vintage (or from the base year of BR1.3):
// minimum ageing required by the production rules plus the typical bottle
// evolution of an average vintage. Exceptional vintages are left to the
// external catalog (U3).
//
// Aliases are already normalised as the recognizer normalises names:
// lowercase, no accents, apostrophes and punctuation turned into spaces.

//
// label-autofill-windows (D2, BR3.6, BR3.7): the 47 Italian rows below are
// kept as they are; the hand-written rows of the rest of the world are in
// world_tables.dart, the rows generated from the official registers in
// generated/appellations.g.dart, and [denominationTable] joins the three.

import 'appellations.dart' show buildDenominationTable;
import 'models.dart';

/// Version of the internal tables, stored in every internal window
/// (`DrinkingWindow.tablesVersion`). Raise it whenever a table value
/// changes: the app then estimates every cellar wine again once (BR3.9).
/// Version 1 is the table of u2-estimation, saved without a version.
const int estimationTablesVersion = 2;

/// Start, peak and end offsets in years.
class YearOffsets {
  const YearOffsets(this.start, this.peak, this.end);

  final int start;
  final int peak;
  final int end;

  /// True for a window of BR3.9: 0 <= start <= peak <= end, end >= start + 1.
  bool get isValid => start >= 0 && start <= peak && peak <= end && end > start;

  @override
  bool operator ==(Object other) =>
      other is YearOffsets &&
      other.start == start &&
      other.peak == peak &&
      other.end == end;

  @override
  int get hashCode => Object.hash(start, peak, end);

  @override
  String toString() => '$start/$peak/$end';
}

/// One row of the denomination table (entities.md `DenominationProfile`,
/// extended by label-autofill-windows ENT-004).
///
/// A row has a main type ([wineType], [offsets]) and, for the wide zones that
/// make several styles (Bordeaux, Napa, Mendoza...), [otherTypes] with their
/// own offsets (BR3.1). The qualifiers apply to the main type only.
class DenominationProfile {
  const DenominationProfile({
    required this.aliases,
    required this.wineType,
    required this.offsets,
    this.qualifierOffsets = const {},
    this.pairingCategories = const [],
    this.key,
    this.name,
    this.country,
    this.region,
    this.otherTypes = const {},
    this.weakAliases = const [],
    this.templateKey,
  });

  /// Compact form of the hand-written rows of world_tables.dart: country,
  /// canonical region of `WineOrigins` (or `null`), display name, main type
  /// and offsets. The normalised display name is always a form of the row;
  /// [aliases] lists the other forms. [key] defaults to the display name in
  /// lowerCamelCase ([keyOfName]).
  const DenominationProfile.world(
    String this.country,
    this.region,
    String this.name,
    this.wineType,
    this.offsets, {
    this.key,
    this.aliases = const [],
    this.otherTypes = const {},
    this.qualifierOffsets = const {},
    this.weakAliases = const [],
  }) : pairingCategories = const [],
       templateKey = null;

  /// Normalised forms besides the display name (always for the Italian rows,
  /// which have no [name] of their own).
  final List<String> aliases;
  final WineType wineType;
  final YearOffsets offsets;

  /// Own offsets of the qualifiers this denomination recognises.
  final Map<Qualifier, YearOffsets> qualifierOffsets;

  /// 3-5 categories, or empty for the type's own (ENT-004, review R-11).
  final List<PairingCategory> pairingCategories;

  /// Stable key when given explicitly; see [DenominationProfile.world].
  final String? key;

  /// Name shown to people ("Saint-Estèphe", "Barolo DOCG").
  final String? name;

  /// ISO 3166-1 alpha-2 code.
  final String? country;

  /// Canonical region of `WineOrigins` for [country], or `null` (BR3.5).
  final String? region;

  /// Further types of a wide zone with their offsets (BR3.1).
  final Map<WineType, YearOffsets> otherTypes;

  /// Normalised forms that count on a label only next to an indicator such
  /// as DOC, AOC or the country name (BR1.2): common words like "toro".
  final List<String> weakAliases;

  /// The model of a generated row (BR3.7); `null` for a dedicated row.
  final String? templateKey;

  /// True for the rows whose values were decided one by one.
  bool get dedicated => templateKey == null;

  /// Every type of the row, the main one first.
  List<WineType> get types => [wineType, ...otherTypes.keys];

  /// Whether the row makes wines of [type].
  bool hasType(WineType type) =>
      type == wineType || otherTypes.containsKey(type);

  /// The offsets of [type], the main ones when the row does not make it.
  YearOffsets offsetsFor(WineType type) =>
      type == wineType ? offsets : otherTypes[type] ?? offsets;

  /// This row with its key and origin, as the joined table stores it.
  DenominationProfile withOrigin({
    required String key,
    required String? name,
    required String? country,
    required String? region,
  }) => DenominationProfile(
    aliases: aliases,
    wineType: wineType,
    offsets: offsets,
    qualifierOffsets: qualifierOffsets,
    pairingCategories: pairingCategories,
    key: key,
    name: name,
    country: country,
    region: region,
    otherTypes: otherTypes,
    weakAliases: weakAliases,
    templateKey: templateKey,
  );
}

/// The lowerCamelCase key of a display name: "Saint-Estèphe" gives
/// `saintEstephe`, "Côte de Nuits" gives `coteDeNuits`. [words] are the
/// normalised words of the name.
String keyOfWords(List<String> words) {
  final buffer = StringBuffer();
  for (var i = 0; i < words.length; i++) {
    final word = words[i];
    if (i == 0) {
      buffer.write(word);
    } else {
      buffer
        ..write(word[0].toUpperCase())
        ..write(word.substring(1));
    }
  }
  return buffer.toString();
}

/// The table every estimate reads: the 47 Italian rows, the hand-written
/// rows of the world and the generated rows, built once (BR3.6: the
/// dedicated rows win over the generated ones).
final Map<String, DenominationProfile> denominationTable =
    buildDenominationTable();

/// One row of the wine-type table, or the generic row (entities.md
/// `TypeProfile`). [wineType] is `null` only for the generic row.
class TypeProfile {
  const TypeProfile({
    required this.wineType,
    required this.offsets,
    required this.pairingCategories,
  });

  final WineType? wineType;
  final YearOffsets offsets;
  final List<PairingCategory> pairingCategories;
}

/// The 47 Italian rows of u2-estimation keyed by a stable denomination key
/// (rules.md, BR2.1), unchanged; their display name and region are in
/// `denominationLabels` of catalog.dart.
const Map<String, DenominationProfile> italianDenominationTable = {
  'barolo': DenominationProfile(
    aliases: ['barolo'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(8, 15, 30),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(10, 18, 35)},
    pairingCategories: [
      PairingCategory.braisedRedMeat,
      PairingCategory.game,
      PairingCategory.mushroomsTruffle,
      PairingCategory.agedCheese,
    ],
  ),
  'barbaresco': DenominationProfile(
    aliases: ['barbaresco'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(6, 12, 25),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(8, 15, 30)},
    pairingCategories: [
      PairingCategory.braisedRedMeat,
      PairingCategory.game,
      PairingCategory.mushroomsTruffle,
      PairingCategory.agedCheese,
    ],
  ),
  'brunelloDiMontalcino': DenominationProfile(
    aliases: ['brunello di montalcino', 'brunello'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(8, 15, 30),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(10, 18, 35)},
    pairingCategories: [
      PairingCategory.grilledRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
      PairingCategory.mushroomsTruffle,
    ],
  ),
  'rossoDiMontalcino': DenominationProfile(
    aliases: ['rosso di montalcino'],
    wineType: WineType.redLight,
    offsets: YearOffsets(2, 4, 8),
    pairingCategories: [
      PairingCategory.pastaMeatSauce,
      PairingCategory.roastPoultry,
      PairingCategory.curedMeats,
    ],
  ),
  'amaroneDellaValpolicella': DenominationProfile(
    aliases: ['amarone della valpolicella', 'amarone'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(6, 12, 25),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(8, 15, 30)},
    pairingCategories: [
      PairingCategory.braisedRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
    ],
  ),
  'valpolicellaRipasso': DenominationProfile(
    aliases: ['valpolicella ripasso', 'ripasso della valpolicella', 'ripasso'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(3, 5, 10),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(3, 6, 12)},
    pairingCategories: [
      PairingCategory.pastaMeatSauce,
      PairingCategory.grilledRedMeat,
      PairingCategory.agedCheese,
    ],
  ),
  'valpolicella': DenominationProfile(
    aliases: ['valpolicella'],
    wineType: WineType.redLight,
    offsets: YearOffsets(1, 2, 5),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(2, 4, 8)},
    pairingCategories: [
      PairingCategory.curedMeats,
      PairingCategory.pastaMeatSauce,
      PairingCategory.poultry,
    ],
  ),
  'chiantiClassico': DenominationProfile(
    aliases: ['chianti classico'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(3, 6, 12),
    qualifierOffsets: {
      Qualifier.riserva: YearOffsets(5, 8, 15),
      Qualifier.granSelezione: YearOffsets(6, 10, 20),
    },
    pairingCategories: [
      PairingCategory.grilledRedMeat,
      PairingCategory.pastaMeatSauce,
      PairingCategory.agedCheese,
    ],
  ),
  'chianti': DenominationProfile(
    aliases: ['chianti'],
    wineType: WineType.redLight,
    offsets: YearOffsets(1, 3, 6),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(3, 5, 10)},
    pairingCategories: [
      PairingCategory.pastaMeatSauce,
      PairingCategory.curedMeats,
      PairingCategory.pizza,
    ],
  ),
  'vinoNobileDiMontepulciano': DenominationProfile(
    aliases: [
      'vino nobile di montepulciano',
      'nobile di montepulciano',
      'vino nobile',
    ],
    wineType: WineType.redStructured,
    offsets: YearOffsets(4, 8, 15),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(5, 10, 20)},
    pairingCategories: [
      PairingCategory.grilledRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
    ],
  ),
  'bolgheri': DenominationProfile(
    aliases: ['bolgheri'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(4, 8, 15),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(6, 12, 25)},
    pairingCategories: [
      PairingCategory.grilledRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
    ],
  ),
  'taurasi': DenominationProfile(
    aliases: ['taurasi'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(6, 12, 25),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(8, 15, 30)},
    pairingCategories: [
      PairingCategory.braisedRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
    ],
  ),
  'aglianicoDelVulture': DenominationProfile(
    aliases: ['aglianico del vulture'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(5, 10, 20),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(6, 12, 25)},
    pairingCategories: [
      PairingCategory.braisedRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
    ],
  ),
  'sagrantinoDiMontefalco': DenominationProfile(
    aliases: [
      'sagrantino di montefalco',
      'montefalco sagrantino',
      'sagrantino',
    ],
    wineType: WineType.redStructured,
    offsets: YearOffsets(6, 12, 25),
    pairingCategories: [
      PairingCategory.braisedRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
    ],
  ),
  'etnaRosso': DenominationProfile(
    aliases: ['etna rosso'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(3, 7, 15),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(5, 10, 20)},
    pairingCategories: [
      PairingCategory.grilledRedMeat,
      PairingCategory.mushroomsTruffle,
      PairingCategory.agedCheese,
    ],
  ),
  'langheNebbiolo': DenominationProfile(
    aliases: ['langhe nebbiolo', 'nebbiolo d alba'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(3, 6, 12),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(4, 8, 15)},
    pairingCategories: [
      PairingCategory.pastaMeatSauce,
      PairingCategory.mushroomsTruffle,
      PairingCategory.roastPoultry,
    ],
  ),
  'gattinara': DenominationProfile(
    aliases: ['gattinara', 'ghemme'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(6, 12, 25),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(8, 15, 30)},
    pairingCategories: [
      PairingCategory.braisedRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
    ],
  ),
  'valtellinaSuperiore': DenominationProfile(
    aliases: ['valtellina superiore', 'sassella', 'grumello', 'valgella'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(4, 8, 15),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(5, 10, 20)},
    pairingCategories: [
      PairingCategory.game,
      PairingCategory.agedCheese,
      PairingCategory.mushroomsTruffle,
    ],
  ),
  'sforzatoDiValtellina': DenominationProfile(
    aliases: ['sforzato di valtellina', 'sforzato', 'sfursat'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(5, 10, 20),
    pairingCategories: [
      PairingCategory.braisedRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
    ],
  ),
  'barberaDAsti': DenominationProfile(
    aliases: ['barbera d asti'],
    wineType: WineType.redLight,
    offsets: YearOffsets(2, 4, 8),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(3, 6, 12)},
    pairingCategories: [
      PairingCategory.pastaMeatSauce,
      PairingCategory.curedMeats,
      PairingCategory.pizza,
    ],
  ),
  'nizza': DenominationProfile(
    aliases: ['nizza'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(4, 7, 14),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(5, 9, 18)},
    pairingCategories: [
      PairingCategory.grilledRedMeat,
      PairingCategory.pastaMeatSauce,
      PairingCategory.agedCheese,
    ],
  ),
  'barberaDAlba': DenominationProfile(
    aliases: ['barbera d alba'],
    wineType: WineType.redLight,
    offsets: YearOffsets(2, 4, 8),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(3, 6, 12)},
    pairingCategories: [
      PairingCategory.pastaMeatSauce,
      PairingCategory.curedMeats,
      PairingCategory.pizza,
    ],
  ),
  'dolcetto': DenominationProfile(
    aliases: ['dolcetto'],
    wineType: WineType.redLight,
    offsets: YearOffsets(1, 2, 4),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(1, 3, 6)},
    pairingCategories: [
      PairingCategory.curedMeats,
      PairingCategory.pastaMeatSauce,
      PairingCategory.pizza,
    ],
  ),
  'montepulcianoDAbruzzo': DenominationProfile(
    aliases: ['montepulciano d abruzzo'],
    wineType: WineType.redLight,
    offsets: YearOffsets(2, 4, 8),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(4, 7, 14)},
    pairingCategories: [
      PairingCategory.pastaMeatSauce,
      PairingCategory.grilledRedMeat,
      PairingCategory.pizza,
    ],
  ),
  'primitivoDiManduria': DenominationProfile(
    aliases: ['primitivo di manduria'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(2, 4, 8),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(3, 6, 12)},
    pairingCategories: [
      PairingCategory.grilledRedMeat,
      PairingCategory.spicyDishes,
      PairingCategory.agedCheese,
    ],
  ),
  'cannonauDiSardegna': DenominationProfile(
    aliases: ['cannonau di sardegna', 'cannonau'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(2, 5, 10),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(4, 7, 14)},
    pairingCategories: [
      PairingCategory.grilledRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
    ],
  ),
  'teroldegoRotaliano': DenominationProfile(
    aliases: ['teroldego rotaliano', 'teroldego'],
    wineType: WineType.redStructured,
    offsets: YearOffsets(2, 5, 10),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(3, 7, 14)},
    pairingCategories: [
      PairingCategory.grilledRedMeat,
      PairingCategory.game,
      PairingCategory.curedMeats,
    ],
  ),
  'lagrein': DenominationProfile(
    aliases: ['lagrein'],
    wineType: WineType.redLight,
    offsets: YearOffsets(2, 4, 8),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(3, 6, 12)},
    pairingCategories: [
      PairingCategory.pork,
      PairingCategory.curedMeats,
      PairingCategory.agedCheese,
    ],
  ),
  'lambrusco': DenominationProfile(
    aliases: ['lambrusco'],
    wineType: WineType.redLight,
    offsets: YearOffsets(0, 1, 2),
    pairingCategories: [
      PairingCategory.curedMeats,
      PairingCategory.pizza,
      PairingCategory.pastaMeatSauce,
    ],
  ),
  'soave': DenominationProfile(
    aliases: ['soave'],
    wineType: WineType.white,
    offsets: YearOffsets(1, 2, 5),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(2, 4, 8)},
    pairingCategories: [
      PairingCategory.fish,
      PairingCategory.vegetables,
      PairingCategory.risotto,
    ],
  ),
  'verdicchioDeiCastelliDiJesi': DenominationProfile(
    aliases: ['verdicchio dei castelli di jesi', 'verdicchio'],
    wineType: WineType.white,
    offsets: YearOffsets(1, 3, 8),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(3, 6, 12)},
    pairingCategories: [
      PairingCategory.fish,
      PairingCategory.seafood,
      PairingCategory.risotto,
    ],
  ),
  'fianoDiAvellino': DenominationProfile(
    aliases: ['fiano di avellino'],
    wineType: WineType.white,
    offsets: YearOffsets(2, 5, 10),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(3, 6, 12)},
    pairingCategories: [
      PairingCategory.fish,
      PairingCategory.seafood,
      PairingCategory.freshCheese,
    ],
  ),
  'grecoDiTufo': DenominationProfile(
    aliases: ['greco di tufo'],
    wineType: WineType.white,
    offsets: YearOffsets(1, 3, 7),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(2, 5, 10)},
    pairingCategories: [
      PairingCategory.seafood,
      PairingCategory.fish,
      PairingCategory.vegetables,
    ],
  ),
  'vermentinoDiGallura': DenominationProfile(
    aliases: ['vermentino di gallura'],
    wineType: WineType.white,
    offsets: YearOffsets(1, 2, 4),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(1, 3, 6)},
    pairingCategories: [
      PairingCategory.seafood,
      PairingCategory.fish,
      PairingCategory.vegetables,
    ],
  ),
  'gavi': DenominationProfile(
    aliases: ['gavi', 'cortese di gavi'],
    wineType: WineType.white,
    offsets: YearOffsets(1, 2, 4),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(2, 4, 8)},
    pairingCategories: [
      PairingCategory.fish,
      PairingCategory.seafood,
      PairingCategory.aperitif,
    ],
  ),
  'lugana': DenominationProfile(
    aliases: ['lugana'],
    wineType: WineType.white,
    offsets: YearOffsets(1, 2, 5),
    qualifierOffsets: {
      Qualifier.superiore: YearOffsets(2, 4, 8),
      Qualifier.riserva: YearOffsets(3, 5, 10),
    },
    pairingCategories: [
      PairingCategory.fish,
      PairingCategory.risotto,
      PairingCategory.freshCheese,
    ],
  ),
  'etnaBianco': DenominationProfile(
    aliases: ['etna bianco'],
    wineType: WineType.white,
    offsets: YearOffsets(2, 4, 10),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(2, 5, 12)},
    pairingCategories: [
      PairingCategory.seafood,
      PairingCategory.fish,
      PairingCategory.risotto,
    ],
  ),
  'trebbianoDAbruzzo': DenominationProfile(
    aliases: ['trebbiano d abruzzo'],
    wineType: WineType.white,
    offsets: YearOffsets(1, 3, 8),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(2, 4, 10)},
    pairingCategories: [
      PairingCategory.fish,
      PairingCategory.vegetables,
      PairingCategory.freshCheese,
    ],
  ),
  'derthona': DenominationProfile(
    aliases: ['derthona', 'timorasso'],
    wineType: WineType.white,
    offsets: YearOffsets(3, 6, 12),
    pairingCategories: [
      PairingCategory.fish,
      PairingCategory.risotto,
      PairingCategory.agedCheese,
    ],
  ),
  'franciacorta': DenominationProfile(
    aliases: ['franciacorta'],
    wineType: WineType.sparklingClassic,
    offsets: YearOffsets(1, 3, 6),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(3, 7, 12)},
    pairingCategories: [
      PairingCategory.aperitif,
      PairingCategory.rawSeafood,
      PairingCategory.friedFood,
      PairingCategory.risotto,
    ],
  ),
  'trento': DenominationProfile(
    aliases: ['trento', 'trentodoc'],
    wineType: WineType.sparklingClassic,
    offsets: YearOffsets(1, 3, 6),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(3, 7, 12)},
    pairingCategories: [
      PairingCategory.aperitif,
      PairingCategory.rawSeafood,
      PairingCategory.friedFood,
    ],
  ),
  'prosecco': DenominationProfile(
    aliases: ['prosecco', 'conegliano valdobbiadene', 'valdobbiadene'],
    wineType: WineType.sparklingTank,
    offsets: YearOffsets(0, 1, 2),
    qualifierOffsets: {Qualifier.superiore: YearOffsets(0, 1, 3)},
    pairingCategories: [
      PairingCategory.aperitif,
      PairingCategory.friedFood,
      PairingCategory.seafood,
    ],
  ),
  'asti': DenominationProfile(
    aliases: ['asti', 'moscato d asti', 'asti spumante'],
    wineType: WineType.sweet,
    offsets: YearOffsets(0, 1, 2),
    pairingCategories: [
      PairingCategory.pastries,
      PairingCategory.dryBiscuits,
      PairingCategory.aperitif,
    ],
  ),
  'reciotoDellaValpolicella': DenominationProfile(
    aliases: ['recioto della valpolicella', 'recioto'],
    wineType: WineType.sweet,
    offsets: YearOffsets(4, 10, 25),
    pairingCategories: [
      PairingCategory.blueCheese,
      PairingCategory.chocolate,
      PairingCategory.pastries,
    ],
  ),
  'passitoDiPantelleria': DenominationProfile(
    aliases: ['passito di pantelleria', 'pantelleria'],
    wineType: WineType.sweet,
    offsets: YearOffsets(2, 8, 20),
    pairingCategories: [
      PairingCategory.blueCheese,
      PairingCategory.pastries,
      PairingCategory.driedFruit,
    ],
  ),
  'vinSanto': DenominationProfile(
    aliases: [
      'vin santo del chianti classico',
      'vin santo del chianti',
      'vin santo',
      'vinsanto',
    ],
    wineType: WineType.sweet,
    offsets: YearOffsets(5, 10, 30),
    qualifierOffsets: {Qualifier.riserva: YearOffsets(8, 15, 40)},
    pairingCategories: [
      PairingCategory.dryBiscuits,
      PairingCategory.blueCheese,
      PairingCategory.driedFruit,
    ],
  ),
  'marsala': DenominationProfile(
    aliases: ['marsala'],
    wineType: WineType.fortified,
    offsets: YearOffsets(3, 10, 30),
    qualifierOffsets: {
      Qualifier.superiore: YearOffsets(5, 12, 40),
      Qualifier.riserva: YearOffsets(8, 15, 50),
    },
    pairingCategories: [
      PairingCategory.agedCheese,
      PairingCategory.chocolate,
      PairingCategory.driedFruit,
    ],
  ),
};

/// Wine-type table (rules.md, BR2.2).
const Map<WineType, TypeProfile> typeTable = {
  // Young, fruity reds with little tannin.
  WineType.redLight: TypeProfile(
    wineType: WineType.redLight,
    offsets: YearOffsets(1, 2, 4),
    pairingCategories: [
      PairingCategory.curedMeats,
      PairingCategory.pastaMeatSauce,
      PairingCategory.poultry,
      PairingCategory.pizza,
    ],
  ),
  // Tannin and acidity that carry bottle ageing.
  WineType.redStructured: TypeProfile(
    wineType: WineType.redStructured,
    offsets: YearOffsets(3, 7, 15),
    pairingCategories: [
      PairingCategory.braisedRedMeat,
      PairingCategory.grilledRedMeat,
      PairingCategory.game,
      PairingCategory.agedCheese,
    ],
  ),
  // Most whites are drunk young.
  WineType.white: TypeProfile(
    wineType: WineType.white,
    offsets: YearOffsets(0, 2, 4),
    pairingCategories: [
      PairingCategory.fish,
      PairingCategory.seafood,
      PairingCategory.vegetables,
      PairingCategory.freshCheese,
    ],
  ),
  // Freshness to enjoy within two years.
  WineType.rose: TypeProfile(
    wineType: WineType.rose,
    offsets: YearOffsets(0, 1, 2),
    pairingCategories: [
      PairingCategory.aperitif,
      PairingCategory.fish,
      PairingCategory.pizza,
      PairingCategory.vegetables,
    ],
  ),
  // From purchase, after disgorgement.
  WineType.sparklingClassic: TypeProfile(
    wineType: WineType.sparklingClassic,
    offsets: YearOffsets(1, 3, 6),
    pairingCategories: [
      PairingCategory.aperitif,
      PairingCategory.rawSeafood,
      PairingCategory.friedFood,
      PairingCategory.risotto,
    ],
  ),
  // Primary aromas that fade early.
  WineType.sparklingTank: TypeProfile(
    wineType: WineType.sparklingTank,
    offsets: YearOffsets(0, 1, 2),
    pairingCategories: [
      PairingCategory.aperitif,
      PairingCategory.friedFood,
      PairingCategory.seafood,
    ],
  ),
  // Sugar and acidity keep for a long time.
  WineType.sweet: TypeProfile(
    wineType: WineType.sweet,
    offsets: YearOffsets(2, 8, 20),
    pairingCategories: [
      PairingCategory.blueCheese,
      PairingCategory.pastries,
      PairingCategory.dryBiscuits,
    ],
  ),
  // Alcohol and controlled oxidation.
  WineType.fortified: TypeProfile(
    wineType: WineType.fortified,
    offsets: YearOffsets(3, 10, 30),
    pairingCategories: [
      PairingCategory.agedCheese,
      PairingCategory.chocolate,
      PairingCategory.driedFruit,
    ],
  ),
};

/// Generic row for an unknown type: a prudent value halfway between whites
/// and reds, always with low confidence and the warning of BR4.3.
const TypeProfile genericTypeProfile = TypeProfile(
  wineType: null,
  offsets: YearOffsets(1, 3, 6),
  pairingCategories: [
    PairingCategory.agedCheese,
    PairingCategory.curedMeats,
    PairingCategory.pastaMeatSauce,
  ],
);
