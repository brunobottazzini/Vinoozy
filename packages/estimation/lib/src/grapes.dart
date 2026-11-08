// Grape table of label-autofill-windows (FR3.2, ENT-004 `GrapeProfile`,
// world-tables.md "Vitigni"): the window of a grape variety, used when no
// denomination is recognised (BR3.1). A grape never gives a country or a
// region (BR1.7), and no grape alias is ever a denomination alias (BR3.2).
//
// Values are wine knowledge decided by the team (project.md correction of
// 2026-11-04): an average of the grape across the world, always with low
// confidence and the "Indicative" notice (BR3.4). Tannic reds (Cabernet,
// Nebbiolo, Aglianico, Tannat, Xinomavro) last longest; fruity reds
// (Gamay, Zweigelt) and aromatic whites (Sauvignon, Pinot Grigio, Glera)
// are drunk young; Riesling, Semillon and Chenin keep for years thanks to
// their acidity.

import 'models.dart';
import 'tables.dart';

typedef _Y = YearOffsets;

const _rl = WineType.redLight;
const _rs = WineType.redStructured;
const _w = WineType.white;
const _spt = WineType.sparklingTank;
const _sw = WineType.sweet;

/// One grape variety (ENT-004 `GrapeProfile`).
class GrapeProfile {
  const GrapeProfile(
    this.name,
    this.wineType,
    this.offsets, [
    this.aliases = const [],
  ]);

  /// Name shown to people ("Cabernet Sauvignon").
  final String name;
  final WineType wineType;
  final YearOffsets offsets;

  /// Normalised forms besides the name.
  final List<String> aliases;
}

/// The grapes keyed by a stable key (stored as `window.denominationKey` of
/// a grape estimate).
const Map<String, GrapeProfile> grapeTable = {
  'cabernetSauvignon': GrapeProfile('Cabernet Sauvignon', _rs, _Y(4, 8, 15), [
    'cabernet',
  ]),
  'merlot': GrapeProfile('Merlot', _rl, _Y(2, 5, 10)),
  'pinotNoir': GrapeProfile('Pinot Noir', _rl, _Y(2, 5, 10), [
    'pinot nero',
    'spatburgunder',
  ]),
  'syrah': GrapeProfile('Syrah', _rs, _Y(3, 6, 12), ['shiraz']),
  'malbec': GrapeProfile('Malbec', _rs, _Y(2, 5, 10)),
  'carmenere': GrapeProfile('Carménère', _rl, _Y(2, 4, 8)),
  'tempranillo': GrapeProfile('Tempranillo', _rs, _Y(3, 6, 12), [
    'tinta roriz',
    'tinto fino',
  ]),
  'grenache': GrapeProfile('Grenache', _rl, _Y(2, 4, 8), ['garnacha']),
  'zinfandel': GrapeProfile('Zinfandel', _rs, _Y(2, 5, 10)),
  'tannat': GrapeProfile('Tannat', _rs, _Y(4, 8, 15)),
  'nebbiolo': GrapeProfile('Nebbiolo', _rs, _Y(4, 8, 18)),
  'sangiovese': GrapeProfile('Sangiovese', _rl, _Y(2, 5, 10)),
  'barbera': GrapeProfile('Barbera', _rl, _Y(2, 4, 8)),
  'aglianico': GrapeProfile('Aglianico', _rs, _Y(5, 10, 20)),
  'montepulciano': GrapeProfile('Montepulciano', _rl, _Y(2, 4, 8)),
  'primitivo': GrapeProfile('Primitivo', _rs, _Y(2, 4, 8)),
  'nerodavola': GrapeProfile("Nero d'Avola", _rl, _Y(2, 4, 8)),
  'touriganacional': GrapeProfile('Touriga Nacional', _rs, _Y(3, 7, 15)),
  'xinomavro': GrapeProfile('Xinomavro', _rs, _Y(4, 8, 18)),
  'blaufrankisch': GrapeProfile('Blaufränkisch', _rl, _Y(2, 5, 10), [
    'lemberger',
    'kekfrankos',
  ]),
  'zweigelt': GrapeProfile('Zweigelt', _rl, _Y(1, 3, 6)),
  'pinotage': GrapeProfile('Pinotage', _rl, _Y(2, 5, 10)),
  'gamay': GrapeProfile('Gamay', _rl, _Y(0, 2, 4)),
  'cabernetFranc': GrapeProfile('Cabernet Franc', _rl, _Y(3, 6, 12)),
  'petitVerdot': GrapeProfile('Petit Verdot', _rs, _Y(4, 8, 15)),
  'mourvedre': GrapeProfile('Mourvèdre', _rs, _Y(3, 6, 12), ['monastrell']),
  'chardonnay': GrapeProfile('Chardonnay', _w, _Y(1, 3, 7)),
  'sauvignonBlanc': GrapeProfile('Sauvignon Blanc', _w, _Y(0, 2, 4), [
    'sauvignon',
  ]),
  'riesling': GrapeProfile('Riesling', _w, _Y(2, 6, 15)),
  'cheninBlanc': GrapeProfile('Chenin Blanc', _w, _Y(1, 4, 10)),
  'pinotGrigio': GrapeProfile('Pinot Grigio', _w, _Y(0, 2, 4), ['pinot gris']),
  'gewurztraminer': GrapeProfile('Gewürztraminer', _w, _Y(1, 3, 6), [
    'traminer',
  ]),
  'viognier': GrapeProfile('Viognier', _w, _Y(0, 2, 4)),
  'gruenerVeltliner': GrapeProfile('Grüner Veltliner', _w, _Y(1, 3, 8)),
  'albarino': GrapeProfile('Albariño', _w, _Y(0, 2, 4), ['alvarinho']),
  'semillon': GrapeProfile('Sémillon', _w, _Y(2, 6, 15)),
  'torrontes': GrapeProfile('Torrontés', _w, _Y(0, 1, 3)),
  'assyrtiko': GrapeProfile('Assyrtiko', _w, _Y(1, 4, 10)),
  'furmint': GrapeProfile('Furmint', _w, _Y(1, 4, 10)),
  'vermentino': GrapeProfile('Vermentino', _w, _Y(0, 2, 4)),
  'moscato': GrapeProfile('Moscato', _sw, _Y(0, 1, 3), ['muscat', 'moscatel']),
  'glera': GrapeProfile('Glera', _spt, _Y(0, 1, 2)),
  // Three Spanish grapes named alone on many labels (Rueda, Bierzo,
  // Valdeorras): Verdejo is a fresh white, Godello keeps a little longer,
  // Mencía is a light red.
  'verdejo': GrapeProfile('Verdejo', _w, _Y(0, 1, 3)),
  'godello': GrapeProfile('Godello', _w, _Y(1, 3, 6)),
  'mencia': GrapeProfile('Mencía', _rl, _Y(1, 3, 6)),
};
