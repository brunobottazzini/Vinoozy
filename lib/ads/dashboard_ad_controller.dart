import 'dart:async';

import 'package:flutter/foundation.dart';

import '../account/network_status.dart';
import '../app/error_reporter.dart';
import '../core/clock.dart';
import '../sync/ledger/key_value_store.dart';
import 'ad_eligibility.dart';
import 'ad_slot_client.dart';
import 'ads_gateway.dart';

/// Where the Dashboard banner of the day is.
enum AdSlotPhase {
  /// Nothing tried yet in this view.
  idle,

  /// A step is running: consent, reservation, SDK initialisation or load.
  working,

  /// The banner is on screen.
  shown,

  /// Nothing more today: the attempt of the day is used, or the conditions
  /// do not allow one.
  done,
}

/// The single Dashboard banner of study §7.7 (freemium-plus FR7.1-FR7.4,
/// FR7.6), step by step:
///
/// 1. Only while [AdEligibility.canAttemptAd] holds: ads on, state verified,
///    no Plus, threshold crossed, Dashboard visible, network, and no attempt
///    today on this phone.
/// 2. The consent flow (UMP) before any request.
/// 3. The backend slot of the account and UTC day; without an answer no ad
///    is loaded. A slot answered (granted or not) uses the day's attempt.
/// 4. Only then the SDK is initialised and one banner loaded, with no retry
///    and no reload the same day.
/// 5. Plus, ads turned off, leaving the Dashboard or the background remove
///    and destroy the banner at once, also while it is loading (FR7.4).
///
/// With `adsEnabled=false` the gateway is never called: no SDK
/// initialisation, no request (FR7.1).
class DashboardAdController extends ChangeNotifier {
  DashboardAdController({
    required this._uid,
    required this._gateway,
    required this._slots,
    required this._network,
    required this._reporter,
    this._store,
    this._clock = const SystemClock(),
  });

  static const String attemptKeyPrefix = 'ads.attempt.v1/';

  final String _uid;
  final AdsGateway _gateway;
  final AdSlotClient _slots;
  final NetworkStatus _network;
  final ErrorReporter _reporter;
  final KeyValueStore? _store;
  final Clock _clock;

  AdSlotPhase _phase = AdSlotPhase.idle;
  AdBannerHandle? _banner;
  AdSlotReservation? _reservation;
  String? _dayOfPhase;
  final Set<AdOutcome> _logged = {};

  AdEligibilityInput _input = const AdEligibilityInput(
    adsEnabled: false,
    stateVerified: false,
    plusActive: false,
    aboveThreshold: false,
  );
  bool _visible = false;

  /// Increases on every cancel, so a step that finishes after it does
  /// nothing.
  int _generation = 0;
  bool _disposed = false;

  AdSlotPhase get phase => _phase;

  /// The banner, only while [phase] is [AdSlotPhase.shown].
  AdBannerHandle? get banner => _phase == AdSlotPhase.shown ? _banner : null;

  String get _today => utcDayId(_clock.now());

  /// `YYYY-MM-DD` of the UTC day of [instant]: the local mark of the day's
  /// attempt (the backend keeps its own, by its clock).
  static String utcDayId(DateTime instant) {
    final utc = instant.toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-'
        '${two(utc.day)}';
  }

  /// The inputs changed (policy, plan, usage, visibility).
  void update({required AdEligibilityInput input, required bool visible}) {
    _input = input;
    _visible = visible;
    if (!_allowedNow) {
      _cancel();
      return;
    }
    if (_phase == AdSlotPhase.done && _dayOfPhase != _today) {
      _phase = AdSlotPhase.idle;
    }
    if (_phase == AdSlotPhase.idle) unawaited(_attempt());
  }

  bool get _allowedNow => AdEligibility.eligible(_input) && _visible;

  Future<void> _attempt() async {
    final generation = _generation;
    _dayOfPhase = _today;
    _set(AdSlotPhase.working);
    bool stale() => _disposed || generation != _generation || !_allowedNow;
    if (await _attemptedToday() || stale()) return _finish(generation);
    final network = await _safe(_network.hasNetwork, false);
    final consent = network && await _safe(_gateway.gatherConsent, false);
    if (stale() ||
        !AdEligibility.canAttemptAd(
          _input,
          AdAttemptContext(
            dashboardVisible: _visible,
            consentAllowsAds: consent,
            networkAvailable: network,
            sensitiveOperationInProgress: false,
            reservedTodayUtc: false,
          ),
        )) {
      return _finish(generation);
    }
    final AdSlotReservation reservation;
    try {
      reservation = await _slots.reserve();
    } catch (error, stack) {
      // No answer, no ad (study §7.7 step 2); tried again on a later visit.
      await _reporter.report(error, stack, reason: 'AdSlotFailed');
      return _finish(generation);
    }
    await _markAttempted();
    if (!reservation.granted || stale()) return _finish(generation);
    _reservation = reservation;
    await _safe(_gateway.initialize, null);
    if (stale()) return _finish(generation);
    _log(AdOutcome.request);
    _banner = _gateway.loadBanner(
      AdBannerCallbacks(
        onLoaded: () => _onLoaded(generation),
        onFailed: () {
          _log(AdOutcome.failed);
          _finish(generation);
        },
        onImpression: () => _log(AdOutcome.impression),
        onPaid: (value, currency, precision) => _log(
          AdOutcome.revenue,
          valueMicros: value,
          currencyCode: currency,
          precision: precision,
        ),
      ),
    );
  }

  void _onLoaded(int generation) {
    // FR7.4: a Plus (or ads off) that arrived during the load wins.
    if (_disposed || generation != _generation || !_allowedNow) {
      _cancel();
      return;
    }
    _log(AdOutcome.loaded);
    _set(AdSlotPhase.shown);
  }

  /// No more tries in this view today.
  void _finish(int generation) {
    if (_disposed || generation != _generation) return;
    unawaited(_disposeBanner());
    _set(AdSlotPhase.done);
  }

  /// Removes and destroys the banner, cancelling any step in progress. The
  /// day's attempt stays used: no reload the same day (FR7.3).
  void _cancel() {
    _generation++;
    unawaited(_disposeBanner());
    if (_phase == AdSlotPhase.idle) return;
    _set(AdSlotPhase.done);
  }

  Future<void> _disposeBanner() async {
    final banner = _banner;
    _banner = null;
    if (banner == null) return;
    try {
      await banner.dispose();
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'AdDisposeFailed');
    }
  }

  void _log(
    AdOutcome outcome, {
    double? valueMicros,
    String? currencyCode,
    String? precision,
  }) {
    final reservation = _reservation;
    // One record per outcome and slot (FR7.6); the backend keeps the first
    // of each event too.
    if (reservation == null) return;
    if (!_logged.add(outcome)) return;
    unawaited(
      _slots
          .logOutcome(
            reservation,
            outcome,
            valueMicros: valueMicros,
            currencyCode: currencyCode,
            precision: precision,
          )
          .catchError(
            (Object error, StackTrace stack) =>
                _reporter.report(error, stack, reason: 'AdOutcomeFailed'),
          ),
    );
  }

  String get _attemptKey => '$attemptKeyPrefix$_uid';

  Future<bool> _attemptedToday() async {
    final store = _store;
    if (store == null) return false;
    return await _safe(() => store.read(_attemptKey), null) == _today;
  }

  Future<void> _markAttempted() async {
    final store = _store;
    if (store == null) return;
    await _safe(() => store.write(_attemptKey, _today), null);
  }

  Future<T> _safe<T>(Future<T> Function() step, T fallback) async {
    try {
      return await step();
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'AdStepFailed');
      return fallback;
    }
  }

  void _set(AdSlotPhase phase) {
    if (_disposed || _phase == phase) return;
    _phase = phase;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    unawaited(_disposeBanner());
    super.dispose();
  }
}
