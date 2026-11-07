// displayNameOrFallback (u7-sharing security-design.md §1, "Nomi di
// ripiego"; NFR4.9): present name, empty, blank, 150 characters.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/sharing/domain/membership.dart';

void main() {
  test('a present name is used, trimmed', () {
    expect(
      displayNameOrFallback('  Giulia Rossi ', 'g@example.com'),
      'Giulia Rossi',
    );
  });

  test('an empty or missing name falls back to the part before the @', () {
    expect(
      displayNameOrFallback('', 'giulia.rossi@example.com'),
      'giulia.rossi',
    );
    expect(
      displayNameOrFallback(null, 'giulia.rossi@example.com'),
      'giulia.rossi',
    );
  });

  test('a name of spaces only falls back too', () {
    expect(displayNameOrFallback('   ', 'luca@example.com'), 'luca');
  });

  test('a name of 150 characters is cut to 100', () {
    final name = 'n' * 150;
    final result = displayNameOrFallback(name, 'x@example.com');
    expect(result.length, 100);
    expect(result, 'n' * 100);
  });

  test('a 100-character name is kept as it is', () {
    expect(displayNameOrFallback('n' * 100, 'x@example.com').length, 100);
  });

  test('the fallback is cut to 100 characters too', () {
    final email = '${'l' * 140}@example.com';
    expect(displayNameOrFallback(null, email), 'l' * 100);
  });

  test('the cut never splits an emoji (surrogate pair)', () {
    final name = '${'a' * 99}🍷🍷';
    final result = displayNameOrFallback(name, 'x@example.com');
    expect(result, 'a' * 99);
    expect(result.length, lessThanOrEqualTo(100));
  });

  test('an email without a local part never gives an empty name', () {
    expect(displayNameOrFallback(null, '@example.com'), '@example.com');
    expect(displayNameOrFallback(null, ''), '?');
  });
}
