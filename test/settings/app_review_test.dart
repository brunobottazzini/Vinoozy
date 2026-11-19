// tester-feedback FR5.1, FR5.4: "Rate the app" asks Google Play for the
// review window and falls back to the store page; the automatic prompt never
// throws and opens nothing else.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/app/store_links.dart';
import 'package:vinoozy/settings/app_review.dart';

class MockInAppReview extends Mock implements InAppReview {}

void main() {
  late MockInAppReview review;
  late List<String> opened;
  late List<Object> errors;

  setUp(() {
    review = MockInAppReview();
    opened = [];
    errors = [];
    when(() => review.requestReview()).thenAnswer((_) async {});
  });

  InAppReviewLauncher launcher({bool linkOpens = true}) => InAppReviewLauncher(
    review: review,
    openLink: (url) async {
      opened.add(url);
      return linkOpens;
    },
    onError: (error, _) => errors.add(error),
  );

  test('available: "Rate the app" asks for the Google Play window', () async {
    when(() => review.isAvailable()).thenAnswer((_) async => true);
    expect(await launcher().openRatingPage(), isTrue);
    verify(() => review.requestReview()).called(1);
    expect(opened, isEmpty);
  });

  test('not available: the Play Store page opens in the browser', () async {
    when(() => review.isAvailable()).thenAnswer((_) async => false);
    expect(await launcher().openRatingPage(), isTrue);
    verifyNever(() => review.requestReview());
    expect(opened, [playStoreLink]);
    expect(await launcher(linkOpens: false).openRatingPage(), isFalse);
  });

  test('a platform exception falls back without crashing', () async {
    when(() => review.isAvailable()).thenAnswer((_) async => true);
    when(() => review.requestReview())
        .thenThrow(PlatformException(code: 'play_store_missing'));
    expect(await launcher().openRatingPage(), isTrue);
    expect(opened, [playStoreLink]);
    expect(errors, [isA<PlatformException>()]);
  });

  test('a failing availability check counts as not available', () async {
    when(() => review.isAvailable())
        .thenThrow(PlatformException(code: 'no_service'));
    await launcher().requestReview();
    verifyNever(() => review.requestReview());
    expect(errors, hasLength(1));
  });

  test('the automatic prompt asks only when available, never throws', () async {
    when(() => review.isAvailable()).thenAnswer((_) async => false);
    await launcher().requestReview();
    verifyNever(() => review.requestReview());

    when(() => review.isAvailable()).thenAnswer((_) async => true);
    await launcher().requestReview();
    verify(() => review.requestReview()).called(1);

    when(() => review.requestReview())
        .thenThrow(PlatformException(code: 'quota'));
    await expectLater(launcher().requestReview(), completes);
    // The automatic prompt never opens the store page (FR5.4).
    expect(opened, isEmpty);
    expect(errors, [isA<PlatformException>()]);
  });
}
