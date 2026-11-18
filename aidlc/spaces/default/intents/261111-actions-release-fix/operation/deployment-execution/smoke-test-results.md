# Smoke test

Eseguito il **12/11/2026 alle 15:17-15:25**, dopo l'approvazione della fase
(inizialmente rimandato dal proprietario). Telefono OnePlus CPH2581
(Android 16), collegato via USB; comandi dal Mac con `adb` e `uiautomator`.

Build provata: **0.2.1 (4)**, installata dal **Play Store** dopo l'adesione al
test interno (`installerPackageName=com.android.vending`, `versionCode=4`),
cioè l'AAB firmato prodotto da `release.yml` (tag `build-4`, commit `6f76475`).

| Controllo (`docs/release-checklist.md` §1) | Esito | Evidenza |
|---|---|---|
| Avvio dell'app | ✅ | Cruscotto con i dati dell'account (5 bottiglie); nessun errore Flutter nel log |
| Accesso con Google | ✅ | uscita e nuovo accesso fatti dal proprietario; servizio credenziali di Google usato alle 15:19:25, nessun `DEVELOPER_ERROR` né eccezione; cantina tornata. Conferma che `GOOGLE_SERVER_CLIENT_ID` della pipeline è corretto |
| Inserimento di un vino e sincronizzazione | ✅ | "Prova Smoke" (senza annata) salvato, comparso nell'elenco, nessun banner di modifiche in sospeso, nessun `PERMISSION_DENIED` o rifiuto nel log |
| Eliminazione | ✅ | "Prova Smoke" eliminato; la cantina è tornata com'era |

Note:

- Il modulo "Scrivi" si apre normalmente sul telefono; il problema visto in
  E2E riguarda solo l'emulatore locale API 36.1.
- Le righe `E` del log (Gralloc, SchedAssist, Oplus) sono del sistema
  OnePlus, non dell'app.

Esito: **superato**. La build 4 può essere promossa in produzione con
`promote.yml` (`versionCode` 4, `fraction` 1.0) quando Google concede
l'accesso alla produzione.
