import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/quantity.dart';

/// "-" and "+" between [min] (1 by default) and 99 (BR2.3); the buttons are
/// disabled at the limits, so the value can never leave the range. The edit
/// form of u4-cellar allows 0 (BR1.13).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = QuantityLimits.min,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;

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
          onPressed: value > min
              ? () => onChanged((value - 1).clamp(min, QuantityLimits.max))
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
              ? () => onChanged((value + 1).clamp(min, QuantityLimits.max))
              : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
