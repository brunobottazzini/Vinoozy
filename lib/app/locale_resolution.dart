import 'package:flutter/widgets.dart';

/// Languages of the interface (BR5.1). This list is the single source of the
/// language set: the ARB files, the generated localizations, the Android
/// locale declaration and the store listing folders are checked against it.
const List<Locale> appLocales = [
  Locale('en'),
  Locale('it'),
  Locale('pt', 'BR'),
  Locale('pt'),
  Locale('fr'),
  Locale('es'),
  Locale('de'),
  Locale('ca'),
  Locale('el'),
  Locale('ro'),
  Locale('hu'),
  Locale('hr'),
  Locale('sl'),
  Locale('cs'),
  Locale('sk'),
  Locale('bg'),
  Locale('sr'),
  Locale('ka'),
  Locale('nl'),
  Locale('pl'),
  Locale('uk'),
  Locale('da'),
  Locale('sv'),
  Locale('nb'),
  Locale('fi'),
];

const Locale fallbackLocale = Locale('en');

/// Language codes a phone may report for a language offered under another
/// code: Norwegian (`no`) and Nynorsk (`nn`) receive Bokmål.
const Map<String, String> _languageAliases = {'no': 'nb', 'nn': 'nb'};

/// BR5.1, wine-culture-languages FR1.4: the first language of the phone that
/// the app offers, in the phone's preference order. A locale matches its
/// exact language and country when offered (`pt-BR`), else the base language
/// (`fr-CA` receives `fr`, any other Portuguese receives `pt`); a language
/// that is not offered is skipped, and English is the fallback.
Locale resolveAppLocale(List<Locale>? preferred) {
  for (final locale in preferred ?? const <Locale>[]) {
    final match = _offeredLocaleFor(locale);
    if (match != null) return match;
  }
  return fallbackLocale;
}

/// The entry of [appLocales] that serves [locale], or `null`.
Locale? _offeredLocaleFor(Locale locale) {
  final language = _languageAliases[locale.languageCode] ?? locale.languageCode;
  Locale? base;
  for (final offered in appLocales) {
    if (offered.languageCode != language) continue;
    if (offered.countryCode == null) {
      base ??= offered;
    } else if (offered.countryCode == locale.countryCode) {
      return offered;
    }
  }
  return base;
}

/// Interface languages that Android must see under another tag
/// (wine-culture-languages FR2.2, loop-back 1). Android expands a tag without
/// region or script with its likely subtags, so a bare `pt` became `pt-BR`
/// and was merged with Brazilian Portuguese in the app language settings;
/// Serbian is declared with its script, Cyrillic, as the app is written in it.
const Map<String, String> _androidTagAliases = {'pt': 'pt-PT', 'sr': 'sr-Cyrl'};

/// The BCP 47 tag under which [locale], an entry of [appLocales], is declared
/// to Android in `android/app/src/main/res/xml/locales_config.xml`: the
/// language tag of the app (`fr`, `pt-BR`), except European Portuguese
/// (`pt-PT`) and Serbian (`sr-Cyrl`). Each tag resolves back to [locale]
/// through [resolveAppLocale] when Android passes it to the app.
String androidLocaleTagOf(Locale locale) {
  final tag = locale.toLanguageTag();
  return _androidTagAliases[tag] ?? tag;
}

/// The name of [locale] for the date and number formats of `intl`
/// (`pt_BR`, `el`). `intl` reads a bare `pt` as Brazilian Portuguese, so the
/// interface language `pt`, European Portuguese, is named `pt_PT`
/// (wine-culture-languages FR3.5).
String intlLocaleNameOf(Locale locale) =>
    locale.languageCode == 'pt' && locale.countryCode == null
    ? 'pt_PT'
    : locale.toString();
