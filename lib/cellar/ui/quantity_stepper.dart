import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/quantity.dart';

/// "-" and "+" between 1 and 99 (BR2.3); the buttons are disabled at the
/// limits, so the value can never leave the range.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      key: const Key('quantity-stepper'),
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const Key('quantity-decrease-button'),
          tooltip: l10n.decreaseQuantity,
          onPressed: value > QuantityLimits.min
              ? () => onChanged(QuantityLimits.clamp(value - 1))
              : null,
          icon: const Icon(Icons.remove),
        ),
        Semantics(
          label: l10n.bottleCount(value),
          excludeSemantics: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 40),
            child: Text(
              '$value',
              key: const Key('quantity-value'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          ),
        ),
        IconButton(
          key: const Key('quantity-increase-button'),
          tooltip: l10n.increaseQuantity,
          onPressed: value < QuantityLimits.max
              ? () => onChanged(QuantityLimits.clamp(value + 1))
              : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
