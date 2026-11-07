// Host-side driver for the on-phone estimation speed check
// (integration_test_perf/estimation_perf_test.dart, cicd-pipeline.md §5).
// `flutter drive` needs it to collect the result; the reported median is
// written to build/integration_response_data.json.
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
