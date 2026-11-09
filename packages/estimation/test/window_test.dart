import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

/// [estimateWindow] for a wine that has a window (every wine of this file).
DrinkingWindow estimated(WineFacts wine, [ExternalProfile? external]) =>
    estimateWindow(wine, external)!;

/// Years of [window] as a list, for compact expectations.
List<int?> years(DrinkingWindow window) => [
  window.startYear,
  window.peakYear,
  window.endYear,
];

Matcher throwsEstimationError(EstimationErrorCode code) =>
    throwsA(isA<EstimationArgumentError>().having((e) => e.code, 'code', code));

void main() {
  group('functional-spec.md W1 examples', () {
    test('"Barolo 2016" -> 2024/2031/2046, medium, denomination', () {
      final window = estimated(const WineFacts(name: 'Barolo', vintage: 2016));
      expect(years(window), [2024, 2031, 2046]);
      expect(window.confidence, Confidence.medium);
      expect(window.basis, EstimationBasis.denomination);
      expect(window.source, WindowSource.internalRules);
      expect(window.qualifier, isNull);
      expect(window.warningCode, isNull);
    });

    test('"Barolo Riserva 2016" -> 2026/2034/2051, medium, riserva', () {
      final window = estimated(
        const WineFacts(name: 'Barolo Riserva', vintage: 2016),
      );
      expect(years(window), [2026, 2034, 2051]);
      expect(window.confidence, Confidence.medium);
      expect(window.qualifier, Qualifier.riserva);
    });

    test('"Barbera d\'Asti Superiore DOCG" without vintage, entered 2026 '
        '-> 2028/2031/2037 (base 2025), low', () {
      final window = estimated(
        const WineFacts(
          name: "Barbera d'Asti Superiore DOCG",
          referenceYear: 2026,
        ),
      );
      expect(years(window), [2028, 2031, 2037]);
      expect(window.confidence, Confidence.low);
      expect(window.basis, EstimationBasis.denomination);
      expect(window.qualifier, Qualifier.superiore);
    });

    test('"Rosso della casa 2023", type redLight -> 2024/2025/2027, low', () {
      final window = estimated(
        const WineFacts(
          name: 'Rosso della casa',
          vintage: 2023,
          wineType: WineType.redLight,
        ),
      );
      // wine-style-profiles BR5.6: a light red by type is R_FRESH 0/1/3
      // (was the type row 1/2/4).
      expect(years(window), [2023, 2024, 2026]);
      expect(window.confidence, Confidence.low);
      expect(window.basis, EstimationBasis.wineType);
    });

    test('"Vino di Mario 2022", unknown type -> 2023/2025/2028, generic', () {
      final window = estimated(
        const WineFacts(name: 'Vino di Mario', vintage: 2022),
      );
      expect(years(window), [2023, 2025, 2028]);
      expect(window.confidence, Confidence.low);
      expect(window.basis, EstimationBasis.generic);
      expect(window.warningCode, 'GENERIC_ESTIMATE');
    });
  });

  group('catalog profile (BR1.4, BR1.6, BR3.1)', () {
    const barolo = WineFacts(name: 'Barolo', vintage: 2016);

    test('a valid catalog window wins with the catalog confidence', () {
      final window = estimated(
        barolo,
        const ExternalProfile(
          startYear: 2022,
          peakYear: 2030,
          endYear: 2045,
          confidence: Confidence.medium,
          vintage: 2016,
        ),
      );
      expect(years(window), [2022, 2030, 2045]);
      expect(window.source, WindowSource.catalog);
      expect(window.basis, EstimationBasis.catalog);
      expect(window.confidence, Confidence.medium);
      expect(needsRefinement(window), isFalse);
    });

    test('without a catalog confidence the window is high', () {
      final window = estimated(
        barolo,
        const ExternalProfile(startYear: 2022, peakYear: 2030, endYear: 2045),
      );
      expect(window.confidence, Confidence.high);
    });

    test('a profile requested without any vintage is at most low', () {
      final window = estimated(
        const WineFacts(name: 'Franciacorta Brut', referenceYear: 2026),
        const ExternalProfile(
          startYear: 2026,
          peakYear: 2028,
          endYear: 2031,
          confidence: Confidence.high,
        ),
      );
      expect(window.confidence, Confidence.low);
      expect(window.source, WindowSource.catalog);
    });

    test('a profile without vintage uses the vintage of WineFacts', () {
      final window = estimated(
        barolo,
        const ExternalProfile(
          startYear: 2022,
          peakYear: 2030,
          endYear: 2045,
          confidence: Confidence.high,
        ),
      );
      expect(window.confidence, Confidence.high);
    });

    test('inverted catalog years are ignored: internal rules apply', () {
      final window = estimated(
        barolo,
        const ExternalProfile(startYear: 2040, peakYear: 2030, endYear: 2020),
      );
      expect(years(window), [2024, 2031, 2046]);
      expect(window.source, WindowSource.internalRules);
      expect(needsRefinement(window), isTrue);
    });

    test('a missing or out-of-range catalog window is ignored', () {
      expect(
        estimated(barolo, const ExternalProfile()).source,
        WindowSource.internalRules,
      );
      expect(
        estimated(
          barolo,
          const ExternalProfile(startYear: 1800, peakYear: 1810, endYear: 1820),
        ).source,
        WindowSource.internalRules,
      );
      expect(
        estimated(
          barolo,
          const ExternalProfile(startYear: 2020, peakYear: 2030),
        ).source,
        WindowSource.internalRules,
      );
    });

    test('an ignored window still lends its type to the rules (BR1.6)', () {
      final window = estimated(
        const WineFacts(name: 'Cuvée della casa', vintage: 2024),
        const ExternalProfile(
          wineType: 'white',
          startYear: 2030,
          endYear: 2020,
        ),
      );
      expect(window.basis, EstimationBasis.wineType);
      // wine-style-profiles BR5.6: a white by type is W_MEDIUM 1/3/6.
      expect(years(window), [2025, 2027, 2030]);
    });
  });

  group('confidence of internal estimates (BR3.1)', () {
    test('denomination without vintage is low', () {
      final window = estimated(
        const WineFacts(name: 'Barolo', referenceYear: 2026),
      );
      expect(window.confidence, Confidence.low);
      expect(years(window), [2033, 2040, 2055]);
    });

    test('a type estimate with vintage is low', () {
      final window = estimated(
        const WineFacts(
          name: 'Cuvée',
          vintage: 2020,
          wineType: WineType.redStructured,
        ),
      );
      expect(window.confidence, Confidence.low);
    });
  });

  group('base year without vintage (BR1.3)', () {
    test('sparkling wines count from the reference year itself', () {
      expect(
        years(
          estimated(
            const WineFacts(name: 'Franciacorta Brut', referenceYear: 2026),
          ),
        ),
        // wine-style-profiles BR6.2: the sparkling wines count in months;
        // without the disgorgement date, from the month added (January
        // without referenceMonth) with start 0: SP_CLASSIC 0/12/36.
        [2026, 2027, 2029],
      );
      expect(
        years(
          estimated(const WineFacts(name: 'Prosecco', referenceYear: 2026)),
        ),
        // SP_TANK 0/6/18 months from January 2026.
        [2026, 2026, 2027],
      );
    });

    test('a generic estimate counts from the reference year itself', () {
      final window = estimated(
        const WineFacts(name: 'Vino di Mario', referenceYear: 2026),
      );
      expect(years(window), [2027, 2029, 2032]);
      expect(window.basis, EstimationBasis.generic);
    });

    test('fortified and sweet wines count from the year before', () {
      expect(
        years(estimated(const WineFacts(name: 'Marsala', referenceYear: 2026))),
        [2028, 2035, 2055],
      );
      expect(
        years(
          estimated(
            const WineFacts(
              name: 'Passito',
              wineType: WineType.sweet,
              referenceYear: 2026,
            ),
          ),
        ),
        // wine-style-profiles BR2.16: "passito" is SW_PASSITO 3/8/20.
        [2028, 2033, 2045],
      );
    });

    test('a vintage always wins over the reference year', () {
      expect(
        years(
          estimated(
            const WineFacts(name: 'Barolo', vintage: 2016, referenceYear: 2026),
          ),
        ),
        [2024, 2031, 2046],
      );
    });
  });

  group('edge cases of functional-spec.md', () {
    test('a future vintage is estimated normally and is waiting', () {
      final window = estimated(const WineFacts(name: 'Soave', vintage: 2027));
      expect(years(window), [2028, 2029, 2032]);
      expect(statusOf(window, DateTime(2026, 9, 1)), WineStatus.waiting);
    });

    test('a very old vintage is past its window, not an error', () {
      final window = estimated(const WineFacts(name: 'Barolo', vintage: 1950));
      expect(years(window), [1958, 1965, 1980]);
      expect(statusOf(window, DateTime(2026, 9, 1)), WineStatus.pastWindow);
    });

    test('a hand-picked type different from the name uses the type table', () {
      final window = estimated(
        const WineFacts(
          name: 'Barolo bianco della casa',
          vintage: 2024,
          wineType: WineType.white,
        ),
      );
      expect(window.basis, EstimationBasis.wineType);
      // wine-style-profiles BR5.6: a white by type is W_MEDIUM 1/3/6.
      expect(years(window), [2025, 2027, 2030]);
    });

    test('a qualifier without its own offsets uses the base row', () {
      final window = estimated(
        const WineFacts(name: 'Barolo Superiore', vintage: 2016),
      );
      expect(years(window), [2024, 2031, 2046]);
      expect(window.qualifier, isNull);
    });

    test('the supported year limits 1900 and 2200 are accepted', () {
      expect(
        estimated(const WineFacts(name: 'Barolo', vintage: 1900)).startYear,
        1908,
      );
      expect(
        estimated(const WineFacts(name: 'Barolo', vintage: 2200)).startYear,
        2208,
      );
    });
  });

  group('invalid inputs (BR4.5)', () {
    test('empty name after trimming', () {
      expect(
        () => estimated(const WineFacts(name: '   ', vintage: 2020)),
        throwsEstimationError(EstimationErrorCode.emptyName),
      );
    });

    test('vintage outside 1900..2200', () {
      expect(
        () => estimated(const WineFacts(name: 'Barolo', vintage: 1899)),
        throwsEstimationError(EstimationErrorCode.vintageOutOfRange),
      );
      expect(
        () => estimated(const WineFacts(name: 'Barolo', vintage: 2201)),
        throwsEstimationError(EstimationErrorCode.vintageOutOfRange),
      );
    });

    test('reference year outside 1900..2200', () {
      expect(
        () => estimated(const WineFacts(name: 'Barolo', referenceYear: 1066)),
        throwsEstimationError(EstimationErrorCode.referenceYearOutOfRange),
      );
    });

    test('neither vintage nor reference year', () {
      expect(
        () => estimated(const WineFacts(name: 'Barolo')),
        throwsEstimationError(EstimationErrorCode.missingReferenceYear),
      );
    });

    test('a valid catalog window does not bypass the checks', () {
      expect(
        () => estimated(
          const WineFacts(name: ''),
          const ExternalProfile(startYear: 2020, peakYear: 2025, endYear: 2030),
        ),
        throwsEstimationError(EstimationErrorCode.emptyName),
      );
    });
  });
}
