// WineDbIndex (label-recognition BR2.5, BR3.2, BR3.6, FR2.3): exact barcode,
// candidates by text with the 0.45 floor and at most 10, best first, and the
// "Cerca online" search of the offline wines.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/offline/text_score.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_index.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';

const _ravera = WineDbRecord(
  code: '8001234567897',
  name: 'Barolo Ravera',
  producer: 'Elvio Cogno',
  denomination: 'Barolo DOCG',
  vintage: 2016,
);
const _cannubi = WineDbRecord(
  code: '8001234567880',
  name: 'Barolo Cannubi',
  producer: 'Cantina Esempio',
);
const _musar = WineDbRecord(
  code: '96385074',
  name: 'Château Musar Rouge',
  producer: 'Château Musar',
  country: 'LB',
);

void main() {
  final index = WineDbIndex.build(const [_ravera, _cannubi, _musar]);

  group('FR2.3 barcode', () {
    test('FR2.3 a present code is found exactly, an absent one is null', () {
      expect(index.byBarcode('8001234567897'), _ravera);
      expect(index.byBarcode('96385074'), _musar);
      expect(index.byBarcode('8001234567873'), isNull);
    });

    test('BR2.4 the first record of a duplicated code wins', () {
      final dup = WineDbIndex.build(const [
        _ravera,
        WineDbRecord(code: '8001234567897', name: 'Other wine'),
      ]);
      expect(dup.length, 1);
      expect(dup.byBarcode('8001234567897')?.name, 'Barolo Ravera');
    });
  });

  group('BR3.6 text', () {
    test('FR2.3 a label text recognises its wine, best first', () {
      final found = index.matchText(
        'ELVIO COGNO\nBAROLO\nDenominazione di Origine Controllata e '
        'Garantita\nRAVERA 2016',
      );
      expect(found.first.record, _ravera);
      expect(found.first.score, 1.0);
      expect(found.first.match.matchedWords, greaterThanOrEqualTo(2));
    });

    test('BR3.2 candidates under 0.45 are not returned', () {
      // "barolo" is 6 of the 6+7+6+7 letters of Barolo Cannubi Cantina
      // Esempio... the producer words make it weak.
      final found = index.matchText('Barolo');
      expect(
        found.every((s) => s.score >= LabelMatchThresholds.candidate),
        isTrue,
      );
      expect(found.map((s) => s.record), isNot(contains(_musar)));
    });

    test('BR3.2 at most 10 candidates, ordered by score then name', () {
      final many = WineDbIndex.build([
        for (var i = 0; i < 15; i++)
          WineDbRecord(
            code: (10000000 + i).toString(),
            name: 'Nebbiolo Vigna${String.fromCharCode(0x61 + i)}',
          ),
      ]);
      final found = many.matchText('Nebbiolo');
      expect(found, hasLength(10));
      final names = [for (final s in found) s.record.name];
      expect(names, [...names]..sort());
    });

    test('an empty text or no shared word gives no candidate', () {
      expect(index.matchText(''), isEmpty);
      expect(index.matchText('Marmellata di fragole'), isEmpty);
    });

    test('an empty database answers nothing', () {
      final empty = WineDbIndex.build(const []);
      expect(empty.length, 0);
      expect(empty.byBarcode('96385074'), isNull);
      expect(empty.matchText('Barolo Ravera'), isEmpty);
      expect(empty.search('barolo'), isEmpty);
    });
  });

  group('BR4.2 search', () {
    test('BR4.2 every query word must start a word of the wine', () {
      final found = index.search('barolo rav');
      expect([for (final s in found) s.record], [_ravera]);
      final both = index.search('Barolo');
      expect(both.map((s) => s.record), containsAll([_ravera, _cannubi]));
    });

    test('BR4.2 common words alone find nothing', () {
      expect(index.search('vino rosso'), isEmpty);
      expect(index.search('Château Musar 2015').single.record, _musar);
    });
  });

  test('OfflineWineDb.fromLines counts loaded and dropped lines', () {
    final db = OfflineWineDb.fromLines(
      WineDbManifest(exportDate: DateTime.utc(2026, 11, 7), wineCount: 2),
      [_ravera.toJsonLine(), '{broken', _musar.toJsonLine()],
    );
    expect(db.wineCount, 2);
    expect(db.skippedRows, 1);
    expect(db.index.byBarcode('96385074'), _musar);
  });
}
