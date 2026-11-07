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

import 'models.dart';

/// Start, peak and end offsets in years.
class YearOffsets {
  const YearOffsets(this.start, this.peak, this.end);

  final int start;
  final int peak;
  final int end;
}

/// One row of the denomination table (entities.md `DenominationProfile`).
class DenominationProfile {
  const DenominationProfile({
    required this.aliases,
    required this.wineType,
    required this.offsets,
    this.qualifierOffsets = const {},
    required this.pairingCategories,
  });

  final List<String> aliases;
  final WineType wineType;
  final YearOffsets offsets;

  /// Own offsets of the qualifiers this denomination recognises.
  final Map<Qualifier, YearOffsets> qualifierOffsets;
  final List<PairingCategory> pairingCategories;
}

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

/// Denomination table keyed by a stable denomination key (rules.md, BR2.1).
const Map<String, DenominationProfile> denominationTable = {
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
