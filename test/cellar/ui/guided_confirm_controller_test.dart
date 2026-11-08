// The controller of the guided check in the add form (label-autofill-
// windows D11, BR7.12, BR7.17, BR7.18, BR7.21, NFR3.8): effects to the
// form, the 2-second notice, a new text, "Clear", fields written by hand.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/ui/guided_confirm_controller.dart';
import 'package:vinoozy/label/core/guided_session.dart';

const _it01 =
    "CASCINA CASTLET\nBarbera d'Asti Superiore\n14,5% vol  75 cl\n2019";
const _empty = {
  KeyField.denomination,
  KeyField.producer,
  KeyField.name,
  KeyField.vintage,
};

void main() {
  late List<GuidedEffect> effects;
  late int notifications;

  GuidedConfirmController controller() {
    effects = [];
    notifications = 0;
    final c = GuidedConfirmController(
      onApply: effects.add,
      contextOf: () => const GuidedContext(currentYear: 2026),
    )..addListener(() => notifications++);
    addTearDown(c.dispose);
    return c;
  }

  LabelAnalysis analysis(String text) =>
      analyzeLabelText(text, currentYear: 2026);

  test('opens on the questions left and applies the answers', () {
    final c = controller()..receiveText(analysis(_it01));
    expect(c.isOpen, isFalse);
    expect(c.pending(_empty), [KeyField.producer, KeyField.name]);
    expect(c.open(_empty), isTrue);
    expect(c.session!.field, KeyField.producer);
    c.dispatch(const YesAction());
    expect(effects.single, isA<FillEffect>());
    expect(c.session!.field, KeyField.name);
    expect(notifications, greaterThanOrEqualTo(2));
    expect(c.open(_empty), isTrue, reason: 'already open, still open');
  });

  test('no question: nothing opens', () {
    final c = controller()..receiveText(analysis('Barolo Vietti\n2019'));
    expect(c.open(_empty), isFalse);
    expect(c.isOpen, isFalse);
  });

  testWidgets('the notice of a "No" goes away after 2 seconds (BR7.12)', (
    tester,
  ) async {
    final c = controller()
      ..receiveText(analysis(_it01))
      ..open(_empty)
      ..dispatch(const SkipAction())
      ..dispatch(const NoAction());
    expect(c.session!.notice, isNotNull);
    await tester.pump(const Duration(milliseconds: 1900));
    expect(c.session!.notice, isNotNull);
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.session!.notice, isNull);
  });

  test('a new text closes the guide open and keeps the answers (BR7.18)', () {
    final c = controller()
      ..receiveText(analysis(_it01))
      ..open(_empty)
      ..dispatch(const YesAction());
    effects.clear();
    c.receiveText(analysis(_it01));
    expect(c.isOpen, isFalse);
    expect(effects.single, isA<ClosedEffect>());
    expect((effects.single as ClosedEffect).completed, isFalse);
    expect(c.memory.answers, contains(KeyField.producer));
    expect(c.pending(_empty), [KeyField.name]);
  });

  testWidgets('"Clear" empties the memory (BR7.21)', (tester) async {
    final c = controller()
      ..receiveText(analysis(_it01))
      ..open(_empty)
      ..dispatch(const NoAction())
      ..clear();
    expect(c.isOpen, isFalse);
    expect(c.memory.answers, isEmpty);
    expect(c.memory.rejected, isEmpty);
    expect(c.memory.analysis, isNull);
    await tester.pump(const Duration(seconds: 3));
    expect(c.isOpen, isFalse);
  });

  test('a field written by hand with the guide closed is not asked', () {
    final c = controller()..receiveText(analysis(_it01));
    final before = notifications;
    c.markManual(KeyField.producer);
    expect(notifications, before + 1);
    c.markManual(KeyField.producer);
    expect(notifications, before + 1, reason: 'no change, no notification');
    expect(c.pending(_empty), [KeyField.name]);
  });

  testWidgets('a notice timer after dispose does nothing', (tester) async {
    final applied = <GuidedEffect>[];
    final c =
        GuidedConfirmController(
            onApply: applied.add,
            contextOf: () => const GuidedContext(currentYear: 2026),
          )
          ..receiveText(analysis(_it01))
          ..open(_empty)
          ..dispatch(const NoAction());
    final before = applied.length;
    c.dispose();
    await tester.pump(const Duration(seconds: 3));
    expect(applied, hasLength(before));
  });
}
