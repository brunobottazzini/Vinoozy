// u8-account BR1.11 and BR1.12: the web page in three languages shows the
// email address as a fallback and for privacy rights, and the checklist holds
// the email procedure (NFR8.5, NFR8.6).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const ownerEmail = 'bottazzinibruno@gmail.com';

void main() {
  final pages = {
    'it': 'docs/account-deletion/index.html',
    'en': 'docs/account-deletion/en/index.html',
    'pt-BR': 'docs/account-deletion/pt-BR/index.html',
  };

  test('BR1.11 the page exists in it, en and pt-BR with its language', () {
    for (final MapEntry(key: lang, value: path) in pages.entries) {
      final html = File(path).readAsStringSync();
      expect(html, contains('<html lang="$lang">'), reason: path);
      expect(html, contains('data-word='), reason: path);
    }
  });

  test(
    'BR1.12 automatic deletion and a fallback privacy contact are available',
    () {
      for (final path in pages.values) {
        final html = File(path).readAsStringSync();
        final section = html.indexOf('id="no-access"');
        expect(section, greaterThan(0), reason: path);
        expect(html.substring(section), contains(ownerEmail), reason: path);
        expect(html, contains('id="sign-in"'), reason: path);
        expect(html, contains('privacy/'), reason: path);
        expect(html, isNot(contains('<form')), reason: 'NFR8.5 no form');
      }
    },
  );

  test('BR1.12 the checklist holds the email procedure with its deadlines', () {
    final checklist = File('docs/release-checklist.md').readAsStringSync();
    expect(checklist, contains(ownerEmail));
    expect(checklist, contains('Procedura per le richieste di cancellazione'));
    expect(checklist, contains('entro 30 giorni dalla richiesta'));
    expect(checklist, contains('**14 giorni**'));
    for (final item in [
      '`wines`',
      '`drinkingRecords`',
      '`members`',
      'Authentication',
    ]) {
      expect(checklist, contains(item));
    }
  });
}
