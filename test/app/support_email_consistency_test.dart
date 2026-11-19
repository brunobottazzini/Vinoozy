// tester-feedback FR6.1, FR6.3, review R-04: the feedback email goes to the
// same support address on both sides. The recipient never travels from
// Dart to Android (NFR7), so the Kotlin constant SUPPORT_EMAIL and the Dart
// constant supportEmail are two copies that must never drift apart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/store_links.dart';

const String _handlerPath =
    'android/app/src/main/kotlin/com/vinoozy/vinoozy/LinksChannelHandler.kt';

/// `const val SUPPORT_EMAIL = "..."` in Kotlin source.
final RegExp _supportEmailDeclaration = RegExp(
  r'''const\s+val\s+SUPPORT_EMAIL\s*(?::\s*String\s*)?=\s*"([^"]*)"''',
);

/// The value of `SUPPORT_EMAIL` in [kotlinSource], or null when the
/// constant is not declared there exactly once.
String? supportEmailOf(String kotlinSource) {
  final matches = _supportEmailDeclaration.allMatches(kotlinSource).toList();
  return matches.length == 1 ? matches.single.group(1) : null;
}

void main() {
  test('the Android SUPPORT_EMAIL equals the Dart supportEmail', () {
    final file = File(_handlerPath);
    expect(file.existsSync(), isTrue, reason: '$_handlerPath is missing');
    final android = supportEmailOf(file.readAsStringSync());
    expect(
      android,
      isNotNull,
      reason: 'const val SUPPORT_EMAIL not found once in $_handlerPath',
    );
    expect(android, supportEmail);
    expect(supportEmail, matches(RegExp(r'^[^@\s]+@[^@\s]+\.[a-z]+$')));
  });

  group('supportEmailOf', () {
    test('reads the value, with or without the explicit type', () {
      expect(supportEmailOf('const val SUPPORT_EMAIL = "a@b.it"'), 'a@b.it');
      expect(
        supportEmailOf('const val SUPPORT_EMAIL: String = "c@d.com"'),
        'c@d.com',
      );
    });

    test('a missing or renamed constant is not found', () {
      expect(supportEmailOf(''), isNull);
      expect(supportEmailOf('const val SUPPORT_MAIL = "a@b.it"'), isNull);
      // A mention in a comment or an interpolation is not a declaration.
      expect(supportEmailOf('/** mailto:\$SUPPORT_EMAIL */'), isNull);
    });

    test('two declarations are ambiguous and not accepted', () {
      expect(
        supportEmailOf(
          'const val SUPPORT_EMAIL = "a@b.it"\n'
          'const val SUPPORT_EMAIL = "x@y.it"',
        ),
        isNull,
      );
    });
  });
}
