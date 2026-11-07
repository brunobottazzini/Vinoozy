## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** 2026-11-06
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u6-label-recognition/infrastructure-design/cicd-pipeline.md > §1 Modifiche a `ci.yml` | Il codice Kotlin `LabelImagePreparer` e `SharedImageReceiver` è l'unico punto che controlla dimensione (20 MB), formato, pixel e `content://` delle immagini condivise (`logical-components.md`, NFR4.4, NFR4.5), ma la pipeline non lo collauda da nessuna parte. La copertura di `lib/label/` misura solo Dart. Il test e2e passa dal selettore o da una sorgente finta, non da un intent di condivisione. Rifiuti ostili, avvio a freddo da condivisione e `onNewIntent` restano solo nella prova manuale di §1-sexies. | Aggiungere un passo di CI per il codice nativo (per esempio unit test JVM di `LabelImagePreparer` su immagini troppo grandi, formato errato e HEIC con API sotto 28; oppure uno scatto di intent con `adb shell am start -a android.intent.action.SEND` nel job `e2e`). In alternativa, dichiarare per iscritto che la copertura è solo manuale e collegare NFR4.4 e NFR4.5 a una voce di checklist per ogni caso di scarto. | New |
| R-02 | Major | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u6-label-recognition/infrastructure-design/cicd-pipeline.md > §1 riga `e2e` (`gen_label_fixtures.dart`) | Il passo `dart run tool/gen_label_fixtures.dart` deve produrre immagini con testo leggibile da ML Kit, ma `dart run` non ha `dart:ui` né font. Il documento non dice come si disegna il testo. Non dice nemmeno come i file arrivano all'emulatore: `integration_test/fixtures/` non è nell'app, e dichiararli come asset in `pubspec.yaml` li metterebbe nella build di rilascio e nel conteggio dei +15 MB (NFR2.3). Non è scelta nemmeno la sorgente che sostituisce il selettore di sistema. | Specificare come si generano le immagini (libreria Dart pura o file versionati in `tool/fixtures/`). Specificare come arrivano sul dispositivo (`adb push` in `cacheDir` o asset solo di test) e la sorgente finta che le consegna a `LabelImagePreparer`. Verificare che non finiscano nella build di rilascio. | New |
| R-03 | Minor | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u6-label-recognition/infrastructure-design/cicd-pipeline.md > §1 riga `check_release_build.sh` | Il passo "legge il manifest unito" non dice da dove. Il manifest dentro l'AAB è binario (protobuf) e non si cerca con `grep`, come invece fa oggi lo script con `libapp.so`. Manca anche un controllo positivo come quello dei marcatori E2E/PERF: un controllo che non vede mai nulla passerebbe sempre. | Indicare la fonte (`bundletool dump manifest` oppure `build/app/intermediates/merged_manifests/release/`) e aggiungere un controllo che fallisca su un manifest di prova con `CAMERA`, sul modello di `check_rule_ids_test.sh`. | New |
| R-04 | Minor | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u6-label-recognition/infrastructure-design/monitoring-design.md > §1 riga "Dimensione dell'app" | Il limite di +15 MB è verificato solo a mano dopo la pubblicazione sul test interno, quando l'AAB è già pubblicato. Nessun controllo di CI lo blocca prima del merge, mentre per le altre soglie esistono controlli in CI. | Aggiungere in `check_release_build.sh` una soglia sulla dimensione dell'AAB arm64 rispetto a un valore di riferimento versionato, oppure annotare che il controllo è solo a posteriori. | New |
| R-05 | Minor | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u6-label-recognition/infrastructure-design/cicd-pipeline.md > Tempi stimati | "Circa 1 minuto in più" per `unit` è senza misura, ma `unit` ha `timeout-minutes: 15` e già fa due build `appbundle`, cinque controlli di copertura e tre benchmark. ML Kit aggiunge librerie native pesanti a entrambe le build. | Misurare la durata di `unit` alla prima esecuzione e alzare il timeout se serve. Non togliere il controllo. | New |

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| Verifica manuale degli ID BR1.1–BR1.15 nel `functional-spec.md` di U6 | PASS: tutti presenti | `check_rule_ids.sh BR1. 15 test/label` è coerente. Nessuna collisione con U4, perché la cartella è diversa. |
| Verifica di fattibilità su `ci.yml`, `check_coverage.sh` (prefisso `lib/label/`), `check_rule_ids.sh`, `promote.yml` | PASS | I passi nuovi si innestano come descritto. Il controllo delle regole di `promote.yml` confronta i blob con l'ultimo deploy, quindi passa se U6 non li cambia. |
| `AndroidManifest.xml` e `build.gradle.kts` | PASS con nota | minSdk 24 coerente con il limite HEIC dichiarato. Il filtro di condivisione non c'è ancora, come atteso a questo stadio. |

### Summary

Costo 0 €, pubblicazione e rollback sono coerenti con team.md e con i workflow esistenti, e tutti i NFR di U6 hanno una destinazione nella tracciabilità. Restano due lacune da chiudere prima della generazione del codice: il gate nativo di immagini non è collaudato in CI, e le immagini di prova per l'e2e non hanno né generazione né consegna definite. Le due lacune sono entro la soglia di due Major, quindi il verdetto è READY.
