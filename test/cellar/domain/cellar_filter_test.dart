// CellarFilter (u4-cellar BR1.8; FR3.2; AC3.2.1, AC3.2.2; NFR2.1).
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/cellar_filter.dart';

import '../cellar_harness.dart';

void main() {
  final today = DateTime(2026, 11, 6);
  final wines = [
    cellarWine(
      'w1',
      name: 'Barolo Città',
      producer: 'Giacomo',
      window: windowOf(2024, 2028, 2034),
    ),
    cellarWine(
      'w2',
      name: 'Soave',
      producer: 'Pieropan',
      wineType: 'white',
      window: windowOf(2027, 2028, 2030),
    ),
    cellarWine('w3', name: 'Vino rosso', wineType: null, producer: null),
    cellarWine(
      'w4',
      name: 'Prosecco',
      wineType: 'sparkling',
      window: windowOf(2018, 2019, 2020),
    ),
  ];

  List<String> ids(CellarFilter filter) =>
      filter.apply(wines, today).map((w) => w.id).toList();

  test('BR1.8 no filter keeps the list as it is', () {
    expect(CellarFilter.none.isEmpty, isTrue);
    expect(CellarFilter.none.apply(wines, today), same(wines));
  });

  test('BR1.8 search ignores case and accents in name and producer', () {
    expect(ids(const CellarFilter(query: 'CITTA')), ['w1']);
    expect(ids(const CellarFilter(query: 'piéropan')), ['w2']);
    expect(ids(const CellarFilter(query: 'xyz')), isEmpty);
  });

  test('BR1.8 status filter with "to estimate"', () {
    expect(ids(const CellarFilter(statuses: {StatusFilter.ready})), ['w1']);
    expect(ids(const CellarFilter(statuses: {StatusFilter.waiting})), ['w2']);
    expect(ids(const CellarFilter(statuses: {StatusFilter.toEstimate})), [
      'w3',
    ]);
    expect(ids(const CellarFilter(statuses: {StatusFilter.pastWindow})), [
      'w4',
    ]);
  });

  test('BR1.8 type filter with "not specified"', () {
    expect(ids(const CellarFilter(types: {TypeFilter.red})), ['w1']);
    expect(ids(const CellarFilter(types: {TypeFilter.notSpecified})), ['w3']);
    expect(
      ids(const CellarFilter(types: {TypeFilter.white, TypeFilter.sparkling})),
      ['w2', 'w4'],
    );
  });

  test('BR1.8 groups combine: search, status and type together', () {
    const filter = CellarFilter(
      query: 'o',
      statuses: {StatusFilter.ready, StatusFilter.pastWindow},
      types: {TypeFilter.sparkling},
    );

    expect(ids(filter), ['w4']);
  });

  test('an inconsistent window counts as "to estimate"', () {
    final broken = cellarWine('wx', window: windowOf(2030, 2020, 2025));

    expect(wineStatusOn(broken, today), StatusFilter.toEstimate);
    expect(statusIndexOf([broken], today), {'wx': StatusFilter.toEstimate});
  });

  test('a precomputed status index is used as given', () {
    const filter = CellarFilter(statuses: {StatusFilter.waiting});
    final index = {for (final w in wines) w.id: StatusFilter.waiting};

    expect(filter.apply(wines, today, statusIndex: index).length, 4);
  });

  test('type mapping of the stored values', () {
    expect(TypeFilter.of('redLight'), TypeFilter.red);
    expect(TypeFilter.of('rose'), TypeFilter.rose);
    expect(TypeFilter.of('fortified'), TypeFilter.sweet);
    expect(TypeFilter.of('sparklingTank'), TypeFilter.sparkling);
    expect(TypeFilter.of('beer'), TypeFilter.notSpecified);
  });

  test('equality and copyWith', () {
    const a = CellarFilter(statuses: {StatusFilter.ready});
    final b = CellarFilter.none.copyWith(statuses: {StatusFilter.ready});

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a.copyWith(query: 'x'), isNot(a));
  });
}
