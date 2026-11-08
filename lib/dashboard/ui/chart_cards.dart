import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/ui/country_flag.dart';
import '../../cellar/domain/wine_origins.dart';
import '../../cellar/ui/wine_badges.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard_providers.dart';
import '../domain/dashboard_summary.dart';
import 'bar_chart.dart';
import 'dashboard_card.dart';
import 'status_icons.dart';

/// "Title: label value, label value, ..." in the order shown (BR1.7), with
/// the correct plural in each language.
String chartDescription(
  AppLocalizations l10n,
  String title,
  Iterable<BarDatum> bars,
) => l10n.chartDescription(
  title,
  bars.map((bar) => l10n.chartBarValue(bar.label, bar.value)).join(', '),
);

/// "N bottles to estimate" under a chart, only when N > 0 (BR1.4, BR1.5).
class _ToEstimateNote extends StatelessWidget {
  const _ToEstimateNote({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        AppLocalizations.of(context).toEstimateNote(count),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

/// Four status bars with icon, label and number; each bar opens the cellar
/// list of that status (BR1.4, BR1.7; NFR3.1, NFR3.5).
class StatusChartCard extends StatelessWidget {
  const StatusChartCard({
    super.key,
    required this.summary,
    required this.onOpenStatus,
  });

  final DashboardSummary summary;
  final void Function(WineStatus status) onOpenStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = StatusColors.of(context);
    final bars = [
      for (final status in WineStatus.values)
        BarDatum(
          key: Key('chart-status-${status.name}'),
          label: statusLabel(l10n, status),
          value: summary.bottlesWith(status),
          color: statusColor(colors, status),
          icon: statusIcons[status],
          onTap: () => onOpenStatus(status),
          semanticsLabel: l10n.chartBarValue(
            statusLabel(l10n, status),
            summary.bottlesWith(status),
          ),
          semanticsHint: l10n.openListHint,
        ),
    ];
    return DashboardCard(
      key: const Key('chart-status'),
      title: l10n.statusChartTitle,
      description: chartDescription(l10n, l10n.statusChartTitle, bars),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarChart(bars: bars),
          _ToEstimateNote(
            key: const Key('chart-status-to-estimate'),
            count: summary.toEstimateBottles,
          ),
        ],
      ),
    );
  }
}

/// Columns "past peak", current year to +10 and "later" (BR1.5).
class PeakYearChartCard extends StatelessWidget {
  const PeakYearChartCard({
    super.key,
    required this.peakYears,
    required this.toEstimateBottles,
  });

  final List<PeakYearBar> peakYears;
  final int toEstimateBottles;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = StatusColors.of(context).neutral;
    final bars = [
      for (final bar in peakYears)
        BarDatum(
          label: switch (bar.kind) {
            PeakColumnKind.pastPeak => l10n.peakPast,
            PeakColumnKind.year => '${bar.year}',
            PeakColumnKind.beyond => l10n.peakBeyond,
          },
          value: bar.bottles,
          color: color,
        ),
    ];
    return DashboardCard(
      key: const Key('chart-peak'),
      title: l10n.peakChartTitle,
      description: chartDescription(l10n, l10n.peakChartTitle, bars),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The description already carries every number.
          ExcludeSemantics(child: ColumnChart(bars: bars)),
          _ToEstimateNote(
            key: const Key('chart-peak-to-estimate'),
            count: toEstimateBottles,
          ),
        ],
      ),
    );
  }
}

/// Type or region chart with its two-way selector (BR1.6). It is the only
/// card that watches the selector, so a change rebuilds only this card and
/// never recomputes the statuses (NFR2.3).
class BreakdownChartCard extends ConsumerWidget {
  const BreakdownChartCard({
    super.key,
    required this.byType,
    required this.byRegion,
  });

  final List<BreakdownBar> byType;
  final List<BreakdownBar> byRegion;

  /// The bar label; a listed region is shown in [languageCode] (Bourgogne
  /// as "Borgogna" in Italian, review R-02).
  static String labelOf(
    AppLocalizations l10n,
    BreakdownBar bar, {
    String languageCode = 'en',
  }) => switch (bar.kind) {
    BreakdownKind.family => wineFamilyLabel(l10n, _familyOf(bar.family!)),
    BreakdownKind.region => WineOrigins.regionDisplayName(
      bar.country,
      bar.region!,
      languageCode,
    ),
    BreakdownKind.otherRegions => l10n.breakdownOtherRegions,
    BreakdownKind.unspecified => l10n.breakdownUnspecified,
  };

  static WineTypeFamily _familyOf(WineFamily family) => switch (family) {
    WineFamily.red => WineTypeFamily.red,
    WineFamily.white => WineTypeFamily.white,
    WineFamily.rose => WineTypeFamily.rose,
    WineFamily.sparkling => WineTypeFamily.sparkling,
    WineFamily.sweet => WineTypeFamily.sweet,
  };

  /// ux-redesign FR3.3: type bars in the color of the family with its icon;
  /// region bars with the flag, "others" with a globe, "not specified" and
  /// a region without country with an icon (review R-06 of the mockups).
  static BarDatum barOf(
    BuildContext context,
    AppLocalizations l10n,
    BreakdownBar bar,
  ) {
    final language = Localizations.localeOf(context).languageCode;
    final label = labelOf(l10n, bar, languageCode: language);
    final neutral = StatusColors.of(context).neutral;
    final typeColors = WineTypeColors.of(context);
    final country = bar.country;
    return switch (bar.kind) {
      BreakdownKind.family => BarDatum(
        label: label,
        value: bar.bottles,
        color: wineFamilyColor(typeColors, _familyOf(bar.family!)),
        icon: wineFamilyIcon(_familyOf(bar.family!)),
        iconColor: wineFamilyColor(typeColors, _familyOf(bar.family!)),
      ),
      BreakdownKind.region => BarDatum(
        label: label,
        value: bar.bottles,
        color: neutral,
        icon: country == null ? Icons.place_outlined : null,
        leading: country == null ? null : CountryFlag(code: country, size: 18),
      ),
      BreakdownKind.otherRegions => BarDatum(
        label: label,
        value: bar.bottles,
        color: neutral,
        icon: Icons.public,
      ),
      BreakdownKind.unspecified => BarDatum(
        label: label,
        value: bar.bottles,
        color: typeColors.unknown,
        icon: Icons.help_outline,
      ),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(breakdownModeProvider);
    final source = mode == BreakdownMode.type ? byType : byRegion;
    final title = mode == BreakdownMode.type
        ? l10n.breakdownTypeTitle
        : l10n.breakdownRegionTitle;
    final bars = [for (final bar in source) barOf(context, l10n, bar)];
    return DashboardCard(
      key: const Key('chart-breakdown'),
      title: title,
      description: chartDescription(l10n, title, bars),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<BreakdownMode>(
            segments: [
              ButtonSegment(
                value: BreakdownMode.type,
                label: Text(
                  l10n.breakdownType,
                  key: const Key('breakdown-type'),
                ),
              ),
              ButtonSegment(
                value: BreakdownMode.region,
                label: Text(
                  l10n.breakdownRegion,
                  key: const Key('breakdown-region'),
                ),
              ),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => ref
                .read(breakdownModeProvider.notifier)
                .select(selection.single),
          ),
          const SizedBox(height: 8),
          ExcludeSemantics(child: BarChart(bars: bars)),
        ],
      ),
    );
  }
}
