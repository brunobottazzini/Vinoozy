// LabelLookupFlow on a merged reading (label-recognition FR2.4, BR3.1-BR3.5,
// BR4.1; u6 BR1.8, BR1.11, BR1.12): one matchLabel call, the vintage read,
// the three not-found kinds and catalog errors that never block.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/label/core/label_lookup_flow.dart';
import 'package:vinoozy/label/core/label_merge.dart';

import '../label_harness.dart';

void main() {
  late LabelCatalog catalog;
  late List<Object> failures;
  late LabelLookupFlow flow;

  setUp(() {
    catalog = LabelCatalog();
    failures = [];
    flow = LabelLookupFlow(
      catalog: catalog,
      currentYear: () => 2026,
      onFailure: (error, _) => failures.add(error),
    );
  });

  Future<LookupOutcome> run(
    String text, {
    String? barcode,
    CatalogLocale locale = CatalogLocale.it,
  }) => flow.run(
    MergedReading(text: text, barcode: barcode),
    locale: locale,
  );

  group('BR1.8 FR2.4 one lookup per reading', () {
    test('BR1.8 the merged text, the barcode and the app language reach '
        'matchLabel once (NFR5.1)', () async {
      catalog.byLabel = sureMatch(candidateOf('Barolo Riserva'));
      final outcome = await run(
        'Barolo DOCG',
        barcode: testEan13,
        locale: CatalogLocale.ptBR,
      );
      expect((outcome as LookupSure).candidate.name, 'Barolo Riserva');
      expect(catalog.textCalls, ['Barolo DOCG']);
      expect(catalog.labelBarcodes, [testEan13]);
      expect(catalog.textLocales, [CatalogLocale.ptBR]);
      expect(catalog.barcodeCalls, isEmpty);
    });

    test('BR1.8 the vintage read on the label replaces the sure '
        "candidate's", () async {
      catalog.byLabel = sureMatch(candidateOf('Barolo', vintage: 2019));
      final outcome = await run('Barolo DOCG 2016', barcode: testEan13);
      expect((outcome as LookupSure).candidate.vintage, 2016);
    });

    test(
      "BR1.8 with no year on the label the candidate's vintage stays",
      () async {
        catalog.byLabel = sureMatch(candidateOf('Barolo DOCG', vintage: 2018));
        final outcome = await run('Barolo DOCG');
        expect((outcome as LookupSure).candidate.vintage, 2018);
      },
    );

    test('BR3.2 candidates keep their own vintage; those without get the '
        'one read', () async {
      catalog.byLabel = candidatesMatch([
        candidateOf('Barbaresco Asili', vintage: 2019),
        candidateOf('Barbaresco'),
      ]);
      final outcome = await run('Barbaresco 2017') as LookupCandidates;
      expect(outcome.candidates.map((c) => c.vintage), [2019, 2017]);
      expect(outcome.step, LabelMatchStep.offlineText);
      expect(outcome.notFound.kind, NotFoundKind.noMatch);
    });

    test('BR3.5 a sure proposal carries the alternatives and the not-found '
        'outcome for "Non è questo"', () async {
      catalog.byLabel = sureMatch(
        candidateOf('Barolo Ravera'),
        others: [candidateOf('Barolo Bussia')],
        step: LabelMatchStep.offlineBarcode,
      );
      final outcome = await run('Elvio Cogno\nBarolo\n2016') as LookupSure;
      expect(outcome.step, LabelMatchStep.offlineBarcode);
      expect(outcome.alternatives.single.name, 'Barolo Bussia');
      expect(outcome.alternatives.single.vintage, 2016);
      expect(outcome.notFound.name, 'Barolo', reason: 'BR1.12 denomination');
    });

    test('BR1.8 a failing catalog never blocks: not found, reported '
        '(NFR6.3)', () async {
      catalog.textError = Exception('rate limited');
      final outcome = await run('Cantina del Lago\nRosso 2020');
      final notFound = outcome as LookupNotFound;
      expect(notFound.kind, NotFoundKind.noMatch);
      expect(notFound.name, 'Cantina del Lago');
      expect(notFound.vintage, 2020);
      expect(failures, hasLength(1));
    });

    test('BR1.8 an invalid input of the catalog is "nothing found", not '
        'reported', () async {
      catalog.textError = CatalogArgumentError(CatalogErrorCode.textTooLong);
      final outcome = await run('Cantina del Lago', barcode: testEan13);
      expect(outcome, isA<LookupNotFound>());
      expect(failures, isEmpty);
    });

    test('NFR4.1 only the barcode and the text reach the catalog', () async {
      await run(labelMarkers.first, barcode: testEan13);
      expect(catalog.labelBarcodes.single, testEan13);
      expect(catalog.textCalls.single, labelMarkers.first);
      expect(catalog.textCalls.single, isNot(contains('.jpg')));
    });
  });

  group('BR3.4 BR1.11 not found', () {
    test('BR1.11 BR3.4 no valid code and fewer than 3 letters: unreadable, '
        'no request', () async {
      final outcome = await run('12 a');
      expect((outcome as LookupNotFound).kind, NotFoundKind.unreadable);
      expect(catalog.calls, 0);
    });

    test('BR1.12 BR3.4 text read and no wine: noMatch with the most '
        'significant line, the vintage and the search words', () async {
      final outcome = await run('750 ml\nTenuta Rossi Collina\n2019');
      final notFound = outcome as LookupNotFound;
      expect(notFound.kind, NotFoundKind.noMatch);
      expect(notFound.name, 'Tenuta Rossi Collina');
      expect(notFound.vintage, 2019);
      expect(notFound.query, 'tenuta rossi collina 2019');
    });

    test('BR3.4 a barcode with no wine and no text: barcodeNotFound, the '
        'barcode as query', () async {
      final outcome = await run('75', barcode: testEan13);
      final notFound = outcome as LookupNotFound;
      expect(notFound.kind, NotFoundKind.barcodeNotFound);
      expect(notFound.query, testEan13);
      expect(catalog.labelBarcodes.single, testEan13);
    });
  });

  group('BR4.1 search words', () {
    test('BR4.1 the longest words in text order, the vintage, at most 120', () {
      expect(
        LabelLookupFlow.searchQueryOf(
          'CHÂTEAU MUSAR\n2015\nBEKAA VALLEY\nLEBANON',
          vintage: 2015,
        ),
        'chateau musar bekaa valley lebanon 2015',
      );
      expect(LabelLookupFlow.searchQueryOf('', barcode: testEan8), testEan8);
      expect(LabelLookupFlow.searchQueryOf('12'), '');
      final long = LabelLookupFlow.searchQueryOf(
        List.filled(6, 'a' * 30).join(' '),
      );
      expect(long.length, lessThanOrEqualTo(LabelLookupFlow.maxQueryLength));
    });
  });
}
