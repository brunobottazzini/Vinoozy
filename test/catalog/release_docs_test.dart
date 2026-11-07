// BR5.3 and NFR6.8 live in the release checklist: this test fails if the
// lines a release with Open Food Facts depends on are removed.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final checklist = File('docs/release-checklist.md').readAsStringSync();
  final setup = File('docs/firebase-setup.md').readAsStringSync();

  test('BR5.3 the release checklist checks contact, privacy, Data safety and '
      'attribution before production', () {
    expect(checklist, contains('`OFF_CONTACT` presente nel segreto'));
    expect(checklist, contains('Informativa privacy aggiornata'));
    expect(checklist, contains('"Sicurezza dei dati" di Google Play'));
    expect(checklist, contains('`offAttribution`'));
    expect(checklist, contains('Open Food Facts, insieme all\'indirizzo IP'));
  });

  test('NFR6.8 the monthly check reads off_suspended with its thresholds', () {
    expect(checklist, contains('## 5. Controllo mensile'));
    expect(checklist, contains('`off_suspended`'));
    expect(checklist, contains('**più di 20**'));
    expect(checklist, contains('**più di 3 utenti**'));
  });

  test('the setup guide explains where the contact goes and how to switch '
      'Open Food Facts off', () {
    expect(setup, contains('## 9. Contatto per Open Food Facts'));
    expect(setup, contains('ambiente `play-internal`'));
    expect(setup, contains('**Spegnere Open Food Facts**'));
  });
}
