import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_notices.dart';
import '../../plan/plan_providers.dart';
import '../../usage/usage_providers.dart';
import '../ad_eligibility.dart';
import '../ads_providers.dart';
import '../dashboard_ad_controller.dart';

/// The only ad space of the app: one banner at the bottom of the Dashboard
/// (freemium-plus FR7.1-FR7.4; study §7.7). Nothing on any other screen.
///
/// It is empty unless [DashboardAdController] has a banner to show. The
/// Dashboard counts as visible only while its tab is selected, no other
/// screen covers it and the app is in the foreground; otherwise the banner
/// is removed and destroyed, and not loaded again the same day.
class DashboardAdSlot extends ConsumerStatefulWidget {
  const DashboardAdSlot({super.key, required this.user});

  final AppUser user;

  @override
  ConsumerState<DashboardAdSlot> createState() => _DashboardAdSlotState();
}

class _DashboardAdSlotState extends ConsumerState<DashboardAdSlot> {
  DashboardAdController? _controller;
  late final AppLifecycleListener _lifecycle;
  bool _foreground = true;
  ({AdEligibilityInput input, bool visible})? _sent;

  @override
  void initState() {
    super.initState();
    final gateway = ref.read(adsGatewayProvider);
    final slots = ref.read(adSlotClientProvider);
    if (gateway != null && slots != null) {
      _controller = DashboardAdController(
        uid: widget.user.uid,
        gateway: gateway,
        slots: slots,
        network: ref.read(networkStatusProvider),
        reporter: ref.read(errorReporterProvider),
        store: ref.read(planNoticeStoreProvider),
        clock: ref.read(clockProvider),
      )..addListener(_changed);
    }
    _lifecycle = AppLifecycleListener(
      onShow: () => _setForeground(true),
      onResume: () => _setForeground(true),
      onHide: () => _setForeground(false),
      onPause: () => _setForeground(false),
    );
  }

  void _setForeground(bool foreground) {
    if (_foreground == foreground || !mounted) return;
    setState(() => _foreground = foreground);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _controller
      ?..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  /// Sends the inputs to the controller after the frame, only when they
  /// changed.
  void _schedule(AdEligibilityInput input, bool visible) {
    final next = (input: input, visible: visible);
    final sent = _sent;
    if (sent != null && sent.visible == visible && _same(sent.input, input)) {
      return;
    }
    _sent = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller?.update(input: input, visible: visible);
    });
  }

  static bool _same(AdEligibilityInput a, AdEligibilityInput b) =>
      a.adsEnabled == b.adsEnabled &&
      a.stateVerified == b.stateVerified &&
      a.plusActive == b.plusActive &&
      a.aboveThreshold == b.aboveThreshold;

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    final uid = widget.user.uid;
    final policy = ref.watch(planPolicyProvider);
    final capabilities = ref.watch(capabilitiesProvider(uid));
    final usage = ref.watch(usageStatusProvider).value;
    final input = AdEligibilityInput(
      adsEnabled: policy.adsEnabled,
      stateVerified:
          (usage?.verified ?? false) &&
          ref.watch(entitlementKnownProvider(uid)),
      plusActive: capabilities.adFree,
      aboveThreshold: usage?.aboveBudget ?? false,
    );
    final visible =
        _foreground &&
        ref.watch(dashboardTabVisibleProvider) &&
        (ModalRoute.of(context)?.isCurrent ?? true);
    _schedule(input, visible);
    // The banner never shows once Plus or "ads off" is known, even before
    // the controller removed it (FR7.4).
    final banner = AdEligibility.eligible(input) && visible
        ? controller.banner
        : null;
    if (banner == null) return const SizedBox.shrink();
    return Semantics(
      container: true,
      label: AppLocalizations.of(context).adLabel,
      child: SafeArea(
        top: false,
        child: Center(
          key: const Key('dashboard-ad-slot'),
          child: banner.buildView(),
        ),
      ),
    );
  }
}
