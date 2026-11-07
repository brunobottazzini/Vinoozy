import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/core/label_lookup_flow.dart';
import 'package:vinoozy/label/core/label_session.dart';

import '../label_harness.dart';

void main() {
  group('BR1.13 reading and "Annulla"', () {
    test('BR1.13 begin shows the reading with a new id', () {
      final session = LabelSession();
      expect(session.state, isA<LabelIdle>());
      final first = session.begin();
      final second = session.begin();
      expect(second, greaterThan(first));
      expect((session.state as LabelReadingState).readId, second);
      expect(session.state.isFinal, isFalse);
    });

    test('BR1.13 Annulla moves to cancelled at once and ignores the late '
        'result', () {
      final session = LabelSession();
      final id = session.begin();
      session.cancel();
      expect(session.state, isA<LabelCancelledState>());
      expect(session.complete(id, const LookupUnreadable()), isFalse);
      expect(session.state, isA<LabelCancelledState>());
      expect(session.state.isFinal, isFalse);
    });

    test('BR1.13 Annulla outside a reading changes nothing', () {
      final session = LabelSession()..cancel();
      expect(session.state, isA<LabelIdle>());
      final id = session.begin();
      session.complete(id, const LookupUnreadable());
      session.cancel();
      expect(session.state, isA<LabelUnreadableState>());
    });

    test('BR1.4 a new reading makes the old one stale', () {
      final session = LabelSession();
      final old = session.begin();
      final current = session.begin();
      expect(session.isCurrent(old), isFalse);
      expect(session.complete(old, const LookupUnreadable()), isFalse);
      expect(session.complete(current, const LookupUnreadable()), isTrue);
    });
  });

  group('BR1.9 BR1.11 outcomes', () {
    test('BR1.9 a proposal keeps the candidate and the offline flag', () {
      final session = LabelSession();
      final id = session.begin();
      session.complete(
        id,
        LookupProposal(candidateOf('Barolo'), offline: true),
      );
      final state = session.state as LabelProposalState;
      expect(state.candidate.name, 'Barolo');
      expect(state.offline, isTrue);
      expect(state.isFinal, isTrue);
    });

    test('BR1.11 incomplete, barcode only and unreadable are final', () {
      final session = LabelSession();
      var id = session.begin();
      session.complete(
        id,
        const LookupIncomplete(name: 'Rosso', vintage: 2020),
      );
      final incomplete = session.state as LabelIncompleteState;
      expect((incomplete.name, incomplete.vintage), ('Rosso', 2020));
      expect(incomplete.isFinal, isTrue);

      id = session.begin();
      session.complete(
        id,
        const LookupBarcodeOnly(testEan13, needsNetwork: true),
      );
      final only = session.state as LabelBarcodeOnlyState;
      expect((only.barcode, only.needsNetwork), (testEan13, true));
      expect(only.isFinal, isTrue);

      id = session.begin();
      expect(session.fail(id), isTrue);
      expect(session.state, isA<LabelUnreadableState>());
      expect(session.state.isFinal, isTrue);
    });
  });

  group('BR1.5 picker outcomes', () {
    test('BR1.5 a denied access is final and stales any reading', () {
      final session = LabelSession();
      final id = session.begin();
      session.denied(PhotoOrigin.gallery);
      expect(
        (session.state as LabelPermissionDeniedState).origin,
        PhotoOrigin.gallery,
      );
      expect(session.state.isFinal, isTrue);
      expect(session.complete(id, const LookupUnreadable()), isFalse);
    });

    test('BR1.5 no camera app is final', () {
      final session = LabelSession()..cameraUnavailable();
      expect(session.state, isA<LabelCameraUnavailableState>());
      expect(session.state.isFinal, isTrue);
    });
  });
}
