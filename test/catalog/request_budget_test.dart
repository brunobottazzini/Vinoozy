// RequestBudget: sliding window of 60 s, 8 searches and 60 product reads
// (BR2.3, NFR2.2), on a simulated clock.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/request_budget.dart';

import 'catalog_test_helpers.dart';

void main() {
  test('BR2.3 the ninth search in 60 s does not start, the one at second 60 '
      'does', () {
    final clock = FakeClock();
    final budget = RequestBudget(clock);
    for (var i = 0; i < 8; i++) {
      expect(budget.tryAcquire(OffRequestKind.search), isTrue, reason: '$i');
    }
    expect(budget.tryAcquire(OffRequestKind.search), isFalse);
    clock.advance(const Duration(seconds: 59));
    expect(budget.tryAcquire(OffRequestKind.search), isFalse);
    clock.advance(const Duration(seconds: 1));
    expect(budget.tryAcquire(OffRequestKind.search), isTrue);
  });

  test('BR2.3 the window slides: each slot frees 60 s after its request', () {
    final clock = FakeClock();
    final budget = RequestBudget(clock);
    for (var i = 0; i < 8; i++) {
      budget.tryAcquire(OffRequestKind.search);
      clock.advance(const Duration(seconds: 5));
    }
    // t = 40 s: full. At t = 60 s only the first slot (t = 0) is free.
    clock.current = clock.current.add(const Duration(seconds: 20));
    expect(budget.tryAcquire(OffRequestKind.search), isTrue);
    expect(budget.tryAcquire(OffRequestKind.search), isFalse);
  });

  test('BR2.3 sixty product reads, counted apart from searches', () {
    final clock = FakeClock();
    final budget = RequestBudget(clock);
    for (var i = 0; i < 60; i++) {
      expect(budget.tryAcquire(OffRequestKind.product), isTrue);
    }
    expect(budget.tryAcquire(OffRequestKind.product), isFalse);
    expect(budget.tryAcquire(OffRequestKind.search), isTrue);
  });

  test('a refused request takes nothing from the budget', () {
    final clock = FakeClock();
    final budget = RequestBudget(clock);
    for (var i = 0; i < 8; i++) {
      budget.tryAcquire(OffRequestKind.search);
    }
    for (var i = 0; i < 20; i++) {
      expect(budget.tryAcquire(OffRequestKind.search), isFalse);
    }
    clock.advance(RequestBudget.window);
    for (var i = 0; i < 8; i++) {
      expect(budget.tryAcquire(OffRequestKind.search), isTrue);
    }
  });
}
