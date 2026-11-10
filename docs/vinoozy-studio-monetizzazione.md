# Vinoozy — studio di sostenibilità e monetizzazione

**Studio tecnico: 9 novembre 2026; previsioni economiche e passaggio Spark → Blaze aggiornati il 10 novembre 2026.** Progetto verificato nello studio iniziale: `main`, commit `ee114e34ecdb2ec0dff873d20ad23d0004996947`. Le previsioni non costituiscono un nuovo audit di tutti i cambiamenti successivi al codice. Stato tecnico e pubblicazione nel documento [vinoozy-pubblicazione-checklist.md](vinoozy-pubblicazione-checklist.md).

## Raccomandazione

**Direzione aggiornata il 9 novembre 2026: freemium con uso leggero senza annunci, annunci occasionali oltre una soglia di uso cloud e Plus a 14,99 €/anno o 1,99 €/mese che rimuove annunci e limite di cantina.** L'obiettivo degli annunci è contribuire ai costi dei server e della sincronizzazione. Al lancio il modulo pubblicitario può restare disattivato mentre si misurano i consumi.

**Per lo sviluppo seguire la [specifica della sezione 7](#7-specifica-per-lo-sviluppo-freemium-e-soglia-pubblicitaria-v1)**: default proposto di **15 schede di vino/annata attive** nel piano gratuito e soglia di **0,005 € per account/mese di costo cloud stimato a tariffa piena**, oltre la quale l'utente gratuito diventa idoneo agli annunci. Sono parametri iniziali di prodotto, non consumi misurati, quote Firebase individuali o una garanzia di pareggio. La sezione 7 prevale sulle alternative esplorative dello studio.

**Per decidere quanto spendere e quando passare a Blaze usare la [sezione 8](#8-previsioni-economiche-e-passaggio-spark--blaze)**: scenari tutti freemium, 100/300/500 abbonati, margini, stress con annunci a zero e limiti di crescita. Stato attuale **Spark**, comunicato dal proprietario il 10 novembre; nessun cambio di piano eseguito. L'obiettivo di non perdere sull'infrastruttura richiede ricavi sufficienti e limiti tecnici di spesa: la sola soglia pubblicitaria non lo garantisce.

**Handoff per iniziare freemium e abbonamenti:** vedere la [sezione 9](#9-handoff-di-sviluppo-e-cheat-nascosto-sblocca-tutto), che include il menu sviluppatore nascosto «Sblocca tutto», i suoi limiti di ambiente e l'accesso Plus gratuito del proprietario su build reali. È una specifica da implementare, non un cheat già presente nell'app.

Mantenere gratis gestione quotidiana, stime, OCR locale, accesso ai propri dati ed esportazione di base quando sarà implementata. Più cantine, condivisione ampliata, statistiche e report avanzati sono possibili estensioni Plus, da sviluppare e validare separatamente. Preservare dati e accesso dei primi utenti durante l'introduzione dei limiti.

**Riserva:** un acquisto una tantum da **19,99 €** per report/statistiche locali, con ambito chiaramente definito. Non promettere servizi cloud premium a vita senza una riserva per mantenerli. B2B è una pista successiva da validare con clienti reali, non una previsione di ricavo del lancio.

Prezzi, soglie, conversioni, frequenze d'uso, rinnovi, tempi e costi di lavoro in questo studio sono **ipotesi/proposte**, non dati commerciali misurati. Tariffe e regole citate provengono da fonti primarie consultate alla data sopra. Non è stata verificata la configurazione di fatturazione Firebase, Play Payments o fiscale del proprietario.

## 1. Che cosa costa oggi, secondo il codice

| Riscontro nel repository | Implicazione economica |
|---|---|
| Firestore persiste offline; cache illimitata (`lib/firebase/firestore_bootstrap.dart`) | Lavorare offline aiuta l'esperienza, ma non rende gratuita la successiva sincronizzazione. |
| Un listener vini con `quantity > 0`, condiviso dai provider; Dashboard calcolato localmente | Evitare di sommare per ogni scheda UI lo stesso caricamento. |
| Storico paginato (`drinking_record_repository.dart`, `pageOfHistory`) e archivi separati | Non supporre che ogni avvio scarichi tutto lo storico. Lo storage storico cresce comunque. |
| `quantity` aggrega bottiglie della stessa scheda | **200 bottiglie non significano 200 documenti.** I modelli sotto usano fino a 200 schede distinte come ipotesi prudente. |
| Regole con `get`, `exists`, `getAfter`; sharing con documenti di membership e contatori | Considerare letture dipendenti, scritture multiple e ascoltatori degli invitati. Non moltiplicare automaticamente ogni documento per tutte le chiamate delle regole: c'è riuso nella singola richiesta. |
| Migrazioni e aggiornamenti stime una tantum | Una nuova versione può produrre un picco distinto dal traffico ordinario. |
| OCR/barcode ML Kit sul dispositivo; stima e database OFF offline locali | Nessuna tariffa Cloud Vision per foto e nessun LLM a consumo nel flusso trovato. La diagnostica SDK rimane da dichiarare. |
| Ricerca OFF diretta, cache e budget richieste, `OFF_CONTACT` come abilitazione | Nessun costo Firestore per consultare il catalogo; servizio esterno soggetto ai suoi limiti e disponibilità. |
| Account Google, niente SMS individuati; Crashlytics in release | Nessuna ipotesi di costi SMS. Auth Google e Crashlytics stimati a costo zero negli scenari descritti. |
| Nessun Billing, backend acquisti o pubblicità trovato | L'eventuale Plus richiede sviluppo e un nuovo budget operativo. |

Il repository non dimostra i consumi reali: servono contatori per operazioni, dimensioni medie, sessioni, utenti attivi e account conservati. Non sono stati letti contenuti delle cantine di produzione.

### Tariffe e limiti ufficiali usati

Firestore **Standard**, regione **Milano `europe-west8`**, consumo ordinario senza CUD: prezzi letti nella [tabella ufficiale](https://cloud.google.com/firestore/pricing), selezionando esplicitamente **Milan** e **Monthly** nel browser il 9/11/2026. Non sono i prezzi predefiniti dell'Iowa.

| Voce | Quota senza costo | Prezzo USD oltre quota |
|---|---:|---:|
| Letture documenti | 50.000/giorno | **0,035 / 100.000** |
| Scritture documenti | 20.000/giorno | **0,104 / 100.000** |
| Cancellazioni documenti ordinarie | 20.000/giorno | **0,012 / 100.000** |
| Storage, metadati e indici compresi | 1 GiB | **0,174 / GiB-mese** |
| Traffico verso utenti internet in Italia/Europa/Brasile, fascia iniziale | 10 GiB/mese | **0,12 / GiB**, nella fascia fino a 1.024 GiB |

Le quote operative sono giornaliere, con reset circa a mezzanotte del Pacifico; non si compensano giorni molto attivi con giorni inattivi. Una sola banca dati del progetto gode della quota gratuita. Backup, PITR, restore e TTL hanno condizioni ulteriori, esclusi dalle stime. Usare gli SKU nella valuta del proprio contratto per il preventivo finale. [Quote e fatturazione](https://firebase.google.com/docs/firestore/pricing).

**Riconnessioni:** con persistenza attiva, un listener disconnesso per oltre 30 minuti può essere fatturato come nuova query. Sono possibili letture aggiuntive per autorizzazioni e indici; le query senza risultati hanno un minimo. [Regole di addebito](https://firebase.google.com/docs/firestore/pricing). Queste voci sono incorporate nelle ipotesi di letture per sessione, non misurate.

Auth: per il normale accesso Google non è prevista una tariffa per ciascun login nel prodotto base. Se è stato attivato **Authentication with Identity Platform**, Spark ha limiti DAU specifici e Blaze prevede 50.000 MAU inclusi per i provider pertinenti; il caso reale va controllato. Gli scenari fino a 10.000 MAU non generano qui costi Auth su Blaze, ma ciò non elimina limiti di frequenza o protezione abusi: su Identity Platform Spark il limite Tier 1 di 3.000 DAU sarebbe superato dai 5.000 DAU dello stress a 10.000 MAU. Crashlytics è un prodotto senza tariffa a consumo. [Piani Firebase](https://firebase.google.com/docs/projects/billing/firebase-pricing-plans), [Auth e Identity Platform](https://firebase.google.com/docs/auth/), [limiti Auth](https://firebase.google.com/docs/auth/limits).

### Due scenari riproducibili

**MAU** = utenti distinti attivi nel mese. **DAU** = utenti distinti attivi in un giorno. Per i calcoli si usa un mese di 30 giorni e traffico uniforme: è un'**ipotesi** che non protegge dai picchi. Gli account conservati possono essere molto più numerosi dei MAU.

| Parametro, tutto ipotesi | Base | Stress ordinario, non attacco |
|---|---:|---:|
| DAU / MAU | 20% | 50% |
| Sessioni con ricaricamento fatturabile per DAU/giorno | 1 | 2 |
| Sessioni per MAU/mese risultanti | 6 | 30 |
| Letture fatturabili per sessione | 300 | 650 |
| Composizione indicativa delle letture | 200 schede + 30 storico + 40 regole + 30 profilo/inviti/delta | 200 personali + 200 condivise + 100 storico + 100 regole + 50 altri aggiornamenti |
| Scritture per MAU/mese, già incluse le operazioni multiple | 20 | 100 |
| Cancellazioni ordinarie per MAU/mese | 2 | 10 |
| Storage per account conservato, con indici e storico | 1 MiB | 1 MiB |
| Account conservati / MAU | 1 | 3 |
| Risposte trasferite per sessione | 250 KiB | 550 KiB |

Nelle risposte non si aggiungono le letture interne delle regole come se fossero tutti documenti restituiti al telefono. Sono ipotesi diverse di dimensione e numero di risultati. Un MiB per account non è un limite implementato: è una dimensione media ipotizzata, da misurare; note, indici e storico potrebbero farla crescere.

**Volumi nello scenario base:**

| MAU | DAU | Letture/giorno | Letture/mese | Scritture/mese | Delete/mese | Storage GiB | Egress GiB/mese |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 100 | 20 | 6.000 | 180.000 | 2.000 | 200 | 0,098 | 0,143 |
| 1.000 | 200 | 60.000 | 1.800.000 | 20.000 | 2.000 | 0,977 | 1,431 |
| 10.000 | 2.000 | 600.000 | 18.000.000 | 200.000 | 20.000 | 9,766 | 14,305 |

**Costi mensili base, USD, quote giornaliere applicate prima di sommare:**

| MAU | Read | Write | Delete | Storage | Egress | Auth Google | Crashlytics | Totale Firebase modellato |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 100 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | **0,00** |
| 1.000 | 0,105 | 0 | 0 | 0 | 0 | 0 | 0 | **0,11** |
| 10.000 | 5,775 | 0 | 0 | 1,525 | 0,517 | 0 | 0 | **7,82** |

**Volumi e totale nello scenario stress:**

| MAU | Letture/giorno | Letture/mese | Scritture/mese | Delete/mese | Storage GiB | Egress GiB/mese | Totale USD/mese |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 100 | 65.000 | 1.950.000 | 10.000 | 1.000 | 0,293 | 1,574 | **0,16** |
| 1.000 | 650.000 | 19.500.000 | 100.000 | 10.000 | 2,930 | 15,736 | **7,32** |
| 10.000 | 6.500.000 | 195.000.000 | 1.000.000 | 100.000 | 29,297 | 157,356 | **90,75** |

Dettaglio stress a 10.000: read 67,725 + write 0,416 + storage 4,924 + egress 17,683; delete/Auth/Crashlytics zero nel modello. Lo stress non è un massimo: abuso, bug di listener, importazioni massive o un numero elevato di account inattivi possono costare di più.

**Costo medio cloud per MAU/mese:** base 0 / 0,000105 / 0,000782 USD rispettivamente a 100/1.000/10.000 MAU; stress 0,001575 / 0,007324 / 0,009075 USD. Questi valori comprendono la quota gratuita condivisa: non sono un costo marginale universale. Oltre quota, il costo marginale base prima delle franchigie è circa **0,00099 USD/MAU-mese**, a parità di tutti gli altri parametri.

Per programmare un budget in euro, **ipotesi convenzionale 1 USD = 1 EUR**, esclusi imposte e differenze degli SKU: riserva cloud prudente **2/15/120 €/mese** ai tre livelli di utenza, contro i risultati dei modelli sopra. Non è un cambio di mercato verificato né un listino EUR. Rivedere gli SKU e la fatturazione effettiva prima dell'addebito. Il budget di 1 € dell'handoff non basta nello scenario stress a 1.000 MAU o nello scenario base a 10.000.

### Formule e limiti della stima

Per ogni giorno `d`, `R_d` e `W_d` comprendono anche le operazioni delle regole e le scritture realmente fatturate. Non convertire prima le quote in un credito mensile:

```text
C_read  = somma_d max(0, R_d - 50_000) / 100_000 * 0.035
C_write = somma_d max(0, W_d - 20_000) / 100_000 * 0.104
C_del   = somma_d max(0, D_d - 20_000) / 100_000 * 0.012
C_store = max(0, GiB_medi_con_indici - 1) * 0.174
C_out   = max(0, GiB_egress_mese - 10) * 0.12  # fascia e destinazioni assunte
GiB_base = N_MAU / 1024
Egress_base_GiB = N_MAU * 6 * 250 / 1_048_576
```

Esempio: 1.000 utenti che si collegano tutti lo stesso giorno possono provocare 300.000 letture in quel giorno; il credito dei giorni seguenti non cancella le 250.000 eccedenti. Analogamente, cancellare un account con molti documenti o migrare tutte le cantine può concentrare scritture/delete. Per storage, i documenti di utenti non più attivi contano comunque.

Non inclusi: backend premium futuro, Pub/Sub, hosting dinamico, Cloud Logging/BigQuery eventualmente introdotti, backup/PITR, supporto commerciale, SMS, storage di foto, campagne marketing, API a pagamento future. Nessuno di questi è stato assunto come costo già presente. Se si aggiunge il backend acquisti, riservare inizialmente **5–15 €/mese aggiuntivi come ipotesi**, misurando invocazioni, log e traffico; non è una tariffa fissa Google.

### Spark, Blaze e protezioni

Il proprietario conferma **Spark al 10 novembre 2026** e vuole passare a Blaze quando si avvicinano le quote gratuite. Il piano e la regione effettiva non sono stati letti direttamente in Firebase Console. **Blaze non è imposto universalmente per pubblicare su Play**: è una scelta architetturale del progetto o un'esigenza dei servizi/volumi usati. Spark non fattura automaticamente il superamento delle quote: può impedire le operazioni del prodotto interessato; verificare comportamento della quota specifica. Blaze collega un conto di fatturazione e consente addebiti oltre le quote incluse. Le condizioni economiche e operative aggiornate sono in sezione 8. [Piani Firebase](https://firebase.google.com/docs/projects/billing/firebase-pricing-plans).

Con il modello base, le letture oltrepassano 50.000/giorno intorno a **834 MAU**; storage da 1 MiB/account intorno a **1.025 account conservati**. Nello stress le letture lo fanno già intorno a **77 MAU**. Non sono soglie di utenti contrattuali e cambiano con sessioni/cantine. Il backend per validare gli acquisti può richiedere Blaze prima di questi numeri.

Un **budget con soli avvisi da 1 € non interrompe Firestore**. Esistono ora spend cap per alcuni servizi Google Cloud, ma Firestore non compare nell'elenco di eleggibilità letto alla data dello studio: non considerarli un limite alla sua fattura. [Budget e spend cap, servizi eleggibili](https://docs.cloud.google.com/billing/docs/how-to/budgets-spend-caps).

Proposte operative, da implementare/misurare prima di ampliare l'utenza:

1. Alert su letture, scritture, byte e costo, con destinatario reale e prova di consegna; conservare quello da 1 €, aggiungendo soglie coerenti con il budget autorizzato.
2. App Check più regole minime, query limitate e paginazione; evitare listener duplicati o sempre attivi in background. App Check limita alcuni abusi, non impone un tetto economico e non sostituisce Auth/regole.
3. Migrazioni con checkpoint, una sola esecuzione e rollout verificato; contare separatamente le letture per autorizzazioni senza stamparne i contenuti.
4. Limiti di dimensione delle note, inviti e frequenze sul server quando la funzione è server-side; un limite solo UI è aggirabile. Non presentare le Security Rules come un contatore globale di spesa.
5. Verificare quota **Play Integrity**: standard indicato 10.000 chiamate/giorno. Con 10.000 MAU e molte sessioni/refresh può servire un aumento di quota; non corrisponde a 10.000 utenti né a una fee automatica. Per il web controllare il piano reCAPTCHA; non generalizzare la gratuità ad assessment illimitati. [App Check quote](https://firebase.google.com/docs/app-check), [TTL e provider](https://firebase.google.com/docs/app-check/android/play-integrity-provider).
6. In incidente, diagnosi e riduzione selettiva delle operazioni costose; una chiusura indiscriminata blocca anche sincronizzazione e cancellazione. Non usare la disattivazione automatica del billing come unico piano di protezione.

### Costi fissi e costo del tempo

| Voce | Importo | Natura/evidenza |
|---|---:|---|
| Account Google Play esistente | **0 incrementale** | Registrazione standard 25 USD una tantum, già sostenuta secondo handoff; nessun secondo account necessario. [Google](https://support.google.com/googleplay/android-developer/answer/6112435?hl=en) |
| Hosting statico privacy/deletion su GitHub Pages pubblico | 0 nel piano pertinente | Servizio disponibile su repository pubblici gratuiti; oggi non abilitato. Non pubblicare il codice solo per questa esigenza: possibile repo separato. [GitHub](https://docs.github.com/en/pages/getting-started-with-github-pages) |
| Dominio proprio | **10–25 €/anno, ipotesi** | Verificare preventivo, rinnovo, imposte e casella email; nessun dominio acquistato verificato. Utile per OAuth/brand. |
| GitHub CI | Nessun costo addizionale modellato | I consumi/piano non sono stati auditati; runner o servizi a pagamento futuri da preventivare. |
| Consulenza privacy/fisco/contabilità | **600–1.500 €/anno, ipotesi di budget** | Non un tariffario; chiedere preventivi. Contributi, imposte e possibile Camera di commercio sono separati. |
| Assistenza e manutenzione | **4 h/mese × 25 € = 100 €/mese, ipotesi** | Valore del tempo, non esborso automatico. A 10.000 utenti può essere molto maggiore. |
| Introduzione Billing robusto | **5–10 giorni di sviluppo, ipotesi** | Backend, lifecycle, account, regole e test; non incluso nei costi cloud della versione gratuita. |

Per uno sviluppatore singolo il rischio principale è mantenere un prodotto con pochi ricavi ricorrenti e obblighi permanenti. Un'infrastruttura da pochi euro non rende automaticamente redditizia un'attività.

## 2. Confronto modelli

Tutti i ricavi in questa sezione sono **ipotesi**, non benchmark di mercato o offerte già ottenute. I compensi commerciali non devono modificare finestre e stime del vino.

| Modello | Vantaggio | Limite/costo | Compatibilità e valutazione |
|---|---|---|---|
| Freemium per capacità | Uso semplice gratuito, premium per esigenze complesse | Paywall e contatori affidabili; rischio di bloccare la cantina esistente | Default aggiornato: 15 schede attive/una cantina personale; quantità di bottiglie distinta dalle schede. Vedere sezione 7. |
| Una tantum 19,99 € | Acquisto comprensibile, niente rinnovo | Ricavo una sola volta, assistenza futura, rischio cloud a vita | Riserva per funzioni locali/report; acquisto digitale in-app da trattare con Billing nel percorso scelto. |
| Plus 14,99 €/anno o 1,99 €/mese | Copertura ricorrente di hosting e aggiornamenti | Serve valore continuativo e gestione scadenze/rimborsi | Modello principale proposto; prezzo e rinnovo chiari, nessuna manipolazione del consenso. |
| Tip jar / contributi | Semplice da capire, volontario | Importi imprevedibili, trattamento fiscale e policy dipendente dal flusso | Non assumere che chiamarlo «donazione» esenti da Billing o imposte. Non è la fonte principale proposta. |
| AdMob oltre soglia | L'uso intenso contribuisce ai costi senza obbligare all'abbonamento | SDK, consenso, inventario e ricavo variabili; non garantisce copertura dei costi | Scelta aggiornata: attivabile dopo misurazione, con soglia personale, frequenza contenuta e interruttore globale; dettagli in sezione 7. |
| Affiliazione enoteche | Potenziale ricavo legato a interesse concreto | Contratti, tracciamento, resi, geografia, rischio promozione alcol | Da rinviare finché il singolo paese e il partner non sono verificati. Niente spinta ad acquistare/consumare per completare una metrica. |
| B2B | Pochi clienti possono produrre più ricavi | Nuove funzioni, onboarding, supporto, accessi e affidabilità professionale | Valido esperimento distinto. Verificare Billing per app distribuite su Play; non assumere un'esenzione per il solo termine B2B. |
| Sponsor consorzi/cantine | Contenuti territoriali finanziati | Vendita commerciale e conflitto di interessi | Ammissibilità dipende da messaggio, paese e target. Sponsorizzazione esplicita; nessun ranking o stima comprato. |

### Commissioni Play: il 15% è uno scenario condizionato

La [pagina ufficiale delle commissioni](https://support.google.com/googleplay/android-developer/answer/112622?hl=en) distingue ora mercati, installazioni e programmi: per SEE/UK/USA il nuovo schema decorre dal 30/6/2026, Australia/Giappone dal 30/9/2026. La tabella presenta **10% + 5% Billing** per il primo milione USD annuo nel programma pertinente e per abbonamenti; altre transazioni possono avere aliquote maggiori in base a installazione e programma. Negli altri mercati resta indicato il tier 15% sul primo milione per iscritti e il 15% per abbonamenti auto-rinnovabili. Verificare iscrizione, account associati e ricavi dell'altra app: la soglia non va trattata come una nuova franchigia separata per Vinoozy.

Per il modello si assume **fee complessiva 15%** con Play Billing, da confermare nel proprio accordo/Console. Per l'una tantum si mostra anche **25%** come sensibilità compatibile con alcune transazioni nuove nel nuovo schema. Non è un preventivo individuale né una proposta di usare sistemi esterni per evitare commissioni. Riesaminare prima di monetizzare e prima dei cambiamenti Play annunciati per il 2027.

### Ricavi da acquisto e abbonamento

Esempio clienti italiani: prezzo finale con IVA **22% come ipotesi di calcolo**; Google determina l'IVA delle vendite digitali UE effettuate con Play Billing. Non applicare l'aliquota italiana ai clienti di ogni paese. La formula semplificata non copre tutti gli addebiti o trattamenti contabili:

```text
ricavo sviluppatore = prezzo finale / 1,22 × (1 - fee)
```

È un ricavo **dopo IVA della vendita e commissione ipotizzate, prima di imposte sul reddito, contributi, altri costi, rimborsi e trattamento fiscale delle commissioni**. Non è denaro netto personale. [IVA secondo Google Play](https://support.google.com/googleplay/android-developer/answer/138000?hl=it).

| Prezzo finale, ipotesi | Ricavo per pagamento con fee 15% | Con fee 25%, sensibilità |
|---|---:|---:|
| 1,99 €/mese | 1,39 € | 1,22 € |
| 9,99 €/anno, alternativa di prezzo | 6,96 € | 6,14 € |
| **14,99 €/anno, proposta** | **10,44 €** | 9,22 € |
| **19,99 € una tantum, riserva** | **13,93 € una sola volta** | 12,29 € una sola volta |

**Scenari annuali per Plus a 14,99 €:** base di MAU stabile, paganti annuali pari all'1/3/5% di tale base, ognuno con un anno pagato intero. Non è la previsione degli incassi del primo anno con utenti acquisiti gradualmente. Il tasso è una conversione ipotizzata, non osservata.

| MAU | Quota paganti | Paganti | Spesa lorda clienti/anno | Ricavo sviluppatore/anno, formula sopra | Equivalente mensile |
|---:|---:|---:|---:|---:|---:|
| 100 | 1% | 1 | 14,99 € | 10,44 € | 0,87 € |
| 100 | 3% | 3 | 44,97 € | 31,33 € | 2,61 € |
| 100 | 5% | 5 | 74,95 € | 52,22 € | 4,35 € |
| 1.000 | 1% | 10 | 149,90 € | 104,44 € | 8,70 € |
| 1.000 | 3% | 30 | 449,70 € | 313,32 € | 26,11 € |
| 1.000 | 5% | 50 | 749,50 € | 522,19 € | 43,52 € |
| 10.000 | 1% | 100 | 1.499,00 € | 1.044,39 € | 87,03 € |
| 10.000 | 3% | 300 | 4.497,00 € | 3.133,16 € | 261,10 € |
| 10.000 | 5% | 500 | 7.495,00 € | 5.221,93 € | 435,16 € |

Il mensile può incassare di più per chi resta 12 mesi: 1,99×12 = 23,88 € lordi, circa 16,64 € dopo IVA/fee ipotizzate. Non assumerlo per tutti gli utenti: cancellazioni, stagionalità, mancati pagamenti e preferenza per annuale cambiano il risultato. **Ipotesi rinnovo annuale 70%:** una coorte di 30 paganti ne conserva 21 l'anno successivo senza nuovi clienti; ricavo coorte scende da circa 313 a 219 €. Il 70% non è un dato misurato.

**Una tantum:** a parità di 30 acquirenti e 19,99 €, ricavo circa 418 € complessivi con fee 15%; a 300 acquirenti circa 4.178 €. Lo stesso cliente non ripaga l'anno seguente. Non confrontare questi importi con ricavi annui ricorrenti come se avessero lo stesso significato.

### Coprire i costi non equivale a guadagnare

Con un annuale da 14,99 €, il contributo medio ipotizzato è circa **0,87 €/mese per pagante**, prima dei costi ulteriori. Con USD≈EUR soltanto per budget:

| Obiettivo, ipotesi | Paganti annuali necessari | Base utenti al 3%, arrotondata |
|---|---:|---:|
| 10 €/mese costi | 12 | 400 |
| 30 €/mese costi | 35 | 1.167 |
| 100 €/mese costi | 115 | 3.834 |
| 200 €/mese costi complessivi | 230 | 7.667 |

A 1.000 MAU/3% si coprono bene i soli modelli cloud, ma i circa 313 €/anno non coprono un'ipotesi di 600–1.500 € di contabilità e 100 €/mese di lavoro. A 10.000 MAU/3%, 261 €/mese devono coprire anche cloud, tempo, fisco e supporto: **non sono un reddito equivalente di 261 € netti**. Nel caso stress, con riserva cloud 120 €, dominio ~2 €, backend premium 15 € e contabilità 50–125 €, restano pochi margini prima di lavoro e contributi.

### Tip, pubblicità, affiliazioni, sponsor e B2B: esempi numerici

| Modello | Ipotesi numerica | Risultato indicativo | Che cosa può invalidarlo |
|---|---|---:|---|
| Tip jar | 1% dei 1.000 MAU versa 3 € una volta nell'anno | **30 € lordi/anno**, prima di costi e fiscalità | Non ricorrente; non sono 30 €/mese. Flusso ammesso e desiderio di contribuire non verificati. |
| Ads leggere | 1.000 MAU × 6 sessioni/mese × 1 impression × 60% fill × 1–3 € eCPM | **3,60–10,80 €/mese** | Fill/eCPM non verificati e già intesi come resa al publisher; niente ulteriore fee Play. Restrizioni/consenso possono ridurre ancora. |
| Ads, 10.000 MAU | Stesse ipotesi | **36–108 €/mese** | Esperienza peggiorata e oneri SDK/consenso; ricavo può essere zero. |
| Affiliazione | 1.000 MAU × 5% click/mese × 3% acquisto × 60 € ordine × 5% commissione | **4,50 €/mese** | Tassi, prezzo e commissione ipotesi, resi e ordini non attribuiti; adeguatezza legale non risolta dal calcolo. |
| Affiliazione, 10.000 MAU | Stesse ipotesi | **45 €/mese** | Non è una proposta di vendere vino nell'app; verificare flusso e paese. |
| Sponsor territoriale | 2 contenuti/anno × 300 € | **600 €/anno** prima di costi/fisco | Nessun contratto/offerta; revisione e vendita commerciale possono assorbire il margine. |
| B2B | 5 clienti × 15 €/mese, prezzo B2B prima di eventuale IVA | **75 €/mese** prima di pagamenti/costi/fisco | Nuovi requisiti, assistenza, fatturazione e canale di vendita. |
| B2B | 20 clienti × 15 €/mese | **300 €/mese** prima di pagamenti/costi/fisco | Non raggiungibile con certezza dalla versione consumer attuale. |

**Tip jar.** L'eccezione Play per tip/contributi user→creator richiede che il 100% vada al creator e che non sblocchi contenuti o servizi digitali, neppure badge. La qualificazione di un contributo allo sviluppatore stesso va verificata sul flusso concreto; non presumere che qualsiasi pulsante PayPal sia ammesso. Se c'è un beneficio digitale, seguire la policy pagamenti. Una donazione a un ente esente e un incasso dello sviluppatore sono casi diversi. [FAQ pagamenti](https://support.google.com/googleplay/android-developer/answer/10281818?hl=en).

**AdMob.** Le restrizioni publisher riguardano, fra l'altro, facilitazione della vendita online di alcol e consumo irresponsabile; l'inventario soggetto a restrizioni può ricevere meno domanda o nessuna. Non è una regola «vino = AdMob vietato», e l'ammissibilità degli annunci alcolici è un controllo separato dal contenuto dell'app. [Publisher restrictions](https://support.google.com/admob/answer/10437795?hl=en), [policy AdMob](https://support.google.com/admob/answer/3150953?hl=en). Una futura integrazione richiede analisi consenso/SDK, CMP quando necessaria e aggiornamento privacy/Data safety; non basta rendere gli annunci non personalizzati per chiudere ogni adempimento.

**Affiliazioni e sponsorizzazioni.** La [policy Play sull'alcol](https://support.google.com/googleplay/android-developer/answer/9878810?hl=en) non vieta universalmente ogni vendita di alcol, ma protegge minori e vieta usi illegali/inappropriati. In Italia l'[art. 13 legge 125/2001](https://www.gazzettaufficiale.it/atto/serie_generale/caricaArticolo?art.codiceRedazionale=001G0181&art.dataPubblicazioneGazzetta=2001-04-18&art.flagTipoArticolo=0&art.idArticolo=13&art.idGruppo=3&art.idSottoArticolo=1&art.idSottoArticolo1=10&art.progressivo=0&art.versione=1) disciplina la pubblicità con protezioni per minori e indicazioni terapeutiche; la fonte consultata è il testo pubblicato originario, non una verifica completa delle norme applicabili al futuro flusso. L'etichetta 18+ da sola non rende lecita una campagna.

Segnalare chiaramente «Pubblicità», «Contenuto sponsorizzato» o «Link affiliato: potremmo ricevere una commissione», in posizione visibile prima del click; l'informazione nel solo footer non basta come scelta progettuale. Le comunicazioni commerciali non devono fingersi neutrali. [AGCM sulla riconoscibilità](https://www.agcm.it/media/comunicati-stampa/2017/7/alias-8853), [Digital Chart IAP, autoregolamentazione](https://www.iap.it/codice-e-altre-fonti/regolamenti-autodisciplinari/regolamento-digital-chart/).

Prima di attivare un partner: verifica legale nel paese di destinazione, protezione minori adeguata al flusso, ruolo del venditore e controlli età/consegna, termini sui resi e tracking, consenso quando richiesto, revisione Play e aggiornamento dichiarazione ads se ci sono contenuti sponsorizzati. **Ipotesi non verificata:** la specifica affiliazione Vinoozy sarebbe ammessa in Italia/Brasile o altri paesi. Nessuna whitelist mondiale è stata prodotta. Per prodotti fisici Billing ha regole diverse dai servizi digitali, ma non elimina i vincoli sull'alcol.

Per sponsor: contratto che escluda influenza sulle stime, separazione visibile dei contenuti sponsorizzati, revisione editoriale e nessuna condivisione di inventari personali con lo sponsor. I ricavi non giustificano una vendita di dati delle cantine.

Per B2B: prima 5 interviste e 2 piloti paganti come **soglie proposte**; solo poi inventario professionale, ruoli, movimenti, export carta vini e assistenza. Se il piano digitale è acquistabile nell'app Play, verificare Billing e programmi applicabili; un contratto aziendale o un'app di sola consultazione possono richiedere un diverso disegno, da verificare prima della vendita. [Regole pagamenti e servizi cloud](https://support.google.com/googleplay/android-developer/answer/10281818?hl=en).

## 3. Fiscalità e diritto in Italia

**Da verificare con un commercialista prima di attivare incassi.** Quadro informativo, non determinazione del regime del proprietario: non sono noti partita IVA esistente, altro reddito, lavoro dipendente, pensione, precedenti attività, ricavi dell'altra app o contratto Payments applicabile. Ogni applicazione personale sotto è da verificare con un commercialista.

| Tema | Dato normativo/fonte | Conseguenza per Vinoozy, da verificare con un commercialista |
|---|---|---|
| Occasionalità | L'abitualità, anche non esclusiva, rileva per l'esercizio dell'attività ai fini IVA; [DPR 633/1972 art. 4](https://www.normattiva.it/atto/caricaDettaglioAtto?atto.articolo.numero=4&atto.codiceRedazionale=072U0633&atto.dataPubblicazioneGazzetta=1972-11-11&qId=&tabID=0.8298684148665065&title=lbl.dettaglioAtto), art. 5 per arti/professioni | Un'app mantenuta e offerta continuativamente con abbonamenti ha indizi di abitualità: **inferenza**, non classificazione definitiva. Non aspettare un importo arbitrario per affrontare partita IVA. |
| «Soglia 5.000 €» | Per autonomi occasionali i primi 5.000 € annui costituiscono franchigia contributiva INPS, non esenzione fiscale generale: [INPS](https://www.inps.it/it/it/dettaglio-approfondimento.schede-informative.49893.i-contributi-dei-lavoratori-autonomi-occasionali.html) | Non è una soglia universale sotto la quale si può vendere stabilmente senza partita IVA. Non confondere lavoro autonomo occasionale, PrestO e vendita abituale di software. |
| Regime forfettario | Quadro generale: 85.000 € ricavi/compensi; superamento 85.000 ma non 100.000 porta all'uscita dall'anno successivo; oltre 100.000 uscita nell'anno, con regole IVA specifiche. [AdE, comunicato circolare 32/E](https://www.fiscooggi.it/sites/default/files/file/2023/12/055_Com.%20st.%20Circolare%20_nuovo_regime_forfettario_05.12.2023.pdf), [legge 190/2014 vigente, commi 54–89](https://www.normattiva.it/atto/caricaDettaglioAtto?atto.codiceRedazionale=14G00203&atto.dataPubblicazioneGazzetta=2014-12-29&classica=true&tipoDettaglio=vigente) | Le soglie non bastano: controllare tutte le cause di esclusione, redditi da lavoro, partecipazioni e rapporti con datori/ex datori; cumulare le attività pertinenti, compresa l'altra app. |
| Aliquota forfettario | Imposta sostitutiva ordinaria 15%; 5% per avvio e quattro periodi successivi se ricorrono requisiti, non automaticamente per ogni nuova app. [Legge 190/2014, commi 64–65](https://www.normattiva.it/atto/caricaDettaglioAtto?atto.codiceRedazionale=14G00203&atto.dataPubblicazioneGazzetta=2014-12-29&classica=true&tipoDettaglio=vigente) | Determinare ATECO e coefficiente di redditività; non applicare semplicemente 5% o 15% all'accredito netto Play e chiamarlo imposta finale. |
| Contributi | Dipendono dalla qualificazione concreta dell'attività e dalla posizione previdenziale | Valutare Gestione separata o impresa/commercio, eventuali minimi, altre coperture e obblighi camerali. Non stimati in euro senza dati personali. |
| IVA ai consumatori UE | Google dichiara di calcolare, addebitare e versare IVA per acquisti digitali UE tramite Play Billing: [Google](https://support.google.com/googleplay/android-developer/answer/138000?hl=it) | Non significa che il reddito sia esentasse o che Google assolva ogni obbligo italiano del developer. |
| Rapporto developer–Google | Contratti, ruolo della controparte e fatture/report vanno esaminati | Verificare fatturazione, eventuali operazioni intra-UE, reverse charge sulle commissioni/servizi, VIES, integrazioni elettroniche, bollo e registrazioni anche se forfettario. Non affermare che la commissione sia sempre deducibile separatamente. |
| Incassi fuori Play | L'IVA gestita da Play non si estende automaticamente a vendite dirette, B2B, affiliazioni, ads o sponsor | Classificare ogni flusso; verificare OSS/IVA quando pertinente e obblighi documentali. Il nome «donazione» non decide da solo il trattamento fiscale. |
| Residenza e vendite estere | Play richiede dati fiscali e bancari coerenti | Controllare eventuali ritenute, documentazione estera e soggetto che paga; non inventare la forma fiscale da compilare. |

**Limite della verifica delle fonti fiscali:** INPS e Google sono stati letti integralmente nelle sezioni pertinenti. Normattiva e comunicati AdE/FiscoOggi hanno restituito errori/limitazioni nell'apertura integrale; gli estratti ufficiali indicizzati e la ricerca indipendente del revisore supportano il quadro 85.000/100.000 e 15%/5%. Non è stata completata una verifica di ogni modifica, condizione o deroga del 2026: **ipotesi da riconfermare** l'effettiva applicabilità al proprietario e le soglie di esclusione personali. Non è stata usata una guida commerciale come autorità fiscale.

**Dossier da portare al commercialista:** identità e posizione lavorativa/previdenziale, altri ricavi e attività, contratto Play/Payments, paese della controparte, report vendite/IVA/fee/payout di un pagamento di prova, prezzi e paesi, previsione delle entrate, fatture Firebase/dominio e scelta annuale/una tantum. Chiedere un preventivo dei costi fissi prima di decidere se poche decine di euro di ricavi giustificano la monetizzazione.

**Diritti del consumatore e privacy:** prima di vendere predisporre condizioni contrattuali, prezzo totale, durata/rinnovo, gestione cancellazione e rimborsi, contatti del professionista e aggiornamento privacy/Data safety con dati acquisto. La cancellazione dell'account Vinoozy non deve far perdere l'informazione su un abbonamento ancora addebitato da Google: mostrare come gestirlo e definire il comportamento tecnico. Trader status è distinto dal tipo di account; verificare la dichiarazione con scadenza 1/2/2027 e gli effetti annunciati dal 1/3/2027. [Google trader status](https://support.google.com/googleplay/android-developer/answer/17594752). Obblighi e testi contrattuali personali **da verificare con un commercialista e, per la parte legale, con un professionista competente**.

## 4. Funzioni e introduzione del Plus

### Proposta di ripartizione

| Funzione | Gratis, proposta | Plus, proposta | Motivo |
|---|---|---|---|
| Gestione vini e finestre indicative | Una cantina personale, 15 schede attive come default v1 | Nessun limite commerciale di schede; più cantine come estensione | Il limite di capacità è distinto dalla soglia di uso cloud; vedere sezione 7. |
| Pubblicità | Nessuna sotto soglia; occasionale oltre soglia quando il modulo è attivo | Nessuna | Contribuisce ai costi di server e sincronizzazione; non blocca il salvataggio o l'accesso ai dati. |
| Condivisione | Conservare le 2 persone già previste dal prodotto | Fino a 5 persone e gestione di più cantine | Non togliere la funzione di lancio; far pagare il proprietario, non obbligare ogni invitato a comprare. |
| Dashboard e storico | Attuali grafici, voti e note | Filtri/statistiche avanzati e confronti | Non trasformare statistiche in incentivi a bere di più. |
| Export | CSV/JSON dei propri dati quando sviluppato | PDF/carta cantina e report con impaginazione | Portabilità/accesso ai dati non devono dipendere da un abbonamento. |
| Notifiche | Nessuna funzione promessa nella build attuale | Promemoria configurabili per gestione inventario | Nuova funzione, consenso OS e controllo frequenza; niente urgenza di consumo. |
| Foto/OCR | Lettura locale gratuita | Non usarla da sola come differenza di piano | Nessun costo cloud per lettura trovato. Limiti OFF devono valere anche per utenti paganti. |
| Stime ed elaborazione | Stessa qualità di base | Strumenti di organizzazione aggiuntivi | Non peggiorare l'accuratezza delle stime gratuite e non venderne una «certezza» inesistente. |

**Limite di capacità aggiornato:** 15 schede attive, secondo le regole della sezione 7.1; le alternative 50/100/200 bottiglie appartengono allo studio iniziale e non sono il default di sviluppo. Consentire sempre lettura, correzione, riduzione, esportazione quando disponibile e cancellazione; non cancellare dati a scadenza. La soglia pubblicitaria è un secondo parametro indipendente dalla capacità.

### Quando introdurlo e quali segnali leggere

Prima chiudere i blocchi della checklist. **Rollout proposto:** misurazione senza annunci, verifica delle stime, poi attivazione di annunci oltre soglia e/o Plus quando i relativi flussi sono pronti. Le precedenti 8–12 settimane o 300–500 MAU restano riferimenti di validazione, non un obbligo di attendere quei numeri. Le condizioni tecniche di ogni fase sono nella sezione 7.10.

| Metrica | Soglia di lavoro, interamente ipotesi | Decisione |
|---|---|---|
| Qualità | Nessun bug noto di perdita dati, login e cancellazione funzionanti; almeno 99,5% utenti senza crash con campione dichiarato | Prima sicurezza d'uso, poi prezzo; non presentare la percentuale di pochi tester come prova robusta. |
| Attivazione | ≥50% dei nuovi utenti salva 5 vini nella prima settimana | Se inferiore, migliorare inserimento e onboarding prima di introdurre il paywall. |
| Ritorno a 30 giorni | ≥25% su coorti abbastanza grandi, esclusi tester | Verificare uso periodico: una cantina non è per forza un'app quotidiana. |
| Interesse premium | Almeno 15–20 richieste concrete per multi-cantina/report/condivisione avanzata | Costruire la funzione richiesta, senza prometterla già disponibile. |
| Conversione pilota | Obiettivo iniziale 2–3%, misurato su utenti esposti e periodo definito | Ridiscutere prezzo/funzioni se troppo basso; non assumere conversione dalla base installata totale. |
| Sostenibilità | Copertura cloud+pagamenti, tempo assistenza e costo fiscale noto | Fermare l'espansione commerciale se costa più gestire gli incassi che mantenerla gratuita. |
| Uso e spesa | Read/DAU, write/operazione, storage/account conservato, byte/sessione e picchi | Sostituire le ipotesi di questo studio con dati misurati. |

Oggi non è presente un sistema di product analytics dedicato individuato. Non usare Crashlytics per riversare dettagli di consumo e inventari a fini marketing. Per le metriche iniziali preferire dati aggregati strettamente necessari, report Play e feedback volontario; se si aggiunge telemetria, ridefinire base giuridica, consenso quando richiesto, privacy e Data safety prima dell'invio.

## 5. Modifiche tecniche necessarie

Non implementate in questo studio. Queste attività riguardano soprattutto il Billing; **ipotesi 5–10 giorni più test su store e margine per review**, da rivalutare. Misuratore d'uso, backend contatori e pubblicità della sezione 7 richiedono lavoro aggiuntivo non compreso in questa stima.

1. **Prodotti e client.** In Play configurare il prodotto Plus con piani annuale/mensile e, se scelto, un prodotto una tantum non consumabile. Integrare un plugin Flutter Billing mantenuto e verificare la versione Android Billing effettivamente inclusa rispetto ai requisiti correnti. Prezzi visualizzati dai dettagli Play, non hardcoded; termini/rinnovo, ripristino acquisti e accesso alla gestione abbonamento visibili. [Integrazione Billing](https://developer.android.com/google/play/billing/integrate).
2. **Backend di verifica.** Endpoint autenticato riceve `purchaseToken`, verifica package/prodotto/stato presso Play Developer API, associa la transazione a un solo account Vinoozy e impedisce riuso/replay. Credenziali solo sul server, mai nel client o nel repository. Concedere diritto soltanto a stato pagato verificato. Il flag locale `premium=true` non è un'autorità. [Sicurezza acquisti](https://developer.android.com/google/play/billing/security).
3. **Acknowledgement.** Persistenza idempotente e conferma acquisto dopo concessione verificata; gestire retry e interruzioni. In generale l'acknowledgement deve arrivare entro tre giorni, con condizioni specifiche del prodotto e dello stato; gli acquisti `PENDING` non sbloccano premium. [Integrazione e acknowledgement](https://developer.android.com/google/play/billing/integrate).
4. **Lifecycle.** RTDN autenticata dal canale previsto, deduplicata e seguita da lettura Play API: il messaggio non è da solo lo stato completo. Gestire rinnovo, cancellazione con diritto fino alla scadenza, grace period, account hold, pausa, scadenza, rimborso/revoca e riconciliazione periodica. [RTDN](https://developer.android.com/google/play/billing/rtdn-reference), [abbonamenti](https://developer.android.com/google/play/billing/subscriptions).
5. **Diritti Firestore.** Proposta schema `entitlements/{uid}` con prodotto, stato verificato, scadenza e ultimo aggiornamento; scrittura solo backend, lettura solo utente autorizzato. Dati/token acquisto in raccolta privata server, senza esporre token a membri della cantina. Cloud Admin SDK bypassa le regole: controllare IAM e validazioni nel backend. Per funzioni collaborative valutare il diritto del proprietario della cantina e accesso dei membri separatamente.
6. **Regole e limiti affidabili.** Negare al client modifiche di piano/scadenza, proteggere creazione cantine e aumento membri con diritti verificati e invarianti atomici. Non contare una collection con scansioni per ogni salvataggio: per un limite in quantità serve un contatore mantenuto e verificato atomicamente, oppure percorso server affidabile. La revoca premium non deve negare la lettura della propria cantina o la cancellazione. Letture aggiuntive dei diritti vanno aggiunte al modello di costo.
7. **Offline.** Cache dei diritti per una finestra dichiarata, **ipotesi 7 giorni**, con ultima verifica/scadenza; distinguere UX locale e autorizzazione server. Non applicare una scadenza fittizia alle persone offline né promettere enforcement forte per algoritmi esclusivamente locali: un client modificato può aggirarli. Sincronizzazioni rifiutate devono essere recuperabili e spiegate.
8. **Account e privacy.** Decidere come ripristinare un acquisto con account Google Play diverso dal login Vinoozy, cambio telefono e cancellazione/reiscrizione. Prevenire furto del diritto tramite token ripetuto. Separare eliminazione dei dati app, gestione abbonamento e conservazione minima documentale giustificata. Aggiornare testi in tre lingue e gestione richieste.

### Test essenziali del futuro pagamento

| Area | Casi che devono passare |
|---|---|
| Play test tracks e license tester | Acquisto annuale/mensile, una tantum se introdotto, ripristino, installazione Play e prezzo/localizzazione corretti; flussi annullati/pending |
| Verifica server | Token falso, package/prodotto sbagliato, replay su altro UID, doppio messaggio, race, backend non raggiungibile; nessun diritto con stato non pagato |
| Lifecycle | Rinnovo, cancellazione senza perdita anticipata, grace/hold, scadenza, rimborso/revoca, notifica fuori ordine e riconciliazione |
| Regole Firestore emulator | Utente gratuito che tenta scrittura diretta premium, diritto scaduto, membro invitato, titolare premium, riduzione piano; accesso ai propri dati e cancellazione sempre preservati |
| Offline/riavvio | Acquisto pagato mentre app chiusa, perdita rete, cache diritti, coda scritture, secondo dispositivo, cambio account, reinstallazione |
| Privacy/UX | Nessun token/log di acquisto nei report pubblici; rinnovo e prezzo chiari; link gestione abbonamento/cancellazione; dati non eliminati quando scade Plus |

Questi sono test con rischi reali di addebito, frode e perdita di diritti: non semplici verifiche dello stesso flag scritto dall'implementazione. Usare tester e strumenti Play, non addebiti di produzione per provare il ciclo.

## 6. Decisioni e incertezze da risolvere

| Decisione | Responsabile | Evidenza richiesta |
|---|---|---|
| Passaggio Spark → Blaze, regione e budget | Proprietario Firebase | Spark comunicato il 10/11/2026; conferma Console, report reali e condizioni della sezione 8 prima del passaggio |
| Tasso letture e account inattivi | Sviluppo/proprietario | Misure aggregate e dimensioni reali, nessun inventario personale nei log |
| Fee effettiva e ricavi dell'altra app | Proprietario Play | Programma attivo, account associati, contratto e report Payments |
| Opportunità di monetizzare da sviluppatore in Italia | Proprietario e commercialista | Inquadramento scritto, stima oneri annuali, gestione IVA/report |
| Capacità e soglia pubblicitaria | Sviluppo/proprietario prodotto | Default v1: 15 schede e 0,005 €/mese di costo stimato; validazione dei coefficienti e migrazione non distruttiva, sezione 7 |
| Valore dell'annuale | Utenti pilota | Richieste e conversione misurate, feedback sul rinnovo |
| Affiliazioni, ads, sponsor | Proprietario con consulenza per flusso/paese | Partner concreto e valutazione normativa, non solo una stima di ricavi |

## 7. Specifica per lo sviluppo: freemium e soglia pubblicitaria v1

**Stato: specifica di progetto, non implementazione.** Aggiornata il 9 novembre 2026 dopo il confronto sul freemium. I valori sotto sono default concreti per costruire e verificare la prima versione; vanno calibrati sui consumi e sui ricavi effettivi. Nessun accesso alla fatturazione o alle cantine di produzione è stato effettuato.

### 7.1. Comportamento del prodotto e parametri iniziali

| Parametro | Default v1 | Significato |
|---|---|---|
| `policyVersion` | `freemium-v1` | Identifica insieme regole, tariffe di budget e algoritmo di stima. |
| `capacityLimitEnabled` | `false` durante la misurazione | Attivare il limite solo dopo migrazione e controlli server. |
| `freeActiveWineLimit` | `15` | Schede attive nella cantina personale gratuita, non bottiglie fisiche. |
| `usageBudgetEuro` | `0.005` | Cinque millesimi di euro di costo cloud stimato a tariffa piena, per account e mese. **Non 0,50 € e non 5 €.** |
| `adsEnabled` | `false` al lancio | Consente di misurare senza inizializzare/caricare il modulo pubblicitario. |
| `maxAdRequestsPerUtcDay` | `1` | Un solo tentativo di caricamento pubblicitario per account e giorno, condiviso fra dispositivi. |
| `adPlacement` | Banner nella Dashboard | Un solo spazio visibile, senza refresh automatico. Nessun interstitial v1. |
| `usagePeriodTimeZone` | `UTC` | Mese di calendario: dal primo giorno alle 00:00 UTC al primo del mese seguente. |
| Plus | `1,99 €/mese` oppure `14,99 €/anno` | Rimuove pubblicità e limite commerciale di schede; prezzi effettivi letti dallo store. |

**Definizione di capacità:** una scheda di vino/annata con `quantity > 0` occupa un posto, indipendentemente dal numero di bottiglie che contiene. Sei bottiglie della stessa scheda occupano un posto. Una scheda con quantità zero resta nello storico/archivio e non occupa un posto attivo. Più schede duplicate occupano più posti finché non vengono unite; non introdurre una deduplicazione automatica distruttiva. Le cantine di altri proprietari condivise con l'utente non occupano posti della sua cantina personale.

Per i dati già esistenti alla data di attivazione registrare sul server `legacyActiveWineLimit = max(15, schedeAttiveEsistenti)`. Il limite gratuito effettivo è questo valore, congelato alla migrazione: nessuna eliminazione o occultamento di vini già salvati. Permettere aggiornamenti, aumento delle quantità su schede già attive, riduzione, archivio, cancellazione e accesso ai dati. Bloccare soltanto operazioni che aumenterebbero il numero di schede attive oltre il limite effettivo, inclusa la riattivazione di una scheda archiviata. Dopo scadenza Plus conservare anche i vini aggiunti durante l'abbonamento; consentire nuove schede attive solo quando si rientra nel limite gratuito effettivo.

Il contatore delle schede attive richiede un'invariante atomica sul server, da applicare a tutti i percorsi di creazione, modifica quantità, unione e cancellazione, anche se l'azione arriva da un membro invitato. Non basta disabilitare il pulsante. In caso di conflitto fra dispositivi, conservare la bozza o la modifica locale e spiegarne la mancata sincronizzazione; non perdere dati e non presentare come sincronizzato un inserimento rifiutato. Le vecchie versioni devono seguire una migrazione compatibile con le regole esistenti, oppure un aggiornamento esplicito prima dell'attivazione del limite.

La soglia pubblicitaria, invece, riguarda **l'account che effettua le operazioni**, comprese le sue letture di cantine condivise. Le letture ricevute su dispositivi diversi sono operazioni distinte. La modifica fatta da una persona e l'aggiornamento ricevuto da un'altra possono generare rispettivamente scritture e letture, senza attribuire entrambe al proprietario. Plus esenta dagli annunci il titolare dell'abbonamento; la condivisione ampliata è un beneficio separato e non estende automaticamente l'esenzione pubblicitaria agli invitati.

### 7.2. Quote Firebase e soglia personale hanno ruoli diversi

Firestore Standard include 50.000 letture, 20.000 scritture e 20.000 cancellazioni al giorno, 1 GiB di storage e 10 GiB/mese di trasferimento in uscita, nelle condizioni descritte nella sezione 1. Le quote operative giornaliere si azzerano secondo il fuso Pacifico e sono condivise dal progetto/database pertinente: **non sono un credito per ciascun account Vinoozy**. Su Spark gli annunci non sbloccano le operazioni oltre quota; per pagare l'eccedenza occorre abilitare la fatturazione/Blaze. Le quote gratuite restano anche su Blaze. [Fatturazione Firestore](https://firebase.google.com/docs/firestore/pricing), [piani Firebase](https://firebase.google.com/docs/projects/billing/firebase-pricing-plans).

Il mese UTC della soglia personale è una regola di prodotto indipendente dal reset giornaliero Firebase. La UI visualizza il prossimo reset nella data/ora locale dell'utente, senza assumere che sia mezzanotte italiana.

Usare due controlli separati:

1. **Personale:** stima cumulativa di uso cloud per decidere l'idoneità agli annunci; non interrompe operazioni né fattura l'utente.
2. **Globale:** consumi reali, costi, picchi e ricavi per decidere sostenibilità, passaggio di piano e attivazione del modulo. Alert iniziale quando letture o scritture giornaliere raggiungono l'80% delle rispettive quote, oltre agli alert di costo. L'alert non è un blocco di spesa.

Non dividere 50.000 per il numero di utenti per imporre una soglia personale: sessioni, giorni attivi e popolazione cambiano. Non abbassare la soglia di un utente durante il mese perché sono arrivati altri utenti.

### 7.3. Formula della soglia: sommare letture, scritture e traffico

Per ogni account `u` e mese UTC `m` memorizzare:

| Variabile | Unità | Contenuto |
|---|---|---|
| `R_hat(u,m)` | Letture stimate | Documenti, letture accessorie delle regole e indici quando applicabili, secondo 7.5. |
| `W_hat(u,m)` | Scritture stimate | Numero di `set`/`update` di documenti confermati, non numero di click o batch. |
| `B_hat(u,m)` | Byte stimati | Dati in uscita da Firestore verso il dispositivo, inclusi aggiornamenti dei listener. |
| `C_hat(u,m)` | Euro di budget | Costo teorico a tariffa piena: serve a confrontare usi diversi, non è la fattura attribuita all'utente. |

Tariffe di budget riprese dal modello Milano della sezione 1: `pR = 0,035 USD/100.000`, `pW = 0,104 USD/100.000`, `pB = 0,12 USD/GiB`. Per rendere i numeri confrontabili con l'eCPM in euro si mantiene **l'ipotesi convenzionale `fx = 1 EUR/USD`**, non un cambio di mercato. Regione effettiva e SKU EUR vanno confermati prima di usare queste tariffe in produzione; prezzi di default Iowa non sostituiscono quelli Milano. [Listino ufficiale](https://cloud.google.com/firestore/pricing).

```text
GiB = 1_073_741_824 byte

C_hat(u,m) = fx * (
    R_hat(u,m) * 0.035 / 100_000
  + W_hat(u,m) * 0.104 / 100_000
  + B_hat(u,m) * 0.12 / GiB
)

T = 0.005 EUR/mese
aboveThreshold(u,m) = C_hat(u,m) > T
```

**La soglia si supera strettamente:** a `C_hat = T` nessun annuncio; dalla prima operazione che porta `C_hat > T` l'account gratuito diventa idoneo. Non caricare un annuncio mentre si completa quell'operazione: attendere la successiva apertura della Dashboard e i controlli della sezione 7.7. L'idoneità resta fino al reset mensile, anche nei giorni seguenti con poco uso.

Calcolare con aritmetica decimale o razionale senza arrotondare ogni singola operazione ai centesimi. Le letture costano frazioni di centesimo: arrotondandole a zero la soglia non verrebbe mai superata. Arrotondare soltanto le cifre mostrate nei report. Salvare contatori e versione delle tariffe, non soltanto un costo arrotondato.

La formula **non sottrae la quota gratuita Firebase a ogni account**. È una misura stabile dell'uso, anche quando la fattura reale è zero. La fattura complessiva usa invece le franchigie giornaliere della sezione 1. Il testo UI deve quindi parlare di contributo ai costi del servizio e mai di un debito o di una fattura causata dal singolo utente.

**Perché iniziare da 0,005 €:** è una scelta di prodotto che lascia un margine generoso all'uso leggero. Nel modello pubblicitario centrale di 2 € eCPM, un'impression vale 0,002 €; la fascia senza annunci corrisponde quindi al valore teorico di 2,5 impression. È una base di esperimento, non una soglia economicamente ottimale dimostrata. Sotto soglia si accetta un costo sostenuto dalle quote condivise, dal budget del progetto e dagli eventuali abbonamenti.

Sono esclusi dalla soglia personale cancellazioni e richieste di eliminazione account, esportazione dei propri dati, migrazioni automatiche, recuperi dovuti a errori dell'app, operazioni del misuratore e backend acquisti/pubblicità. Si conteggiano comunque nel costo globale. Storage di account attivi/inattivi e costi fissi non devono far comparire annunci a chi non sta usando l'app. Le scritture funzionali necessarie a un'azione ordinaria, inclusi i contatori di capacità, rientrano invece in `W_hat`.

### 7.4. Esempi numerici e primo superamento

Gli esempi assumono le tariffe e il cambio convenzionale di 7.3, senza quote gratuite personali. Sono simulazioni, non misure di una sessione reale.

| Caso isolato, altre voci zero | Ultimo valore sotto soglia | Primo valore oltre soglia |
|---|---:|---:|
| Sole letture | 14.285 → 0,00499975 € | **14.286 → 0,00500010 €** |
| Sole scritture | 4.807 → 0,00499928 € | **4.808 → 0,00500032 €** |
| Solo traffico in uscita | 44.739.242 byte | **44.739.243 byte**, circa 42,667 MiB |

Esempio vicino a una piccola cantina: un caricamento completo ipotetico genera **20 letture complessive** (15 schede più letture accessorie stimate) e **30 KiB in uscita**. Non si assume che ciascun avvio dell'app generi questo caricamento.

```text
costo_caricamento = 20 * 0.035 / 100_000
                  + 30 * 1024 * 0.12 / 1_073_741_824
                  = 0.0000104332275390625 EUR

primo_superamento = floor(0.005 / costo_caricamento) + 1
                  = 480 caricamenti nel mese

479 caricamenti: 0.0049975159912109375 EUR → sotto soglia
480 caricamenti: 0.0050079492187500000 EUR → oltre soglia
```

Con un **ciclo misto ipotetico di 20 letture totali, 1 scrittura e 32 KiB totali in uscita**, il costo è `0,000011702109375 €`: il primo superamento avviene al **428° ciclo**. Le 20 letture comprendono quelle del ciclo intero, inclusi gli aggiornamenti; non aggiungere di nuovo gli stessi documenti come effetto della scrittura.

| Profilo mensile simulato | `R_hat` | `W_hat` | `B_hat` | `C_hat`, arrotondato per la tabella | Stato |
|---|---:|---:|---:|---:|---|
| Leggero | 600 | 20 | 940 KiB | 0,00033837 € | Senza annunci |
| Regolare | 3.600 | 100 | 5.600 KiB | 0,00200487 € | Senza annunci |
| Intenso | 12.000 | 600 | 19.200 KiB | 0,00702127 € | Idoneo oltre soglia |
| Molto intenso | 60.000 | 3.000 | 96.000 KiB | 0,03510633 € | Idoneo oltre soglia; stesso tetto pubblicitario |

Non tradurre questi numeri in «dopo N aperture compare la pubblicità»: con cache, storico, condivisioni e dimensioni differenti, lo stesso numero di aperture può produrre consumi molto diversi.

### 7.5. Come stimare i consumi nel codice esistente

Il client Firestore non fornisce un contatore esatto della fattura per UID. Anche il dashboard d'uso può differire dal report di billing, che resta il riferimento finale. **Il misuratore v1 è una stima di prodotto, non un sistema di fatturazione né una protezione economica contro client modificati.** [Monitoraggio e limiti Firestore](https://firebase.google.com/docs/firestore/quotas).

Introdurre un servizio `CloudUsageMeter`, testabile senza rete, nei repository e negli adattatori di sincronizzazione. Contare l'operazione una volta nel punto in cui parte/riceve conferma; i provider/UI consumatori non devono moltiplicarla.

Strumentare gli snapshot Firestore prima della trasformazione nei modelli di dominio: dopo il mapping possono andare persi origine, `docChanges` e metadati necessari a distinguere cache e server. Gli adattatori che non espongono questi dati richiedono un'estensione prima di poter alimentare il misuratore.

| Punto del progetto | Regola v1 |
|---|---|
| `lib/cellar/data/wine_repository.dart`, listener e query | Primo snapshot dal server della singola sottoscrizione: `max(1, documenti)` come stima iniziale. Successivamente contare documenti aggiunti/modificati e uscite per modifica del filtro; una cancellazione riconosciuta non aggiunge letture del documento. Eventi solo cache e soli metadata successivi non aggiungono documenti. |
| `lib/app/providers.dart`, `lib/cellar/cellar_providers.dart`, Dashboard | Il listener condiviso conta una volta anche quando alimenta più schermate. Filtri, ordinamento e grafici locali non contano. Il dettaglio ha un listener separato: le sue vere letture restano distinte. |
| `lib/cellar/data/drinking_record_repository.dart` | Storico: contare la pagina effettivamente ricevuta dal server, con minimo una lettura per query vuota. `RecordsSource.cache` non conta. |
| `lib/cellar/data/server_or_cache.dart` | Strumentare la richiesta server originale prima di applicare il timeout: un fallback alla cache non cancella il consumo di una richiesta che termina più tardi sul server. Non contare due volte lo stesso completamento. |
| Scritture nei repository e nel ledger di sync | Contare i documenti `set`/`update` del batch quando confermati dal server, una volta per tentativo realmente completato. Una modifica soltanto in coda offline non conta ancora; al successivo invio conta nel mese della conferma. |
| `lib/sharing/data/sharing_repository.dart`, profilo, `lib/sync/sync_gateway.dart` | Includere query, listener e verifiche server dell'account; una sola azione può coinvolgere più documenti. Le attività automatiche di recupero guasti restano fra i costi di sistema. |
| Migrazioni e aggiornamenti stime automatici | Attribuire al contatore di sistema, separato da quello personale. |
| OCR, calcoli locali, catalogo OFF | Zero uso Firestore quando non c'è un'operazione Firestore. Le richieste OFF hanno limiti propri. |

**Letture delle regole:** usare una tabella versionata per percorso e operazione, senza moltiplicare l'accesso dipendente per ogni documento della stessa query. I commenti e le funzioni di `firestore.rules` indicano, per vini/storico, un documento dipendente per il proprietario e due per l'invitato nella richiesta valutata. Il flusso di gestione inviti ha accessi diversi. Aggiungere questi accessi alla stima della richiesta/query e delle rivalutazioni pertinenti, rispettando il riuso del medesimo documento; aggiornare la tabella quando si introducono contatori o diritti Plus. Un batch contiene più scritture ma può riusare accessi delle regole. Indici fatturabili e retry di transazioni vanno inclusi quando osservabili, altrimenti annotati fra gli scostamenti da calibrare.

**Limite dell'algoritmo listener:** un nuovo snapshot dal server non dimostra che tutti i documenti siano stati fatturati di nuovo. La stima iniziale può sovrastimare una ripresa breve; le riconnessioni lunghe e alcune rivalutazioni possono aggiungere letture non visibili. Conservare identità e ciclo di vita delle sottoscrizioni per deduplicare cache→server, modifiche locali→conferma e rebuild. La fatturazione documentata dopo una disconnessione superiore a 30 minuti è un caso da verificare in calibrazione, non un motivo per contare tutte le schermate. [Regole listener](https://firebase.google.com/docs/firestore/pricing#listening_to_query_results).

Per `B_hat`, v1 usa **2 KiB per documento ricevuto dal server** come fallback esplicito; il minimo di una lettura per query vuota non inventa un documento trasferito. Sostituire il fallback con la dimensione stimata della risposta quando disponibile, senza inviare il contenuto dei documenti nella telemetria. Non dedurre i byte dalle letture delle regole, che sono interne. Tutte le dimensioni sono stime: protocollo e addebiti effettivi vanno confrontati con i report aggregati.

Prima di attivare annunci, confrontare per almeno due settimane letture/scritture/byte stimati con metriche aggregate, distinguendo utenti e sistema. Un rapporto reale/stimato fuori da `0,8–1,2` è una soglia di verifica proposta: correggere i coefficienti e ripetere il confronto. Non pubblicare annunci attribuiti al superamento se il misuratore presenta doppi conteggi noti. Conservare tariffe e algoritmo della policy per tutto il mese; modifiche economiche o di soglia valgono dal mese successivo. Bug di conteggio vanno corretti subito, sospendendo gli annunci e rettificando i contatori coinvolti se necessario.

### 7.6. Persistenza, backend e più dispositivi

Schema proposto, interamente da implementare:

```text
usage/{uid}/periods/{YYYY-MM}
  policyVersion, estimatedReadCount, estimatedWriteCount,
  estimatedEgressBytes, updatedAt

usage/{uid}/periods/{YYYY-MM}/devices/{installationId}
  lastSequence, cumulativeReadCount, cumulativeWriteCount,
  cumulativeEgressBytes, updatedAt

adSlots/{uid}/days/{YYYY-MM-DD-UTC}
  reservationId, reservedAt, impressionAt?, outcome?

entitlements/{uid}
  stato e scadenza verificati come nella sezione 5
```

Il dispositivo mantiene contatori cumulativi locali per account, installazione e mese. Un endpoint autenticato e protetto da App Check riceve `installationId`, periodo, sequenza e cumulativi; l'UID deriva dall'autenticazione. In una transazione il backend applica soltanto la differenza rispetto all'ultimo cumulativo accettato di quel dispositivo e restituisce totale account, policy, ora server e prossimo reset. Sequenza ripetuta con gli stessi valori è idempotente; una più vecchia non aggiunge uso, una ripetuta con valori diversi è rifiutata. I cumulativi non possono diminuire. Una nuova installazione ha un nuovo ID ma si somma allo stesso account, senza azzerarlo.

Inviare un batch al passaggio in background/fine sessione, ogni 15 minuti durante sessioni lunghe e al primo superamento locale; non una scrittura Firestore per ogni lettura. Persistenza locale prima dell'invio e retry con gli stessi cumulativi. L'endpoint restituisce anche lo stato aggiornato, evitando un secondo listener per contare i consumi.

Per decidere localmente usare il totale server più **soltanto il delta locale successivo all'ultimo cumulativo riconosciuto**. Mai sommare totale server e tutto il totale locale. Il consumo di un altro dispositivo diventa visibile al prossimo scambio con il backend; prima di prenotare un annuncio caricare il delta e rivalutare il totale aggregato sul server. L'idoneità può arrivare in ritardo, mai giustificare un blocco dei dati.

I contatori della policy e i diritti Plus sono scritti solo dal backend. Il client può leggere soltanto il proprio stato; non può cambiare prezzo, totale aggregato o esenzione Plus. Il backend verifica formato, monotonia e frequenza, ma **un valore auto-riferito dal client non prova quante letture siano state fatturate**. Auth/App Check e questa soglia non sostituiscono regole, query efficienti e controllo dei costi globali. L'esenzione Plus deriva soltanto dal diritto verificato.

Usare l'ora server per periodo, scadenze e limite giornaliero. Alla mezzanotte UTC del nuovo mese passare a nuovi contatori senza cancellare quelli precedenti; non basta un timer mentre l'app è aperta. Le conferme di scritture offline appartengono al periodo in cui raggiungono il server. Upload tardivi di contatori già prodotti nel mese precedente aggiornano quel periodo senza riattivarne l'idoneità nel mese nuovo. Un vecchio messaggio o slot pubblicitario non può attraversare il reset.

Se stato, ora server, contatori o diritti non sono verificabili, **niente annunci nuovi e uso dell'app consentito**. Non attivare pubblicità da un dato scaduto o incerto. Recuperare lo stato alla riconnessione. L'enforcement del limite di inventario ha il proprio recupero bozze e non deve dipendere dal caricamento di un annuncio.

Conservare solo numeri, versioni, date e identificatori necessari: niente nomi dei vini, foto, note o token di acquisto nei contatori. Retention iniziale proposta 90 giorni per i dettagli di misurazione, con pulizia server e relativo costo globale; la conservazione amministrativa degli acquisti è separata. L'attuale `ConsoleAppEventLogger` non è un sistema di misura remoto e non va trasformato in un invio di dettagli a Crashlytics.

**Costo del misuratore:** una transazione ideale che legge stato dispositivo + aggregato e scrive entrambi comporta 2 letture e 2 scritture: `2 × 0,035/100.000 + 2 × 0,104/100.000 = 0,00000278 USD` a tariffa piena. A 30.000 upload/mese sono 0,0834 USD per queste sole operazioni. Aggiungere letture di configurazione/diritti, prenotazioni ads, rete, runtime, log, retention e retry; Cloud Functions/backend non sono inclusi in tale cifra. Questi consumi sono di sistema e non fanno crescere la soglia dell'utente. Un backend Cloud Functions richiede Blaze: non promettere questa architettura come interamente disponibile su Spark.

### 7.7. Decisione pubblicitaria e tetto di frequenza

```text
eligible = adsEnabled
           AND statoAccountEDirittiVerificato
           AND NOT plusVerificatoAttivo
           AND C_hat(account, meseCorrenteUTC) > usageBudgetEuro

canAttemptAd = eligible
               AND DashboardVisibile
               AND SDKConsenteRichiesteAds
               AND reteDisponibile
               AND nessunaOperazioneSensibileInCorso
               AND nessunaPrenotazioneAdsOggiUTC
```

`SDKConsenteRichiesteAds` comprende lo stato del flusso privacy/CMP e le condizioni applicabili all'inventario; non significa semplicemente «ha accettato annunci personalizzati». Il rifiuto della personalizzazione non autorizza a bloccare l'app o a bypassare il consenso richiesto. [Requisiti Google sul consenso](https://support.google.com/admob/answer/13554116?hl=it).

Flusso v1:

1. Al primo superamento mostrare una spiegazione nella Dashboard, una sola volta per periodo e account, senza popup durante un salvataggio. La stessa apertura può ospitare il banner se tutti i controlli sono soddisfatti.
2. Prima del caricamento prenotare sul backend lo slot `{uid, giornoUTC}` con transazione atomica, ricontrollando periodo, soglia, `adsEnabled` e diritto Plus. Solo un dispositivo ottiene la prenotazione. Se il backend non risponde non caricare l'annuncio.
3. La prenotazione consente **un caricamento SDK**; consuma il tentativo giornaliero anche in caso di mancato riempimento o errore. Nessun ciclo di retry pubblicitario e nessun ulteriore tentativo quel giorno. Il sistema può quindi mostrare meno di un annuncio al giorno, mai prometterne il ricavo.
4. Il banner rimane nello spazio della Dashboard finché quella vista è aperta; non chiuderlo istantaneamente al callback di impression. Alla navigazione fuori Dashboard/background rimuoverlo e fare dispose. Non ricaricarlo alle successive visite dello stesso giorno. Disabilitare il refresh automatico anche nella configurazione AdMob per rispettare il tetto. [Banner Flutter](https://developers.google.com/admob/flutter/banner).
5. Registrare separatamente richiesta, caricamento riuscito, impression e, quando disponibile, ricavo stimato con valuta/precisione. `onAdLoaded` non equivale a un'impression o a un ricavo. Deduplicare i callback con la prenotazione; riconciliare i ricavi con AdMob. [Callback banner](https://developers.google.com/admob/flutter/banner), [ricavi e callback native ads](https://developers.google.com/admob/flutter/native/platforms).
6. Con acquisto Plus verificato rimuovere il banner e annullare eventuali caricamenti immediatamente, prima di mostrare contenuti caricati. Con scadenza Plus rivalutare la soglia del mese: l'uso accumulato continua anche mentre Plus è attivo, ma l'esenzione prevale finché il diritto è valido. Al reset mensile l'idoneità si azzera indipendentemente dagli annunci già visti.

Nessun annuncio in scanner, form, conferma salvataggio, esportazione o eliminazione account; nessun obbligo di vedere/cliccare un annuncio per conservare o sincronizzare i propri dati. Interstitial e rewarded ads sono fuori dalla v1. L'interruttore globale può spegnere subito nuovi caricamenti e rimuovere banner attivi in caso di errore, senza modificare la soglia in corso.

### 7.8. Testi UI

Alla prima presentazione del piano gratuito, quando il modulo viene attivato:

> Puoi gestire gratuitamente fino a 15 vini diversi. L'uso leggero è senza pubblicità. Se superi la soglia mensile di utilizzo del servizio, potresti vedere annunci occasionali che contribuiscono ai costi dei server e della sincronizzazione. Con Plus elimini gli annunci e il limite di cantina.

Al superamento:

> **Gli annunci aiutano a mantenere Vinoozy gratuito**
>
> Hai raggiunto la soglia mensile di utilizzo senza pubblicità. Da questo momento potresti vedere annunci occasionali: ci aiutano a coprire i costi dei server e della sincronizzazione, mantenendo Vinoozy gratuito.
>
> Il conteggio si azzera il prossimo mese. Con Plus puoi usare l'app senza pubblicità e senza il limite di cantina.

Mostrare il prossimo reset con data/ora locale e i collegamenti «Come funziona» e «Scopri Plus». Nella spiegazione aggiuntiva indicare che la soglia dipende da una stima delle sincronizzazioni e che l'uso offline non genera da solo nuove operazioni cloud; non serve esporre formule o prezzi dei documenti nel normale percorso. Nel piano di lancio con modulo disattivato usare «Nessuna pubblicità nella versione di lancio», senza promettere assenza di annunci per sempre. Non promettere Plus acquistabile prima che Billing sia disponibile.

### 7.9. Verifica matematica della copertura economica

Definire `D_u` come numero di giorni del mese in cui un account gratuito è già oltre soglia **e** apre una Dashboard idonea. Non usare tutti i giorni del mese, tutte le sessioni o tutti i MAU come se producessero impression.

```text
tentativi_massimi_mese = somma_u D_u
impression_attese     = tentativi_massimi_mese * q
ricavo_ads_atteso_EUR = impression_attese / 1000 * eCPM_publisher_EUR
```

`q` comprende inventario disponibile, esito SDK e reale visualizzazione dopo i controlli di consenso/posizionamento. Le esenzioni Plus sono già escluse da `D_u`. Assunzioni di simulazione: `q = 60%`, eCPM publisher `1 / 2 / 3 €`. Non sono benchmark verificati; il ricavo effettivo può essere zero. L'eCPM è già la resa al publisher: non sottrarre di nuovo una commissione Play.

Esempio di 30 giorni, con cicli uniformi da `20 letture + 1 scrittura + 32 KiB`:

| Utilizzo simulato | Primo superamento | Giorni idonei con visita dopo il superamento | Impression attese al 60% | Ricavo a eCPM 1 / 2 / 3 € | Costo teorico mensile `C_hat` |
|---|---|---:|---:|---:|---:|
| 20 cicli/giorno, 600 nel mese | 428° ciclo, giorno 22 | 9 | 5,4 | 0,0054 / 0,0108 / 0,0162 € | 0,00702127 € |
| 100 cicli/giorno, 3.000 nel mese | 428° ciclo, giorno 5 | 26 | 15,6 | 0,0156 / 0,0312 / 0,0468 € | 0,03510633 € |
| 600 cicli tutti il giorno 30 | 428° ciclo, giorno 30 | 1 | 0,6 | 0,0006 / 0,0012 / 0,0018 € | 0,00702127 € |

I giorni indicati presumono che resti una visita idonea alla Dashboard nel giorno del superamento. Se non c'è, quel giorno non produce neppure un tentativo. I valori di impression sono medie attese su coorti, non frazioni di un annuncio mostrato alla singola persona. Nel caso centrale intenso il ricavo simulato supera il costo a tariffa piena; nel caso molto intenso e in quello concentrato a fine mese può non bastare. Il tetto pubblicitario resta uguale: non aumentare automaticamente la pressione pubblicitaria per inseguire i costi.

**Anche molti utenti leggeri possono superare le quote globali senza vedere annunci.** Esempio: 10.000 utenti, ciascuno con il profilo regolare di 7.4, sono tutti sotto 0,005 €. Con traffico uniforme su 30 giorni, 1 MiB di storage per account e nessun altro costo:

| Voce globale | Volume | Costo modellato oltre quota, USD |
|---|---:|---:|
| Letture | 36.000.000/mese, 1.200.000/giorno | 12,075000 |
| Scritture | 1.000.000/mese | 0,416000 |
| Traffico in uscita | 53,405762 GiB/mese | 5,208691 |
| Storage | 9,765625 GiB | 1,525219 |
| **Totale** | Nessun account oltre soglia personale | **19,224910 USD/mese**, circa 19,22 € solo con il cambio convenzionale |

Questo modello contribuisce ai costi ma **non garantisce l'autofinanziamento di tutta l'infrastruttura**. I consumi sotto soglia e gli account inattivi richiedono un budget residuo o ricavi Plus. Il controllo mensile è:

```text
margine_infra = ricavo_ads_effettivo
              + ricavo_Plus_allocato_all_infrastruttura
              - costo_Firebase_effettivo
              - costo_backend_misuratore_acquisti_ads
              - altri_costi_infrastruttura

copertura_infra = ricavi_allocati_infra / costi_infra   # se costi_infra > 0
```

Per prevedere il fabbisogno pubblicitario, `impression_necessarie = ceil(1000 * costo_residuo_EUR / eCPM_EUR)`. Con 5 € residui ed eCPM 2 € servono 2.500 impression; con `q=60%` occorrono almeno 4.167 tentativi idonei, compatibili con i giorni disponibili dopo soglia. In alternativa l'annuale Plus del modello della sezione 2 contribuisce circa 0,87 €/mese equivalente per pagante, prima degli altri costi. Se manca copertura, rivedere budget, efficienza, prezzo o policy per i periodi futuri; non presentare la pubblicità come un limite alla fattura Firebase.

### 7.10. Sequenza di sviluppo e attivazione

1. **Misurazione:** introdurre `CloudUsageMeter`, contatori locali e report aggregati, con `adsEnabled=false` e `capacityLimitEnabled=false`. Confermare piano, regione, SKU e budget globale. Se si sceglie il backend Cloud Functions, predisporre Blaze prima del suo utilizzo. Non inizializzare SDK ads in questa fase.
2. **Validazione:** eseguire i casi di 7.11, misurare per almeno due settimane e correggere doppi conteggi/scostamenti. Congelare una policy mensile versionata; pubblicare il comportamento nelle informazioni del piano gratuito. Valutare il costo aggiuntivo della misura, senza assumere che sia zero.
3. **Capacità e Plus:** migrazione dei limiti legacy, invariante server e recupero offline; acquisti verificati, scadenze e ripristino come nella sezione 5. Abilitare ciascun componente solo dopo i suoi controlli, senza attendere che tutte le estensioni Plus siano già state costruite.
4. **Annunci:** integrare CMP, spazio Dashboard, prenotazione account/giorno e callback; aggiornare privacy, Data safety e dichiarazione ads. Usare ID pubblicitari di test durante lo sviluppo. Confermare l'idoneità dell'inventario secondo le policy citate in sezione 2. Attivare `adsEnabled` in un rollout limitato quando il modulo è pronto e i costi osservati/previsionali ne motivano l'uso; nessun numero di MAU lo rende automaticamente necessario.
5. **Riesame mensile:** confrontare soglia, quota di utenti idonei, giorni effettivamente disponibili, ricavi e costo globale. Conservare il tetto giornaliero; una nuova soglia o nuove tariffe di budget entrano in vigore dal mese successivo e vengono spiegate. Il comando di spegnimento resta immediato.

### 7.11. Criteri di accettazione e calcolo riproducibile

| Caso da verificare nello sviluppo | Risultato atteso |
|---|---|
| `C_hat < T`, `C_hat = T`, `C_hat > T` | Idoneità soltanto nell'ultimo caso; nessun arrotondamento anticipato. Esempio di uguaglianza esatta: 14.256 letture + 10 scritture + zero byte. |
| 14.285/14.286 letture isolate; 4.807/4.808 scritture isolate | Primo valore sotto e secondo sopra soglia. |
| 479/480 caricamenti; 427/428 cicli misti | Confine identico agli esempi di 7.4. |
| Stesso listener consumato da Cantina e Dashboard | Nessuna duplicazione dei consumi. |
| Cache, metadata, filtro locale, modifica offline | Nessun falso caricamento server; scrittura conteggiata alla conferma. |
| Query vuota e query server che termina dopo fallback cache | Minimo di lettura previsto e conteggio del completamento server, una sola volta. |
| Scrittura batch con più documenti; regole riusate | Numero documenti corretto, senza moltiplicare accessi dipendenti riusati. |
| Retry upload, sequenza vecchia, reinstallazione e due dispositivi | Nessun doppio conteggio o reset dell'account; somma dei soli delta nuovi. |
| Due dispositivi chiedono l'annuncio insieme | Una sola prenotazione/account/giorno; refresh automatico disabilitato. |
| No fill, errore SDK, assenza consenso applicabile o rete | Uso dell'app invariato; nessun loop di richieste, nessun ricavo presunto. |
| Plus attivo, appena acquistato, in grace period valido, scaduto | Nessun annuncio con diritto valido; alla scadenza rivalutare la soglia corrente. |
| Cambio mese, fuso italiano, ora legale, orologio dispositivo alterato | Periodo UTC server, reset corretto e nessuno slot del mese vecchio riutilizzato. |
| Migrazione, esportazione ed eliminazione account | Operazioni sempre accessibili, spesa attribuita al sistema per la soglia personale. |
| Sedicesima scheda, aumento quantità esistente, riattivazione archivio, conflitto offline | Applicare il limite alle sole variazioni di capacità; conservare bozze e dati in caso di rifiuto. |
| Costi globali oltre quota con tutti gli utenti sotto soglia | Alert globale e revisione del budget; nessuna falsa garanzia di copertura ads. |

Script Python 3 senza dipendenze per riprodurre i confini e i costi principali. **Verifica il modello matematico, non i consumi reali del progetto.**

```python
from decimal import Decimal, ROUND_FLOOR, ROUND_CEILING

D = Decimal
GIB = D(2) ** 30
PR = D("0.035") / 100_000
PW = D("0.104") / 100_000
PB = D("0.12") / GIB
T = D("0.005")
FX = D("1")  # EUR/USD convenzionale, non cambio verificato

def cost(reads, writes, out_bytes):
    return FX * (D(reads) * PR + D(writes) * PW + D(out_bytes) * PB)

def first_over(unit_cost):
    return int((T / unit_cost).to_integral_value(rounding=ROUND_FLOOR)) + 1

assert cost(14285, 0, 0) < T < cost(14286, 0, 0)
assert cost(0, 4807, 0) < T < cost(0, 4808, 0)
assert cost(0, 0, 44739242) < T < cost(0, 0, 44739243)
# Caso di costo esattamente uguale alla soglia, ancora senza annunci.
assert cost(14256, 10, 0) == T

load = cost(20, 0, 30 * 1024)
cycle = cost(20, 1, 32 * 1024)
assert first_over(load) == 480
assert first_over(cycle) == 428
assert 479 * load < T < 480 * load
assert 427 * cycle < T < 428 * cycle

profiles = [
    ("leggero", 600, 20, 940),
    ("regolare", 3600, 100, 5600),
    ("intenso", 12000, 600, 19200),
    ("molto_intenso", 60000, 3000, 96000),
]
for name, r, w, kib in profiles:
    c = cost(r, w, kib * 1024)
    print(name, c, "oltre_soglia=", c > T)

for cycles_per_day in (20, 100):
    crossing_day = (first_over(cycle) + cycles_per_day - 1) // cycles_per_day
    eligible_days = max(0, 31 - crossing_day)  # mese di 30 giorni
    revenue = D(eligible_days) * D("0.6") * D("2") / 1000
    print("giorno_superamento", crossing_day,
          "giorni_idonei", eligible_days, "ricavo_atteso_EUR", revenue)

# 10.000 utenti regolari, traffico uniforme: franchigie per ogni giorno.
n = 10000
global_cost_usd = (
    sum(max(D(0), D(n * 3600) / 30 - 50000) * PR for _ in range(30))
    + sum(max(D(0), D(n * 100) / 30 - 20000) * PW for _ in range(30))
    + max(D(0), D(n * 5600 * 1024) / GIB - 10) * D("0.12")
    + max(D(0), D(n) / 1024 - 1) * D("0.174")
)
assert abs(global_cost_usd - D("19.22491015625")) < D("0.000000001")
print("costo_globale_USD", global_cost_usd)
needed_impressions = int((1000 * D("5") / D("2")).to_integral_value(
    rounding=ROUND_CEILING))
needed_attempts = int((D(needed_impressions) / D("0.6")).to_integral_value(
    rounding=ROUND_CEILING))
assert (needed_impressions, needed_attempts) == (2500, 4167)
```

## 8. Previsioni economiche e passaggio Spark → Blaze

**Aggiornamento: 10 novembre 2026. Obiettivo: coprire l'infrastruttura anche dopo il passaggio a Blaze, rendendo visibili le condizioni in cui si perde.** Tutti gli scenari sono simulazioni condizionate alle ipotesi dichiarate, non previsioni di acquisizione o garanzie di guadagno. Questa sezione aggiunge i costi operativi e il modello pubblicitario oltre soglia agli esempi precedenti; per decidere il budget usare queste tabelle complete, non i soli ricavi della sezione 2.

### 8.1. Stato attuale e cosa cambia passando a Blaze

- **Oggi: Spark**, come comunicato dal proprietario. Entro le quote dei prodotti usati, Firestore non genera una fattura a consumo. Eventuali dominio, amministrazione e lavoro restano costi separati anche se Firebase è gratuito.
- **Domani: Blaze**, da predisporre prima di esaurire le quote, secondo 8.7. Mantiene le quote gratuite pertinenti: il passaggio non fa pagare da zero tutte le letture. Si paga il consumo fatturabile eccedente e quello di eventuali servizi aggiuntivi. [Piani Firebase](https://firebase.google.com/docs/projects/billing/firebase-pricing-plans), [quote Firestore](https://firebase.google.com/docs/firestore/pricing).
- **Backend acquisti/misuratore:** se serve Cloud Functions, Blaze può essere necessario prima che Firestore si avvicini alla propria quota. Questo anticipo va previsto come fase tecnica e finanziata; non assumere che sia possibile incassare abbonamenti tramite l'architettura proposta restando su Spark.

Le tabelle seguenti descrivono **Blaze con moduli futuri attivi**, non la fattura attuale Spark. Il costo minimo Google può essere zero in un mese entro tutte le quote: i budget backend usati sotto non sono canoni Google obbligatori.

### 8.2. Ipotesi comuni, ricavi disponibili e formule

`N` indica gli utenti attivi mensili totali; `P` i paganti inclusi in `N`; `F = N - P` i gratuiti. Le coorti restano stabili per un mese di 30 giorni, con traffico uniforme. Gli scenari annualizzati mantengono tali condizioni per 12 mesi; non descrivono un primo anno di crescita progressiva.

| Parametro | Scenario centrale | Stress economico |
|---|---|---|
| Utenti gratuiti | 90% profilo regolare + 10% intenso di 7.4 | Tutti con profilo intenso |
| Utenti Plus | Tutti con profilo molto intenso di 7.4 | Stesso profilo molto intenso |
| Account conservati | `N`, con 1 MiB medio ciascuno | `3 × N`, con 1 MiB medio ciascuno |
| Pubblicità | Solo gratuiti intensi, 9 giorni idonei/mese, `q=60%`, eCPM 2 € | Ricavi ads **zero** |
| Upload misuratore | 30/account attivo/mese, ciascuno 2 letture + 2 scritture | Stessa ipotesi |
| Prenotazioni ads | 9/gratuito intenso/mese, ciascuna 4 letture + 1 scrittura | Stessi tentativi, senza ricavo |
| Backend extra, runtime, rete e log | Budget operativo 10 €/mese | Budget operativo 15 €/mese |
| Dominio e altri costi statici | Budget 2 €/mese | Budget 2 €/mese |
| Rettifica ricavi Plus | 5% per rimborsi/insoluti | 5% |
| Cambio di budget | `1 USD = 1 EUR` | Stessa convenzione, non un cambio garantito |

Sono assunzioni modificabili. I profili includono le operazioni funzionali, anche accessorie, già stimate; misuratore e prenotazioni sono aggiunti qui per non dimenticarli. Le letture dei diritti nella prenotazione sono comprese nelle quattro letture ipotizzate. Il budget backend extra **esclude** le operazioni Firestore già aggiunte e comprende invece runtime, traffico delle API, configurazione, log e attività operative non rappresentate nei profili. Storage medio comprende dati e metadati del misuratore come ipotesi, non dimensione verificata. Se questi budget sono superati vanno sostituiti con i costi reali: 10/15 € non sono tetti imposti al fornitore.

Per conservare i conti riproducibili, nel modello numerico sono zero le cancellazioni ordinarie fatturabili e sono esclusi backup/PITR/TTL, foto cloud, marketing, servizi professionali ulteriori e sviluppo iniziale. Eventuali costi reali di queste voci vanno aggiunti prima di usare il risultato per una decisione. Non trattare l'esclusione come una loro gratuità.

Ricavi Plus: prezzo cliente con IVA italiana 22% e commissione complessiva 15% sono le ipotesi della sezione 2. La struttura delle commissioni va verificata per il proprio account; il 5% seguente è una **rettifica prudenziale del modello**, non un'ulteriore commissione Play. [Commissioni Play](https://support.google.com/googleplay/android-developer/answer/112622?hl=en).

```text
r_annuale_mese = 14.99 / 1.22 × 0.85 × 0.95 / 12
               = 0.8268049863 EUR per pagante/mese equivalente

r_mensile      = 1.99 / 1.22 × 0.85 × 0.95
               = 1.3171516393 EUR per pagamento mensile

R_Plus = P_annuali × r_annuale_mese + P_mensili × r_mensile
R_ads_centrale = gratuiti_intensi × 9 × 0.60 × 2 / 1000
              = gratuiti_intensi × 0.0108 EUR/mese

C_infra_centrale = C_Firestore_con_quote + 10 + 2
C_infra_stress   = C_Firestore_stress_con_quote + 15 + 2

M_infra         = R_Plus + R_ads - C_infra
M_operativo     = M_infra - 50   # amministrazione: budget 600 EUR/anno
M_con_tempo     = M_operativo - 100  # 4 h/mese × 25 EUR
```

`C_Firestore` applica la quota a ogni giorno prima di sommare, più storage ed egress oltre franchigia, usando le tariffe della sezione 1. Non sottrae una franchigia per ciascun utente o per ciascun piano. `M_infra` è il margine di budget dopo i soli costi d'infrastruttura. `M_operativo` comprende il budget amministrativo indicato; `M_con_tempo` sottrae anche il valore del lavoro. **Nessuno dei tre è un utile netto personale:** restano imposte sul reddito, contributi e costi esclusi/non noti. Se l'amministrazione costa 125 €/mese anziché 50, sottrarre altri 75 €/mese agli ultimi due margini.

### 8.3. Se tutti usano soltanto il freemium

Scenario centrale Blaze: 90% di gratuiti regolari senza annunci, 10% intensi idonei soltanto dopo il superamento. Nessun abbonato. Importi mensili arrotondati alla fine.

| Utenti totali, tutti gratis | Firestore modellato | Backend + dominio | Ads attese | Margine infra con ads | Margine infra se ads = 0 |
|---:|---:|---:|---:|---:|---:|
| 100 | 0,00 € | 12,00 € | 0,11 € | **−11,89 €** | −12,00 € |
| 1.000 | 1,05 € | 12,00 € | 1,08 € | **−11,97 €** | −13,05 € |
| 10.000 | 25,10 € | 12,00 € | 10,80 € | **−26,30 €** | −37,10 € |

**Con queste ipotesi, il freemium da solo non copre l'infrastruttura completa.** A 10.000 utenti il margine infra annualizzato è circa −315,57 €, prima di amministrazione e tempo. Il fatto che le ads possano coprire una parte di Firestore non significa che coprano backend e altri servizi. Con tutti sotto soglia, o con modulo disattivato, i ricavi ads sono zero.

La prima riga non significa che oggi Spark costi 12 €/mese: è un budget per l'architettura futura, con backend aggiuntivo. Se un servizio non viene usato o costa meno del budget, sostituirne l'importo; non eliminare un costo soltanto per far risultare il pareggio.

### 8.4. Se pagano 100 persone: contano anche quanti gratuiti restano

100 abbonati annuali spendono in totale **1.499 €/anno**. Dopo IVA/fee ipotizzate restano 1.044,39 €/anno; dopo la rettifica prudenziale del 5%, il budget disponibile è **992,17 €/anno**, equivalente a **82,68 €/mese**. Non sono 149,90 €/mese e non sono 100 € netti al mese.

100 paganti mensili producono invece un budget di **131,72 €/mese** alle stesse ipotesi. Presuppone che tutti e 100 paghino quel mese: non garantisce rinnovi futuri. Il mix 50 annuali + 50 mensili equivale a **107,20 €/mese**.

| Utenti totali | Gratuiti | Paganti e piano | Ricavi Plus/mese | Ads/mese | Costi infra/mese | Margine infra/mese |
|---:|---:|---|---:|---:|---:|---:|
| 100 | 0 | 100 annuali | 82,68 € | 0,00 € | 13,58 € | **69,10 €** |
| 1.000 | 900 | 100 annuali | 82,68 € | 0,97 € | 15,61 € | **68,04 €** |
| 1.000 | 900 | 100 mensili | 131,72 € | 0,97 € | 15,61 € | **117,08 €** |
| 1.000 | 900 | 50 annuali + 50 mensili | 107,20 € | 0,97 € | 15,61 € | **92,56 €** |
| 10.000 | 9.900 | 100 annuali | 82,68 € | 10,69 € | 40,36 € | **53,02 €** |
| 10.000 | 9.900 | 100 mensili | 131,72 € | 10,69 € | 40,36 € | **102,05 €** |
| 10.000 | 9.900 | 50 annuali + 50 mensili | 107,20 € | 10,69 € | 40,36 € | **77,53 €** |

Il consumo dei paganti è incluso ed è ipotizzato maggiore di quello gratuito: non vengono trattati come utenti a costo zero. Quando un utente passa a Plus viene tolto dal bacino pubblicitario. Le percentuali implicite sono scenari, non conversioni previste: 100 paganti su 1.000 sono il 10%, su 10.000 sono l'1%.

Gli importi annuali rappresentano ricavi equivalenti ripartiti sul servizio, non incassi bancari mensili. Non spendere tutto il ricavo annuale il primo mese; pianificare i mesi ancora da erogare, rimborsi e ritardi di pagamento delle piattaforme. L'IVA cliente e gli importi riservati non sono budget libero per Firebase.

### 8.5. Se crescono i paganti: margine e valore del lavoro

Scenario centrale con **10.000 MAU**, tutti gli abbonati sul piano annuale. I costi aumentano con il numero di Plus perché il loro utilizzo è più intenso. Le ultime due colonne applicano i budget amministrazione/tempo di 8.2.

| Paganti | Gratuiti | Ricavi Plus + ads/mese | Costi infra/mese | Margine infra/mese | Dopo amministrazione | Dopo amministrazione e tempo |
|---:|---:|---:|---:|---:|---:|---:|
| 0 | 10.000 | 10,80 € | 37,10 € | **−26,30 €** | −76,30 € | −176,30 € |
| 100 | 9.900 | 93,37 € | 40,36 € | **53,02 €** | 3,02 € | −96,98 € |
| 300 | 9.700 | 258,52 € | 46,88 € | **211,64 €** | 161,64 € | 61,64 € |
| 500 | 9.500 | 423,66 € | 53,40 € | **370,27 €** | 320,27 € | 220,27 € |

Per 100/300/500 annuali i margini infra annualizzati sono rispettivamente **636,19 / 2.539,69 / 4.443,20 €**. Sottraendo amministrazione e tempo, nelle ipotesi date, diventano circa **−1.163,81 / 739,69 / 2.643,20 €/anno**, ancora prima dei costi esclusi e della fiscalità personale. I risultati derivano dai valori non arrotondati: le colonne mostrate ai centesimi possono differire di un centesimo dalla sottrazione visiva.

Pareggio centrale con prezzo annuale, ricalcolando anche i costi dei Plus e le ads perse a ogni conversione:

| Popolazione totale | Paganti per coprire infrastruttura | Anche amministrazione 50 €/mese | Anche tempo 100 €/mese |
|---:|---:|---:|---:|
| 1.000 | 15 | 78 | 204 |
| 10.000 | 34 | 97 | 223 |

Questi sono pareggi dello scenario centrale, **non soglie di sicurezza**. Non usarli da soli per autorizzare crescita o spesa illimitata.

### 8.6. Stress: uso più intenso e nessun ricavo pubblicitario

Tutti i gratuiti hanno il profilo intenso; i Plus quello molto intenso; gli account conservati sono tre volte i MAU; backend extra 15 €/mese più dominio 2 €. Le prenotazioni ads possono consumare risorse anche se non producono ricavi. Si mantengono le quote Firebase giornaliere e la rettifica ricavi Plus del 5%. Tutti i paganti della tabella sono annuali.

| MAU | Paganti | Ricavi Plus/mese, ads zero | Costi infra stress/mese | Margine infra stress/mese | Ricavi almeno 130% dei costi? |
|---:|---:|---:|---:|---:|---|
| 1.000 | 0 | 0,00 € | 22,11 € | **−22,11 €** | No |
| 1.000 | 100 | 82,68 € | 24,92 € | **57,76 €** | Sì |
| 10.000 | 0 | 0,00 € | 90,84 € | **−90,84 €** | No |
| 10.000 | 100 | 82,68 € | 93,65 € | **−10,97 €** | No |
| 10.000 | 300 | 248,04 € | 99,26 € | **148,78 €** | Sì |
| 10.000 | 500 | 413,40 € | 104,87 € | **308,53 €** | Sì |

**100 annuali coprono bene lo scenario da 1.000 utenti, ma possono non coprire quello da 10.000.** Nel secondo caso il margine positivo centrale di 53,02 € diventa −10,97 € sotto stress. Con 300 annuali lo stress copre l'infrastruttura, ma il margine dopo 50 € di amministrazione e 100 € di tempo è ancora circa −1,22 €/mese.

Per avere ricavi almeno pari al 130% dei costi **di questo stress** servono 37 annuali o 23 mensili a 1.000 MAU; 150 annuali o 93 mensili a 10.000 MAU. Sono risultati condizionati al volume e ai budget scelti: stress più intenso, picchi, abusi, fatture non modellate o meno rinnovi possono superarli. Uno scenario stress non costituisce un limite massimo di consumo.

### 8.7. Quando preparare ed eseguire il passaggio Spark → Blaze

Usare **consumi reali aggregati**, non il numero di bottiglie o il superamento personale di 0,005 €. Valutare ogni risorsa separatamente; la prima che si avvicina al limite determina l'urgenza.

| Risorsa | Quota gratuita pertinente | Preparazione al 70% | Soglia operativa all'80% |
|---|---:|---:|---:|
| Letture | 50.000/giorno | 35.000 | 40.000 |
| Scritture | 20.000/giorno | 14.000 | 16.000 |
| Cancellazioni ordinarie | 20.000/giorno | 14.000 | 16.000 |
| Storage | 1 GiB | 0,7 GiB | 0,8 GiB |
| Traffico in uscita | 10 GiB/mese | 7 GiB | 8 GiB |

Le percentuali sono margini operativi proposti, non nuove quote Google. Per letture/scritture/delete considerare i giorni di reset Firestore nel fuso Pacifico, gli ultimi sette giorni completi e i picchi, oltre alla proiezione della giornata in corso. Per il traffico mensile usare anche la proiezione di fine mese; per storage includere account inattivi e indici. Un andamento che prevede superamento entro sette giorni fa iniziare la preparazione anche prima del 70%. Con pochi giorni di dati non dichiarare una previsione affidabile: usare il picco osservato con margine.

**Al 70%:** confermare regione, SKU EUR, conto di fatturazione, alert, budget e stato della monetizzazione; completare la prova dei limiti di 8.8 e il controllo di cassa. **All'80% di una risorsa o prima del superamento previsto:** effettuare il passaggio se le condizioni economiche sono soddisfatte, senza aspettare un errore a quota esaurita. L'upgrade mantiene la franchigia; un mese che rimane entro quota non diventa a pagamento per le sole letture Firestore.

Condizioni prudenziali proposte prima di ampliare il traffico a pagamento:

```text
R_affidabile = ricavo_Plus_verificato_dopo_IVA_fee_e_rettifica
              + eventuali_ricavi_minimi_contrattualmente_garantiti
              # previsione ads = 0 per questa decisione

C_pianificato = costo_infra_stress_calibrato_sui_volumi_attesi

copertura = R_affidabile >= 1.30 × C_pianificato
liquidita = cassa_gia_disponibile_per_infra >= 3 × C_pianificato
```

La riserva di tre mesi serve a gestire ritardi degli incassi e variazioni, non sostituisce la copertura ricorrente; escludere dalla cassa spendibile IVA, rimborsi accantonati e debiti già maturati. Per gli annuali ripartire il ricavo sulla durata ancora da erogare. Non contare utenti che «potrebbero pagare» o futuri rinnovi come entrate già certe. Esempio: a 10.000 MAU/100 annuali, lo stress richiede circa 280,94 € di riserva ma la copertura ricorrente non passa; avere quella riserva consente solo di assorbire temporaneamente perdite.

Se il prodotto è ancora tutto gratuito e deve sostenere costi positivi senza entrate affidabili, **l'assenza di perdita non è dimostrabile**. Le opzioni sono mantenere il traffico nel perimetro finanziato, limitare nuove adesioni, introdurre Plus pronto e verificato, oppure destinare consapevolmente un budget di avvio. Quest'ultimo resta spesa del progetto: non chiamarlo profitto o pareggio. La necessità tecnica di Blaze per il backend non elimina questo passaggio finanziario.

Gli alert non fermano la fattura. Al 10 novembre la documentazione elenca spend cap per alcuni servizi, fra cui Cloud Run e Cloud Run functions; **Firestore non è nell'elenco**. Anche i cap disponibili hanno ritardi, richieste in corso e risorse persistenti da considerare: non sono una garanzia di fattura esattamente sotto una cifra. [Budget e servizi ammissibili](https://docs.cloud.google.com/billing/docs/how-to/budgets-spend-caps).

### 8.8. Se «non andare in perdita» è un requisito: budget massimi e limiti reali

**La v1 della sezione 7 stima l'uso per mostrare annunci; non impone un massimo di costo.** Il client può sottostimare, essere modificato o produrre richieste ulteriori; le regole possono generare letture anche quando una richiesta viene negata. App Check, la pubblicità e un contatore nel telefono non bastano a garantire il pareggio. Prima di presentare la spesa come limitata occorre un controllo aggiuntivo sui percorsi che generano costi.

Per una pianificazione più conservativa proporre questi **budget massimi di progetto**, distinti dalla soglia ads e ancora da tradurre in limiti tecnici:

| Budget massimo proposto | Importo mensile | Perimetro richiesto |
|---|---:|---|
| `b_free` | 0,02 €/account gratuito attivo | Operazioni, trasferimenti, quota di controllo e storage attivo allocati all'account. |
| `b_plus` | 0,10 €/account Plus attivo | Stesso perimetro, con quota maggiore; Plus non equivale a cloud economicamente illimitato. |
| `K` | 17 €/progetto | Backend extra 15 € e dominio 2 €, coerenti con il budget stress; da rendere compatibili con i limiti dei servizi effettivi. |
| `S_inattivi` | 5 €/progetto | Storage/manutenzione degli account inattivi; da coprire separatamente e ricontrollare nel tempo. |

Questi valori non sono soglie già implementate o tetti di fattura Google. Sono ipotesi di costo massimo per un progetto controllato, **a tariffa piena e senza sfruttare le franchigie**; devono includere tutti i costi allocati indicati, usare gli SKU EUR effettivi e lasciare margine per arrotondamenti/operazioni in corso. Se non si riesce a dimostrare il rispetto di un budget, la seguente stima non è una garanzia. Anche l'accesso gratuito ai dati personali, i processi di sistema e lo storage persistente richiedono capacità finanziata: non vanno cancellati dal conto.

```text
C_massimo_modellato = K + S_inattivi + F × b_free + P × b_plus

R_affidabile >= 1.30 × C_massimo_modellato

F_massimo = floor((R_affidabile / 1.30 - K - S_inattivi
                   - P × b_plus) / b_free)
```

Con risultato negativo neppure la base pagante corrente copre il perimetro scelto. Con **100 annuali**, `R_affidabile = 82,68049863 €/mese`: il limite economico di questo modello è **1.580 gratuiti**, per 1.680 attivi totali. Con **100 mensili** diventa **3.465 gratuiti**, per 3.565 attivi totali. Usare gli interi arrotondati per difetto; il gratuito successivo non è finanziato con il margine del 30% scelto. Questi limiti cambiano con prezzo, costi, durata dei pagamenti e popolazione inattiva.

Il budget inattivi da 5 € evita di ipotizzare soltanto 2 € mentre lo stress conserva molti più account: a 10.000 MAU e 30.000 account totali, i 20.000 inattivi da 1 MiB costerebbero già circa 3,40 USD/mese a tariffa storage piena, prima della loro manutenzione. Se gli inattivi aumentano, ricalcolare `S_inattivi`; un limite alle nuove registrazioni non fa scomparire lo storage già conservato.

A popolazione totale `N`, i paganti minimi del modello limitato si ottengono con:

```text
P_minimo = ceil(1.30 × (K + S_inattivi + N × b_free)
                / (r_pagante - 1.30 × (b_plus - b_free)))
```

Il denominatore deve essere positivo; se il risultato supera `N`, quel prezzo/perimetro non è sostenibile neppure con tutti paganti.

| Popolazione totale finanziabile | Annuali minimi | Mensili minimi |
|---:|---:|---:|
| 1.000 | **76** | **46** |
| 10.000 | **400** | **238** |

Questi numeri sono più prudenti dei pareggi centrali di 8.5 e dello stress di 8.6: si basano sui budget massimi ipotizzati. **Con 10.000 utenti e soli 100 annuali non autorizzare crescita a spesa aperta facendo affidamento sulle ads.** Per includere amministrazione e lavoro nella stessa condizione, aggiungere rispettivamente 50 e 100 € ai costi del progetto e ricalcolare; i limiti della tabella coprono solo l'infrastruttura definita.

Requisiti di sviluppo per rendere applicabile questo controllo:

1. Tradurre i budget in quote verificabili di richieste/documenti/byte e dimensione dei dati, con contatori affidabili lato server e prenotazione prima delle operazioni costose. Includere letture accessorie, contatori, retry e traffico; non usare soltanto `C_hat` auto-riferito dal telefono come autorità.
2. Verificare che tutti i percorsi fatturabili rispettino le quote. **L'accesso Firestore diretto attuale richiede una revisione architetturale per un limite forte delle letture**: un semplice proxy aggiunto ad alcuni endpoint non limita i listener o le query che lo aggirano. Budget/esposizione del backend, richieste rifiutate, operazioni in corso e storage vanno trattati separatamente; un servizio che può ancora crescere senza controllo impedisce di dichiarare un massimo complessivo.
3. Quando il budget disponibile si avvicina al limite, ridurre prima listener ridondanti, refresh non necessari e attività differibili; fermare l'ampliamento della base gratuita. Un'eventuale quota di sincronizzazione esaurita va spiegata prima nel piano, anche per Plus, mantenendo uso locale, bozze e coda recuperabili. Non subordinare la conservazione dei dati alla visione di un annuncio.
4. Prevedere capacità riservata per lettura essenziale, esportazione, cancellazione e recupero, oltre ai costi di mantenimento dei dati già esistenti. Non usare come piano finanziario la cancellazione automatica degli account o lo spegnimento indiscriminato del billing.
5. Controllare ogni giorno costo già maturato, proiezione di fine mese, margine di copertura e capacità residua. I report di billing possono arrivare in ritardo: testare il contenimento con carichi controllati e un margine in volo, non intervenire soltanto dopo una email di costo.

**Stato della protezione:** da implementare e validare. Le formule danno un piano finanziario condizionato; finché i percorsi restano aperti a consumo non limitato e gli importi reali non sono verificati, non è corretto promettere «nessuna possibilità di perdita». L'abilitazione Blaze e l'eventuale ridisegno del cloud non sono eseguiti da questo documento.

### 8.9. Calcolatore riproducibile per le previsioni

Python 3, senza dipendenze. I profili e i budget sono parametri espliciti. Il calcolatore stampa gli scenari di 8.3–8.6 e verifica pareggi e limiti di 8.8; cambiare le ipotesi quando arrivano fatture, SKU EUR, dati d'uso e ricavi reali. Gli annunci a zero devono restare un caso di verifica.

```python
from decimal import Decimal as D, ROUND_CEILING, ROUND_FLOOR

GIB = D(2) ** 30
PR, PW = D("0.035") / 100_000, D("0.104") / 100_000
PB, PS, FX = D("0.12"), D("0.174"), D("1")
RA = D("14.99") / D("1.22") * D("0.85") * D("0.95") / 12
RM = D("1.99") / D("1.22") * D("0.85") * D("0.95")

def forecast(n, annual=0, monthly=0, stress=False):
    assert 0 <= annual + monthly <= n
    paid = D(annual + monthly)
    free = D(n) - paid
    heavy = free if stress else free / 10
    regular = free - heavy
    reads = regular * 3600 + heavy * 12000 + paid * 60000
    writes = regular * 100 + heavy * 600 + paid * 3000
    # 30 upload per MAU: 2 read + 2 write; 9 slot ads: 4 read + 1 write.
    reads += D(n) * 60 + heavy * 9 * 4
    writes += D(n) * 60 + heavy * 9
    out_gib = (regular * 5600 + heavy * 19200 + paid * 96000) * 1024 / GIB
    stored_gib = D(n) * (3 if stress else 1) / 1024
    # Franchigie giornaliere prima della somma; traffico uniforme ipotizzato.
    operations = sum(
        max(D(0), reads / 30 - 50000) * PR
        + max(D(0), writes / 30 - 20000) * PW
        for _ in range(30)
    )
    cloud = FX * (operations + max(D(0), out_gib - 10) * PB
                  + max(D(0), stored_gib - 1) * PS)
    ads = D(0) if stress else heavy * 9 * D("0.60") * 2 / 1000
    plus = D(annual) * RA + D(monthly) * RM
    infra = cloud + (D(15) if stress else D(10)) + 2
    margin = plus + ads - infra
    return dict(cloud=cloud, ads=ads, plus=plus, infra=infra,
                margin=margin, operating=margin - 50,
                with_time=margin - 150, annual_margin=margin * 12)

def show(label, result):
    print(label, {k: str(v.quantize(D("0.01"))) for k, v in result.items()})

for n in (100, 1000, 10000):
    show((n, "tutti_free"), forecast(n))
for n in (100, 1000, 10000):
    show((n, "100_annuali"), forecast(n, annual=100))
for n in (1000, 10000):
    show((n, "100_mensili"), forecast(n, monthly=100))
    show((n, "mix_50_50"), forecast(n, annual=50, monthly=50))
for p in (0, 100, 300, 500):
    show((10000, p, "annuali_centrale"), forecast(10000, annual=p))
for n, p in ((1000, 0), (1000, 100), (10000, 0),
             (10000, 100), (10000, 300), (10000, 500)):
    show((n, p, "stress_ads_zero"), forecast(n, annual=p, stress=True))

def first_paid(n, overhead=0, stress=False, coverage=D(1), monthly=False):
    for p in range(n + 1):
        result = forecast(n, annual=0 if monthly else p,
                          monthly=p if monthly else 0, stress=stress)
        if result["plus"] + result["ads"] >= coverage * (result["infra"] + overhead):
            return p
    return None

assert [first_paid(1000, x) for x in (0, 50, 150)] == [15, 78, 204]
assert [first_paid(10000, x) for x in (0, 50, 150)] == [34, 97, 223]
assert first_paid(1000, stress=True, coverage=D("1.30")) == 37
assert first_paid(10000, stress=True, coverage=D("1.30")) == 150
assert first_paid(1000, stress=True, coverage=D("1.30"), monthly=True) == 23
assert first_paid(10000, stress=True, coverage=D("1.30"), monthly=True) == 93
assert forecast(10000, annual=100)["margin"] > 0
assert forecast(10000, annual=100, stress=True)["margin"] < 0

# Modello di costo massimo: applicabile solo con limiti tecnici dimostrati.
BF, BP, FIXED, COVER = D("0.02"), D("0.10"), D(22), D("1.30")
def free_max(paid, rate):
    return int(((paid * rate / COVER - FIXED - paid * BP) / BF)
               .to_integral_value(rounding=ROUND_FLOOR))

def paid_min(n, rate):
    denominator = rate - COVER * (BP - BF)
    assert denominator > 0
    return int((COVER * (FIXED + n * BF) / denominator)
               .to_integral_value(rounding=ROUND_CEILING))

assert (free_max(100, RA), free_max(100, RM)) == (1580, 3465)
assert [paid_min(n, RA) for n in (1000, 10000)] == [76, 400]
assert [paid_min(n, RM) for n in (1000, 10000)] == [46, 238]
```

## 9. Handoff di sviluppo e cheat nascosto «Sblocca tutto»

**Richiesta del proprietario, 10 novembre 2026:** iniziare lo sviluppo di freemium e abbonamento prevedendo un comando nascosto per sbloccare tutte le funzionalità e provarle senza acquistare. Questa sezione definisce il comportamento da costruire; non modifica l'app, non concede abbonamenti e non attiva fatturazione o annunci.

### 9.1. Da dove iniziare

1. Leggere la sezione 7 per capacità gratuita, soglia ads, stato Plus e migrazioni; la sezione 8 per budget, Spark/Blaze e condizioni di sostenibilità.
2. Introdurre un unico servizio/repository dei diritti e un'unica risoluzione delle capacità usata da schermate, azioni e backend. Distinguere piano, origine del diritto, stato e scadenza. Il piano gratuito include 15 schede attive secondo 7.1; Plus rimuove limite commerciale e pubblicità. Le estensioni non ancora sviluppate non vanno presentate come disponibili.
3. Aggiungere il menu di 9.2 insieme alle prime capacità freemium: deve consentire di passare fra casi gratuiti e Plus prima di integrare acquisti reali. Tenere inizialmente `adsEnabled=false`; implementare Billing e verifica server con i criteri della sezione 5.
4. Provare limiti e migrazioni con le regole effettive negli emulatori; successivamente acquisti e lifecycle con gli strumenti di test dello store, usando il percorso Billing autentico. Lo sblocco sviluppatore non certifica acquisti, rinnovi o rimborsi.

### 9.2. Gesto nascosto e comandi

**Ingresso previsto:** aprire **Informazioni** e toccare **7 volte la riga della versione entro 5 secondi**. Superati i 5 secondi dal primo tocco, azzerare la sequenza; uscendo dalla schermata azzerarla sempre. Alla settima pressione aprire «Strumenti sviluppatore». La riga esiste in `lib/app/ui/about_screen.dart`, con chiave widget `about-version`; non usare il footer di tutta l'app come trigger accidentale.

| Comando | Effetto nel contesto di sviluppo |
|---|---|
| **Sblocca tutto — Plus di test** | Abilita tutte le capacità Plus implementate, rimuove il limite commerciale di schede e disattiva richieste/visualizzazione ads. |
| **Simula piano gratuito** | Applica i limiti gratuiti e il comportamento ordinario; nessuna cancellazione dei dati oltre soglia. |
| **Simula Plus scaduto** | Esercita la riduzione di piano mantenendo dati, accesso e recupero delle modifiche, come in 7.1. |
| **Ripristina stato normale** | Rimuove l'override e usa di nuovo il repository dei diritti ordinario. |

Quando l'override è attivo mostrare un indicatore chiaro **«DEV · Plus di test»**, oppure il relativo stato simulato, nel pannello e nel profilo. Il gesto è nascosto; lo stato di test deve essere riconoscibile per evitare screenshot o verifiche scambiati per acquisti veri. Non aprire dialoghi di pagamento e non generare token, transazioni o ricevute finte.

Default: override spento. Memorizzarlo soltanto nel contesto locale di sviluppo, associato a UID e progetto demo; logout, cambio account, passaggio di ambiente e comando Ripristina lo eliminano. Persiste fra riavvii dell'app finché account e progetto sono gli stessi e non viene disattivato. Non usare un unico `premium=true` condiviso fra tutti gli account o fra demo e produzione.

### 9.3. Disponibilità del cheat e diritti lato server

Condizione proposta, da collegare alla configurazione già presente in `lib/firebase/firebase_env.dart`:

```text
devCheatsAvailable = NOT kReleaseMode
                    AND ENABLE_DEV_CHEATS == true
                    AND FirebaseEnvConfig.usesEmulators
                    AND projectId == "demo-vinoozy"

ENABLE_DEV_CHEATS: dart-define booleano, default false
```

Il flag autorizza a compilare/abilitare gli strumenti nella build di sviluppo; **non è una password**. Il conteggio dei tocchi, il pannello e i relativi percorsi devono essere esclusi dal rilascio pubblico. Una build collegata al progetto reale non abilita il cheat, anche se il flag viene passato per errore. L'assenza del solo pulsante visibile non basta: non lasciare route, deep link, comando nascosto o handler di sblocco funzionanti nella release.

Esempio di avvio da usare **dopo che il flag sarà implementato**, con Emulator Suite e dispositivo/emulatore Android già configurati secondo README:

```bash
flutter run --debug --dart-define=FIREBASE_ENV=demo --dart-define=ENABLE_DEV_CHEATS=true
```

Il solo override UI non autorizza operazioni premium protette dalle regole. Per collaudare davvero tutte le funzioni, il test harness deve predisporre il diritto corrispondente **nel solo Firebase Emulator Suite**, tramite fixture/strumento amministrativo locale, e ripristinarlo quando si cambia scenario o si elimina l'override. Le operazioni premium devono continuare a passare dalle stesse verifiche di autorizzazione usate dal prodotto. Se la fixture non è disponibile, segnalare che la simulazione non è completa; non far apparire una scrittura rifiutata come riuscita.

Lo strumento che prepara tali fixture deve verificare host degli emulatori e progetto `demo-vinoozy` prima di scrivere. Non distribuire un endpoint di grant senza autenticazione e non aggiungere alle regole di produzione un'eccezione per «7 tocchi», PIN, flag client o build debug. Nessun acquisto reale può essere alterato dal cheat.

### 9.4. Plus gratuito del proprietario su una build reale

Per usare personalmente tutte le funzioni anche su un telefono collegato a Firebase reale, prevedere un **diritto Plus omaggio amministrativo** distinto dal cheat demo. Questo permette di provare il piano sulla build normale senza un bypass del pagamento nel client.

- Grant/revoca soltanto da un comando amministrativo autenticato lato server, su UID esplicito scelto dal proprietario; niente password universale o elenco email fidato dentro l'APK.
- Il backend scrive in `entitlements/{uid}` un diritto verificato con origine `manual_grant`, capacità Plus, inizio, scadenza esplicita e motivo `owner_test`; questo diritto non contiene un falso `purchaseToken`.
- Il repository dei diritti e le autorizzazioni server riconoscono tale origine come grant amministrativo, distinto da un acquisto Play. Mostrare «Plus omaggio» anziché un rinnovo/addebito inesistente. Revoca e scadenza applicano la normale conservazione dei dati e riduzione di piano.
- Il pannello nascosto non può creare, prolungare o revocare grant sul progetto reale. Per i test del pagamento mantenere separato l'account/scenario con licenza tester e acquisto sandbox dello store.

Un Plus omaggio **costa infrastruttura e non produce ricavi**: nelle previsioni non contarlo fra i 100/300/500 abbonamenti pagati. Prevedere un contatore separato `P_gratuiti`, attribuirgli il profilo di costo Plus e ricavo zero; la base di ricavi rimane quella dei soli paganti. Il grant non rimuove i controlli economici globali né eventuali quote cloud di servizio della sezione 8.8.

### 9.5. Criteri di consegna del cheat

| Verifica nello sviluppo | Risultato richiesto |
|---|---|
| Demo, build non release, flag attivo, 7 tocchi entro 5 secondi | Apre il pannello; «Sblocca tutto» attiva il diritto di test e tutte le capacità implementate. |
| 6 tocchi, sequenza oltre 5 secondi, uscita dalla schermata | Non apre il pannello; contatore ripristinato come previsto. |
| Flag assente/falso; progetto reale; build release anche con flag vero | Nessun pannello o percorso di sblocco disponibile. |
| Passaggio Plus di test → gratuito/scaduto → normale | Nessuna perdita dati; limiti e ads tornano coerenti con lo scenario. |
| Cambio UID/progetto e riavvio nello stesso contesto | Nessuna contaminazione fra account/ambienti; persistenza soltanto nel contesto demo dichiarato. |
| Operazione server premium con e senza fixture emulatore | Permesso/rifiuto coerenti con i diritti; nessun successo simulato al posto di un errore reale. |
| Attivazione Plus di test mentre ads sono caricati/in caricamento | Dispone e rimuove gli annunci; non avvia nuove richieste. Usare solo ads di test. |
| Grant omaggio reale e tentativo di scrittura da client | Il grant amministrativo funziona; il client non può assegnarselo o cambiarne la scadenza. |
| Acquisti e contabilità | Nessuna ricevuta falsa; grant e override non aumentano i paganti o i ricavi. |
| Artifact release | Verifica funzionale delle condizioni e controllo assenza dei percorsi/marker di cheat nell'artifact effettivamente distribuibile. |

Estendere il controllo di rilascio esistente `tool/check_release_build.sh` con il perimetro dei cheat. Se si usa un marker quale `VINOOZY_DEV_CHEATS_PANEL`, dimostrarne prima la rilevabilità in una build demo di sviluppo con flag attivo; verificare poi l'assenza nell'artifact pubblico. Il controllo positivo del cheat deve usare un modo non release, perché `kReleaseMode` deve impedirlo anche nella release demo con flag attivo. I controlli E2E/PERF già presenti restano separati e devono continuare a verificare i rispettivi flag.

## Verifica dell'agente antagonista — studio iniziale

**Ambito storico:** la revisione descritta sotto riguarda lo studio iniziale, precedente alla specifica freemium v1 della sezione 7, alle previsioni della sezione 8 e all'handoff della sezione 9. Non costituisce una revisione indipendente dei nuovi default, del misuratore, del modulo pubblicitario, dei limiti finanziari o del cheat. I nuovi esempi sono ricalcolabili con gli script di 7.11 e 8.9.

Revisione indipendente completata dall'agente `/root/antagonista`: ricerca su fonti primarie, lettura integrale dei due documenti e ricalcolo autonomo con Python di volumi, quote giornaliere, costi, ricavi e pareggio. Tabelle confermate entro gli arrotondamenti; corretta la stima marginale a 0,0009926 USD/MAU-mese. Integrato anche il limite DAU di Identity Platform Spark nello scenario stress. Non sono rimaste obiezioni numeriche aperte; workload, domanda, stato delle console e applicazione fiscale personale restano da verificare. La revisione non sostituisce quella del commercialista o l'approvazione Play.

| Contestazione | Correzione incorporata | Che cosa resta incerto |
|---|---|---|
| Costi sottostimati per effetto offline | Considerati listener, riconnessioni, regole, egress, indici nello storage e utenti inattivi | Frequenze e dimensioni reali; attacchi esclusi dai modelli |
| Prezzi della regione sbagliata | Selezionata Milano nel listino interattivo: 0,035 read, 0,104 write, 0,174 storage | SKU EUR e fatturazione del progetto effettivo |
| «200 bottiglie = 200 documenti», MAU=DAU | Definizioni separate e ipotesi esplicite | Distribuzione reale di quantità e sessioni |
| Alert 1 € presentato come cap | Distinti alert e spend cap; nessuna protezione Firestore dal solo alert | Controlli operativi ancora da configurare |
| Ricavi chiamati netti senza IVA | Formula prezzo/1,22×0,85, costo fiscale/tempo separato | Aliquote per paese, fee del proprio accordo, rimborsi e fiscalità delle commissioni |
| 15% universale | Schema commissioni aggiornato 2026 e verifica programma/account associati | Condizioni individuali e cambiamenti annunciati 2027 |
| App vino sempre vietata su AdMob o affiliazioni sempre consentite | Distinte policy Play, publisher e leggi nazionali | Ammissibilità del singolo flusso e partner |
| 5.000 € come soglia partita IVA | Chiarita franchigia previdenziale occasionale, inferenza di abitualità | Inquadramento italiano personale, da verificare con un commercialista |
| OCR «illimitato» giustifica un costo cloud | OCR locale mantenuto gratis; limiti OFF separati | Valore premium da verificare con utenti |
| Una tantum finanzia per sempre il cloud | Riserva circoscritta a funzioni locali, non lifetime cloud illimitato | Domanda e costo di mantenimento nel tempo |

