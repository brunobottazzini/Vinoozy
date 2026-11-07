// Fixture of tool/check_dashboard_readonly_test.sh: a Dashboard file that
// imports a write repository, which the read-only check must refuse.
import '../../cellar/data/wine_repository.dart';

WinesSnapshot? lastSnapshot;
