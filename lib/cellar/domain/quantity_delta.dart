import 'quantity.dart';

/// Quantity changes as increments (BR1.15, ADR-004, NFR6.2). Pure.
///
/// Concurrent decrements can leave a negative stored value s, shown as 0.
/// An increase of n then writes `increment(n − s)`, so the result is n and
/// not n − |s|. A decrease is allowed only while the shown value is above 0.
abstract final class QuantityDelta {
  /// The increment that raises the shown quantity by [n] (n ≥ 1).
  static int forIncrease(int stored, int n) {
    if (n < 1) throw ArgumentError.value(n, 'n', 'must be at least 1');
    return n - (stored < 0 ? stored : 0);
  }

  /// How many bottles can still be added to the shown quantity without
  /// going over 99 (BR1.3 cap, review R-05); 0 when it is full.
  static int room(int stored) => QuantityLimits.max - displayQuantity(stored);

  /// Whether adding [n] bottles keeps the shown quantity within 99.
  static bool canIncrease(int stored, int n) => n >= 1 && n <= room(stored);

  /// Whether "Drunk" and "−" are enabled.
  static bool canDecrease(int stored) => displayQuantity(stored) > 0;

  /// The increment that moves the shown quantity to [target] (the edit form,
  /// BR1.13); 0 when nothing changes. Never below 0.
  static int forEdit(int stored, int target) {
    if (target < 0) throw ArgumentError.value(target, 'target');
    final shown = displayQuantity(stored);
    if (target == shown) return stored < 0 ? -stored : 0;
    if (target > shown) return forIncrease(stored, target - shown);
    return target - shown;
  }
}
