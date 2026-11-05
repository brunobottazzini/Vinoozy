import 'dart:math';

/// Bottle quantity limits of the add-wine form (BR2.3).
abstract final class QuantityLimits {
  static const int min = 1;
  static const int max = 99;
  static const int initial = 1;

  static bool isValid(int quantity) => quantity >= min && quantity <= max;

  /// Keeps a stepper value inside [min]..[max].
  static int clamp(int quantity) => quantity.clamp(min, max);
}

/// Quantity shown to the user. Concurrent decrements sent as increments can
/// take the stored value below zero; the app shows it as 0 and corrects it
/// on the next write (ADR-004, BR3.4).
int displayQuantity(int storedQuantity) => max(0, storedQuantity);
