# Functional Design — u8-account — Domande

Contesto:
- `unit-of-work.md` (U8: presentazione al primo avvio, uscita con avviso sulle modifiche non sincronizzate, cancellazione dell'account con eliminazione dei dati e revoca delle condivisioni);
- `requirements.md` (FR1.3, FR1.4 e NFR8, aggiornati il 2026-11-06 senza le foto; FR10, NFR3);
- `stories.md` (US1.2, US1.3);
- contratti C3 (dati e regole) e C4 (condivisione, U7);
- mockup: presentazione in tre pagine al primo avvio, profilo;
- unità già costruite: U1 (accesso, registro delle scritture in coda, azzeramento locale al cambio di account), U3, U4, U5, U6, U7.

Vincoli già fissati: nessuna funzione nel cloud e budget 0 €. Quindi la cancellazione la fa l'app stessa, con le regole di sicurezza che la permettono solo al proprietario dei dati. Restano tre scelte di prodotto.

## Q1. [Prodotto] Uscita con modifiche non ancora salvate nel cloud

Senza rete l'app salva sul telefono e sincronizza dopo (U1). Se esci prima della sincronizzazione, quelle modifiche restano sul telefono. Si perdono se poi entra un altro account, perché l'app azzera i dati locali.

A. Avviso con due scelte: "Hai N modifiche non ancora salvate. Se esci e poi entra un altro account, andranno perse." con "Resta e sincronizza" e "Esci comunque". Se rientri con lo stesso account, le modifiche si sincronizzano come sempre (consigliato).
B. Uscita bloccata finché tutto non è sincronizzato: "Collegati a Internet per uscire senza perdere le modifiche", senza "Esci comunque".
X. Other (please specify)

[Answer]: A

## Q2. [Prodotto] Pagina web per chiedere la cancellazione (obbligo di Google Play)

Google Play chiede, oltre alla cancellazione dentro l'app, un indirizzo web dove chiedere la cancellazione dell'account anche senza l'app installata.

A. Una pagina statica gratuita su GitHub Pages, nelle tre lingue: spiega come cancellare dall'app e offre un indirizzo email a cui scrivere. Le richieste via email le gestisci tu dalla console Firebase entro 30 giorni (NFR8), con una procedura scritta nella checklist (consigliato).
B. Nessuna pagina web: solo la cancellazione nell'app. Rischio che Google Play rifiuti la pubblicazione.
X. Other (please specify)

[Answer]: A

## Q3. [Prodotto] Cosa succede alle cantine condivise quando si cancella l'account

**Cantine di cui sei proprietario:** quando cancelli l'account si cancellano, e le persone invitate perdono l'accesso (FR1.4).

**Cantine di altri a cui sei stato invitato:**

A. Esci da tutte in automatico. Si cancella il tuo invito, le cantine restano ai proprietari, e le bevute che hai registrato lì restano nel loro Storico senza il tuo nome, con "Persona non più presente" (consigliato).
B. Esci da tutte e si cancellano anche le bevute che hai registrato nelle loro cantine.
X. Other (please specify)

[Answer]: A

## Analisi delle risposte

- Q1, Q2 e Q3 = A, senza ambiguità né contraddizioni.
- Q2 aggiunge un'attività fuori dall'app: la pagina su GitHub Pages e la procedura manuale per le richieste via email.

## Consolidated Summary Confirmation

- **Presentazione al primo avvio:** tre pagine, come nel mockup:
  1. "Sai sempre quando bere ogni bottiglia";
  2. "Aggiungi un vino in pochi secondi, scrivendo o con una foto";
  3. "Condividi la cantina con chi vuoi".
  
  Ci sono "Salta" e "Inizia", che portano all'accesso. Compare solo la prima volta sul telefono, anche dopo un'uscita.
- **Profilo:** si apre dal menu, con il nome e l'email dell'account Google, "Esci" e "Cancella account".
- **Uscita (Q1 = A):**
  - senza modifiche in coda: conferma "Vuoi uscire?" e poi la schermata di accesso;
  - con modifiche in coda: avviso con il numero delle modifiche, "Resta e sincronizza" ed "Esci comunque";
  - le modifiche restano sul telefono e si sincronizzano se rientra lo stesso account; se entra un altro account, si perdono con l'azzeramento locale di U1, come dice l'avviso.
- **Cancellazione dell'account:**
  - serve la rete; senza rete compare "Collegati a Internet per cancellare l'account";
  - la conferma elenca cosa si cancella: la tua cantina con i vini e lo Storico, le condivisioni che hai dato, la tua partecipazione alle cantine di altri, il profilo. Le foto non ci sono più, perché non si conservano;
  - per conferma si scrive "CANCELLA" (o la parola nella lingua dell'app), poi si rifà l'accesso con Google: Firebase lo chiede per cancellare un account;
  - l'app cancella in quest'ordine:
    1. le tue partecipazioni alle cantine di altri (Q3 = A: le cantine restano ai proprietari, le tue bevute restano nel loro Storico come "Persona non più presente");
    2. gli inviti della tua cantina, così le persone invitate perdono subito l'accesso;
    3. bevute e vini della tua cantina;
    4. la cantina e il profilo;
    5. infine l'account di Firebase.
  - Se qualcosa si interrompe (rete, chiusura dell'app), la cancellazione riprende da dove era arrivata al prossimo avvio con lo stesso account, prima di qualsiasi altra cosa. L'account non torna utilizzabile a metà.
  - Alla fine: azzeramento dei dati sul telefono e schermata di accesso con "Account cancellato".
- **Regole del cloud:** si aggiornano solo se servono a permettere queste cancellazioni, sempre e solo al proprietario dei dati, e con i test sull'emulatore.
- **Pagina web per Google Play (Q2 = A):**
  - una pagina statica su GitHub Pages in italiano, inglese e portoghese, con i passi per cancellare dall'app e un indirizzo email per chiedere la cancellazione;
  - per le richieste via email, una procedura nella checklist: verificare che il mittente sia l'email dell'account e cancellare i dati dalla console Firebase entro 30 giorni (NFR8);
  - l'indirizzo email da usare lo scegli tu prima della pubblicazione.
- **Accessibilità e lingue:** tutto nelle tre lingue, testo al 200%, TalkBack, aree di tocco di almeno 48 dp.
- **Costo:** 0 €. Nessuna funzione nel cloud; GitHub Pages è gratuito.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
