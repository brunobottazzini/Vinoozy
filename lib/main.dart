import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account/ui/status_screens.dart';
import 'app/bootstrap.dart';
import 'app/vinoozy_app.dart';
import 'firebase/firebase_env.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runVinoozy();
}

/// Starts the services and shows the app. If start-up fails (for example
/// Firebase cannot initialize, or local data cannot be cleared after a reset)
/// an error screen with "Try again" is shown instead (logical-components.md).
Future<void> runVinoozy({FirebaseEnvConfig? config}) async {
  try {
    final services = await AppBootstrap.start(config: config);
    runApp(
      UncontrolledProviderScope(
        container: services.container,
        child: const VinoozyApp(),
      ),
    );
  } catch (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack, library: 'startup'),
    );
    runApp(StartupErrorApp(onRetry: () => runVinoozy(config: config)));
  }
}

/// Minimal app shown when start-up fails.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: VinoozyApp(
        home: Builder(
          builder: (context) => GateErrorScreen(
            message: AppLocalizations.of(context).startupFailed,
            onRetry: onRetry,
          ),
        ),
      ),
    );
  }
}
