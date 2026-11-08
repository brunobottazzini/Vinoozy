import 'package:flutter/material.dart';

import '../../cellar/domain/wine_origins.dart';

/// The flag of a country as the phone's emoji (NFR3: no library, works
/// offline), read by the screen reader as the country name, never as the
/// emoji (NFR1, A3). An unknown or malformed code shows the code in a small
/// box instead (review R-05).
class CountryFlag extends StatelessWidget {
  const CountryFlag({super.key, required this.code, this.size = 20});

  /// ISO 3166-1 alpha-2 code.
  final String code;

  /// Font size of the emoji; the fallback box follows it.
  final double size;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final country = WineOrigins.country(code);
    final emoji = country == null ? null : WineOrigins.flagEmoji(code);
    return Semantics(
      label: country?.nameIn(language) ?? code,
      image: true,
      excludeSemantics: true,
      child: emoji == null
          ? _CodeBox(code: code, size: size)
          : Text(
              emoji,
              key: Key('flag-$code'),
              style: TextStyle(fontSize: size, height: 1.15),
            ),
    );
  }
}

/// The two letters of the code in an outlined box: the fallback flag.
class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.code, required this.size});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: Key('flag-fallback-$code'),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        code.toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.6,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}
