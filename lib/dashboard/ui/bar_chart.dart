import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One bar of a chart. The widgets never count: [value] comes ready from
/// the DashboardSummary (frontend-components.md, "Modelli di vista").
class BarDatum {
  const BarDatum({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    this.onTap,
    this.semanticsLabel,
    this.semanticsHint,
    this.key,
  });

  final String label;
  final int value;
  final Color color;

  /// Shown before the label (status bars, NFR3.5).
  final IconData? icon;

  /// When set the bar is a button reachable on its own by TalkBack, with
  /// [semanticsLabel] and [semanticsHint] (BR1.7, security-design.md §3).
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final String? semanticsHint;
  final Key? key;
}

/// Minimum side of a touch target (NFR3.3).
const double minTapTarget = 48;

/// Width share of a bar of [value] over [max], never invisible above 0.
double barFactor(int value, int max) {
  if (value <= 0 || max <= 0) return 0;
  return math.max(value / max, 0.02);
}

/// Horizontal bars, one row each: icon, label, bar and number. Plain rows
/// with [FractionallySizedBox], no painter or animation (NFR2.4). Labels
/// wrap with large text (NFR3.4); every row is at least 48 dp high.
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.bars});

  final List<BarDatum> bars;

  @override
  Widget build(BuildContext context) {
    final max = bars.fold<int>(0, (m, bar) => math.max(m, bar.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final bar in bars) _BarRow(bar: bar, max: max)],
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.bar, required this.max});

  final BarDatum bar;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minTapTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (bar.icon != null) ...[
              Icon(bar.icon, size: 20, color: theme.colorScheme.onSurface),
              const SizedBox(width: 8),
            ],
            Expanded(flex: 2, child: Text(bar.label)),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: barFactor(bar.value, max),
                  child: Container(height: 16, color: bar.color),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${bar.value}', style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
    final onTap = bar.onTap;
    if (onTap == null) return KeyedSubtree(key: bar.key, child: row);
    return Semantics(
      key: bar.key,
      container: true,
      button: true,
      label: bar.semanticsLabel ?? bar.label,
      hint: bar.semanticsHint,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

/// Vertical columns with the number above and the label below (the peak
/// chart, BR1.5). Each column is at least 48 dp wide and grows with the
/// text size; when they do not fit, the chart scrolls horizontally
/// (NFR3.4, performance-design.md).
class ColumnChart extends StatelessWidget {
  const ColumnChart({super.key, required this.bars, this.barAreaHeight = 96});

  final List<BarDatum> bars;
  final double barAreaHeight;

  @override
  Widget build(BuildContext context) {
    final max = bars.fold<int>(0, (m, bar) => math.max(m, bar.value));
    final scaler = MediaQuery.textScalerOf(context);
    final minColumnWidth = math.max(minTapTarget, scaler.scale(44));
    return LayoutBuilder(
      builder: (context, constraints) {
        final fitted = constraints.maxWidth / bars.length;
        final width = math.max(minColumnWidth, fitted);
        final columns = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final bar in bars)
              SizedBox(
                key: bar.key,
                width: width,
                child: _Column(bar: bar, max: max, height: barAreaHeight),
              ),
          ],
        );
        if (width * bars.length <= constraints.maxWidth) return columns;
        return SingleChildScrollView(
          key: const Key('column-chart-scroll'),
          scrollDirection: Axis.horizontal,
          child: columns,
        );
      },
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.bar, required this.max, required this.height});

  final BarDatum bar;
  final int max;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${bar.value}', style: theme.textTheme.labelLarge),
          SizedBox(
            height: height,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: barFactor(bar.value, max),
                widthFactor: 0.6,
                child: Container(color: bar.color),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bar.label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
