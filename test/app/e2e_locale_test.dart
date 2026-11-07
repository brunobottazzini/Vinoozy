// The Italian language of the E2E builds never applies to other builds
// (u8-account review R-01; the release build is checked by
// tool/check_release_build.sh).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/vinoozy_app.dart';
import 'package:vinoozy/e2e/e2e_locale.dart';
import 'package:vinoozy/firebase/firebase_env.dart';

void main() {
  test('without E2E=true there is no language override', () {
    expect(kIsE2EBuild, isFalse);
    expect(appLocaleOverride, isNull);
    expect(e2eLocale, const Locale('it'));
  });

  test('the announcement logs nothing outside E2E builds', () {
    final logs = <String?>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message);
    addTearDown(() => debugPrint = original);
    announceE2ELocale();
    expect(logs, isEmpty);
  });

  testWidgets('the app follows the phone language (BR5.1)', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(
      const ProviderScope(child: VinoozyApp(home: SizedBox())),
    );
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, isNull);
    expect(
      Localizations.localeOf(tester.element(find.byType(SizedBox))),
      const Locale('en'),
    );
  });
}
