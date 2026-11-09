import 'package:estimation/src/errors.dart';
import 'package:estimation/src/models.dart';
import 'package:test/test.dart';

void main() {
  group('WineType.tryParse (BR1.7)', () {
    test('accepts every enum name as it is', () {
      for (final type in WineType.values) {
        expect(WineType.tryParse(type.name), type, reason: type.name);
      }
    });

    test('maps the C1 values', () {
      expect(WineType.tryParse('red'), WineType.redStructured);
      expect(WineType.tryParse('white'), WineType.white);
      expect(WineType.tryParse('rose'), WineType.rose);
      expect(WineType.tryParse('sparkling'), WineType.sparklingClassic);
      expect(WineType.tryParse('sweet'), WineType.sweet);
    });

    test('trims surrounding spaces', () {
      expect(WineType.tryParse('  fortified '), WineType.fortified);
    });

    test('unknown, empty and null values are absent, never errors', () {
      expect(WineType.tryParse(null), isNull);
      expect(WineType.tryParse(''), isNull);
      expect(WineType.tryParse('orange'), isNull);
      expect(WineType.tryParse('RED'), isNull);
      expect(WineType.tryParse('generic'), isNull);
    });

    test('isSparkling is true only for the two sparkling types', () {
      final sparkling = WineType.values.where((t) => t.isSparkling).toSet();
      expect(sparkling, {WineType.sparklingClassic, WineType.sparklingTank});
    });
  });

  group('EstimationBasis.resolveStoredBasis (W4)', () {
    test('keeps a stored basis', () {
      expect(
        EstimationBasis.resolveStoredBasis(
          WindowSource.internalRules,
          EstimationBasis.generic,
        ),
        EstimationBasis.generic,
      );
    });

    test('missing basis on a catalog window reads as catalog', () {
      expect(
        EstimationBasis.resolveStoredBasis(WindowSource.catalog, null),
        EstimationBasis.catalog,
      );
    });

    test('missing basis on an internal window reads as wineType', () {
      expect(
        EstimationBasis.resolveStoredBasis(WindowSource.internalRules, null),
        EstimationBasis.wineType,
      );
    });
  });

  group('DrinkingWindow', () {
    DrinkingWindow window({
      EstimationBasis basis = EstimationBasis.denomination,
      Qualifier? qualifier,
    }) => DrinkingWindow(
      startYear: 2024,
      peakYear: 2031,
      endYear: 2046,
      confidence: Confidence.medium,
      source: WindowSource.internalRules,
      basis: basis,
      qualifier: qualifier,
    );

    test('equal fields give equal values and hash codes', () {
      expect(window(), window());
      expect(window().hashCode, window().hashCode);
    });

    test('any different field breaks equality', () {
      expect(window(), isNot(window(qualifier: Qualifier.riserva)));
      expect(window(), isNot(window(basis: EstimationBasis.wineType)));
      expect(
        window(),
        isNot(
          const DrinkingWindow(
            startYear: 2024,
            peakYear: 2031,
            endYear: 2046,
            confidence: Confidence.low,
            source: WindowSource.internalRules,
            basis: EstimationBasis.denomination,
          ),
        ),
      );
    });

    test('warningCode is GENERIC_ESTIMATE only for a generic basis', () {
      expect(
        window(basis: EstimationBasis.generic).warningCode,
        'GENERIC_ESTIMATE',
      );
      expect(genericEstimateWarningCode, 'GENERIC_ESTIMATE');
      for (final basis in EstimationBasis.values) {
        if (basis == EstimationBasis.generic) continue;
        expect(window(basis: basis).warningCode, isNull, reason: basis.name);
      }
    });

    test('toString names the years and the enums', () {
      expect(
        window(qualifier: Qualifier.riserva).toString(),
        'DrinkingWindow(2024/2031/2046, confidence: medium, '
        'source: internalRules, basis: denomination, qualifier: riserva)',
      );
    });
  });

  group('WineFacts (NFR8.1)', () {
    const full = WineFacts(
      name: 'Barolo',
      producer: 'Cantina',
      vintage: 2016,
      wineType: WineType.redStructured,
      region: 'Piemonte',
      denomination: 'Barolo DOCG',
      referenceYear: 2026,
    );

    test('fields are exactly those of entities.md, none personal', () {
      final fieldNames = RegExp(r'(\w+): ')
          .allMatches(full.toString())
          .map((m) => m.group(1))
          .toList();
      expect(fieldNames, [
        'name',
        'producer',
        'vintage',
        'wineType',
        'region',
        'denomination',
        'referenceYear',
        // label-autofill-windows ENT-005: the level, not personal either.
        'level',
      ]);
    });

    test('value equality on every field', () {
      const same = WineFacts(
        name: 'Barolo',
        producer: 'Cantina',
        vintage: 2016,
        wineType: WineType.redStructured,
        region: 'Piemonte',
        denomination: 'Barolo DOCG',
        referenceYear: 2026,
      );
      expect(full, same);
      expect(full.hashCode, same.hashCode);
      expect(full, isNot(const WineFacts(name: 'Barolo', vintage: 2016)));
      expect(
        const WineFacts(name: 'Barolo', referenceYear: 2025),
        isNot(const WineFacts(name: 'Barolo', referenceYear: 2026)),
      );
    });
  });

  group('ExternalProfile', () {
    test('value equality includes the pairings list', () {
      const a = ExternalProfile(
        startYear: 2020,
        peakYear: 2025,
        endYear: 2030,
        pairings: ['Brasato', 'Tartufo'],
        wineType: 'red',
      );
      final b = ExternalProfile(
        startYear: 2020,
        peakYear: 2025,
        endYear: 2030,
        pairings: List.of(['Brasato', 'Tartufo']),
        wineType: 'red',
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const ExternalProfile(pairings: ['Brasato'])));
      expect(
        const ExternalProfile(pairings: ['a', 'b']),
        isNot(const ExternalProfile(pairings: ['a', 'c'])),
      );
    });

    test('window and pairings are optional', () {
      const empty = ExternalProfile();
      expect(empty.startYear, isNull);
      expect(empty.pairings, isEmpty);
      expect(empty.toString(), contains('window: null/null/null'));
    });
  });

  group('Pairings', () {
    test('value equality on items, keys and source', () {
      const a = Pairings(
        items: [],
        categoryKeys: [PairingCategory.fish, PairingCategory.risotto],
        source: WindowSource.internalRules,
      );
      final b = Pairings(
        items: const [],
        categoryKeys: List.of([PairingCategory.fish, PairingCategory.risotto]),
        source: WindowSource.internalRules,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(
        a,
        isNot(
          const Pairings(
            items: [],
            categoryKeys: [PairingCategory.fish, PairingCategory.risotto],
            source: WindowSource.catalog,
          ),
        ),
      );
      expect(
        a.toString(),
        'Pairings(items: [], categoryKeys: [fish, risotto], '
        'source: internalRules)',
      );
    });
  });

  group('EstimationArgumentError', () {
    test('is an ArgumentError carrying a stable code', () {
      final error = EstimationArgumentError(
        EstimationErrorCode.vintageOutOfRange,
        'vintage',
        1800,
      );
      expect(error, isA<ArgumentError>());
      expect(error.code, EstimationErrorCode.vintageOutOfRange);
      expect(error.name, 'vintage');
      expect(error.invalidValue, 1800);
      expect(error.message, 'vintageOutOfRange');
    });

    test('the code set is the one of security-design.md §2', () {
      expect(EstimationErrorCode.values.map((c) => c.name), [
        'emptyName',
        'vintageOutOfRange',
        'referenceYearOutOfRange',
        'missingReferenceYear',
        'invalidWindow',
        // wine-style-profiles BR8.2, BR6.10.
        'monthOutOfRange',
        'invalidAgingStart',
      ]);
    });
  });
}
