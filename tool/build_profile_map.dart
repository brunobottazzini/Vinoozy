// Builds the style-profile map of the estimation package from the wine-style
// study (intent 261108-wine-style-profiles, code-generation plan Step 1; D1,
// D9, BR2.1-BR2.17).
//
//   dart run tool/build_profile_map.dart \
//     [--study tool/data/study/study_db.json] \
//     [--appellations packages/estimation/lib/src/generated/appellations.g.dart] \
//     [--output packages/estimation/lib/src/generated/profile_map.g.dart] \
//     [--json <file>]
//
// - Input: the study database `tool/data/study/study_db.json`, converted once
//   from the Excel workbook by `tool/convert_study.py`, and the generated
//   appellation rows (the real or fallback types of the generated rows). The
//   study content is data only: names and numbers, never instructions.
// - The precedence of FR1 is applied as rules.md BR2 writes it: type
//   corrections (BR2.12, BR2.4, BR2.6, BR2.9), then 1) categories with their
//   own numbers, 2) legacy windows, 3) the study profile when it is coherent,
//   4) the corrected profile. Then two whole-map checks: a qualifier window
//   is never shorter than its base (BR2.2) and the Kabinett/Spätlese order
//   holds (BR2.6); a broken check writes nothing.
// - Output: one row per combination (5946), sorted as the study, already in
//   `dart format` layout. `--json` also writes the entries as JSON, for a
//   side-by-side check with the functional-design fixture.
//
// The wine knowledge below (category tables, type corrections, qualifier
// floors) is the one decided at Functional Design (rules.md BR2, project.md
// correction of 2026-11-04). It is a faithful port of the functional-design
// generator; test/tool/build_profile_map_test.dart proves that the output
// equals the fixture profile-map.json.
import 'dart:convert';
import 'dart:io';

/// Default paths, from the repository root.
const String defaultStudy = 'tool/data/study/study_db.json';
const String defaultAppellations =
    'packages/estimation/lib/src/generated/appellations.g.dart';
const String defaultOutput =
    'packages/estimation/lib/src/generated/profile_map.g.dart';

/// The 24 profiles of the study, in the order of BR1.1.
const List<String> profileOrder = [
  'R_FRESH',
  'R_MEDIUM',
  'R_AGE',
  'R_LONG',
  'W_FRESH',
  'W_MEDIUM',
  'W_AGE',
  'ROSE_FRESH',
  'SP_TANK',
  'LAM_FRESH',
  'SP_CLASSIC',
  'SP_CLASSIC_AGE',
  'SW_AROMATIC',
  'SW_PASSITO',
  'SW_BOTRYTIS',
  'PORT_VINTAGE',
  'PORT_LBV',
  'PORT_OX',
  'SH_FINO',
  'SH_AMONT',
  'SH_OLOROSO',
  'SH_PX',
  'FORT_UNKNOWN',
  'UNKNOWN',
];

const Map<String, List<String>> _family = {
  'red': ['R_FRESH', 'R_MEDIUM', 'R_AGE', 'R_LONG'],
  'white': ['W_FRESH', 'W_MEDIUM', 'W_AGE'],
  'rose': ['ROSE_FRESH'],
};

const Map<String, String> _familyOfType = {
  'redLight': 'red',
  'redStructured': 'red',
  'white': 'white',
  'rose': 'rose',
};

/// BR5.6: the profile of a type when the style is not known.
const Map<String, String> typeDefaultProfile = {
  'redLight': 'R_FRESH',
  'redStructured': 'R_MEDIUM',
  'white': 'W_MEDIUM',
  'rose': 'ROSE_FRESH',
  'sparklingClassic': 'SP_CLASSIC',
  'sparklingTank': 'SP_TANK',
  'sweet': 'UNKNOWN',
  'fortified': 'FORT_UNKNOWN',
};

/// BR2.5: the sweet category of each dedicated sweet row.
const Map<String, String> _sweet = {
  'asti': 'SW_AROMATIC',
  'brachettoDAcqui': 'SW_AROMATIC',
  'canelli': 'SW_AROMATIC',
  'malvasiaDiCastelnuovoDonBosco': 'SW_AROMATIC',
  'sangueDiGiuda': 'SW_AROMATIC',
  'colliEuganeiFiorDArancio': 'SW_AROMATIC',
  'cannellinoDiFrascati': 'SW_AROMATIC',
  'muscatDeBeaumesDeVenise': 'SW_AROMATIC',
  'muscatDeRivesaltes': 'SW_AROMATIC',
  'samos': 'SW_AROMATIC',
  'kindzmarauli': 'SW_AROMATIC',
  'khvanchkara': 'SW_AROMATIC',
  'reciotoDellaValpolicella': 'SW_PASSITO',
  'passitoDiPantelleria': 'SW_PASSITO',
  'vinSanto': 'SW_PASSITO',
  'loazzolo': 'SW_PASSITO',
  'calusoPassito': 'SW_PASSITO',
  'moscatoDiScanzo': 'SW_PASSITO',
  'reciotoDiGambellara': 'SW_PASSITO',
  'reciotoDiSoave': 'SW_PASSITO',
  'breganzeTorcolato': 'SW_PASSITO',
  'colliOrientaliDelFriuliPicolit': 'SW_PASSITO',
  'ramandolo': 'SW_PASSITO',
  'romagnaAlbana': 'SW_PASSITO',
  'aleaticoPassitoDellElba': 'SW_PASSITO',
  'primitivoDiManduriaDolceNaturale': 'SW_PASSITO',
  'grecoDiBianco': 'SW_PASSITO',
  'malvasiaDelleLipari': 'SW_PASSITO',
  'cinqueTerreSciacchetra': 'SW_PASSITO',
  'alsaceVendangesTardives': 'SW_PASSITO',
  'jurancon': 'SW_PASSITO',
  'malaga': 'SW_PASSITO',
  'niagaraPeninsula': 'SW_PASSITO',
  'vinDeConstance': 'SW_PASSITO',
  'sauternes': 'SW_BOTRYTIS',
  'barsac': 'SW_BOTRYTIS',
  'loupiac': 'SW_BOTRYTIS',
  'sainteCroixDuMont': 'SW_BOTRYTIS',
  'cerons': 'SW_BOTRYTIS',
  'cadillac': 'SW_BOTRYTIS',
  'vouvray': 'SW_BOTRYTIS',
  'montlouisSurLoire': 'SW_BOTRYTIS',
  'coteauxDuLayon': 'SW_BOTRYTIS',
  'quartsDeChaume': 'SW_BOTRYTIS',
  'bonnezeaux': 'SW_BOTRYTIS',
  'coteauxDeLAubance': 'SW_BOTRYTIS',
  'alsaceSelectionDeGrainsNobles': 'SW_BOTRYTIS',
  'monbazillac': 'SW_BOTRYTIS',
  'neusiedlersee': 'SW_BOTRYTIS',
  'rusterAusbruch': 'SW_BOTRYTIS',
  'tokaji': 'SW_BOTRYTIS',
};

/// BR2.9: sweet-typed rows that are fortified wines.
const Set<String> _sweetToFortified = {
  'rasteau',
  'moscatelDeSetubal',
  'moscatelDoDouro',
};

const Set<String> _sherry = {'jerez', 'montillaMoriles'};

const Map<String?, String> _portByQualifier = {
  null: 'PORT_OX',
  'vintage': 'PORT_VINTAGE',
  'lbv': 'PORT_LBV',
  'colheita': 'PORT_OX',
};

const Set<String> _lambruscoKeys = {'lambrusco'};

/// One type correction of BR2.12: the types the row really makes (main
/// first), its profile and whether the style stays to confirm.
class TypeFix {
  const TypeFix(this.types, this.profile, {this.toConfirm = false});

  final List<String> types;
  final String profile;
  final bool toConfirm;
}

/// BR2.12, BR2.5, BR2.9: wrong or fake types of the rows, corrected.
const Map<String, TypeFix> typeFixes = {
  'castelliDiJesiVerdicchioRiservaIT': TypeFix(['white'], 'W_AGE'),
  'cabernetDeSaumurFR': TypeFix(['rose'], 'ROSE_FRESH'),
  'couleeDeSerrantFR': TypeFix(['white'], 'W_AGE'),
  'courChevernyFR': TypeFix(['white'], 'W_MEDIUM'),
  'arabakoTxakolinaES': TypeFix(['white', 'rose', 'redLight'], 'W_FRESH'),
  'bizkaikoTxakolinaES': TypeFix(['white', 'rose', 'redLight'], 'W_FRESH'),
  'moscatoDiTraniIT': TypeFix(['sweet'], 'SW_PASSITO'),
  'setubalPT': TypeFix(['fortified'], 'FORT_UNKNOWN'),
  'muscatDeFrontignanFR': TypeFix(['sweet'], 'SW_AROMATIC'),
  'muscatDeLunelFR': TypeFix(['sweet'], 'SW_AROMATIC'),
  'muscatDeMirevalFR': TypeFix(['sweet'], 'SW_AROMATIC'),
  'muscatDeSaintJeanDeMinervoisFR': TypeFix(['sweet'], 'SW_AROMATIC'),
  'muscatDuCapCorseFR': TypeFix(['sweet'], 'SW_AROMATIC'),
  'malvasiaHandakasCandiaGR': TypeFix(['sweet'], 'SW_PASSITO'),
  'malvasiaParosGR': TypeFix(['sweet'], 'SW_PASSITO'),
  'malvasiaSitiaGR': TypeFix(['sweet'], 'SW_PASSITO'),
  'monemvasiaMalvasiaGR': TypeFix(['sweet'], 'SW_PASSITO'),
  'mavrodafniKefalliniasGR': TypeFix(['fortified'], 'FORT_UNKNOWN'),
  'aleaticoDiGradoliIT': TypeFix(['sweet'], 'SW_PASSITO'),
  'aleaticoDiPugliaIT': TypeFix(['sweet'], 'SW_PASSITO'),
  'malvasiaDiCasorzoDAstiIT': TypeFix(['sweet'], 'SW_AROMATIC'),
  'moscatoDiSardegnaIT': TypeFix(['sweet'], 'SW_AROMATIC'),
  'moscatoDiSorsoIT': TypeFix(['sweet'], 'SW_PASSITO'),
  'pinotNeroDellOltrepoPaveseIT': TypeFix(
    ['redLight'],
    'R_FRESH',
    toConfirm: true,
  ),
  'corteseDellAltoMonferratoIT': TypeFix(
    ['white'],
    'W_MEDIUM',
    toConfirm: true,
  ),
  'ortrugoDeiColliPiacentiniIT': TypeFix(
    ['white'],
    'W_MEDIUM',
    toConfirm: true,
  ),
  'pineauDesCharentesFR': TypeFix(['fortified'], 'FORT_UNKNOWN'),
  'flocDeGascogneFR': TypeFix(['fortified'], 'FORT_UNKNOWN'),
  'macvinDuJuraFR': TypeFix(['fortified'], 'FORT_UNKNOWN'),
  'grandRoussillonFR': TypeFix(['fortified'], 'FORT_UNKNOWN'),
  'picpoulDePinetFR': TypeFix(['white'], 'W_FRESH'),
  'roussetteDeSavoieFR': TypeFix(['white'], 'W_MEDIUM'),
  'roussetteDuBugeyFR': TypeFix(['white'], 'W_MEDIUM'),
  'clairetteDuLanguedocFR': TypeFix(['white'], 'W_MEDIUM', toConfirm: true),
  'clairetteDeBellegardeFR': TypeFix(['white'], 'W_MEDIUM', toConfirm: true),
  'koumandariaCY': TypeFix(['sweet'], 'SW_PASSITO'),
  'reggianoIT': TypeFix(['sparklingTank'], 'LAM_FRESH'),
  'modenaIT': TypeFix(['sparklingTank'], 'LAM_FRESH'),
};

/// BR2.12: every generated Retsina row is a resinated white (or rosé).
const TypeFix retsinaFix = TypeFix(['white', 'rose'], 'W_FRESH');

/// BR2.13: Revision-60 dedicated keys whose proposal is "legacy invariato".
const Set<String> _reviewLegacy = {
  'barolo',
  'barbaresco',
  'brunelloDiMontalcino',
  'chiantiClassico',
  'soave',
  'chablis',
  'pauillac',
  'vinhoVerde',
  'sauternes',
};

/// BR2.13: Revision-60 dedicated keys whose base is UNKNOWN.
const Set<String> _reviewUnknownDedicated = {
  'bordeauxRouge',
  'mosel',
  'rheingau',
  'wachau',
  'kamptal',
  'napaValley',
  'hunterValley',
  'marlborough',
};

/// Keys whose study action keeps the other colours as legacy (Bordeaux).
const Set<String> _reviewUnknownKeepOtherTypes = {'bordeauxRouge'};

/// BR2.13: Revision-60 rows with a numeric conditional candidate.
const Set<String> _reviewCandidate = {'muscadet', 'rioja', 'barossaValley'};

/// BR2.10: qualifier variants whose increment the study disables.
const Set<String> _qualifierDisabled = {'soave:superiore'};

/// BR2.10: study actions not followed, for consistency (Pauillac).
const Set<String> _actionOverridden = {'pauillac:grandCru'};

/// BR2.12: generated rows that duplicate a dedicated combination.
const Map<String, String> _mirror = {
  'castelliDiJesiVerdicchioRiservaIT':
      'verdicchioDeiCastelliDiJesi:qualifier:riserva',
};

const Set<String> _redAgeQualifiers = {
  'riserva',
  'reserva',
  'granReserva',
  'granSelezione',
  'grandCru',
  'premierCru',
};
const Set<String> _whiteAgeQualifiers = {..._redAgeQualifiers, 'spatlese'};
const Set<String> _sparklingAgeQualifiers = {
  'riserva',
  'granReserva',
  'vintage',
};
const Map<String, String> _sweetPradikat = {'auslese': 'SW_BOTRYTIS'};

/// BR4.4: qualifiers that preselect the "aging" level.
const Set<String> _agingQualifiers = {
  'riserva',
  'granReserva',
  'grandCru',
  'granSelezione',
  'auslese',
  'beerenauslese',
  'trockenbeerenauslese',
  'eiswein',
};

/// BR4.3: fresh profiles that preselect "everyday" without a qualifier.
const Set<String> _freshProfiles = {
  'R_FRESH',
  'W_FRESH',
  'ROSE_FRESH',
  'SW_AROMATIC',
  'SP_TANK',
  'LAM_FRESH',
};

/// The fake types of a generated row without a type in the register.
const List<String> fallbackTypes = ['redLight', 'white', 'rose'];

/// One profile of the study ("Profili candidati").
class StudyProfile {
  const StudyProfile({
    required this.id,
    required this.anchor,
    required this.unit,
    required this.start,
    required this.peak,
    required this.end,
  });

  final String id;
  final String? anchor;
  final String? unit;
  final int? start;
  final int? peak;
  final int? end;
}

/// One combination of the study ("Mappa completa").
class StudyRow {
  const StudyRow({
    required this.id,
    required this.key,
    required this.origin,
    required this.variant,
    required this.studyType,
    required this.qualifier,
    required this.legacy,
    required this.studyProfile,
    required this.scope,
    required this.action,
    required this.template,
  });

  final String id;
  final String key;
  final String origin;
  final String variant;
  final String studyType;
  final String? qualifier;
  final List<int> legacy;
  final String studyProfile;
  final String scope;
  final String action;
  final String? template;

  bool get generated => origin == 'generata';
}

/// The study database read from `study_db.json`.
class Study {
  Study({
    required this.version,
    required this.profiles,
    required this.rows,
    required this.reviewedKeys,
    required this.typeWindows,
  });

  /// Reads the database written by `tool/convert_study.py`.
  factory Study.fromJson(Map<String, Object?> json) {
    final study = json['study']! as Map<String, Object?>;
    final profiles = <String, StudyProfile>{};
    for (final row in _rowsOf(json, 'profiles')) {
      final id = row['ID profilo']! as String;
      if (!profileOrder.contains(id)) continue;
      String? none(Object? v) => v == 'none' ? null : v as String?;
      profiles[id] = StudyProfile(
        id: id,
        anchor: none(row['Decorrenza']),
        unit: none(row['Unità']),
        start: row['Start'] as int?,
        peak: row['Peak'] as int?,
        end: row['End'] as int?,
      );
    }
    if (profiles.keys.join(',') != profileOrder.join(',')) {
      throw StateError('profiles: ${profiles.keys}');
    }
    final rows = [
      for (final row in _rowsOf(json, 'combinations'))
        StudyRow(
          id: row['ID combinazione']! as String,
          key: row['Chiave denominazione']! as String,
          origin: row['Origine']! as String,
          variant: row['Variante']! as String,
          studyType: row['Tipo v2']! as String,
          qualifier: _orNull(row['Qualifica v2'] as String?),
          legacy: [
            row['Start v2']! as int,
            row['Peak v2']! as int,
            row['End v2']! as int,
          ],
          studyProfile: row['Profilo candidato']! as String,
          scope: row['Ambito candidato']! as String,
          action: row['Azione proposta']! as String,
          template: _orNull(row['Modello v2'] as String?),
        ),
    ];
    final reviewed = {
      for (final row in _rowsOf(json, 'review60'))
        if ((row['Chiave'] as String?)?.isNotEmpty ?? false)
          row['Chiave']! as String,
    };
    final typeWindows = <String, List<int>>{
      for (final row in _rowsOf(json, 'grapesAndTypes'))
        if (row['Categoria'] == 'tipo')
          row['Chiave']! as String: [
            row['Start v2']! as int,
            row['Peak v2']! as int,
            row['End v2']! as int,
          ],
    };
    return Study(
      version: '${study['version']}',
      profiles: profiles,
      rows: rows,
      reviewedKeys: reviewed,
      typeWindows: typeWindows,
    );
  }

  final String version;
  final Map<String, StudyProfile> profiles;
  final List<StudyRow> rows;
  final Set<String> reviewedKeys;

  /// Today's windows of the types and of the generic row ("Vitigni e tipi").
  final Map<String, List<int>> typeWindows;
}

String? _orNull(String? value) =>
    value == null || value.isEmpty || value == '—' ? null : value;

List<Map<String, Object?>> _rowsOf(Map<String, Object?> json, String sheet) {
  final table = json[sheet]! as Map<String, Object?>;
  final columns = (table['columns']! as List).cast<String>();
  return [
    for (final row in table['rows']! as List)
      {for (var i = 0; i < columns.length; i++) columns[i]: (row as List)[i]},
  ];
}

/// The real or fallback types of each generated row, read from the
/// generated appellation table (`key|name|country|region|model|types|...`).
Map<String, List<String>> generatedTypesOf(String source) {
  final pattern = RegExp(
    r"^[ \t]*'([^|\n]+)\|([^|\n]*)\|([^|\n]*)\|([^|\n]*)\|([^|\n]*)\|([^|\n]*)\|",
    multiLine: true,
  );
  return {
    for (final match in pattern.allMatches(source))
      match.group(1)!: match.group(6)!.split(','),
  };
}

/// One decided combination (a row of profile-map.json).
class ProfileMapEntry {
  ProfileMapEntry({
    required this.id,
    required this.key,
    required this.variant,
    required this.qualifier,
    required this.studyProfile,
    required this.template,
  });

  final String id;
  final String key;
  final String variant;
  final String? qualifier;
  final String studyProfile;
  final String? template;

  String? type;
  bool typeCorrected = false;
  bool rowMakesType = true;
  String profile = 'UNKNOWN';
  int step = 0;
  String estimate = 'profiled';
  String? anchor;
  String? unit;
  int? start;
  int? peak;
  int? end;
  String presetLevel = 'good';
  bool styleToConfirm = false;
  String? deviationCode;

  /// BR4.1: the level changes only year windows with a peak and an end.
  bool get levelApplies => unit == 'years' && peak != null && end != null;

  /// The row of the generated Dart table:
  /// `id|type|profile|step|estimate|anchor|unit|start|peak|end|flags|level`,
  /// flags `c` (style to confirm), `n` (the row does not make the type),
  /// `t` (type corrected).
  String toRow() {
    final flags = [
      if (styleToConfirm) 'c',
      if (!rowMakesType) 'n',
      if (typeCorrected) 't',
    ].join();
    String text(Object? value) => value == null ? '' : '$value';
    return [
      id,
      text(type),
      profile,
      step,
      estimate,
      text(anchor),
      text(unit),
      text(start),
      text(peak),
      text(end),
      flags,
      presetLevel,
    ].join('|');
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'key': key,
    'variant': variant,
    'qualifier': qualifier,
    'type': type,
    'typeCorrected': typeCorrected,
    'rowMakesType': rowMakesType,
    'profile': profile,
    'step': step,
    'estimate': estimate,
    'anchor': anchor,
    'unit': unit,
    'start': start,
    'peak': peak,
    'end': end,
    'levelApplies': levelApplies,
    'presetLevel': presetLevel,
    'styleToConfirm': styleToConfirm,
    'deviationCode': deviationCode,
  };
}

/// Applies BR2 to every combination of [study]. [generatedTypes] are the
/// types of the generated appellation rows. Throws [StateError] when a
/// whole-map check fails (then nothing must be written).
List<ProfileMapEntry> buildProfileMap(
  Study study,
  Map<String, List<String>> generatedTypes,
) => _MapBuilder(study, generatedTypes).build();

class _MapBuilder {
  _MapBuilder(this.study, this.generatedTypes);

  final Study study;
  final Map<String, List<String>> generatedTypes;
  final Map<String, String> _baseLabel = {};

  List<int> get _generic => study.typeWindows['generic']!;

  List<ProfileMapEntry> build() {
    final rows = study.rows;
    final order = List.generate(rows.length, (i) => i)
      ..sort((a, b) {
        final byBase = (rows[a].variant != 'base' ? 1 : 0).compareTo(
          rows[b].variant != 'base' ? 1 : 0,
        );
        return byBase != 0 ? byBase : a.compareTo(b);
      });
    final decided = <int, ProfileMapEntry>{};
    for (final i in order) {
      decided[i] = _decide(rows[i]);
    }
    final entries = [for (var i = 0; i < rows.length; i++) decided[i]!];
    final byId = {for (final e in entries) e.id: e};
    _applyMirrors(entries, byId);
    _raiseQualifiersToBase(entries);
    _checkPradikatOrder(entries, byId);
    _checkWindows(entries);
    return entries;
  }

  StudyProfile _p(String id) => study.profiles[id]!;

  List<int> _values(String id) {
    final p = _p(id);
    return [p.start!, p.peak!, p.end!];
  }

  static int _dist(List<int> a, List<int> b) =>
      (a[0] - b[0]).abs() + (a[1] - b[1]).abs() + (a[2] - b[2]).abs();

  String _nearest(String family, List<int> window) {
    String? best;
    var bestDistance = 0;
    for (final id in _family[family]!) {
      final d = _dist(_values(id), window);
      if (best == null || d < bestDistance) {
        best = id;
        bestDistance = d;
      }
    }
    return best!;
  }

  static String _atLeast(String family, String id, String floor) {
    final order = _family[family]!;
    final index = order.indexOf(id) > order.indexOf(floor)
        ? order.indexOf(id)
        : order.indexOf(floor);
    return order[index];
  }

  String _coherentStill(
    String type,
    String? qualifier,
    List<int> window, [
    String? baseLabel,
  ]) {
    final family = _familyOfType[type]!;
    var id = _nearest(family, window);
    if (family == 'white') {
      if (_whiteAgeQualifiers.contains(qualifier)) {
        id = _atLeast(family, id, 'W_AGE');
      } else if (qualifier == 'kabinett') {
        return 'W_MEDIUM';
      }
    }
    if (family == 'red') {
      if (_redAgeQualifiers.contains(qualifier)) {
        id = _atLeast(family, id, 'R_AGE');
      } else if (qualifier == 'crianza') {
        id = _atLeast(family, id, 'R_MEDIUM');
      }
    }
    if (baseLabel != null && _family[family]!.contains(baseLabel)) {
      id = _atLeast(family, id, baseLabel);
    }
    return id;
  }

  static bool _studyLabelOk(
    String type,
    String? qualifier,
    String id, [
    String? baseLabel,
  ]) {
    final family = _familyOfType[type];
    if (family == null || !_family[family]!.contains(id)) return false;
    final order = _family[family]!;
    if (family == 'white' &&
        _whiteAgeQualifiers.contains(qualifier) &&
        order.indexOf(id) < order.indexOf('W_AGE')) {
      return false;
    }
    if (family == 'red' &&
        _redAgeQualifiers.contains(qualifier) &&
        order.indexOf(id) < order.indexOf('R_AGE')) {
      return false;
    }
    if (baseLabel != null &&
        order.contains(baseLabel) &&
        order.indexOf(id) < order.indexOf(baseLabel)) {
      return false;
    }
    return true;
  }

  static String _actionClass(String action) {
    if (action.startsWith('Conservare identità')) return 'identity';
    if (action.startsWith('Conservare valore legacy')) return 'legacy';
    return 'review';
  }

  static String _presetLevel(
    String profile,
    String? qualifier,
    String key,
    String? template,
  ) {
    if (_agingQualifiers.contains(qualifier) ||
        (qualifier == 'vintage' && key == 'porto')) {
      return 'aging';
    }
    if (profile == 'SP_TANK' || profile == 'LAM_FRESH') return 'everyday';
    if (_freshProfiles.contains(profile) && qualifier == null) {
      return 'everyday';
    }
    if (template == 'IT-IGT' || template == 'FR-IGP') return 'everyday';
    return 'good';
  }

  /// Window fields: the profile's numbers, or [legacy] year values from the
  /// vintage, or no window at all ([none]).
  void _window(
    ProfileMapEntry e,
    String profile, {
    List<int>? legacy,
    bool none = false,
  }) {
    if (none) {
      e
        ..anchor = null
        ..unit = null
        ..start = null
        ..peak = null
        ..end = null;
      return;
    }
    if (legacy != null) {
      e
        ..anchor = 'vintage'
        ..unit = 'years'
        ..start = legacy[0]
        ..peak = legacy[1]
        ..end = legacy[2];
      return;
    }
    final p = _p(profile);
    e
      ..anchor = p.anchor
      ..unit = p.unit
      ..start = p.start
      ..peak = p.peak
      ..end = p.end;
  }

  ProfileMapEntry _finish(
    ProfileMapEntry e, {
    required String? type,
    required bool typeCorrected,
    required bool makes,
    required String profile,
    required int step,
    required String estimate,
    List<int>? legacy,
    bool none = false,
    bool toConfirm = false,
    String? code,
  }) {
    e
      ..type = type
      ..typeCorrected = typeCorrected
      ..rowMakesType = makes
      ..profile = profile
      ..step = step
      ..estimate = estimate;
    _window(e, profile, legacy: legacy, none: none);
    e
      ..presetLevel = _presetLevel(profile, e.qualifier, e.key, e.template)
      ..styleToConfirm =
          toConfirm || profile == 'UNKNOWN' || profile == 'FORT_UNKNOWN';
    if (code == null && profile != e.studyProfile) code = 'PROFILE_CHANGED';
    if (code == null && typeCorrected) code = 'TYPE_FIX';
    e.deviationCode = code;
    return e;
  }

  bool _hasManyStyles(String type) =>
      _familyOfType.containsKey(type) &&
      _family[_familyOfType[type]]!.length > 1;

  ProfileMapEntry _decide(StudyRow r) {
    final key = r.key;
    final variant = r.variant;
    final stype = r.studyType;
    final qual = r.qualifier;
    final legacy = r.legacy;
    final sprof = r.studyProfile;
    final act = _actionClass(r.action);
    final generated = r.generated;
    final reviewed = r.scope.startsWith('Solo ipotesi');
    final e = ProfileMapEntry(
      id: r.id,
      key: key,
      variant: variant,
      qualifier: qual,
      studyProfile: sprof,
      template: r.template,
    );

    var type = stype;
    var typeCorrected = false;
    var makes = true;

    // ---- type corrections (BR2.12, BR2.4, BR2.6, BR2.9) ----
    var fix = typeFixes[key];
    if (generated && key.startsWith('retsina')) fix = retsinaFix;
    if (fix != null) {
      if (variant == 'base' || variant == 'qualifier') {
        type = fix.types.first;
      } else if (fix.types.contains(stype)) {
        type = stype;
      } else {
        makes = false;
      }
      if (type != stype) typeCorrected = true;
    }
    if (_sweetToFortified.contains(key) && stype == 'sweet') {
      type = 'fortified';
      typeCorrected = true;
    }
    if (_lambruscoKeys.contains(key)) {
      type = 'sparklingTank';
      typeCorrected = true;
    }
    if (_sweetPradikat.containsKey(qual) && stype == 'white') {
      type = 'sweet';
      typeCorrected = true;
    }

    // ---- 0. the row does not make the type (BR2.12) ----
    if (!makes) {
      final pid = typeDefaultProfile[stype]!;
      if (pid == 'UNKNOWN') {
        return _finish(
          e,
          type: type,
          typeCorrected: typeCorrected,
          makes: false,
          profile: pid,
          step: 4,
          estimate: 'indicative',
          legacy: study.typeWindows[stype],
          toConfirm: _hasManyStyles(stype),
          code: 'TYPE_NOT_MADE',
        );
      }
      return _finish(
        e,
        type: type,
        typeCorrected: typeCorrected,
        makes: false,
        profile: pid,
        step: 4,
        estimate: pid == 'FORT_UNKNOWN' ? 'none' : 'profiled',
        none: pid == 'FORT_UNKNOWN',
        toConfirm: _hasManyStyles(stype),
        code: 'TYPE_NOT_MADE',
      );
    }

    // ---- 1. categories with the study's own numbers (BR2.3-BR2.8) ----
    String? category;
    String? code;
    if (type == 'sparklingClassic') {
      category = _sparklingAgeQualifiers.contains(qual)
          ? 'SP_CLASSIC_AGE'
          : 'SP_CLASSIC';
      if (category != sprof) code = 'SPARKLING_AGE';
    } else if (type == 'sparklingTank') {
      category = (_lambruscoKeys.contains(key) || fix?.profile == 'LAM_FRESH')
          ? 'LAM_FRESH'
          : 'SP_TANK';
    } else if (type == 'sweet') {
      if (_sweetPradikat.containsKey(qual)) {
        category = _sweetPradikat[qual];
        code = 'PRADIKAT';
      } else if (fix != null) {
        category = fix.profile;
      } else {
        category = _sweet[key];
        if (category == null) {
          throw StateError('sweet row without a decision: $key');
        }
        if (category != sprof) code = 'SWEET_CATEGORY';
      }
    } else if (type == 'fortified' && key == 'porto') {
      category = _portByQualifier[qual];
      if (category != sprof) code = 'PORT_CATEGORY';
    } else if (type == 'fortified' && _sherry.contains(key)) {
      // BR2.8: no style word in a map combination.
      return _finish(
        e,
        type: type,
        typeCorrected: false,
        makes: true,
        profile: 'FORT_UNKNOWN',
        step: 2,
        estimate: 'indicative',
        legacy: legacy,
        toConfirm: true,
        code: 'SHERRY_NO_STYLE',
      );
    }
    if (category != null) {
      // BR2.5, R-09: botrytised wines of dedicated legacy rows keep today's
      // window.
      if (category == 'SW_BOTRYTIS' &&
          !generated &&
          !_sweetPradikat.containsKey(qual) &&
          (act == 'legacy' || _reviewLegacy.contains(key))) {
        return _finish(
          e,
          type: type,
          typeCorrected: false,
          makes: true,
          profile: category,
          step: 2,
          estimate: 'profiled',
          legacy: legacy,
          code: code,
        );
      }
      final step = (fix != null && typeCorrected) ? 4 : 1;
      if (fix != null && typeCorrected && code == null) code = 'TYPE_FIX';
      return _finish(
        e,
        type: type,
        typeCorrected: typeCorrected,
        makes: true,
        profile: category,
        step: step,
        estimate: 'profiled',
        code: code,
      );
    }

    // ---- generated rows: the row never knows the style (BR2.11) ----
    if (generated) return _decideGenerated(e, r, type, typeCorrected, fix);
    return _decideDedicated(e, r, type, typeCorrected, act, reviewed);
  }

  ProfileMapEntry _decideGenerated(
    ProfileMapEntry e,
    StudyRow r,
    String type,
    bool typeCorrected,
    TypeFix? fix,
  ) {
    final sprof = r.studyProfile;
    if (fix != null) {
      var pid = fix.profile;
      var toConfirm = fix.toConfirm;
      if (type != fix.types.first) {
        pid = typeDefaultProfile[type]!;
        toConfirm = _hasManyStyles(type);
      }
      if (pid == 'FORT_UNKNOWN') {
        return _finish(
          e,
          type: type,
          typeCorrected: typeCorrected,
          makes: true,
          profile: pid,
          step: 4,
          estimate: 'none',
          none: true,
          code: 'TYPE_FIX',
        );
      }
      final step = (pid == sprof && !typeCorrected) ? 3 : 4;
      final changed = pid != sprof || typeCorrected;
      return _finish(
        e,
        type: type,
        typeCorrected: typeCorrected,
        makes: true,
        profile: pid,
        step: step,
        estimate: 'profiled',
        toConfirm: toConfirm,
        code: changed ? 'TYPE_FIX' : null,
      );
    }
    final types = generatedTypes[r.key];
    final fallback =
        types != null && types.join(',') == fallbackTypes.join(',');
    if (type == 'fortified') {
      return _finish(
        e,
        type: type,
        typeCorrected: false,
        makes: true,
        profile: 'FORT_UNKNOWN',
        step: sprof == 'FORT_UNKNOWN' ? 3 : 4,
        estimate: 'none',
        none: true,
      );
    }
    if (fallback && r.variant == 'base') {
      final step = sprof == 'UNKNOWN' ? 3 : 4;
      return _finish(
        e,
        type: null,
        typeCorrected: false,
        makes: true,
        profile: 'UNKNOWN',
        step: step,
        estimate: 'indicative',
        legacy: _generic,
        toConfirm: true,
        code: step == 3 ? null : 'FAKE_TYPE',
      );
    }
    final pid = typeDefaultProfile[type]!;
    final step = pid == sprof ? 3 : 4;
    return _finish(
      e,
      type: type,
      typeCorrected: false,
      makes: true,
      profile: pid,
      step: step,
      estimate: 'profiled',
      toConfirm: _hasManyStyles(type),
      code: step == 4 ? 'GENERATED_STYLE' : null,
    );
  }

  ProfileMapEntry _decideDedicated(
    ProfileMapEntry e,
    StudyRow r,
    String type,
    bool typeCorrected,
    String act,
    bool reviewed,
  ) {
    final key = r.key;
    final qual = r.qualifier;
    final legacy = r.legacy;
    final sprof = r.studyProfile;
    final isReviewKey = study.reviewedKeys.contains(key);
    var legacyWindow = legacy;
    final disabled = _qualifierDisabled.contains('$key:$qual');
    if (disabled) {
      final base = study.rows.firstWhere(
        (x) => x.key == key && x.variant == 'base',
      );
      legacyWindow = base.legacy;
    }

    if (_reviewUnknownDedicated.contains(key)) {
      if (r.variant == 'base') {
        return _finish(
          e,
          type: type,
          typeCorrected: false,
          makes: true,
          profile: 'UNKNOWN',
          step: 3,
          estimate: 'indicative',
          legacy: legacy,
          toConfirm: true,
        );
      }
      if (_reviewUnknownKeepOtherTypes.contains(key)) {
        final pid = _coherentStill(type, qual, legacy);
        return _finish(
          e,
          type: type,
          typeCorrected: false,
          makes: true,
          profile: pid,
          step: 2,
          estimate: 'profiled',
          legacy: legacy,
          code: pid == sprof ? null : 'LABEL_NEAREST',
        );
      }
      if (qual == 'kabinett' || qual == 'spatlese') {
        // R-06: Kabinett W_MEDIUM, Spätlese W_AGE, today's windows kept.
        final pid = _coherentStill(type, qual, legacy);
        return _finish(
          e,
          type: type,
          typeCorrected: false,
          makes: true,
          profile: pid,
          step: 2,
          estimate: 'profiled',
          legacy: legacy,
          code: 'PRADIKAT_STILL',
        );
      }
      final pid = _coherentStill(type, qual, legacy);
      final step = pid == sprof ? 3 : 4;
      return _finish(
        e,
        type: type,
        typeCorrected: false,
        makes: true,
        profile: pid,
        step: step,
        estimate: 'profiled',
        toConfirm: qual == null,
        code: step == 3 ? null : 'CONTRADICTION',
      );
    }

    if (type == 'fortified') {
      // Madeira: the study withdraws its numbers (FR1.4): "Da stimare".
      if (act == 'review') {
        return _finish(
          e,
          type: type,
          typeCorrected: false,
          makes: true,
          profile: 'FORT_UNKNOWN',
          step: 3,
          estimate: 'none',
          none: true,
        );
      }
      return _finish(
        e,
        type: type,
        typeCorrected: typeCorrected,
        makes: true,
        profile: 'FORT_UNKNOWN',
        step: 2,
        estimate: 'indicative',
        legacy: legacy,
        code: typeCorrected ? 'TYPE_FIX' : null,
      );
    }

    final legacyAction =
        act == 'legacy' || (isReviewKey && _reviewLegacy.contains(key));
    final family = _familyOfType[type]!;
    final baseLabel = r.variant == 'qualifier'
        ? _baseLabel['$key:$type']
        : null;
    if (legacyAction) {
      final pid = reviewed && _studyLabelOk(type, qual, sprof, baseLabel)
          ? sprof
          : _coherentStill(type, qual, legacyWindow, baseLabel);
      if (r.variant == 'base') _baseLabel['$key:$type'] = pid;
      String? code;
      if (disabled) {
        code = 'QUALIFIER_DISABLED';
      } else if (_actionOverridden.contains('$key:$qual')) {
        code = 'ACTION_OVERRIDDEN';
      } else if (qual == 'kabinett' && pid != sprof) {
        code = 'PRADIKAT_STILL';
      } else if (pid != sprof) {
        code = (qual != null && pid != _nearest(family, legacyWindow))
            ? 'QUALIFIER_FLOOR'
            : 'LABEL_NEAREST';
      }
      return _finish(
        e,
        type: type,
        typeCorrected: false,
        makes: true,
        profile: pid,
        step: 2,
        estimate: 'profiled',
        legacy: legacyWindow,
        code: code,
      );
    }

    final pid =
        reviewed &&
            _studyLabelOk(type, qual, sprof, baseLabel) &&
            _reviewCandidate.contains(key)
        ? sprof
        : _coherentStill(type, qual, legacy, baseLabel);
    if (r.variant == 'base') _baseLabel['$key:$type'] = pid;
    final step = pid == sprof ? 3 : 4;
    return _finish(
      e,
      type: type,
      typeCorrected: false,
      makes: true,
      profile: pid,
      step: step,
      estimate: 'profiled',
      code: step == 3 ? null : 'CONTRADICTION',
    );
  }

  /// BR2.12, R-08: generated duplicates take the dedicated value.
  void _applyMirrors(
    List<ProfileMapEntry> entries,
    Map<String, ProfileMapEntry> byId,
  ) {
    for (final e in entries) {
      final source = _mirror[e.key];
      if (source == null || !e.rowMakesType) continue;
      final s = byId[source]!;
      if (e.type != s.type) continue;
      e
        ..profile = s.profile
        ..anchor = s.anchor
        ..unit = s.unit
        ..start = s.start
        ..peak = s.peak
        ..end = s.end
        ..estimate = s.estimate
        ..styleToConfirm = s.styleToConfirm
        ..step = s.step
        // Riserva is in the name.
        ..presetLevel = 'aging'
        ..deviationCode = 'TYPE_FIX';
    }
  }

  /// BR2.2, R-08: a qualifier window is never shorter than its base.
  void _raiseQualifiersToBase(List<ProfileMapEntry> entries) {
    final bases = {
      for (final e in entries)
        if (e.variant == 'base') '${e.key}:${e.type}': e,
    };
    for (final e in entries) {
      if (e.variant != 'qualifier' || e.estimate == 'none') continue;
      final b = bases['${e.key}:${e.type}'];
      if (b == null || b.estimate == 'none' || b.unit != e.unit) continue;
      var raised = false;
      if (e.start != null && b.start != null && e.start! < b.start!) {
        e.start = b.start;
        raised = true;
      }
      if (e.peak != null && b.peak != null && e.peak! < b.peak!) {
        e.peak = b.peak;
        raised = true;
      }
      if (e.end != null && b.end != null && e.end! < b.end!) {
        e.end = b.end;
        raised = true;
      }
      if (raised) e.deviationCode ??= 'QUALIFIER_BELOW_BASE';
    }
  }

  /// BR2.6, R-06: the Kabinett never starts before the base; the Spätlese
  /// stays above the Kabinett.
  void _checkPradikatOrder(
    List<ProfileMapEntry> entries,
    Map<String, ProfileMapEntry> byId,
  ) {
    for (final key in {for (final e in entries) e.key}) {
      final kab = byId['$key:qualifier:kabinett'];
      final spa = byId['$key:qualifier:spatlese'];
      final base = byId['$key:base:white'];
      if (kab != null && base != null && kab.start! < base.start!) {
        throw StateError('Kabinett before the base: $key');
      }
      if (kab != null && spa != null) {
        final above = _compare(
          [spa.start!, spa.peak!, spa.end!],
          [kab.start!, kab.peak!, kab.end!],
        );
        if (above <= 0 || spa.end! <= kab.end!) {
          throw StateError('Spätlese not above the Kabinett: $key');
        }
      }
    }
  }

  static int _compare(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return a[i].compareTo(b[i]);
    }
    return 0;
  }

  /// BR6.10: start <= peak <= end on the values present.
  void _checkWindows(List<ProfileMapEntry> entries) {
    for (final e in entries) {
      if (e.estimate == 'none') continue;
      final s = e.start;
      final p = e.peak;
      final en = e.end;
      if (s == null || (p != null && s > p) || (en != null && (p ?? s) > en)) {
        throw StateError('invalid window: ${e.id}');
      }
      if (!profileOrder.contains(e.profile)) {
        throw StateError('unknown profile: ${e.id}');
      }
    }
  }
}

/// The Dart source of the generated table, already in `dart format` layout.
String renderProfileMap(List<ProfileMapEntry> entries, Study study) {
  final buffer = StringBuffer()
    ..writeln(
      '// GENERATED by tool/build_profile_map.dart: do not edit by hand.',
    )
    ..writeln('//')
    ..writeln(
      '// Source: tool/data/study/study_db.json, wine-style study '
      '${study.version},',
    )
    ..writeln(
      '// applied with the FR1 precedence of rules.md BR2 '
      '(intent 261108-wine-style-profiles).',
    )
    ..writeln('// ${entries.length} combinations.')
    ..writeln(
      '// Row format: id|type|profile|step|estimate|anchor|unit|start|peak|'
      'end|flags|level',
    )
    ..writeln(
      '// flags: c = style to confirm, n = the row does not make the type, '
      't = type corrected',
    )
    ..writeln('// (see parseProfileMapRow in profile_map.dart).')
    ..writeln()
    ..writeln('/// Version of the study the table was generated from.')
    ..writeln("const String profileMapStudyVersion = '${study.version}';")
    ..writeln()
    ..writeln('/// Rows of the generated profile map.')
    ..writeln('const List<String> profileMapRows = [');
  for (final e in entries) {
    buffer.writeln("  '${e.toRow().replaceAll("'", r"\'")}',");
  }
  buffer.writeln('];');
  return buffer.toString();
}

Future<void> main(List<String> args) async {
  exitCode = await runBuildProfileMap(args);
}

/// Runs the generator with [args]; returns the exit code (0 written, 1 a
/// broken study, 2 wrong arguments). On a failure nothing is written.
Future<int> runBuildProfileMap(List<String> args) async {
  if (args.length.isOdd || args.any((a) => a.isEmpty)) {
    stderr.writeln(
      'usage: dart run tool/build_profile_map.dart [--study f] '
      '[--appellations f] [--output f] [--json f]',
    );
    return 2;
  }
  final options = <String, String>{};
  for (var i = 0; i + 1 < args.length; i += 2) {
    options[args[i].replaceFirst('--', '')] = args[i + 1];
  }
  try {
    final study = Study.fromJson(
      jsonDecode(File(options['study'] ?? defaultStudy).readAsStringSync())
          as Map<String, Object?>,
    );
    final generatedTypes = generatedTypesOf(
      File(options['appellations'] ?? defaultAppellations).readAsStringSync(),
    );
    final entries = buildProfileMap(study, generatedTypes);
    File(options['output'] ?? defaultOutput)
        .writeAsStringSync(renderProfileMap(entries, study));
    final json = options['json'];
    if (json != null) {
      File(json).writeAsStringSync(
        const JsonEncoder.withIndent(' ')
            .convert([for (final e in entries) e.toJson()]),
      );
    }
    stdout.writeln(
      'build_profile_map: ${entries.length} combinations, '
      'study ${study.version}',
    );
    return 0;
  } on StateError catch (error) {
    stderr.writeln('build_profile_map: ${error.message}; nothing written');
    return 1;
  } on FileSystemException catch (error) {
    stderr.writeln('build_profile_map: ${error.message}; nothing written');
    return 1;
  } on FormatException catch (error) {
    stderr.writeln('build_profile_map: ${error.message}; nothing written');
    return 1;
  }
}
