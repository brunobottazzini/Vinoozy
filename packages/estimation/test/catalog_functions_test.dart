// Catalog functions of C2 (compatible additions of 2026-11-05 for
// u3-wine-catalog): normalisation, denomination recognition and the
// denomination list.
import 'package:estimation/estimation.dart';
import 'package:estimation/src/catalog.dart' show denominationLabels;
import 'package:estimation/src/recognizer.dart' show tokenize;
import 'package:estimation/src/tables.dart' show denominationTable;
import 'package:test/test.dart';

const _italianRegions = {
  'Abruzzo',
  'Basilicata',
  'Campania',
  'Emilia-Romagna',
  'Lombardia',
  'Marche',
  'Piemonte',
  'Puglia',
  'Sardegna',
  'Sicilia',
  'Toscana',
  'Trentino-Alto Adige',
  'Umbria',
  'Veneto',
};

void main() {
  group('normalizeWineText', () {
    test('lowercases, removes accents and turns punctuation into spaces', () {
      expect(normalizeWineText("  Barbera d'Asti  "), 'barbera d asti');
      expect(
        normalizeWineText('Côtes-du-Rhône, Réserve!'),
        'cotes du rhone reserve',
      );
      expect(normalizeWineText('Nebbiolo...  d’Alba'), 'nebbiolo d alba');
    });

    test('keeps digits and whole texts longer than a wine name', () {
      final long = '${'Vigna ' * 30}Barolo 2016';
      final normalized = normalizeWineText(long);
      expect(normalized.endsWith('barolo 2016'), isTrue);
      expect(normalized.length, greaterThan(150));
      // The name tokenizer of the estimate still stops at 60 characters.
      expect(tokenize(long).join(' ').contains('barolo'), isFalse);
    });

    test('gives an empty string for text without letters or digits', () {
      expect(normalizeWineText(''), '');
      expect(normalizeWineText(" -'. !? "), '');
      expect(normalizeWineText('🍷🍷'), '');
    });
  });

  group('recognizeDenomination', () {
    test('recognises a denomination by whole words with its labels', () {
      final barbera = recognizeDenomination("Barbera d'Asti 2019");
      expect(barbera, isNotNull);
      expect(barbera!.key, 'barberaDAsti');
      expect(barbera.displayName, "Barbera d'Asti DOCG");
      expect(barbera.wineType, WineType.redLight);
      expect(barbera.region, 'Piemonte');
      expect(barbera.qualifier, isNull);
    });

    test('never matches part of a word', () {
      expect(recognizeDenomination('Castiglione Falletto'), isNull);
      expect(recognizeDenomination('Vino rosso della casa'), isNull);
      expect(recognizeDenomination(''), isNull);
    });

    test('prefers the alias with the most words', () {
      expect(recognizeDenomination("Moscato d'Asti")!.key, 'asti');
      expect(
        recognizeDenomination('Vin Santo del Chianti Classico')!.key,
        'vinSanto',
      );
      expect(
        recognizeDenomination('Chianti Classico Riserva')!.key,
        'chiantiClassico',
      );
    });

    test('reports a qualifier with its own offsets', () {
      final barolo = recognizeDenomination('Barolo Riserva Cannubi');
      expect(barolo!.qualifier, Qualifier.riserva);
      // Riserva has no own offsets for Lambrusco: it is ignored.
      expect(recognizeDenomination('Lambrusco Riserva')!.qualifier, isNull);
    });

    test('reads a whole label text, beyond the 60 characters of a name', () {
      final label =
          '${'Imbottigliato all origine dal viticoltore ' * 20}'
          'Denominazione di Origine Controllata e Garantita BAROLO 2015';
      expect(label.length, greaterThan(800));
      final recognized = recognizeDenomination(label);
      expect(recognized?.key, 'barolo');
      expect(recognized?.displayName, 'Barolo DOCG');
    });

    test('value semantics', () {
      final a = recognizeDenomination('Barolo Riserva');
      final b = recognizeDenomination('BAROLO riserva!');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(recognizeDenomination('Barolo')));
      expect(a.toString(), 'RecognizedDenomination(barolo, riserva)');
    });
  });

  group('denominationCatalog', () {
    test('lists every denomination of the table, in table order', () {
      expect(
        denominationCatalog.map((d) => d.key).toList(),
        denominationTable.keys.toList(),
      );
      expect(denominationCatalog, hasLength(47));
      expect(denominationLabels.keys.toSet(), denominationTable.keys.toSet());
    });

    test('every entry has its table aliases, type, a display name and an '
        'Italian region', () {
      final names = <String>{};
      for (final info in denominationCatalog) {
        final row = denominationTable[info.key]!;
        expect(info.aliases, row.aliases, reason: info.key);
        expect(info.wineType, row.wineType, reason: info.key);
        expect(info.displayName, matches(RegExp(r' DOCG?$')), reason: info.key);
        expect(_italianRegions, contains(info.region), reason: info.key);
        expect(names.add(info.displayName), isTrue, reason: 'duplicate name');
        // The display name of a denomination is recognised as itself.
        expect(
          recognizeDenomination(info.displayName)?.key,
          info.key,
          reason: info.displayName,
        );
      }
    });

    test('cannot be modified', () {
      expect(
        () => denominationCatalog.add(denominationCatalog.first),
        throwsUnsupportedError,
      );
      expect(
        () => denominationCatalog.first.aliases.add('x'),
        throwsUnsupportedError,
      );
    });

    test('value semantics of DenominationInfo', () {
      final first = denominationCatalog.first;
      final copy = DenominationInfo(
        key: first.key,
        displayName: first.displayName,
        aliases: [...first.aliases],
        wineType: first.wineType,
        region: first.region,
      );
      expect(copy, first);
      expect(copy.hashCode, first.hashCode);
      expect(copy, isNot(denominationCatalog[1]));
      final otherAliases = DenominationInfo(
        key: first.key,
        displayName: first.displayName,
        aliases: [...first.aliases, 'altro'],
        wineType: first.wineType,
        region: first.region,
      );
      expect(otherAliases, isNot(first));
      final sameLengthOtherAlias = DenominationInfo(
        key: first.key,
        displayName: first.displayName,
        aliases: ['altro'],
        wineType: first.wineType,
        region: first.region,
      );
      expect(sameLengthOtherAlias, isNot(first));
      expect(first.toString(), 'DenominationInfo(barolo)');
    });
  });
}
