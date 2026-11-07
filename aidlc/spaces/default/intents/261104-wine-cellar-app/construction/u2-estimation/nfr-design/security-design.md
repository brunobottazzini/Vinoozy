# Security Design — u2-estimation

Fonti: `security-requirements.md` (NFR4.1–NFR4.4, NFR8.1), `tech-stack-decisions.md`, `functional-spec.md` e `rules.md` di u2 (BR1.6, BR4.4, BR4.5), `contract-summary.md` (C2), riepilogo confermato in `nfr-design-questions.md`.

U2 è una libreria pura: niente rete, disco, cloud o dati personali. La sicurezza qui significa tre cose: superficie minima (nessuna dipendenza), ingressi controllati ai confini, e comportamento prevedibile (stessi ingressi, stesso risultato). Accesso, autenticazione e regole del cloud non riguardano U2 (sono di U1 e U7).

## 1. Superficie minima (NFR4.1)

- `packages/estimation/pubspec.yaml` non ha dipendenze di produzione. Di sviluppo: `test`, `lints`, `benchmark_harness`, `coverage`.
- Import ammessi in `lib/`: solo `dart:core` (implicito), `dart:collection`, `dart:math` e file interni del pacchetto.
- **Controllo:** `tool/check_estimation_purity.sh`, eseguito nel job `unit` della CI. Fallisce se:
  1. la sezione `dependencies:` del `pubspec.yaml` contiene una voce diversa dall'SDK;
  2. un file di `lib/` contiene un `import` diverso da `dart:collection`, `dart:math` o un percorso relativo/`package:estimation/`;
  3. compare una delle parole vietate del §3.

## 2. Ingressi controllati (NFR4.2, NFR4.3, BR4.5, BR1.6)

Le funzioni di C2 controllano gli ingressi all'inizio, in un unico modulo (`src/validation.dart`), prima di ogni calcolo. `needsRefinement` non ha ingressi da controllare: restituisce `window.source == internalRules` come dice C2 e non lancia mai errori (BR1.5); i test lo verificano anche con finestre incoerenti.

| Funzione | Ingresso non valido | Codice |
|---|---|---|
| `estimateWindow`, `pairingsFor` | nome vuoto dopo la pulizia degli spazi | `emptyName` |
| `estimateWindow`, `pairingsFor` | annata o anno di riferimento fuori da 1900–2200 | `vintageOutOfRange` / `referenceYearOutOfRange` |
| `estimateWindow`, `pairingsFor` | annata e anno di riferimento entrambi assenti | `missingReferenceYear` |
| `statusOf` | finestra con inizio > picco o picco > fine (NFR4.2) | `invalidWindow` |

- **Errore unico:** `EstimationArgumentError`, sottoclasse di `ArgumentError`, con un campo `code` (enum `EstimationErrorCode`) e il nome dell'argomento. U4 decide cosa mostrare leggendo `code`, mai il testo del messaggio. Il messaggio è in inglese e serve solo ai log.
- **Nessun'altra eccezione:** il calcolo non usa divisioni per variabili che possono essere zero, non accede a liste per indice senza controllo, e gli enum sconosciuti in ingresso (per esempio una `wineType` salvata come stringa non riconosciuta) diventano "assente" invece di generare un errore (BR1.7).
- **Profilo esterno incoerente:** un `ExternalProfile` con anni invertiti o fuori dai limiti viene ignorato in silenzio per la finestra (BR1.6). Non è un errore: la stima usa le regole interne e `needsRefinement` resta vero.
- **Testi esterni:** gli abbinamenti di C1 passano così come sono in `items`, troncati ai primi 5 (NFR4.3). U2 non li interpreta, non li concatena a codice e non li usa come chiave; U4 li mostra come testo semplice.
- **Normalizzazione dei nomi:** il confronto degli alias lavora su una copia del nome in minuscolo, senza accenti e senza apostrofi, limitata a 60 caratteri come C3. Il nome originale non viene modificato né restituito.

```dart
// Illustrative only
enum EstimationErrorCode { emptyName, vintageOutOfRange, referenceYearOutOfRange, missingReferenceYear, invalidWindow }

class EstimationArgumentError extends ArgumentError {
  EstimationArgumentError(this.code, String name) : super.value(null, name, code.name);
  final EstimationErrorCode code;
}
```

## 3. Purezza e determinismo (NFR4.4, BR4.4)

- **Parole vietate in `lib/`** (controllate dallo script del §1 con `grep -E` per parola intera, sulle righe senza commento iniziale `//`): `DateTime\.now`, `\bRandom\b`, `\bStopwatch\b`, `\bPlatform\b`, `\bIsolate\b`, `\bZone\b`, `\bprint\(`. I nomi del pacchetto non usano queste parole, quindi non ci sono falsi positivi da gestire; se servisse un nome simile, si sceglie un altro nome invece di aggiungere eccezioni.
- **Stato globale:** a primo livello sono ammessi solo `const` e `final`, e nelle classi `static` solo con `const` o `final`. Lo script cerca le righe che iniziano a colonna 0 con `var ` o `late `, e le righe con `static` senza `const`/`final`. È un controllo semplice e voluto: `dart format` mette sempre le dichiarazioni di primo livello a colonna 0. Un caso che sfugge al grep viene comunque preso dal test di determinismo.
- **Strutture costruite una sola volta (NFR2.2):** le tabelle sono letterali `const`, costruiti dal compilatore e mai a runtime: `window.dart` e `pairings.dart` le leggono direttamente tramite una mappa `const` per chiave. L'unica struttura costruita a runtime è l'indice degli alias, creato dalla funzione `buildAliasIndex()` in `recognizer.dart`. Due controlli: lo script verifica che `buildAliasIndex(` compaia in `lib/` solo nella sua definizione e nell'inizializzazione `final aliasIndex = buildAliasIndex();` (esattamente 2 occorrenze); il benchmark misura anche il costo di `buildAliasIndex()` da solo e fallisce se una stima singola costa più di un decimo della costruzione dell'indice, cosa che accadrebbe se l'indice venisse ricostruito a ogni chiamata.
- **Tipi immutabili:** tutti i tipi pubblici hanno solo campi `final` e costruttori `const` dove possibile. Le liste che vengono dalle tabelle sono già `const` e si restituiscono così come sono, senza copia. Solo le liste costruite a runtime (i primi 5 abbinamenti di C1) passano da `List.unmodifiable`.
- **Test di determinismo:** per ogni funzione, 1000 ingressi generati con `Random(42)` nei test (fuori da `lib/`), ogni funzione chiamata due volte; i risultati devono essere uguali (`==` con uguaglianza per valore sui tipi).

## 4. Dati personali (NFR8.1)

- I tipi di C2 (`WineFacts`, `ExternalProfile`, `DrinkingWindow`, `WineStatus`, `Pairings`) non hanno campi per email, uid, posizione o dispositivo.
- **Test:** un test elenca i campi di `WineFacts` tramite il suo `toString`/costruttore e verifica che coincidano con quelli di `entities.md`. Un campo nuovo fa fallire il test e obbliga a una revisione.

## 5. Copertura e gate in CI (NFR7.1, NFR7.4, NFR7.5)

| Passo nel job `unit` | Comando | Fallisce se |
|---|---|---|
| Purezza | `tool/check_estimation_purity.sh` | §1 o §3 violati |
| Formattazione | `dart format --output=none --set-exit-if-changed packages/estimation` | file non formattati |
| Analisi | `dart analyze --fatal-infos packages/estimation` | qualsiasi segnalazione |
| Test e copertura | `dart test --coverage=coverage` nel pacchetto, poi `format_coverage --lcov`, poi `tool/check_coverage.sh 90` | test rossi o copertura < 90% |
| Benchmark | `dart run benchmark/estimation_benchmark.dart` | soglie di `logical-components.md` superate: lo script stampa le misure e termina con `exit(1)` |

Il job è quello condiviso definito da U1: U2 aggiunge passi e non modifica quelli esistenti.

## Rischi residui

| Rischio | Gravità | Mitigazione |
|---|---|---|
| Una correzione delle tabelle introduce una finestra incoerente | Bassa | Test generati da ogni riga (NFR7.2) e controllo inizio ≤ picco ≤ fine |
| Una dipendenza futura introduce rete o disco | Bassa | Script di purezza in CI |
| Testi esterni di C1 con contenuto strano | Bassa | U2 non li interpreta; U4 li mostra come testo semplice |
