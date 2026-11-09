# Riepilogo di Build and Test — profili di stile e classificazione automatica

## Fonti

- `construction/code-generation/code-generation-plan.md` (piano approvato, 12 passi, `## Testing Contract`)
- `construction/code-generation/unit-test-instructions.md`
- `construction/code-generation/code-summary.md`
- `construction/nfr-requirements/` (performance, security, reliability, scalability, observability, tech-stack)
- `test-results.md` (questa cartella)

## Esito

**Build e test verdi; resta non dimostrato solo l'end-to-end.** Dopo il loop-back 1 la base si genera in 1 min 25 s (identica a prima) e la migrazione di 500 vini ha il suo test.
- Build, formattazione e analisi pulite.
- App: 2638 test verdi, copertura del progetto 89,30%.
- Pacchetto della stima: 2011 test verdi, copertura 98,10%.
- Regole Firestore: 215 + 30 verdi, 2 saltati come prima.
- Benchmark e controlli di rilascio OK.
- Non dimostrato: **end-to-end**, non caricati in questo ambiente (servizio VM via adb).

## Tipi di test

- Unit test del pacchetto: profili, mappa, classificatore, finestre in mesi, Revisione 60, campione di 100 vini.
- Unit e widget test dell'app: migrazione, repository, widget dello Stile, cruscotto, generatori, matrice di accessibilità.
- Integrazione: regole Firestore sull'emulatore e test di compatibilità tra versioni.
- Benchmark del pacchetto.
- End-to-end sull'emulatore Android: scritti, non eseguiti qui.

Istruzioni: `build-instructions.md` e `integration-test-instructions.md`. Con la strategia Standard non servono istruzioni separate di prestazioni e sicurezza: le prestazioni sono nel benchmark e la sicurezza nei test delle regole.

## Copertura attesa

Il lavoro non ha Units. Il progetto deve restare ≥ 80% senza esclusioni e il pacchetto `estimation` ≥ 90%.

## Target Verification Matrix

| Target ID | Source | Expected | Actual | Evidence | Owning Stage | Verdict |
|---|---|---|---|---|---|---|
| TC-SUITE | Testing Contract, scope floor | suite esistente verde | 2638 + 2011 + 245 verdi | `test-results.md` § Riepilogo | build-and-test | Met |
| TC-CI | Testing Contract (CI before merge) | test in CI prima del merge | — | il piano salta CI Pipeline (`ci-pipeline — SKIP`) | — | N/A (the plan runs no CI Pipeline) |
| TEAM-FORMAT | team.md Code Style | `dart format` e `flutter analyze` puliti | 0 cambiati, nessun problema | `test-results.md` | build-and-test | Met |
| NFR4.1-PRJ | nfr-requirements/reliability NFR4.1; team.md | copertura progetto ≥ 80% senza esclusioni | 89,30% | `check_coverage.sh 80`, uscita 0 | build-and-test | Met |
| NFR4.1-PKG | reliability NFR4.1 | pacchetto ≥ 90% | 98,10% | `check_coverage.sh 90`, uscita 0 | build-and-test | Met |
| NFR4.2 | reliability NFR4.2 | 24 profili, 5946 combinazioni, Revisione 60 | tutti verdi | `profile_map_test`, `revision60_test`, `build_profile_map_test` | build-and-test | Met |
| NFR4.3 | reliability NFR4.3 | Tipologia ≥ 95%, Livello ≥ 85%, base ≥ 84% e = manifest | 97,7%, 98,9%, 84,22% | `classification_sample_test`, `build_wine_db_classify_test` | build-and-test | Met |
| NFR4.4 | reliability NFR4.4 | migrazione in transazione, campi `user` invariati | test verdi | `style_migration_test`, `estimates_migration_test` | build-and-test | Met |
| NFR4.5-SUITE | reliability NFR4.5 | suite esistente verde | verde | come TC-SUITE | build-and-test | Met |
| NFR4.5-E2E | reliability NFR4.5; team.md End-to-end | e2e del modulo con Stile e data verde | non caricato | `test-results.md` § End-to-end | build-and-test | Unverified |
| NFR4.6–NFR4.9 | reliability | ripresa, stima mai bloccata, data non valida rifiutata, offline e integrità | test verdi | `style_migration_test`, `classifier_test`, `style_widgets_test` | build-and-test | Met |
| NFR2.1–NFR2.3 | security | documenti di oggi validi, regole sui campi nuovi, compatibilità | 30/30 e 215/0 | `style_profiles.rules.test.mjs`, `compat/` | build-and-test | Met |
| NFR2.4 | security | `RULES_FEATURES` con `style-profiles`; regole pubblicate solo con OK | voce presente; regole correnti non ancora pubblicate | `promote.yml`, checklist 1-undecies | build-and-test | Met |
| NFR2.5–NFR2.6 | security | nessun dato personale nuovo; nessuna rete per stimare | test verdi | test del logger, test con rete spenta | build-and-test | Met |
| NFR3.1-CI | performance NFR3.1 | `classifyWine` ≤ 5 ms per vino | 0,018 ms | benchmark | build-and-test | Met |
| NFR3.1-PHONE | performance NFR3.1 | ≤ 50 ms per vino sul telefono, ridisegno compreso | non misurato | — (nessuna fase successiva lo possiede) | build-and-test | Unverified |
| NFR3.2 | performance NFR3.2 | 500 stime ≤ 10 ms | 6,80 ms | benchmark | build-and-test | Met |
| NFR3.3 | performance NFR3.3 | generazione della base ≤ 2 min | 1 min 25 s, base identica | `test-results.md` § Riepilogo (`time`, `cmp`) | build-and-test | Met |
| NFR3.4 | performance NFR3.4 | migrazione di 200 vini ≤ 1 s di calcolo | < 1 s | `estimates_migration_test.dart` "NFR3.4 200 wines" | build-and-test | Met |
| NFR3.5 | performance NFR3.5 | base ≤ 3 MB compressa, ≤ 30 MB | OK | `check_wine_db_release.sh` | build-and-test | Met |
| NFR3.6 | performance NFR3.6 | fixture solo nei test | fixture in `packages/estimation/test/fixtures/` | struttura del pacchetto | build-and-test | Met |
| NFR3.7 | scalability NFR3.7 | 500 vini: migrazione ≤ 2,5 s; ricalcolo ≤ 10 ms | ricalcolo 6,75 ms; migrazione di 500 < 2,5 s | benchmark; `estimates_migration_test.dart` "NFR3.7 500 wines" | build-and-test | Met |
| NFR3.8 | scalability NFR3.8 | classificazione lineare | 0,018 ms per vino costante | benchmark | build-and-test | Met |
| NFR5.1–NFR5.2 | tech-stack | inglese nel codice, 3 ARB, matrice di accessibilità | test verdi | `style_widgets_test`, test delle localizzazioni | build-and-test | Met |
| NFR6.1–NFR6.3 | observability | quota nel manifest e in Informazioni, eventi senza nomi, fonti nel codice | test verdi | manifest, `about_screen` test, logger | build-and-test | Met |

## Pronti per

- **Build**: sì.
- **Test**: sì per unit, widget, regole e benchmark; no per gli e2e in questo ambiente.
- **Rilascio**: non ancora. Prima vanno:
  - pubblicate le regole correnti, con l'OK del proprietario;
  - eseguiti gli e2e;
  - fatto il commit.

## Limiti e cose aperte

- E2E: da eseguire da un terminale del proprietario (`integration-test-instructions.md`).
- La modifica di un vino con riscontro viene salvata in due update, che insieme non sono atomici. Il margine delle regole è stretto.
- Prima dello store, dai lavori precedenti: Storico e "Annulla", avviso `setState` del `CellarSwitcher`, `OFF_CONTACT`, scheda "Sicurezza dei dati", repository pubblico.
