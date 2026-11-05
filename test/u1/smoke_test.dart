import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/core/clock.dart';
import 'package:vinoozy/core/id_generator.dart';

import '../helpers/fakes.dart';

/// Smoke test of the runner: proves `flutter test test/u1/` loads the package,
/// the helpers and the first production types.
void main() {
  group('RandomIdGenerator', () {
    test('produces 20-character alphanumeric ids', () {
      final id = RandomIdGenerator().newId();

      expect(id, hasLength(RandomIdGenerator.idLength));
      expect(RegExp(r'^[A-Za-z0-9]{20}$').hasMatch(id), isTrue);
    });

    test('does not repeat ids across many draws', () {
      final generator = RandomIdGenerator();
      final ids = {for (var i = 0; i < 1000; i++) generator.newId()};

      expect(ids, hasLength(1000));
    });

    test('is driven by the injected random source', () {
      final first = RandomIdGenerator(random: Random(7)).newId();
      final second = RandomIdGenerator(random: Random(7)).newId();
      final other = RandomIdGenerator(random: Random(8)).newId();

      expect(first, second);
      expect(first, isNot(other));
    });
  });

  group('clocks', () {
    test('SystemClock follows the real time', () {
      final before = DateTime.now();
      final now = const SystemClock().now();

      expect(now.isBefore(before), isFalse);
    });

    test('FakeClock returns exactly the time set by the test', () {
      final clock = FakeClock(DateTime(2026, 11, 5));
      expect(clock.now(), DateTime(2026, 11, 5));

      clock.current = DateTime(2027, 1, 1);
      expect(clock.now().year, 2027);
    });
  });
}
