import 'firestore_values.dart';

/// Field names of `users/{uid}` (C3).
abstract final class UserProfileFields {
  static const String displayName = 'displayName';
  static const String email = 'email';
  static const String onboardingSeen = 'onboardingSeen';
  static const String createdAt = 'createdAt';
  static const String schemaVersion = 'schemaVersion';
}

/// Profile document of a signed-in user.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.onboardingSeen,
    this.createdAt,
    this.schemaVersion = currentSchemaVersion,
  });

  factory UserProfile.fromMap(String uid, Map<String, Object?> data) =>
      UserProfile(
        uid: uid,
        displayName:
            FirestoreValues.string(data[UserProfileFields.displayName]) ?? '',
        email: FirestoreValues.string(data[UserProfileFields.email]) ?? '',
        onboardingSeen:
            FirestoreValues.boolean(data[UserProfileFields.onboardingSeen]) ??
            false,
        createdAt: FirestoreValues.dateTime(data[UserProfileFields.createdAt]),
        schemaVersion:
            FirestoreValues.integer(data[UserProfileFields.schemaVersion]) ??
            currentSchemaVersion,
      );

  /// Fields of a new profile, without `createdAt` (server timestamp set by the
  /// repository). `onboardingSeen` starts false (functional-spec.md).
  static Map<String, Object?> createFields({
    required String displayName,
    required String email,
  }) => {
    UserProfileFields.displayName: displayName,
    UserProfileFields.email: email,
    UserProfileFields.onboardingSeen: false,
    UserProfileFields.schemaVersion: currentSchemaVersion,
  };

  /// Fields refreshed on every sign-in. Only these two change, so
  /// `onboardingSeen` and `createdAt` are never reset (NFR4.11).
  static Map<String, Object?> refreshFields({
    required String displayName,
    required String email,
  }) => {
    UserProfileFields.displayName: displayName,
    UserProfileFields.email: email,
  };

  final String uid;
  final String displayName;
  final String email;
  final bool onboardingSeen;
  final DateTime? createdAt;
  final int schemaVersion;
}
