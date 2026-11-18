import 'package:estimation/estimation.dart';

import '../../core/text_folding.dart';
import 'origin_country_names.g.dart';

// Countries and wine regions of the ux-redesign intent (FR1.1-FR1.5): every
// list lives in the app code, so the pickers and the search work offline
// and cost no Firestore read (NFR3). The region lists, the canonical names
// and the denomination table are wine knowledge decided at Code Generation
// (project.md correction of 2026-11-04); the reasons are in code-summary.md
// of the intent. Pure Dart: no Flutter import.

/// The origin language tags that have a name for every country: `it`, `en`
/// and `pt` (Brazilian Portuguese, the tag used since the first release)
/// written by hand below, then the generated ones (`pt-PT` is European
/// Portuguese). `lib/cellar/ui/origin_language.dart` maps a locale to its tag.
final List<String> originLanguageTags = List.unmodifiable([
  'it',
  'en',
  'pt',
  ...originCountryNames.keys,
]);

/// A country or territory of ISO 3166-1 with its hand-written names in
/// Italian, English and Brazilian Portuguese; the names in the other
/// interface languages are generated from Unicode CLDR
/// (`origin_country_names.g.dart`).
class OriginCountry {
  const OriginCountry(this.code, this.it, this.en, this.pt);

  /// ISO 3166-1 alpha-2 code, two upper-case letters (the stored value).
  final String code;
  final String it;
  final String en;
  final String pt;

  /// The name in the origin language tag [languageCode] (one of
  /// [originLanguageTags]); English for any other value.
  String nameIn(String languageCode) => switch (languageCode) {
    'it' => it,
    'pt' => pt,
    'en' => en,
    _ => originCountryNames[languageCode]?[code] ?? en,
  };

  /// The flag emoji built from the two regional indicator symbols.
  String get flag => WineOrigins.flagEmoji(code)!;

  @override
  String toString() => 'OriginCountry($code)';
}

/// A wine region of a country: the canonical name is what is stored (it
/// never depends on the language, review R-02), the translations are only
/// shown.
class WineRegion {
  const WineRegion(
    this.canonical, {
    this.it,
    this.en,
    this.pt,
    this.names,
    this.aliases,
  });

  /// Stored value, e.g. `Bourgogne`, `Piemonte`, `Serra Gaúcha`.
  final String canonical;
  final String? it;
  final String? en;

  /// Brazilian Portuguese (origin language tag `pt`).
  final String? pt;

  /// Names by origin language tag for the other interface languages, only
  /// where the language has a name in common use (`Burgund`, `Borgoña`);
  /// a language without an entry shows the canonical name (FR3.2).
  final Map<String, String>? names;

  /// Other written forms recognised as this region (e.g. `Alto Adige`).
  final List<String>? aliases;

  /// The shown name in the origin language tag [languageCode], the canonical
  /// one when there is no translation. European Portuguese (`pt-PT`) uses
  /// the Brazilian form unless its spelling differs.
  String nameIn(String languageCode) =>
      switch (languageCode) {
        'it' => it,
        'pt' => pt,
        'en' => en,
        'pt-PT' => names?['pt-PT'] ?? pt,
        _ => names?[languageCode],
      } ??
      canonical;

  /// Every written form: canonical, translations and aliases.
  Iterable<String> get forms => [
    canonical,
    ?it,
    ?en,
    ?pt,
    ...?names?.values,
    ...?aliases,
  ];

  @override
  String toString() => 'WineRegion($canonical)';
}

/// Country and region proposed for a recognised wine (FR1.3): both stay
/// editable in the form.
class OriginGuess {
  const OriginGuess({this.country, this.region});

  static const OriginGuess none = OriginGuess();

  /// ISO code, or `null` when no country was recognised.
  final String? country;

  /// A canonical region, the free text when nothing matched, or `null`.
  final String? region;

  @override
  bool operator ==(Object other) =>
      other is OriginGuess &&
      other.country == country &&
      other.region == region;

  @override
  int get hashCode => Object.hash(country, region);

  @override
  String toString() => 'OriginGuess($country, $region)';
}

/// Country and region chosen in a form (FR1.1, FR1.2): changing the
/// country clears the region (review R-06).
class OriginSelection {
  const OriginSelection({this.country, this.region});

  final String? country;
  final String? region;

  /// The selection with [code] as country; a different country clears the
  /// region, the same one keeps it.
  OriginSelection withCountry(String? code) =>
      code == country ? this : OriginSelection(country: code);

  /// The selection with [value] as region, blank text meaning none.
  OriginSelection withRegion(String? value) {
    final trimmed = value?.trim();
    return OriginSelection(
      country: country,
      region: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is OriginSelection &&
      other.country == country &&
      other.region == region;

  @override
  int get hashCode => Object.hash(country, region);
}

/// Lower case, accents removed, every other character a single space: the
/// form used to compare names in every interface language (search and
/// matching). See [foldText].
String foldOriginText(String text) => foldText(text);

/// Countries, regions, flags and the matching rules of FR1.
abstract final class WineOrigins {
  /// ISO code of Italy, used by the "Italian region means Italy" rule.
  static const String italy = 'IT';

  /// The 21 wine countries of the grid, Old World then New World, Italy
  /// first (FR1.1).
  static const List<String> wineCountryCodes = [
    'IT', 'FR', 'ES', 'PT', 'DE', 'AT', 'CH', 'GR', 'HU', 'SI', 'HR', 'GE', //
    'US', 'CA', 'AR', 'CL', 'BR', 'UY', 'AU', 'NZ', 'ZA',
  ];

  /// "Rare for wine": producing countries outside the grid, shown first in
  /// the sheet with every country (interaction-spec.md, mockup 8).
  static const List<String> rareWineCountryCodes = [
    'JP', 'CN', 'IN', 'LB', 'IL', 'MA', 'MD', 'RO', 'BG', 'AM', 'MX', 'PE', //
    'GB', 'CY', 'TR', 'LU',
  ];

  static final Map<String, OriginCountry> _byCode = {
    for (final country in _countries) country.code: country,
  };

  /// Every country and territory of ISO 3166-1 (249), by code.
  static List<OriginCountry> get allCountries => _countries;

  /// The country of [code], or `null` when it is not an ISO 3166-1 code.
  static OriginCountry? country(String? code) =>
      code == null ? null : _byCode[code];

  /// True for an ISO 3166-1 alpha-2 code in upper case.
  static bool isCountryCode(String? code) =>
      code != null && _byCode.containsKey(code);

  /// The flag emoji of [code] (two regional indicator symbols), or `null`
  /// when [code] is not two letters A-Z: the caller shows the code instead.
  static String? flagEmoji(String? code) {
    if (code == null || code.length != 2) return null;
    final units = code.codeUnits;
    for (final unit in units) {
      if (unit < 0x41 || unit > 0x5A) return null;
    }
    return String.fromCharCodes([
      for (final unit in units) 0x1F1E6 + unit - 0x41,
    ]);
  }

  /// [codes] as countries, unknown codes left out.
  static List<OriginCountry> countriesOf(List<String> codes) => [
    for (final code in codes) ?_byCode[code],
  ];

  /// Every country sorted by its name in [languageCode], accents ignored.
  static List<OriginCountry> sortedFor(String languageCode) {
    final keyed = [
      for (final country in _countries)
        (key: foldOriginText(country.nameIn(languageCode)), country: country),
    ]..sort((a, b) => a.key.compareTo(b.key));
    return [for (final entry in keyed) entry.country];
  }

  /// Countries whose name in [languageCode], Italian, English or Brazilian
  /// Portuguese contains [query], ignoring case and accents, or whose code
  /// equals it; the country of the code first, then by name in
  /// [languageCode]. An empty query returns every country.
  static List<OriginCountry> searchCountries(
    String query, {
    String languageCode = 'en',
  }) {
    final needle = foldOriginText(query);
    final sorted = sortedFor(languageCode);
    if (needle.isEmpty) return sorted;
    final byCode = _byCode[needle.toUpperCase()];
    return [
      ?byCode,
      for (final country in sorted)
        if (country != byCode &&
            (foldOriginText(country.nameIn(languageCode)).contains(needle) ||
                foldOriginText(country.it).contains(needle) ||
                foldOriginText(country.en).contains(needle) ||
                foldOriginText(country.pt).contains(needle)))
          country,
    ];
  }

  /// The listed wine regions of [country] (empty for the other countries
  /// and for `null`).
  static List<WineRegion> regionsOf(String? country) =>
      _regions[country] ?? const [];

  /// The listed region of [country] whose canonical name, translation or
  /// alias equals [text] ignoring case and accents.
  static WineRegion? findRegion(String? country, String? text) {
    if (text == null || country == null) return null;
    final forms = _regionIndex[country];
    if (forms == null) return null;
    final needle = foldOriginText(text);
    return needle.isEmpty ? null : forms[needle];
  }

  /// Every written form of every listed region, folded, by country: built
  /// once, so the Dashboard can match a region per wine cheaply.
  static final Map<String, Map<String, WineRegion>> _regionIndex = {
    for (final MapEntry(key: country, value: regions) in _regions.entries)
      country: {
        for (final region in regions.reversed)
          for (final form in region.forms) foldOriginText(form): region,
      },
  };

  /// True when [region] is one of the 20 Italian regions (case and accents
  /// ignored, translations and aliases included).
  static bool isItalianRegion(String? region) =>
      findRegion(italy, region) != null;

  /// The value to store for [region] (review R-02 and R-07): the canonical
  /// name when the text is a listed region of [country] in any language,
  /// or, without a country, an Italian region; otherwise the text with the
  /// outer spaces removed. Blank text is `null`.
  static String? canonicalRegion(String? country, String? region) {
    final trimmed = region?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final listed =
        findRegion(country, trimmed) ??
        (country == null ? findRegion(italy, trimmed) : null);
    return listed?.canonical ?? trimmed;
  }

  /// The country shown and saved for a wine: its own when valid, else Italy
  /// when its region is an Italian one (review R-06), else `null`.
  static String? effectiveCountry(String? country, String? region) {
    if (isCountryCode(country)) return country;
    return isItalianRegion(region) ? italy : null;
  }

  /// [region] as shown in [languageCode]: the translation of a listed
  /// region of [country], else the text as stored.
  static String regionDisplayName(
    String? country,
    String region,
    String languageCode,
  ) =>
      findRegion(
        effectiveCountry(country, region),
        region,
      )?.nameIn(languageCode) ??
      region;

  /// The country whose name in it, en or pt equals [text] (case and accents
  /// ignored), or its code written in upper case; then the names of the
  /// wine countries on labels in French, Spanish, German and the native
  /// language, from the estimation package (label-autofill-windows D1).
  static OriginCountry? countryNamed(String? text) {
    if (text == null) return null;
    final trimmed = text.trim();
    if (_byCode.containsKey(trimmed)) return _byCode[trimmed];
    final needle = foldOriginText(trimmed);
    if (needle.isEmpty) return null;
    for (final country in _countries) {
      if (foldOriginText(country.it) == needle ||
          foldOriginText(country.en) == needle ||
          foldOriginText(country.pt) == needle) {
        return country;
      }
    }
    return _countryAliases[needle] ?? _byCode[countryCodeOfName(trimmed)];
  }

  /// Country and region of a recognised wine (FR1.3, review R-06):
  ///
  /// 1. a denomination of the world tables of the estimation package found
  ///    in [denomination], [name] or [region] (Barolo DOCG → Piemonte →
  ///    Italy, Chablis → Bourgogne → France). Since label-autofill-windows
  ///    (BR3.5) the package table is the only source of these origins; a
  ///    common word that is also a denomination ("Toro") counts only in the
  ///    denomination field;
  /// 2. [region] read as parts separated by commas, such as the Open Food
  ///    Facts `origins` ("Mendoza, Argentina"): a country name gives the
  ///    country, a listed region of that country (or of a single country)
  ///    gives the region; a part that matches nothing is kept as free
  ///    region text.
  static OriginGuess guess({
    String? region,
    String? denomination,
    String? name,
  }) {
    for (final (text, weak) in [
      (denomination, true),
      (name, false),
      (region, false),
    ]) {
      final origin = _denominationOrigin(text, includeWeak: weak);
      if (origin != null) return origin;
    }
    return _guessFromRegionText(region);
  }

  /// The origin of the denomination named in [text], or `null`.
  static OriginGuess? _denominationOrigin(
    String? text, {
    required bool includeWeak,
  }) {
    if (text == null || text.trim().isEmpty) return null;
    var info = findAppellation(text, includeWeak: includeWeak);
    if (info == null && !includeWeak) {
      final weak = findAppellation(text);
      if (_knownWeakDenominations.contains(weak?.key)) info = weak;
    }
    if (info == null || !isCountryCode(info.country)) return null;
    return OriginGuess(
      country: info.country,
      region: findRegion(info.country, info.region)?.canonical,
    );
  }

  static OriginGuess _guessFromRegionText(String? region) {
    final trimmed = region?.trim();
    if (trimmed == null || trimmed.isEmpty) return OriginGuess.none;
    final parts = [
      for (final part in trimmed.split(RegExp('[,;/|()]')))
        if (part.trim().isNotEmpty) part.trim(),
    ];
    String? country;
    final leftover = <String>[];
    for (final part in parts) {
      final named = countryNamed(part);
      if (named != null && country == null) {
        country = named.code;
      } else if (named == null) {
        leftover.add(part);
      }
    }
    for (final part in leftover) {
      final match = _regionMatch(country, part);
      if (match != null) {
        return OriginGuess(country: match.country, region: match.region);
      }
    }
    if (country != null) return OriginGuess(country: country);
    return OriginGuess(region: trimmed);
  }

  /// A listed region named [text]: inside [country] when known, else the
  /// only country that lists it.
  static ({String country, String region})? _regionMatch(
    String? country,
    String text,
  ) {
    if (country != null) {
      final region = findRegion(country, text);
      return region == null
          ? null
          : (country: country, region: region.canonical);
    }
    ({String country, String region})? found;
    for (final code in _regions.keys) {
      final region = findRegion(code, text);
      if (region == null) continue;
      if (found != null) return null;
      found = (country: code, region: region.canonical);
    }
    return found;
  }
}

/// Short or old names of a few countries, as they appear on labels and in
/// Open Food Facts `origins` (folded).
final Map<String, OriginCountry> _countryAliases = {
  'usa': WineOrigins._byCode['US']!,
  'u s a': WineOrigins._byCode['US']!,
  'stati uniti d america': WineOrigins._byCode['US']!,
  'united states of america': WineOrigins._byCode['US']!,
  'uk': WineOrigins._byCode['GB']!,
  'england': WineOrigins._byCode['GB']!,
  'inghilterra': WineOrigins._byCode['GB']!,
  'espana': WineOrigins._byCode['ES']!,
  'deutschland': WineOrigins._byCode['DE']!,
  'osterreich': WineOrigins._byCode['AT']!,
  'schweiz': WineOrigins._byCode['CH']!,
  'suisse': WineOrigins._byCode['CH']!,
  'svizra': WineOrigins._byCode['CH']!,
  'magyarorszag': WineOrigins._byCode['HU']!,
  'slovenija': WineOrigins._byCode['SI']!,
  'hrvatska': WineOrigins._byCode['HR']!,
  'sakartvelo': WineOrigins._byCode['GE']!,
  'czech republic': WineOrigins._byCode['CZ']!,
  'repubblica ceca': WineOrigins._byCode['CZ']!,
  'turkey': WineOrigins._byCode['TR']!,
  'moldavia': WineOrigins._byCode['MD']!,
};

/// Denominations whose name is a common word (weak, BR1.2) but that the
/// origin guess of ux-redesign already recognised in a name or a region
/// text: they keep doing so (BR3.5 made the package table the only source).
const Set<String> _knownWeakDenominations = {'rioja', 'cava', 'napaValley'};

/// Wine regions of the 21 countries of the grid, in the order shown.
const Map<String, List<WineRegion>> _regions = {
  // All 20 Italian regions (FR1.2): the most cited for wine first, as in
  // mockup 3, then the others. Canonical names are the Italian ones, the
  // same strings as the denomination catalog of the estimation package.
  'IT': [
    WineRegion(
      'Piemonte',
      en: 'Piedmont',
      names: {
        'fr': 'Piémont', 'es': 'Piamonte', 'de': 'Piemont', 'ca': 'Piemont', //
        'el': 'Πεδεμόντιο', 'ro': 'Piemont', 'hu': 'Piemont', //
        'hr': 'Pijemont', 'sl': 'Piemont', 'cs': 'Piemont', 'sk': 'Piemont', //
        'bg': 'Пиемонт', 'sr': 'Пијемонт', 'ka': 'პიემონტი', //
        'nl': 'Piëmont', 'pl': 'Piemont', 'uk': 'Пʼємонт',
      },
    ),
    WineRegion(
      'Toscana',
      en: 'Tuscany',
      names: {
        'fr': 'Toscane', 'de': 'Toskana', 'el': 'Τοσκάνη', 'hu': 'Toszkána', //
        'hr': 'Toskana', 'sl': 'Toskana', 'cs': 'Toskánsko', //
        'sk': 'Toskánsko', 'bg': 'Тоскана', 'sr': 'Тоскана', //
        'ka': 'ტოსკანა', 'pl': 'Toskania', 'uk': 'Тоскана',
      },
    ),
    WineRegion(
      'Veneto',
      names: {
        'pt-PT': 'Véneto', 'fr': 'Vénétie', 'es': 'Véneto', //
        'de': 'Venetien', 'ca': 'Vèneto', 'el': 'Βένετο', 'cs': 'Benátsko', //
        'sk': 'Benátsko', 'bg': 'Венето', 'sr': 'Венето', 'ka': 'ვენეტო', //
        'uk': 'Венето',
      },
    ),
    WineRegion(
      'Sicilia',
      en: 'Sicily',
      pt: 'Sicília',
      names: {
        'fr': 'Sicile', 'de': 'Sizilien', 'ca': 'Sicília', 'el': 'Σικελία', //
        'hu': 'Szicília', 'hr': 'Sicilija', 'sl': 'Sicilija', //
        'cs': 'Sicílie', 'sk': 'Sicília', 'bg': 'Сицилия', //
        'sr': 'Сицилија', 'ka': 'სიცილია', 'nl': 'Sicilië', //
        'pl': 'Sycylia', 'uk': 'Сицилія', 'da': 'Sicilien', //
        'sv': 'Sicilien', 'fi': 'Sisilia',
      },
    ),
    WineRegion(
      'Puglia',
      en: 'Apulia',
      pt: 'Apúlia',
      names: {
        'fr': 'Pouilles', 'es': 'Apulia', 'de': 'Apulien', 'ca': 'Pulla', //
        'el': 'Απουλία', 'ro': 'Apulia', 'hr': 'Apulija', 'sl': 'Apulija', //
        'cs': 'Apulie', 'sk': 'Apúlia', 'bg': 'Апулия', 'sr': 'Апулија', //
        'ka': 'აპულია', 'nl': 'Apulië', 'pl': 'Apulia', 'uk': 'Апулія', //
        'da': 'Apulien', 'sv': 'Apulien', 'fi': 'Apulia',
      },
    ),
    WineRegion(
      'Campania',
      pt: 'Campânia',
      names: {
        'fr': 'Campanie', 'de': 'Kampanien', 'ca': 'Campània', //
        'hr': 'Kampanija', 'sl': 'Kampanija', 'cs': 'Kampánie', //
        'sk': 'Kampánia', 'bg': 'Кампания', 'sr': 'Кампанија', //
        'ka': 'კამპანია', 'nl': 'Campanië', 'pl': 'Kampania', //
        'uk': 'Кампанія', 'sv': 'Kampanien',
      },
    ),
    WineRegion(
      'Friuli-Venezia Giulia',
      names: {
        'fr': 'Frioul-Vénétie Julienne', 'es': 'Friul-Venecia Julia', //
        'de': 'Friaul-Julisch Venetien', //
        'hr': 'Furlanija-Julijska krajina', //
        'sl': 'Furlanija - Julijska krajina',
      },
      aliases: ['Friuli'],
    ),
    WineRegion(
      'Trentino-Alto Adige',
      en: 'Trentino-South Tyrol',
      pt: 'Trentino-Alto Ádige',
      names: {
        'fr': 'Trentin-Haut-Adige', 'es': 'Trentino-Alto Adigio', //
        'de': 'Trentino-Südtirol',
      },
      aliases: ['Trentino', 'Alto Adige', 'Südtirol', 'South Tyrol'],
    ),
    WineRegion(
      'Lombardia',
      en: 'Lombardy',
      names: {
        'fr': 'Lombardie', 'es': 'Lombardía', 'de': 'Lombardei', //
        'el': 'Λομβαρδία', 'hr': 'Lombardija', 'sl': 'Lombardija', //
        'cs': 'Lombardie', 'sk': 'Lombardsko', 'bg': 'Ломбардия', //
        'sr': 'Ломбардија', 'ka': 'ლომბარდია', 'nl': 'Lombardije', //
        'uk': 'Ломбардія', 'da': 'Lombardiet', 'sv': 'Lombardiet',
      },
    ),
    WineRegion(
      'Sardegna',
      en: 'Sardinia',
      pt: 'Sardenha',
      names: {
        'fr': 'Sardaigne', 'es': 'Cerdeña', 'de': 'Sardinien', //
        'ca': 'Sardenya', 'el': 'Σαρδηνία', 'ro': 'Sardinia', //
        'hu': 'Szardínia', 'hr': 'Sardinija', 'sl': 'Sardinija', //
        'cs': 'Sardinie', 'sk': 'Sardínia', 'bg': 'Сардиния', //
        'sr': 'Сардинија', 'ka': 'სარდინია', 'nl': 'Sardinië', //
        'pl': 'Sardynia', 'uk': 'Сардинія', 'da': 'Sardinien', //
        'sv': 'Sardinien', 'nb': 'Sardinia', 'fi': 'Sardinia',
      },
    ),
    WineRegion(
      'Abruzzo',
      pt: 'Abruzos',
      names: {
        'fr': 'Abruzzes', 'es': 'Abruzos', 'de': 'Abruzzen', //
        'ca': 'Abruços', 'nl': 'Abruzzen', 'pl': 'Abruzja',
      },
    ),
    WineRegion(
      'Marche',
      pt: 'Marcas',
      names: {
        'fr': 'Marches', 'es': 'Marcas', 'de': 'Marken', 'ca': 'Marques', //
        'nl': 'Marken',
      },
    ),
    WineRegion(
      'Umbria',
      pt: 'Úmbria',
      names: {
        'fr': 'Ombrie', 'de': 'Umbrien', 'ca': 'Úmbria', 'el': 'Ούμβρια', //
        'hr': 'Umbrija', 'sl': 'Umbrija', 'cs': 'Umbrie', 'bg': 'Умбрия', //
        'sr': 'Умбрија', 'nl': 'Umbrië', 'uk': 'Умбрія', 'da': 'Umbrien', //
        'sv': 'Umbrien',
      },
    ),
    WineRegion(
      'Emilia-Romagna',
      names: {
        'pt-PT': 'Emília-Romanha', 'fr': 'Émilie-Romagne', //
        'es': 'Emilia-Romaña', 'ca': 'Emília-Romanya', //
        'pl': 'Emilia-Romania',
      },
    ),
    WineRegion(
      'Lazio',
      pt: 'Lácio',
      names: {
        'fr': 'Latium', 'es': 'Lacio', 'de': 'Latium', 'ca': 'Laci', //
        'nl': 'Latium', 'pl': 'Lacjum',
      },
    ),
    WineRegion('Basilicata', names: {'fr': 'Basilicate'}),
    WineRegion(
      'Calabria',
      pt: 'Calábria',
      names: {
        'fr': 'Calabre', 'de': 'Kalabrien', 'ca': 'Calàbria', //
        'el': 'Καλαβρία', 'hr': 'Kalabrija', 'sl': 'Kalabrija', //
        'cs': 'Kalábrie', 'sk': 'Kalábria', 'bg': 'Калабрия', //
        'sr': 'Калабрија', 'nl': 'Calabrië', 'pl': 'Kalabria', //
        'uk': 'Калабрія', 'da': 'Calabrien', 'sv': 'Kalabrien',
      },
    ),
    WineRegion(
      'Liguria',
      pt: 'Ligúria',
      names: {
        'fr': 'Ligurie', 'de': 'Ligurien', 'ca': 'Ligúria', //
        'el': 'Λιγουρία', 'hr': 'Ligurija', 'sl': 'Ligurija', //
        'cs': 'Ligurie', 'bg': 'Лигурия', 'sr': 'Лигурија', //
        'nl': 'Ligurië', 'uk': 'Лігурія', 'da': 'Ligurien', //
        'sv': 'Ligurien',
      },
    ),
    WineRegion(
      "Valle d'Aosta",
      en: 'Aosta Valley',
      pt: 'Vale de Aosta',
      names: {
        'fr': "Vallée d'Aoste", 'es': 'Valle de Aosta', 'de': 'Aostatal', //
        'ca': "Vall d'Aosta", 'hr': 'Dolina Aoste', 'sl': 'Dolina Aoste', //
        'cs': 'Údolí Aosty', 'pl': 'Dolina Aosty', 'da': 'Aostadalen', //
        'sv': 'Aostadalen', 'nb': 'Aostadalen', 'fi': 'Aostanlaakso',
      },
    ),
    WineRegion('Molise'),
  ],
  // The 11 regions named by FR1.2, French canonical names.
  'FR': [
    WineRegion(
      'Bordeaux',
      names: {
        'pt-PT': 'Bordéus', 'es': 'Burdeos', 'ca': 'Bordeus', //
        'el': 'Μπορντό', 'bg': 'Бордо', 'sr': 'Бордо', 'ka': 'ბორდო', //
        'uk': 'Бордо',
      },
    ),
    WineRegion(
      'Bourgogne',
      it: 'Borgogna',
      en: 'Burgundy',
      pt: 'Borgonha',
      names: {
        'es': 'Borgoña', 'de': 'Burgund', 'ca': 'Borgonya', //
        'el': 'Βουργουνδία', 'ro': 'Burgundia', 'hu': 'Burgundia', //
        'hr': 'Burgundija', 'sl': 'Burgundija', 'cs': 'Burgundsko', //
        'sk': 'Burgundsko', 'bg': 'Бургундия', 'sr': 'Бургундија', //
        'ka': 'ბურგუნდია', 'pl': 'Burgundia', 'uk': 'Бургундія', //
        'nb': 'Burgund', 'fi': 'Burgundi',
      },
    ),
    WineRegion(
      'Champagne',
      names: {
        'es': 'Champaña', 'ca': 'Xampanya', 'hr': 'Šampanja', //
        'sl': 'Šampanja', 'bg': 'Шампан', 'sr': 'Шампања', //
        'ka': 'შამპანი', 'pl': 'Szampania', 'uk': 'Шампань',
      },
    ),
    WineRegion(
      'Vallée du Rhône',
      it: 'Valle del Rodano',
      en: 'Rhône Valley',
      pt: 'Vale do Ródano',
      names: {
        'es': 'Valle del Ródano', 'de': 'Rhônetal', //
        'ca': 'Vall del Roine', 'el': 'Κοιλάδα του Ροδανού', //
        'ro': 'Valea Ronului', 'hu': 'Rhône-völgy', 'hr': 'Dolina Rhône', //
        'sl': 'Dolina Rone', 'cs': 'Údolí Rhôny', 'sk': 'Údolie Rhôny', //
        'bg': 'Долината на Рона', 'sr': 'Долина Роне', //
        'ka': 'რონის ველი', 'nl': 'Rhônedal', 'pl': 'Dolina Rodanu', //
        'uk': 'Долина Рони', 'da': 'Rhônedalen', 'sv': 'Rhônedalen', //
        'nb': 'Rhônedalen', 'fi': 'Rhônen laakso',
      },
      aliases: ['Rhône'],
    ),
    WineRegion(
      'Vallée de la Loire',
      it: 'Valle della Loira',
      en: 'Loire Valley',
      pt: 'Vale do Loire',
      names: {
        'es': 'Valle del Loira', 'de': 'Loiretal', 'ca': 'Vall del Loira', //
        'el': 'Κοιλάδα του Λίγηρα', 'ro': 'Valea Loarei', //
        'hu': 'Loire-völgy', 'hr': 'Dolina Loire', 'sl': 'Dolina Loare', //
        'cs': 'Údolí Loiry', 'sk': 'Údolie Loiry', //
        'bg': 'Долината на Лоара', 'sr': 'Долина Лоаре', //
        'ka': 'ლუარის ველი', 'nl': 'Loiredal', 'pl': 'Dolina Loary', //
        'uk': 'Долина Луари', 'da': 'Loiredalen', 'sv': 'Loiredalen', //
        'nb': 'Loiredalen', 'fi': 'Loiren laakso',
      },
      aliases: ['Loire'],
    ),
    WineRegion(
      'Alsace',
      it: 'Alsazia',
      pt: 'Alsácia',
      names: {
        'es': 'Alsacia', 'de': 'Elsass', 'ca': 'Alsàcia', 'el': 'Αλσατία', //
        'ro': 'Alsacia', 'hu': 'Elzász', 'hr': 'Alzas', 'sl': 'Alzacija', //
        'cs': 'Alsasko', 'sk': 'Alsasko', 'bg': 'Елзас', 'sr': 'Алзас', //
        'ka': 'ელზასი', 'nl': 'Elzas', 'pl': 'Alzacja', 'uk': 'Ельзас',
      },
    ),
    WineRegion(
      'Languedoc-Roussillon',
      it: 'Linguadoca-Rossiglione',
      names: {'es': 'Languedoc-Rosellón', 'ca': 'Llenguadoc-Rosselló'},
      aliases: ['Languedoc'],
    ),
    WineRegion(
      'Provence',
      it: 'Provenza',
      pt: 'Provença',
      names: {
        'es': 'Provenza', 'ca': 'Provença', 'el': 'Προβηγκία', //
        'hr': 'Provansa', 'sl': 'Provansa', 'bg': 'Прованс', //
        'sr': 'Прованса', 'ka': 'პროვანსი', 'pl': 'Prowansja', //
        'uk': 'Прованс',
      },
    ),
    WineRegion(
      'Beaujolais',
      names: {'bg': 'Божоле', 'sr': 'Божоле', 'uk': 'Божоле'},
    ),
    WineRegion('Jura'),
    WineRegion(
      'Sud-Ouest',
      it: 'Sud-Ovest',
      en: 'South West France',
      pt: 'Sudoeste',
      names: {
        'es': 'Suroeste', 'de': 'Südwestfrankreich', 'ca': 'Sud-oest', //
      },
    ),
  ],
  'ES': [
    WineRegion(
      'Rioja',
      names: {
        'el': 'Ριόχα', 'bg': 'Риоха', 'sr': 'Риоха', 'ka': 'რიოხა', //
        'uk': 'Ріоха',
      },
    ),
    WineRegion('Ribera del Duero'),
    WineRegion('Priorat', names: {'es': 'Priorato'}, aliases: ['Priorato']),
    WineRegion('Penedès', names: {'es': 'Penedés'}),
    WineRegion('Rías Baixas'),
    WineRegion('Rueda'),
    WineRegion('Toro'),
    WineRegion(
      'Jerez',
      en: 'Jerez (Sherry)',
      names: {
        'fr': 'Xérès', 'ca': 'Xerès', 'bg': 'Херес', 'sr': 'Херес', //
        'uk': 'Херес',
      },
      aliases: ['Sherry'],
    ),
    WineRegion('La Mancha'),
    WineRegion('Navarra', en: 'Navarre', names: {'fr': 'Navarre'}),
    WineRegion('Bierzo'),
  ],
  'PT': [
    WineRegion('Douro'),
    WineRegion('Vinho Verde'),
    WineRegion('Alentejo'),
    WineRegion('Dão'),
    WineRegion('Bairrada'),
    WineRegion(
      'Lisboa',
      it: 'Lisbona',
      en: 'Lisbon',
      names: {
        'fr': 'Lisbonne', 'de': 'Lissabon', 'el': 'Λισαβόνα', //
        'ro': 'Lisabona', 'hu': 'Lisszabon', 'hr': 'Lisabon', //
        'sl': 'Lizbona', 'cs': 'Lisabon', 'sk': 'Lisabon', //
        'bg': 'Лисабон', 'sr': 'Лисабон', 'ka': 'ლისაბონი', //
        'nl': 'Lissabon', 'pl': 'Lizbona', 'uk': 'Лісабон', //
        'da': 'Lissabon', 'sv': 'Lissabon', 'fi': 'Lissabon',
      },
    ),
    WineRegion(
      'Tejo',
      it: 'Tago',
      en: 'Tagus',
      names: {'fr': 'Tage', 'es': 'Tajo'},
    ),
    WineRegion(
      'Península de Setúbal',
      it: 'Penisola di Setúbal',
      en: 'Setúbal Peninsula',
      names: {'fr': 'Péninsule de Setúbal', 'de': 'Halbinsel Setúbal'},
    ),
    WineRegion(
      'Madeira',
      names: {
        'fr': 'Madère', 'el': 'Μαδέρα', 'bg': 'Мадейра', 'sr': 'Мадеира', //
        'ka': 'მადეირა', 'uk': 'Мадейра',
      },
    ),
    WineRegion(
      'Açores',
      it: 'Azzorre',
      en: 'Azores',
      names: {
        'es': 'Azores', 'de': 'Azoren', 'el': 'Αζόρες', 'ro': 'Azore', //
        'hu': 'Azori-szigetek', 'hr': 'Azori', 'sl': 'Azori', //
        'cs': 'Azory', 'sk': 'Azory', 'bg': 'Азорски острови', //
        'sr': 'Азори', 'ka': 'აზორის კუნძულები', 'nl': 'Azoren', //
        'pl': 'Azory', 'uk': 'Азорські острови', 'da': 'Azorerne', //
        'sv': 'Azorerna', 'nb': 'Azorene', 'fi': 'Azorit',
      },
    ),
  ],
  // The 13 German Anbaugebiete.
  'DE': [
    WineRegion(
      'Mosel',
      it: 'Mosella',
      pt: 'Mosela',
      names: {
        'fr': 'Moselle', 'es': 'Mosela', 'ca': 'Mosel·la', 'cs': 'Mosela', //
        'sk': 'Mosela', 'bg': 'Мозел', 'sr': 'Мозел', 'nl': 'Moezel', //
        'pl': 'Mozela', 'uk': 'Мозель',
      },
    ),
    WineRegion('Rheingau'),
    WineRegion(
      'Pfalz',
      it: 'Palatinato',
      en: 'Palatinate',
      pt: 'Palatinado',
      names: {
        'fr': 'Palatinat', 'es': 'Palatinado', 'ca': 'Palatinat', //
        'cs': 'Falc', 'sk': 'Falcko', 'nl': 'Palts', 'pl': 'Palatynat',
      },
    ),
    WineRegion(
      'Rheinhessen',
      it: 'Assia Renana',
      en: 'Rhinehesse',
      pt: 'Hesse Renana',
      names: {
        'fr': 'Hesse rhénane', 'es': 'Hesse Renano', //
        'cs': 'Rýnské Hesensko', 'nl': 'Rijn-Hessen', //
        'pl': 'Hesja Nadreńska',
      },
    ),
    WineRegion('Nahe'),
    WineRegion('Baden', names: {'fr': 'Bade'}),
    WineRegion(
      'Franken',
      it: 'Franconia',
      en: 'Franconia',
      pt: 'Francônia',
      names: {
        'pt-PT': 'Francónia', 'fr': 'Franconie', 'es': 'Franconia', //
        'ca': 'Francònia', 'cs': 'Franky', 'pl': 'Frankonia',
      },
    ),
    WineRegion('Württemberg'),
    WineRegion('Ahr'),
    WineRegion(
      'Mittelrhein',
      it: 'Medio Reno',
      en: 'Middle Rhine',
      pt: 'Médio Reno',
      names: {'fr': 'Rhin moyen', 'es': 'Rin Medio', 'nl': 'Middenrijn'},
    ),
    WineRegion('Saale-Unstrut'),
    WineRegion(
      'Sachsen',
      it: 'Sassonia',
      en: 'Saxony',
      pt: 'Saxônia',
      names: {
        'pt-PT': 'Saxónia', 'fr': 'Saxe', 'es': 'Sajonia', //
        'ca': 'Saxònia', 'el': 'Σαξονία', 'hu': 'Szászország', //
        'hr': 'Saska', 'sl': 'Saška', 'cs': 'Sasko', 'sk': 'Sasko', //
        'bg': 'Саксония', 'sr': 'Саксонија', 'nl': 'Saksen', //
        'pl': 'Saksonia', 'uk': 'Саксонія', 'fi': 'Saksi',
      },
    ),
    WineRegion('Hessische Bergstraße'),
  ],
  'AT': [
    WineRegion('Wachau'),
    WineRegion('Kamptal'),
    WineRegion('Kremstal'),
    WineRegion('Weinviertel'),
    WineRegion('Wagram'),
    WineRegion('Carnuntum'),
    WineRegion('Thermenregion'),
    WineRegion('Burgenland'),
    // Slovenian and Croatian call Austrian Styria "Štajerska", the canonical
    // name of the Slovenian region: Slovenian gets the qualified form and
    // Croatian the canonical one, so a region text never matches both.
    WineRegion(
      'Steiermark',
      it: 'Stiria',
      en: 'Styria',
      pt: 'Estíria',
      names: {
        'fr': 'Styrie', 'es': 'Estiria', 'ca': 'Estíria', //
        'hu': 'Stájerország', 'sl': 'Avstrijska Štajerska', //
        'cs': 'Štýrsko', 'sk': 'Štajersko', 'bg': 'Щирия', //
        'nl': 'Stiermarken', 'pl': 'Styria', 'uk': 'Штирія',
      },
    ),
    WineRegion(
      'Wien',
      it: 'Vienna',
      en: 'Vienna',
      pt: 'Viena',
      names: {
        'fr': 'Vienne', 'es': 'Viena', 'ca': 'Viena', 'el': 'Βιέννη', //
        'ro': 'Viena', 'hu': 'Bécs', 'hr': 'Beč', 'sl': 'Dunaj', //
        'cs': 'Vídeň', 'sk': 'Viedeň', 'bg': 'Виена', 'sr': 'Беч', //
        'ka': 'ვენა', 'nl': 'Wenen', 'pl': 'Wiedeń', 'uk': 'Відень',
      },
    ),
  ],
  'CH': [
    WineRegion(
      'Valais',
      it: 'Vallese',
      names: {'de': 'Wallis', 'nl': 'Wallis'},
      aliases: ['Wallis'],
    ),
    WineRegion('Vaud', names: {'de': 'Waadt'}),
    WineRegion(
      'Genève',
      it: 'Ginevra',
      en: 'Geneva',
      pt: 'Genebra',
      names: {
        'es': 'Ginebra', 'de': 'Genf', 'ca': 'Ginebra', 'el': 'Γενεύη', //
        'ro': 'Geneva', 'hu': 'Genf', 'hr': 'Ženeva', 'sl': 'Ženeva', //
        'cs': 'Ženeva', 'sk': 'Ženeva', 'bg': 'Женева', 'sr': 'Женева', //
        'ka': 'ჟენევა', 'pl': 'Genewa', 'uk': 'Женева', 'fi': 'Geneve',
      },
    ),
    WineRegion('Ticino', names: {'fr': 'Tessin', 'de': 'Tessin'}),
    WineRegion('Neuchâtel', names: {'de': 'Neuenburg'}),
    WineRegion(
      'Graubünden',
      it: 'Grigioni',
      en: 'Grisons',
      pt: 'Grisões',
      names: {'fr': 'Grisons', 'es': 'Grisones', 'ca': 'Grisons'},
    ),
    WineRegion('Schaffhausen', it: 'Sciaffusa', names: {'fr': 'Schaffhouse'}),
  ],
  // Canonical names are the Latin transliterations; Greek shows the names
  // in its own script.
  'GR': [
    WineRegion(
      'Santorini',
      names: {
        'fr': 'Santorin', 'de': 'Santorin', 'el': 'Σαντορίνη', //
        'bg': 'Санторини', 'sr': 'Санторини', 'ka': 'სანტორინი', //
        'uk': 'Санторіні',
      },
    ),
    WineRegion('Naoussa', names: {'el': 'Νάουσα'}),
    WineRegion('Nemea', names: {'el': 'Νεμέα'}),
    WineRegion('Amyntaio', names: {'el': 'Αμύνταιο'}),
    WineRegion(
      'Makedonia',
      it: 'Macedonia',
      en: 'Macedonia',
      pt: 'Macedônia',
      names: {
        'pt-PT': 'Macedónia', 'fr': 'Macédoine', 'es': 'Macedonia', //
        'de': 'Makedonien', 'ca': 'Macedònia', 'el': 'Μακεδονία', //
        'ro': 'Macedonia', 'hu': 'Makedónia', 'hr': 'Makedonija', //
        'sl': 'Makedonija', 'cs': 'Makedonie', 'sk': 'Macedónsko', //
        'bg': 'Македония', 'sr': 'Македонија', 'ka': 'მაკედონია', //
        'nl': 'Macedonië', 'pl': 'Macedonia', 'uk': 'Македонія', //
        'da': 'Makedonien', 'sv': 'Makedonien',
      },
    ),
    WineRegion(
      'Peloponnisos',
      it: 'Peloponneso',
      en: 'Peloponnese',
      pt: 'Peloponeso',
      names: {
        'fr': 'Péloponnèse', 'es': 'Peloponeso', 'de': 'Peloponnes', //
        'ca': 'Peloponès', 'el': 'Πελοπόννησος', 'ro': 'Peloponez', //
        'hu': 'Peloponnészosz', 'hr': 'Peloponez', 'sl': 'Peloponez', //
        'cs': 'Peloponés', 'sk': 'Peloponéz', 'bg': 'Пелопонес', //
        'sr': 'Пелопонез', 'ka': 'პელოპონესი', 'nl': 'Peloponnesos', //
        'pl': 'Peloponez', 'uk': 'Пелопоннес', 'da': 'Peloponnes', //
        'sv': 'Peloponnesos', 'nb': 'Peloponnes', 'fi': 'Peloponnesos',
      },
    ),
    WineRegion(
      'Kriti',
      it: 'Creta',
      en: 'Crete',
      pt: 'Creta',
      names: {
        'fr': 'Crète', 'es': 'Creta', 'de': 'Kreta', 'ca': 'Creta', //
        'el': 'Κρήτη', 'ro': 'Creta', 'hu': 'Kréta', 'hr': 'Kreta', //
        'sl': 'Kreta', 'cs': 'Kréta', 'sk': 'Kréta', 'bg': 'Крит', //
        'sr': 'Крит', 'ka': 'კრეტა', 'nl': 'Kreta', 'pl': 'Kreta', //
        'uk': 'Крит', 'da': 'Kreta', 'sv': 'Kreta', 'nb': 'Kreta', //
        'fi': 'Kreeta',
      },
    ),
    WineRegion(
      'Attiki',
      it: 'Attica',
      en: 'Attica',
      pt: 'Ática',
      names: {
        'fr': 'Attique', 'es': 'Ática', 'de': 'Attika', 'ca': 'Àtica', //
        'el': 'Αττική', 'ro': 'Attica', 'hu': 'Attika', 'hr': 'Atika', //
        'sl': 'Atika', 'cs': 'Attika', 'sk': 'Atika', 'bg': 'Атика', //
        'sr': 'Атика', 'ka': 'ატიკა', 'nl': 'Attica', 'pl': 'Attyka', //
        'uk': 'Аттика', 'da': 'Attika', 'sv': 'Attika', 'nb': 'Attika', //
        'fi': 'Attika',
      },
    ),
    WineRegion(
      'Kefalonia',
      it: 'Cefalonia',
      en: 'Cephalonia',
      pt: 'Cefalônia',
      names: {
        'pt-PT': 'Cefalónia', 'fr': 'Céphalonie', 'es': 'Cefalonia', //
        'ca': 'Cefalònia', 'el': 'Κεφαλονιά', 'bg': 'Кефалония', //
        'sr': 'Кефалонија', 'uk': 'Кефалонія',
      },
    ),
  ],
  'HU': [
    WineRegion(
      'Tokaj',
      names: {
        'el': 'Τοκάι', 'bg': 'Токай', 'sr': 'Токај', 'ka': 'ტოკაი', //
        'uk': 'Токай',
      },
    ),
    WineRegion('Eger'),
    WineRegion('Villány'),
    WineRegion('Szekszárd'),
    WineRegion('Badacsony'),
    WineRegion('Somló'),
    WineRegion('Sopron'),
    WineRegion('Kunság'),
  ],
  'SI': [
    WineRegion(
      'Goriška Brda',
      it: 'Collio sloveno',
      en: 'Brda',
      pt: 'Brda',
      aliases: ['Brda'],
    ),
    WineRegion(
      'Vipavska dolina',
      it: 'Valle del Vipacco',
      en: 'Vipava Valley',
      pt: 'Vale de Vipava',
    ),
    WineRegion('Kras', it: 'Carso', en: 'Karst', pt: 'Carso'),
    WineRegion(
      'Slovenska Istra',
      it: 'Istria slovena',
      en: 'Slovenian Istria',
      pt: 'Ístria eslovena',
    ),
    WineRegion(
      'Štajerska',
      it: 'Stiria slovena',
      en: 'Slovenian Styria',
      pt: 'Estíria eslovena',
      aliases: ['Podravje'],
    ),
    WineRegion('Posavje'),
  ],
  'HR': [
    WineRegion(
      'Istra',
      it: 'Istria',
      en: 'Istria',
      pt: 'Ístria',
      names: {
        'fr': 'Istrie', 'es': 'Istria', 'de': 'Istrien', 'ca': 'Ístria', //
        'el': 'Ίστρια', 'ro': 'Istria', 'hu': 'Isztria', 'cs': 'Istrie', //
        'sk': 'Istria', 'bg': 'Истрия', 'sr': 'Истра', 'nl': 'Istrië', //
        'pl': 'Istria', 'uk': 'Істрія', 'da': 'Istrien', 'sv': 'Istrien', //
        'nb': 'Istria', 'fi': 'Istria',
      },
    ),
    WineRegion(
      'Dalmacija',
      it: 'Dalmazia',
      en: 'Dalmatia',
      pt: 'Dalmácia',
      names: {
        'fr': 'Dalmatie', 'es': 'Dalmacia', 'de': 'Dalmatien', //
        'ca': 'Dalmàcia', 'el': 'Δαλματία', 'ro': 'Dalmația', //
        'hu': 'Dalmácia', 'cs': 'Dalmácie', 'sk': 'Dalmácia', //
        'bg': 'Далмация', 'sr': 'Далмација', 'nl': 'Dalmatië', //
        'pl': 'Dalmacja', 'uk': 'Далмація', 'da': 'Dalmatien', //
        'sv': 'Dalmatien', 'nb': 'Dalmatia', 'fi': 'Dalmatia',
      },
    ),
    WineRegion(
      'Slavonija',
      it: 'Slavonia',
      en: 'Slavonia',
      pt: 'Eslavônia',
      names: {
        'pt-PT': 'Eslavónia', 'fr': 'Slavonie', 'es': 'Eslavonia', //
        'de': 'Slawonien', 'ca': 'Eslavònia', 'ro': 'Slavonia', //
        'hu': 'Szlavónia', 'cs': 'Slavonie', 'sk': 'Slavónia', //
        'bg': 'Славония', 'sr': 'Славонија', 'nl': 'Slavonië', //
        'pl': 'Slawonia', 'uk': 'Славонія', 'da': 'Slavonien', //
        'sv': 'Slavonien', 'nb': 'Slavonia', 'fi': 'Slavonia',
      },
    ),
    WineRegion('Plešivica'),
    WineRegion('Moslavina'),
    WineRegion(
      'Hrvatsko primorje',
      it: 'Litorale croato',
      en: 'Croatian Coast',
      pt: 'Litoral croata',
    ),
  ],
  // Canonical names are the Latin transliterations; Georgian shows the
  // names in its own script.
  'GE': [
    WineRegion(
      'Kakheti',
      it: 'Cachezia',
      pt: 'Caquécia',
      names: {
        'fr': 'Kakhétie', 'es': 'Kajetia', 'de': 'Kachetien', //
        'ca': 'Kakhètia', 'ro': 'Kahetia', 'cs': 'Kachetie', //
        'sk': 'Kachetia', 'bg': 'Кахетия', 'sr': 'Кахетија', //
        'ka': 'კახეთი', 'nl': 'Kachetië', 'pl': 'Kachetia', //
        'uk': 'Кахетія', 'sv': 'Kachetien', 'fi': 'Kahetia',
      },
    ),
    WineRegion(
      'Kartli',
      names: {'bg': 'Картли', 'sr': 'Картли', 'ka': 'ქართლი', 'uk': 'Картлі'},
    ),
    WineRegion(
      'Imereti',
      it: 'Imerezia',
      names: {
        'fr': 'Iméréthie', 'de': 'Imeretien', 'bg': 'Имеретия', //
        'sr': 'Имеретија', 'ka': 'იმერეთი', 'pl': 'Imeretia', //
        'uk': 'Імеретія',
      },
    ),
    WineRegion('Racha-Lechkhumi', names: {'ka': 'რაჭა-ლეჩხუმი'}),
  ],
  'US': [
    WineRegion('Napa Valley', aliases: ['Napa']),
    WineRegion('Sonoma', aliases: ['Sonoma County']),
    WineRegion(
      'California',
      pt: 'Califórnia',
      names: {
        'fr': 'Californie', 'de': 'Kalifornien', 'ca': 'Califòrnia', //
        'el': 'Καλιφόρνια', 'hu': 'Kalifornia', 'hr': 'Kalifornija', //
        'sl': 'Kalifornija', 'cs': 'Kalifornie', 'sk': 'Kalifornia', //
        'bg': 'Калифорния', 'sr': 'Калифорнија', 'ka': 'კალიფორნია', //
        'nl': 'Californië', 'pl': 'Kalifornia', 'uk': 'Каліфорнія', //
        'da': 'Californien', 'sv': 'Kalifornien', 'fi': 'Kalifornia',
      },
    ),
    WineRegion('Oregon'),
    WineRegion('Washington', aliases: ['Washington State']),
    WineRegion(
      'New York',
      pt: 'Nova York',
      names: {
        'pt-PT': 'Nova Iorque', 'es': 'Nueva York', 'ca': 'Nova York', //
        'el': 'Νέα Υόρκη', 'bg': 'Ню Йорк', 'sr': 'Њујорк', //
        'ka': 'ნიუ-იორკი', 'pl': 'Nowy Jork', 'uk': 'Нью-Йорк',
      },
    ),
    WineRegion(
      'Virginia',
      pt: 'Virgínia',
      names: {'fr': 'Virginie', 'cs': 'Virginie', 'pl': 'Wirginia'},
    ),
  ],
  'CA': [
    WineRegion(
      'Ontario',
      pt: 'Ontário',
      names: {'bg': 'Онтарио', 'sr': 'Онтарио', 'uk': 'Онтаріо'},
      aliases: ['Niagara Peninsula'],
    ),
    WineRegion(
      'British Columbia',
      it: 'Columbia Britannica',
      pt: 'Colúmbia Britânica',
      names: {
        'fr': 'Colombie-Britannique', 'es': 'Columbia Británica', //
        'ca': 'Colúmbia Britànica', 'hr': 'Britanska Kolumbija', //
        'sl': 'Britanska Kolumbija', 'cs': 'Britská Kolumbie', //
        'sk': 'Britská Kolumbia', 'bg': 'Британска Колумбия', //
        'sr': 'Британска Колумбија', 'pl': 'Kolumbia Brytyjska', //
        'uk': 'Британська Колумбія',
      },
      aliases: ['Okanagan Valley'],
    ),
    WineRegion(
      'Québec',
      en: 'Quebec',
      pt: 'Quebec',
      names: {
        'es': 'Quebec', 'ca': 'Quebec', 'bg': 'Квебек', 'sr': 'Квебек', //
        'nl': 'Quebec', 'pl': 'Quebec', 'uk': 'Квебек',
      },
    ),
    WineRegion(
      'Nova Scotia',
      it: 'Nuova Scozia',
      pt: 'Nova Escócia',
      names: {
        'fr': 'Nouvelle-Écosse', 'es': 'Nueva Escocia', //
        'de': 'Neuschottland', 'ca': 'Nova Escòcia', //
        'cs': 'Nové Skotsko', 'sk': 'Nové Škótsko', 'pl': 'Nowa Szkocja',
      },
    ),
  ],
  // FR1.2 example plus La Rioja and Catamarca (mockup 2).
  'AR': [
    WineRegion(
      'Mendoza',
      names: {'bg': 'Мендоса', 'sr': 'Мендоса', 'uk': 'Мендоса'},
    ),
    WineRegion('Salta'),
    WineRegion('San Juan'),
    WineRegion('La Rioja'),
    WineRegion('Catamarca'),
    WineRegion(
      'Patagonia',
      pt: 'Patagônia',
      names: {
        'pt-PT': 'Patagónia', 'fr': 'Patagonie', 'de': 'Patagonien', //
        'ca': 'Patagònia', 'el': 'Παταγονία', 'hu': 'Patagónia', //
        'hr': 'Patagonija', 'sl': 'Patagonija', 'cs': 'Patagonie', //
        'sk': 'Patagónia', 'bg': 'Патагония', 'sr': 'Патагонија', //
        'nl': 'Patagonië', 'uk': 'Патагонія', 'da': 'Patagonien', //
        'sv': 'Patagonien',
      },
      aliases: ['Neuquén'],
    ),
  ],
  'CL': [
    WineRegion(
      'Valle del Maipo',
      en: 'Maipo Valley',
      pt: 'Vale do Maipo',
      aliases: ['Maipo'],
    ),
    WineRegion(
      'Valle de Colchagua',
      it: 'Valle di Colchagua',
      en: 'Colchagua Valley',
      pt: 'Vale de Colchagua',
      aliases: ['Colchagua', 'Valle del Colchagua'],
    ),
    WineRegion(
      'Valle de Casablanca',
      it: 'Valle di Casablanca',
      en: 'Casablanca Valley',
      pt: 'Vale de Casablanca',
      aliases: ['Casablanca'],
    ),
    WineRegion(
      'Valle de Aconcagua',
      it: "Valle dell'Aconcagua",
      en: 'Aconcagua Valley',
      pt: 'Vale do Aconcágua',
      aliases: ['Aconcagua'],
    ),
    WineRegion(
      'Valle de Cachapoal',
      it: 'Valle di Cachapoal',
      en: 'Cachapoal Valley',
      pt: 'Vale de Cachapoal',
      aliases: ['Cachapoal'],
    ),
    WineRegion(
      'Valle del Maule',
      en: 'Maule Valley',
      pt: 'Vale do Maule',
      aliases: ['Maule'],
    ),
    WineRegion(
      'Valle de Leyda',
      it: 'Valle di Leyda',
      en: 'Leyda Valley',
      pt: 'Vale de Leyda',
      aliases: ['Leyda'],
    ),
    WineRegion(
      'Valle del Limarí',
      en: 'Limarí Valley',
      pt: 'Vale do Limarí',
      aliases: ['Limarí'],
    ),
  ],
  // FR1.2 example plus the other official Brazilian wine areas.
  'BR': [
    WineRegion('Serra Gaúcha'),
    WineRegion('Campanha Gaúcha', aliases: ['Campanha']),
    WineRegion(
      'Vale do São Francisco',
      it: 'Valle del São Francisco',
      en: 'São Francisco Valley',
    ),
    WineRegion('Serra do Sudeste'),
    WineRegion('Campos de Cima da Serra'),
    WineRegion('Planalto Catarinense'),
  ],
  'UY': [
    WineRegion('Canelones'),
    WineRegion('Montevideo', pt: 'Montevidéu', names: {'pt-PT': 'Montevideu'}),
    WineRegion('Maldonado'),
    WineRegion('Colonia', pt: 'Colônia', names: {'pt-PT': 'Colónia'}),
    WineRegion('Rivera'),
    WineRegion('San José', pt: 'São José'),
  ],
  'AU': [
    WineRegion('Barossa Valley', aliases: ['Barossa']),
    WineRegion('McLaren Vale'),
    WineRegion('Eden Valley'),
    WineRegion('Clare Valley'),
    WineRegion('Coonawarra'),
    WineRegion('Hunter Valley'),
    WineRegion('Yarra Valley'),
    WineRegion('Margaret River'),
    WineRegion(
      'Tasmania',
      pt: 'Tasmânia',
      names: {
        'fr': 'Tasmanie', 'de': 'Tasmanien', 'ca': 'Tasmània', //
        'el': 'Τασμανία', 'hr': 'Tasmanija', 'sl': 'Tasmanija', //
        'cs': 'Tasmánie', 'sk': 'Tasmánia', 'bg': 'Тасмания', //
        'sr': 'Тасманија', 'nl': 'Tasmanië', 'uk': 'Тасманія', //
        'da': 'Tasmanien', 'sv': 'Tasmanien',
      },
    ),
  ],
  'NZ': [
    WineRegion('Marlborough'),
    WineRegion("Hawke's Bay"),
    WineRegion('Central Otago'),
    WineRegion('Wairarapa', aliases: ['Martinborough']),
    WineRegion('Gisborne'),
    WineRegion('Nelson'),
    WineRegion('North Canterbury', aliases: ['Waipara']),
  ],
  'ZA': [
    WineRegion('Stellenbosch'),
    WineRegion('Paarl'),
    WineRegion('Franschhoek'),
    WineRegion('Constantia'),
    WineRegion('Swartland'),
    WineRegion('Elgin'),
    WineRegion('Walker Bay', aliases: ['Hemel-en-Aarde']),
    WineRegion('Robertson'),
  ],
};

/// The 249 countries and territories of ISO 3166-1, by code, with their
/// names in Italian, English and Brazilian Portuguese.
const List<OriginCountry> _countries = [
  OriginCountry('AD', 'Andorra', 'Andorra', 'Andorra'),
  OriginCountry(
    'AE',
    'Emirati Arabi Uniti',
    'United Arab Emirates',
    'Emirados Árabes Unidos',
  ),
  OriginCountry('AF', 'Afghanistan', 'Afghanistan', 'Afeganistão'),
  OriginCountry(
    'AG',
    'Antigua e Barbuda',
    'Antigua and Barbuda',
    'Antígua e Barbuda',
  ),
  OriginCountry('AI', 'Anguilla', 'Anguilla', 'Anguila'),
  OriginCountry('AL', 'Albania', 'Albania', 'Albânia'),
  OriginCountry('AM', 'Armenia', 'Armenia', 'Armênia'),
  OriginCountry('AO', 'Angola', 'Angola', 'Angola'),
  OriginCountry('AQ', 'Antartide', 'Antarctica', 'Antártida'),
  OriginCountry('AR', 'Argentina', 'Argentina', 'Argentina'),
  OriginCountry('AS', 'Samoa Americane', 'American Samoa', 'Samoa Americana'),
  OriginCountry('AT', 'Austria', 'Austria', 'Áustria'),
  OriginCountry('AU', 'Australia', 'Australia', 'Austrália'),
  OriginCountry('AW', 'Aruba', 'Aruba', 'Aruba'),
  OriginCountry('AX', 'Isole Åland', 'Åland Islands', 'Ilhas Aland'),
  OriginCountry('AZ', 'Azerbaigian', 'Azerbaijan', 'Azerbaijão'),
  OriginCountry(
    'BA',
    'Bosnia ed Erzegovina',
    'Bosnia and Herzegovina',
    'Bósnia e Herzegovina',
  ),
  OriginCountry('BB', 'Barbados', 'Barbados', 'Barbados'),
  OriginCountry('BD', 'Bangladesh', 'Bangladesh', 'Bangladesh'),
  OriginCountry('BE', 'Belgio', 'Belgium', 'Bélgica'),
  OriginCountry('BF', 'Burkina Faso', 'Burkina Faso', 'Burkina Faso'),
  OriginCountry('BG', 'Bulgaria', 'Bulgaria', 'Bulgária'),
  OriginCountry('BH', 'Bahrein', 'Bahrain', 'Bahrein'),
  OriginCountry('BI', 'Burundi', 'Burundi', 'Burundi'),
  OriginCountry('BJ', 'Benin', 'Benin', 'Benin'),
  OriginCountry('BL', 'Saint-Barthélemy', 'Saint Barthélemy', 'São Bartolomeu'),
  OriginCountry('BM', 'Bermuda', 'Bermuda', 'Bermudas'),
  OriginCountry('BN', 'Brunei', 'Brunei', 'Brunei'),
  OriginCountry('BO', 'Bolivia', 'Bolivia', 'Bolívia'),
  OriginCountry(
    'BQ',
    'Caraibi olandesi',
    'Caribbean Netherlands',
    'Países Baixos Caribenhos',
  ),
  OriginCountry('BR', 'Brasile', 'Brazil', 'Brasil'),
  OriginCountry('BS', 'Bahamas', 'Bahamas', 'Bahamas'),
  OriginCountry('BT', 'Bhutan', 'Bhutan', 'Butão'),
  OriginCountry('BV', 'Isola Bouvet', 'Bouvet Island', 'Ilha Bouvet'),
  OriginCountry('BW', 'Botswana', 'Botswana', 'Botsuana'),
  OriginCountry('BY', 'Bielorussia', 'Belarus', 'Bielorrússia'),
  OriginCountry('BZ', 'Belize', 'Belize', 'Belize'),
  OriginCountry('CA', 'Canada', 'Canada', 'Canadá'),
  OriginCountry(
    'CC',
    'Isole Cocos (Keeling)',
    'Cocos (Keeling) Islands',
    'Ilhas Cocos (Keeling)',
  ),
  OriginCountry(
    'CD',
    'Repubblica Democratica del Congo',
    'DR Congo',
    'República Democrática do Congo',
  ),
  OriginCountry(
    'CF',
    'Repubblica Centrafricana',
    'Central African Republic',
    'República Centro-Africana',
  ),
  OriginCountry('CG', 'Congo', 'Republic of the Congo', 'República do Congo'),
  OriginCountry('CH', 'Svizzera', 'Switzerland', 'Suíça'),
  OriginCountry('CI', "Costa d'Avorio", "Côte d'Ivoire", 'Costa do Marfim'),
  OriginCountry('CK', 'Isole Cook', 'Cook Islands', 'Ilhas Cook'),
  OriginCountry('CL', 'Cile', 'Chile', 'Chile'),
  OriginCountry('CM', 'Camerun', 'Cameroon', 'Camarões'),
  OriginCountry('CN', 'Cina', 'China', 'China'),
  OriginCountry('CO', 'Colombia', 'Colombia', 'Colômbia'),
  OriginCountry('CR', 'Costa Rica', 'Costa Rica', 'Costa Rica'),
  OriginCountry('CU', 'Cuba', 'Cuba', 'Cuba'),
  OriginCountry('CV', 'Capo Verde', 'Cape Verde', 'Cabo Verde'),
  OriginCountry('CW', 'Curaçao', 'Curaçao', 'Curaçao'),
  OriginCountry('CX', 'Isola di Natale', 'Christmas Island', 'Ilha Christmas'),
  OriginCountry('CY', 'Cipro', 'Cyprus', 'Chipre'),
  OriginCountry('CZ', 'Cechia', 'Czechia', 'Tchéquia'),
  OriginCountry('DE', 'Germania', 'Germany', 'Alemanha'),
  OriginCountry('DJ', 'Gibuti', 'Djibouti', 'Djibuti'),
  OriginCountry('DK', 'Danimarca', 'Denmark', 'Dinamarca'),
  OriginCountry('DM', 'Dominica', 'Dominica', 'Dominica'),
  OriginCountry(
    'DO',
    'Repubblica Dominicana',
    'Dominican Republic',
    'República Dominicana',
  ),
  OriginCountry('DZ', 'Algeria', 'Algeria', 'Argélia'),
  OriginCountry('EC', 'Ecuador', 'Ecuador', 'Equador'),
  OriginCountry('EE', 'Estonia', 'Estonia', 'Estônia'),
  OriginCountry('EG', 'Egitto', 'Egypt', 'Egito'),
  OriginCountry(
    'EH',
    'Sahara Occidentale',
    'Western Sahara',
    'Saara Ocidental',
  ),
  OriginCountry('ER', 'Eritrea', 'Eritrea', 'Eritreia'),
  OriginCountry('ES', 'Spagna', 'Spain', 'Espanha'),
  OriginCountry('ET', 'Etiopia', 'Ethiopia', 'Etiópia'),
  OriginCountry('FI', 'Finlandia', 'Finland', 'Finlândia'),
  OriginCountry('FJ', 'Figi', 'Fiji', 'Fiji'),
  OriginCountry('FK', 'Isole Falkland', 'Falkland Islands', 'Ilhas Malvinas'),
  OriginCountry('FM', 'Micronesia', 'Micronesia', 'Micronésia'),
  OriginCountry('FO', 'Isole Fær Øer', 'Faroe Islands', 'Ilhas Faroé'),
  OriginCountry('FR', 'Francia', 'France', 'França'),
  OriginCountry('GA', 'Gabon', 'Gabon', 'Gabão'),
  OriginCountry('GB', 'Regno Unito', 'United Kingdom', 'Reino Unido'),
  OriginCountry('GD', 'Grenada', 'Grenada', 'Granada'),
  OriginCountry('GE', 'Georgia', 'Georgia', 'Geórgia'),
  OriginCountry('GF', 'Guyana francese', 'French Guiana', 'Guiana Francesa'),
  OriginCountry('GG', 'Guernsey', 'Guernsey', 'Guernsey'),
  OriginCountry('GH', 'Ghana', 'Ghana', 'Gana'),
  OriginCountry('GI', 'Gibilterra', 'Gibraltar', 'Gibraltar'),
  OriginCountry('GL', 'Groenlandia', 'Greenland', 'Groenlândia'),
  OriginCountry('GM', 'Gambia', 'Gambia', 'Gâmbia'),
  OriginCountry('GN', 'Guinea', 'Guinea', 'Guiné'),
  OriginCountry('GP', 'Guadalupa', 'Guadeloupe', 'Guadalupe'),
  OriginCountry(
    'GQ',
    'Guinea Equatoriale',
    'Equatorial Guinea',
    'Guiné Equatorial',
  ),
  OriginCountry('GR', 'Grecia', 'Greece', 'Grécia'),
  OriginCountry(
    'GS',
    'Georgia del Sud e Sandwich Australi',
    'South Georgia and the South Sandwich Islands',
    'Ilhas Geórgia do Sul e Sandwich do Sul',
  ),
  OriginCountry('GT', 'Guatemala', 'Guatemala', 'Guatemala'),
  OriginCountry('GU', 'Guam', 'Guam', 'Guam'),
  OriginCountry('GW', 'Guinea-Bissau', 'Guinea-Bissau', 'Guiné-Bissau'),
  OriginCountry('GY', 'Guyana', 'Guyana', 'Guiana'),
  OriginCountry('HK', 'Hong Kong', 'Hong Kong', 'Hong Kong'),
  OriginCountry(
    'HM',
    'Isole Heard e McDonald',
    'Heard Island and McDonald Islands',
    'Ilhas Heard e McDonald',
  ),
  OriginCountry('HN', 'Honduras', 'Honduras', 'Honduras'),
  OriginCountry('HR', 'Croazia', 'Croatia', 'Croácia'),
  OriginCountry('HT', 'Haiti', 'Haiti', 'Haiti'),
  OriginCountry('HU', 'Ungheria', 'Hungary', 'Hungria'),
  OriginCountry('ID', 'Indonesia', 'Indonesia', 'Indonésia'),
  OriginCountry('IE', 'Irlanda', 'Ireland', 'Irlanda'),
  OriginCountry('IL', 'Israele', 'Israel', 'Israel'),
  OriginCountry('IM', 'Isola di Man', 'Isle of Man', 'Ilha de Man'),
  OriginCountry('IN', 'India', 'India', 'Índia'),
  OriginCountry(
    'IO',
    "Territorio britannico dell'Oceano Indiano",
    'British Indian Ocean Territory',
    'Território Britânico do Oceano Índico',
  ),
  OriginCountry('IQ', 'Iraq', 'Iraq', 'Iraque'),
  OriginCountry('IR', 'Iran', 'Iran', 'Irã'),
  OriginCountry('IS', 'Islanda', 'Iceland', 'Islândia'),
  OriginCountry('IT', 'Italia', 'Italy', 'Itália'),
  OriginCountry('JE', 'Jersey', 'Jersey', 'Jersey'),
  OriginCountry('JM', 'Giamaica', 'Jamaica', 'Jamaica'),
  OriginCountry('JO', 'Giordania', 'Jordan', 'Jordânia'),
  OriginCountry('JP', 'Giappone', 'Japan', 'Japão'),
  OriginCountry('KE', 'Kenya', 'Kenya', 'Quênia'),
  OriginCountry('KG', 'Kirghizistan', 'Kyrgyzstan', 'Quirguistão'),
  OriginCountry('KH', 'Cambogia', 'Cambodia', 'Camboja'),
  OriginCountry('KI', 'Kiribati', 'Kiribati', 'Kiribati'),
  OriginCountry('KM', 'Comore', 'Comoros', 'Comores'),
  OriginCountry(
    'KN',
    'Saint Kitts e Nevis',
    'Saint Kitts and Nevis',
    'São Cristóvão e Névis',
  ),
  OriginCountry('KP', 'Corea del Nord', 'North Korea', 'Coreia do Norte'),
  OriginCountry('KR', 'Corea del Sud', 'South Korea', 'Coreia do Sul'),
  OriginCountry('KW', 'Kuwait', 'Kuwait', 'Kuwait'),
  OriginCountry('KY', 'Isole Cayman', 'Cayman Islands', 'Ilhas Cayman'),
  OriginCountry('KZ', 'Kazakistan', 'Kazakhstan', 'Cazaquistão'),
  OriginCountry('LA', 'Laos', 'Laos', 'Laos'),
  OriginCountry('LB', 'Libano', 'Lebanon', 'Líbano'),
  OriginCountry('LC', 'Santa Lucia', 'Saint Lucia', 'Santa Lúcia'),
  OriginCountry('LI', 'Liechtenstein', 'Liechtenstein', 'Liechtenstein'),
  OriginCountry('LK', 'Sri Lanka', 'Sri Lanka', 'Sri Lanka'),
  OriginCountry('LR', 'Liberia', 'Liberia', 'Libéria'),
  OriginCountry('LS', 'Lesotho', 'Lesotho', 'Lesoto'),
  OriginCountry('LT', 'Lituania', 'Lithuania', 'Lituânia'),
  OriginCountry('LU', 'Lussemburgo', 'Luxembourg', 'Luxemburgo'),
  OriginCountry('LV', 'Lettonia', 'Latvia', 'Letônia'),
  OriginCountry('LY', 'Libia', 'Libya', 'Líbia'),
  OriginCountry('MA', 'Marocco', 'Morocco', 'Marrocos'),
  OriginCountry('MC', 'Monaco', 'Monaco', 'Mônaco'),
  OriginCountry('MD', 'Moldavia', 'Moldova', 'Moldávia'),
  OriginCountry('ME', 'Montenegro', 'Montenegro', 'Montenegro'),
  OriginCountry('MF', 'Saint-Martin', 'Saint Martin', 'São Martinho'),
  OriginCountry('MG', 'Madagascar', 'Madagascar', 'Madagascar'),
  OriginCountry('MH', 'Isole Marshall', 'Marshall Islands', 'Ilhas Marshall'),
  OriginCountry(
    'MK',
    'Macedonia del Nord',
    'North Macedonia',
    'Macedônia do Norte',
  ),
  OriginCountry('ML', 'Mali', 'Mali', 'Mali'),
  OriginCountry('MM', 'Myanmar', 'Myanmar', 'Mianmar'),
  OriginCountry('MN', 'Mongolia', 'Mongolia', 'Mongólia'),
  OriginCountry('MO', 'Macao', 'Macao', 'Macau'),
  OriginCountry(
    'MP',
    'Isole Marianne Settentrionali',
    'Northern Mariana Islands',
    'Ilhas Marianas do Norte',
  ),
  OriginCountry('MQ', 'Martinica', 'Martinique', 'Martinica'),
  OriginCountry('MR', 'Mauritania', 'Mauritania', 'Mauritânia'),
  OriginCountry('MS', 'Montserrat', 'Montserrat', 'Montserrat'),
  OriginCountry('MT', 'Malta', 'Malta', 'Malta'),
  OriginCountry('MU', 'Mauritius', 'Mauritius', 'Maurício'),
  OriginCountry('MV', 'Maldive', 'Maldives', 'Maldivas'),
  OriginCountry('MW', 'Malawi', 'Malawi', 'Malawi'),
  OriginCountry('MX', 'Messico', 'Mexico', 'México'),
  OriginCountry('MY', 'Malaysia', 'Malaysia', 'Malásia'),
  OriginCountry('MZ', 'Mozambico', 'Mozambique', 'Moçambique'),
  OriginCountry('NA', 'Namibia', 'Namibia', 'Namíbia'),
  OriginCountry('NC', 'Nuova Caledonia', 'New Caledonia', 'Nova Caledônia'),
  OriginCountry('NE', 'Niger', 'Niger', 'Níger'),
  OriginCountry('NF', 'Isola Norfolk', 'Norfolk Island', 'Ilha Norfolk'),
  OriginCountry('NG', 'Nigeria', 'Nigeria', 'Nigéria'),
  OriginCountry('NI', 'Nicaragua', 'Nicaragua', 'Nicarágua'),
  OriginCountry('NL', 'Paesi Bassi', 'Netherlands', 'Países Baixos'),
  OriginCountry('NO', 'Norvegia', 'Norway', 'Noruega'),
  OriginCountry('NP', 'Nepal', 'Nepal', 'Nepal'),
  OriginCountry('NR', 'Nauru', 'Nauru', 'Nauru'),
  OriginCountry('NU', 'Niue', 'Niue', 'Niue'),
  OriginCountry('NZ', 'Nuova Zelanda', 'New Zealand', 'Nova Zelândia'),
  OriginCountry('OM', 'Oman', 'Oman', 'Omã'),
  OriginCountry('PA', 'Panama', 'Panama', 'Panamá'),
  OriginCountry('PE', 'Perù', 'Peru', 'Peru'),
  OriginCountry(
    'PF',
    'Polinesia francese',
    'French Polynesia',
    'Polinésia Francesa',
  ),
  OriginCountry(
    'PG',
    'Papua Nuova Guinea',
    'Papua New Guinea',
    'Papua-Nova Guiné',
  ),
  OriginCountry('PH', 'Filippine', 'Philippines', 'Filipinas'),
  OriginCountry('PK', 'Pakistan', 'Pakistan', 'Paquistão'),
  OriginCountry('PL', 'Polonia', 'Poland', 'Polônia'),
  OriginCountry(
    'PM',
    'Saint-Pierre e Miquelon',
    'Saint Pierre and Miquelon',
    'São Pedro e Miquelão',
  ),
  OriginCountry('PN', 'Isole Pitcairn', 'Pitcairn Islands', 'Ilhas Pitcairn'),
  OriginCountry('PR', 'Porto Rico', 'Puerto Rico', 'Porto Rico'),
  OriginCountry('PS', 'Palestina', 'Palestine', 'Palestina'),
  OriginCountry('PT', 'Portogallo', 'Portugal', 'Portugal'),
  OriginCountry('PW', 'Palau', 'Palau', 'Palau'),
  OriginCountry('PY', 'Paraguay', 'Paraguay', 'Paraguai'),
  OriginCountry('QA', 'Qatar', 'Qatar', 'Catar'),
  OriginCountry('RE', 'Riunione', 'Réunion', 'Reunião'),
  OriginCountry('RO', 'Romania', 'Romania', 'Romênia'),
  OriginCountry('RS', 'Serbia', 'Serbia', 'Sérvia'),
  OriginCountry('RU', 'Russia', 'Russia', 'Rússia'),
  OriginCountry('RW', 'Ruanda', 'Rwanda', 'Ruanda'),
  OriginCountry('SA', 'Arabia Saudita', 'Saudi Arabia', 'Arábia Saudita'),
  OriginCountry('SB', 'Isole Salomone', 'Solomon Islands', 'Ilhas Salomão'),
  OriginCountry('SC', 'Seychelles', 'Seychelles', 'Seicheles'),
  OriginCountry('SD', 'Sudan', 'Sudan', 'Sudão'),
  OriginCountry('SE', 'Svezia', 'Sweden', 'Suécia'),
  OriginCountry('SG', 'Singapore', 'Singapore', 'Singapura'),
  OriginCountry(
    'SH',
    "Sant'Elena, Ascensione e Tristan da Cunha",
    'Saint Helena, Ascension and Tristan da Cunha',
    'Santa Helena, Ascensão e Tristão da Cunha',
  ),
  OriginCountry('SI', 'Slovenia', 'Slovenia', 'Eslovênia'),
  OriginCountry(
    'SJ',
    'Svalbard e Jan Mayen',
    'Svalbard and Jan Mayen',
    'Svalbard e Jan Mayen',
  ),
  OriginCountry('SK', 'Slovacchia', 'Slovakia', 'Eslováquia'),
  OriginCountry('SL', 'Sierra Leone', 'Sierra Leone', 'Serra Leoa'),
  OriginCountry('SM', 'San Marino', 'San Marino', 'San Marino'),
  OriginCountry('SN', 'Senegal', 'Senegal', 'Senegal'),
  OriginCountry('SO', 'Somalia', 'Somalia', 'Somália'),
  OriginCountry('SR', 'Suriname', 'Suriname', 'Suriname'),
  OriginCountry('SS', 'Sudan del Sud', 'South Sudan', 'Sudão do Sul'),
  OriginCountry(
    'ST',
    'São Tomé e Príncipe',
    'São Tomé and Príncipe',
    'São Tomé e Príncipe',
  ),
  OriginCountry('SV', 'El Salvador', 'El Salvador', 'El Salvador'),
  OriginCountry('SX', 'Sint Maarten', 'Sint Maarten', 'Sint Maarten'),
  OriginCountry('SY', 'Siria', 'Syria', 'Síria'),
  OriginCountry('SZ', 'Eswatini', 'Eswatini', 'Essuatíni'),
  OriginCountry(
    'TC',
    'Isole Turks e Caicos',
    'Turks and Caicos Islands',
    'Ilhas Turcas e Caicos',
  ),
  OriginCountry('TD', 'Ciad', 'Chad', 'Chade'),
  OriginCountry(
    'TF',
    'Terre australi francesi',
    'French Southern Territories',
    'Terras Austrais Francesas',
  ),
  OriginCountry('TG', 'Togo', 'Togo', 'Togo'),
  OriginCountry('TH', 'Thailandia', 'Thailand', 'Tailândia'),
  OriginCountry('TJ', 'Tagikistan', 'Tajikistan', 'Tadjiquistão'),
  OriginCountry('TK', 'Tokelau', 'Tokelau', 'Tokelau'),
  OriginCountry('TL', 'Timor Est', 'Timor-Leste', 'Timor-Leste'),
  OriginCountry('TM', 'Turkmenistan', 'Turkmenistan', 'Turcomenistão'),
  OriginCountry('TN', 'Tunisia', 'Tunisia', 'Tunísia'),
  OriginCountry('TO', 'Tonga', 'Tonga', 'Tonga'),
  OriginCountry('TR', 'Turchia', 'Türkiye', 'Turquia'),
  OriginCountry(
    'TT',
    'Trinidad e Tobago',
    'Trinidad and Tobago',
    'Trinidad e Tobago',
  ),
  OriginCountry('TV', 'Tuvalu', 'Tuvalu', 'Tuvalu'),
  OriginCountry('TW', 'Taiwan', 'Taiwan', 'Taiwan'),
  OriginCountry('TZ', 'Tanzania', 'Tanzania', 'Tanzânia'),
  OriginCountry('UA', 'Ucraina', 'Ukraine', 'Ucrânia'),
  OriginCountry('UG', 'Uganda', 'Uganda', 'Uganda'),
  OriginCountry(
    'UM',
    'Isole minori esterne degli Stati Uniti',
    'U.S. Outlying Islands',
    'Ilhas Menores Distantes dos EUA',
  ),
  OriginCountry('US', 'Stati Uniti', 'United States', 'Estados Unidos'),
  OriginCountry('UY', 'Uruguay', 'Uruguay', 'Uruguai'),
  OriginCountry('UZ', 'Uzbekistan', 'Uzbekistan', 'Uzbequistão'),
  OriginCountry(
    'VA',
    'Città del Vaticano',
    'Vatican City',
    'Cidade do Vaticano',
  ),
  OriginCountry(
    'VC',
    'Saint Vincent e Grenadine',
    'Saint Vincent and the Grenadines',
    'São Vicente e Granadinas',
  ),
  OriginCountry('VE', 'Venezuela', 'Venezuela', 'Venezuela'),
  OriginCountry(
    'VG',
    'Isole Vergini britanniche',
    'British Virgin Islands',
    'Ilhas Virgens Britânicas',
  ),
  OriginCountry(
    'VI',
    'Isole Vergini americane',
    'U.S. Virgin Islands',
    'Ilhas Virgens Americanas',
  ),
  OriginCountry('VN', 'Vietnam', 'Vietnam', 'Vietnã'),
  OriginCountry('VU', 'Vanuatu', 'Vanuatu', 'Vanuatu'),
  OriginCountry(
    'WF',
    'Wallis e Futuna',
    'Wallis and Futuna',
    'Wallis e Futuna',
  ),
  OriginCountry('WS', 'Samoa', 'Samoa', 'Samoa'),
  OriginCountry('YE', 'Yemen', 'Yemen', 'Iêmen'),
  OriginCountry('YT', 'Mayotte', 'Mayotte', 'Mayotte'),
  OriginCountry('ZA', 'Sudafrica', 'South Africa', 'África do Sul'),
  OriginCountry('ZM', 'Zambia', 'Zambia', 'Zâmbia'),
  OriginCountry('ZW', 'Zimbabwe', 'Zimbabwe', 'Zimbábue'),
];
