# Struttura del codice

## Albero del repository (solo ciò che è scritto a mano)

```text
./
├── lib/                      app Flutter (203 file .dart)
│   ├── main.dart             runVinoozy, StartupErrorApp
│   ├── app/                  avvio, provider di servizio, tema, shell, Informazioni, footer, link esterni
│   ├── firebase/             firebase_env, opzioni demo/prod, FirestoreBootstrap
│   ├── account/              AccountGate, auth Google, profilo utente, eliminazione account, UI di accesso e profilo
│   ├── cellar/               dominio vini e bevute, repository Firestore, azioni, provider, UI della cantina
│   ├── sharing/              inviti, ruoli, cantina attiva, UI "Persone"
│   ├── dashboard/            calcolo puro del riepilogo, provider di sola lettura, UI
│   ├── sync/                 ledger locale, SyncWatcher, gateway, bus degli errori, banner
│   ├── label/                foto/testo dell'etichetta, Lens, ML Kit, flussi guidati
│   ├── catalog/              catalogo vini: interno, base offline, Open Food Facts, cache
│   ├── core/                 Clock, IdGenerator
│   ├── e2e/                  ganci compilati solo con E2E=true
│   └── l10n/                 ARB it/en/pt_BR (+ pt vuoto) e classi generate
├── packages/estimation/      libreria Dart pura (lib/src 34 file, test 22 file, benchmark)
├── android/                  progetto Gradle, Kotlin nativo (4 classi), risorse, test Robolectric
├── firestore.rules           regole di sicurezza
├── firestore.indexes.json    indice composito drinkingRecords, override members.inviteeEmail
├── firebase.json, .firebaserc
├── test/                     unit e widget test (154 file), test/rules (.mjs), test/web (.mjs)
├── integration_test/         E2E su emulatore Android + Emulator Suite (13 test + support/)
├── integration_test_perf/    misure di prestazioni sul telefono
├── test_driver/              driver per force-stop e perf
├── benchmark/                benchmark Dart di catalogo, cantina, dashboard
├── tool/                     script di gate CI, generatori di tabelle e base dati, fixture
├── docs/                     setup Firebase, checklist, privacy, cancellazione account (web), studio monetizzazione
├── distribution/google-play/ testi e immagini della scheda Play, data safety
└── .github/                  workflow ci, release, promote, pages, firebase-deploy; dependabot
```

## Organizzazione per moduli

Ogni modulo funzionale segue lo stesso schema:

| Strato | Cartella tipica | Regola |
|---|---|---|
| Dominio | `domain/` | Dart puro, nessun import Firebase o Flutter (es. `lib/cellar/domain/quantity_delta.dart`). |
| Dati | `data/` | Repository su `FirebaseFirestore`, percorsi in `lib/cellar/data/firestore_codec.dart`. |
| Servizi / azioni | file in radice del modulo | Combinano repository e regole di permesso (es. `CellarActions`). |
| Provider | `*_providers.dart` | Riverpod: i servizi creati all'avvio sono `_injected(...)` e sovrascritti in `AppBootstrap._wire`. |
| UI | `ui/` | `ConsumerWidget`/`ConsumerStatefulWidget`, chiavi `Key('...')` usate dai test. |
| Piattaforma | `platform/` (label, catalog) | Adattatori di plugin e canali nativi. |

## Classificazione dei file

| Categoria | Esempi |
|---|---|
| Model/Entity | `lib/cellar/domain/wine.dart`, `drinking_record.dart`, `cellar.dart`, `user_profile.dart`, `lib/sharing/domain/membership.dart`, `lib/sync/ledger/ledger_state.dart`, `packages/estimation/lib/src/models.dart` |
| Repository/DAO | `lib/cellar/data/wine_repository.dart`, `drinking_record_repository.dart`, `cellar_repository.dart`, `lib/account/data/user_repository.dart`, `lib/sharing/data/sharing_repository.dart`, `lib/account/deletion/firestore_deletion_backend.dart` |
| Service/UseCase | `lib/cellar/cellar_actions.dart`, `cellar_maintenance.dart`, `estimate_refresher.dart`, `estimates_migration.dart`, `lib/account/account_gate.dart`, `lib/account/deletion/account_deletion_runner.dart`, `lib/sync/sync_watcher.dart`, `lib/catalog/core/catalog_coordinator.dart` |
| Configuration | `lib/firebase/*.dart`, `lib/app/bootstrap.dart`, `lib/app/providers.dart`, `pubspec.yaml`, `l10n.yaml`, `analysis_options.yaml`, `firebase.json` |
| Middleware (cross-cutting) | `lib/app/error_reporter.dart`, `crashlytics_sink.dart`, `lib/sync/sync_error_bus.dart`, `lib/app/app_event_logger.dart` |
| Utility | `lib/cellar/data/server_or_cache.dart`, `retry.dart`, `lib/core/clock.dart`, `id_generator.dart`, `lib/cellar/domain/firestore_values.dart` |
| Controller/UI | `lib/**/ui/*.dart`, `lib/app/home_shell.dart`, `lib/app/vinoozy_app.dart` |
| Migration | `lib/cellar/data/match_key_backfill.dart`, `lib/cellar/estimates_migration.dart`, `WineRepository.migrateWine` |
| Test | `test/**`, `integration_test/**`, `packages/estimation/test/**`, `android/app/src/test/**`, `test/rules/**`, `test/web/**` |
| Static/Asset | `assets/branding/`, `assets/icon/`, `assets/wine_db/` (base generata), `docs/**/*.html`, `distribution/` |
| Generated | `lib/l10n/app_localizations*.dart`, `packages/estimation/lib/src/generated/*.g.dart`, `docs/account-deletion/app.bundle.js` |

## Pattern ricorrenti

- **Iniezione all'avvio**: provider che lanciano `UnimplementedError` finché
  `AppBootstrap` non li sovrascrive; i test usano gli stessi override con
  fake (`test/helpers/fakes.dart`, `firestore_mocks.dart`, `service_mocks.dart`).
- **Risultati sigillati**: `SaveOutcome` (`SaveAccepted`/`SaveFailure`),
  `AddResult`, `DrinkOutcome`, `GateState`, `DashboardState`, `LabelState`.
- **Ticket di generazione**: ogni scrittura porta un `WriteTicket`; un esito
  arrivato dopo un reset del ledger viene ignorato.
- **Valori sensibili**: ogni report d'errore passa la lista `sensitive`
  (uid, email, nomi dei vini) che `ErrorReporter` oscura.
- **Flag di compilazione**: `kIsE2EBuild`, `kIsPerfBuild` in
  `lib/firebase/firebase_env.dart`; i rami condizionati spariscono dalla
  release.
- **Tracciabilità**: commenti con ID dei requisiti (BR/NFR/FR delle unità
  U1-U8 e degli intent successivi); `tool/check_rule_ids.sh` verifica che ogni
  BR abbia un test con il suo ID nel nome.
- **Chiavi di widget stabili**: `about-version`, `brand-footer`,
  `profile-screen`, `home-nav-*`, `dashboard-*` sono il contratto dei test.

## Dove stanno le superfici dell'intent

| Superficie richiesta dallo studio | File |
|---|---|
| Configurazione ambiente e flag | `lib/firebase/firebase_env.dart`, `lib/firebase/options_demo.dart` (`demoProjectId`) |
| Riga versione / gesto nascosto | `lib/app/ui/about_screen.dart` (tile `about-version`) |
| Indicatore nel profilo | `lib/account/ui/profile_screen.dart` |
| Capacità e schede attive | `lib/cellar/data/wine_repository.dart`, `lib/cellar/cellar_actions.dart`, `lib/cellar/domain/quantity_delta.dart` |
| Listener condiviso | `lib/app/providers.dart` (`winesStreamProvider`), `lib/cellar/cellar_providers.dart` |
| Storico e cache | `lib/cellar/data/drinking_record_repository.dart`, `lib/cellar/data/server_or_cache.dart` |
| Sync e ledger | `lib/sync/sync_gateway.dart`, `lib/sync/ledger/local_ledger.dart`, `lib/sync/sync_watcher.dart` |
| Condivisione | `lib/sharing/data/sharing_repository.dart`, `lib/sharing/domain/invite_validator.dart` |
| Spazio annuncio | `lib/dashboard/ui/dashboard_screen.dart` (`DashboardContent`) |
| Regole | `firestore.rules`, test in `test/rules/` |
| Controllo di rilascio | `tool/check_release_build.sh` |
