# Tech Stack Decisions — u1-skeleton

Fonti: `team.md` (Testing Posture, Deployment, Code Style), `feasibility-assessment.md` e `constraint-register.md` (Ideation), `decisions.md` (ADR-001…ADR-004), `contract-summary.md`, risposte in `nfr-requirements-questions.md`.

Le versioni non sono fissate qui: alla generazione del codice si usa l'ultima versione stabile di ogni pacchetto, compatibile con le altre, e `pubspec.lock` va nel repository.

## Scelte

| Area | Scelta | Motivo | Alternative scartate |
|------|--------|--------|----------------------|
| Linguaggio e framework | Dart, Flutter stabile | Deciso nelle pratiche (Q1); una sola base di codice per Android e, in futuro, iPhone | Kotlin nativo (solo Android) |
| Autenticazione | `firebase_auth` + `google_sign_in` | BR1.1; Firebase scelto in Feasibility | Accesso con email e password (più attrito) |
| Dati | `cloud_firestore` con memoria offline persistente e cache illimitata | Q1 del design funzionale; NFR6.1 | Database locale con sincronizzazione nostra (scartato in Functional Design) |
| Protezione del progetto | `firebase_app_check` (Play Integrity; provider di debug solo nelle build di debug su telefono reale) | Q1; NFR4.6 | Nessuna protezione (Q1, scartata) |
| Crash | `firebase_crashlytics`, anonimo | Q2; NFR8.2 | Nessuna segnalazione (Q2, scartata) |
| Stato dell'app | `flutter_riverpod` | Ascoltatori unici e condivisi (NFR5.1, NFR2.4), facile da sostituire nei test | `provider` (meno controllo su ciclo di vita), `bloc` (più codice per uno scheletro) |
| Preferenze locali | `shared_preferences` per `lastUid`, il registro delle modifiche in attesa e il giornale delle creazioni | NFR4.9, NFR6.3; dati piccoli, cancellati con il reset (NFR4.10) | Documento in Firestore (non leggibile prima dell'accesso) |
| Connessione | `connectivity_plus`, solo per il primo accesso | NFR2.5 | — |
| Lingue | `flutter_localizations` + `intl` con file ARB (it, en, pt-BR; riserva en) | BR5.1; testi fuori dal codice (team.md) | Stringhe nel codice (vietato) |
| Test | `flutter_test`, `mocktail`, `integration_test`; `@firebase/rules-unit-testing` per le regole | team.md: test-after, 80% senza esclusioni, end-to-end su emulatore Android | — |
| Emulatori | Firebase Emulator Suite (Auth, Firestore) in locale e in CI, con il progetto dimostrativo `demo-vinoozy` (configurazione nel repository, nessuna credenziale reale) | team.md (Q9); NFR4.7 | Progetto di test separato (costi e segreti in più) |
| Qualità | `dart format`, `flutter analyze` con `flutter_lints` | team.md (Code Style) | — |
| CI | GitHub Actions: formattazione, analisi, test con copertura, test delle regole, end-to-end su emulatore Android, build AAB firmato e invio al test interno | team.md (Way of Working, Deployment), NFR7 | — |

## Struttura del codice

```
lib/
  app/            # MaterialApp, temi, lingue, radice con l'ascoltatore degli errori
  account/        # AuthGate, SignInScreen, servizio di accesso e cambio account
  cellar/         # CellarScreen, AddWineScreen, repository dei vini e della cantina
  sync/           # stato della sincronizzazione, flusso degli errori
  l10n/           # file ARB
firestore.rules   # regole di sicurezza (U1: users e cantina del proprietario)
test/             # unit test e test dei widget
integration_test/ # test end-to-end sull'emulatore
```

Codice, identificatori e commenti in inglese (project.md).

## Copertura (NFR7)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR7.1 | Copertura delle righe ≥ 80% su tutto `lib/`, senza esclusioni, compresi i file di traduzione generati. Poiché `flutter test --coverage` conta solo i file importati dai test, uno script genera prima dei test `test/coverage_helper_test.dart`, che importa ogni file di `lib/`; così un file senza test conta come 0%. | `flutter test --coverage` in CI; il job fallisce sotto la soglia. |
| NFR7.2 | Le regole di sicurezza hanno test per ogni caso di NFR4.2–NFR4.5 e NFR4.10. | Job di CI con l'emulatore Firestore. |
| NFR7.3 | Il test end-to-end dello scheletro (accesso, aggiunta offline, sincronizzazione, secondo utente che non vede i dati, cambio di account bloccato) gira su emulatore Android in CI e blocca il merge se fallisce. | Job di CI. |
