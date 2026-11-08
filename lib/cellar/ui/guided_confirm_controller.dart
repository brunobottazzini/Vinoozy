import 'dart:async';

import 'package:estimation/estimation.dart';
import 'package:flutter/foundation.dart';

import '../../label/core/guided_session.dart';

/// The guided check of one add form (label-autofill-windows D11, BR7.10-
/// BR7.21): it keeps the memory of the form, applies the pure transitions
/// of `guided_session.dart` and hands their effects to the form
/// ([onApply]). It lives in the `State` of the form, so a rotation or the
/// background keep the guide at the same question (BR7.19), and nothing of
/// it is ever saved, logged or restored by Android (FR7.9).
class GuidedConfirmController extends ChangeNotifier {
  GuidedConfirmController({
    required this.onApply,
    required this.contextOf,
    this.noticeDuration = const Duration(seconds: 2),
  });

  /// Applies an effect to the form: fill a field, tick "no vintage",
  /// announce, close.
  final void Function(GuidedEffect effect) onApply;

  /// The year, type and country of the form now.
  final GuidedContext Function() contextOf;

  /// How long the notice of a "No" stays (BR7.12).
  final Duration noticeDuration;

  GuidedMemory _memory = GuidedMemory.empty;
  Timer? _noticeTimer;
  bool _disposed = false;

  GuidedMemory get memory => _memory;

  /// The open guide, or `null`.
  GuidedSession? get session => _memory.session;

  bool get isOpen => _memory.session != null;

  /// The questions left for [empty] fields of the form (BR7.17): the
  /// "Guided check" button shows while this is not empty.
  List<KeyField> pending(Set<KeyField> empty) =>
      _memory.pendingQuestions(empty);

  /// A new text (BR7.18): an open guide closes, keeping what was confirmed;
  /// the new analysis replaces the old one.
  void receiveText(LabelAnalysis analysis) {
    final wasOpen = isOpen;
    _cancelNotice();
    _memory = _memory.withText(analysis);
    if (wasOpen) onApply(const ClosedEffect(completed: false));
    _notify();
  }

  /// Opens the guide on the questions left for [empty] fields (BR7.10,
  /// BR7.17); false when there is none.
  bool open(Set<KeyField> empty) {
    final questions = pending(empty);
    if (questions.isEmpty) return false;
    _memory = openGuide(_memory, questions, contextOf());
    _notify();
    return isOpen;
  }

  /// Applies [action] to the open guide.
  void dispatch(GuidedAction action) {
    final step = reduceGuide(_memory, action, contextOf());
    final noticeBefore = _memory.session?.notice;
    _memory = step.memory;
    final notice = _memory.session?.notice;
    if (notice == null) {
      _cancelNotice();
    } else if (!identical(notice, noticeBefore)) {
      _startNotice();
    }
    for (final effect in step.effects) {
      onApply(effect);
    }
    _notify();
  }

  /// [field] written by hand with the guide closed: never asked again
  /// (BR7.19).
  void markManual(KeyField field) {
    final next = _memory.markManual(field);
    if (identical(next, _memory)) return;
    _memory = next;
    _notify();
  }

  /// "Clear" (BR7.21): the guide closes and the memory empties.
  void clear() {
    _cancelNotice();
    _memory = GuidedMemory.empty;
    _notify();
  }

  void _startNotice() {
    _cancelNotice();
    _noticeTimer = Timer(noticeDuration, () {
      if (_disposed) return;
      dispatch(const NoticeExpiredAction());
    });
  }

  void _cancelNotice() {
    _noticeTimer?.cancel();
    _noticeTimer = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelNotice();
    super.dispose();
  }
}
