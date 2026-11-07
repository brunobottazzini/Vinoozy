// StatusColors contrast (u5-dashboard security-design.md §3, NFR3.2): every
// bar at least 3:1 against the card, the numbers at least 4.5:1, in the
// light and dark theme. WCAG 2.x relative luminance and contrast ratio.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/theme.dart';

double _channel(double c) =>
    c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double relativeLuminance(Color color) =>
    0.2126 * _channel(color.r) +
    0.7152 * _channel(color.g) +
    0.0722 * _channel(color.b);

double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('the WCAG formula gives 21:1 for black on white and 1:1 for equal', () {
    expect(
      contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
    expect(
      contrastRatio(const Color(0xFF777777), const Color(0xFF777777)),
      closeTo(1, 0.0001),
    );
  });

  for (final brightness in Brightness.values) {
    group('${brightness.name} theme', () {
      final theme = buildAppTheme(brightness);
      final colors = theme.extension<StatusColors>()!;
      // Dashboard cards are painted with the theme surface.
      final card = theme.colorScheme.surface;

      test('registers its StatusColors', () {
        expect(
          colors,
          brightness == Brightness.light
              ? StatusColors.light
              : StatusColors.dark,
        );
      });

      final bars = {
        'waiting': colors.waiting,
        'ready': colors.ready,
        'drinkSoon': colors.drinkSoon,
        'pastWindow': colors.pastWindow,
        'neutral': colors.neutral,
      };
      for (final MapEntry(key: name, value: color) in bars.entries) {
        test('$name bar has at least 3:1 against the card', () {
          expect(contrastRatio(color, card), greaterThanOrEqualTo(3.0));
        });
      }

      test('the numbers (onSurface on the card) have at least 4.5:1', () {
        expect(
          contrastRatio(theme.colorScheme.onSurface, card),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('the four status colors are distinct', () {
        expect({
          colors.waiting,
          colors.ready,
          colors.drinkSoon,
          colors.pastWindow,
        }, hasLength(4));
      });
    });
  }

  test('copyWith and lerp keep the extension usable in theme animations', () {
    const light = StatusColors.light;
    final changed = light.copyWith(ready: const Color(0xFF000000));

    expect(changed.ready, const Color(0xFF000000));
    expect(changed.waiting, light.waiting);
    expect(light.copyWith(), light);
    expect(light.lerp(StatusColors.dark, 0), light);
    expect(light.lerp(StatusColors.dark, 1).neutral, StatusColors.dark.neutral);
    expect(light.lerp(null, 0.5), light);
  });

  testWidgets('StatusColors.of reads the theme, with the light fallback', (
    tester,
  ) async {
    late StatusColors fromDark;
    late StatusColors fallback;
    await tester.pumpWidget(
      Column(
        children: [
          Theme(
            data: buildAppTheme(Brightness.dark),
            child: Builder(
              builder: (context) {
                fromDark = StatusColors.of(context);
                return const SizedBox();
              },
            ),
          ),
          Theme(
            data: ThemeData(),
            child: Builder(
              builder: (context) {
                fallback = StatusColors.of(context);
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );

    expect(fromDark, StatusColors.dark);
    expect(fallback, StatusColors.light);
  });
}
