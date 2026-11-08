## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** UTC, come indicato dalla riga `Date for this review:` del brief (il brief non la riporta: valore non inventato)
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | integration_test/label_test.dart; aidlc/spaces/default/intents/261107-label-recognition/construction/code-generation/code-generation-plan.md > Step 17 | L'end-to-end è scritto ma non ha mai girato (l'emulatore si è bloccato), eppure il passo 17 è spuntato come fatto. Tutti gli scenari (retro con codice solo sul retro, "Salta", candidati, "Cerca online" senza rete, Lens annullato, file rovinato) non hanno quindi alcuna prova eseguita. Tutto il file è un unico `testWidgets` con 6 scenari: se fallisce, il merge in `main` resta bloccato e la diagnosi è lenta. Il riepilogo lo dichiara onestamente, ma il piano no. | Far girare l'e2e su un emulatore libero prima dell'approvazione o riportare il passo 17 come "non verificato" fino a quel momento. Valutare di dividere il test in uno scenario per `testWidgets`. Correggere in `unit-test-instructions.md` il comando e2e, che non ha i `--dart-define=FIREBASE_ENV=demo --dart-define=E2E=true` indicati nel riepilogo. | New |
| R-02 | Major | assets/wine_db/manifest.json, assets/wine_db/wines.jsonl.gz; tool/fixtures/off_wines_sample.csv; .github/workflows/promote.yml | La base che finisce nell'app è la base dell'estratto di prova: 45 vini scritti a mano con codici a barre inventati e sequenziali (es. 8001234567897, creatore `contributor-sample`). Il manifesto la presenta come `source: Open Food Facts`, `exportDate: 2026-11-07`, e l'app mostra "Dati da Open Food Facts, licenza ODbL" e la data nella schermata Informazioni. Con "deploy su merge" va sul canale di test interno, e nulla di automatico impedisce la promozione in produzione: c'è solo una casella nella checklist (§1-nonies). Sarebbero dati falsi attribuiti a Open Food Facts. | Aggiungere un controllo automatico prima della promozione (in `promote.yml` o `tool/check_release_build.sh`) che rifiuti un manifesto con meno di 5000 vini o marcato come estratto di prova. In alternativa, nel manifesto del campione scrivere `source: "sample"` e far sì che l'attribuzione non compaia per quel caso. | New |
| R-03 | Minor | lib/catalog/core/catalog_coordinator.dart > searchOnline, mappa `OnlineSearchStatus` | `disabled`, `limited` e `failed` danno tutti `rateLimited`. BR4.3 chiede il messaggio corrispondente a ogni caso: con Open Food Facts spento (build senza contatto) l'utente legge "non disponibile ora, riprova" come per un limite. | Aggiungere lo stato `unavailable` per `disabled`, oppure documentare che i casi condividono il messaggio. | New |
| R-04 | Minor | aidlc/spaces/default/intents/261107-label-recognition/construction/code-generation/code-generation-plan.md (Step 5, 7, 8); unit-test-instructions.md > Finti e dati di prova | Il piano approvato non è allineato al codice: `NetworkStatus` è diventato `CatalogNetworkStatus` / `ConnectivityCatalogNetworkStatus`, l'estratto è `off_wines_sample.csv` e non `.csv.gz`, i test dello strumento girano con `flutter test` e non `dart test`, serve `--allow-small-sample`. Le deviazioni stanno solo in `code-summary.md`. | Aggiornare il piano o aggiungere una nota di deviazione, così la tracciabilità ha una sola fonte. | New |
| R-05 | Minor | tool/check_lens_manifest.sh > rimozione dei commenti | Il filtro `<!--[^>]*-->` si ferma al primo `>` dentro un commento: un commento del manifesto con `>` farebbe leggere come attivo il testo che resta. Oggi non succede, ma il controllo di privacy di Lens è fragile. | Rimuovere i commenti con un'espressione che ammetta `>` al loro interno, oppure aggiungere un caso a `fixtures/lens_manifest/`. | New |

### Verifiche fatte

- **BR3.6 e BR3.2** (`lib/catalog/core/offline/text_score.dart`): peso uguale alle lettere; punteggio uguale a pesi trovati su pesi totali; tetto 0,60 sotto 2 parole distintive; bonus annata +0,05 con tetto 1,0, dato solo se almeno una parola è trovata; elenco delle parole comuni identico a BR3.6. Soglie in `LabelMatchThresholds` (0,85, 0,15, 0,45, 10, 0,70), con tolleranza 1e-9 sul distacco. Proposta sicura richiede ≥ 2 parole trovate. Conforme.
- **BR3.1** (`CatalogCoordinator.matchLabel`): codice offline, poi testo offline (sicuro), poi denominazione interna a 0,70 (mai sicura da sola), poi codice e testo su Open Food Facts, poi unione senza doppioni con vittoria dell'offline (BR3.3) e decisione finale. Conforme. Il testo resta a 4000 caratteri (4001 rifiutato).
- **BR6.1**: in `_external` l'assenza di rete restituisce `offline` prima di breaker e budget, quindi nessun `recordFailure` e nessun `off_suspended`. Un errore del controllo di rete vale "rete presente", come previsto. `lib/catalog/core` resta puro (`check_off_config.sh` OK).
- **BR1.4** (`TempLabelStore`, `LabelSessionController`): `hold` all'atto della preparazione di fronte e retro; `beforeRead`, `release` e `_deleteWhere` saltano i file in uso; `releaseCapture` li rilascia e cancella alla chiusura dello schermo, all'annullamento e quando la lettura è sostituita; `wipeAll` all'avvio. Il retro preparato dopo l'uscita dello schermo viene comunque rilasciato perché `_Capture` è lo stesso oggetto. Conforme.
- **Privacy di Lens**: conferma a ogni tocco (`LensConfirmSheet`); parte solo il fronte preparato (`capture.front`); il Dart rifiuta un JPEG con segmento APP1 (EXIF/XMP) o non JPEG; `FileProvider` con `exported=false`, `grantUriPermissions=true`, solo `cache-path label/`; il Kotlin accetta solo un file direttamente in `cacheDir/label` (percorso canonico); solo permesso di lettura; ripiego con `createChooser` che esclude Vinoozy; `<queries>` limitate al pacchetto Google e a `SEND image/*`. `check_lens_manifest.sh` e il suo test passano. Il tipo MIME dell'intent è `image/jpeg` (il piano dice `image/jpeg`, BR5.2 dice `image/*`): innocuo.
- **Limiti della base** (`tool/build_wine_db.dart`): 3 MB compressi e 30 MB non compressi (decisione del proprietario), controllati prima di scrivere, con limiti iniettabili per il test; plausibilità ≥ 5000 vini, `--allow-small-sample` solo per l'estratto.
- **Rete nei test**: i test del catalogo e della ricerca usano `MockClient`; nessun `HttpClient` reale in `test/`. L'e2e usa un client finto.
- **Soglie di copertura**: `ci.yml` aggiunge solo commenti, i controlli di cartella 80% di `lib/catalog/` e `lib/label/` sono invariati, `check_coverage.sh` non è modificato.
- **Lingua**: i nomi `label*` e `about*` dei tre file ARB (en, it, pt_BR) sono gli stessi in tutti e tre; codice e commenti in inglese.
- **Gestione degli errori ai confini**: `WineDbLoader` non lancia mai (motivi `missing`, `corruptGzip`, `noValidRows`, `unexpected`); `MethodChannelLensLauncher.open` e `LensIntentLauncher.open` restituiscono `failed`; il canale non risponde con eccezioni; il controller cattura tutto.

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| `flutter analyze --fatal-infos` | PASS, nessun problema | Il codice compila, anche `integration_test/label_test.dart`. |
| `flutter test test/catalog test/label test/app/about_screen_test.dart test/tool` | PASS, 635 test | I test mirati passano. |
| `tool/check_lens_manifest.sh` e `check_lens_manifest_test.sh` | OK | Provider non esportato, solo `cache/label/`, `<queries>` limitate. |
| `tool/check_off_config.sh`, `tool/check_label_imports.sh` | OK | `lib/catalog/core` puro, nessun Firestore in `lib/label`. |
| `flutter gen-l10n` | OK, nessun cambiamento nei file generati | I file generati sono allineati agli ARB. |
| e2e `integration_test/label_test.dart` | NON ESEGUITO (come richiesto) | Vedi il primo Major. |
| Copertura 89,15% / `lib/label/` 98,79% / `lib/catalog/` 98,16% | NON RIESEGUITA | Valori dichiarati dallo sviluppatore, non verificati da me. |
| Test nativi Gradle (`LensIntentLauncherTest`) | NON ESEGUITI | Dichiarati come passati (36 test), non verificati da me. |

### Summary

Il codice segue il piano e le regole BR1.4, BR3.1, BR3.2, BR3.6, BR6.1 e la privacy di Lens; i test mirati e i controlli statici passano. Restano due punti da pesare al gate: l'end-to-end non ha mai girato, e la base con dati inventati e attribuzione a Open Food Facts non ha nessuna protezione automatica prima della produzione. Con 2 Major e nessun Critical il verdetto, solo consultivo, è READY.
