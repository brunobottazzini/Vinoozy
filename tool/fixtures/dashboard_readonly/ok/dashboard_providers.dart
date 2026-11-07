// Fixture of tool/check_dashboard_readonly_test.sh: the only file allowed to
// use shared_preferences, reading the U1 listeners only.
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/providers.dart';

Future<String?> readChoice() async =>
    (await SharedPreferences.getInstance()).getString('dashboard.choice');

final readOnlyListener = winesStreamProvider;
