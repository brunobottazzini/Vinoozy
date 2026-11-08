// CandidateList (label-recognition FR3.2, BR3.2, BR6.2, L4, L8): chips in
// words, the flag read as the country name, the attribution only with
// offline or Open Food Facts data, at most 10, and the accessibility
// matrix.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/ui/candidate_list.dart';

import '../../helpers/ui_harness.dart';

const _offline = WineCandidate(
  name: 'Barbaresco DOCG 2019',
  producer: 'Produttori del Barbaresco',
  vintage: 2019,
  wineType: CatalogWineType.red,
  source: CandidateSource.offline,
  country: 'IT',
);
const _online = WineCandidate(
  name: 'Château Musar Rouge',
  producer: 'Château Musar',
  source: CandidateSource.openFoodFacts,
  region: 'Bekaa Valley, Lebanon',
);
const _nameOnly = WineCandidate(
  name: 'Barbaresco',
  source: CandidateSource.internal,
);

void _ignore(WineCandidate _) {}

void main() {
  Widget list(
    List<WineCandidate> candidates, {
    ValueChanged<WineCandidate>? onPick,
    VoidCallback? onNone,
  }) => Scaffold(
    body: SingleChildScrollView(
      child: CandidateList(
        candidates: candidates,
        onPick: onPick ?? (_) {},
        onNone: onNone,
      ),
    ),
  );

  for (final locale in testLocales) {
    testWidgets('L4 FR3.2 name, producer, chips in words, vintage or "no '
        'vintage" (${locale.toLanguageTag()})', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      await pumpScreen(
        tester,
        list(const [_offline, _online, _nameOnly], onNone: () {}),
        locale: locale,
      );
      expect(find.text('Barbaresco DOCG 2019'), findsOneWidget);
      expect(find.text(l10n.labelChipOffline), findsOneWidget);
      expect(find.text(l10n.labelChipOnline), findsOneWidget);
      expect(find.text(l10n.labelChipCatalog), findsOneWidget);
      expect(find.text('2019'), findsOneWidget);
      expect(find.text(l10n.noVintage), findsNWidgets(2));
      expect(find.textContaining(l10n.labelNoProducer), findsOneWidget);
      expect(find.text(l10n.labelCandidatesNone), findsOneWidget);
      expect(find.text(l10n.labelOffAttribution), findsOneWidget);
    });
  }

  testWidgets('L8 the flag of a candidate is read as the country name', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, list(const [_offline, _online]));
    // The card is one tappable node: the country name is part of its label,
    // never the emoji.
    expect(find.bySemanticsLabel(RegExp('Italia')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Libano')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('🇮🇹')), findsNothing);
    handle.dispose();
  });

  testWidgets('BR6.2 a list of the internal catalog only has no '
      'attribution', (tester) async {
    await pumpScreen(tester, list(const [_nameOnly]));
    expect(find.byKey(const Key('label-off-attribution')), findsNothing);
    expect(needsOffAttribution(const [_nameOnly]), isFalse);
    expect(needsOffAttribution(const [_nameOnly, _online]), isTrue);
  });

  test('review R-02 offline results of the sample database need no '
      'attribution; Open Food Facts results still do', () {
    expect(needsOffAttribution(const [_offline]), isTrue);
    expect(
      needsOffAttribution(const [_offline], offlineIsSample: true),
      isFalse,
    );
    expect(
      needsOffAttribution(const [_offline, _online], offlineIsSample: true),
      isTrue,
    );
  });

  for (final locale in testLocales) {
    testWidgets('review R-02 with the sample database an offline-only list '
        'has no "Dati da Open Food Facts" (${locale.toLanguageTag()})', (
      tester,
    ) async {
      final l10n = lookupAppLocalizations(locale);
      await pumpScreen(
        tester,
        const Scaffold(
          body: SingleChildScrollView(
            child: CandidateList(
              candidates: [_offline],
              onPick: _ignore,
              offlineIsSample: true,
            ),
          ),
        ),
        locale: locale,
      );
      expect(find.text('Barbaresco DOCG 2019'), findsOneWidget);
      expect(find.text(l10n.labelChipOffline), findsOneWidget);
      expect(find.text(l10n.labelOffAttribution), findsNothing);
      expect(find.byKey(const Key('label-off-attribution')), findsNothing);
    });
  }

  testWidgets('review R-02 with the sample database an Open Food Facts '
      'result keeps the attribution', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: SingleChildScrollView(
          child: CandidateList(
            candidates: [_offline, _online],
            onPick: _ignore,
            offlineIsSample: true,
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('label-off-attribution')), findsOneWidget);
  });

  testWidgets('BR3.2 at most 10 shown; a tap picks the candidate; "Nessuno '
      'di questi" calls back', (tester) async {
    final picked = <WineCandidate>[];
    var none = 0;
    final many = [
      for (var i = 0; i < 12; i++)
        WineCandidate(name: 'Vino $i', source: CandidateSource.offline),
    ];
    await pumpScreen(
      tester,
      list(many, onPick: picked.add, onNone: () => none++),
    );
    expect(find.byKey(const Key('label-candidate-9')), findsOneWidget);
    expect(find.byKey(const Key('label-candidate-10')), findsNothing);
    await tester.tap(find.byKey(const Key('label-candidate-0')));
    expect(picked.single.name, 'Vino 0');
    await tester.ensureVisible(find.byKey(const Key('label-candidates-none')));
    await tester.tap(find.byKey(const Key('label-candidates-none')));
    expect(none, 1);
  });

  testWidgets('without onNone there is no "Nessuno di questi"', (tester) async {
    await pumpScreen(tester, list(const [_offline]));
    expect(find.byKey(const Key('label-candidates-none')), findsNothing);
  });

  accessibilityMatrix(
    'CandidateList',
    () => list(const [_offline, _online, _nameOnly], onNone: () {}),
  );
}
