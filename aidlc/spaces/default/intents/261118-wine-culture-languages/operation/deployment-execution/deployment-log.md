# Registro del rilascio — Lingue dei paesi del vino

Data: 2026-11-18. Ambiente: canale di **test interno** di Google Play, che è lo staging del progetto (`team.md`, Deployment). La produzione non è stata toccata.

## Decisioni del proprietario

- Q1: commit direttamente su `main` e push (messaggio 4b53920f).
- Q2: versione **0.3.0** (`pubspec.yaml` `0.3.0+3`; il numero di build lo assegna GitHub Actions).
- Q3: le altre modifiche non salvate vanno in un commit separato. `.swp`, un file di recupero di Vim, resta fuori.

## Passi eseguiti

| Passo | Esito |
|---|---|
| Commit `e8ae150` | Note di Play Console e GitHub, modulo sulla sicurezza dei dati, registro `261111-actions-release-fix` |
| Commit `375a581` | Le 25 lingue, versione 0.3.0 (194 file) |
| `git push origin main` | `6f76475..375a581` |
| CI `ci.yml`, run 44320859372 | **success**: secrets, format, analyze, estimation, rules; `unit` 25 min 14 s (limite 40); `e2e` 26 min 9 s |
| Rilascio `release.yml`, run 44325641297 | **success**: AAB firmato caricato sul canale interno; tag `build-5` sul commit `375a581` |

Build pubblicata: **0.3.0 (5)**.

## Migrazioni e servizi

- Nessuna migrazione di dati: i valori salvati non dipendono dalla lingua.
- Regole e indici di Firestore invariati: nessuna distribuzione su Firebase.
- Nessuna Cloud Function cambiata.

## Rollback

Google Play non permette di tornare a una build già pubblicata (`team.md`).
- **Canale interno**: si carica una nuova build con la correzione.
- **Produzione**, quando ci arriveremo: si ferma il rilascio graduale con `promote.yml`, azione `halt`, e si pubblica una correzione.

## Ancora a mano, in Play Console

1. Promuovere 0.3.0 (5) dal test interno al test chiuso **Alpha**, con le note di `distribution/google-play/release-notes.txt`. Poi inviare le modifiche per la revisione.
2. Caricare le schede delle 22 lingue nuove, seguendo `docs/store-languages.md`.
