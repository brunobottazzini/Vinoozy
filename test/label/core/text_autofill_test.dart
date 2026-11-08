// The text flows of label-autofill-windows: a pasted or shared text through
// the catalog and then the label fields (BR2.2, BR2.3, NFR3.4, NFR3.7), and
// the label photo that opens the form filled (BR2.1, F1).
import 'dart:async';

import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/label/core/label_lookup_flow.dart';
import 'package:vinoozy/label/core/label_merge.dart';
import 'package:vinoozy/label/core/text_autofill.dart';

import '../label_harness.dart';

void main() {
  late LabelCatalog catalog;
  late List<Object> lookupFailures;
  late List<Object> extractFailures;

  setUp(() {
    catalog = LabelCatalog();
    lookupFailures = [];
    extractFailures = [];
  });

  TextAutofillFlow flow({int Function()? year, Duration? budget}) =>
      TextAutofillFlow(
        catalog: catalog,
        currentYear: year ?? () => 2026,
        onLookupFailure: (error, _) => lookupFailures.add(error),
        onExtractFailure: (error, _) => extractFailures.add(error),
        lookupBudget: budget ?? TextAutofillFlow.defaultLookupBudget,
      );

  group('BR2.2 TextAutofillFlow', () {
    test('a sure wine of the catalog comes first (FR2.5)', () async {
      catalog.byLabel = sureMatch(candidateOf('Barolo Ravera'));
      final result = await flow().run(
        'Barolo\nRavera\n2016',
        locale: CatalogLocale.it,
      );
      expect((result as TextSureMatch).candidate.name, 'Barolo Ravera');
      expect(catalog.textLocales, [CatalogLocale.it]);
    });

    test('otherwise the label fields of the text', () async {
      catalog.byLabel = candidatesMatch([candidateOf('Barolo')]);
      final result = await flow().run(
        "CHÂTEAU MEYNEY\nSAINT-ESTÈPHE\n2016\nAppellation Saint-Estèphe "
        'Contrôlée',
        locale: CatalogLocale.it,
      );
      final fields = (result as TextFields).fields;
      expect(fields.name, 'Château Meyney');
      expect(fields.denomination, 'Saint-Estèphe');
      expect(fields.vintage, 2016);
    });

    test('NFR3.7 a text with no field gives empty fields', () async {
      final result = await flow().run(
        'Contiene solfiti 750 ml',
        locale: CatalogLocale.it,
      );
      expect((result as TextFields).fields.isEmpty, isTrue);
    });

    test('a blank text never reaches the catalog', () async {
      final result = await flow().run(' \n\t ', locale: CatalogLocale.it);
      expect((result as TextFields).fields.isEmpty, isTrue);
      expect(catalog.textCalls, isEmpty);
    });

    test(
      'BR2.3 NFR3.4 the catalog receives the text cut and cleaned',
      () async {
        await flow().run(
          'Barolo\u0000​ ${'x' * 5000}',
          locale: CatalogLocale.it,
        );
        final sent = catalog.textCalls.single;
        expect(sent.length, lessThanOrEqualTo(maxLabelTextLength));
        expect(sent, isNot(contains('\u0000')));
        expect(sent, isNot(contains('​')));
      },
    );

    test(
      'a catalog error is "nothing found", reported without the text',
      () async {
        catalog.textError = StateError('offline database broken');
        final result = await flow().run(
          'Barolo 2016',
          locale: CatalogLocale.it,
        );
        expect((result as TextFields).fields.denomination, 'Barolo DOCG');
        expect(lookupFailures.single, isA<StateError>());
        catalog.textError = CatalogArgumentError(CatalogErrorCode.textTooLong);
        await flow().run('Barolo 2016', locale: CatalogLocale.it);
        expect(lookupFailures, hasLength(1));
      },
    );

    test('a failure of the reader gives no field and is reported', () async {
      final result = await flow(year: () => throw StateError('clock'))
          .run('Barolo 2016', locale: CatalogLocale.it);
      expect((result as TextFields).fields.isEmpty, isTrue);
      expect(extractFailures.single, isA<StateError>());
    });
  });

  group('a paste always answers: the catalog lookup is bounded', () {
    const lensText =
        "CASCINA CASTLET\nBarbera d'Asti\nDenominazione di Origine "
        'Controllata e Garantita\n2019\n14% vol\n75 cl';

    test('the default budget stays under the 2 s the person waits', () {
      expect(
        TextAutofillFlow.defaultLookupBudget,
        lessThan(const Duration(seconds: 2)),
      );
      expect(flow().lookupBudget, TextAutofillFlow.defaultLookupBudget);
    });

    test('a catalog that never answers: the fields of the text at the '
        'budget, nothing reported', () async {
      catalog.labelGate = Completer<void>();
      final watch = Stopwatch()..start();
      final result = await flow(budget: const Duration(milliseconds: 50))
          .run(lensText, locale: CatalogLocale.it);
      expect(watch.elapsed, greaterThanOrEqualTo(_ms(50)));
      expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
      final fields = (result as TextFields).fields;
      expect(fields.name, isNotNull);
      expect(fields.denomination, "Barbera d'Asti DOCG");
      expect(fields.vintage, 2019);
      expect(lookupFailures, isEmpty);
    });

    test('a sure wine found within the budget is still proposed', () async {
      final gate = Completer<void>();
      catalog
        ..labelGate = gate
        ..byLabel = sureMatch(candidateOf("Barbera d'Asti"));
      final pending = flow(budget: const Duration(seconds: 5))
          .run(lensText, locale: CatalogLocale.it);
      await Future<void>.delayed(_ms(20));
      gate.complete();
      final result = await pending;
      expect((result as TextSureMatch).candidate.name, "Barbera d'Asti");
    });

    test('a lookup failing after the budget is reported and never '
        'thrown', () async {
      final gate = Completer<void>();
      catalog
        ..labelGate = gate
        ..textError = StateError('late failure');
      final result = await flow(budget: const Duration(milliseconds: 10))
          .run(lensText, locale: CatalogLocale.it);
      expect(result, isA<TextFields>());
      expect(lookupFailures, isEmpty);
      gate.complete();
      await Future<void>.delayed(Duration.zero);
      expect(lookupFailures.single, isA<StateError>());
    });
  });

  group('BR2.1 the label photo carries the fields of its text', () {
    test('a text with fields: LookupNotFound has them', () async {
      final lookup = LabelLookupFlow(catalog: catalog, currentYear: () => 2026);
      final outcome = await lookup.run(
        const MergedReading(text: 'Rioja\nDenominación de Origen\n2015'),
        locale: CatalogLocale.it,
      );
      final fields = (outcome as LookupNotFound).fields;
      expect(fields.denomination, 'Rioja');
      expect(fields.vintage, 2015);
      expect(fields.isEmpty, isFalse);
    });

    test('an unreadable photo has none', () async {
      final lookup = LabelLookupFlow(catalog: catalog, currentYear: () => 2026);
      final outcome = await lookup.run(
        const MergedReading(text: '12'),
        locale: CatalogLocale.it,
      );
      expect((outcome as LookupNotFound).fields.isEmpty, isTrue);
    });

    test('a failure of the reader is reported apart and gives none', () async {
      final failures = <Object>[];
      final lookup = LabelLookupFlow(
        catalog: catalog,
        currentYear: () => 2026,
        onExtractFailure: (error, _) => failures.add(error),
      );
      // The year is read once by the vintage, then by the reader.
      var calls = 0;
      final failing = LabelLookupFlow(
        catalog: catalog,
        currentYear: () => ++calls > 1 ? throw StateError('x') : 2026,
        onExtractFailure: (error, _) => failures.add(error),
      );
      expect(
        ((await lookup.run(
          const MergedReading(text: 'Barolo 2016'),
          locale: CatalogLocale.it,
        )) as LookupNotFound).fields.denomination,
        'Barolo DOCG',
      );
      final outcome = await failing.run(
        const MergedReading(text: 'Barolo 2016'),
        locale: CatalogLocale.it,
      );
      expect((outcome as LookupNotFound).fields.isEmpty, isTrue);
      expect(failures.single, isA<StateError>());
    });
  });
}

Duration _ms(int value) => Duration(milliseconds: value);
