# Scelte tecniche — riconoscimento delle etichette

## Fonti

- `construction/functional-design/functional-spec.md` (D1–D5).
- `inception/requirements-analysis/requirements.md` (NFR4, NFR5, NFR6).
- `nfr-requirements-questions.md` (Q1 = A, repository pubblico).
- Licenze di Open Food Facts: base dati ODbL, contenuti DbCL, immagini CC BY-SA.

## Decisioni

### TS1 — Nessun pacchetto nuovo per la base

`dart:io` (`GZipCodec`), `dart:convert` e `Isolate.run` bastano. Si scarta `sqflite` (D1).

### TS2 — Controllo della rete: `connectivity_plus`

Pacchetto ufficiale di Flutter Community, licenza BSD-3, gratuito. Si usa solo in `lib/catalog/platform/` dietro un'interfaccia (BR6.1). Alternativa scartata: provare una richiesta HTTP prima di ogni ricerca, che costa tempo e chiamate a Open Food Facts.

### TS3 — Lens con codice Kotlin nel progetto Android

Un `MethodChannel` `vinoozy/lens` in `MainActivity` più il `FileProvider` di AndroidX (già disponibile). Alternativa scartata: `share_plus`, che non permette di scegliere il pacchetto destinatario né di gestire il ripiego come in BR5.2.

### TS4 — Strumento di costruzione in Dart

`tool/build_wine_db.dart`, eseguito con `dart run`, legge l'export CSV di Open Food Facts in streaming (NFR2.8). Solo librerie standard di Dart. L'estratto di prova sta in `tool/fixtures/`.

### TS5 — Licenza e attribuzione (NFR5)

- La base derivata è sotto **ODbL**: il repository pubblico (Q1 = A, decisione del proprietario) la rende disponibile con la stessa licenza. Nella cartella `assets/wine_db/` ci sono un `LICENSE` ODbL e un `README` che indica la fonte e lo strumento che la genera.
- I contenuti dei prodotti sono sotto **DbCL**: citati nella schermata Informazioni.
- Attribuzione "Dati da Open Food Facts, licenza ODbL" ovunque compaiano dati (BR6.2).
- Nessuna immagine di Open Food Facts nella base, quindi la CC BY-SA delle immagini non si applica.
- **Distribuzione nell'APK.** La base viaggia dentro l'app pubblicata su Google Play. Per l'ODbL è una distribuzione al pubblico della base derivata, quindi serve offrirla anche in forma leggibile. Il repository pubblico la offre: file della base, strumento che la genera ed estratto di prova. La schermata Informazioni indica dove trovarla.
- **Perimetro della condivisione alle stesse condizioni.** L'ODbL vale solo per la base derivata (`assets/wine_db/`). Il codice dell'app resta con la sua licenza. I vini della cantina dell'utente sono un uso della base e non una base derivata da condividere.
- **Dicitura di attribuzione.** Nella schermata Informazioni: "Contiene informazioni da Open Food Facts, rese disponibili con la Open Database License (ODbL). I singoli contenuti sono sotto Database Contents License (DbCL)." Nelle proposte: "Dati da Open Food Facts, licenza ODbL" (BR6.2). I testi stanno nei 3 file ARB.

**Requisito derivato NFR5.6:** la cartella `assets/wine_db/` contiene `LICENSE` (ODbL) e `README` con fonte, data dell'export e comando di generazione; un test controlla che ci siano.

**Requisito derivato NFR5.7:** prima della pubblicazione sullo store il repository è pubblico. È un'azione del proprietario ed è una voce di `docs/release-checklist.md`.

### TS6 — Test e strumenti (NFR4, NFR6)

| ID | Requisito |
|---|---|
| NFR4.1 | Copertura ≥ 80% delle righe sul progetto intero senza esclusioni (`tool/check_coverage.sh 80`), e anche su `lib/label/` e su `lib/catalog/` presi da soli, con il terzo argomento di prefisso che lo script supporta già (`tool/check_coverage.sh 80 coverage/lcov.info lib/label/`). |
| NFR4.2 | Suite esistente verde; nessuna soglia abbassata. |
| NFR4.3 | `integration_test/label_test.dart` aggiunge: fronte + retro con sorgente finta, codice solo sul retro, "Salta", candidati, "Cerca online" senza rete, conferma di Lens annullata. |
| NFR6.1 | Codice, identificatori e commenti in inglese. |
| NFR6.2 | Tutti i testi nuovi nei 3 file ARB (it, en, pt-BR). |
| NFR6.3 | Matrice di accessibilità esistente (3 lingue × testo 1,0/2,0 × chiaro/scuro) per `BackPhotoPrompt`, `CandidateList`, `NotFoundView`, `OnlineSearchScreen`, `LensConfirmSheet`, `AboutScreen`, con i punti L1–L9. |
| NFR6.4 | `dart format` e `flutter analyze --fatal-infos` puliti. |
| NFR6.5 | `lib/catalog/core` resta puro (nessun import di Flutter o di plugin): `tool/check_label_imports.sh` e controlli simili restano verdi. |
| NFR6.6 | I blocchi di CI esistenti (7 job, incluso gitleaks) restano obbligatori; nessun job nuovo chiama servizi esterni. |
| NFR5.1 | Nessun servizio a pagamento. |
| NFR5.2 | Pacchetti nuovi solo open source e gratuiti: solo `connectivity_plus` (TS2). |
| NFR5.3 | Le chiamate a Open Food Facts mandano il User-Agent esistente `Vinoozy/<versione> (<contatto>)`. |
