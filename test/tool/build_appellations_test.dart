// tool/build_appellations.dart (label-autofill-windows BR3.6, BR3.7, NFR4.5,
// NFR4.12, NFR4.13) on the sample of tool/fixtures/ and the CSVs of
// tool/data/appellations/: never the real eAmbrosia register, never the
// network.
import 'dart:convert';
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/build_appellations.dart';

const _sample = 'tool/fixtures/eambrosia_sample.csv';
const _data = 'tool/data/appellations';

/// A few GIs in the shape of the eAmbrosia API export: a registered wine, a
/// Greek and a Bulgarian name with their transcription, a GI of two
/// countries, a PGI, and rows the reader skips (a spirit, an application,
/// a removed wine, a TSG, a name with no Latin form). The producer group
/// fields are there and must never be read.
const String _jsonExport = '''
[
  {"protectedNames": ["Barolo"], "countries": ["IT"], "giType": "PDO",
   "productType": "WINE", "status": "registered", "removedFlag": false,
   "producerGroupEmail": "someone@example.org"},
  {"protectedNames": ["Τριφυλία"], "transcriptions": ["Trifilia"],
   "countries": ["GR"], "giType": "PDO", "productType": "WINE",
   "status": "registered"},
  {"protectedNames": ["Мелник"], "transcriptions": ["Melnik"],
   "countries": ["BG"], "giType": "PDO", "productType": "WINE",
   "status": "registered"},
  {"protectedNames": ["Maasvallei Limburg"], "countries": ["BE", "NL"],
   "giType": "PDO", "productType": "WINE", "status": "registered"},
  {"protectedNames": ["Toscana"], "countries": ["IT"], "giType": "PGI",
   "productType": "WINE", "status": "registered"},
  {"protectedNames": ["Grappa"], "countries": ["IT"], "giType": "GI",
   "productType": "SPIRIT", "status": "registered"},
  {"protectedNames": ["Colline del Sale"], "countries": ["IT"],
   "giType": "PDO", "productType": "WINE", "status": "applied"},
  {"protectedNames": ["Terre di Chieti"], "countries": ["IT"],
   "giType": "PGI", "productType": "WINE", "status": "registered",
   "removedFlag": true},
  {"protectedNames": ["Vin X"], "countries": ["FR"], "giType": "TSG",
   "productType": "WINE", "status": "registered"},
  {"protectedNames": ["沙城葡萄酒"], "countries": ["CN"], "giType": "PGI",
   "productType": "WINE", "status": "registered"}
]
''';

void main() {
  late Directory temp;

  setUp(
    () => temp = Directory.systemTemp.createTempSync('vinoozy_appellations'),
  );
  tearDown(() => temp.deleteSync(recursive: true));

  String outputPath() => '${temp.path}/appellations.g.dart';
  String manifestPath() => '${temp.path}/manifest.json';

  Future<(int, String, String)> run(
    List<String> extra, {
    String? input,
    String? data,
  }) async {
    final out = StringBuffer();
    final err = StringBuffer();
    final code = await runBuildAppellations(
      [
        '--eambrosia',
        input ?? _sample,
        '--data',
        data ?? _data,
        '--output',
        outputPath(),
        '--manifest',
        manifestPath(),
        '--export-date',
        '2026-11-08',
        ...extra,
      ],
      out: out,
      err: err,
    );
    return (code, out.toString(), err.toString());
  }

  List<RegisterRow> sampleRows() => [
    ...readEAmbrosia(File(_sample).readAsStringSync()),
    // As the tool: the CSV files only, never the README of the folder.
    for (final file
        in Directory(_data)
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.csv'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path)))
      ...readNonEuCsv(file.readAsStringSync()),
  ];

  group('BR3.6 reading the registers', () {
    test('eAmbrosia JSON: only registered wines not removed, names in '
        'Latin letters, the first country', () {
      final rows = readEAmbrosiaJson(_jsonExport);
      expect(rows.map((r) => r.name), [
        'Barolo',
        'Trifilia',
        'Melnik',
        'Maasvallei Limburg',
        'Toscana',
      ]);
      expect(rows[1].country, 'GR');
      expect(rows[1].aliases, ['Τριφυλία']);
      expect(rows[2].aliases, ['Мелник']);
      expect(rows[3].country, 'BE');
      expect(rows[4].protection, 'PGI');
      expect(rows.first.aliases, isEmpty);
    });

    test('eAmbrosia JSON: not a list, or broken, is refused', () {
      expect(() => readEAmbrosiaJson('{"a": 1}'), throwsFormatException);
      expect(() => readEAmbrosiaJson('[{"a": '), throwsFormatException);
      expect(readEAmbrosiaJson('[1, "x", {}]'), isEmpty);
    });

    test('an export is read as JSON when it starts with "[", else as CSV', () {
      expect(readEAmbrosiaExport('  $_jsonExport'), hasLength(5));
      expect(
        readEAmbrosiaExport(File(_sample).readAsStringSync()),
        hasLength(readEAmbrosia(File(_sample).readAsStringSync()).length),
      );
    });

    test('eAmbrosia: only registered wine rows, aliases from " / "', () {
      final rows = readEAmbrosia(File(_sample).readAsStringSync());
      expect(rows.map((r) => r.name), isNot(contains('Grappa')));
      expect(rows.map((r) => r.name), isNot(contains('Parmigiano Reggiano')));
      expect(rows.map((r) => r.name), isNot(contains('Colline del Sale')));
      final altoAdige = rows.firstWhere((r) => r.name == 'Alto Adige');
      expect(altoAdige.aliases, ['Südtirol']);
      expect(altoAdige.country, 'IT');
      expect(rows.firstWhere((r) => r.name == 'Toscana').protection, 'PGI');
    });

    test('eAmbrosia: ";" separator, country names, PDO/PGI spellings', () {
      final rows = readEAmbrosia(
        'Name;Country;Type;Category;Status\n'
        'Mosel;Germany;DOP;Wine;Registered\n'
        'Vin X;Narnia;PDO;Wine;Registered\n'
        'Vin Y;FR;TSG;Wine;Registered\n',
      );
      expect(rows, hasLength(1));
      expect(rows.single.country, 'DE');
      expect(rows.single.protection, 'PDO');
    });

    test('an export without the needed columns is refused', () {
      expect(() => readEAmbrosia('Foo,Bar\n1,2\n'), throwsFormatException);
      expect(() => readEAmbrosia('# only comments\n'), throwsFormatException);
    });

    test('non-EU CSV: types, region and weak words', () {
      final rows = readNonEuCsv(
        '# source\nname,country,region,types,weak\n'
        'Edna Valley,US,California,rL|B,\n'
        'Augusta,US,,,weak\n',
      );
      expect(rows.first.types, [WineType.redLight, WineType.white]);
      expect(rows.first.region, 'California');
      expect(rows.last.weak, isTrue);
      expect(() => readNonEuCsv('a,b\nc,d\n'), throwsFormatException);
      expect(readNonEuCsv('# nothing\n'), isEmpty);
    });

    test('every data file has its source, date, licence and the note to '
        'verify it in Build and Test', () {
      // Only the CSV files: the tool reads only those, the folder also
      // holds its README.
      for (final file in [
        File(_sample),
        ...Directory(_data)
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.csv')),
      ]) {
        final head = file.readAsStringSync();
        expect(head, contains('Source'), reason: file.path);
        expect(head, contains('Date: 2026-11-08'), reason: file.path);
        expect(head.toLowerCase(), contains('licence'), reason: file.path);
        // The hand-written sample stays a sample; the files of the folder
        // were checked against the official lists in Build and Test.
        expect(
          head,
          contains(
            file.path == _sample
                ? 'To verify against the official list in Build and Test'
                : 'Verified against the official list',
          ),
          reason: file.path,
        );
      }
    });
  });

  group('BR3.6 and BR3.7 the generated rows', () {
    test('dedicated rows and grapes win: their names are left out', () {
      final build = buildAppellations(sampleRows(), allowSample: true);
      final names = [for (final row in build.rows) row.split('|')[1]];
      expect(names, isNot(contains('Barolo')));
      expect(names, isNot(contains('Saint-Émilion grand cru')));
      expect(names, isNot(contains('Lambrusco di Sorbara')));
      expect(names, contains('Toscana'));
      expect(build.leftOut, greaterThan(0));
    });

    test('each row has a model of its country and protection level', () {
      expect(templateOf('IT', 'PDO'), TemplateKeys.italyDoc);
      expect(templateOf('IT', 'PGI'), TemplateKeys.italyIgt);
      expect(templateOf('FR', 'PGI'), TemplateKeys.franceIgp);
      expect(templateOf('PT', 'PDO'), TemplateKeys.iberia);
      expect(templateOf('AT', 'PGI'), TemplateKeys.germanAustrian);
      expect(templateOf('CH', 'PDO'), TemplateKeys.switzerland);
      expect(templateOf('ZA', 'PDO'), TemplateKeys.newWorld);
      expect(templateOf('RO', 'PDO'), TemplateKeys.otherEu);
      final build = buildAppellations(sampleRows(), allowSample: true);
      for (final raw in build.rows) {
        final row = parseGeneratedRow(raw)!;
        expect(appellationTemplates, contains(row.templateKey));
      }
    });

    test('the words of a name choose the types, else light red, white, '
        'rosé', () {
      expect(typesFromName('Asti Spumante'), [WineType.sparklingTank]);
      expect(typesFromName('Crémant de Savoie'), [WineType.sparklingClassic]);
      expect(typesFromName('Vin Santo di Montepulciano'), [WineType.sweet]);
      expect(typesFromName('Marsala Superiore'), [WineType.fortified]);
      expect(typesFromName('Rosso Piceno'), [WineType.redLight]);
      expect(typesFromName('Bianco di Pitigliano'), [WineType.white]);
      expect(typesFromName('Chiaretto'), [WineType.rose]);
      expect(typesFromName('Langhe'), isEmpty);
    });

    test('a row whose types its model lacks is dropped and counted '
        '(NFR4.13)', () {
      final build = buildAppellations([
        const RegisterRow(
          name: 'Vin Doux Naturel du Nord',
          country: 'CH',
          protection: 'PDO',
        ),
      ], allowSample: true);
      expect(build.rows, isEmpty);
      expect(build.dropped, 1);
    });

    test('regions: only regions of WineOrigins, from the file or the name', () {
      final build = buildAppellations([
        const RegisterRow(name: 'Toscana', country: 'IT', protection: 'PGI'),
        const RegisterRow(
          name: 'Zona Nuova',
          country: 'US',
          protection: 'PDO',
          region: 'Napa Valley',
        ),
      ], allowSample: true);
      expect(build.ok, isTrue);
      expect(build.rows.first.split('|')[3], 'Toscana');
      expect(build.rows.last.split('|')[3], 'Napa Valley');
      final bad = buildAppellations([
        const RegisterRow(
          name: 'Zona Nuova',
          country: 'US',
          protection: 'PDO',
          region: 'Atlantis',
        ),
      ], allowSample: true);
      expect(bad.ok, isFalse);
      expect(bad.failures.single.message, contains('Atlantis'));
    });

    test('region and country names and common words are weak (BR1.2)', () {
      final build = buildAppellations([
        const RegisterRow(name: 'Toscana', country: 'IT', protection: 'PGI'),
        const RegisterRow(name: 'Terre', country: 'IT', protection: 'PGI'),
        const RegisterRow(
          name: 'Ozark Mountain',
          country: 'US',
          protection: 'PDO',
        ),
        const RegisterRow(name: 'English', country: 'GB', protection: 'PDO'),
        const RegisterRow(name: 'Drama', country: 'GR', protection: 'PGI'),
      ], allowSample: true);
      final weak = {
        for (final raw in build.rows) raw.split('|')[1]: raw.split('|')[7],
      };
      expect(weak['Toscana'], 'toscana');
      expect(weak['Terre'], 'terre');
      expect(weak['Ozark Mountain'], isEmpty);
      expect(weak['English'], 'english');
      expect(weak['Drama'], 'drama');
    });

    test('a name inside a grape name, or a GI whose other name is '
        'dedicated, is left out (BR3.2)', () {
      final build = buildAppellations([
        const RegisterRow(name: 'Avola', country: 'IT', protection: 'PDO'),
        const RegisterRow(
          name: 'Vin Imaginaire',
          country: 'FR',
          protection: 'PDO',
          aliases: ['Barolo'],
        ),
        const RegisterRow(name: 'Gabiano', country: 'IT', protection: 'PDO'),
      ], allowSample: true);
      expect([for (final raw in build.rows) raw.split('|')[1]], ['Gabiano']);
      expect(build.leftOut, 2);
    });

    test('a region of the app among the names is the display name', () {
      final build = buildAppellations([
        const RegisterRow(
          name: 'Toscano',
          country: 'IT',
          protection: 'PGI',
          aliases: ['Toscana'],
        ),
      ], allowSample: true);
      final fields = build.rows.single.split('|');
      expect(fields[1], 'Toscana');
      expect(fields[6], 'toscano');
    });

    test('a register row repeated is written once', () {
      final build = buildAppellations([
        const RegisterRow(name: 'Gabiano', country: 'IT', protection: 'PDO'),
        const RegisterRow(name: 'Gabiano', country: 'IT', protection: 'PDO'),
      ], allowSample: true);
      expect(build.rows, hasLength(1));
      expect(build.leftOut, 1);
    });
  });

  group('NFR4.12 checks', () {
    test('fewer than 1500 appellations without --allow-sample: nothing '
        'written, exit 1', () async {
      // The sample with one small register file: well under the floor (the
      // sample with all the verified national files is already above it).
      final data = Directory('${temp.path}/data')..createSync();
      File('${data.path}/x.csv').writeAsStringSync(
        '# source\nname,country,region,types,weak\nKumeu,NZ,,,\n',
      );
      final (code, _, err) = await run(const [], data: data.path);
      expect(code, 1);
      expect(err, contains('at least 1500'));
      expect(File(outputPath()).existsSync(), isFalse);
      expect(File(manifestPath()).existsSync(), isFalse);
    });

    test('a bad region stops the build, nothing written', () async {
      final input = File('${temp.path}/bad.csv')
        ..writeAsStringSync(
          'Name,Country,GI type,Product category,Status\n'
          'Toscana,IT,PGI,Wine,Registered\n',
        );
      final data = Directory('${temp.path}/data')..createSync();
      File('${data.path}/x.csv').writeAsStringSync(
        'name,country,region,types,weak\nZona,US,Atlantis,,\n',
      );
      final err = StringBuffer();
      final code = await runBuildAppellations([
        '--eambrosia',
        input.path,
        '--data',
        data.path,
        '--output',
        outputPath(),
        '--manifest',
        manifestPath(),
        '--allow-sample',
      ], err: err);
      expect(code, 1);
      expect(err.toString(), contains('Atlantis'));
      expect(File(outputPath()).existsSync(), isFalse);
    });

    test('usage and missing inputs exit 2', () async {
      expect(await runBuildAppellations(const [], err: StringBuffer()), 2);
      expect(
        await runBuildAppellations(const ['--nope'], err: StringBuffer()),
        2,
      );
      expect(
        await runBuildAppellations(const [
          '--eambrosia',
          'x.csv',
          '--export-date',
          '8 Nov',
        ], err: StringBuffer()),
        2,
      );
      final (code, _, _) = await run(
        const [],
        input: 'tool/fixtures/missing.csv',
      );
      expect(code, 2);
    });

    test('an unreadable export exits 2', () async {
      final input = File('${temp.path}/broken.csv')..writeAsStringSync('a,b\n');
      final (code, _, err) = await run(const [], input: input.path);
      expect(code, 2);
      expect(err, contains('unreadable'));
    });
  });

  group('--allow-sample and NFR4.5 stable output', () {
    test('the sample builds, writes source "sample" in the manifest', () async {
      final (code, out, _) = await run(const ['--allow-sample']);
      expect(code, 0);
      expect(out, contains('OK'));
      final manifest = jsonDecode(
        File(manifestPath()).readAsStringSync(),
      ) as Map<String, Object?>;
      expect(manifest['source'], sampleSource);
      expect(manifest['exportDate'], '2026-11-08');
      expect(manifest['appellationCount'], greaterThan(1000));
      final source = File(outputPath()).readAsStringSync();
      expect(source, contains("generatedAppellationsSource = 'sample'"));
    });

    test('two builds from the same inputs give the same file', () async {
      await run(const ['--allow-sample']);
      final first = File(outputPath()).readAsStringSync();
      await run(const ['--allow-sample']);
      expect(File(outputPath()).readAsStringSync(), first);
    });

    test('the file in the package is a build from the registers that its '
        'manifest describes', () {
      final manifest = jsonDecode(
        File(defaultManifest).readAsStringSync(),
      ) as Map<String, Object?>;
      expect(manifest['source'], registerSource);
      expect(manifest['appellationCount'], greaterThanOrEqualTo(1500));
      expect(appellationsSource, manifest['source']);
      final dedicated = appellations.where((info) => info.dedicated).length;
      expect(manifest['dedicatedRows'], dedicated);
      expect(
        appellations.length - dedicated,
        manifest['generatedRows'],
        reason: 'every generated row of the file is in the table',
      );
      expect(
        manifest['appellationCount'],
        appellations.length,
        reason: 'the manifest counts the table the app uses',
      );
    });

    test('a JSON export builds like a CSV one', () async {
      final input = File('${temp.path}/export.json')
        ..writeAsStringSync(_jsonExport);
      final (code, out, _) = await run(const [
        '--allow-sample',
      ], input: input.path);
      expect(code, 0, reason: out);
      expect(File(outputPath()).readAsStringSync(), contains('trifiliaGR'));
    });

    test('a long source is split after "=" as dart format does', () {
      const empty = AppellationBuild(
        rows: [],
        failures: [],
        dedicated: 0,
        read: 0,
        leftOut: 0,
        dropped: 0,
      );
      expect(
        renderGeneratedFile(empty, source: registerSource),
        contains(
          'generatedAppellationsSource =\n'
          "    'eAmbrosia and official national registers';",
        ),
      );
      expect(
        renderGeneratedFile(empty, source: sampleSource),
        contains("generatedAppellationsSource = 'sample';"),
      );
    });

    test('rows are sorted by country, the file is at most 1 MB (NFR1.6)', () {
      final build = buildAppellations(sampleRows(), allowSample: true);
      final countries = [for (final row in build.rows) row.split('|')[2]];
      expect(countries, [...countries]..sort());
      final rendered = renderGeneratedFile(build, source: sampleSource);
      expect(utf8.encode(rendered).length, lessThan(1024 * 1024));
      expect(build.total, build.dedicated + build.rows.length);
    });

    test('a real build is "eAmbrosia and official national registers"', () {
      final empty = renderGeneratedFile(
        const AppellationBuild(
          rows: [],
          failures: [],
          dedicated: 0,
          read: 0,
          leftOut: 0,
          dropped: 0,
        ),
        source: registerSource,
      );
      expect(empty, contains('generatedAppellationRows = [];'));
      expect(empty, contains(registerSource));
    });

    test("quotes and dollars in a name are escaped", () {
      final build = buildAppellations([
        const RegisterRow(
          name: "Cacc'e mmitte",
          country: 'IT',
          protection: 'PDO',
        ),
      ], allowSample: true);
      final rendered = renderGeneratedFile(build, source: sampleSource);
      expect(rendered, contains(r"Cacc\'e mmitte"));
    });
  });

  test('splitCsvLine reads quotes and escaped quotes', () {
    expect(splitCsvLine('a,"b, c","d ""e"""', ','), ['a', 'b, c', 'd "e"']);
  });
}
