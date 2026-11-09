// classifyWine (wine-style-profiles BR3, BR4.3-BR4.5, BR5.3): Type, Level and
// Style proposed for a wine.
import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

void main() {
  group('BR3.1 precedence: a denomination beats the words', () {
    test('Barolo: structured red, R_LONG, level "good" (BR4.2)', () {
      final p = classifyWine('Barolo 2016');
      expect(p.wineType, WineType.redStructured);
      expect(p.style, WineStyle.redLong);
      expect(p.level, WineLevel.good);
      expect(p.styleToConfirm, isFalse);
      expect(p.reasons, contains(PreselectionReason.denomination));
    });

    test('Barolo Riserva: "aging" (BR4.4)', () {
      expect(classifyWine('Barolo Riserva').level, WineLevel.aging);
    });

    test('Reserva and Premier Cru stay "good"', () {
      expect(classifyWine('Rioja Reserva').level, WineLevel.good);
      expect(classifyWine('Chablis Premier Cru').level, WineLevel.good);
    });

    test('a colour picks the type of a wide zone (BR3.3)', () {
      expect(classifyWine('Pessac-Léognan blanc').wineType, WineType.white);
      expect(classifyWine('Pessac-Léognan').wineType, WineType.redStructured);
    });
  });

  group('BR3.2 dosage words never beat a denomination or a method', () {
    test('Lambrusco dell\'Emilia Dolce stays sparklingTank LAM_FRESH', () {
      final p = classifyWine("Lambrusco dell'Emilia Dolce");
      expect(p.wineType, WineType.sparklingTank);
      expect(p.style, WineStyle.lambrusco);
      expect(p.level, WineLevel.everyday);
    });

    test('Crémant d\'Alsace Doux stays sparklingClassic', () {
      expect(
        classifyWine("Crémant d'Alsace Doux").wineType,
        WineType.sparklingClassic,
      );
    });

    test('Prosecco Dolce stays sparklingTank', () {
      final p = classifyWine('Prosecco Dolce');
      expect(p.wineType, WineType.sparklingTank);
      expect(p.style, WineStyle.tankFresh);
    });

    test('Dornfelder Rosé lieblich stays a rosé', () {
      expect(classifyWine('Dornfelder Rosé lieblich').wineType, WineType.rose);
    });

    test('a dosage word alone gives a sweet wine', () {
      final p = classifyWine('Cuvée amabile');
      expect(p.wineType, WineType.sweet);
      expect(p.style, WineStyle.sweetAromatic);
    });

    test('"Rosa dei Venti" gives no type from the name', () {
      expect(classifyWine('Rosa dei Venti').wineType, isNull);
    });
  });

  group('BR3.4-BR3.9 type without a denomination', () {
    test('generic table wine: light red, fresh, everyday (BR3.8)', () {
      final p = classifyWine('Vin rouge', dbType: WineType.redStructured);
      expect(p.wineType, WineType.redLight);
      expect(p.style, WineStyle.redFresh);
      expect(p.level, WineLevel.everyday);
    });

    test('a grape gives the type and the nearest style (BR3.6)', () {
      final p = classifyWine('Fetzer Sundial Chardonnay');
      expect(p.wineType, WineType.white);
      expect(p.style, WineStyle.whiteMedium);
      expect(p.reasons, contains(PreselectionReason.grape));
    });

    test('a colour-only grape gives the type, style to confirm', () {
      final p = classifyWine('Trebbiano della casa');
      expect(p.wineType, WineType.white);
      expect(p.styleToConfirm, isTrue);
    });

    test('Muscat is sweet; a dry Muscat is white', () {
      expect(classifyWine('Muscat de la maison').wineType, WineType.sweet);
      expect(classifyWine('Muscat sec').wineType, WineType.white);
    });

    test('the database type is the last clue (BR3.1 step 5)', () {
      final p = classifyWine('Cuvée Prestige', dbType: WineType.rose);
      expect(p.wineType, WineType.rose);
      expect(p.reasons, [PreselectionReason.dbType]);
    });

    test('Château without any clue: structured red to confirm (BR3.7)', () {
      final p = classifyWine('Château Lagrange', country: 'FR');
      expect(p.wineType, WineType.redStructured);
      expect(p.style, WineStyle.redMedium);
      expect(p.styleToConfirm, isTrue);
      expect(classifyWine('Château Lagrange', country: 'US').wineType, isNull);
    });

    test('no clue: no type, level good (BR3.9)', () {
      final p = classifyWine('Cuvée Mario');
      expect(p.wineType, isNull);
      expect(p.style, isNull);
      expect(p.level, WineLevel.good);
    });

    test('a product that is not wine has no type even with a db type', () {
      final p = classifyWine('Hard Seltzer lime', dbType: WineType.white);
      expect(p.wineType, isNull);
      expect(p.nonWine, isTrue);
      expect(classifyWine('Vin de liqueur').nonWine, isFalse);
      expect(classifyWine('Crème de cassis liqueur').nonWine, isTrue);
    });

    test('Riserva makes a light red structured (BR3.4)', () {
      expect(
        classifyWine('Rosso riserva della casa').wineType,
        WineType.redStructured,
      );
    });
  });

  group('BR2.6, BR2.7, BR2.8 categories', () {
    test('Kabinett white W_MEDIUM, Spätlese W_AGE', () {
      final kab = classifyWine('Mosel Riesling Kabinett');
      expect(kab.wineType, WineType.white);
      expect(kab.style, WineStyle.whiteMedium);
      final spa = classifyWine('Mosel Riesling Spätlese');
      expect(spa.style, WineStyle.whiteAge);
      expect(spa.level, WineLevel.good);
    });

    test('Auslese and BA are sweet, aging', () {
      final p = classifyWine('Riesling Beerenauslese');
      expect(p.wineType, WineType.sweet);
      expect(p.level, WineLevel.aging);
      expect(p.style, WineStyle.sweetBotrytis);
    });

    test('Porto Vintage: fortified, aging; Ruby: LBV style', () {
      final vintage = classifyWine('Porto Vintage 2017');
      expect(vintage.wineType, WineType.fortified);
      expect(vintage.level, WineLevel.aging);
      expect(vintage.style, WineStyle.portVintage);
      expect(classifyWine('Ruby Port').style, WineStyle.portLbv);
    });

    test('Sherry without a style word: no style preselected', () {
      final p = classifyWine('Jerez');
      expect(p.wineType, WineType.fortified);
      expect(p.style, isNull);
      expect(p.styleToConfirm, isTrue);
    });

    test('Madeira: the Madeira style, to confirm', () {
      final p = classifyWine('Madeira 10 years');
      expect(p.style, WineStyle.madeira);
      expect(p.styleToConfirm, isTrue);
    });

    test('a vintage traditional method is classicAge (BR2.3)', () {
      expect(classifyWine('Champagne Brut').style, WineStyle.classicFresh);
      expect(
        classifyWine('Champagne Brut', vintage: 2015).style,
        WineStyle.classicAge,
      );
    });

    test('Pauillac: structured red, R_LONG', () {
      final p = classifyWine('Château Latour Pauillac');
      expect(p.wineType, WineType.redStructured);
      expect(p.style, WineStyle.redLong);
    });
  });

  group('BR4.3 level', () {
    test('an IGT is everyday', () {
      expect(classifyWine('Toscana IGT rosso').level, WineLevel.everyday);
    });

    test('a fresh profile known for sure is everyday', () {
      expect(classifyWine('Muscadet').level, WineLevel.everyday);
    });

    test('a rosé is everyday', () {
      expect(classifyWine('Rosato del Salento').level, WineLevel.everyday);
    });

    test('Preselection equality and text', () {
      expect(classifyWine('Barolo'), classifyWine('Barolo'));
      expect(classifyWine('Barolo').hashCode, classifyWine('Barolo').hashCode);
      expect(classifyWine('Barolo').toString(), contains('redStructured'));
    });
  });
}
