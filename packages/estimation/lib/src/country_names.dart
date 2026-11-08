// Names of the wine countries in the languages of wine labels
// (label-autofill-windows BR1.2, BR1.7, D1): Italian, English, French,
// Spanish, Portuguese, German and the native name. Used to read "Product of
// Argentina" or "Produit de France" and as the country indicator next to a
// weak alias. The app's `WineOrigins` reads it too, so the two never drift.

import 'recognizer.dart' show tokenizeAll;

/// Normalised country names (as `normalizeWineText` gives them) and their
/// ISO 3166-1 alpha-2 code.
const Map<String, String> wineCountryNames = {
  'italy': 'IT', 'italia': 'IT', 'italie': 'IT', 'italien': 'IT', //
  'france': 'FR', 'francia': 'FR', 'frankreich': 'FR', 'franca': 'FR', //
  'spain': 'ES', 'spagna': 'ES', 'espana': 'ES', 'espagne': 'ES', //
  'spanien': 'ES', 'espanha': 'ES', //
  'portugal': 'PT', 'portogallo': 'PT', //
  'germany': 'DE', 'germania': 'DE', 'allemagne': 'DE', //
  'deutschland': 'DE', 'alemania': 'DE', 'alemanha': 'DE', //
  'austria': 'AT', 'autriche': 'AT', 'osterreich': 'AT', //
  'oesterreich': 'AT', //
  'switzerland': 'CH', 'svizzera': 'CH', 'suisse': 'CH', 'schweiz': 'CH', //
  'suiza': 'CH', 'suica': 'CH', //
  'greece': 'GR', 'grecia': 'GR', 'grece': 'GR', 'griechenland': 'GR', //
  'hellas': 'GR', 'grecia ellada': 'GR', //
  'hungary': 'HU', 'ungheria': 'HU', 'hongrie': 'HU', 'ungarn': 'HU', //
  'hungria': 'HU', 'magyarorszag': 'HU', //
  'slovenia': 'SI', 'slovenie': 'SI', 'slowenien': 'SI', 'eslovenia': 'SI', //
  'slovenija': 'SI', //
  'croatia': 'HR', 'croazia': 'HR', 'croatie': 'HR', 'kroatien': 'HR', //
  'croacia': 'HR', 'hrvatska': 'HR', //
  'georgia': 'GE', 'georgie': 'GE', 'georgien': 'GE', 'sakartvelo': 'GE', //
  'united states': 'US', 'usa': 'US', 'u s a': 'US', 'america': 'US', //
  'united states of america': 'US', 'stati uniti': 'US', //
  'etats unis': 'US', 'estados unidos': 'US', 'vereinigte staaten': 'US', //
  'canada': 'CA', 'kanada': 'CA', //
  'argentina': 'AR', 'argentine': 'AR', 'argentinien': 'AR', //
  'chile': 'CL', 'cile': 'CL', 'chili': 'CL', //
  'brazil': 'BR', 'brasile': 'BR', 'bresil': 'BR', 'brasilien': 'BR', //
  'brasil': 'BR', //
  'uruguay': 'UY', 'uruguai': 'UY', //
  'australia': 'AU', 'australie': 'AU', 'australien': 'AU', //
  'new zealand': 'NZ', 'nuova zelanda': 'NZ', 'nouvelle zelande': 'NZ', //
  'neuseeland': 'NZ', 'nueva zelanda': 'NZ', 'nova zelandia': 'NZ', //
  'south africa': 'ZA', 'sudafrica': 'ZA', 'afrique du sud': 'ZA', //
  'sudafrika': 'ZA', 'africa do sul': 'ZA', //
  'lebanon': 'LB', 'libano': 'LB', 'liban': 'LB', //
  'israel': 'IL', 'israele': 'IL', //
  'england': 'GB', 'inghilterra': 'GB', 'angleterre': 'GB', //
  'united kingdom': 'GB', 'regno unito': 'GB', //
  'moldova': 'MD', 'moldavia': 'MD', //
  'romania': 'RO', 'roumanie': 'RO', 'rumanien': 'RO', //
  'bulgaria': 'BG', 'bulgarie': 'BG', 'bulgarien': 'BG', //
  'mexico': 'MX', 'messico': 'MX', //
};

/// Every word of [wineCountryNames] that starts a name, for a quick check.
final Set<String> _firstWords = {
  for (final name in wineCountryNames.keys) name.split(' ').first,
};

/// The ISO code of the country named [text] (case, accents and
/// punctuation ignored), or `null`.
String? countryCodeOfName(String text) =>
    wineCountryNames[tokenizeAll(text).join(' ')];

/// The ISO codes of the country names found in [words], whole words only.
Set<String> countryCodesIn(List<String> words) {
  final codes = <String>{};
  for (var i = 0; i < words.length; i++) {
    if (!_firstWords.contains(words[i])) continue;
    for (var length = 4; length >= 1; length--) {
      if (i + length > words.length) continue;
      final code = wineCountryNames[words.sublist(i, i + length).join(' ')];
      if (code != null) {
        codes.add(code);
        break;
      }
    }
  }
  return codes;
}
