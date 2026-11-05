import 'package:firebase_auth/firebase_auth.dart';

import 'app_user.dart';

/// Maps a Firebase user to [AppUser]. The display name falls back to the
/// email, then to an empty string.
AppUser appUserFromFirebase(User user) => AppUser(
  uid: user.uid,
  email: user.email ?? '',
  displayName: user.displayName ?? user.email ?? '',
);
