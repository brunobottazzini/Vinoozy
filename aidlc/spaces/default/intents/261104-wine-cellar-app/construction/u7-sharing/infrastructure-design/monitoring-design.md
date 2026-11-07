# Monitoring Design — u7-sharing

Fonti: `security-design.md` di U7 (§2 privacy, §4 affidabilità), `performance-design.md` di U7 (misure e costo), `logical-components.md` di U7, `functional-spec.md` di U7, `docs/firebase-setup.md` §7 (avvisi esistenti), riepilogo confermato in `infrastructure-design-questions.md`.

## 1. Segnali

| Segnale | Origine | Contenuto | Note |
|---|---|---|---|
| Letture giornaliere di Firestore | Cloud Monitoring, metrica delle letture di documenti di Firestore | Numero di letture per giorno | Nuovo avviso (§2) |
| Rifiuti delle regole | Cloud Monitoring, avviso esistente (> 50 in 1 ora) | Valutazioni negate | Già configurato da U1 |
| Errori della condivisione (non fatali) | `ErrorReporter` → Crashlytics, con `reason` fisso (`sharing_invite_failed`, `sharing_revoke_failed`, `sharing_activate_failed`, `sharing_leave_failed`) | Tipo dell'errore e messaggio senza email | Nessun dato personale (NFR8.2) |
| Tempi delle operazioni | Misura manuale sul telefono, checklist | Mediana di 5 prove per operazione | Una volta per versione |
| Comparsa e revoca | `integration_test/sharing_test.dart` in CI; misura manuale con due telefoni | Esito con limite di 15 s in CI, tempo in secondi sul telefono | — |

## 2. Soglie e azioni

| Condizione | Dove si vede | Azione |
|---|---|---|
| Letture del giorno > **35.000** (70% della quota) | Email da Cloud Monitoring (nuovo criterio) | Guardare nella console quali raccolte leggono di più. Prima misura: tenere aperto 30 minuti l'ascolto della cantina appena lasciata (`performance-design.md` §4). Se non basta, decidere con il proprietario il passaggio al pagamento a consumo. |
| Rifiuti delle regole > 50 in 1 ora | Email esistente | Dopo una revoca alcuni rifiuti sono normali: la persona revocata ha ascolti aperti e scritture in coda. Si indaga se il numero resta alto per più ore o se riguarda proprietari. |
| `sharing_*_failed` > 10 eventi o > 3 utenti in 7 giorni | Crashlytics, controllo mensile | Controllare la traduzione degli errori e le regole; correggere con una nuova versione. |
| Mediana delle operazioni sopra 3 s, o comparsa o revoca sopra 5 s sul telefono | Checklist di rilascio | La versione non va in produzione finché non rientra, oppure il proprietario accetta lo scostamento per iscritto. |

## 3. Configurazione del nuovo avviso (`docs/firebase-setup.md` §7)

- **Cloud Monitoring → Avvisi → Crea criterio:**
  - metrica: probabilmente `firestore.googleapis.com/document/read_count`, risorsa `firestore_instance`, database `(default)`. Prima di crearlo, verificare il nome esatto nel Metrics Explorer e annotarlo nella stessa riga della checklist, come per l'avviso sui rifiuti;
  - **condizione principale:** somma mobile su **24 ore** (finestra della condizione di 1 giorno, il massimo consentito per gli avvisi a soglia) sopra **35.000**;
  - **condizione di riserva, se la finestra di 24 ore non è accettata:** somma su 1 ora sopra **3.000**, mantenuta per 3 ore. Corrisponde a un ritmo che porterebbe oltre la quota in meno di un giorno;
  - notifica: email al proprietario.
- **Limite noto:** la somma mobile non coincide con il giorno della quota di Firestore, che si azzera a mezzanotte, ora del Pacifico. È un avviso precoce, non un conteggio esatto della quota. Il valore esatto si legge nella pagina "Utilizzo" della console Firebase durante il controllo mensile.

## 4. Aggiunte alla checklist (`docs/release-checklist.md`)

- **§1-quater Condivisione (u7-sharing):** prova con due telefoni sulla build del test interno:
  - invito e messaggio di Android;
  - comparsa della cantina, con il tempo;
  - cambio di permesso (i comandi compaiono o spariscono);
  - revoca, con il tempo e l'avviso;
  - uscita volontaria, senza avviso;
  - terzo invito rifiutato con "Hai raggiunto il limite di 2 persone";
  - mediana dei tempi delle operazioni.
- **§2 Data Safety:** aggiungere "Indirizzi email di altre persone forniti dall'utente, per la funzione di condivisione; non condivisi con terze parti; cancellabili".
- **§3 Promozione:** prima `firebase-deploy.yml` (regole e indice), verifica che l'indice sia "Abilitato", poi la promozione dell'app.
- **§5 Controllo mensile:** una riga per le letture giornaliere (massimo del mese) e per gli eventi `sharing_*_failed`.
