// QuantityDelta (u4-cellar BR1.15; NFR6.2; ADR-004): stored values −2, 0, 3.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/quantity_delta.dart';

void main() {
  group('BR1.15 increase', () {
    test('a negative stored value is corrected: the result is n', () {
      // −2 shown as 0; +3 must give 3, so increment(5).
      expect(QuantityDelta.forIncrease(-2, 3), 5);
      expect(-2 + QuantityDelta.forIncrease(-2, 3), 3);
    });

    test('0 and positive stored values add n', () {
      expect(QuantityDelta.forIncrease(0, 1), 1);
      expect(QuantityDelta.forIncrease(3, 2), 2);
    });

    test('n below 1 is a programming error', () {
      expect(() => QuantityDelta.forIncrease(3, 0), throwsArgumentError);
    });
  });

  test('BR1.15 decreases only while the shown value is above 0', () {
    expect(QuantityDelta.canDecrease(-2), isFalse);
    expect(QuantityDelta.canDecrease(0), isFalse);
    expect(QuantityDelta.canDecrease(3), isTrue);
  });

  test('BR1.3 R-05 the room left under the cap of 99 bottles', () {
    expect(QuantityDelta.room(97), 2);
    expect(QuantityDelta.room(99), 0);
    expect(QuantityDelta.room(-2), 99, reason: 'shown as 0');
    expect(QuantityDelta.canIncrease(97, 2), isTrue);
    expect(QuantityDelta.canIncrease(97, 3), isFalse);
    expect(QuantityDelta.canIncrease(99, 1), isFalse);
    expect(QuantityDelta.canIncrease(3, 0), isFalse);
  });

  group('BR1.13 edit to a target quantity', () {
    test('no change is 0, or the correction of a negative value', () {
      expect(QuantityDelta.forEdit(3, 3), 0);
      expect(QuantityDelta.forEdit(0, 0), 0);
      expect(QuantityDelta.forEdit(-2, 0), 2);
    });

    test('up from a negative stored value lands on the target', () {
      expect(-2 + QuantityDelta.forEdit(-2, 4), 4);
    });

    test('down never goes below 0', () {
      expect(QuantityDelta.forEdit(3, 0), -3);
      expect(QuantityDelta.forEdit(3, 1), -2);
      expect(() => QuantityDelta.forEdit(3, -1), throwsArgumentError);
    });
  });
}
