// RecordReconciler (NFR6.6; BR1.12, BR1.14): entries in shared_preferences
// under cellar.pending.<uid>, idempotent, at most 50, expired after 7 days,
// removed on success or refusal, in memory without shared_preferences.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/cellar/data/record_reconciler.dart';

import '../../helpers/fakes.dart';
import '../../helpers/firestore_mocks.dart';

void main() {
  late FakeClock clock;
  late RecordingErrorSink sink;
  late RecordReconciler reconciler;

  PendingOp op(
    String wineId, {
    PendingOpKind kind = PendingOpKind.reapplyAdjustment,
    DateTime? at,
  }) => PendingOp(
    kind: kind,
    cellarId: 'user-a',
    wineId: wineId,
    createdAt: at ?? clock.now(),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    clock = FakeClock(DateTime(2026, 11, 6, 12));
    sink = RecordingErrorSink();
    reconciler = RecordReconciler(
      preferences: SharedPreferences.getInstance,
      clock: clock,
      reporter: recordingReporter(sink),
    );
  });

  test(
    'NFR6.6 entries are stored as JSON under cellar.pending.<uid>',
    () async {
      await reconciler.add(
        'user-a',
        op('w1', kind: PendingOpKind.purgeRecords),
      );

      final prefs = await SharedPreferences.getInstance();
      final stored =
          jsonDecode(prefs.getString('cellar.pending.user-a')!) as List;
      expect(stored.single, {
        'op': 'purgeRecords',
        'cellarId': 'user-a',
        'wineId': 'w1',
        'createdAt': clock.now().millisecondsSinceEpoch,
      });
      expect(await reconciler.pending('user-b'), isEmpty);
    },
  );

  test('NFR6.6 the same operation on the same wine is kept once', () async {
    await reconciler.add('user-a', op('w1'));
    await reconciler.add('user-a', op('w1'));
    await reconciler.add('user-a', op('w1', kind: PendingOpKind.purgeRecords));

    expect(await reconciler.pending('user-a'), hasLength(2));
  });

  test('NFR6.6 at most 50 entries: the oldest is dropped', () async {
    for (var i = 0; i < 51; i++) {
      await reconciler.add('user-a', op('w$i'));
    }

    final pending = await reconciler.pending('user-a');
    expect(pending, hasLength(50));
    expect(pending.first.wineId, 'w1');
  });

  test('NFR6.6 an entry older than 7 days is dropped', () async {
    await reconciler.add('user-a', op('old', at: DateTime(2026, 10, 30, 11)));
    await reconciler.add('user-a', op('new'));

    expect((await reconciler.pending('user-a')).map((o) => o.wineId), ['new']);
  });

  test(
    'BR1.12 BR1.14 run: success and refusal remove, a transient error keeps',
    () async {
      await reconciler.add('user-a', op('ok'));
      await reconciler.add(
        'user-a',
        op('refused', kind: PendingOpKind.purgeRecords),
      );
      await reconciler.add('user-a', op('offline'));

      final summary = await reconciler.run('user-a', (pending) async {
        switch (pending.wineId) {
          case 'refused':
            throw firestoreError('permission-denied');
          case 'offline':
            throw firestoreError('unavailable');
        }
      });

      expect(summary.done, 1);
      expect(summary.refused, 1);
      expect(summary.kept, 1);
      expect((await reconciler.pending('user-a')).single.wineId, 'offline');
      expect(sink.reasons, ['cellar_reconcile_failed']);
    },
  );

  test('an unexpected error keeps the entry and is reported', () async {
    await reconciler.add('user-a', op('w1'));

    await reconciler.run('user-a', (_) async => throw StateError('bug'));

    expect(await reconciler.pending('user-a'), hasLength(1));
    expect(sink.reasons, ['cellar_reconcile_failed']);
  });

  test('NFR6.6 without shared_preferences the entries stay in memory, reported once', () async {
    final memoryOnly = RecordReconciler(
      preferences: () async => throw StateError('no storage'),
      clock: clock,
      reporter: recordingReporter(sink),
    );

    await memoryOnly.add('user-a', op('w1'));
    await memoryOnly.add('user-a', op('w2'));

    expect(await memoryOnly.pending('user-a'), hasLength(2));
    expect(sink.reasons, ['cellar_reconcile_failed']);
  });

  test('damaged stored data is ignored, not thrown', () async {
    SharedPreferences.setMockInitialValues({
      'cellar.pending.user-a': '[{"op":"burn"},{"op":"purgeRecords"},7]',
    });
    expect(await reconciler.pending('user-a'), isEmpty);

    SharedPreferences.setMockInitialValues({
      'cellar.pending.user-a': '{not json',
    });
    expect(await reconciler.pending('user-a'), isEmpty);
    expect(PendingOp.fromJson('x'), isNull);
  });
}
