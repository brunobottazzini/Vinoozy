import 'package:flutter/widgets.dart';

/// Languages of the interface (BR5.1).
const List<Locale> appLocales = [
  Locale('en'),
  Locale('it'),
  Locale('pt', 'BR'),
];

const Locale fallbackLocale = Locale('en');

/// BR5.1: Italian, English or Brazilian Portuguese as set on the phone;
/// anything else, including Portuguese of other countries, falls back to
/// English. The phone's preference order is respected.
Locale resolveAppLocale(List<Locale>? preferred) {
  for (final locale in preferred ?? const <Locale>[]) {
    switch (locale.languageCode) {
      case 'it':
        return const Locale('it');
      case 'en':
        return const Locale('en');
      case 'pt' when locale.countryCode == 'BR':
        return const Locale('pt', 'BR');
    }
  }
  return fallbackLocale;
}
