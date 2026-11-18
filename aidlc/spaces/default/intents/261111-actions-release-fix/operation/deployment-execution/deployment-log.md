# Registro del deployment (12/11/2026)

## Configurazione (a cura del proprietario e di un agente di supporto)

- `play-internal`: 7 segreti e variabile `GOOGLE_SERVER_CLIENT_ID`
  (`docs/github-config-handoff.md`). Il primo keystore caricato
  (`keystore_apk`) era sbagliato; sostituito con `vinoozy-upload.p12`
  (SHA-1 `81:7C:4B:3A:…:A3:7E`, uguale alla chiave di caricamento di Play).
- `play-production`: creato, revisore `brunobottazzini`, solo `main`, segreto
  `PLAY_PRODUCTION_SA_JSON`.
- Segnalazione di secret scanning #1: verificati limiti e metriche della
  chiave web, chiusa come falso positivo (nessuna rotazione, decisione Q4).

## Commit pubblicati su `main` (decisione Q1: commit diretto)

| Commit | Contenuto |
|---|---|
| `38d19b6` | verifica dei segreti, `play_api.sh`, test, correzione E2E test 8, guida |
| `4cc0024` | Flutter fissato a 3.47.9 nei workflow (l'azione installava 3.50.0) + controllo di allineamento con `.flutter-version` |
| `6f76475` | tre difetti dietro l'E2E intermittente di cancellazione account; diagnostica di `waitFor` |

## Esecuzioni

| Run | Esito | Note |
|---|---|---|
| CI `43190709684` (`38d19b6`) | rossa | Flutter 3.50.0: `analyze` (149 deprecazioni) e test nativi; `e2e` annullato dal push successivo |
| CI `43192173893` (`4cc0024`) | rossa | solo `e2e`: test "BR1.7 … whole deletion" (difetto preesistente, già in 4 CI precedenti); test 8 verde |
| CI `43202895608` (`6f76475`) | **verde, 7/7** | E2E completo verde, test 8 e cancellazione account compresi |
| Release `43207310918` tentativo 1 | rossa | upload rifiutato: AAB firmato con la chiave sbagliata (SHA-1 `7E:B0:…:EB:A9`) |
| Release `43207310918` tentativo 2 | **verde** | dopo la sostituzione del keystore; nessuna modifica al codice |

## Release sul canale interno

- Verifica: "The play-internal configuration is complete."
- Versione: `0.2.1`, versionCode `4` (ultimo caricato a mano: 3).
- AAB firmato caricato sul canale di test interno, stato `completed`.
- Tag `build-4` sul commit `6f76475`.
- File dei segreti rimossi; job `crashlytics-symbols` saltato (WIF non
  configurato, atteso).

## Migrazioni di database

Nessuna: regole e indici Firestore invariati in questo lavoro.

## Rollback

Non necessario. Procedura in
`operation/deployment-pipeline/rollback-runbook.md`.
