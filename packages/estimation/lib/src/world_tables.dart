// The world tables of label-autofill-windows (D2, BR3.6, BR3.7,
// world-tables.md): the hand-written rows of every country, and the models
// that give a window to the rows generated from the official registers.
//
// Values are wine knowledge decided by the team (project.md correction of
// 2026-11-04); the reasons are next to each family and each model.

import 'europe_tables.dart';
import 'france_tables.dart';
import 'italy_tables.dart';
import 'models.dart';
import 'new_world_tables.dart';
import 'tables.dart';

typedef _Y = YearOffsets;

const _rl = WineType.redLight;
const _rs = WineType.redStructured;
const _w = WineType.white;
const _ro = WineType.rose;
const _spc = WineType.sparklingClassic;
const _spt = WineType.sparklingTank;
const _sw = WineType.sweet;
const _fo = WineType.fortified;

/// Every hand-written row outside the 47 Italian ones of tables.dart.
const List<DenominationProfile> worldDenominations = [
  ...italianWorldDenominations,
  ...frenchDenominations,
  ...europeanDenominations,
  ...newWorldDenominations,
];

/// Model keys of the generated rows (BR3.7).
abstract final class TemplateKeys {
  static const String italyDoc = 'IT-DOC';
  static const String italyIgt = 'IT-IGT';
  static const String franceAoc = 'FR-AOC';
  static const String franceIgp = 'FR-IGP';
  static const String iberia = 'ES-PT';
  static const String germanAustrian = 'DE-AT';
  static const String otherEu = 'EU';
  static const String newWorld = 'NEW-WORLD';
  static const String switzerland = 'CH';
}

/// The models of BR3.7: one window per type for a country and a level of
/// classification. A type missing from a model is a type the area does not
/// make; a generated row keeps only the types its model has.
///
/// Reasons (world-tables.md, "Motivazione dei modelli"):
/// - DOC, DOCG and AOC have lower yields and minimum ageing, so they last
///   longer than IGT and IGP;
/// - Germany and Austria: whites last longer thanks to the acidity of
///   Riesling and Grüner Veltliner;
/// - New World: riper wines, ready earlier;
/// - Switzerland: fresh wines, few long-ageing reds;
/// - every model has low confidence and the "Indicative" notice (BR3.4).
const Map<String, Map<WineType, YearOffsets>> appellationTemplates = {
  TemplateKeys.italyDoc: {
    _rl: _Y(1, 3, 6),
    _rs: _Y(4, 8, 15),
    _w: _Y(1, 2, 5),
    _ro: _Y(0, 1, 2),
    _spc: _Y(1, 3, 6),
    _spt: _Y(0, 1, 2),
    _sw: _Y(2, 6, 15),
    _fo: _Y(3, 10, 25),
  },
  TemplateKeys.italyIgt: {
    _rl: _Y(1, 2, 4),
    _rs: _Y(2, 4, 8),
    _w: _Y(0, 1, 3),
    _ro: _Y(0, 1, 2),
    _spt: _Y(0, 1, 2),
    _sw: _Y(1, 4, 10),
  },
  TemplateKeys.franceAoc: {
    _rl: _Y(2, 4, 8),
    _rs: _Y(4, 8, 15),
    _w: _Y(1, 3, 6),
    _ro: _Y(0, 1, 2),
    _spc: _Y(1, 3, 6),
    _spt: _Y(0, 1, 2),
    _sw: _Y(3, 10, 25),
    _fo: _Y(3, 10, 25),
  },
  TemplateKeys.franceIgp: {
    _rl: _Y(1, 2, 4),
    _rs: _Y(2, 4, 7),
    _w: _Y(0, 1, 3),
    _ro: _Y(0, 1, 2),
    _spt: _Y(0, 1, 2),
  },
  TemplateKeys.iberia: {
    _rl: _Y(1, 3, 6),
    _rs: _Y(3, 6, 12),
    _w: _Y(0, 2, 4),
    _ro: _Y(0, 1, 2),
    _spc: _Y(1, 2, 5),
    _spt: _Y(0, 1, 2),
    _sw: _Y(2, 6, 15),
    _fo: _Y(2, 10, 30),
  },
  TemplateKeys.germanAustrian: {
    _rl: _Y(2, 4, 8),
    _rs: _Y(3, 6, 12),
    _w: _Y(1, 4, 10),
    _ro: _Y(0, 1, 2),
    _spc: _Y(1, 3, 6),
    _spt: _Y(0, 1, 2),
    _sw: _Y(4, 10, 25),
  },
  TemplateKeys.otherEu: {
    _rl: _Y(1, 3, 6),
    _rs: _Y(3, 6, 12),
    _w: _Y(1, 2, 5),
    _ro: _Y(0, 1, 2),
    _spc: _Y(1, 2, 5),
    _spt: _Y(0, 1, 2),
    _sw: _Y(3, 10, 25),
  },
  TemplateKeys.newWorld: {
    _rl: _Y(1, 3, 6),
    _rs: _Y(3, 6, 12),
    _w: _Y(0, 2, 5),
    _ro: _Y(0, 1, 2),
    _spc: _Y(1, 3, 6),
    _spt: _Y(0, 1, 2),
    _sw: _Y(2, 6, 15),
    _fo: _Y(3, 10, 25),
  },
  TemplateKeys.switzerland: {
    _rl: _Y(1, 3, 6),
    _rs: _Y(3, 6, 10),
    _w: _Y(1, 2, 5),
    _ro: _Y(0, 1, 2),
    _spc: _Y(1, 2, 5),
  },
};

/// Types of a generated row whose register gives none (BR3.7): those of
/// the country's "IGP" model, light red, white and rosé.
const List<WineType> defaultGeneratedTypes = [_rl, _w, _ro];
