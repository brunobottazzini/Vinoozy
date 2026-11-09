// The Revision 60 of the study (wine-style-profiles BR2.13) and the
// enological decisions of BR2.2-BR2.12 that the owner confirmed: each row
// estimated as a wine typed by hand would be.
import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

DrinkingWindow? _window(
  String name, {
  int? vintage = 2020,
  WineType? type,
  WineLevel? level,
  int? agingYear,
  int? agingMonth,
}) => estimateWindow(
  WineFacts(
    name: name,
    vintage: vintage,
    wineType: type,
    level: level,
    referenceYear: 2026,
    referenceMonth: 5,
    agingStartYear: agingYear,
    agingStartMonth: agingMonth,
  ),
);

List<int?> _offsets(DrinkingWindow w, int base) => [
  w.startYear - base,
  w.peakYear == null ? null : w.peakYear! - base,
  w.endYear == null ? null : w.endYear! - base,
];

void main() {
  group('BR2.13 "legacy invariato": today\'s window, the profile names it', () {
    const legacy = {
      'Barolo': ([8, 15, 30], StyleProfile.rLong),
      'Barbaresco': ([6, 12, 25], StyleProfile.rLong),
      'Brunello di Montalcino': ([8, 15, 30], StyleProfile.rLong),
      'Sauternes': ([5, 15, 40], StyleProfile.swBotrytis),
    };
    for (final MapEntry(key: name, value: expected) in legacy.entries) {
      test(name, () {
        final w = _window(name)!;
        expect(_offsets(w, 2020), expected.$1);
        expect(w.profile, expected.$2);
        expect(w.indicative, isFalse);
      });
    }
  });

  group('BR2.13 numeric candidates: the profile numbers', () {
    test('Rioja is R_MEDIUM 2/4/8', () {
      final w = _window('Rioja')!;
      expect(w.profile, StyleProfile.rMedium);
      expect(_offsets(w, 2020), [2, 4, 8]);
    });

    test('Muscadet is W_FRESH 0/1/3', () {
      final w = _window('Muscadet')!;
      expect(w.profile, StyleProfile.wFresh);
      expect(_offsets(w, 2020), [0, 1, 3]);
    });
  });

  group('BR2.13, BR2.14 "—/—/—" rows: indicative with today\'s values', () {
    test('Bordeaux rouge base is UNKNOWN, indicative, low', () {
      final w = _window('Bordeaux')!;
      expect(w.profile, StyleProfile.unknown);
      expect(w.indicative, isTrue);
      expect(w.confidence, Confidence.low);
    });

    test('Napa Valley base is indicative 4/8/18', () {
      final w = _window('Napa Valley')!;
      expect(w.indicative, isTrue);
      expect(_offsets(w, 2020), [4, 8, 18]);
    });

    test('Mosel Kabinett W_MEDIUM keeps 2/6/15; Spätlese W_AGE 3/8/20', () {
      final kab = _window('Mosel Kabinett')!;
      expect(kab.profile, StyleProfile.wMedium);
      expect(_offsets(kab, 2020), [2, 6, 15]);
      final spa = _window('Mosel Spätlese')!;
      expect(spa.profile, StyleProfile.wAge);
      expect(_offsets(spa, 2020), [3, 8, 20]);
    });
  });

  group('BR2.6 Prädikat', () {
    test('Auslese is sweet SW_BOTRYTIS 5/15/30', () {
      final w = _window('Mosel Auslese')!;
      expect(w.profile, StyleProfile.swBotrytis);
      expect(_offsets(w, 2020), [5, 15, 30]);
    });

    test('BA and TBA are never an Auslese, ice wine is SW_PASSITO', () {
      expect(_window('Mosel Beerenauslese')!.profile, StyleProfile.swBotrytis);
      expect(
        _window('Rheingau Trockenbeerenauslese')!.profile,
        StyleProfile.swBotrytis,
      );
      expect(_window('Mosel Eiswein')!.profile, StyleProfile.swPassito);
    });

    test('a dry Auslese is a white W_AGE', () {
      final r = resolveStyle(
        const WineFacts(name: 'Mosel Auslese trocken', vintage: 2020),
      );
      expect(r.profile, StyleProfile.wAge);
      expect(r.wineType, WineType.white);
    });
  });

  group('BR2.10 qualifiers', () {
    test(
      'Pauillac Grand Cru keeps its offsets 10/20/40 (ACTION_OVERRIDDEN)',
      () {
        expect(_offsets(_window('Pauillac Grand Cru')!, 2020), [10, 20, 40]);
        // The Grand Cru keeps its own offsets in every commune (R-05).
        expect(_window('Pauillac Grand Cru')!.qualifier, Qualifier.grandCru);
        expect(_offsets(_window('Margaux Grand Cru')!, 2020), [10, 18, 35]);
      },
    );

    test('Soave Superiore has the window of Soave', () {
      expect(
        _offsets(_window('Soave Superiore')!, 2020),
        _offsets(_window('Soave')!, 2020),
      );
    });
  });

  group('BR2.3 sparkling', () {
    test('Champagne non vintage is SP_CLASSIC from the disgorgement', () {
      final w = _window(
        'Champagne',
        vintage: null,
        agingYear: 2024,
        agingMonth: 3,
      )!;
      expect(w.profile, StyleProfile.spClassic);
      expect(w.unit, WindowUnit.months);
      expect([w.startYear, w.startMonth], [2024, 3]);
      expect([w.peakYear, w.peakMonth], [2025, 3]);
      expect([w.endYear, w.endMonth], [2027, 3]);
      expect(w.anchor, AgingAnchor.disgorgement);
      expect(w.confidence, Confidence.medium);
    });

    test('a vintage makes it SP_CLASSIC_AGE (R-07)', () {
      final w = _window('Champagne', agingYear: 2024, agingMonth: 3)!;
      expect(w.profile, StyleProfile.spClassicAge);
      expect([w.peakYear, w.peakMonth], [2027, 3]);
    });

    test('Franciacorta Riserva and "millesimato" are SP_CLASSIC_AGE', () {
      expect(
        _window('Franciacorta Riserva', vintage: null)!.profile,
        StyleProfile.spClassicAge,
      );
      expect(
        _window('Trento DOC Millesimato', vintage: null)!.profile,
        StyleProfile.spClassicAge,
      );
    });

    test('without a date: month added, start 0, low (BR6.2, BR8.3)', () {
      final w = _window('Champagne Riserva', vintage: null)!;
      expect(w.profile, StyleProfile.spClassicAge);
      expect([w.startYear, w.startMonth], [2026, 5]);
      expect([w.peakYear, w.peakMonth], [2029, 5]);
      expect(w.anchorFallback, isTrue);
      expect(w.confidence, Confidence.low);
    });

    test('Prosecco and Prosecco Dolce stay SP_TANK (BR3.2)', () {
      for (final name in ['Prosecco', 'Prosecco Superiore', 'Prosecco Dolce']) {
        final w = _window(name, vintage: null)!;
        expect(w.profile, StyleProfile.spTank, reason: name);
      }
    });

    test('Lambrusco is LAM_FRESH, its traditional method SP_CLASSIC', () {
      expect(
        _window('Lambrusco', vintage: null)!.profile,
        StyleProfile.lamFresh,
      );
      final classic = resolveStyle(
        const WineFacts(name: 'Lambrusco metodo classico', referenceYear: 2026),
      );
      expect(classic.profile, StyleProfile.spClassic);
      expect(classic.wineType, WineType.sparklingClassic);
    });
  });

  group('BR2.7, BR2.8, BR2.9 fortified', () {
    test('Porto categories', () {
      expect(_window('Porto Vintage')!.profile, StyleProfile.portVintage);
      final ruby = _window('Porto Ruby')!;
      expect(ruby.profile, StyleProfile.portLbv);
      expect(ruby.endYear, isNull);
      expect(_window('Porto Tawny 20 anni')!.profile, StyleProfile.portOx);
      expect(_window('Porto LBV')!.profile, StyleProfile.portLbv);
    });

    test('Sherry without a style word: indicative, no style', () {
      final r = resolveStyle(const WineFacts(name: 'Jerez', vintage: 2020));
      expect(r.profile, StyleProfile.fortUnknown);
      expect(r.style, isNull);
      expect(r.indicative, isTrue);
    });

    test('Sherry with a style word uses its profile', () {
      expect(_window('Jerez Fino')!.profile, StyleProfile.shFino);
      expect(_window('Jerez Amontillado')!.profile, StyleProfile.shAmont);
      expect(_window('Jerez Oloroso')!.profile, StyleProfile.shOloroso);
      expect(_window('Jerez Pedro Ximenez')!.profile, StyleProfile.shPx);
      expect(
        _window('Montilla-Moriles Pale Cream')!.profile,
        StyleProfile.shFino,
      );
    });

    test('Madeira is "To estimate" until a style is chosen', () {
      expect(_window('Madeira'), isNull);
      final chosen = estimateWindow(
        const WineFacts(
          name: 'Madeira',
          vintage: 2000,
          style: WineStyle.madeira,
          styleChosen: true,
        ),
      )!;
      expect(chosen.indicative, isTrue);
      expect(
        [chosen.startYear, chosen.peakYear, chosen.endYear],
        [2005, 2020, 2050],
      );
    });

    test('a fortified type without a style word has no window', () {
      expect(_window('Liquore della casa', type: WineType.fortified), isNull);
      final other = estimateWindow(
        const WineFacts(
          name: 'Liquore della casa',
          vintage: 2010,
          wineType: WineType.fortified,
          style: WineStyle.fortifiedOther,
          styleChosen: true,
        ),
      )!;
      expect(
        [other.startYear, other.peakYear, other.endYear],
        [2013, 2020, 2040],
      );
    });
  });

  group('BR2.11, BR2.14 generated rows and unknown styles', () {
    test('a sweet type without a style word is indicative 2/8/20', () {
      final w = _window('Dolce della casa', type: WineType.sweet)!;
      expect(w.profile, StyleProfile.unknown);
      expect(w.indicative, isTrue);
      expect(_offsets(w, 2020), [2, 8, 20]);
    });

    test('no information: generic indicative 1/3/6, never "light red"', () {
      final w = _window('Vino di Mario')!;
      expect(w.profile, StyleProfile.unknown);
      expect(w.basis, EstimationBasis.generic);
      expect(_offsets(w, 2020), [1, 3, 6]);
    });

    test('a grape keeps its window with the style to confirm', () {
      final r = resolveStyle(const WineFacts(name: 'Merlot', vintage: 2020));
      expect(r.basis, EstimationBasis.grape);
      expect([r.start, r.peak, r.end], [2, 5, 10]);
      expect(r.styleToConfirm, isTrue);
      expect(r.profile, StyleProfile.rMedium);
    });

    test('a sparkling grape uses its type profile', () {
      final r = resolveStyle(const WineFacts(name: 'Glera', vintage: 2020));
      expect(r.profile, StyleProfile.spTank);
      expect(r.basis, EstimationBasis.grape);
    });
  });

  group('BR2.15 style chosen by the user', () {
    test('the chosen profile wins over the legacy window', () {
      final w = estimateWindow(
        const WineFacts(
          name: 'Barolo',
          vintage: 2020,
          style: WineStyle.redAge,
          styleChosen: true,
        ),
      )!;
      expect(w.profile, StyleProfile.rAge);
      expect(_offsets(w, 2020), [4, 8, 15]);
    });

    test('an automatic style does not override the map', () {
      final w = estimateWindow(
        const WineFacts(name: 'Barolo', vintage: 2020, style: WineStyle.redAge),
      )!;
      expect(w.profile, StyleProfile.rLong);
    });
  });

  group('BR4.1 level: absolute, never counted twice', () {
    test('Barolo "good" stays 8/15/30', () {
      expect(_offsets(_window('Barolo', level: WineLevel.good)!, 2020), [
        8,
        15,
        30,
      ]);
    });

    test('Barolo "aging" multiplies; Barolo Riserva "aging" does not', () {
      expect(_offsets(_window('Barolo', level: WineLevel.aging)!, 2020), [
        10,
        20,
        42,
      ]);
      expect(
        _offsets(_window('Barolo Riserva', level: WineLevel.aging)!, 2020),
        [10, 18, 35],
      );
    });

    test('the level changes no window in months', () {
      final good = _window(
        'Prosecco',
        vintage: null,
        agingYear: 2025,
        agingMonth: 1,
      )!;
      final everyday = _window(
        'Prosecco',
        vintage: null,
        agingYear: 2025,
        agingMonth: 1,
        level: WineLevel.everyday,
      )!;
      expect(everyday, good);
    });
  });
}
