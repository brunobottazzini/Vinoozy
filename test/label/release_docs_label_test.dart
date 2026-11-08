// The owner's actions of label-recognition live in the release checklist
// (NFR3.6, NFR3.9, NFR3.10, NFR5.7, NFR5.8): this test fails if one is
// removed.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final checklist = File('docs/release-checklist.md').readAsStringSync();

  test('NFR5.8 the database is rebuilt by hand from the export, then the '
      'manifest is checked', () {
    expect(checklist, contains('**Scarica a mano**'));
    expect(checklist, contains('dart run tool/build_wine_db.dart'));
    expect(checklist, contains('**Controlla il manifesto**'));
    expect(checklist, contains('**30 MB**'));
  });

  test('NFR3.6 privacy policy and Data safety cover the photo sent to '
      'Google Lens; the app is tried on the phone', () {
    expect(checklist, contains('**Foto condivisa con Google Lens**'));
    expect(checklist, contains('app Google apre Lens con la foto del fronte'));
  });

  // label-autofill-windows NFR3.6, NFR5.6, BR6.3: the owner's actions of
  // this work stay in the checklist.
  test('label-autofill-windows: the registers downloaded by hand, the '
      'table generated and checked, the rules first, the phone trials and '
      'the migration check', () {
    expect(checklist, contains('**Scarica a mano l\'export di eAmbrosia**'));
    expect(checklist, contains('dart run tool/build_appellations.dart'));
    expect(checklist, contains('tool/check_appellations_release.sh'));
    expect(checklist, contains('**Prima le regole**'));
    expect(checklist, contains('**Da Google Lens**'));
    expect(checklist, contains('**Incolla automatico**'));
    expect(checklist, contains('`estimates_migration_failed`'));
    expect(checklist, contains('**più di 5** in 7 giorni'));
  });

  test('NFR3.9 the monthly check reads wine_db_unavailable', () {
    expect(checklist, contains('`wine_db_unavailable`'));
    expect(checklist, contains('`wine_db_reason`'));
  });

  test('NFR3.10 NFR5.7 the four checks before the repository goes public', () {
    expect(checklist, contains('**Prima di rendere pubblico il repository**'));
    expect(checklist, contains('gitleaks'));
    expect(
      checklist,
      contains(
        'git log --all -- config/firebase_prod.json '
        'android/app/google-services.json',
      ),
    );
    expect(checklist, contains('`offContact`'));
    expect(checklist, contains('`firebase-config.js`'));
    expect(checklist, contains('**Repository pubblico prima della'));
  });
}
