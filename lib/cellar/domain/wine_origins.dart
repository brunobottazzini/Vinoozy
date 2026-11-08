import 'package:estimation/estimation.dart';

// Countries and wine regions of the ux-redesign intent (FR1.1-FR1.5): every
// list lives in the app code, so the pickers and the search work offline
// and cost no Firestore read (NFR3). The region lists, the canonical names
// and the denomination table are wine knowledge decided at Code Generation
// (project.md correction of 2026-11-04); the reasons are in code-summary.md
// of the intent. Pure Dart: no Flutter import.

/// A country or territory of ISO 3166-1 with its names in the three
/// interface languages (it, en, pt-BR).
class OriginCountry {
  const OriginCountry(this.code, this.it, this.en, this.pt);

  /// ISO 3166-1 alpha-2 code, two upper-case letters (the stored value).
  final String code;
  final String it;
  final String en;
  final String pt;

  /// The name in [languageCode] (`it`, `en` or `pt`); English otherwise.
  String nameIn(String languageCode) => switch (languageCode) {
    'it' => it,
    'pt' => pt,
    _ => en,
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
  const WineRegion(this.canonical, {this.it, this.en, this.pt, this.aliases});

  /// Stored value, e.g. `Bourgogne`, `Piemonte`, `Serra Gaúcha`.
  final String canonical;
  final String? it;
  final String? en;
  final String? pt;

  /// Other written forms recognised as this region (e.g. `Alto Adige`).
  final List<String>? aliases;

  /// The shown name in [languageCode], the canonical one when there is no
  /// translation.
  String nameIn(String languageCode) =>
      switch (languageCode) {
        'it' => it,
        'pt' => pt,
        _ => en,
      } ??
      canonical;

  /// Every written form: canonical, translations and aliases.
  Iterable<String> get forms => [canonical, ?it, ?en, ?pt, ...?aliases];

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
/// form used to compare names in it, en and pt-BR (search and matching).
String foldOriginText(String text) {
  final buffer = StringBuffer();
  var pendingSpace = false;
  for (final rune in text.toLowerCase().runes) {
    final folded = _folding[rune] ?? _plain(rune);
    if (folded == null) {
      pendingSpace = buffer.isNotEmpty;
      continue;
    }
    if (pendingSpace) buffer.write(' ');
    pendingSpace = false;
    buffer.write(folded);
  }
  return buffer.toString();
}

String? _plain(int rune) {
  final isLetter = rune >= 0x61 && rune <= 0x7A;
  final isDigit = rune >= 0x30 && rune <= 0x39;
  return isLetter || isDigit ? String.fromCharCode(rune) : null;
}

/// Latin-1 and Latin Extended-A letters of the country and region names.
const Map<int, String> _folding = {
  0xE0: 'a', 0xE1: 'a', 0xE2: 'a', 0xE3: 'a', 0xE4: 'a', 0xE5: 'a', //
  0xE6: 'ae', 0xE7: 'c', 0xE8: 'e', 0xE9: 'e', 0xEA: 'e', 0xEB: 'e', //
  0xEC: 'i', 0xED: 'i', 0xEE: 'i', 0xEF: 'i', 0xF1: 'n', 0xF2: 'o', //
  0xF3: 'o', 0xF4: 'o', 0xF5: 'o', 0xF6: 'o', 0xF8: 'o', 0xF9: 'u', //
  0xFA: 'u', 0xFB: 'u', 0xFC: 'u', 0xFD: 'y', 0xFF: 'y', 0xDF: 'ss', //
  0x101: 'a', 0x103: 'a', 0x105: 'a', 0x107: 'c', 0x10D: 'c', 0x111: 'd', //
  0x113: 'e', 0x117: 'e', 0x119: 'e', 0x11B: 'e', 0x11F: 'g', 0x12B: 'i', //
  0x131: 'i', 0x142: 'l', 0x144: 'n', 0x148: 'n', 0x14D: 'o', 0x151: 'o', //
  0x153: 'oe', 0x159: 'r', 0x15B: 's', 0x15F: 's', 0x161: 's', 0x163: 't', //
  0x165: 't', 0x16B: 'u', 0x16F: 'u', 0x171: 'u', 0x17A: 'z', 0x17C: 'z', //
  0x17E: 'z', 0x219: 's', 0x21B: 't',
};

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

  /// Countries whose name in any of the three languages contains [query],
  /// ignoring case and accents, or whose code equals it; the country of the
  /// code first, then by name in [languageCode]. An empty query returns
  /// every country.
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
            (foldOriginText(country.it).contains(needle) ||
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
    WineRegion('Piemonte', en: 'Piedmont'),
    WineRegion('Toscana', en: 'Tuscany'),
    WineRegion('Veneto'),
    WineRegion('Sicilia', en: 'Sicily', pt: 'Sicília'),
    WineRegion('Puglia', en: 'Apulia', pt: 'Apúlia'),
    WineRegion('Campania', pt: 'Campânia'),
    WineRegion('Friuli-Venezia Giulia', aliases: ['Friuli']),
    WineRegion(
      'Trentino-Alto Adige',
      en: 'Trentino-South Tyrol',
      pt: 'Trentino-Alto Ádige',
      aliases: ['Trentino', 'Alto Adige', 'Südtirol', 'South Tyrol'],
    ),
    WineRegion('Lombardia', en: 'Lombardy'),
    WineRegion('Sardegna', en: 'Sardinia', pt: 'Sardenha'),
    WineRegion('Abruzzo', pt: 'Abruzos'),
    WineRegion('Marche', pt: 'Marcas'),
    WineRegion('Umbria', pt: 'Úmbria'),
    WineRegion('Emilia-Romagna'),
    WineRegion('Lazio', pt: 'Lácio'),
    WineRegion('Basilicata'),
    WineRegion('Calabria', pt: 'Calábria'),
    WineRegion('Liguria', pt: 'Ligúria'),
    WineRegion("Valle d'Aosta", en: 'Aosta Valley', pt: 'Vale de Aosta'),
    WineRegion('Molise'),
  ],
  // The 11 regions named by FR1.2, French canonical names.
  'FR': [
    WineRegion('Bordeaux'),
    WineRegion('Bourgogne', it: 'Borgogna', en: 'Burgundy', pt: 'Borgonha'),
    WineRegion('Champagne'),
    WineRegion(
      'Vallée du Rhône',
      it: 'Valle del Rodano',
      en: 'Rhône Valley',
      pt: 'Vale do Ródano',
      aliases: ['Rhône'],
    ),
    WineRegion(
      'Vallée de la Loire',
      it: 'Valle della Loira',
      en: 'Loire Valley',
      pt: 'Vale do Loire',
      aliases: ['Loire'],
    ),
    WineRegion('Alsace', it: 'Alsazia', pt: 'Alsácia'),
    WineRegion(
      'Languedoc-Roussillon',
      it: 'Linguadoca-Rossiglione',
      aliases: ['Languedoc'],
    ),
    WineRegion('Provence', it: 'Provenza', pt: 'Provença'),
    WineRegion('Beaujolais'),
    WineRegion('Jura'),
    WineRegion(
      'Sud-Ouest',
      it: 'Sud-Ovest',
      en: 'South West France',
      pt: 'Sudoeste',
    ),
  ],
  'ES': [
    WineRegion('Rioja'),
    WineRegion('Ribera del Duero'),
    WineRegion('Priorat', aliases: ['Priorato']),
    WineRegion('Penedès'),
    WineRegion('Rías Baixas'),
    WineRegion('Rueda'),
    WineRegion('Toro'),
    WineRegion('Jerez', en: 'Jerez (Sherry)', aliases: ['Sherry']),
    WineRegion('La Mancha'),
    WineRegion('Navarra', en: 'Navarre'),
    WineRegion('Bierzo'),
  ],
  'PT': [
    WineRegion('Douro'),
    WineRegion('Vinho Verde'),
    WineRegion('Alentejo'),
    WineRegion('Dão'),
    WineRegion('Bairrada'),
    WineRegion('Lisboa', it: 'Lisbona', en: 'Lisbon'),
    WineRegion('Tejo', it: 'Tago', en: 'Tagus'),
    WineRegion(
      'Península de Setúbal',
      it: 'Penisola di Setúbal',
      en: 'Setúbal Peninsula',
    ),
    WineRegion('Madeira'),
    WineRegion('Açores', it: 'Azzorre', en: 'Azores'),
  ],
  // The 13 German Anbaugebiete.
  'DE': [
    WineRegion('Mosel', it: 'Mosella', pt: 'Mosela'),
    WineRegion('Rheingau'),
    WineRegion('Pfalz', it: 'Palatinato', en: 'Palatinate', pt: 'Palatinado'),
    WineRegion(
      'Rheinhessen',
      it: 'Assia Renana',
      en: 'Rhinehesse',
      pt: 'Hesse Renana',
    ),
    WineRegion('Nahe'),
    WineRegion('Baden'),
    WineRegion('Franken', it: 'Franconia', en: 'Franconia', pt: 'Francônia'),
    WineRegion('Württemberg'),
    WineRegion('Ahr'),
    WineRegion(
      'Mittelrhein',
      it: 'Medio Reno',
      en: 'Middle Rhine',
      pt: 'Médio Reno',
    ),
    WineRegion('Saale-Unstrut'),
    WineRegion('Sachsen', it: 'Sassonia', en: 'Saxony', pt: 'Saxônia'),
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
    WineRegion('Steiermark', it: 'Stiria', en: 'Styria', pt: 'Estíria'),
    WineRegion('Wien', it: 'Vienna', en: 'Vienna', pt: 'Viena'),
  ],
  'CH': [
    WineRegion('Valais', it: 'Vallese', aliases: ['Wallis']),
    WineRegion('Vaud'),
    WineRegion('Genève', it: 'Ginevra', en: 'Geneva', pt: 'Genebra'),
    WineRegion('Ticino'),
    WineRegion('Neuchâtel'),
    WineRegion('Graubünden', it: 'Grigioni', en: 'Grisons', pt: 'Grisões'),
    WineRegion('Schaffhausen', it: 'Sciaffusa'),
  ],
  'GR': [
    WineRegion('Santorini'),
    WineRegion('Naoussa'),
    WineRegion('Nemea'),
    WineRegion('Amyntaio'),
    WineRegion('Makedonia', it: 'Macedonia', en: 'Macedonia', pt: 'Macedônia'),
    WineRegion(
      'Peloponnisos',
      it: 'Peloponneso',
      en: 'Peloponnese',
      pt: 'Peloponeso',
    ),
    WineRegion('Kriti', it: 'Creta', en: 'Crete', pt: 'Creta'),
    WineRegion('Attiki', it: 'Attica', en: 'Attica', pt: 'Ática'),
    WineRegion('Kefalonia', it: 'Cefalonia', en: 'Cephalonia', pt: 'Cefalônia'),
  ],
  'HU': [
    WineRegion('Tokaj'),
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
    WineRegion('Istra', it: 'Istria', en: 'Istria', pt: 'Ístria'),
    WineRegion('Dalmacija', it: 'Dalmazia', en: 'Dalmatia', pt: 'Dalmácia'),
    WineRegion('Slavonija', it: 'Slavonia', en: 'Slavonia', pt: 'Eslavônia'),
    WineRegion('Plešivica'),
    WineRegion('Moslavina'),
    WineRegion(
      'Hrvatsko primorje',
      it: 'Litorale croato',
      en: 'Croatian Coast',
      pt: 'Litoral croata',
    ),
  ],
  'GE': [
    WineRegion('Kakheti', it: 'Cachezia', pt: 'Caquécia'),
    WineRegion('Kartli'),
    WineRegion('Imereti', it: 'Imerezia'),
    WineRegion('Racha-Lechkhumi'),
  ],
  'US': [
    WineRegion('Napa Valley', aliases: ['Napa']),
    WineRegion('Sonoma', aliases: ['Sonoma County']),
    WineRegion('California', pt: 'Califórnia'),
    WineRegion('Oregon'),
    WineRegion('Washington', aliases: ['Washington State']),
    WineRegion('New York', pt: 'Nova York'),
    WineRegion('Virginia', pt: 'Virgínia'),
  ],
  'CA': [
    WineRegion('Ontario', pt: 'Ontário', aliases: ['Niagara Peninsula']),
    WineRegion(
      'British Columbia',
      it: 'Columbia Britannica',
      pt: 'Colúmbia Britânica',
      aliases: ['Okanagan Valley'],
    ),
    WineRegion('Québec', en: 'Quebec', pt: 'Quebec'),
    WineRegion('Nova Scotia', it: 'Nuova Scozia', pt: 'Nova Escócia'),
  ],
  // FR1.2 example plus La Rioja and Catamarca (mockup 2).
  'AR': [
    WineRegion('Mendoza'),
    WineRegion('Salta'),
    WineRegion('San Juan'),
    WineRegion('La Rioja'),
    WineRegion('Catamarca'),
    WineRegion('Patagonia', pt: 'Patagônia', aliases: ['Neuquén']),
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
    WineRegion('Montevideo', pt: 'Montevidéu'),
    WineRegion('Maldonado'),
    WineRegion('Colonia', pt: 'Colônia'),
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
    WineRegion('Tasmania', pt: 'Tasmânia'),
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
