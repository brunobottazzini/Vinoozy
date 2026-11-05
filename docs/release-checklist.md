# Checklist di rilascio

Si usa prima di ogni promozione in produzione (`cicd-pipeline.md` §5). La build da provare è quella del canale **Test interno**, pubblicata da `release.yml` dopo il merge in `main`.

## 1. Smoke test sul telefono reale

- [ ] Installa la build dal canale Test interno (`versionCode`: ______).
- [ ] Avvio a freddo: la Cantina compare in circa **2 s** (NFR2.1). Tempo misurato: ______.
- [ ] Salvataggio di un vino: dal tocco su "Salva" alla riga nella lista in meno di **300 ms** (NFR1.1), con questa build di rilascio. Tempo misurato: ______. I test end-to-end usano 2 s solo come limite provvisorio di non regressione (build di debug sull'emulatore): NFR1.1 e NFR2.1 restano aperti finché queste due misure non sono fatte qui.
- [ ] Accesso con Google con il selettore di account vero (non coperto dai test automatici).
- [ ] Aggiungi un vino con la rete.
- [ ] Attiva la **modalità aereo**, aggiungi un secondo vino, verifica la fascia "Offline - sincronizzazione in attesa".
- [ ] Riattiva la rete: entrambi i vini compaiono nella Console Firestore e la fascia scompare.
- [ ] Crashlytics: nessun crash nuovo per questa versione.
- [ ] App Check: le richieste di questa versione risultano verificate.
- [ ] Profilo di prestazioni in modalità profile con 500 vini: meno del 5% di fotogrammi oltre 16 ms (NFR2.2).

## 2. Data Safety in Play Console (NFR8.1–NFR8.3)

Da aggiornare se cambiano i dati raccolti. Per U1 la dichiarazione è:

| Dato | Raccolto | Condiviso con terzi | Scopo |
|------|----------|---------------------|-------|
| Email e nome dell'account Google | Sì | No | Account (accesso e profilo `users/{uid}`) |
| Cantina e vini | Sì | No | Funzionalità dell'app (`cellars/{uid}` e `wines`) |
| Rapporti di crash (Crashlytics, anonimi) | Sì | No | Analisi dei crash. Nessun identificatore utente, nessuna email, nessun nome di vino o percorso di documento |

Dati che restano solo sul telefono, fuori da Firestore, nel valore `ledger.v1` di `shared_preferences`. Servono a non perdere modifiche e si cancellano con il reset dei dati locali (NFR4.10):

| Campo di `ledger.v1` | Contenuto |
|----------------------|-----------|
| `lastUid` | uid dell'ultimo utente che ha usato il telefono |
| `generation` | contatore dei reset |
| `owner.uid`, `owner.email`, `owner.seq` | account a cui appartengono le modifiche in coda e contatore delle scritture |
| `journal[].wineId`, `journal[].cellarId`, `journal[].name`, `journal[].ownerUid`, `journal[].state`, `journal[].notices` | giornale delle creazioni non ancora confermate: ID, cantina, nome del vino, proprietario, stato (`open`/`rejected`) e numero di avvisi mostrati |
| `resetPending` | reset dei dati locali in corso |

- [ ] Backup automatico disattivato (`allowBackup=false` e regole di estrazione dei dati, NFR8.4): verificato nel manifest dell'AAB.
- [ ] Dichiarazione Data Safety coerente con le tabelle sopra.

## 3. Promozione e tag

- [ ] Esegui `promote.yml` con `action: promote`, `fraction: 0.2` e il `versionCode` provato; approva l'ambiente `play-production`.
- [ ] Controlla Crashlytics e Android vitals per almeno 24 ore.
- [ ] Esegui `promote.yml` con `action: complete`. Il workflow crea il tag **`v<versionName>+<versionCode>`** sul commit del tag `build-<versionCode>`.

## 4. Se qualcosa va storto (rollback)

- [ ] `promote.yml` con `action: halt` ferma il rilascio graduale alla percentuale a cui è arrivato (la legge dalla traccia di produzione, non la impone), oppure fermalo dalla Console di Play.
- [ ] La correzione esce come nuova versione e ripassa dal Test interno: Google Play non permette di tornare a una build già pubblicata.
- [ ] Regole di sicurezza: `firebase-deploy.yml` con il `ref` del tag `v*` precedente.
