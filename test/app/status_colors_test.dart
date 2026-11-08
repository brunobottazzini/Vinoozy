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

      // ux-redesign FR3.1 (A1, A8): every text/background pair of the
      // palette at least 4.5:1.
      final scheme = theme.colorScheme;
      final textPairs = {
        'onPrimary on primary (buttons, FAB, box)': (
          scheme.onPrimary,
          scheme.primary,
        ),
        'onSurface on surface': (scheme.onSurface, scheme.surface),
        'onSurface on cards': (scheme.onSurface, scheme.surfaceContainer),
        'onSurface on chosen cells': (
          scheme.onSurface,
          scheme.surfaceContainerHigh,
        ),
        'onSurfaceVariant on surface': (
          scheme.onSurfaceVariant,
          scheme.surface,
        ),
        'onSurfaceVariant on cards': (
          scheme.onSurfaceVariant,
          scheme.surfaceContainer,
        ),
        'onSurfaceVariant on the disabled FAB': (
          scheme.onSurfaceVariant,
          scheme.surfaceContainerHighest,
        ),
        'onSecondaryContainer on "Ho bevuto"': (
          scheme.onSecondaryContainer,
          scheme.secondaryContainer,
        ),
        'onPrimaryContainer on primaryContainer': (
          scheme.onPrimaryContainer,
          scheme.primaryContainer,
        ),
        'primary titles on surface': (scheme.primary, scheme.surface),
        'primary on cards (outlined buttons)': (
          scheme.primary,
          scheme.surfaceContainer,
        ),
        'snack text on the snack bar': (scheme.surface, scheme.onSurface),
        'snack actions on the snack bar': (
          scheme.inversePrimary,
          scheme.onSurface,
        ),
        'ready chip': (colors.onReadyChip, colors.readyChip),
        'waiting chip and notice': (colors.onWaitingChip, colors.waitingChip),
        'drink soon chip': (colors.onDrinkSoonChip, colors.drinkSoonChip),
        'past window chip': (colors.onPastWindowChip, colors.pastWindowChip),
      };
      for (final MapEntry(key: name, value: (text, background))
          in textPairs.entries) {
        test('A1 $name has at least 4.5:1', () {
          expect(contrastRatio(text, background), greaterThanOrEqualTo(4.5));
        });
      }

      test('A1 stars and control borders have at least 3:1 (review R-10)', () {
        expect(
          contrastRatio(scheme.secondary, scheme.surfaceContainer),
          greaterThanOrEqualTo(3.0),
          reason: 'stars of the rating',
        );
        expect(
          contrastRatio(scheme.outline, scheme.surface),
          greaterThanOrEqualTo(3.0),
          reason: 'field and chip borders',
        );
      });

      test('the bars keep 3:1 also on the cards (surfaceContainer)', () {
        for (final color in bars.values) {
          expect(
            contrastRatio(color, scheme.surfaceContainer),
            greaterThanOrEqualTo(3.0),
          );
        }
      });

      test(
        'FR3.1 secondary, tertiary, containers and surfaces are distinct',
        () {
          expect({
            scheme.primary,
            scheme.secondary,
            scheme.tertiary,
            scheme.surface,
            scheme.surfaceContainer,
            scheme.surfaceContainerHigh,
            scheme.secondaryContainer,
          }, hasLength(7));
        },
      );

      test('registers its WineTypeColors with 6 distinct colors', () {
        final types = theme.extension<WineTypeColors>()!;
        expect(
          types,
          brightness == Brightness.light
              ? WineTypeColors.light
              : WineTypeColors.dark,
        );
        expect({
          types.red,
          types.white,
          types.rose,
          types.sparkling,
          types.sweet,
          types.unknown,
        }, hasLength(6));
      });

      test('titles use the system serif (review Major 2, NFR3)', () {
        expect(theme.textTheme.titleLarge?.fontFamily, titleFontFamily);
        expect(theme.textTheme.displaySmall?.fontFamily, 'serif');
        expect(theme.textTheme.bodyMedium?.fontFamily, isNot('serif'));
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
    expect(light.lerp(StatusColors.dark, 1), StatusColors.dark);
    expect(light.lerp(null, 0.5), light);
    expect(changed.readyChip, light.readyChip, reason: 'chips kept');
    expect(light == StatusColors.dark, isFalse);
    expect(light.hashCode, StatusColors.light.hashCode);
  });

  test('WineTypeColors copyWith and lerp', () {
    const light = WineTypeColors.light;
    final changed = light.copyWith(red: const Color(0xFF000000));

    expect(changed.red, const Color(0xFF000000));
    expect(changed.white, light.white);
    expect(light.copyWith(), light);
    expect(light.lerp(WineTypeColors.dark, 1), WineTypeColors.dark);
    expect(light.lerp(null, 0.3), light);
    expect(light.hashCode, WineTypeColors.light.hashCode);
  });

  testWidgets('WineTypeColors.of reads the theme, with the light fallback', (
    tester,
  ) async {
    late WineTypeColors fromDark;
    late WineTypeColors fallback;
    await tester.pumpWidget(
      Column(
        children: [
          Theme(
            data: buildAppTheme(Brightness.dark),
            child: Builder(
              builder: (context) {
                fromDark = WineTypeColors.of(context);
                return const SizedBox();
              },
            ),
          ),
          Theme(
            data: ThemeData(),
            child: Builder(
              builder: (context) {
                fallback = WineTypeColors.of(context);
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );

    expect(fromDark, WineTypeColors.dark);
    expect(fallback, WineTypeColors.light);
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
