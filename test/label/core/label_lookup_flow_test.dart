import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/label/core/label_lookup_flow.dart';
import 'package:vinoozy/label/core/label_reading.dart';

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

  LabelReading reading({String text = '', List<String> codes = const []}) =>
      LabelReading(
        text: text,
        barcodes: [
          for (final value in codes)
            ReadBarcode(LabelBarcodeFormat.ean13, value),
        ],
      );

  Future<LookupOutcome> run(
    LabelReading value, {
    bool online = true,
    CatalogLocale locale = CatalogLocale.it,
  }) => flow.run(value, online: online, locale: locale);

  group('BR1.8 lookup order', () {
    test(
      'BR1.8 a barcode and a network: lookupBarcode, text not asked',
      () async {
        catalog.byBarcode = candidateOf(
          'Barolo Riserva',
          producer: 'Cantina A',
        );
        final outcome = await run(
          reading(text: 'Barolo DOCG', codes: [testEan13]),
        );
        expect(outcome, isA<LookupProposal>());
        final proposal = outcome as LookupProposal;
        expect(proposal.candidate.name, 'Barolo Riserva');
        expect(proposal.offline, isFalse);
        expect(catalog.barcodeCalls, [testEan13]);
        expect(catalog.textCalls, isEmpty);
      },
    );

    test('BR1.8 no result for the barcode: matchLabelText with the text and '
        'the app language', () async {
      catalog.byText = LabelMatch.matched(candidateOf('Barolo DOCG'));
      final outcome = await run(
        reading(text: 'Barolo DOCG', codes: [testEan13]),
        locale: CatalogLocale.ptBR,
      );
      expect((outcome as LookupProposal).candidate.name, 'Barolo DOCG');
      expect(catalog.barcodeCalls, [testEan13]);
      expect(catalog.textCalls, ['Barolo DOCG']);
      expect(catalog.textLocales, [CatalogLocale.ptBR]);
    });

    test('BR1.8 without network the barcode is skipped and the proposal '
        'says so (BR1.9)', () async {
      catalog.byText = LabelMatch.matched(
        candidateOf('Barolo DOCG', source: CandidateSource.internal),
      );
      final outcome = await run(
        reading(text: 'Barolo DOCG', codes: [testEan13]),
        online: false,
      );
      expect((outcome as LookupProposal).offline, isTrue);
      expect(catalog.barcodeCalls, isEmpty);
      expect(catalog.textCalls, hasLength(1));
    });

    test(
      'BR1.8 the vintage read on the label replaces the candidate one',
      () async {
        catalog.byBarcode = candidateOf('Barolo', vintage: 2019);
        final outcome = await run(
          reading(text: 'Barolo DOCG 2016', codes: [testEan13]),
        );
        expect((outcome as LookupProposal).candidate.vintage, 2016);
      },
    );

    test(
      "BR1.8 with no year on the label the candidate's vintage stays",
      () async {
        catalog.byText = LabelMatch.matched(
          candidateOf('Barolo DOCG', vintage: 2018),
        );
        final outcome = await run(reading(text: 'Barolo DOCG'));
        expect((outcome as LookupProposal).candidate.vintage, 2018);
      },
    );

    test('BR1.8 a failing catalog never blocks: next step, then the U4 form '
        '(NFR6.3)', () async {
      catalog
        ..barcodeError = StateError('network down')
        ..textError = Exception('rate limited');
      final outcome = await run(
        reading(text: 'Cantina del Lago\nRosso 2020', codes: [testEan13]),
      );
      expect(outcome, isA<LookupIncomplete>());
      expect((outcome as LookupIncomplete).name, 'Cantina del Lago');
      expect(outcome.vintage, 2020);
      expect(failures, hasLength(2), reason: 'reported as lookup failures');
    });

    test('BR1.8 an invalid input of the catalog is "no result", not '
        'reported', () async {
      catalog
        ..barcodeError = CatalogArgumentError(CatalogErrorCode.invalidBarcode)
        ..textError = CatalogArgumentError(CatalogErrorCode.textTooLong);
      final outcome = await run(
        reading(text: 'Cantina del Lago', codes: [testEan13]),
      );
      expect(outcome, isA<LookupIncomplete>());
      expect(failures, isEmpty);
    });

    test('BR1.8 at most two catalog requests per photo (NFR5.1)', () async {
      await run(
        reading(text: 'Barolo DOCG 2016', codes: [testEan13, testEan8]),
      );
      expect(catalog.calls, 2);
      expect(catalog.barcodeCalls, hasLength(1));
    });

    test(
      'BR1.8 only the barcode and the text reach the catalog (NFR4.1)',
      () async {
        await run(reading(text: labelMarkers.first, codes: [testEan13]));
        expect(catalog.barcodeCalls.single, testEan13);
        expect(catalog.textCalls.single, labelMarkers.first);
        expect(catalog.textCalls.single, isNot(contains('.jpg')));
      },
    );

    test('BR1.7 the text sent is at most 2000 characters', () async {
      await run(reading(text: 'Barolo ${'x' * 2500}'));
      expect(catalog.textCalls.single.length, LabelReading.maxTextLength);
    });
  });

  group('BR1.11 hard cases', () {
    test('BR1.11 no valid code and fewer than 3 letters: unreadable, no '
        'request', () async {
      final outcome = await run(reading(text: '12 a', codes: ['123']));
      expect(outcome, isA<LookupUnreadable>());
      expect(catalog.calls, 0);
    });

    test('BR1.11 text read and no wine: the form with the line and the '
        'vintage', () async {
      final outcome = await run(reading(text: 'Tenuta Rossi\n2019'));
      final incomplete = outcome as LookupIncomplete;
      expect(incomplete.name, 'Tenuta Rossi');
      expect(incomplete.vintage, 2019);
    });

    test('BR1.11 a barcode with no result and no text: barcode only, with '
        'network', () async {
      final outcome = await run(reading(text: '75', codes: [testEan13]));
      final only = outcome as LookupBarcodeOnly;
      expect(only.barcode, testEan13);
      expect(only.needsNetwork, isFalse);
      expect(catalog.textCalls, isEmpty);
    });

    test(
      'BR1.11 a barcode and no network and no text: needs the network',
      () async {
        final outcome = await run(reading(codes: [testEan13]), online: false);
        expect((outcome as LookupBarcodeOnly).needsNetwork, isTrue);
        expect(catalog.calls, 0);
      },
    );
  });

  group('BR1.8 "Riprova quando torna la rete"', () {
    test('BR1.8 still offline: needs the network, no request', () async {
      final outcome = await flow.retryBarcode(testEan13, online: false);
      expect((outcome as LookupBarcodeOnly).needsNetwork, isTrue);
      expect(catalog.calls, 0);
    });

    test('BR1.8 back online and found: the proposal', () async {
      catalog.byBarcode = candidateOf('Barolo');
      final outcome = await flow.retryBarcode(testEan13, online: true);
      expect((outcome as LookupProposal).candidate.name, 'Barolo');
    });

    test(
      'BR1.8 back online and not found: barcode only with network',
      () async {
        final outcome = await flow.retryBarcode(testEan13, online: true);
        expect((outcome as LookupBarcodeOnly).needsNetwork, isFalse);
      },
    );
  });
}
