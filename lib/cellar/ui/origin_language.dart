import 'package:flutter/widgets.dart';

/// The origin language tag of [locale]: the key under which the names of
/// countries and wine regions are looked up in
/// `lib/cellar/domain/wine_origins.dart` (`OriginCountry.nameIn`,
/// `WineRegion.nameIn`, `WineOrigins.sortedFor`).
///
/// It is the language code, with one exception kept from the first release:
/// `pt` means Brazilian Portuguese (`pt-BR`), so European Portuguese, and
/// any other Portuguese, is `pt-PT`. This is the only place where a locale
/// becomes an origin language tag.
String originLanguageOf(Locale locale) {
  if (locale.languageCode != 'pt') return locale.languageCode;
  return locale.countryCode == 'BR' ? 'pt' : 'pt-PT';
}

/// The origin language tag of the interface language of [context].
String originLanguageTagOf(BuildContext context) =>
    originLanguageOf(Localizations.localeOf(context));
