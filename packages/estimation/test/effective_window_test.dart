// effectiveWindow and the limits of the manual end (label-autofill-windows
// D3, BR4.4, BR4.6, FR5.1, FR5.6).
import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

const _window = DrinkingWindow(
  startYear: 2024,
  peakYear: 2031,
  endYear: 2046,
  confidence: Confidence.medium,
  source: WindowSource.internalRules,
  basis: EstimationBasis.denomination,
  denominationKey: 'barolo',
  tablesVersion: 2,
);

List<int> years(DrinkingWindow window) => [
  window.startYear,
  window.peakYear,
  window.endYear,
];

void main() {
  group('effectiveWindow (BR4.4)', () {
    test('without a correction the window is the same object', () {
      expect(effectiveWindow(_window), same(_window));
    });

    test('a later end keeps start and peak', () {
      expect(years(effectiveWindow(_window, overrideEndYear: 2050)), [
        2024,
        2031,
        2050,
      ]);
    });

    test('an end before the peak brings the peak to it (FR5.1)', () {
      expect(years(effectiveWindow(_window, overrideEndYear: 2028)), [
        2024,
        2028,
        2028,
      ]);
    });

    test('an end equal to the start is valid; start never changes', () {
      expect(years(effectiveWindow(_window, overrideEndYear: 2024)), [
        2024,
        2024,
        2024,
      ]);
    });

    test('a feedback that moved the start past the end stops there '
        '(FR5.6)', () {
      final adjusted = _window.withYears(2030, 2034, 2049);
      expect(years(effectiveWindow(adjusted, overrideEndYear: 2028)), [
        2028,
        2028,
        2028,
      ]);
    });

    test('everything but the years is kept', () {
      final result = effectiveWindow(_window, overrideEndYear: 2030);
      expect(result.confidence, _window.confidence);
      expect(result.basis, _window.basis);
      expect(result.denominationKey, 'barolo');
      expect(result.tablesVersion, 2);
    });
  });

  group('BR4.6 limits of the manual end', () {
    test('from the start to the start plus 60', () {
      final range = overrideYearRange(_window);
      expect(range.first, 2024);
      expect(range.last, 2084);
      expect(maxOverrideSpan, 60);
    });

    test('isValidOverrideYear accepts the limits and refuses outside', () {
      expect(isValidOverrideYear(_window, 2024), isTrue);
      expect(isValidOverrideYear(_window, 2084), isTrue);
      expect(isValidOverrideYear(_window, 2023), isFalse);
      expect(isValidOverrideYear(_window, 2085), isFalse);
    });
  });
}
