# Mockups (media fedeltà) — Vinoozy

Fonti: `wireframes.md` e `user-flow.md` (Rough Mockups), `stories.md`, `requirements.md`, `team-practices.md`, risposte in `refined-mockups-questions.md`. Gli anni negli esempi sono coerenti con oggi (novembre 2026). Rispetto ai wireframe aggiunge: presentazione iniziale, quantità nella proposta da foto, Modifica, Dettaglio bevuta, vista "solo lettura", indicatore offline in ogni schermata.

## Elementi comuni a tutte le schermate

- **Barra superiore**: titolo della schermata a sinistra; a destra l'icona profilo (avatar Google) in Cruscotto, Cantina e Storico. Quando ci sono modifiche non sincronizzate compare sotto la barra la fascia "Offline - sincronizzazione in attesa" (FR9.3, US9.1).
- **Barra in basso** (dopo l'accesso): Cruscotto · Cantina · Aggiungi · Storico, icona + etichetta, selezione indicata anche dal testo in grassetto (FR10, US10.1).
- **Cantina condivisa**: se l'utente vede una cantina di un altro proprietario, sotto il titolo compare "Cantina di Mario · solo lettura" o "· può modificare" (FR8, US8.3).
- **Stato del vino**: sempre icona + testo (FR4.5): ⏳ Da aspettare · ✓ Pronto · ⚠ Da bere presto (è un caso particolare di "Pronto", evidenziato) · ✕ Oltre la finestra.

## M0 — Presentazione (primo avvio) *(Q2)*

```
+--------------------------------+
|                                |
|        [illustrazione]         |
|                                |
|   Sai sempre quando bere       |
|   ogni bottiglia               |
|                                |
|          o  .  .               |
|  [Salta]            [Avanti]   |
+--------------------------------+
```

Tre pagine: 1) "Sai sempre quando bere ogni bottiglia"; 2) "Aggiungi un vino in pochi secondi, scrivendo o con una foto"; 3) "Condividi la cantina con chi vuoi". L'ultima pagina ha "Inizia", che porta all'Accesso. Mostrata solo al primo avvio; "Salta" va direttamente all'Accesso.

## M1 — Accesso *(US1.1)*

Come S1 dei wireframe: logo, frase "La tua cantina, al momento giusto", pulsante "Continua con Google". Stati: caricamento nel pulsante; errore "Accesso non riuscito" + "Riprova"; senza rete al primo accesso "Serve la connessione per il primo accesso".

## M2 — Cruscotto *(US5.1, US5.2)*

```
+--------------------------------+
| Cruscotto                 (av) |
+--------------------------------+
| ⚠ Da bere presto (2)           |
|  Barbera d'Asti Sup. 2021      |
|   entro dic 2026        x2  >  |
|  Arneis 2024                   |
|   entro mar 2027        x1  >  |
+--------------------------------+
| Stato delle bottiglie          |
|  ⏳ Da aspettare  ######## 14   |
|  ✓ Pronte        ######    11   |
|  ✕ Oltre          #         1   |
+--------------------------------+
| Picchi per anno                |
|  2027 ### 5   2028 #### 7      |
|  2029 ## 3    2030 # 2         |
+--------------------------------+
| Per tipologia                  |
|  Rosso ######## 18  Bianco ## 6|
+--------------------------------+
| [Cruscotto][Cantina][+][Storico]|
+--------------------------------+
```

- "Pronte" include anche le "Da bere presto" (11 = 9 pronte + 2 da bere presto); il riquadro in alto le evidenzia.
- Il grafico per categoria usa la **tipologia** (rosso, bianco, rosato, spumante, dolce); la regione è un filtro in Cantina.
- Cantina vuota: illustrazione + "La tua cantina è vuota" + pulsante "Aggiungi il primo vino" (FR5.6).
- Caricamento: segnaposto grigi a forma di riquadro; errore di sincronizzazione: fascia "Non riesco a sincronizzare. Riprova" con i dati locali visibili.

## M3 — Cantina *(US3.1, US3.2; Q3)*

```
+--------------------------------+
| Cantina                   (av) |
| [Cerca un vino......]          |
| [Stato v] [Tipologia v] [Reg.v]|
+--------------------------------+
| Barolo DOCG 2016               |
| ✓ Pronto · fiducia alta        |
|                  [-]  2  [+]   |
+--------------------------------+
| Barbera d'Asti Sup. 2021       |
| ⚠ Da bere presto · media       |
|                  [-]  2  [+]   |
+--------------------------------+
| Dolcetto d'Alba 2024           |
| ⏳ Da aspettare fino 2027 ·bassa|
|                  [-]  1  [+]   |
+--------------------------------+
| [Cruscotto][Cantina][+][Storico]|
+--------------------------------+
```

- **+ e -** correggono l'inventario (bottiglia regalata, rotta, trovata) senza creare voci nello Storico. Con quantità 1, "-" chiede conferma: "Togliere l'ultima bottiglia di Dolcetto d'Alba 2024? Non verrà registrata come bevuta." Quantità massima 99 (FR2.4).
- Tocco sulla riga: Dettaglio vino. Ordinamento predefinito: per stato (da bere presto prima), poi per nome.
- In "solo lettura" i pulsanti + e - non compaiono.

## M4 — Aggiungi *(US2.1, US2.2)*

Due pulsanti grandi e uguali: "📷 Scatta foto" e "✏ Scrivi" (come S4).

### M4a — Scatta foto → proposta

```
+--------------------------------+
| < Foto etichetta               |
+--------------------------------+
| [   anteprima fotocamera    ]  |
|            ( O )               |
+--------------------------------+
| Ho riconosciuto:               |
|  Barolo DOCG 2016              |
|  Produttore: Cantina X         |
| Quantità:      [-]  1  [+]     |
| [Correggi]        [Conferma]   |
+--------------------------------+
```

"Correggi" apre M4b già compilato con nome, produttore, annata e quantità (FR2.3). Errori come in S4a.

### M4b — Scrivi → conferma

Campo "Vino" con suggerimenti sotto, campo "Annata" (numero oppure interruttore "Senza annata"), "Quantità" con - / + (1–99), pulsante "Salva". Se il vino esiste già: "Hai già Barolo DOCG 2016 (2 bottiglie). Aggiungere 1 bottiglia?" [Annulla] [Aggiungi] (FR2.5). Dopo il salvataggio torna alla Cantina con il messaggio "Barolo DOCG 2016 aggiunto · bere tra 2024 e 2036".

## M5 — Dettaglio vino *(US4.1, US7.1)*

```
+--------------------------------+
| < Barolo DOCG 2016        x2   |
| Rosso · Piemonte · Cantina X   |
+--------------------------------+
| Finestra ideale                |
|  2024 ======|====== 2036       |
|          picco 2030            |
| ✓ Pronto · fiducia alta        |
| Fonte: base dati vini          |
+--------------------------------+
| Abbinamenti                    |
|  Brasato, tartufo, formaggi    |
|  stagionati                    |
+--------------------------------+
| [   Segna una come bevuta   ]  |
| [Modifica]        [Elimina]    |
+--------------------------------+
```

La barra mostra la posizione di oggi sulla finestra. Con fonte "stima per tipologia" compare la nota "Stima basata sulla tipologia: meno precisa". Senza abbinamenti specifici: "Abbinamenti tipici dei rossi strutturati".

## M5a — Modifica vino *(US3.3)*

Gli stessi campi di M4b più Produttore e Tipologia (selezione: rosso, bianco, rosato, spumante, dolce) e Regione (testo). "Salva" ricalcola la stima. Uscendo con modifiche non salvate: "Uscire senza salvare?".

## M5b — Elimina *(US3.4)*

Finestra di conferma: "Eliminare Barolo DOCG 2016 (2 bottiglie)? Non verrà registrato nello Storico." [Annulla] [Elimina].

## M6 — Segna come bevuta *(US6.1; Q4)*

1. Tocco "Segna una come bevuta" → conferma "Segnare 1 bottiglia di Barolo DOCG 2016 come bevuta?" [Annulla] [Sì].
2. Si apre il foglio con Voto (5 stelle, facoltativo), Note (max 1000 caratteri, contatore visibile), Data (oggi); [Salta] salva senza voto e note, [Salva] li registra.
3. Dopo il salvataggio, messaggio in basso per 6 secondi: "Bevuta registrata · Annulla". "Annulla" ripristina la quantità e toglie la voce dallo Storico.

## M7 — Storico e Dettaglio bevuta *(US6.2)*

Elenco come S7; tocco su una voce → Dettaglio bevuta: nome, annata, data, voto ("4 su 5"), note, chi l'ha registrata (se la cantina è condivisa). Da qui si possono modificare voto e note.

## M8 — Profilo e Condivisione *(US1.2, US1.3, US8.1, US8.2)*

Profilo: nome e email Google, "Condivisione", "Esci", "Cancella account" (in rosso con icona e testo). Condivisione: elenco persone con permesso modificabile, "Invita una persona" (email + permesso), contatore "3 di 5". Una Persona invitata vede nel profilo solo "Esci" e "Cancella account" e l'elenco delle cantine a cui ha accesso.

## Assumptions & Open Questions

- [assumption] Gli esempi di nomi, quantità e finestre sono illustrativi; le finestre reali le calcola la stima (FR4).
