// One list of languages (wine-culture-languages NFR5, FR1.1, FR2.2):
// appLocales is the source; the ARB files, the generated localizations, the
// Android locale declaration, the store languages and the store folders must
// list the same 25 languages.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/locale_resolution.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

/// `pt-BR`, `fr`: the BCP 47 tag of a locale without script.
String _tagOf(Locale locale) =>
    [locale.languageCode, ?locale.countryCode].join('-');

final Set<String> _appTags = {for (final l in appLocales) _tagOf(l)};

Map<String, Object?> _storeLanguagesJson() => (jsonDecode(
  File('distribution/google-play/languages.json').readAsStringSync(),
) as Map).cast<String, Object?>();

Map<String, String> _storeLanguages() =>
    (_storeLanguagesJson()['languages']! as Map).cast<String, String>();

void main() {
  test('appLocales lists 25 languages, each once', () {
    expect(appLocales, hasLength(25));
    expect(_appTags, hasLength(25));
  });

  test('there is one ARB file per language and no other', () {
    final arbTags = <String>{};
    for (final entity in Directory('lib/l10n').listSync()) {
      final name = entity.uri.pathSegments.last;
      final match = RegExp(r'^app_([a-z]{2,3})(?:_([A-Z]{2}))?\.arb$')
          .firstMatch(name);
      if (match == null) continue;
      arbTags.add([match.group(1)!, ?match.group(2)].join('-'));
      final arb = jsonDecode(File(entity.path).readAsStringSync()) as Map;
      expect(
        arb['@@locale'],
        [match.group(1)!, ?match.group(2)].join('_'),
        reason: name,
      );
    }
    expect(arbTags, _appTags);
  });

  test('the generated localizations support the same languages', () {
    expect({
      for (final l in AppLocalizations.supportedLocales) _tagOf(l),
    }, _appTags);
    for (final locale in appLocales) {
      expect(
        AppLocalizations.delegate.isSupported(locale),
        isTrue,
        reason: _tagOf(locale),
      );
    }
  });

  test('Android declares the same languages (FR2.2)', () {
    final xml = File('android/app/src/main/res/xml/locales_config.xml')
        .readAsStringSync();
    final declared = [
      for (final match in RegExp(
        r'<locale\s+android:name="([^"]+)"\s*/>',
      ).allMatches(xml))
        match.group(1)!,
    ];
    expect(declared.toSet(), hasLength(declared.length));
    expect(declared.toSet(), {
      for (final locale in appLocales) androidLocaleTagOf(locale),
    });
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:localeConfig="@xml/locales_config"'));
  });

  test('Android tags are BCP 47 tags, one per language (loop-back 1)', () {
    // language, optional script, optional region, separated by "-"; never a
    // resource qualifier such as b+sr+Cyrl.
    final bcp47 = RegExp(r'^[a-z]{2,3}(-[A-Z][a-z]{3})?(-[A-Z]{2})?$');
    final tags = [for (final locale in appLocales) androidLocaleTagOf(locale)];
    for (final tag in tags) {
      expect(tag, matches(bcp47));
    }
    // A tag without region or script is expanded by Android with its likely
    // subtags: two tags of one language must differ in region or script.
    expect(tags, containsAll(['pt-BR', 'pt-PT', 'sr-Cyrl']));
    expect(tags, isNot(contains('pt')));
    expect(tags, isNot(contains('sr')));
  });

  test('every Android tag comes back to its app language', () {
    for (final locale in appLocales) {
      final tag = androidLocaleTagOf(locale);
      final parts = tag.split('-');
      final fromAndroid = Locale.fromSubtags(
        languageCode: parts.first,
        scriptCode: parts.length > 1 && parts[1].length == 4 ? parts[1] : null,
        countryCode: parts.last.length == 2 && parts.length > 1
            ? parts.last
            : null,
      );
      expect(resolveAppLocale([fromAndroid]), locale, reason: tag);
    }
  });

  test('the store languages map every app language to its folder', () {
    final languages = _storeLanguages();
    expect(languages.keys.toSet(), _appTags);
    final folders = languages.values.toList();
    expect(folders.toSet(), hasLength(folders.length));
    expect(folders, contains(_storeLanguagesJson()['defaultListing']));
    expect(languages['pt-BR'], 'pt-BR');
    expect(languages['pt'], 'pt-PT');
    expect(languages['nb'], 'no-NO');
  });

  test('every store folder exists with its three texts, and no other', () {
    final folders = _storeLanguages().values.toSet();
    final onDisk = {
      for (final entity in Directory('distribution/google-play').listSync())
        if (entity is Directory &&
            File('${entity.path}/title.txt').existsSync())
          entity.uri.pathSegments.where((s) => s.isNotEmpty).last,
    };
    expect(onDisk, folders);
    for (final folder in folders) {
      for (final name in [
        'title.txt',
        'short-description.txt',
        'full-description.txt',
      ]) {
        final file = File('distribution/google-play/$folder/$name');
        expect(file.existsSync(), isTrue, reason: file.path);
        expect(file.readAsStringSync().trim(), isNotEmpty, reason: file.path);
      }
    }
  });

  test('the release notes have one block per store folder', () {
    final notes = File('distribution/google-play/release-notes.txt')
        .readAsStringSync();
    final tags = [
      for (final match in RegExp(
        r'^<([A-Za-z-]+)>$',
        multiLine: true,
      ).allMatches(notes))
        match.group(1)!,
    ];
    expect(tags.toSet(), hasLength(tags.length));
    expect(tags.toSet(), _storeLanguages().values.toSet());
  });
}
