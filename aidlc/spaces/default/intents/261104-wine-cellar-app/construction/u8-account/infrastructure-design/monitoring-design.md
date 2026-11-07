# Monitoring Design — u8-account

Fonti: `security-design.md` di U8 (§4 privacy, §7), `performance-design.md` di U8 (§5 misure), `logical-components.md`, `functional-spec.md`, riepilogo confermato in `infrastructure-design-questions.md`.

## 1. Metriche

| Metrica | Origine | Soglia | Perché conta |
|---|---|---|---|
| Errori dell'account (non fatali) | Crashlytics: `account_delete_failed`, `account_signout_failed`, `account_reauth_failed`, con il passo | > 3 eventi nei 30 giorni del controllo mensile | Una cancellazione bloccata è un problema di privacy |
| Richieste di cancellazione via email | Casella `bottazzinibruno@gmail.com` | Risposta entro 14 giorni, cancellazione entro 30 | NFR8 |
| Richieste App Check | Console Firebase, App Check | ≥ 99% di richieste verificate per 7 giorni prima dell'obbligo (`docs/firebase-setup.md` §2) | Evita di bloccare utenti legittimi |
| Tempo di cancellazione | Checklist ed end-to-end | ≤ 60 s | NFR1.2 |

## 2. Avvisi

| Avviso | Condizione | Gravità | Destinatario |
|---|---|---|---|
| Errori dell'account | Soglia di §1, letta nel controllo mensile | Media | Crashlytics, nessuna email |
| Rifiuti delle regole (esistente) | > 50 in 1 ora | Media | Email al proprietario |

Nessun avviso nuovo.

## 3. SLI e obiettivi

| Indicatore | Obiettivo | Finestra |
|---|---|---|
| Cancellazioni dall'app senza errore definitivo | Utenti con `account_delete_failed` senza una cancellazione completata dopo = 0 | 30 giorni |
| Richieste via email chiuse nei tempi | Richieste chiuse entro 30 giorni / richieste ricevute = 100% (registro tenuto dal proprietario nella checklist) | 30 giorni |

## 4. Log e cruscotti

- Nessun log sul server. Eventi non fatali di Crashlytics con motivo e passo.
- Controllo mensile: errori `account_*`, richieste via email aperte, metriche di App Check.

## 5. Aggiunte alla checklist (`docs/release-checklist.md`)

- **§1-septies Account (u8-account):**
  - presentazione al primo avvio;
  - uscita senza e con modifiche in coda;
  - cancellazione completa su un account di prova con una cantina condivisa e un invito in una cantina altrui;
  - ripresa dopo aver chiuso l'app a metà;
  - cancellazione dalla pagina web nel browser.
- **Console Firebase (una volta):**
  - app web registrata;
  - dominio GitHub Pages autorizzato;
  - App Check per il web;
  - obbligo su Firestore dopo aver verificato le metriche.
- **§2 Data Safety:** URL della pagina di cancellazione; informativa con i residui dichiarati.
- **Procedura per le richieste via email** (NFR8.6): risposta all'indirizzo dell'account, cancellazione dopo il "Sì", chiusura dopo 14 giorni senza risposta.
- **§3 Promozione:** prima le regole, poi `pages.yml`, poi l'app.
- **§5 Controllo mensile:** errori `account_*`, richieste via email, App Check.

**Pagina web, errori:** la pagina non invia telemetria (scelta di privacy). Un errore mostra all'utente il messaggio con "Riprova" e l'indirizzo email come ultima strada. Le segnalazioni arrivano quindi via email e si contano nel registro della checklist. È un limite dichiarato.

