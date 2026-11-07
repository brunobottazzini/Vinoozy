// Fixture of tool/check_dashboard_readonly_test.sh: a pure calculator whose
// collection writes (List.add, Map.update) must not trip the read-only check.
import 'package:estimation/estimation.dart';

class FixtureCalculator {
  List<WineStatus> compute(List<WineStatus> statuses) {
    final counts = <WineStatus, int>{};
    final list = <WineStatus>[];
    for (final status in statuses) {
      counts.update(status, (n) => n + 1, ifAbsent: () => 1);
      list.add(status);
    }
    return list;
  }
}
