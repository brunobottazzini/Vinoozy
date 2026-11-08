// The text flows with the analysis of the guided check (label-autofill-
// windows D9, BR7.8, BR7.10, NFR4.21): what the form fills, when the photo
// opens the form, a reader failure reported once.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/label/core/label_lookup_flow.dart';
import 'package:vinoozy/label/core/label_merge.dart';
import 'package:vinoozy/label/core/text_autofill.dart';

import '../label_harness.dart';

void main() {
  late LabelCatalog catalog;
  late List<Object> failures;

  setUp(() {
    catalog = LabelCatalog();
    failures = [];
  });

  TextAutofillFlow flow({int Function()? year}) => TextAutofillFlow(
    catalog: catalog,
    currentYear: year ?? () => 2026,
    onExtractFailure: (error, _) => failures.add(error),
  );

  group('TextFields with the analysis (D9)', () {
    test('a short text fills as today, with no question', () async {
      final result = await flow().run(
        'Barolo Vietti\n2019',
        locale: CatalogLocale.it,
      ) as TextFields;
      expect(result.analysis.uncertainFields, isEmpty);
      final filled = result.filled;
      expect(filled.name, 'Barolo Vietti');
      expect(filled.denomination, 'Barolo DOCG');
      expect(filled.vintage, 2019);
      expect(filled.sourceKeys, result.fields.sourceKeys);
    });

    test('IT01: the form fills only the certain fields; the reader of BR1 '
        'stays as it is', () async {
      final result = await flow().run(
        "CASCINA CASTLET\nBarbera d'Asti Superiore\n14,5% vol  75 cl\n"
        '2019',
        locale: CatalogLocale.it,
      ) as TextFields;
      expect(result.fields.name, isNotNull);
      expect(result.filled.name, isNull);
      expect(result.filled.producer, isNull);
      expect(result.filled.denomination, "Barbera d'Asti DOCG");
      expect(result.analysis.uncertainFields, [
        KeyField.producer,
        KeyField.name,
      ]);
    });

    test(
      'the type is never read from an uncertain denomination (BR7.8 b)',
      () async {
        final result = await flow().run(
          'FINCA LOS OLIVOS\nVino Tinto\nRibera del Guadiana\n2021',
          locale: CatalogLocale.it,
        ) as TextFields;
        expect(result.filled.wineType, isNull);
        expect(result.filled.denomination, isNull);
      },
    );

    test('without an analysis the fields of BR1 are filled', () {
      const fields = LabelFields(name: 'Barolo');
      expect(const TextFields(fields).filled, same(fields));
      expect(const TextFields(fields).analysis, same(LabelAnalysis.empty));
    });

    test('a failure of the reader: empty analysis, reported once', () async {
      final result = await flow(
        year: () => throw StateError('clock'),
      ).run('Barolo 2016', locale: CatalogLocale.it) as TextFields;
      expect(result.analysis, same(LabelAnalysis.empty));
      expect(failures, hasLength(1));
    });

    test('a failure of the analysis alone is reported and gives no '
        'analysis', () async {
      var calls = 0;
      final result = await flow(
        year: () => ++calls > 1 ? throw StateError('x') : 2026,
      ).run('Barolo 2016', locale: CatalogLocale.it) as TextFields;
      expect(result.fields.denomination, 'Barolo DOCG');
      expect(result.analysis, same(LabelAnalysis.empty));
      expect(failures.single, isA<StateError>());
    });
  });

  group('the photo opens the form (BR2.1, BR7.10)', () {
    Future<LookupNotFound> read(String text) async =>
        await LabelLookupFlow(catalog: catalog, currentYear: () => 2026).run(
          MergedReading(text: text),
          locale: CatalogLocale.it,
        ) as LookupNotFound;

    test('a certain field or a question opens it, with the analysis', () async {
      final certain = await read('Cantina del Lago');
      expect(certain.opensForm, isTrue);
      expect(certain.analysis.certainFields.producer, 'Cantina del Lago');
      final question = await read(
        'FINCA LOS OLIVOS\nVino Tinto\nRibera del Guadiana\nRiserva',
      );
      expect(question.analysis.certainFields.denomination, isNull);
      expect(question.opensForm, isTrue);
    });

    test('noise only: "Not found"', () async {
      final noise = await read('750 ml\n13% vol\nwww.example.com');
      expect(noise.opensForm, isFalse);
    });

    test('without an analysis the fields of BR1 decide', () {
      expect(
        const LookupNotFound(
          NotFoundKind.noMatch,
          fields: LabelFields(producer: 'X'),
        ).opensForm,
        isTrue,
      );
      expect(const LookupNotFound(NotFoundKind.noMatch).opensForm, isFalse);
    });
  });
}
