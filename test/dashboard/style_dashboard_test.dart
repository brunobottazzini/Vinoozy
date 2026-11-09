// The Dashboard with the style profiles (wine-style-profiles BR6.4, BR6.5,
// BR6.7): "drink soon" ordered by the end month and written "by Mar 2027",
// no peak column for a window without a peak, the "To confirm" card.
import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/dashboard/domain/dashboard_calculator.dart';
import 'package:vinoozy/dashboard/domain/dashboard_summary.dart';
import 'package:vinoozy/dashboard/ui/drink_soon_section.dart';
import 'package:vinoozy/dashboard/ui/to_confirm_card.dart';

import '../helpers/ui_harness.dart';

const _calculator = DashboardCalculator();
final _today = DateTime(2026, 11, 9);

Wine _wine(
  String id, {
  required String name,
  String? wineType,
  DrinkingWindow? window,
  int? vintage = 2020,
  WineStyle? style,
  FieldSource? styleSource,
}) => Wine(
  id: id,
  name: name,
  vintage: vintage,
  storedQuantity: 1,
  wineType: wineType,
  window: window,
  style: style,
  styleSource: styleSource,
);

DrinkingWindow _estimate(WineFacts facts) => estimateWindow(facts)!;

void main() {
  // SP_TANK from 2025-10: ends 2027-04; drink soon in Nov 2026? notice 4
  // months (25% of 19): no. From 2025-06: ends 2026-12, 2 months left.
  final prosecco = _estimate(
    const WineFacts(
      name: 'Prosecco',
      referenceYear: 2026,
      agingStartYear: 2025,
      agingStartMonth: 6,
    ),
  );
  final fino = _estimate(
    const WineFacts(
      name: 'Jerez Fino',
      referenceYear: 2026,
      agingStartYear: 2025,
      agingStartMonth: 12,
    ),
  ); // ends 2026-12, no peak
  final lbv = _estimate(
    const WineFacts(name: 'Porto LBV', referenceYear: 2026),
  );

  group('BR6.7 calculator', () {
    test('drink soon in months, ordered by the end month', () {
      final summary = _calculator.compute([
        _wine(
          'a',
          name: 'Prosecco',
          wineType: 'sparklingTank',
          window: prosecco,
        ),
        _wine('b', name: 'Fino', wineType: 'fortified', window: fino),
      ], _today);
      expect(summary.drinkSoon.map((r) => r.wineId), ['b', 'a']);
      expect(summary.drinkSoon.first.endMonth, 12);
      expect(summary.drinkSoon.first.endIndex, 2026 * 12 + 11);
    });

    test('BR6.4 a window without a peak is not in the peak chart', () {
      final summary = _calculator.compute([
        _wine('b', name: 'Fino', wineType: 'fortified', window: fino),
        _wine('c', name: 'LBV', wineType: 'fortified', window: lbv),
      ], _today);
      final counted = summary.peakYears.fold<int>(0, (n, b) => n + b.bottles);
      expect(counted, 0);
      // BR6.5: no end, always ready.
      expect(summary.readyBottles, 1);
    });

    test('To confirm: indicative, unclear style and "To estimate"', () {
      final generic = _estimate(
        const WineFacts(name: 'Vino di Mario', vintage: 2022),
      );
      final summary = _calculator.compute([
        _wine('g', name: 'Vino di Mario', window: generic),
        _wine('m', name: 'Madeira', wineType: 'fortified'),
        _wine(
          'b',
          name: 'Barolo',
          wineType: 'redStructured',
          window: _estimate(const WineFacts(name: 'Barolo', vintage: 2016)),
        ),
        _wine(
          'r',
          name: 'Rosso della casa',
          wineType: 'redLight',
          window: _estimate(
            const WineFacts(
              name: 'Rosso della casa',
              vintage: 2024,
              wineType: WineType.redLight,
            ),
          ),
        ),
        _wine(
          'u',
          name: 'Rosso della casa',
          wineType: 'redLight',
          style: WineStyle.redFresh,
          styleSource: FieldSource.user,
          window: _estimate(
            const WineFacts(
              name: 'Rosso della casa',
              vintage: 2024,
              wineType: WineType.redLight,
            ),
          ),
        ),
      ], _today);
      expect(summary.toConfirm.map((r) => r.wineId), ['m', 'r', 'g']);
      expect(summary.toConfirm.first.toString(), 'ToConfirmRow(m)');
      expect(summary, isNot(_calculator.compute(const [], _today)));
    });
  });

  group('cards', () {
    testWidgets('"by Mar 2027" in the drink-soon list', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: DrinkSoonSection(
            rows: const [
              DrinkSoonRow(
                wineId: 'a',
                name: 'Prosecco',
                quantity: 1,
                endYear: 2027,
                endMonth: 3,
              ),
            ],
            total: 1,
            onOpenWine: (_) {},
            onOpenStatus: (_) {},
          ),
        ),
        locale: const Locale('it'),
      );
      expect(find.textContaining('entro mar 2027'), findsOneWidget);
    });

    testWidgets('To confirm: count, list, tap; hidden when empty', (
      tester,
    ) async {
      String? opened;
      await pumpScreen(
        tester,
        Scaffold(
          body: ToConfirmCard(
            rows: const [ToConfirmRow(wineId: 'm', name: 'Madeira')],
            onOpenWine: (id) => opened = id,
          ),
        ),
      );
      expect(find.text('Da confermare'), findsOneWidget);
      expect(find.text('1 vino'), findsOneWidget);
      await tester.tap(find.byKey(const Key('to-confirm-m')));
      expect(opened, 'm');
      await pumpScreen(tester, const Scaffold(body: ToConfirmCard(rows: [])));
      expect(find.byKey(const Key('dashboard-to-confirm')), findsNothing);
    });
  });

  accessibilityMatrix(
    'ToConfirmCard',
    () => Scaffold(
      body: ToConfirmCard(
        rows: const [
          ToConfirmRow(wineId: 'm', name: 'Madeira', vintage: 2010),
          ToConfirmRow(wineId: 'g', name: 'Vino di Mario'),
        ],
        onOpenWine: (_) {},
      ),
    ),
  );
}
