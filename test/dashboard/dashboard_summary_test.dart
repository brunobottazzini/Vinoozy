import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/dashboard/domain/dashboard_summary.dart';

DashboardSummary summary({
  int total = 5,
  List<DrinkSoonRow>? drinkSoon,
  List<BreakdownBar>? byRegion,
  int invalid = 0,
}) => DashboardSummary(
  totalBottles: total,
  waitingBottles: 1,
  readyBottles: 2,
  drinkSoonBottles: 1,
  pastWindowBottles: 0,
  toEstimateBottles: 1,
  drinkSoon:
      drinkSoon ??
      const [
        DrinkSoonRow(
          wineId: 'w1',
          name: 'Barolo',
          vintage: 2016,
          producer: 'Cantina',
          quantity: 1,
          endYear: 2026,
        ),
      ],
  drinkSoonTotal: 1,
  peakYears: const [
    PeakYearBar(kind: PeakColumnKind.pastPeak, bottles: 0),
    PeakYearBar(kind: PeakColumnKind.year, year: 2026, bottles: 4),
    PeakYearBar(kind: PeakColumnKind.beyond, bottles: 0),
  ],
  byType: const [
    BreakdownBar(
      kind: BreakdownKind.family,
      family: WineFamily.red,
      bottles: 5,
    ),
  ],
  byRegion:
      byRegion ??
      const [
        BreakdownBar(
          kind: BreakdownKind.region,
          region: 'Piemonte',
          bottles: 5,
        ),
      ],
  invalidWindowCount: invalid,
);

void main() {
  test('summaries with the same values are equal, with the same hashCode', () {
    final a = summary();
    final b = summary(drinkSoon: [...a.drinkSoon], byRegion: [...a.byRegion]);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(identical(a.drinkSoon, b.drinkSoon), isFalse);
  });

  test('a different count, row or bar makes them different', () {
    final base = summary();

    expect(summary(total: 6), isNot(base));
    expect(summary(invalid: 1), isNot(base));
    expect(summary(drinkSoon: const []), isNot(base));
    expect(
      summary(
        byRegion: const [
          BreakdownBar(
            kind: BreakdownKind.region,
            region: 'Toscana',
            bottles: 5,
          ),
        ],
      ),
      isNot(base),
    );
  });

  test('bottlesWith maps each status to its bar (BR1.4)', () {
    final s = summary();

    expect(s.bottlesWith(WineStatus.waiting), 1);
    expect(s.bottlesWith(WineStatus.ready), 2);
    expect(s.bottlesWith(WineStatus.drinkSoon), 1);
    expect(s.bottlesWith(WineStatus.pastWindow), 0);
  });

  test('rows and bars compare by value', () {
    const row = DrinkSoonRow(
      wineId: 'w1',
      name: 'Barolo',
      quantity: 2,
      endYear: 2027,
    );
    const sameRow = DrinkSoonRow(
      wineId: 'w1',
      name: 'Barolo',
      quantity: 2,
      endYear: 2027,
    );
    const peak = PeakYearBar(kind: PeakColumnKind.year, year: 2030, bottles: 1);
    const bar = BreakdownBar(kind: BreakdownKind.unspecified, bottles: 3);

    expect(row, sameRow);
    expect(row.hashCode, sameRow.hashCode);
    expect(
      row,
      isNot(
        const DrinkSoonRow(
          wineId: 'w1',
          name: 'Barolo',
          quantity: 3,
          endYear: 2027,
        ),
      ),
    );
    expect(
      peak,
      const PeakYearBar(kind: PeakColumnKind.year, year: 2030, bottles: 1),
    );
    expect(
      peak,
      isNot(
        const PeakYearBar(kind: PeakColumnKind.year, year: 2031, bottles: 1),
      ),
    );
    expect(
      bar,
      const BreakdownBar(kind: BreakdownKind.unspecified, bottles: 3),
    );
    expect(bar.hashCode, isNot(0));
    expect(row.toString(), contains('w1'));
    expect(peak.toString(), contains('2030'));
    expect(bar.toString(), contains('unspecified'));
    expect(summary().toString(), contains('total: 5'));
  });
}
