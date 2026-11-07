import 'package:estimation/estimation.dart';

/// Longest `matchKey` the rules accept (security-design.md §1).
const int maxMatchKeyLength = 400;

/// The duplicate key of a wine (BR1.4): normalized name, normalized producer
/// and vintage (`normalizeWineText` of C2: lower case, no accents, marks as
/// spaces), joined by `|`, at most [maxMatchKeyLength] characters. Pure.
///
/// "Barolo", "BAROLO" and "Barolo " of the same producer and vintage get the
/// same key; a missing producer or vintage is an empty part.
String matchKeyOf(String name, String? producer, int? vintage) {
  final key =
      '${normalizeWineText(name)}|${normalizeWineText(producer ?? '')}|'
      '${vintage ?? ''}';
  return key.length <= maxMatchKeyLength
      ? key
      : key.substring(0, maxMatchKeyLength);
}
