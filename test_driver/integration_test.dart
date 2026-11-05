// Host-side driver for `flutter drive`, used only by tool/e2e_force_stop.sh:
// unlike `flutter test`, `flutter drive --keep-app-running` leaves the app
// installed and running when the test ends, so the script can kill it with
// `adb shell am force-stop`.
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
