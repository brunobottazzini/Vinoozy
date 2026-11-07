# estimation

Pure Dart library behind Vinoozy's drinking-window estimate (contract C2 v1).
No Flutter, no Firebase, no network, disk or clock access: the same input always
gives the same output.

## API

```dart
import 'package:estimation/estimation.dart';

final window = estimateWindow(
  const WineFacts(name: 'Barolo', vintage: 2016),
); // 2024 / 2031 / 2046, medium, internalRules, basis denomination
final status = statusOf(window, DateTime(2026, 9, 1)); // WineStatus.ready
final pairings = pairingsFor(const WineFacts(name: 'Barolo', vintage: 2016));
final refine = needsRefinement(window); // true: ask the catalog when online
```

Invalid input (empty name, year outside 1900..2200, no vintage and no
`referenceYear`, an incoherent window passed to `statusOf`) throws
`EstimationArgumentError`, whose `code` tells the caller what went wrong.

The wine tables (denominations, wine types, pairing categories) live in
`lib/src/tables.dart` as `const` data.

## Checks

Run from this directory:

```bash
dart pub get
dart test
dart test --coverage=coverage && dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib && ../../tool/check_coverage.sh 90 coverage/lcov.info
../../tool/check_estimation_purity.sh
dart run benchmark/estimation_benchmark.dart
```
