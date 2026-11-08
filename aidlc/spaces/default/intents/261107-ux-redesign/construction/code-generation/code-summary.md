# Riepilogo del codice — nuova UX di Vinoozy (261107-ux-redesign)

## In breve

Il piano approvato è costruito per intero, nell'ordine test-after per strato (dominio → dati e sincronizzazione → interfaccia), con tutti gli 11 passi spuntati nel piano. Lo Step 9 è spuntato solo per le modifiche agli end-to-end: eseguirli sull'emulatore Android spetta a Build and Test.

- **Paese e regione:** griglia di 21 bandiere più "Altro paese…" con tutti i 249 paesi e territori ISO 3166-1 (nomi it/en/pt-BR nel codice, sezione "Rari per il vino", ricerca senza accenti nelle 3 lingue), regioni a chip, compilazione automatica dal catalogo, da Open Food Facts e dall'etichetta, campo `country` salvato e accettato dalle regole.
- **"Ho bevuto":** pulsante con il verbo e l'icona dei calici (la scheda Cantina ora è la bottiglia), pannello di conferma con "n → n−1" e 5 stelle facoltative, voto nella stessa scrittura della bevuta, "Togli una bottiglia senza bevuta" con conferma.
- **Identità visiva:** palette bordeaux/oro/crema in chiaro e scuro, `StatusColors` con i colori delle etichette di stato, nuovo `WineTypeColors`, titoli con il serif di sistema, schede dei vini, Dashboard con riquadro in cima e bandiere, "Momento ideale" con "Consigliato fino al …".

Nessun pacchetto nuovo, nessuna pubblicazione su Firebase, nessun commit.

## File cambiati

### Nuovi in `lib/`

- `lib/cellar/domain/wine_origins.dart` — tabella dei 249 paesi (it/en/pt-BR), bandiera emoji dal codice, 21 paesi del vino, "Rari per il vino", regioni con nome canonico e traduzioni, ricerca senza accenti, nomi canonici, regola "regione italiana → Italia", riconoscimento da denominazione / nome / `origins`, `OriginSelection` (cambio di paese che azzera la regione).
- `lib/app/ui/country_flag.dart` — `CountryFlag`: emoji letta dal lettore di schermo con il nome del paese; sigla in un riquadro per un codice sconosciuto.
- `lib/cellar/ui/origin_pickers.dart` — `CountryPicker`, `AllCountriesSheet`, `RegionPicker`.
- `lib/cellar/ui/wine_badges.dart` — `WineTypeFamily` (5 famiglie per gli 8 `WineType`), nome, colore e icona della famiglia, `WineTypeBadge`, `StateChip`.
- `lib/cellar/ui/wine_card.dart` — `WineCard` e `DrinkActionButton` ("Ho bevuto").
- `lib/cellar/ui/drink_confirm_sheet.dart` — `DrinkConfirmSheet` e `DrinkConfirmation`.
- `lib/cellar/ui/ideal_moment_card.dart` — `IdealMomentCard` e `WindowBar`.

### Modificati in `lib/`

- Dominio: `lib/cellar/domain/wine.dart` (`country`, `displayCountry`), `wine_draft.dart` (`country`), `wine_validator.dart` (`country`, `RegionError`, `CountryError`, nome canonico, regola R-06).
- Dati: `lib/cellar/data/wine_repository.dart` (`country` in `addWine` e `updateWine`), `lib/cellar/data/drinking_record_repository.dart` (`drink` con `rating` nello stesso batch; le modifiche già presenti della correzione della fascia sono conservate), `lib/cellar/cellar_actions.dart` (`drink(rating:)`, `country` nel vino creato).
- Tema e navigazione: `lib/app/theme.dart`, `lib/app/home_shell.dart` (icone Cruscotto `bar_chart`, Cantina `liquor`, Storico `menu_book`).
- Cantina: `add_wine_screen.dart`, `edit_wine_screen.dart`, `cellar_screen.dart`, `wine_detail_screen.dart`, `drink_flow.dart`, `history_screen.dart`, `archived_wines_screen.dart`, `cellar_dialogs.dart` (`RemoveBottleDialog`), `window_card.dart` (resta solo `PairingsCard`), `wine_list_tile.dart` (ora solo un alias di `WineCard`, vedi Deviazioni).
- Dashboard: `domain/dashboard_summary.dart` e `domain/dashboard_calculator.dart` (`country` nelle righe), `ui/bar_chart.dart` (icona colorata o bandiera per riga), `ui/chart_cards.dart`, `ui/dashboard_card.dart`, `ui/dashboard_screen.dart` (riquadro bordeaux), `ui/drink_soon_section.dart`.
- Etichetta: `lib/label/ui/label_proposal_sheet.dart` (paese, regione, famiglia), `lib/label/ui/label_reading_screen.dart` ("Conferma" salva paese e regione).
- Testi: `lib/l10n/app_it.arb`, `app_en.arb`, `app_pt_BR.arb` (39 chiavi `ux*` nuove per lingua) e i file generati da `flutter gen-l10n`.

### Regole, compatibilità e configurazione

- `firestore.rules` — `country` in `wineFields()`, `validCountry` (nullo oppure 2 lettere maiuscole) alla creazione e alla modifica; `region` resta 1–120; il voto della bevuta era già accettato da `validRating`.
- `test/rules/u4.rules.test.mjs` — 6 test nuovi (`country` valido e non valido, vino senza `country`, R-06, regione di 100/121 caratteri con paese, bevuta con voto).
- `test/rules/compat/app-writes.json` — nuova versione `ux-redesign` con le scritture di oggi (vino con paese, vino senza paese, vino vecchio modificato con `IT`, bevuta con voto).
- `.github/workflows/promote.yml` — `RULES_FEATURES: sharing cellar account origin` (R-01).
- `docs/release-checklist.md` — nuova sezione "1-octies. Nuova UX" con la prova sul telefono e il punto sulle regole da pubblicare prima.
- `pubspec.yaml` invariato (NFR3). `test/coverage_helper_test.dart` rigenerato (167 file; è ignorato da git e rigenerato anche in CI).

### Test

- Nuovi: `test/cellar/domain/wine_origins_test.dart` (30 test), `test/cellar/ui/ux_redesign_test.dart` (30 test più 3 matrici di accessibilità da 12 casi ciascuna).
- Estesi: `test/cellar/domain/wine_validator_test.dart`, `test/cellar/data/wine_repository_test.dart`, `test/cellar/data/drinking_record_repository_test.dart`, `test/app/status_colors_test.dart` (coppie testo/sfondo A1/A8, stelle e bordi ≥ 3:1, `WineTypeColors`, serif), `test/app/home_shell_test.dart`, `test/dashboard/dashboard_screen_test.dart` (riquadro, bandiere, barre), `test/cellar/ui/add_wine_screen_test.dart` e `test/label/ui/label_screens_test.dart` (paese e regione compilati da soli).
- Aggiornati al nuovo flusso, senza togliere verifiche: `cellar_screen_test.dart`, `wine_detail_screen_test.dart`, `drink_reads_refresh_test.dart`, `edit_wine_screen_test.dart`, `cellar_ui_harness.dart`, `cellar_harness.dart`, `test/dashboard/dashboard_calculator_test.dart`, `test/dashboard/fixtures.dart`, `test/u1/ui/add_wine_screen_test.dart`, `test/u1/ui/cellar_screen_test.dart`, `test/u1/ui/cellar_retry_test.dart`, `test/sharing/cellar_switcher_test.dart`, `test/sharing/permissions_screens_test.dart`.
- End-to-end modificati (non eseguiti): `integration_test/e2e_helpers.dart`, `cellar_test.dart`, `concurrent_drink_test.dart`, `u1_skeleton_test.dart`, `account_test.dart`.

## Elenchi enologici e motivazioni

Scelte fatte in autonomia, come chiede la correzione del 2026-11-04 in `project.md`. Si correggono tutte in un solo file, `lib/cellar/domain/wine_origins.dart`.

### Criteri generali

- **Nome canonico = nome nella lingua del paese.** È il nome che c'è in etichetta (Bourgogne, Rheinhessen, Vale do São Francisco), resta uguale in tutte le lingue dell'app (R-02) e la Dashboard raggruppa per quello. Le traduzioni servono solo a mostrarlo: Borgogna in italiano, Burgundy in inglese, Borgonha in portoghese.
- **Per l'Italia i nomi canonici sono quelli del catalogo delle denominazioni** del pacchetto `estimation` (per esempio "Trentino-Alto Adige", "Emilia-Romagna"). Così una regione arrivata dal catalogo coincide con il chip.
- **Alias:** forme che si trovano davvero su etichette e in Open Food Facts ("Alto Adige", "Südtirol", "Friuli", "Loire", "Rhône", "Maipo", "Barossa", "Napa", "Martinborough", "Waipara", "Podravje"…). Vengono riconosciute e salvate con il nome canonico.
- **Testo libero:** se coincide, senza maiuscole e accenti, con un nome canonico, tradotto o alias del paese scelto, si salva il nome canonico (R-07). Altrimenti si salva com'è, senza spazi esterni.
- **Livello di dettaglio:** in ogni paese uso la ripartizione che il commercio e le carte dei vini usano davvero. In Italia sono le regioni amministrative (FR1.2). In Francia le grandi regioni vinicole (FR1.2). In Germania le 13 zone ufficiali (Anbaugebiete). Altrove le zone o denominazioni più citate in etichetta. Ogni paese ne ha 4–13, così la griglia di chip resta leggibile a testo 2,0.

### Regioni per paese

| Paese | Regioni (nome salvato) | Perché |
|---|---|---|
| Italia (20) | Piemonte, Toscana, Veneto, Sicilia, Puglia, Campania, Friuli-Venezia Giulia, Trentino-Alto Adige, Lombardia, Sardegna, Abruzzo, Marche, Umbria, Emilia-Romagna, Lazio, Basilicata, Calabria, Liguria, Valle d'Aosta, Molise | Tutte le 20 (FR1.2). Prima le più importanti per volume e notorietà, nell'ordine del mockup 3, poi le altre 5. |
| Francia (11) | Bordeaux, Bourgogne, Champagne, Vallée du Rhône, Vallée de la Loire, Alsace, Languedoc-Roussillon, Provence, Beaujolais, Jura, Sud-Ouest | Esattamente le 11 di FR1.2. Il Beaujolais è separato dalla Borgogna perché così lo indicano etichette e carte dei vini. |
| Spagna (11) | Rioja, Ribera del Duero, Priorat, Penedès, Rías Baixas, Rueda, Toro, Jerez, La Mancha, Navarra, Bierzo | In Spagna il riferimento in etichetta è la DO, non la comunità autonoma. Sono le DO più diffuse in Italia. Il Penedès rappresenta anche il Cava. |
| Portogallo (10) | Douro, Vinho Verde, Alentejo, Dão, Bairrada, Lisboa, Tejo, Península de Setúbal, Madeira, Açores | Le regioni vinicole ufficiali più presenti, con le due isole dei vini fortificati e insulari. Il Porto ricade nel Douro. |
| Germania (13) | Mosel, Rheingau, Pfalz, Rheinhessen, Nahe, Baden, Franken, Württemberg, Ahr, Mittelrhein, Saale-Unstrut, Sachsen, Hessische Bergstraße | Le 13 zone ufficiali (Anbaugebiete): l'elenco è chiuso per legge e completo. |
| Austria (10) | Wachau, Kamptal, Kremstal, Weinviertel, Wagram, Carnuntum, Thermenregion, Burgenland, Steiermark, Wien | Le zone DAC e i Länder vinicoli come compaiono in etichetta. Per la Bassa Austria uso le valli, che sono il riferimento usato. |
| Svizzera (7) | Valais, Vaud, Genève, Ticino, Neuchâtel, Graubünden, Schaffhausen | I cantoni vinicoli principali, nella loro lingua (Ticino in italiano). |
| Grecia (9) | Santorini, Naoussa, Nemea, Amyntaio, Makedonia, Peloponnisos, Kriti, Attiki, Kefalonia | Le 4 denominazioni più note e le grandi regioni, con la traslitterazione usata in etichetta. |
| Ungheria (8) | Tokaj, Eger, Villány, Szekszárd, Badacsony, Somló, Sopron, Kunság | Le zone storiche e quelle più esportate. Tokaj prima di tutte. |
| Slovenia (6) | Goriška Brda, Vipavska dolina, Kras, Slovenska Istra, Štajerska, Posavje | Le zone di Primorska, vicine al Friuli e alle più vendute in Italia (Brda come "Collio sloveno"), più le due grandi regioni interne. |
| Croazia (6) | Istra, Dalmacija, Slavonija, Plešivica, Moslavina, Hrvatsko primorje | Le regioni con i vini più noti: Malvasia istriana, Plavac mali, Graševina. |
| Georgia (4) | Kakheti, Kartli, Imereti, Racha-Lechkhumi | Kakheti produce gran parte del vino georgiano, comprese le anfore (qvevri). Le altre tre sono le zone storiche. |
| Stati Uniti (7) | Napa Valley, Sonoma, California, Oregon, Washington, New York, Virginia | Napa e Sonoma sono le AVA più citate e meritano un chip proprio. "California" copre il resto dello stato. Seguono gli altri stati vinicoli principali. |
| Canada (4) | Ontario, British Columbia, Québec, Nova Scotia | Le 4 province produttrici. Niagara Peninsula e Okanagan Valley sono alias. |
| Argentina (6) | Mendoza, Salta, San Juan, La Rioja, Catamarca, Patagonia | Esempio di FR1.2 più La Rioja (mockup 2) e Catamarca. Neuquén è un alias di Patagonia. |
| Cile (8) | Valle del Maipo, Valle de Colchagua, Valle de Casablanca, Valle de Aconcagua, Valle de Cachapoal, Valle del Maule, Valle de Leyda, Valle del Limarí | Le valli in cui è diviso il vino cileno ("Valle de…" come in etichetta). Il nome breve senza "Valle" è un alias, come "Valle del Colchagua" del mockup 7. |
| Brasile (6) | Serra Gaúcha, Campanha Gaúcha, Vale do São Francisco, Serra do Sudeste, Campos de Cima da Serra, Planalto Catarinense | Esempio di FR1.2 (Campanha diventa "Campanha Gaúcha", il nome della DO) più le altre zone riconosciute. |
| Uruguay (6) | Canelones, Montevideo, Maldonado, Colonia, Rivera, San José | I dipartimenti dove si concentra quasi tutta la produzione. Canelones da solo ne fa la maggior parte. |
| Australia (9) | Barossa Valley, McLaren Vale, Eden Valley, Clare Valley, Coonawarra, Hunter Valley, Yarra Valley, Margaret River, Tasmania | Le GI più vendute in Europa, che sono quelle scritte in etichetta (lo stato da solo dice poco). |
| Nuova Zelanda (7) | Marlborough, Hawke's Bay, Central Otago, Wairarapa, Gisborne, Nelson, North Canterbury | Le regioni ufficiali principali. Marlborough per il Sauvignon, Central Otago per il Pinot nero. |
| Sudafrica (8) | Stellenbosch, Paarl, Franschhoek, Constantia, Swartland, Elgin, Walker Bay, Robertson | I distretti del Capo più citati. Hemel-en-Aarde è un alias di Walker Bay. |

### "Rari per il vino"

Giappone, Cina, India, Libano, Israele, Marocco, Moldavia, Romania, Bulgaria, Armenia, Messico e Perù, i 12 del mockup 8, più Regno Unito, Cipro, Turchia e Lussemburgo. Sono paesi che producono e vendono vino in Europa ma non sono nella griglia dei 21. Così si trovano senza cercarli.

### Da denominazione a paese e regione (FR1.3)

1. **Denominazioni italiane:** il catalogo del pacchetto `estimation` (47 voci) dà la regione: per esempio Barolo DOCG → Piemonte → Italia, Brunello → Toscana.
2. **Denominazioni estere:** una tabella breve di parole intere, controllate in denominazione, nome e `origins`:
   - Francia: Chablis, Meursault, Pommard, Gevrey-Chambertin, Côte de Nuits/Beaune → Bourgogne; Champagne; Pauillac, Margaux, Saint-Émilion, Pomerol, Sauternes, Médoc, Pessac-Léognan → Bordeaux; Sancerre, Pouilly-Fumé, Vouvray, Muscadet → Vallée de la Loire; Châteauneuf-du-Pape, Côte-Rôtie, Hermitage, Côtes du Rhône, Gigondas → Vallée du Rhône; Crémant d'Alsace; Beaujolais, Morgon, Fleurie; Cahors, Madiran → Sud-Ouest; Bandol → Provence.
   - Spagna: Rioja, Ribera del Duero, Priorat, Cava → Penedès, Rías Baixas, Jerez/Sherry.
   - Portogallo: Vinho do Porto e Porto Tawny/Ruby, Vintage Port → Douro; Vinho Verde.
   - Altri: Tokaji → Tokaj, Egri Bikavér → Eger, Barossa, Napa.

   Ho scelto le denominazioni più diffuse in Italia. Non ho usato parole ambigue, come "Port" da solo o i nomi dei vitigni.
3. **`origins` di Open Food Facts:** il testo si divide alle virgole. Un nome di paese in una delle 3 lingue, oppure un nome locale o abbreviato ("USA", "España", "Deutschland", "Schweiz"…), dà il paese. Una regione dell'elenco di quel paese, o di un solo paese, dà la regione. Un testo che non corrisponde a nulla resta come regione libera.

Tutto resta modificabile nel modulo.

## Decisioni di implementazione

- **Regola R-06 nel validatore.** `WineValidator` salva `country = IT` quando non c'è paese e la regione è italiana. Vale per aggiunta, modifica ed etichetta. Il repository scrive `country` solo se il vino ne ha uno o ne aveva uno prima: modificare un vino che non ha mai avuto un paese non aggiunge il campo, così resta compatibile con le regole di oggi. La lettura non riscrive mai il documento: `Wine.displayCountry` mostra l'Italia.
- **Voto nella stessa scrittura (R-04).** `DrinkingRecordRepository.drink(rating:)` mette `rating` nel record dello stesso batch. Un voto fuori da 1–5 è rifiutato prima di scrivere. La sonda della fascia "in attesa" resta quella corretta dell'intent precedente.
- **Pannello prima della scrittura.** `drinkWithUndo` legge i servizi prima di ogni attesa, poi apre il pannello. "Annulla", il gesto indietro o un tocco fuori non scrivono nulla. Il messaggio con "Annulla" resta come rete di sicurezza.
- **"Aggiungi" flottante.** La Cantina ha un suo `ScaffoldMessenger`: il messaggio "Bevuta segnata" si apre nella Cantina e si dispone sopra il pulsante flottante, invece di coprirlo.
- **Tema.** I valori sono quelli di `design-system-mapping.md`. Dove la mappatura non li dava, li ho scelti verificandone il contrasto:
  - `primaryContainer`, `tertiary` e l'etichetta "da bere presto" (arancio);
  - `outline` più scuro per i bordi dei controlli (≥ 3:1, R-10);
  - `WineTypeColors` scuri come nel mockup 7: rosso `#C75A6C`, bollicine `#86A35A`;
  - stelle in `secondary`, cioè l'oro chiaro nel tema scuro (R-10).

  I chip scelti nei filtri restano gold (`secondaryContainer`); i chip delle regioni scelti sono bordeaux come nel mockup.
- **Icone delle famiglie:** goccia (rosso), sole (bianco), fiore (rosato), bolle (bollicine), favo (dolce). Sono le emoji del mockup rese come icone Material, sempre accanto al nome della famiglia.

## Deviazioni dal piano

1. **Limite della regione 120 invece di 80.** È la scelta del piano e della specifica (R-03, R-08 accettato): `requirements.md` dice ancora 80. Validatore, regole e test usano 120.
2. **`wine_list_tile.dart` non è cancellato.** Contiene solo `typedef WineListTile = WineCard`, perché il brief non permette di cancellare file dalla shell. Nessun file lo importa più. Il proprietario può cancellarlo.
3. **`WindowCard` sostituita da `IdealMomentCard`.** La chiave `window-card` è conservata. Inizio/picco/fine, fiducia e fonte sono nella nuova scheda. La vecchia chiave ARB `estimateDisclaimer` non è più usata ma è rimasta nei file.
4. **"Salva" fisso in basso** nei moduli di aggiunta e modifica, come nei mockup 2 e 3, con l'errore di salvataggio subito sopra. Il dettaglio usa ora `SingleChildScrollView` invece di `ListView`, così tutti i comandi esistono anche fuori schermo.
5. **Storico "anche archiviato".** La riga prende bandiera e famiglia dai vini già sul telefono: l'ascolto dei vini in cantina (lo stesso della Cantina) e l'archivio dei finiti solo se è stato aperto. Non ho aggiunto letture per non violare NFR3 ("nessuna lettura Firestore in più"). Un vino finito con l'archivio mai aperto si vede come oggi.
6. **Test delle regole in `u4.rules.test.mjs`** invece di un file nuovo, perché `npm run test:rules` elenca i file uno per uno e così `package.json` non cambia.
7. **End-to-end toccati oltre ai 3 del piano:** anche `u1_skeleton_test.dart` e `account_test.dart`, che leggevano "Aggiungi" come pulsante normale, "x2" e `WineListTile`. È il minimo per tenerli coerenti.
8. **Altri test aggiornati oltre all'elenco della mappa del codice:** quelli della condivisione (`cellar_switcher_test.dart`, `permissions_screens_test.dart`) per "Aggiungi" flottante e "Nome annata" su una riga.
9. **Testi visibili cambiati:**
   - le etichette di stato hanno la maiuscola ("Pronte", "Da aspettare");
   - il grafico per tipo usa i nomi delle famiglie delle schede ("Rosso", "Bollicine" invece di "rosso", "spumante");
   - "−" del dettaglio è diventato "Togli una bottiglia senza bevuta".
10. **"Da bere presto" della Dashboard** è una scheda con righe compatte (bandiera, nome, "entro il …"), non con `WineCard` intere: è la soluzione della revisione dei mockup (R-06), come nel mockup 6.
11. **Bandiera anche nell'archivio dei vini finiti.** Non era nel piano; l'ho aggiunta per coerenza (FR3.4).

## Risultati dei comandi

| Comando | Esito |
|---|---|
| `flutter test test/cellar test/dashboard test/app` (base, prima delle modifiche) | exit 0, 483 test superati |
| `flutter test test/cellar/domain` (dopo lo strato dominio) | exit 0, 96 superati |
| `flutter test test/cellar test/dashboard test/app` (dopo lo strato dominio) | exit 0, 520 superati |
| `flutter test test/cellar` (dopo lo strato dati) | exit 0, 385 superati |
| `npm run test:rules` | **exit 1**: non è partito perché la porta 8080 è occupata dall'emulatore del proprietario (`firebase emulators:start --only auth,firestore --project demo-vinoozy`, attivo da ore). Non l'ho fermato. |
| Stesse suite delle regole su porte separate (`npx firebase emulators:exec --config /tmp/claude-vz/firebase.json --only firestore --project demo-vinoozy "npm --prefix test/rules test -- u1.rules.test.mjs u7.rules.test.mjs u4.rules.test.mjs u8.rules.test.mjs compat/"`) | exit 0: 199 test, 198 superati, 0 falliti, 1 saltato (nessun tag `v*`) |
| `flutter test` (completo) | exit 0, 1705 superati |
| `flutter test --coverage` | exit 0, 1705 superati |
| `dart test --coverage=coverage` in `packages/estimation` | exit 0, 321 superati |
| `dart run tool/gen_coverage_helper.dart` | exit 0, 167 file |
| `flutter gen-l10n` | exit 0 |
| `dart format --output=none --set-exit-if-changed .` | exit 0, 337 file, 0 cambiati |
| `flutter analyze --fatal-infos` | exit 0, nessun problema |
| `dart run benchmark/dashboard_benchmark.dart` | exit 0, 0,73 ms su 500 vini (limite 10 ms) |
| `dart run benchmark/cellar_benchmark.dart` | exit 0, filtri 0,83 ms (limite 20), finestra 0,03 ms (limite 5) |
| `tool/check_dashboard_readonly.sh`, `tool/check_label_imports.sh`, `tool/check_rule_ids.sh` (cantina ed etichetta) | exit 0 |
| sensore `traceability` su `traceability.json` | passed |

### Copertura delle righe

| Ambito | Copertura | Soglia |
|---|---|---|
| Progetto + pacchetto `estimation` | 89,27% (10182/11406) | 80% |
| Solo app | 88,94% (9839/11063) | 80% |
| `lib/cellar/` | 95,29% (3522/3696) | 80% |
| `lib/dashboard/` | 98,84% (683/691) | 80% |
| `lib/catalog/`, `lib/sharing/`, `lib/label/`, `lib/account/` | 99,48% · 98,42% · 98,65% · 97,44% | 80% |

La copertura del progetto unito è calcolata con la stessa formula di `tool/check_coverage.sh` sulle due lcov lette insieme. Non ho scritto `coverage/merged.lcov.info` dalla shell, come chiede il brief.

File nuovi: `origin_pickers.dart`, `wine_card.dart`, `drink_confirm_sheet.dart`, `ideal_moment_card.dart`, `country_flag.dart` 100%; `wine_badges.dart` 98,7%; `wine_origins.dart` 94,4%.

## Test scritti ma non eseguiti

- Gli end-to-end aggiornati (`integration_test/cellar_test.dart`, `concurrent_drink_test.dart`, `u1_skeleton_test.dart`, `account_test.dart` e l'helper `e2e_helpers.dart`) non sono stati eseguiti. Servono l'emulatore Android e la Firebase Emulator Suite; per il piano li esegue Build and Test (job `e2e` di `ci.yml`). In `cellar_test.dart` ci sono anche le verifiche nuove:
  - paese e regione scelti nel modulo, con bandiera e regione sulla scheda;
  - "Annulla" nel pannello che non scrive nulla;
  - bevuta con 4 stelle.

## Da fare per il proprietario

1. **Escalation: regole su `vinoozy-d6f45`.** Le regole nuove vanno pubblicate con `firebase-deploy.yml` **prima** di installare sul telefono la build che scrive `country`, e solo con il tuo via. Con le regole vecchie ogni vino salvato con un paese verrebbe rifiutato ("non salvato"). La promozione in produzione è comunque bloccata finché le regole della build non sono quelle pubblicate (`origin` in `RULES_FEATURES`). Non ho pubblicato nulla.
2. **Prova sul telefono:** la sezione "1-octies" di `docs/release-checklist.md`, in particolare che le bandiere si vedano a colori sul OnePlus e che i titoli usino il serif.
3. **Elenchi enologici:** se vuoi cambiare regioni, nomi o l'elenco "Rari per il vino", basta dirmelo. Sono tutti in `lib/cellar/domain/wine_origins.dart`.
4. **Facoltativo:** cancellare `lib/cellar/ui/wine_list_tile.dart` (alias non più usato) e la chiave ARB `estimateDisclaimer`.
5. **Emulatore locale:** `npm run test:rules` richiede la porta 8080 libera. Con `npm run emulators` acceso, va chiuso prima di lanciarlo.
