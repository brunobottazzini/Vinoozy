// Non-regression check of U1's backup rules, on which catalog_cache.json
// relies (security-design.md §5, NFR8.1): U3 does not change them, it only
// fails here if they ever stop excluding the `file` domain.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _manifest = 'android/app/src/main/AndroidManifest.xml';
const _rules = 'android/app/src/main/res/xml/data_extraction_rules.xml';

/// Body of the first `<tag>...</tag>` of [xml] without comments, or `null`.
String? _section(String xml, String tag) =>
    RegExp('<$tag>(.*?)</$tag>', dotAll: true).firstMatch(xml)?.group(1);

String _withoutComments(String xml) =>
    xml.replaceAll(RegExp('<!--.*?-->', dotAll: true), '');

void main() {
  test(
    'the application disables backup and points to the extraction rules',
    () {
      final manifest = _withoutComments(File(_manifest).readAsStringSync());
      expect(manifest, contains('android:allowBackup="false"'));
      expect(manifest, contains('android:fullBackupContent="false"'));
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
    },
  );

  test('the file domain, where catalog_cache.json lives, is excluded from '
      'cloud backup and device transfer', () {
    final rules = _withoutComments(File(_rules).readAsStringSync());
    for (final section in ['cloud-backup', 'device-transfer']) {
      final body = _section(rules, section);
      expect(body, isNotNull, reason: section);
      expect(body, contains('<exclude domain="file" />'), reason: section);
      expect(body, contains('<exclude domain="root" />'), reason: section);
      expect(body, isNot(contains('<include')), reason: section);
    }
  });

  test('the section reader finds nothing for a missing section', () {
    expect(_section('<a></a>', 'cloud-backup'), isNull);
    expect(_withoutComments('x<!-- y -->z'), 'xz');
  });
}
