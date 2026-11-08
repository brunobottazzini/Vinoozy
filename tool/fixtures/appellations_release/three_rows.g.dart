// Fixture of tool/check_appellations_release_test.sh: a table from the
// registers with 3 rows, which a manifest saying 2 rows must not describe.

/// Where the rows below come from.
const String generatedAppellationsSource =
    'eAmbrosia and official national registers';

/// Rows of the generated appellation table.
const List<String> generatedAppellationRows = [
  'barrealAR|Barreal|AR|San Juan|NEW-WORLD|redLight,white,rose||',
  'kumeuNZ|Kumeu|NZ||NEW-WORLD|redLight,white,rose||',
  'matakanaNZ|Matakana|NZ||NEW-WORLD|redLight,white,rose||',
];
