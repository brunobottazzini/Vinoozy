import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/label/core/label_lookup_flow.dart';
import 'package:vinoozy/label/core/label_merge.dart';
import 'package:vinoozy/label/core/label_session.dart';

import '../label_harness.dart';

const _unreadable = LookupNotFound(NotFoundKind.unreadable);
const _noMatch = LookupNotFound(NotFoundKind.noMatch, name: 'Rosso');

void main() {
  group('BR1.13 reading and "Annulla"', () {
    test('BR1.13 begin shows the reading with a new id, the front running', () {
      final session = LabelSession();
      expect(session.state, isA<LabelIdle>());
      final first = session.begin();
      final second = session.begin();
      expect(second, greaterThan(first));
      final reading = session.state as LabelReadingState;
      expect(reading.readId, second);
      expect(reading.progress.of(ReadingStep.front), StepStatus.running);
      expect(reading.progress.of(ReadingStep.back), StepStatus.pending);
      expect(session.state.isFinal, isFalse);
    });

    test('BR1.13 Annulla moves to cancelled at once and ignores the late '
        'result', () {
      final session = LabelSession();
      final id = session.begin();
      session.cancel();
      expect(session.state, isA<LabelCancelledState>());
      expect(session.complete(id, _unreadable), isFalse);
      expect(session.state, isA<LabelCancelledState>());
      expect(session.state.isFinal, isFalse);
    });

    test('BR1.13 Annulla outside a reading changes nothing', () {
      final session = LabelSession()..cancel();
      expect(session.state, isA<LabelIdle>());
      final id = session.begin();
      session.complete(id, _unreadable);
      session.cancel();
      expect(session.state, isA<LabelNotFoundState>());
    });

    test('BR1.4 a new reading makes the old one stale', () {
      final session = LabelSession();
      final old = session.begin();
      final current = session.begin();
      expect(session.isCurrent(old), isFalse);
      expect(session.complete(old, _unreadable), isFalse);
      expect(session.complete(current, _unreadable), isTrue);
    });
  });

  group('BR1.1 "Ora il retro"', () {
    test('BR1.1 the front ready asks for the back; resume goes on reading', () {
      final session = LabelSession();
      final id = session.begin();
      expect(session.askBack(id), isTrue);
      expect((session.state as LabelBackPromptState).readId, id);
      expect(session.isCurrent(id), isTrue);
      const progress = ReadingProgress({ReadingStep.back: StepStatus.skipped});
      expect(session.resume(id, progress), isTrue);
      expect(
        (session.state as LabelReadingState).progress.of(ReadingStep.back),
        StepStatus.skipped,
      );
    });

    test('BR1.6 Annulla while waiting for the back cancels the reading', () {
      final session = LabelSession();
      final id = session.begin();
      session
        ..askBack(id)
        ..cancel();
      expect(session.state, isA<LabelCancelledState>());
      expect(session.askBack(id), isFalse);
      expect(session.resume(id, const ReadingProgress()), isFalse);
    });
  });

  group('BR3.2 BR3.4 BR3.5 outcomes', () {
    test('BR1.9 a sure proposal keeps the candidate, the alternatives and '
        'the back status', () {
      final session = LabelSession();
      final id = session.begin();
      session.complete(
        id,
        LookupSure(
          candidateOf('Barolo'),
          step: LabelMatchStep.offlineBarcode,
          alternatives: [candidateOf('Barbaresco')],
          notFound: _noMatch,
        ),
        backStatus: BackStatus.unreadable,
      );
      final state = session.state as LabelProposalState;
      expect(state.candidate.name, 'Barolo');
      expect(state.alternatives.single.name, 'Barbaresco');
      expect(state.backStatus, BackStatus.unreadable);
      expect(state.isFinal, isTrue);
    });

    test('BR3.5 "Non è questo" leads to the candidates, then "Nessuno di '
        'questi" to not found', () {
      final session = LabelSession();
      final id = session.begin();
      session.complete(
        id,
        LookupSure(
          candidateOf('Barolo'),
          step: LabelMatchStep.offlineText,
          alternatives: [candidateOf('Barbaresco')],
          notFound: _noMatch,
        ),
      );
      session.notThis();
      final list = session.state as LabelCandidatesState;
      expect(list.candidates.single.name, 'Barbaresco');
      expect(list.isFinal, isTrue);
      session.noneOfThese();
      final notFound = session.state as LabelNotFoundState;
      expect(notFound.kind, NotFoundKind.noMatch);
      expect(notFound.outcome.name, 'Rosso');
    });

    test('BR3.5 "Non è questo" without alternatives is not found', () {
      final session = LabelSession();
      final id = session.begin();
      session.complete(
        id,
        LookupSure(
          candidateOf('Barolo'),
          step: LabelMatchStep.onlineBarcode,
          notFound: const LookupNotFound(NotFoundKind.barcodeNotFound),
        ),
      );
      session.notThis();
      expect(
        (session.state as LabelNotFoundState).kind,
        NotFoundKind.barcodeNotFound,
      );
      session
        ..notThis()
        ..noneOfThese();
      expect(session.state, isA<LabelNotFoundState>(), reason: 'no change');
    });

    test('BR3.4 BR1.11 the three not-found kinds are final', () {
      final session = LabelSession();
      for (final kind in NotFoundKind.values) {
        final id = session.begin();
        session.complete(id, LookupNotFound(kind));
        expect((session.state as LabelNotFoundState).kind, kind);
        expect(session.state.isFinal, isTrue);
      }
      final id = session.begin();
      expect(session.fail(id), isTrue);
      expect(
        (session.state as LabelNotFoundState).kind,
        NotFoundKind.unreadable,
      );
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
      expect(session.complete(id, _unreadable), isFalse);
    });

    test('BR1.5 no camera app is final', () {
      final session = LabelSession()..cameraUnavailable();
      expect(session.state, isA<LabelCameraUnavailableState>());
      expect(session.state.isFinal, isTrue);
    });
  });
}
