import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app/error_reporter.dart';
import '../core/clock.dart';
import 'dev_cheats.dart';

/// Writes the entitlement of a developer scenario in the Firestore
/// **emulator** only (freemium-plus FR5.6, plan decision D5, study §9.3), so
/// the rules on the server see the same plan as the app.
///
/// It uses the emulator REST API with `Authorization: Bearer owner`, which
/// only the emulator accepts and which skips the rules there. Before any
/// request it checks that the project is `demo-vinoozy` and that the host is
/// a local or private address (the emulator on this computer or on its
/// network), never a public host. Development builds only: it is reached
/// only from the developer panel, inside `if (kDevCheatsAvailable)`.
class DevEntitlementFixture {
  DevEntitlementFixture({
    required this._client,
    required this._host,
    required this._reporter,
    this._port = 8080,
    this._projectId = devCheatsProjectId,
    this._clock = const SystemClock(),
    this._timeout = const Duration(seconds: 3),
  });

  final http.Client _client;
  final String _host;
  final int _port;
  final String _projectId;
  final ErrorReporter _reporter;
  final Clock _clock;
  final Duration _timeout;

  /// Whether [host] may be an emulator: loopback, the Android emulator's
  /// alias of the computer, or a private network address.
  static bool isEmulatorHost(String host) {
    if (host == 'localhost' || host == '10.0.2.2') return true;
    final parts = host.split('.').map(int.tryParse).toList();
    if (parts.length != 4 || parts.any((p) => p == null || p > 255)) {
      return false;
    }
    final a = parts[0]!;
    final b = parts[1]!;
    return a == 127 ||
        a == 10 ||
        (a == 192 && b == 168) ||
        (a == 172 && b >= 16 && b <= 31);
  }

  /// Applies [scenario] for [uid]; null removes the test entitlement
  /// ("Restore normal state"). True only when the emulator confirmed it:
  /// false means "incomplete simulation", never a success.
  Future<bool> apply(String uid, DevScenario? scenario) async {
    if (_projectId != devCheatsProjectId || !isEmulatorHost(_host)) {
      return false;
    }
    final uri = Uri.http(
      '$_host:$_port',
      '/v1/projects/$_projectId/databases/(default)/documents/entitlements/'
          '$uid',
    );
    const headers = {
      'Authorization': 'Bearer owner',
      'Content-Type': 'application/json',
    };
    try {
      final response = switch (_fieldsOf(scenario)) {
        null => await _client.delete(uri, headers: headers).timeout(_timeout),
        final fields =>
          await _client
              .patch(
                uri,
                headers: headers,
                body: jsonEncode({'fields': fields}),
              )
              .timeout(_timeout),
      };
      // A delete of a missing document is a success too.
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'DevFixtureFailed');
      return false;
    }
  }

  /// The entitlement of [scenario] in the REST format; null for none (free
  /// plan, restore).
  Map<String, Object?>? _fieldsOf(DevScenario? scenario) {
    final now = _clock.now().toUtc();
    Map<String, Object?> text(String value) => {'stringValue': value};
    Map<String, Object?> time(DateTime value) => {
      'timestampValue': value.toUtc().toIso8601String(),
    };
    final common = {
      'plan': text('plus'),
      'source': text('manual_grant'),
      'reason': text('owner_test'),
      'startedAt': time(now),
      'updatedAt': time(now),
    };
    return switch (scenario) {
      DevScenario.unlockAll => {...common, 'status': text('active')},
      DevScenario.simulateExpired => {
        ...common,
        'status': text('expired'),
        'expiresAt': time(now.subtract(const Duration(days: 1))),
      },
      DevScenario.simulateFree || null => null,
    };
  }
}
