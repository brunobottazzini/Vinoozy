# Panoramica di business — Vinoozy

## Scopo

Vinoozy è un'app Android personale per gestire la propria cantina di vini e sapere **quando** aprire ogni bottiglia ("la tua cantina, al momento giusto"). Funziona anche offline e sincronizza i dati su Firebase al ritorno della rete. Il budget è 0 €/mese (piano gratuito Firebase, nessuna funzione cloud, nessun servizio a pagamento).

## Funzioni principali (per unit di costruzione)

| Unit | Funzione |
|---|---|
| u1-skeleton | Accesso con Google, cantina personale `cellars/{uid}`, inserimento di un vino scritto a mano, uso offline con sincronizzazione, registro locale per il cambio di account, fascia di stato della sincronizzazione |
| u2-estimation | Stima della finestra di consumo, stato del vino, indice di fiducia e abbinamenti (pacchetto Dart puro `packages/estimation`) |
| u3-wine-catalog | Catalogo interno di denominazioni italiane + Open Food Facts (suggerimenti, ricerca per codice a barre e per testo), cache su file per 30 giorni |
| u4-cellar | Cantina completa: doppioni, filtri, dettaglio, modifica ed eliminazione, **"Bevuto" con "Annulla"**, voto e note, Storico a pagine, recupero al ritorno della rete |
| u5-dashboard | Cruscotto in sola lettura (vini da bere presto, grafici) |
| u6-label-recognition | Aggiunta da **una** foto dell'etichetta (scatto, galleria o "Condividi → Vinoozy"), lettura sul telefono con ML Kit (testo e codice a barre), proposta da confermare o correggere |
| u7-sharing | Condivisione della cantina con al massimo 2 persone invitate |
| u8-account | Presentazione, profilo, uscita, cancellazione dell'account (in app e pagina web su GitHub Pages) |

## Lingue e utenti

Interfaccia in italiano, inglese e portoghese brasiliano. Un proprietario (sviluppatore unico) e i suoi eventuali invitati.

## Contesto dell'intent 261107-pending-banner-fix

Requisito u4-cellar **NFR6.6**: dopo una bevuta fatta senza rete, la fascia "modifiche in attesa" deve restare visibile finché la bevuta non arriva al server. Al momento di quella scansione a volte non compariva: vedi [code-quality-assessment.md](code-quality-assessment.md#difetto-nfr66-fascia-in-attesa-dopo-una-bevuta-offline). La correzione è nel working tree, non ancora committata.

## Contesto dell'intent 261107-ux-redesign (storico)

Dopo il primo uso reale il proprietario aveva chiesto paese e regione nel form, una "Bevuta" più chiara e un'interfaccia più grafica. Le descrizioni "stato attuale" scritte per quell'intent (form senza paese né regione, bevuta immediata, tema a 5 colori) erano vere **prima** delle sue modifiche, che ora sono nel working tree non committato. Per il percorso "proposta → form" questa scansione ha riverificato il codice: il form ha `CountryPicker` e `RegionPicker`, il vino ha il campo `country` (ISO 3166-1) e le regole Firestore lo ammettono; vedi [component-inventory.md](component-inventory.md#addwinescreen). Le altre parti (bevuta, tema) sono descritte com'erano e non sono state riverificate.

## Contesto dell'intent 261107-label-recognition

Prima della pubblicazione sullo store il proprietario vuole un riconoscimento dell'etichetta migliore, senza servizi a pagamento. Richiesta (testo originale):

> improve label recognition before the store release: (1) front and back label photos read on the phone with ML Kit, text merged before recognition; (2) an offline wine database on the phone derived from the Open Food Facts export (wines only: name, producer, barcode, category, denomination), with online Open Food Facts only as fallback; (3) when everything fails a "Cerca online" button that searches Open Food Facts by text and shows candidates to pick, which fill the form even with partial info; (4) as last resort "Apri in Google Lens", passing the photo to the Google app only on explicit tap. No paid services.

Stato del codice per ciascun punto **alla scansione di quell'intent** (u6). Il working tree attuale ha già realizzato i quattro punti: vedi la sezione successiva.

1. **Fronte e retro**: oggi una lettura è **una** foto. ML Kit legge testo e codice a barre della stessa immagine in parallelo; il testo è limitato a 2000 caratteri. Non c'è modo di aggiungere una seconda foto né di unire i testi. Dettagli in [architecture.md](architecture.md#foto-dalletichetta-alla-proposta-comportamento-attuale).
2. **Database dei vini sul telefono**: non esiste. Il "catalogo interno" contiene solo le denominazioni italiane del pacchetto `estimation` (47 secondo la prima scansione); senza rete un codice a barre non trova mai un vino. Non c'è un motore di database locale, né una procedura per derivare dati dall'esportazione di Open Food Facts. Dettagli in [code-quality-assessment.md](code-quality-assessment.md#label-2-nessun-database-locale-di-vini).
3. **"Cerca online"**: la ricerca testuale su Open Food Facts esiste già, ma è automatica e nascosta: durante la lettura dell'etichetta l'app manda fino a 6 parole e prende in silenzio il primo risultato adatto; nel form di aggiunta i suggerimenti arrivano dopo una pausa di 600 ms. Nessuna schermata d'esito offre "Cerca online" con una lista di candidati. Open Food Facts è acceso solo nelle build di produzione con il contatto configurato.
4. **"Apri in Google Lens"**: non esiste. L'app non dichiara di voler vedere altre app (Android 11+), non ha un fornitore di file per passare la foto e cancella la copia della foto appena finisce la lettura. Oggi la documentazione di privacy dice che le foto non lasciano mai il telefono: un passaggio esplicito a Google va dichiarato.

## Contesto dell'intent 261108-label-autofill-windows

Richiesta (testo originale, riassunto dal brief):

> "Compila dall etichetta e Incolla da Lens": dal testo letto sulla foto dell'etichetta, o dal testo copiato da Google Lens e incollato in Vinoozy, ricavare nome, produttore, denominazione, annata, tipo, paese e regione, e compilare il form di aggiunta anche quando il vino non è in nessuna base dati. Inoltre: estendere la stima della finestra di consumo (`packages/estimation`) ai vini di tutto il mondo, con denominazioni del Vecchio e del Nuovo Mondo e i vitigni come ripiego; aggiungere un campo "Livello" (Quotidiano / Buono / Da invecchiamento) che accorcia o allunga la finestra; permettere di correggere a mano "Consigliato fino al".

Stato attuale del codice (working tree non committato, verificato in questa scansione):

1. **Riconoscimento già presente** (intent 261107-label-recognition, nel working tree): fronte e retro uniti (`mergeLabelReadings`, testo ≤ 4000), base dei vini sul telefono (`assets/wine_db/`, oggi un campione di 45 vini), ordine di ricerca offline → denominazione interna → Open Food Facts, "Cerca online" con lista di candidati, "Apri in Google Lens" come ultima possibilità. Dettagli in [architecture.md](architecture.md#etichetta-dal-testo-al-form-comportamento-attuale).
2. **Compilazione dal testo**: dal testo si ricavano solo il **nome** (riga più significativa) e l'**annata**. Produttore, denominazione, tipo, paese e regione arrivano solo da un candidato trovato in una base dati; se non si trova nulla, "Scrivi a mano" apre il form con nome e annata. Nessun analizzatore estrae i campi dal testo libero.
3. **"Incolla da Lens"**: non esiste. Google Lens è solo in uscita (la foto del fronte passa all'app Google su conferma; "Vinoozy non riceve i risultati"). L'app non legge gli appunti e non accetta testo condiviso (riceve solo immagini).
4. **Stima per tutto il mondo**: la stima conosce 47 denominazioni, tutte italiane, 8 tipi e una riga generica. Per un vino estero vale la riga del tipo (o la generica); il paese e la regione non entrano nella stima. Nessuna tabella di vitigni.
5. **"Livello"**: non esiste né nel modello né nelle regole Firestore.
6. **"Consigliato fino al" manuale**: oggi è l'anno di fine della finestra calcolata (`window.endYear`), corretta solo dalle bevute (`WindowAdjuster`). Non si può modificare a mano e verrebbe ricalcolata da modifica, aggiornamento col catalogo e bevute. Dettagli in [code-quality-assessment.md](code-quality-assessment.md#intent-261108-label-autofill-windows-punti-di-attenzione).

