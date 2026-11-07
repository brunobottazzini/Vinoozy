import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/cellar.dart';
import 'package:vinoozy/cellar/domain/firestore_values.dart';

void main() {
  group('Cellar', () {
    test('the personal cellar id is the uid (BR1.3)', () {
      expect(Cellar.personalCellarId('user-a'), 'user-a');
    });

    test('create fields carry owner, trimmed name and schemaVersion 1', () {
      final fields = Cellar.createFields(
        uid: 'user-a',
        name: ' La mia cantina ',
      );

      expect(fields, {
        CellarFields.ownerId: 'user-a',
        CellarFields.name: 'La mia cantina',
        CellarFields.schemaVersion: 1,
      });
      expect(fields.containsKey(CellarFields.createdAt), isFalse);
    });

    test('an empty or too long name is rejected', () {
      expect(
        () => Cellar.createFields(uid: 'u', name: '  '),
        throwsArgumentError,
      );
      expect(
        () => Cellar.createFields(uid: 'u', name: 'x' * 61),
        throwsArgumentError,
      );
      expect(Cellar.createFields(uid: 'u', name: 'x' * 60), isNotEmpty);
    });

    test('fromMap reads the fields and ignores unknown ones', () {
      final created = DateTime.utc(2026, 11, 4);
      final cellar = Cellar.fromMap('user-a', {
        CellarFields.ownerId: 'user-a',
        CellarFields.name: 'La mia cantina',
        CellarFields.createdAt: created,
        CellarFields.schemaVersion: 1,
        'members': ['x'],
      });

      expect(cellar.ownerId, 'user-a');
      expect(cellar.name, 'La mia cantina');
      expect(cellar.createdAt, created);
      expect(cellar.schemaVersion, 1);
    });

    test('fromMap tolerates missing and malformed fields', () {
      final cellar = Cellar.fromMap('c', {CellarFields.ownerId: 3});

      expect(cellar.ownerId, '');
      expect(cellar.name, '');
      expect(cellar.createdAt, isNull);
      expect(cellar.schemaVersion, currentSchemaVersion);
      expect(cellar.memberSlots, 0);
      expect(cellar.memberOpKey, isNull);
    });

    test('fromMap reads memberSlots and memberOpKey of u7-sharing', () {
      final cellar = Cellar.fromMap('user-a', {
        CellarFields.ownerId: 'user-a',
        CellarFields.memberSlots: 2,
        CellarFields.memberOpKey: 'b@example.com',
      });

      expect(cellar.memberSlots, 2);
      expect(cellar.memberOpKey, 'b@example.com');
    });

    test('a missing, negative or mistyped memberSlots counts 0 and never '
        'throws', () {
      expect(Cellar.fromMap('c', const {}).memberSlots, 0);
      expect(
        Cellar.fromMap('c', {CellarFields.memberSlots: -1}).memberSlots,
        0,
      );
      expect(
        Cellar.fromMap('c', {CellarFields.memberSlots: '2'}).memberSlots,
        0,
      );
      expect(
        Cellar.fromMap('c', {CellarFields.memberSlots: 1.0}).memberSlots,
        1,
      );
      expect(
        Cellar.fromMap('c', {CellarFields.memberOpKey: 4}).memberOpKey,
        isNull,
      );
    });

    test('FirestoreValues rejects non-finite doubles', () {
      expect(FirestoreValues.integer(double.nan), isNull);
      expect(FirestoreValues.integer(double.infinity), isNull);
      expect(FirestoreValues.boolean('true'), isNull);
    });
  });
}
