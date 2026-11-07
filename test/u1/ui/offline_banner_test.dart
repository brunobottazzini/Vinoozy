import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';
import 'package:vinoozy/sync/sync_status.dart';
import 'package:vinoozy/sync/ui/offline_banner.dart';

import '../../helpers/ui_harness.dart';
import 'cellar_screen_test.dart' show CellarFixture, cellarSnapshot;

void main() {
  const serverClean = SnapshotMeta(hasPendingWrites: false, isFromCache: false);
  const cachePending = SnapshotMeta(hasPendingWrites: true, isFromCache: true);
  const serverPending = SnapshotMeta(
    hasPendingWrites: true,
    isFromCache: false,
  );

  late CellarFixture fixture;

  setUp(() => fixture = CellarFixture());

  Future<void> pump(WidgetTester tester) => pumpScreen(
    tester,
    const Scaffold(body: OfflineBanner(cellarId: 'user-a')),
    overrides: fixture.overrides,
  );

  Future<void> wines(WidgetTester tester, SnapshotMeta meta) async {
    fixture.winesStream.add(WinesSnapshot(wines: const [], meta: meta));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('hidden while everything is synced', (tester) async {
    await pump(tester);
    fixture.cellar.add(cellarSnapshot());
    await wines(tester, serverClean);

    expect(find.byKey(const Key('offline-banner')), findsNothing);
  });

  testWidgets('"Sincronizzazione in corso" with pending writes online', (
    tester,
  ) async {
    await pump(tester);
    await wines(tester, serverClean);
    await wines(tester, serverPending);

    expect(find.text('Sincronizzazione in corso'), findsOneWidget);
  });

  testWidgets('offline at once on a later cache snapshot, not on the first', (
    tester,
  ) async {
    await pump(tester);
    await wines(tester, cachePending);
    expect(find.text('Offline - sincronizzazione in attesa'), findsNothing);
    expect(find.text('Sincronizzazione in corso'), findsOneWidget);

    await wines(tester, cachePending);
    expect(find.text('Offline - sincronizzazione in attesa'), findsOneWidget);
  });

  testWidgets('back online triggers SyncWatcher and the banner goes', (
    tester,
  ) async {
    await pump(tester);
    await wines(tester, serverClean);
    await wines(tester, cachePending);
    await wines(tester, serverClean);

    verify(() => fixture.watcher.trigger()).called(1);
    expect(find.byKey(const Key('offline-banner')), findsNothing);
  });

  testWidgets('the banner is a live region for TalkBack', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpScreen(
      tester,
      const Scaffold(body: SyncStateBanner(state: SyncState.offline)),
    );

    final node = tester.getSemantics(find.byKey(const Key('offline-banner')));
    expect(node.label, 'Offline - sincronizzazione in attesa');
    expect(node.flagsCollection.isLiveRegion, isTrue);
    semantics.dispose();
  });

  for (final state in [SyncState.syncing, SyncState.offline]) {
    accessibilityMatrix(
      'OfflineBanner ${state.name}',
      () => Scaffold(body: SyncStateBanner(state: state)),
    );
  }

  test('fixture streams are independent per test', () {
    expect(fixture.cellar, isA<StreamController<CellarSnapshot>>());
  });
}
