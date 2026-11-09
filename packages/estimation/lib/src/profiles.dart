// The 24 style profiles of the wine-style study and the style keys saved on a
// wine (intent 261108-wine-style-profiles, D1, BR1.1-BR1.4, ENT-101,
// ENT-102). Compile-time constants: the numbers are those of the study sheet
// "Profili candidati" (tool/data/study/study_db.json), copied without
// changes; test/profiles_test.dart compares them with the study.
//
// The study is an editorial draft, not validated (NFR6): each profile states
// the nature of its evidence and the sources of the study (BR1.3). A peak or
// an end the study does not estimate ("—") is `null` and is never invented
// (BR1.2).

import 'models.dart';

/// Unit of a window (ENT-106).
enum WindowUnit { years, months }

/// What a window counts from (ENT-101): the vintage, the bottling or the
/// disgorgement.
enum AgingAnchor { vintage, bottling, disgorgement }

/// Nature of the evidence of a profile (BR1.3), as the study names it.
enum ProfileEvidence {
  editorialEstimate('stima_editoriale'),
  legacyNotValidated('legacy_non_validato'),
  readinessOnly('solo_prontezza'),
  editorialLimitFromRange('limite_editoriale_da_fascia'),
  insufficientData('dati_insufficienti');

  const ProfileEvidence(this.studyName);

  /// The name the study uses.
  final String studyName;
}

const _v = AgingAnchor.vintage;
const _b = AgingAnchor.bottling;
const _d = AgingAnchor.disgorgement;
const _y = WindowUnit.years;
const _m = WindowUnit.months;
const _est = ProfileEvidence.editorialEstimate;
const _leg = ProfileEvidence.legacyNotValidated;
const _ready = ProfileEvidence.readinessOnly;
const _limit = ProfileEvidence.editorialLimitFromRange;
const _none = ProfileEvidence.insufficientData;

/// One profile of the study (ENT-101, BR1.1). [start], [peak] and [end] are
/// offsets in [unit] from [anchor].
enum StyleProfile {
  // Sources: E1. Short window of freshness.
  rFresh('R_FRESH', _v, _y, 0, 1, 3, _est, 'E1', freshForLevel: true),
  // Sources: E1.
  rMedium('R_MEDIUM', _v, _y, 2, 4, 8, _est, 'E1'),
  // Sources: E1, E3. Only a confirmed ageing potential.
  rAge('R_AGE', _v, _y, 4, 8, 15, _est, 'E1, E3'),
  // Sources: R0, E1. Today's Barolo/Brunello/Pauillac candidate.
  rLong('R_LONG', _v, _y, 8, 15, 30, _leg, 'R0, E1'),
  // Sources: E1.
  wFresh('W_FRESH', _v, _y, 0, 1, 3, _est, 'E1', freshForLevel: true),
  // Sources: E1.
  wMedium('W_MEDIUM', _v, _y, 1, 3, 6, _est, 'E1'),
  // Sources: E1, S10.
  wAge('W_AGE', _v, _y, 3, 7, 15, _est, 'E1, S10'),
  // Sources: R0, E1.
  roseFresh('ROSE_FRESH', _v, _y, 0, 1, 2, _leg, 'R0, E1', freshForLevel: true),
  // Sources: E1. From the bottling, in months.
  spTank('SP_TANK', _b, _m, 0, 6, 18, _est, 'E1', freshForLevel: true),
  // Sources: S2, S3.
  lamFresh('LAM_FRESH', _b, _m, 0, 6, 24, _est, 'S2, S3', freshForLevel: true),
  // Sources: S6, S7. From the disgorgement, in months.
  spClassic('SP_CLASSIC', _d, _m, 0, 12, 36, _est, 'S6, S7'),
  // Sources: S6, S7.
  spClassicAge('SP_CLASSIC_AGE', _d, _m, 12, 36, 72, _est, 'S6, S7'),
  // Sources: E1.
  swAromatic('SW_AROMATIC', _v, _y, 0, 1, 2, _est, 'E1', freshForLevel: true),
  // Sources: E1.
  swPassito('SW_PASSITO', _v, _y, 3, 8, 20, _est, 'E1'),
  // Sources: E1, S11.
  swBotrytis('SW_BOTRYTIS', _v, _y, 5, 15, 30, _est, 'E1, S11'),
  // Sources: R0, S8.
  portVintage('PORT_VINTAGE', _v, _y, 15, 30, 60, _leg, 'R0, S8'),
  // Sources: S8. Ready at bottling, no end known.
  portLbv('PORT_LBV', _b, _m, 0, null, null, _ready, 'S8'),
  // Sources: S8.
  portOx('PORT_OX', _b, _m, 0, null, null, _ready, 'S8'),
  // Sources: S9. Upper limit of the range, no peak.
  shFino('SH_FINO', _b, _m, 0, null, 12, _limit, 'S9'),
  // Sources: S9.
  shAmont('SH_AMONT', _b, _m, 0, null, 18, _limit, 'S9'),
  // Sources: S9.
  shOloroso('SH_OLOROSO', _b, _m, 0, null, 24, _limit, 'S9'),
  // Sources: S9.
  shPx('SH_PX', _b, _m, 0, null, 24, _limit, 'S9'),
  // Sources: E1. Fortified wine whose style is not known: no numbers.
  fortUnknown('FORT_UNKNOWN', null, null, null, null, null, _none, 'E1'),
  // Sources: E1. Style not identified: no numbers.
  unknown('UNKNOWN', null, null, null, null, null, _none, 'E1');

  const StyleProfile(
    this.id,
    this.anchor,
    this.unit,
    this.start,
    this.peak,
    this.end,
    this.evidence,
    this.sources, {
    this.freshForLevel = false,
  });

  /// The study's identifier (`R_FRESH`), stored in `window.profile`.
  final String id;

  /// `null` only for [fortUnknown] and [unknown].
  final AgingAnchor? anchor;
  final WindowUnit? unit;
  final int? start;

  /// `null` = not estimated (BR1.2).
  final int? peak;

  /// `null` = no end estimated (BR1.2).
  final int? end;
  final ProfileEvidence evidence;

  /// References of the study (R0, E1-E3, S1-S20).
  final String sources;

  /// True for the fresh profiles that preselect "everyday" without a
  /// qualifier (BR4.3).
  final bool freshForLevel;

  /// True when the style is not clear (BR2.14).
  bool get isUnclear => this == unknown || this == fortUnknown;

  /// True when the window counts in months.
  bool get inMonths => unit == WindowUnit.months;

  /// The profile whose study identifier is [id], or `null`.
  static StyleProfile? tryParse(Object? id) {
    if (id is! String) return null;
    for (final profile in values) {
      if (profile.id == id) return profile;
    }
    return null;
  }
}

const _rl = WineType.redLight;
const _rs = WineType.redStructured;
const _wh = WineType.white;
const _ro = WineType.rose;
const _spc = WineType.sparklingClassic;
const _spt = WineType.sparklingTank;
const _sw = WineType.sweet;
const _fo = WineType.fortified;

/// The style saved on a wine (ENT-102, BR1.4): a stable key that points to a
/// profile. Two keys may point to the same profile ([madeira] and
/// [fortifiedOther]); `UNKNOWN` is never a saved style.
enum WineStyle {
  redFresh(StyleProfile.rFresh, [_rl, _rs]),
  redMedium(StyleProfile.rMedium, [_rl, _rs]),
  redAge(StyleProfile.rAge, [_rl, _rs]),
  redLong(StyleProfile.rLong, [_rl, _rs]),
  whiteFresh(StyleProfile.wFresh, [_wh]),
  whiteMedium(StyleProfile.wMedium, [_wh]),
  whiteAge(StyleProfile.wAge, [_wh]),
  roseFresh(StyleProfile.roseFresh, [_ro]),
  tankFresh(StyleProfile.spTank, [_spt]),
  lambrusco(StyleProfile.lamFresh, [_spt]),
  classicFresh(StyleProfile.spClassic, [_spc]),
  classicAge(StyleProfile.spClassicAge, [_spc]),
  sweetAromatic(StyleProfile.swAromatic, [_sw]),
  sweetPassito(StyleProfile.swPassito, [_sw]),
  sweetBotrytis(StyleProfile.swBotrytis, [_sw]),
  portVintage(StyleProfile.portVintage, [_fo]),
  portLbv(StyleProfile.portLbv, [_fo]),
  portTawny(StyleProfile.portOx, [_fo]),
  sherryFino(StyleProfile.shFino, [_fo]),
  sherryAmontillado(StyleProfile.shAmont, [_fo]),
  sherryOloroso(StyleProfile.shOloroso, [_fo]),
  sherryPx(StyleProfile.shPx, [_fo]),
  madeira(StyleProfile.fortUnknown, [_fo]),
  fortifiedOther(StyleProfile.fortUnknown, [_fo]);

  const WineStyle(this.profile, this.wineTypes);

  /// The profile the style points to.
  final StyleProfile profile;

  /// The types that show this style among their options (BR5.2).
  final List<WineType> wineTypes;

  /// What the date of a months profile is (BR8.1): disgorgement for the
  /// traditional method, bottling for the others; `null` for the profiles
  /// in years.
  AgingAnchor? get agingStartLabel => profile.inMonths ? profile.anchor : null;

  /// The style stored as [value], or `null` for anything else (an unknown
  /// key reads as "no style", NFR2.1).
  static WineStyle? tryParse(Object? value) {
    if (value is! String) return null;
    for (final style in values) {
      if (style.name == value) return style;
    }
    return null;
  }

  /// The options of [type] in the order of BR5.2.
  static List<WineStyle> optionsFor(WineType type) => [
    for (final style in values)
      if (style.wineTypes.contains(type)) style,
  ];

  /// The style that shows [profile] (BR5.3): `null` for [StyleProfile.unknown];
  /// [fortifiedOther] for [StyleProfile.fortUnknown], or [madeira] when
  /// [madeiraDenomination] is true.
  static WineStyle? ofProfile(
    StyleProfile profile, {
    bool madeiraDenomination = false,
  }) {
    if (profile == StyleProfile.unknown) return null;
    if (profile == StyleProfile.fortUnknown) {
      return madeiraDenomination ? madeira : fortifiedOther;
    }
    for (final style in values) {
      if (style.profile == profile) return style;
    }
    return null;
  }
}
