// Qualifier words (label-autofill-windows BR1.8, review R-05): which words
// of a name or a label give which qualifier, in which order. Whole words of
// the normalised text only, so "Grande" is never "gran".

import 'models.dart';

/// One qualifier phrase: its normalised words and the qualifier it gives.
class QualifierPhrase {
  const QualifierPhrase(this.words, this.qualifier);

  final List<String> words;
  final Qualifier qualifier;
}

/// Every phrase, longer ones first at the same starting word, so "premier
/// grand cru classe" is a premier cru and "late bottled vintage" is LBV.
const List<QualifierPhrase> qualifierPhrases = [
  QualifierPhrase(['gran', 'selezione'], Qualifier.granSelezione),
  QualifierPhrase(['gran', 'reserva'], Qualifier.granReserva),
  QualifierPhrase(['premier', 'grand', 'cru', 'classe'], Qualifier.premierCru),
  QualifierPhrase(['grand', 'cru', 'classe'], Qualifier.grandCru),
  QualifierPhrase(['grand', 'cru'], Qualifier.grandCru),
  QualifierPhrase(['premier', 'cru'], Qualifier.premierCru),
  QualifierPhrase(['1er', 'cru'], Qualifier.premierCru),
  QualifierPhrase(['late', 'bottled', 'vintage'], Qualifier.lbv),
  QualifierPhrase(['riserva'], Qualifier.riserva),
  QualifierPhrase(['reserva'], Qualifier.reserva),
  QualifierPhrase(['reserve'], Qualifier.reserva),
  QualifierPhrase(['crianza'], Qualifier.crianza),
  QualifierPhrase(['superiore'], Qualifier.superiore),
  // wine-style-profiles BR2.6: BA and TBA are their own categories, never
  // an Auslese; the ice wine is a dried-grape sweet wine.
  QualifierPhrase(['trockenbeerenauslese'], Qualifier.trockenbeerenauslese),
  QualifierPhrase(['beerenauslese'], Qualifier.beerenauslese),
  QualifierPhrase(['eiswein'], Qualifier.eiswein),
  QualifierPhrase(['icewine'], Qualifier.eiswein),
  QualifierPhrase(['ice', 'wine'], Qualifier.eiswein),
  QualifierPhrase(['auslese'], Qualifier.auslese),
  QualifierPhrase(['spatlese'], Qualifier.spatlese),
  QualifierPhrase(['kabinett'], Qualifier.kabinett),
  QualifierPhrase(['lbv'], Qualifier.lbv),
  QualifierPhrase(['colheita'], Qualifier.colheita),
  QualifierPhrase(['vintage'], Qualifier.vintage),
];

/// The priority of BR1.8, most specific first.
const List<Qualifier> qualifierPriority = [
  Qualifier.granSelezione,
  Qualifier.granReserva,
  Qualifier.grandCru,
  Qualifier.premierCru,
  Qualifier.riserva,
  Qualifier.reserva,
  Qualifier.crianza,
  Qualifier.superiore,
  Qualifier.trockenbeerenauslese,
  Qualifier.beerenauslese,
  Qualifier.eiswein,
  Qualifier.auslese,
  Qualifier.spatlese,
  Qualifier.kabinett,
  Qualifier.lbv,
  Qualifier.colheita,
  Qualifier.vintage,
];

/// The qualifiers that suggest the "aging" level (wine-style-profiles
/// BR4.4, replacing the list of label-autofill-windows BR1.8): "vintage"
/// only with Porto, checked by the callers. Reserva, Premier Cru, Spätlese
/// and Colheita no longer suggest it: their own offsets already lengthen
/// the window and the level is absolute (BR4.1).
const Set<Qualifier> agingQualifiers = {
  Qualifier.granSelezione,
  Qualifier.granReserva,
  Qualifier.grandCru,
  Qualifier.riserva,
  Qualifier.auslese,
  Qualifier.beerenauslese,
  Qualifier.trockenbeerenauslese,
  Qualifier.eiswein,
  Qualifier.vintage,
};

/// The qualifiers that mark a selection or a long ageing on a label:
/// they make a red "structured" and close a composed appellation
/// (label-autofill-windows BR1.8, BR7.16). Unchanged by wine-style-profiles,
/// which narrows only the level suggestion ([agingQualifiers]).
const Set<Qualifier> selectionQualifiers = {
  Qualifier.granSelezione,
  Qualifier.granReserva,
  Qualifier.grandCru,
  Qualifier.premierCru,
  Qualifier.riserva,
  Qualifier.reserva,
  Qualifier.auslese,
  Qualifier.beerenauslese,
  Qualifier.trockenbeerenauslese,
  Qualifier.eiswein,
  Qualifier.spatlese,
  Qualifier.vintage,
  Qualifier.colheita,
};

/// Whether [qualifier] suggests the "aging" level (BR4.4): one of
/// [agingQualifiers], "vintage" only for Porto ([denominationKey]).
bool suggestsAgingLevel(Qualifier? qualifier, String? denominationKey) {
  if (qualifier == null || !agingQualifiers.contains(qualifier)) return false;
  return qualifier != Qualifier.vintage || denominationKey == 'porto';
}

/// Bit mask (bit = [Qualifier.index]) of the qualifier phrases in [words],
/// skipping the [skipCount] words from [skipStart] (an alias).
int qualifierMaskOf(
  List<String> words, {
  int skipStart = 0,
  int skipCount = 0,
}) {
  var mask = 0;
  var i = 0;
  while (i < words.length) {
    if (i >= skipStart && i < skipStart + skipCount) {
      i++;
      continue;
    }
    final phrase = _phraseAt(words, i);
    if (phrase == null) {
      i++;
      continue;
    }
    mask |= 1 << phrase.qualifier.index;
    i += phrase.words.length;
  }
  return mask;
}

/// The qualifiers of [mask] in the order of [qualifierPriority].
List<Qualifier> qualifiersOf(int mask) => [
  for (final qualifier in qualifierPriority)
    if (mask & (1 << qualifier.index) != 0) qualifier,
];

QualifierPhrase? _phraseAt(List<String> words, int start) {
  for (final phrase in qualifierPhrases) {
    if (phrase.words.first != words[start]) continue;
    if (start + phrase.words.length > words.length) continue;
    var matches = true;
    for (var j = 1; j < phrase.words.length; j++) {
      if (words[start + j] != phrase.words[j]) {
        matches = false;
        break;
      }
    }
    if (matches) return phrase;
  }
  return null;
}
