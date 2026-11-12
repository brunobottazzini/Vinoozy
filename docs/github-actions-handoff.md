# Handoff per risolvere i fallimenti GitHub Actions di Vinoozy

Verifica dell'11 novembre 2026. Destinatario: agent incaricato della correzione. Repository: `brunobottazzini/Vinoozy`, ramo `main`, commit esaminato `abe4fc0ebfd37dc2dc61ab1b415ba34471fc3a96`. Orari indicati in Europe/Rome.

**Il blocco attuale del deployment `play-internal` è la configurazione incompleta delle credenziali Actions.** La CI più recente passa tutti e sette i job, ma `release.yml` parte comunque senza i segreti necessari e fallisce nello step `Versions`, prima della build e del caricamento su Google Play. Esiste anche un fallimento E2E precedente, apparentemente intermittente, da trattare separatamente.

## Esecuzioni e stato verificato

| Esecuzione | Esito | Evidenza rilevante |
|---|---|---|
| [CI 16 sul commit abe4fc0](https://github.com/brunobottazzini/Vinoozy/actions/runs/42985865810) | Successo | Verdi `format`, `secrets`, `analyze`, `unit`, `estimation`, `rules`, `e2e`. |
| [Release 15 sul commit abe4fc0](https://github.com/brunobottazzini/Vinoozy/actions/runs/42991975646/job/130426792995) | Fallimento | 11 novembre, ore 10:04:17; job `internal`, step 7 `Versions`, exit code 1. Deployment `7706008188`. |
| [Release 9 sul commit 0edfe06](https://github.com/brunobottazzini/Vinoozy/actions/runs/42885179246/job/130071500203) | Fallimento | 10 novembre, ore 20:26:26; stesso step e stessi quattro input vuoti. Deployment `7692021683`. |
| [CI 15 sul commit c777f03](https://github.com/brunobottazzini/Vinoozy/actions/runs/42985498196/job/130405570268) | Fallimento E2E | Eccezione Flutter durante il test di riavvio con scritture offline. Gli altri sei job passano. |
| [CI 14 sul commit c01e95d](https://github.com/brunobottazzini/Vinoozy/actions/runs/42971511583/job/130367402129) | Fallimento secrets | Due rilevamenti nella copia pubblicata sul ramo `gh-pages`; il controllo è verde nelle CI 15 e 16 dopo la modifica `c777f03`. |

La [pagina deployment indicata dal proprietario](https://github.com/brunobottazzini/Vinoozy/deployments/play-internal) corrisponde ai due job `internal` falliti sopra. Le release marcate `skipped` dopo una CI fallita sono il comportamento previsto dalla condizione di `release.yml`.

## Causa del blocco attuale

La lettura dei soli metadati con GitHub CLI ha restituito `[]` per tutti e quattro gli elenchi:

```sh
gh secret list --repo brunobottazzini/Vinoozy --env play-internal --json name,updatedAt
gh secret list --repo brunobottazzini/Vinoozy --json name,updatedAt
gh variable list --repo brunobottazzini/Vinoozy --env play-internal --json name
gh variable list --repo brunobottazzini/Vinoozy --json name
```

Mancano quindi i segreti sia nell'ambiente `play-internal` sia a livello di repository. Manca anche la variabile `GOOGLE_SERVER_CLIENT_ID`. Non sono stati letti valori di credenziali.

Nel [workflow di rilascio, righe 56–77](https://github.com/brunobottazzini/Vinoozy/blob/abe4fc0ebfd37dc2dc61ab1b415ba34471fc3a96/.github/workflows/release.yml#L56), lo step `Write secret files` riceve questi input, tutti **vuoti** nei log di entrambe le release:

```text
GOOGLE_SERVICES_B64:
PROD_DEFINES_B64:
KEYSTORE_B64:
PLAY_SA_JSON:
```

La scrittura riesce comunque, creando file vuoti: la decodifica Base64 dell'input vuoto non segnala errore e `printf` scrive zero byte. Lo step successivo esegue `code="$(tool/play_api.sh next-version-code)"`.

[tool/play_api.sh, righe 19–25](https://github.com/brunobottazzini/Vinoozy/blob/abe4fc0ebfd37dc2dc61ab1b415ba34471fc3a96/tool/play_api.sh#L19) controlla soltanto che `PLAY_SA_JSON_FILE` sia valorizzata, poi autentica `gcloud` con quel file vuoto. L'attivazione dell'account redirige sia stdout sia stderr a `/dev/null`: questo spiega l'assenza di un messaggio utile prima dell'exit code 1. Il log non conserva il messaggio originale di `gcloud`; il file delle credenziali vuoto è però accertato dagli input e dalla configurazione.

GitHub documenta che un segreto non configurato viene risolto come stringa vuota: [Using secrets in GitHub Actions](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets#using-secrets-in-a-workflow).

Nelle due esecuzioni esaminate **build AAB, pubblicazione dell'artefatto, upload al test interno e tag sono tutti saltati**. Non ci sono ancora evidenze per attribuire il blocco a Gradle, firma, permessi Play o collisioni del versionCode. `crashlytics-symbols` è anch'esso saltato e richiede inoltre una configurazione facoltativa separata.

Il documento locale `docs/play-console-handoff.md`, sezione 3, conferma la scelta operativa precedente: upload e promozione manuali finché i segreti di `release.yml` e `promote.yml` non vengono configurati.

## Lavoro richiesto per il rilascio automatico

1. Completare la configurazione di `play-internal` secondo [docs/firebase-setup.md, sezione 5](https://github.com/brunobottazzini/Vinoozy/blob/abe4fc0ebfd37dc2dc61ab1b415ba34471fc3a96/docs/firebase-setup.md#5-google-play-app-e-i-due-account-di-servizio), usando le credenziali valide e la chiave di caricamento già associata all'app. Il solo aggiornamento del codice non può fornire queste credenziali.

   | Nome | Contenuto richiesto |
   |---|---|
   | `PLAY_INTERNAL_SA_JSON` | JSON originale dell'account di servizio autorizzato al test interno di `com.vinoozy.app`, senza codifica Base64. |
   | `ANDROID_UPLOAD_KEYSTORE_B64` | Keystore della chiave di caricamento esistente, codificato Base64. |
   | `ANDROID_UPLOAD_KEYSTORE_PASSWORD` | Password del keystore. |
   | `ANDROID_UPLOAD_KEY_ALIAS` | Alias della chiave di caricamento. |
   | `ANDROID_UPLOAD_KEY_PASSWORD` | Password della chiave. |
   | `FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64` | `google-services.json` di produzione, codificato Base64. |
   | `FIREBASE_PROD_DEFINES_JSON_B64` | JSON dei dart-defines di produzione, codificato Base64. |

   Configurare inoltre la variabile Actions `GOOGLE_SERVER_CLIENT_ID` con l'OAuth web client ID corretto. `ADMOB_APP_ID` ha già un fallback nel progetto ed è separato dal blocco attuale. La configurazione WIF del deploy Firestore usa un altro ambiente e non sostituisce l'autenticazione Play prevista dallo script.

2. Aggiungere a `release.yml` una verifica iniziale degli input obbligatori, prima di scrivere file o iniziare la build. In caso di valore mancante, riportare il **nome** del segreto e l'ambiente da configurare. Verificare file non vuoti, decodifica Base64 e struttura essenziale dei JSON senza stamparne il contenuto. Conservare la pulizia finale con `if: always()`.
3. Migliorare `tool/play_api.sh`: controllare esistenza, dimensione e formato del file dell'account di servizio; segnalare chiaramente un fallimento dell'autenticazione senza esporre chiave o token. Mantenere stdout riservato al solo valore restituito da `next-version-code`.
4. Verificare la gestione degli errori con fixture senza credenziali reali: input assente, file vuoto, JSON/Base64 non valido e autenticazione fallita. Usare uno stub di `gcloud` per controllare l'errore senza chiamare Google Play. Eseguire `actionlint` dopo modifiche ai workflow.
5. Dopo la configurazione, validare il calcolo del versionCode e una nuova release sul test interno. Una modifica al codice richiede una nuova CI sul commit corretto: il rerun di una vecchia release continua a fare checkout del commit della CI originaria. Il rerun della release esistente è adatto solo a una correzione della configurazione esterna.

Credenziali e chiavi devono essere fornite attraverso i segreti Actions, senza inserirle nel repository, nei log o nell'handoff. Questa verifica non ha modificato impostazioni GitHub, credenziali o workflow, né avviato nuovi rilasci.

## Fallimento E2E da investigare separatamente

Nella CI 15 fallisce `integration_test/u1_skeleton_test.dart:241`, test `8. after a restart the queued changes are still there`. Il caso disabilita la rete, aggiunge un vino, termina Firestore e riavvia l'app per verificare il recupero della scrittura accodata.

Il [log del job](https://github.com/brunobottazzini/Vinoozy/actions/runs/42985498196/job/130405570268) riporta:

```text
setState() or markNeedsBuild() called during build.
Widget da ricostruire: CellarSwitcher
Widget in costruzione: CellarScreen
CellarScreen.build (package:vinoozy/cellar/ui/cellar_screen.dart:103:24)
ConsumerStatefulElement.watch / ProviderElement._notifyListeners
```

Segue `A SemanticsHandle was active at the end of the test`; la suite termina con 30 test passati, 1 fallito e 3 saltati. L'emulatore aveva avviato i test: il retry del workflow, riservato al mancato avvio dell'emulatore, correttamente non scatta.

La CI 16 passa e il confronto `git diff c777f03 abe4fc0 --stat` contiene **solo `docs/play-console-handoff.md`**. Il codice applicativo e i test sono uguali tra la CI fallita e quella riuscita: questo suggerisce un difetto intermittente e non dimostra che sia stato corretto.

Punti da esaminare: `lib/cellar/ui/cellar_screen.dart:103` legge `activeCellarProvider`; `lib/sharing/ui/cellar_switcher.dart:23` osserva `accessibleCellarsProvider`; `lib/sharing/sharing_providers.dart:249` costruisce `ActiveCellarNotifier` e registra i listener. Investigare notifiche sincrone dei provider durante build e ripristino, insieme al teardown/riavvio in `integration_test/e2e_helpers.dart`. La causa precisa richiede riproduzione; lo stack individua il percorso, non ancora la correzione.

Per riprodurre, usare gli emulatori Firebase Auth/Firestore/Functions e Android API 34 come nel job `e2e` di `.github/workflows/ci.yml`, Flutter `3.47.9`, quindi il comando `flutter test integration_test/u1_skeleton_test.dart --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true`. Verificare anche l'intera suite dopo la correzione, perché il caso può dipendere dallo stato dei test precedenti.

## Problema storico già superato

Nella CI 14 Gitleaks segnalava due valori nella copia `account-deletion/firebase-config.js` del commit `cdfac5c` sul ramo `gh-pages`. Il commit `c777f03` limita la scansione alla storia di `HEAD` tramite `--log-opts=HEAD`; i job `secrets` delle CI 15 e 16 passano. Questo fallimento storico è distinto sia dalle credenziali Play mancanti sia dall'eccezione E2E e non richiede di disabilitare la scansione dei segreti.

## Controllo esteso di tutti i workflow

Il controllo esteso dell'11 novembre comprende tutte le **38 esecuzioni disponibili**: 22 fallite, 10 saltate e 6 riuscite. Sono tutte terminate; nessuna risulta in corso o in attesa. I fallimenti comprendono vecchi commit e problemi diversi, quindi il totale non rappresenta 22 problemi attuali.

| Workflow | Esecuzioni | Ultimo esito disponibile | Interpretazione |
|---|---:|---|---|
| `ci` | 16 | [Successo](https://github.com/brunobottazzini/Vinoozy/actions/runs/42985865810) | Tutti i sette job verdi; resta da investigare l'intermittenza E2E descritta sopra. |
| `release` | 15 | [Fallimento](https://github.com/brunobottazzini/Vinoozy/actions/runs/42991975646) | Due fallimenti per credenziali mancanti, tre vecchi fallimenti prima dell'avvio dei job e dieci esecuzioni saltate dopo CI non riuscite. |
| `promote` | 3 | [Fallimento del 9 novembre](https://github.com/brunobottazzini/Vinoozy/actions/runs/42595342598) | Tutte e tre le esecuzioni sono precedenti alla correzione del workflow; nessuna promozione manuale successiva. |
| `firebase-deploy` | 1 | [Successo](https://github.com/brunobottazzini/Vinoozy/actions/runs/42829140441) | Nessun fallimento registrato. |
| `pages` | 1 | [Successo](https://github.com/brunobottazzini/Vinoozy/actions/runs/42880753932) | Pubblicazione riuscita. |
| Pages automatico | 2 | [Successo](https://github.com/brunobottazzini/Vinoozy/actions/runs/42880826417) | Entrambe le distribuzioni riuscite. |
| `functions-deploy` | 0 | Mai eseguito | Workflow attivo e manuale; nessun esito operativo da valutare. |

### Promozione in produzione ancora da configurare

Le tre vecchie esecuzioni di `promote` e le prime tre di `release` non hanno job. GitHub CLI le segnala come probabili problemi del file workflow. Nei file di quei commit `runner.temp` compare in `jobs.<job_id>.env`, dove il contesto `runner` non è consentito secondo la [tabella ufficiale dei contesti GitHub](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts#context-availability). Il [commit 1248449](https://github.com/brunobottazzini/Vinoozy/commit/1248449c651af6546d7171e718329e425217f39f) sposta i percorsi nello step usando `$RUNNER_TEMP` e `$GITHUB_ENV`. La CI attuale valida i workflow con `actionlint`, ma `promote` non ha ancora una successiva esecuzione manuale riuscita.

La lettura dell'elenco ambienti restituisce soltanto `firebase-prod`, `github-pages`, `github-pages-publish` e `play-internal`: **`play-production` non esiste**. La richiesta dei suoi segreti restituisce 404; anche l'elenco dei segreti del repository è vuoto. Manca quindi la configurazione prevista da `promote.yml`, incluso `PLAY_PRODUCTION_SA_JSON`.

Per una futura promozione automatica, predisporre `play-production` con le protezioni e l'approvazione del proprietario già previste in `docs/firebase-setup.md`, oltre alle credenziali Play appropriate. Questa è preparazione ancora necessaria, distinta dai vecchi errori di sintassi; il controllo non ha creato ambienti né avviato promozioni.

### Altri errori presenti nelle vecchie CI

| Area ed evidenza | Errore osservato | Stato rispetto alla CI attuale |
|---|---|---|
| [Test Android nativi, CI 3](https://github.com/brunobottazzini/Vinoozy/actions/runs/42595346078/job/129086514109) | `./gradlew: No such file or directory`, exit 127. Lo stesso step falliva anche nelle CI 1 e 2. | Il wrapper è ora presente; lo step nativo passa nella CI 16. |
| [Test web, CI 4](https://github.com/brunobottazzini/Vinoozy/actions/runs/42825033789/job/129860029499) | Il caso con configurazione placeholder attendeva il messaggio di errore per 30 secondi; il messaggio restava nascosto. | Il test ora fornisce esplicitamente una configurazione fittizia; `test:web` passa nella CI 16. |
| [Controllo configurazione web, CI 6](https://github.com/brunobottazzini/Vinoozy/actions/runs/42828178771/job/129870889440) | Il test pretendeva API key e app ID vuoti nel file reale, già compilato; due aspettative fallivano. | Il controllo usa ora `tool/fixtures/web_config/placeholders.js` e passa nella CI 16. |
| [Test Functions, CI 8](https://github.com/brunobottazzini/Vinoozy/actions/runs/42841762486/job/129918561365) | Timeout Mocha di 2000 ms nel `beforeEach` di `reserveAdSlot`, file `ad_slots.test.js`. | Il commit `3d67a90` introduce un timeout di 15 secondi in `functions/.mocharc.json`; il job `rules` passa nelle CI successive. |
| [Altri E2E, CI 9](https://github.com/brunobottazzini/Vinoozy/actions/runs/42852183437/job/129955548306) | Tre casi falliti: data dello Champagne attesa `[2027, 3]`, ottenuta `[2027, 1]`; `Bad state: No element` nel Cruscotto con 500 vini; timeout nel test di cancellazione account. | Non ricompaiono nell'ultima CI verde. Se tornano, usare questi log come casi distinti dall'eccezione di build della CI 15. |

Le priorità restano completare le credenziali del test interno e riprodurre l'eccezione E2E della CI 15. La promozione automatica in produzione richiede la preparazione separata sopra; Firebase e Pages non mostrano altri blocchi nelle esecuzioni disponibili.

## Criteri di completamento per il prossimo agent

- Gli input mancanti producono un errore leggibile prima della creazione dei file; stdout dello script Play resta utilizzabile come numero.
- Tutti i segreti obbligatori e la variabile OAuth sono presenti nello scope corretto; autenticazione e lettura dei track Play funzionano.
- Una release del commit validato dalla CI genera l'AAB firmato, lo carica sul test interno e crea il relativo tag `build-<versionCode>`. Il job di simboli facoltativo può restare saltato finché non viene configurato.
- Il difetto E2E riceve una riproduzione e una correzione verificata; un singolo passaggio verde non è sufficiente a dichiararlo risolto.

La copia locale contiene già modifiche del proprietario a `distribution/google-play/data-safety.csv`, `docs/play-console-handoff.md`, `docs/release-checklist.md`, oltre a file non tracciati. Preservarle. In questo intervento è stato aggiunto soltanto questo handoff; non sono state applicate correzioni funzionali.
