import 'package:cloud_functions/cloud_functions.dart';

import '../firebase/functions_config.dart';

/// The backend's answer to a slot request (study §7.7 step 2, freemium-plus
/// FR7.2): one slot per account and UTC day, shared by every device.
class AdSlotReservation {
  const AdSlotReservation({
    required this.granted,
    this.reservationId,
    this.day,
    this.reason,
  });

  static const AdSlotReservation refused = AdSlotReservation(granted: false);

  /// Only a granted slot allows one SDK load.
  final bool granted;

  /// Identifies the slot in the outcome log (FR7.6).
  final String? reservationId;

  /// The UTC day of the slot (`YYYY-MM-DD`), by the server's clock.
  final String? day;

  /// Why it was not granted: `ADS_DISABLED`, `PLUS_ACTIVE`,
  /// `BELOW_THRESHOLD`, `ALREADY_RESERVED`.
  final String? reason;
}

/// What happened to the ad of a slot (FR7.6). A load is never an
/// impression, and an impression is never a revenue.
enum AdOutcome {
  request('request'),
  loaded('loaded'),
  failed('failed'),
  impression('impression'),
  revenue('revenue');

  const AdOutcome(this.wireValue);

  final String wireValue;
}

/// The ad calls of the backend, injected so the ad slot is tested without
/// the network.
abstract interface class AdSlotClient {
  /// `reserveAdSlot`: the backend checks again period, threshold,
  /// `adsEnabled` and Plus in a transaction, for the UTC day of its clock.
  Future<AdSlotReservation> reserve();

  /// Records one [outcome] of [reservation] (FR7.6). [valueMicros],
  /// [currencyCode] and [precision] only for [AdOutcome.revenue].
  Future<void> logOutcome(
    AdSlotReservation reservation,
    AdOutcome outcome, {
    double? valueMicros,
    String? currencyCode,
    String? precision,
  });
}

/// [AdSlotClient] over the callables `reserveAdSlot` and `recordAdOutcome`
/// (contracts in functions/README.md).
///
/// `reserveAdSlot` request: `{}`; answer: `granted`, `reason`,
/// `reservationId`, `day`. `recordAdOutcome` request: `reservationId`, `day`,
/// `event` and, for a revenue, `valueMicros` (integer), `currencyCode`,
/// `precision` (`unknown`, `estimated`, `publisher_provided`, `precise`).
class FunctionsAdSlotClient implements AdSlotClient {
  FunctionsAdSlotClient(this._functions);

  final FirebaseFunctions Function() _functions;

  static const String reserveName = 'reserveAdSlot';
  static const String outcomeName = 'recordAdOutcome';

  @override
  Future<AdSlotReservation> reserve() async {
    final result = await _functions()
        .httpsCallable(reserveName)
        .call<Object?>(<String, Object?>{});
    return parseReservation(result.data);
  }

  @override
  Future<void> logOutcome(
    AdSlotReservation reservation,
    AdOutcome outcome, {
    double? valueMicros,
    String? currencyCode,
    String? precision,
  }) async {
    final id = reservation.reservationId;
    final day = reservation.day;
    if (id == null || day == null) return;
    await _functions().httpsCallable(outcomeName).call<Object?>({
      'reservationId': id,
      'day': day,
      'event': outcome.wireValue,
      'valueMicros': ?valueMicros?.round(),
      'currencyCode': ?currencyCode,
      'precision': ?wirePrecision(precision),
    });
  }
}

/// The answer of `reserveAdSlot`, read leniently: anything but a granted
/// slot with its id and day is a refusal.
AdSlotReservation parseReservation(Object? data) {
  final answer = callableMap(data);
  final id = answer['reservationId'];
  final day = answer['day'];
  final reason = answer['reason'];
  if (answer['granted'] == true &&
      id is String &&
      id.isNotEmpty &&
      day is String) {
    return AdSlotReservation(granted: true, reservationId: id, day: day);
  }
  return AdSlotReservation(
    granted: false,
    reason: reason is String ? reason : null,
  );
}

/// The SDK precision names (`publisherProvided`) in the backend's words
/// (`publisher_provided`); null for an unknown name.
String? wirePrecision(String? precision) => switch (precision) {
  'unknown' => 'unknown',
  'estimated' => 'estimated',
  'publisherProvided' || 'publisher_provided' => 'publisher_provided',
  'precise' => 'precise',
  _ => null,
};
