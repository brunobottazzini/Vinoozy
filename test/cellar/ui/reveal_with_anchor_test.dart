// The add form filled from a text, opened with the name focused (u4-cellar
// BR1.18): the scroll that the focus triggers keeps the autofill bar, and
// "Search online" in it, fully visible with a 48 dp tap target (A2), at
// 200% text in the matrix languages and at normal size (wine-culture-
// languages, owner decision on the 200% layout).
import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/cellar/ui/reveal_with_anchor.dart';

import '../../helpers/ui_harness.dart';
import '../../label/autofill_fakes.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

const String _baroloText = 'Barolo Vietti\n2019';

Future<void> _openFilledForm(
  WidgetTester tester, {
  required Locale locale,
  required double textScale,
}) async {
  final cellarUi = CellarUi();
  await pumpScreen(
    tester,
    AddWineScreen(
      user: cellarOwner,
      cellarId: ownerCellar.cellarId,
      cellar: ownerCellar,
      initialValues: AddWineInitialValues.fromLabelFields(
        extractLabelFields(_baroloText, currentYear: 2026),
        notice: 'Compilato',
      ),
      onLens: () {},
      onSearchOnline: (_, _) {},
    ),
    locale: locale,
    textScale: textScale,
    overrides: [...cellarUi.overrides, ...AutofillFakes().overrides],
  );
  await tester.pumpAndSettle();
}

final Finder _searchOnline = find.byKey(const Key('autofill-search-online'));
final Finder _nameField = find.byKey(const Key('add-wine-name-field'));

/// The visible area of the form's scroll view.
Rect _viewport(WidgetTester tester) => tester.getRect(
  find.ancestor(of: _searchOnline, matching: find.byType(Scrollable)).first,
);

ScrollPosition _position(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.ancestor(of: _searchOnline, matching: find.byType(Scrollable)).first,
    )
    .position;

void _expectSearchOnlineFullyVisible(WidgetTester tester) {
  final button = tester.getRect(_searchOnline);
  final viewport = _viewport(tester);
  expect(button.height, greaterThanOrEqualTo(48));
  expect(button.top, greaterThanOrEqualTo(viewport.top));
  expect(button.bottom, lessThanOrEqualTo(viewport.bottom));
}

bool _nameHasFocus(WidgetTester tester) =>
    tester.widget<TextField>(_nameField).focusNode!.hasFocus;

void main() {
  group('200% text', () {
    for (final locale in const [
      Locale('de'),
      Locale('fr'),
      Locale('el'),
      Locale('uk'),
      Locale('ka'),
      Locale('nl'),
    ]) {
      testWidgets('${locale.toLanguageTag()}: "Search online" stays fully '
          'visible and the name keeps the focus', (tester) async {
        final handle = tester.ensureSemantics();
        await _openFilledForm(tester, locale: locale, textScale: 2.0);
        expect(_nameHasFocus(tester), isTrue, reason: 'BR1.18');
        _expectSearchOnlineFullyVisible(tester);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
      });
    }

    testWidgets('the form still scrolled down towards the name', (
      tester,
    ) async {
      await _openFilledForm(tester, locale: const Locale('de'), textScale: 2.0);
      // The focus scroll happened, it only stopped earlier.
      expect(_position(tester).pixels, greaterThan(0));
    });
  });

  group('normal text size', () {
    for (final locale in const [Locale('it'), Locale('en'), Locale('de')]) {
      testWidgets('${locale.toLanguageTag()}: nothing scrolls and the bar '
          'is visible', (tester) async {
        await _openFilledForm(tester, locale: locale, textScale: 1.0);
        expect(_nameHasFocus(tester), isTrue, reason: 'BR1.18');
        expect(_position(tester).pixels, 0);
        _expectSearchOnlineFullyVisible(tester);
        final name = tester.getRect(_nameField);
        expect(name.bottom, lessThanOrEqualTo(_viewport(tester).bottom));
      });
    }
  });

  group('later reveals are the ordinary ones', () {
    testWidgets('after the first reveal the caret is revealed alone', (
      tester,
    ) async {
      await _openFilledForm(tester, locale: const Locale('de'), textScale: 2.0);
      final render = tester.renderObject<RenderRevealWithAnchor>(
        find.ancestor(of: _nameField, matching: find.byType(RevealWithAnchor)),
      );
      expect(render.firstRevealDone, isTrue);

      // Scroll to the end, then focus the name again (as "Clear" does): the
      // name comes back into view, the bar is not forced in with it.
      final position = _position(tester);
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      tester.widget<TextField>(_nameField).focusNode!.requestFocus();
      await tester.pumpAndSettle();
      final name = tester.getRect(_nameField);
      final viewport = _viewport(tester);
      expect(name.top, greaterThanOrEqualTo(viewport.top - 1));
      expect(name.top, lessThan(viewport.bottom));
    });

    testWidgets('without a bar the name is revealed as before', (tester) async {
      final cellarUi = CellarUi();
      await pumpScreen(
        tester,
        AddWineScreen(
          user: cellarOwner,
          cellarId: ownerCellar.cellarId,
          cellar: ownerCellar,
        ),
        locale: const Locale('de'),
        textScale: 2.0,
        overrides: [...cellarUi.overrides, ...AutofillFakes().overrides],
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('autofill-toolbar')), findsNothing);
      expect(_nameHasFocus(tester), isTrue);
      final name = tester.getRect(_nameField);
      final viewport = tester.getRect(
        find.ancestor(of: _nameField, matching: find.byType(Scrollable)).first,
      );
      expect(name.top, greaterThanOrEqualTo(viewport.top));
      expect(name.bottom, lessThanOrEqualTo(viewport.bottom));
    });
  });
}
