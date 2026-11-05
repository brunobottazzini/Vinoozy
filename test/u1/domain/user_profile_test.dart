import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/user_profile.dart';

void main() {
  group('UserProfile', () {
    test(
      'create fields start with onboardingSeen false and schemaVersion 1',
      () {
        final fields = UserProfile.createFields(
          displayName: 'User A',
          email: 'user-a@example.com',
        );

        expect(fields, {
          UserProfileFields.displayName: 'User A',
          UserProfileFields.email: 'user-a@example.com',
          UserProfileFields.onboardingSeen: false,
          UserProfileFields.schemaVersion: 1,
        });
      },
    );

    test(
      'refresh fields never touch onboardingSeen or createdAt (NFR4.11)',
      () {
        final fields = UserProfile.refreshFields(
          displayName: 'User A',
          email: 'user-a@example.com',
        );

        expect(fields.keys, unorderedEquals(['displayName', 'email']));
      },
    );

    test('fromMap reads every field', () {
      final created = DateTime.utc(2026, 11, 4);
      final profile = UserProfile.fromMap('user-a', {
        UserProfileFields.displayName: 'User A',
        UserProfileFields.email: 'user-a@example.com',
        UserProfileFields.onboardingSeen: true,
        UserProfileFields.createdAt: created,
        UserProfileFields.schemaVersion: 1,
      });

      expect(profile.uid, 'user-a');
      expect(profile.onboardingSeen, isTrue);
      expect(profile.createdAt, created);
    });

    test('fromMap tolerates a document with wrong types', () {
      final profile = UserProfile.fromMap('user-a', {
        UserProfileFields.onboardingSeen: 'yes',
        UserProfileFields.email: null,
      });

      expect(profile.onboardingSeen, isFalse);
      expect(profile.email, '');
      expect(profile.displayName, '');
    });

    test('fromMap ignores unknown fields', () {
      final profile = UserProfile.fromMap('user-a', {
        UserProfileFields.email: 'user-a@example.com',
        'unknown': 1,
      });

      expect(profile.email, 'user-a@example.com');
    });

    test('a missing schemaVersion defaults to the current version', () {
      expect(UserProfile.fromMap('u', const {}).schemaVersion, 1);
    });
  });
}
