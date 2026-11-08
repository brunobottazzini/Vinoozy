import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../catalog/core/wine_catalog.dart';
import '../../cellar/domain/wine.dart';
import '../../cellar/ui/add_wine_screen.dart';
import '../../sharing/domain/membership.dart';
import '../core/label_session.dart';
import '../label_providers.dart';
import '../platform/picker_image_source.dart';
import 'label_reading_screen.dart';
import 'online_search_screen.dart';

/// Where the person adds the wine: the user, the active cellar and its
/// wines, passed along to the U4 form and save.
class LabelTarget {
  const LabelTarget({
    required this.user,
    required this.cellar,
    this.cellarWines = const [],
  });

  final AppUser user;
  final AccessibleCellar cellar;
  final List<Wine> cellarWines;
}

/// "Riprova" from a reading started by a button: start that button again.
class LabelRetry {
  const LabelRetry(this.origin);

  final PhotoOrigin origin;
}

/// Opens the system camera or photo picker and then the reading
/// (frontend-components.md, LabelCaptureFlow; BR1.2, BR1.3, BR1.5):
/// - back without a photo: nothing, "Aggiungi" stays (no message);
/// - a photo: the reading screen;
/// - a refused access, no camera, a failure: the reading screen in that
///   state, with its way out.
abstract final class LabelCaptureFlow {
  static Future<void> run(
    BuildContext context,
    WidgetRef ref,
    LabelTarget target,
    PhotoOrigin origin,
  ) async {
    // Taken from this screen's scope once, and carried into the reading:
    // the reading screen is pushed on the app Navigator, outside any nested
    // ProviderScope around this screen.
    final services = LabelServices.of(ref);
    var next = origin;
    while (context.mounted) {
      final outcome = await services.source.pick(next);
      if (!context.mounted) return;
      final input = switch (outcome) {
        PickCancelled() => null,
        PickedImage(:final path) => PickedLabelInput(path),
        PickDenied() => DeniedLabelInput(next),
        PickCameraUnavailable() => const CameraUnavailableLabelInput(),
        PickFailed(:final error, :final stack) => FailedPickLabelInput(
          error,
          stack,
        ),
      };
      if (input == null) return;
      final retry = await Navigator.of(context).push<LabelRetry>(
        MaterialPageRoute(
          builder: (_) => LabelReadingScreen(
            target: target,
            input: input,
            origin: next,
            services: services,
          ),
        ),
      );
      if (retry == null) return;
      next = retry.origin;
    }
  }

  /// "Scrivi" and "Scrivi a mano": the empty U4 form, name active (BR1.1,
  /// BR1.11), above the shell.
  ///
  /// label-autofill-windows: [openLens] opens Lens once the form is shown
  /// (BR2.5); [sharedText] fills it with a text shared to the app (BR2.4).
  static void openForm(
    BuildContext context,
    LabelTarget target, {
    AddWineInitialValues? initialValues,
    bool openLens = false,
    String? sharedText,
  }) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LabelFormTracker(
          tracked: initialValues != null,
          child: AddWineScreen(
            user: target.user,
            cellarId: target.cellar.cellarId,
            cellar: target.cellar,
            cellarWines: target.cellarWines,
            initialValues: initialValues,
            openLensOnStart: openLens,
            sharedText: sharedText,
            onSearchOnline: (context, query) =>
                searchOnline(context, target, query),
          ),
        ),
      ),
      (route) => route.isFirst,
    );
  }

  /// The form filled from the text of a photo with no wine found
  /// (label-autofill-windows BR2.1, F1): pushed above the reading, so
  /// "Lens" of the bar can send the front photo and back returns to it; a
  /// save goes back to the cellar.
  static Future<void> openFilledForm(
    BuildContext context,
    LabelTarget target,
    AddWineInitialValues initialValues, {
    VoidCallback? onLens,
    void Function(BuildContext context, String query)? onSearchOnline,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => LabelFormTracker(
        child: AddWineScreen(
          user: target.user,
          cellarId: target.cellar.cellarId,
          cellar: target.cellar,
          cellarWines: target.cellarWines,
          initialValues: initialValues,
          returnToRootOnSave: true,
          onLens: onLens,
          onSearchOnline:
              onSearchOnline ??
              (context, query) => searchOnline(context, target, query),
        ),
      ),
    ),
  );

  /// "Search online" of the autofill bar (FR1.2): the search of today with
  /// the words of the form.
  static Future<void> searchOnline(
    BuildContext context,
    LabelTarget target,
    String query,
  ) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => OnlineSearchScreen(
        target: target,
        initialQuery: query.length > OnlineSearchScreen.maxQueryLength
            ? query.substring(0, OnlineSearchScreen.maxQueryLength)
            : query,
      ),
    ),
  );

  /// A candidate chosen (label-recognition FR3.3, BR4.4): the U4 form
  /// filled with everything the candidate has, country and region as in
  /// the UX, pushed above the list so "back" returns to it; a save goes back
  /// to the cellar.
  static Future<void> openCandidateForm(
    BuildContext context,
    LabelTarget target,
    WineCandidate candidate,
  ) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => LabelFormTracker(
        child: AddWineScreen(
          user: target.user,
          cellarId: target.cellar.cellarId,
          cellar: target.cellar,
          cellarWines: target.cellarWines,
          initialValues: AddWineInitialValues.fromCandidate(candidate),
          returnToRootOnSave: true,
        ),
      ),
    ),
  );
}

/// Marks a U4 form filled from a label as "unsaved data" while it is open,
/// for the question before a new shared photo replaces it (BR1.4).
class LabelFormTracker extends ConsumerStatefulWidget {
  const LabelFormTracker({super.key, required this.child, this.tracked = true});

  final Widget child;
  final bool tracked;

  @override
  ConsumerState<LabelFormTracker> createState() => _LabelFormTrackerState();
}

class _LabelFormTrackerState extends ConsumerState<LabelFormTracker> {
  late final LabelFlow _flow;

  @override
  void initState() {
    super.initState();
    _flow = ref.read(labelFlowProvider.notifier);
    if (!widget.tracked) return;
    // Not while the tree builds: providers cannot change then.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _flow.set(this, LabelFlowStatus.unsaved);
    });
  }

  @override
  void dispose() {
    final flow = _flow;
    final owner = this;
    WidgetsBinding.instance.addPostFrameCallback((_) => flow.release(owner));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
