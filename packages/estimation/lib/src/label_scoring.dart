// Weights, threshold and margin of the guided check (label-autofill-windows
// BR7.3-BR7.7, D8). Every score is an integer number of hundredths: 0,55 is
// 55, sums stay exact and the comparisons with T and M never depend on the
// rounding of a double (BR7.1). These are the values of rules.md, tuned by
// hand on label-reference-set.md; a change is allowed only with the whole
// reference set green on every criterion of BR7.9, and is written here with
// its reason (BR7.7).

part of 'label_fields.dart';

/// Threshold T (BR7.7): the first candidate of a certain field scores at
/// least this. 80 needs two independent clues: one clue alone is never
/// enough.
const int labelCertaintyThreshold = 80;

/// Margin M (BR7.7): the first candidate of a certain field beats the
/// second by at least this. 25 is just over one average signal: when two
/// candidates are closer than that, the choice depends on a detail of the
/// text and the guide asks.
const int labelCertaintyMargin = 25;

/// Whether a field whose first two candidates score [top] and [second]
/// (`null` without a second one) is certain (BR7.7). Integer hundredths.
bool isCertainScore(int top, int? second) =>
    top >= labelCertaintyThreshold &&
    top - (second ?? 0) >= labelCertaintyMargin;

/// Weights of BR7.3-BR7.6, in hundredths.
abstract final class _W {
  // Denomination (BR7.3).
  static const int strongAlias = 55;
  static const int weakAlias = 25;
  static const int indicatorNear = 30;
  static const int indicatorTwoLines = 20;
  static const int indicatorElsewhere = 10;
  static const int multiWordAlias = 10;
  static const int countryEu = 5;
  static const int countryOutsideEu = 25;
  static const int containedAlias = -30;
  static const int aliasInProducerLine = -25;
  static const int aliasIsGrape = -20;
  static const int shortTextHead = 25;

  // Producer (BR7.4).
  static const int bottlingPhrase = 90;
  static const int bottlingVerb = 75;
  static const int producerLine = 70;
  static const int weakProducerLine = 45;
  static const int firstLines = 15;
  static const int estateBottled = 55;
  static const int producerInLongLine = 50;
  static const int producerInAddress = 55;
  static const int plainFirstLine = 35;
  static const int uniqueProducer = 10;
  static const int twoSources = 10;
  static const int foundingCut = -15;
  static const int onlyProducerWords = -50;

  // Name (BR7.5).
  static const int denominationAndBrandCertain = 85;
  static const int denominationAndBrandUncertain = 60;
  static const int brandBesideDenomination = 50;
  static const int singleShortBrand = 85;
  static const int singleBrand = 70;
  static const int brandAndGrape = 70;
  static const int brandBesideGrape = 55;
  static const int grapeBesideBrand = 40;
  static const int severalBrands = 50;
  static const int longestBrand = 10;
  static const int houseLine = 85;
  static const int grapeAlone = 55;
  static const int grapeWithBrands = 40;
  static const int denominationAndGrape = 60;
  static const int denominationLinePlus = 50;
  static const int denominationLine = 45;
  static const int shortTextDenominationLine = 35;
  static const int aliasOnly = 30;
  static const int producerAsName = 30;
  static const int producerAndGrape = 50;
  static const int uppercaseBrand = -30;

  // Vintage (BR7.6).
  static const int year = 50;
  static const int vintageWord = 40;
  static const int yearAlone = 20;
  static const int uniqueYear = 30;
  static const int foundingYear = -45;
  static const int bottlingYear = -40;
  static const int awardOrAddressYear = -35;
  static const int cuveeYear = -30;
}
