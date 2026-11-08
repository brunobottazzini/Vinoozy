## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** 2026-11-08
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Minor | packages/estimation/lib/src/recognizer.dart > `findAlias` / `resolveWine` (ramo `nameMatch`) | `findAlias` conta anche gli alias deboli (toro, port, cava, rioja, napa…) quando cerca nel nome del vino. BR1.2 li limita al testo dell'etichetta, mentre nel nome scritto a mano un "Toro" o un "Cava" può diventare una denominazione e dare la sua finestra. L'effetto è attenuato: il tipo scelto filtra le denominazioni incompatibili e la confidenza resta bassa. Il commento nel codice dice che è voluto ("a name typed by the user is never a label text"), ma `rules.md` non lo dice. | Allineare `rules.md` o il commento di BR3.1 alla scelta, oppure far contare gli alias deboli solo nel campo denominazione dell'utente e non nel nome. Si può decidere in Build and Test. | New |
| R-02 | Minor | lib/cellar/ui/edit_wine_screen.dart (scostamento dichiarato: nessuna barra, nessun "Incolla da Lens") | Il modulo di modifica non ha "Pulisci" né "Incolla da Lens". Lo scostamento è motivato (il modulo di modifica non riceve mai un testo) e ha il campo denominazione, il livello e l'anteprima. Resta una differenza rispetto a `interaction-spec.md`. | Segnare lo scostamento in modo esplicito nel riepilogo che il proprietario approva, come correzione dell'interaction-spec. | New |
| R-03 | Minor | aidlc/spaces/default/intents/261108-label-autofill-windows/construction/code-generation/code-summary.md > "Fuori dalle regole sui file" | Il file di prova con heredoc in `packages/estimation/.scratch/` è una violazione di processo dichiarata dallo sviluppatore. La cartella è stata rimossa e `git status` non la mostra. | Nessuna azione sul codice; basta che resti nel registro. | New |
| R-04 | Minor | tool/check_appellations_release.sh e `packages/estimation/lib/src/generated/appellations_manifest.json` | Il controllo di rilascio legge solo il manifesto (`source`, `appellationCount`). Il file `.g.dart` che l'app usa ha una sua costante `generatedAppellationsSource`. Se i due file si separano, per esempio con un manifesto rigenerato a mano, il controllo non se ne accorge. Oggi sono coerenti (entrambi `sample`) e un test pacchetto verifica la provenienza del file generato. | In Build and Test, quando si rigenera la tabella con l'export reale, far verificare dal controllo anche che `generatedAppellationsSource` nel `.g.dart` coincida con il manifesto. | New |

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| `flutter analyze` | No issues found | Pulito. |
| `dart test` in `packages/estimation` | 1797 passati | Coincide con il riepilogo. |
| `flutter test` su `estimates_migration_test.dart` e `level_override_test.dart` | 32 passati | La migrazione e il livello con la correzione funzionano. |
| Soglie di copertura in `ci.yml` | 80% progetto e per cartella, 90% pacchetto, invariate | Nessuna soglia abbassata. Il diff di `ci.yml` aggiunge solo controlli. |
| ARB it / en / pt_BR | 490 chiavi ciascuno | Completi. `app_pt.arb` è un file minimo preesistente. |
| e2e, emulatori, regole | Non eseguiti (richiesto così) | Accetto i numeri dello sviluppatore: 215/216 con 1 salto motivato, e2e 2/2 e 1/1. |

### Verifiche per punto

- **BR3.1 / BR3.2 (`resolveWine`)**: la precedenza è come da regola. Vengono prima il catalogo esterno, poi la denominazione dell'utente, poi quella del catalogo e quella del nome, poi il vitigno, il tipo e la riga generica. `_hasType` salta una denominazione che non ammette il tipo scelto. Senza tipo, `_grapeTypeIn` sceglie tra i tipi multipli. La qualifica si usa solo se il tipo coincide con quello principale della riga.
- **BR4.1 / BR4.2 (livello)**: `WineLevel.apply` moltiplica gli scarti con interi (50/60/60 e 125/130/140), arrotonda per eccesso e ordina `start ≤ peak ≤ end` con `end ≥ start+1`. `aging` non moltiplica una qualifica già usata, `everyday` sì. Una finestra del catalogo non cambia.
- **BR4.4 / FR5.6**: `effectiveWindow` mette `end = override` e ferma `start` e `peak` con `min`.
- **BR4.5 (6 punti)**: `saveNewWine`, `saveEdit` (con `before.windowOverride`), `ensureEstimates`, `EstimateRefresher` (`refine` con `override`), `recomputeAdjustment` e `WineEstimator.displayed` passano tutti `level` e `override`. `WineFactsInput.ofWine` porta il livello.
- **Migrazione (BR3.9, NFR4.8a)**: un vino per volta con `setEstimate`, solo con `canEdit`, solo i vini con base `internalRules` e `tablesVersion` diversa. Un rifiuto del server (`rejected`) la ferma con un solo `estimates_migration_failed`. Il contatore persiste in `SharedPreferences` e il tetto è 3 avvii. Offline le scritture vanno in coda. Una finestra del catalogo non viene toccata.
- **Appunti (BR2.6, NFR3.1, NFR3.7)**: `clipTimestamp` legge solo `primaryClipDescription` e restituisce `null` sotto API 26. `shouldPaste` controlla ora, MIME e `clip.timestamp > openedAt`, e scarta il timestamp già consumato. Il timestamp è segnato come consumato prima della lettura del testo. Il testo si legge solo in `_paste` e in `LensAutoPaste.take`. Il logger registra solo l'esito (`lens_open (route)`, `estimates_migrated (n, ms)`). L'incolla parte sia al ritorno in primo piano sia al focus della finestra.
- **Regole Firestore (BR5)**: in aggiornamento `level`, `windowOverride` e `country` sono controllati solo con `changed.hasAny`. `setAt == request.time` e `endYear` tra 1900 e 2200 sono richiesti. L'elenco delle 14 qualifiche coincide con l'enum `Qualifier`. `denominationKey` ≤ 60 caratteri (il più lungo generato è 37) e `tablesVersion` intero. I test di compatibilità usano `requiresRules: level-override`, presente in `RULES_FEATURES` di `promote.yml`.
- **Tabella di prova bloccata dalla produzione**: il manifesto ha `source: sample` e 1415 voci. `check_appellations_release.sh` fallisce apposta (minimo 1500 e la fonte attesa). `promote.yml` lo esegue sul manifesto del commit `build-<versionCode>` prima di Google Play. Il test del controllo gira in `ci.yml`.
- **Valori enologici (campione)**: Rioja crianza 2/5/10, reserva 4/8/15, gran reserva 6/12/25; Porto vintage 15/30/60; Sauternes 5/15/40; Beaujolais 0/1/3; Mosel Kabinett, Spätlese e Auslese. Sono plausibili e hanno la motivazione accanto alle righe, come chiede la correzione di `project.md`.
- **Codice in inglese e gestione degli errori**: nessuna violazione trovata. Gli errori ai confini (`clipTimestamp`, `readText`, `PreferencesMigrationAttemptStore`) sono catturati e non lanciano.

### Summary

Nessun difetto critico o maggiore: BR1–BR6 sono rispettate nel codice, la privacy degli appunti è corretta, le regole Firestore e la compatibilità sono coerenti e la tabella di prova non può arrivare in produzione. Restano quattro rilievi minori, soprattutto la documentazione degli scostamenti e il controllo di rilascio che legge solo il manifesto.
