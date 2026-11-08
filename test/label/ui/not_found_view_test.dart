// NotFoundView (label-recognition FR3.1, FR4.1, BR3.4, BR5.3, BR1.5): the
// three kinds with their title, the ways out in order with Google Lens
// last, no Lens without the photo, "Retro non leggibile", and the
// accessibility matrix.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/core/label_lookup_flow.dart';
import 'package:vinoozy/label/ui/not_found_view.dart';

import '../../helpers/ui_harness.dart';

void main() {
  final taps = <String>[];

  setUp(taps.clear);

  Widget view(
    NotFoundKind kind, {
    bool photos = true,
    bool backUnreadable = false,
    String readText = 'CHÂTEAU MUSAR',
  }) => Scaffold(
    body: NotFoundView(
      kind: kind,
      readText: readText,
      photosAvailable: photos,
      backUnreadable: backUnreadable,
      onRetry: () => taps.add('retry'),
      onSearchOnline: () => taps.add('search'),
      onWriteByHand: () => taps.add('write'),
      onLens: () => taps.add('lens'),
    ),
  );

  for (final locale in testLocales) {
    testWidgets('BR3.4 the three kinds have their own title '
        '(${locale.toLanguageTag()})', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      for (final (kind, title) in [
        (NotFoundKind.unreadable, l10n.labelUnreadable),
        (NotFoundKind.barcodeNotFound, l10n.labelBarcodeNotFound),
        (NotFoundKind.noMatch, l10n.labelNoMatch),
      ]) {
        await pumpScreen(tester, view(kind), locale: locale);
        expect(find.text(title), findsOneWidget, reason: kind.name);
        expect(find.text(l10n.labelSearchOnline), findsOneWidget);
        expect(find.text(l10n.labelWriteByHand), findsOneWidget);
        expect(find.text(l10n.labelOpenLens), findsOneWidget);
        expect(find.text(l10n.labelLensLastResort), findsOneWidget);
      }
    });
  }

  testWidgets('FR4.1 "Cerca online", "Scrivi a mano", then Google Lens last', (
    tester,
  ) async {
    await pumpScreen(tester, view(NotFoundKind.noMatch));
    double top(String key) => tester.getTopLeft(find.byKey(Key(key))).dy;
    expect(top('label-search-online'), lessThan(top('label-write-by-hand')));
    expect(top('label-write-by-hand'), lessThan(top('label-lens')));
    for (final key in ['search-online', 'write-by-hand', 'lens']) {
      await tester.tap(find.byKey(Key('label-$key')));
    }
    expect(taps, ['search', 'write', 'lens']);
    expect(find.textContaining('CHÂTEAU MUSAR'), findsOneWidget);
    expect(find.byKey(const Key('label-retry')), findsNothing);
  });

  testWidgets('BR1.11 "Riprova" only when nothing was read', (tester) async {
    await pumpScreen(tester, view(NotFoundKind.unreadable));
    await tester.tap(find.byKey(const Key('label-retry')));
    expect(taps, ['retry']);
  });

  testWidgets('BR5.3 without the photo there is no Google Lens', (
    tester,
  ) async {
    await pumpScreen(tester, view(NotFoundKind.noMatch, photos: false));
    expect(find.byKey(const Key('label-lens')), findsNothing);
    expect(find.byKey(const Key('label-search-online')), findsOneWidget);
    expect(find.byKey(const Key('label-write-by-hand')), findsOneWidget);
  });

  testWidgets('BR1.5 "Retro non leggibile" on top when the back failed', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('it'));
    await pumpScreen(tester, view(NotFoundKind.noMatch, backUnreadable: true));
    expect(find.text(l10n.labelBackUnreadable), findsOneWidget);
  });

  for (final kind in NotFoundKind.values) {
    accessibilityMatrix(
      'NotFoundView ${kind.name} with the back unreadable',
      () => view(kind, backUnreadable: true),
    );
  }
}
