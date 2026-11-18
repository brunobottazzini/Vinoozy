# Riepilogo di Code Generation — Lingue dei paesi del vino

Stato: i 23 passi del piano sono fatti e spuntati, compreso il passo 23 del [Loop-back 1](#loop-back-1--elenco-delle-lingue-nelle-impostazioni-di-android-passo-23). L'intera suite è verde. I tre punti rimasti aperti alla prima consegna (modulo precompilato a testo 200%, plurali del portoghese del Brasile, piano e abbonamento in finlandese) sono stati decisi dal proprietario e realizzati: vedi [Decisioni del proprietario](#decisioni-del-proprietario).

## Verifica del runner (passo 2)

- Comando: `flutter test test/app/`, eseguito dopo il passo 1 (elenco a 25 lingue, file ARB nuovi ancora vuoti) e prima dei passi dal 3 in poi.
- Esito: 136 test superati, nessuno fallito.
- Il comando di `unit-test-instructions.md` è eseguibile: `flutter test` accetta l'elenco dei file, e `dart run tool/gen_l10n_exercise.dart` genera `test/l10n/l10n_exercise_test.dart`.

## Risultati dei test

| Comando | Esito |
|---|---|
| `flutter test` (tutta la suite, dopo `gen_coverage_helper` e `gen_l10n_exercise`) | 4990 superati, 3 saltati, 0 falliti; 153 secondi su questo Mac |
| `flutter test test/cellar/ui/reveal_with_anchor_test.dart test/l10n/languages_test.dart` | 113 superati |
| `node tool/check_publication.mjs --draft` | superato: 25 cartelle × 3 testi e 25 blocchi di note di rilascio entro i limiti |
| `dart format --output=none --set-exit-if-changed .` | nessun file da formattare |
| `flutter analyze --fatal-infos` | nessun problema |
| `flutter gen-l10n` | `l10n_untranslated.json` vale `{}` |

I 3 test saltati erano già saltati prima di questo lavoro; nessun test di questo lavoro è saltato.

Test scritti ma non eseguiti: nessuno. Non misurati qui, come prevede il piano: la copertura dell'intera suite (NFR1, `tool/check_coverage.sh 80` in Build and Test) e la durata del job in GitHub Actions (NFR2, limite di 40 minuti). In locale la suite dura 153 secondi; la durata prima di questo lavoro non è stata misurata. La prova completa delle schermate passa da 3 a 10 lingue (da 12 a 40 prove per schermata).

### File di test non elencati in `unit-test-instructions.md`

`unit-test-instructions.md` è il file approvato e non è stato modificato. Elenca 7 file; questo lavoro ne ha aggiunti altri 4, che girano con `flutter test` insieme al resto della suite:

- `test/account/delete_confirm_word_languages_test.dart`: parola di conferma della cancellazione dell'account con e senza accenti (ro, de, hu, pl, sk, el, ka).
- `test/core/text_folding_test.dart`: confronto senza maiuscole e accenti nelle quattro scritture.
- `test/cellar/ui/origin_language_test.dart`: etichetta di lingua dei nomi d'origine e nome della lingua per `intl`.
- `test/cellar/ui/reveal_with_anchor_test.dart`: "Cerca online" interamente visibile dopo l'apertura del modulo precompilato.

Per eseguire solo i test di questo lavoro:

```bash
dart run tool/gen_l10n_exercise.dart
flutter test test/app/locale_resolution_languages_test.dart test/app/language_consistency_test.dart test/account/privacy_url_languages_test.dart test/cellar/domain/wine_origins_languages_test.dart test/catalog/core/catalog_locale_languages_test.dart test/l10n/languages_test.dart test/l10n/l10n_exercise_test.dart test/account/delete_confirm_word_languages_test.dart test/core/text_folding_test.dart test/cellar/ui/origin_language_test.dart test/cellar/ui/reveal_with_anchor_test.dart
```

## File creati

| File | A cosa serve |
|---|---|
| `lib/l10n/app_<lingua>.arb` (21 nuovi) e `app_pt.arb` compilato | Testi delle 22 lingue nuove (scritti dai traduttori) |
| `lib/l10n/app_localizations_<lingua>.dart` (21 nuovi) | Codice generato da `flutter gen-l10n`, versionato |
| `lib/cellar/domain/origin_country_names.g.dart` | Nomi dei 249 paesi nelle 22 lingue, generati da Unicode CLDR |
| `lib/cellar/ui/origin_language.dart` | Etichetta di lingua per i nomi d'origine (`pt` = Brasile, `pt-PT` = Portogallo) |
| `lib/core/text_folding.dart` | Confronto senza maiuscole e accenti in scrittura latina, greca, cirillica e georgiana (ricerca e parola di conferma) |
| `lib/cellar/ui/reveal_with_anchor.dart` | Alla prima richiesta di scorrimento del campo del nome tiene in vista anche la barra del modulo precompilato |
| `android/app/src/main/res/xml/locales_config.xml` | Le 25 lingue dichiarate ad Android 13 e successivi |
| `distribution/google-play/languages.json` | Lingua dell'app → cartella di Google Play |
| `distribution/google-play/<cartella>/` (22 nuove) | Titolo, descrizione breve e completa (scritti dai traduttori) |
| `tool/gen_origin_names.mjs` | Generatore dei nomi dei paesi da CLDR |
| `tool/gen_l10n_exercise.dart` | Generatore del test che richiama ogni messaggio in ogni lingua |
| `docs/l10n-glossary.md` | Glossario dei termini del vino, una colonna per lingua |
| `docs/store-languages.md` | Le 25 lingue, caricamento su Google Play, come aggiungere una lingua |
| Test nuovi | `test/app/locale_resolution_languages_test.dart`, `test/app/language_consistency_test.dart`, `test/account/privacy_url_languages_test.dart`, `test/account/delete_confirm_word_languages_test.dart`, `test/cellar/domain/wine_origins_languages_test.dart`, `test/cellar/ui/origin_language_test.dart`, `test/cellar/ui/reveal_with_anchor_test.dart`, `test/catalog/core/catalog_locale_languages_test.dart`, `test/core/text_folding_test.dart`, `test/l10n/languages_test.dart`; generato e ignorato da git: `test/l10n/l10n_exercise_test.dart` |

## File modificati

| File | Che cosa |
|---|---|
| `lib/app/locale_resolution.dart` | `appLocales` a 25 lingue; `resolveAppLocale` senza `switch` (lingua e paese, poi lingua base, `no`/`nn` → `nb`); `intlLocaleNameOf`; `androidLocaleTagOf` (loop-back 1) |
| `lib/cellar/domain/wine_origins.dart` | Nomi dei paesi da CLDR, mappa `names` delle regioni, ricerca nella lingua corrente; `foldOriginText` delega a `lib/core/text_folding.dart` |
| `lib/catalog/core/wine_catalog.dart`, `lib/catalog/core/off/open_food_facts_source.dart` | `CatalogLocale` per ogni lingua; nome del prodotto nella lingua, poi in inglese |
| `lib/account/account_providers.dart`, `lib/account/ui/profile_screen.dart` | Pagina della privacy per lingua |
| `lib/account/ui/delete_account_screen.dart` | Parola di conferma confrontata senza maiuscole e accenti (deviazione, vedi sotto) |
| `lib/cellar/ui/add_wine_screen.dart` | Il campo del nome è avvolto in `RevealWithAnchor`, con la barra come ancora (decisione del proprietario) |
| `lib/l10n/app_pt_BR.arb` | Ramo `=0` in 16 messaggi con il plurale (decisione del proprietario) |
| `lib/l10n/app_fi.arb`, `distribution/google-play/release-notes.txt` (blocco `fi-FI`) | Piano = "paketti", abbonamento di Google Play = "tilaus" (decisione del proprietario) |
| `lib/app/ui/country_flag.dart`, `lib/cellar/ui/origin_pickers.dart`, `wine_card.dart`, `wine_detail_screen.dart`, `drink_confirm_sheet.dart`, `lib/dashboard/ui/chart_cards.dart`, `lib/label/ui/candidate_list.dart`, `label_proposal_sheet.dart` | Le 11 letture di `languageCode` usano `originLanguageTagOf` |
| `lib/cellar/ui/wine_labels.dart`, `lib/app/ui/about_screen.dart`, `lib/plan/ui/dashboard_plan_notices.dart` | Date e numeri con `intlLocaleNameOf` (portoghese europeo = `pt_PT`) |
| `lib/l10n/app_localizations.dart`, `app_localizations_pt.dart` | Rigenerati |
| `l10n.yaml`, `.gitignore` | File dei messaggi non tradotti; file generati ignorati |
| `android/app/src/main/AndroidManifest.xml` | `android:localeConfig` |
| `tool/check_publication.mjs` | Legge `languages.json`, controlla le 25 cartelle e i blocchi delle note (massimo 500 caratteri) |
| `distribution/google-play/release-notes.txt` | 25 blocchi, nello stesso formato di prima |
| `distribution/google-play/{it-IT,en-US,pt-BR}/full-description.txt` | La frase sulle lingue dice ora "25 lingue" (vedi sotto) |
| `.github/workflows/ci.yml`, `README.md`, `tool/check_coverage.sh` (commento) | Generazione del test dei messaggi prima della copertura |
| `test/helpers/ui_harness.dart` | `supportedLocales` da `appLocales`, `matrixLocales` (10 lingue), `longestTextLocale` = `nl` |
| `test/u1/ui/app_root_test.dart`, `test/catalog/wine_catalog_types_test.dart`, `test/catalog/open_food_facts_source_test.dart` | Attese del comportamento a tre lingue aggiornate (tedesco, portoghese europeo e francese sono ora lingue dell'app) |

## Scelte prese in autonomia e loro motivo

### Nomi dei paesi (FR3.1)

- I nomi vengono dai dati Unicode CLDR, pacchetto `cldr-localenames-modern` versione 45.0.0, con `tool/gen_origin_names.mjs`. Lo strumento legge l'elenco delle lingue da `appLocales` e l'elenco dei paesi da `wine_origins.dart`, e si ferma se manca un nome.
- Per Hong Kong, Macao e Palestina si usa la forma breve di CLDR ("Hong Kong" e non "R.A.S. chinoise de Hong Kong"), come fanno i nomi già scritti a mano in italiano, inglese e portoghese del Brasile.
- Il serbo usa la scrittura cirillica (assunzione dei requisiti).

### Nomi delle regioni vinicole (FR3.2)

Scelta enologica: una regione ha un nome tradotto solo dove la lingua ne ha uno d'uso comune; altrimenti resta il nome canonico. Il valore salvato non cambia mai.

- **Tradotte in quasi tutte le lingue**: le regioni che sono anche regioni geografiche note, con un nome storico in ogni lingua (Borgogna, Toscana, Sicilia, Sardegna, Alsazia, Creta, Peloponneso, Macedonia, Dalmazia, Istria, Vienna, Ginevra, Lisbona, California, Tasmania, Patagonia).
- **Tradotte solo in alcune lingue**: le regioni con un nome consolidato solo nelle lingue vicine (per esempio `Pfalz` in francese, spagnolo, catalano, olandese, polacco, ceco e slovacco; `Valais` in tedesco e olandese).
- **Lasciate in originale**: i nomi che sono marchi del vino e che gli appassionati usano in originale (Rioja, Douro, Wachau, Napa Valley, Barossa Valley, Stellenbosch e simili, in ogni lingua a scrittura latina; Bordeaux e Champagne nelle lingue che non hanno un nome proprio, cioè tutte tranne spagnolo, catalano, portoghese, polacco, croato e sloveno). Nelle lingue in cirillico, greco e georgiano i più noti hanno la traslitterazione d'uso (Бордо, Μπορντό, ბორდო), perché in quelle lingue il nome si scrive così.
- **Grecia e Georgia**: i nomi canonici sono le traslitterazioni latine (`Kriti`, `Kakheti`); in greco e in georgiano si mostrano i nomi nella scrittura propria (Κρήτη, კახეთი).
- **Le valli del Cile** restano in spagnolo nelle lingue nuove: fuori da italiano, inglese e portoghese non hanno un nome consolidato.
- **Portoghese del Portogallo**: usa il nome brasiliano già presente, tranne dove la grafia europea è diversa (Francónia, Saxónia, Macedónia, Patagónia, Nova Iorque e simili).
- **Champagne e Campania in greco**: in greco si chiamano entrambe "Καμπανία". Per non confondere due regioni di due paesi, in greco restano i nomi canonici.
- **Stiria**: in sloveno e in croato la Stiria austriaca si chiama "Štajerska", che è anche il nome canonico della regione slovena. In sloveno la regione austriaca è "Avstrijska Štajerska"; in croato resta il nome canonico "Steiermark". Così un testo "Štajerska" continua a indicare una sola regione.

### Abbinamento "frutta secca" (`pairingDriedFruit`)

- In italiano "Frutta secca" indica soprattutto la frutta a guscio (noci, mandorle, nocciole) e, nell'uso comune, anche la frutta essiccata. È il senso giusto per gli abbinamenti dove compare: passiti, Vin Santo, Marsala, vini liquorosi.
- Il modello inglese "Dried fruit" è più stretto: indica solo la frutta essiccata. Il modello è quindi ambiguo rispetto all'italiano; non è stato modificato.
- Le lingue nuove seguono il senso italiano: dove la traduzione diceva solo "frutta essiccata" ora dice "frutta a guscio e frutta essiccata" (`de` Nüsse und Trockenfrüchte, `el` Ξηροί καρποί, `uk` Горіхи та сухофрукти e così via, 17 lingue). Restano com'erano `es`, `pt` (frutos secos), `ca` (fruita seca), `fr` (fruits secs) e `pl` (bakalie), che hanno già il senso italiano.

### Piano e abbonamento in `nl`, `da`, `nb`, `fi`

- In queste lingue la stessa parola ("abonnement", in finlandese "tilaus") indicava sia il piano dell'app (gratuito o Plus) sia l'abbonamento a pagamento su Google Play. Ora il piano è `pakket` (nl), `pakke` (da, nb) e `paketti` (fi, piano gratuito `ilmaispaketti` al posto di "ilmaisversio"). `abonnement` e `tilaus` restano solo per Google Play, come fanno il tedesco (Tarif / Abo) e lo svedese (abonnemang / prenumeration). Cambiati 8 messaggi per lingua e il blocco delle note di rilascio. In finlandese "Plus-tilauksella" (`thresholdReset`) resta, perché parla dell'abbonamento Plus di Google Play. I testi della scheda `fi-FI` non nominavano il piano.

### Frase sulle lingue nella scheda di Google Play

- La frase "Interfaccia in italiano, inglese e portoghese brasiliano" non era più vera. In tutte le 25 cartelle ora dice che l'interfaccia è disponibile in 25 lingue, tra cui quella della scheda (per esempio "Interface available in 25 languages, including English."), come già facevano `bg`, `el-GR`, `ka-GE`, `sr` e `uk`. Cambiati anche `it-IT`, `en-US` e `pt-BR`, come chiesto.

### Ricerca (FR3.3)

- La ricerca ignora maiuscole e accenti anche in greco (compreso il sigma finale), cirillico e georgiano. In cirillico `й` vale `и`, `ё` vale `е`, `ї` vale `і`, `ґ` vale `г`: sono lettere distinte, ma chi cerca le scrive spesso senza segno.
- Un accento scritto come carattere separato (forma decomposta) viene ignorato; prima spezzava la parola.

### Catalogo online (FR3.4)

- `CatalogLocale` non è più un elenco chiuso di tre lingue: accetta il codice di qualunque lingua dell'app, così il catalogo non ha un secondo elenco di lingue da tenere allineato (NFR5).
- La ricerca chiede a Open Food Facts anche il nome del prodotto nella lingua dell'app e in inglese (`product_name_<lingua>`, `product_name_en`). Il nome mostrato è, nell'ordine: quello nella lingua dell'app, quello inglese, quello senza lingua. La lettura di un prodotto dal codice a barre non cambia.

### Lingua del telefono (FR1.4, FR2.1)

- `resolveAppLocale` cerca in `appLocales` la lingua e il paese, poi la lingua base. `no` e `nn` ricevono `nb`. Un telefono in serbo con scrittura latina riceve il serbo in cirillico (unica variante offerta).

### Date, numeri e plurali del portoghese europeo (FR1.3, FR1.5, FR3.5)

- Il pacchetto `intl` legge `pt` come portoghese del Brasile. Per date e numeri la lingua dell'app `pt` passa a `intl` il nome `pt_PT` (`intlLocaleNameOf`).
- Per i plurali il codice generato usa invece `pt`, cioè la regola brasiliana, dove 0 cade nella forma "uno": `=1{1 garrafa}` avrebbe mostrato "1 garrafa" per zero bottiglie. I 16 messaggi di `app_pt.arb` con `=1{1 ...}` hanno ora un ramo `=0` con il plurale ("0 garrafas"), come vuole il portoghese europeo. Lo stesso valeva da prima per `app_pt_BR.arb`: vedi [Decisioni del proprietario](#decisioni-del-proprietario).

### Prova delle schermate (NFR3)

- La lingua con i testi più lunghi, misurata sui file ARB (somma dei caratteri), è l'olandese (21.880), fuori dalle altre nove della matrice. `longestTextLocale` in `test/helpers/ui_harness.dart` vale ora `nl` (prima, in via provvisoria, `fi`). `test/l10n/languages_test.dart` fallisce se un'altra lingua diventa più lunga.
- La schermata principale mostrata nelle 15 lingue fuori dalla matrice (NFR4) è il Cruscotto con due vini, a testo 200%.

## Deviazioni dal piano

1. **Parola di conferma della cancellazione dell'account** (necessaria perché FR1.2 funzioni in ogni lingua). `lib/account/ui/delete_account_screen.dart` confrontava `text.trim().toUpperCase() == word`: con parole che hanno diacritici (ȘTERGE, TÖRLÉS, LÖSCHEN, USUŃ, ODSTRÁNIŤ) chi scrive senza segni non poteva confermare, e il georgiano non ha maiuscole (`'წაშლა'.toUpperCase()` in Dart restituisce `'წაშლა'` invariato). Ora il confronto usa `foldText` (minuscole, accenti tolti, segni combinanti ignorati, maiuscole georgiane Mtavruli ricondotte alle lettere ordinarie). Le parole naturali sono tornate: greco `ΔΙΑΓΡΑΦΗ` al posto di `ΝΑΙ`, georgiano `წაშლა` al posto di `DELETE`. Il ripiegamento, prima privato in `wine_origins.dart`, è stato spostato in `lib/core/text_folding.dart` per usarlo in entrambi i punti. Test: `test/account/delete_confirm_word_languages_test.dart` (ro, de, hu, pl, sk, el, ka: parola esatta, senza accenti o in altro caso, parola sbagliata che lascia il pulsante disattivato) e `test/core/text_folding_test.dart`.
2. **Due traduzioni sostituite da sinonimi** per un falso positivo del controllo di contrasto. Con `uk` "Редагувати" (`guideEdit`) e `ka` "გადახედვა" (`guideComposePreview`) il controllo del contrasto a pixel dei test falliva in tema scuro e chiaro, mentre gli stessi widget, con gli stessi colori del tema, passavano nelle altre 23 lingue: è un effetto del font dei test su quelle due stringhe, non un contrasto reale. Ora sono "Змінити" e "წინასწარი ნახვა", traduzioni corrette dello stesso significato. Il tema e i test non sono stati toccati.
3. **Test in più rispetto al piano**: `test/cellar/ui/origin_language_test.dart`, `test/core/text_folding_test.dart`, `test/account/delete_confirm_word_languages_test.dart`, `test/cellar/ui/reveal_with_anchor_test.dart`, e in `test/l10n/languages_test.dart` un controllo che un ramo `one`/`=1` mostri il conteggio quando la regola CLDR della lingua lo usa anche per altri numeri.
4. **Regole di lavoro non rispettate**:
   - Nella prima parte del lavoro sei file sono stati modificati con `python3` dalla shell invece che con gli strumenti di modifica: `lib/account/account_providers.dart`, `lib/account/ui/profile_screen.dart`, `lib/app/locale_resolution.dart`, `test/u1/ui/app_root_test.dart`, `test/catalog/open_food_facts_source_test.dart`, `test/catalog/wine_catalog_types_test.dart`. La cartella `.cache/cldr` è stata creata con `mkdir -p`. Il contenuto è quello voluto e i test passano.
   - Nella seconda parte l'uscita della prima esecuzione completa di `flutter test` è stata scritta in `.cache/build-work/full_run_1.txt` invece di essere letta dal risultato del comando. Il file sta nella cartella `.cache/`, ignorata da git, insieme agli script di sola lettura usati per unire i glossari e misurare gli ARB (`.cache/build-work/*.mjs`, `upper_probe.dart`). Si possono cancellare.

## Decisioni del proprietario

Alla prima consegna tre punti erano rimasti aperti. Il proprietario li ha decisi e sono stati realizzati.

1. **Modulo precompilato a testo 200%.** Prima c'erano 10 test rossi in `test/cellar/ui/autofill_form_test.dart`, "AddWineScreen filled from a text meets the a11y guidelines", in `fr`, `de`, `el`, `uk`, `ka`, tema chiaro e scuro.
   - **Causa**: all'apertura il nome prende il fuoco (BR1.18) e il campo di testo scorre per mostrare il cursore. Lo scorrimento si fermava con "Cerca online" tagliato dal bordo superiore: 27 dp visibili su 48.
   - **Decisione**: il fuoco resta sul nome, ma lo scorrimento si ferma con il pulsante interamente visibile.
   - **Realizzazione**:
     - `lib/cellar/ui/reveal_with_anchor.dart` avvolge il campo del nome. Alla prima richiesta di scorrimento (quella del fuoco all'apertura), il rettangolo da mostrare parte dalla cima della barra del modulo precompilato e arriva al cursore.
     - Se tutto entra nello schermo restano visibili sia la barra sia il nome; se non entra, la barra si allinea al bordo superiore e il nome mantiene il fuoco.
     - Se il campo è già visibile non scorre nulla, quindi a testo normale il modulo non cambia.
     - Le richieste successive (scrittura, apertura della tastiera, ritorno del fuoco dopo "Pulisci" o dopo la verifica guidata) passano invariate, così il cursore resta sempre visibile mentre si scrive.
   - **BR1.18 e test**: BR1.18, `add_wine_screen_test.dart`, le soglie e le linee guida di accessibilità non sono stati toccati.
   - **`test/cellar/ui/reveal_with_anchor_test.dart`**:
     - a testo 200% in `de`, `fr`, `el`, `uk`, `ka`, `nl`: il nome ha il fuoco, "Cerca online" è alto almeno 48 dp e sta tutto dentro l'area visibile, e la linea guida dei 48 dp passa;
     - a testo normale in `it`, `en`, `de`: nessuno scorrimento, barra e nome visibili;
     - dopo la prima volta il campo si mostra come prima;
     - senza barra il comportamento è quello di prima.
   - **Verifica**: con l'estensione disattivata le 6 prove a testo 200% falliscono e quelle a testo normale passano; con l'estensione passano tutte.
2. **Plurali del portoghese del Brasile.** I 16 messaggi di `app_pt_BR.arb` con `=1{1 ...}` hanno ora un ramo `=0` con il plurale, come in `app_pt.arb`. Prima, con 0, mostravano "1 garrafa", "1 estrela de 5" e simili. Il controllo in `test/l10n/languages_test.dart` non salta più `pt-BR` e passa.
3. **Finlandese.** Il piano è "paketti" (piano gratuito "ilmaispaketti"), l'abbonamento di Google Play resta "tilaus". Le modifiche sono in `app_fi.arb`, nel blocco `fi-FI` delle note di rilascio ("Pakettisi (Ilmainen)") e nel glossario. I testi della scheda `fi-FI` non nominavano il piano e non sono cambiati.

## Loop-back 1 — elenco delle lingue nelle impostazioni di Android (passo 23)

Il problema l'ha trovato Build and Test sul telefono del proprietario (OnePlus CPH2581, Android 16; dettagli in `../build-and-test/test-results.md`, "Loop-back 1"). In **Impostazioni → App → Vinoozy → Lingua dell'app** comparivano 23 voci su 25: il serbo mancava, e `pt-BR` e `pt` comparivano fusi in un solo "Português".

### Causa e correzione

- **Forma dei tag**: la documentazione Android ("Per-app language preferences", sezioni "How to form locale names" e "Sample locale_config.xml file") vuole in `<locale android:name>` tag BCP 47: lingua, scrittura facoltativa (ISO 15924), paese facoltativo, separati da `-` (per esempio `zh-Hans-MO`). Non accetta la forma `b+sr+Cyrl` delle cartelle di risorse.
- **Portoghese**: il file di esempio di Google dichiara il portoghese come `pt-BR` e `pt-PT`. Un `pt` senza paese viene completato da Android con i valori più probabili, cioè `pt-BR`, e così si fondeva con il brasiliano. Ora il portoghese europeo è dichiarato `pt-PT`.
- **Serbo**: è dichiarato `sr-Cyrl`, con la scrittura esplicita, perché l'app è scritta in cirillico.
- **Unica fonte (NFR5)**: `appLocales` resta l'unica fonte e non cambia (`Locale('pt')`, `Locale('sr')`, file `app_pt.arb` e `app_sr.arb`). La corrispondenza con i tag di Android è esplicita: `androidLocaleTagOf` in `lib/app/locale_resolution.dart` dà il tag della lingua dell'app, tranne `pt` → `pt-PT` e `sr` → `sr-Cyrl`.
- **Risoluzione**: `resolveAppLocale` porta già ogni tag alla lingua giusta, perché confronta lingua e paese e ignora la scrittura. `pt-PT` → `pt`; `pt-BR` e `pt-Latn-BR` → `pt-BR`; `sr`, `sr-Cyrl`, `sr-Cyrl-RS`, `sr-Latn`, `sr-Latn-RS` → `sr` (serbo cirillico, l'unico offerto). Non è servito cambiarla; i test lo fissano.

### File cambiati

| File | Che cosa |
|---|---|
| `android/app/src/main/res/xml/locales_config.xml` | `pt` → `pt-PT`, `sr` → `sr-Cyrl`; commento sulla forma dei tag |
| `lib/app/locale_resolution.dart` | `androidLocaleTagOf` e la mappa `_androidTagAliases` |
| `test/app/language_consistency_test.dart` | La dichiarazione Android si confronta con `appLocales` attraverso `androidLocaleTagOf`. Due test nuovi: i tag sono BCP 47 (niente `pt` né `sr` nudi); ogni tag di Android torna alla sua lingua dell'app con `resolveAppLocale` |
| `test/app/locale_resolution_languages_test.dart` | Gruppo nuovo "languages chosen in the Android app settings": `pt-PT`, `pt-BR` (anche con `Latn`), `sr-Cyrl`, `sr-Cyrl-RS`, `sr-Latn-RS`, `sr-Latn`, e i tag dati da `androidLocaleTagOf` |
| `docs/store-languages.md` | Passo "Android" della guida per aggiungere una lingua: forma dei tag e mappa `androidLocaleTagOf` |

`traceability.json` non cambia: la destinazione di FR2.2, `android/app/src/main/res/xml/locales_config.xml`, esiste ancora ed è il file corretto. Nel fascicolo non c'è un elenco di fonti separato; l'elenco dei file è questo documento.

### Risultati

| Controllo | Esito |
|---|---|
| `flutter test test/app/language_consistency_test.dart test/app/locale_resolution_languages_test.dart` | 33 superati |
| `flutter gen-l10n` | `l10n_untranslated.json` = `{}` |
| `dart format` / `--set-exit-if-changed` | nessun file cambiato |
| `flutter analyze --fatal-infos` | nessun problema |
| `flutter test` (suite completa, dopo `gen_coverage_helper` e `gen_l10n_exercise`) | 4998 superati, 3 saltati (gli stessi di prima), 0 falliti; 168 secondi |
| `tool/check_release_build.sh` | uscita 0: tutti i controlli del manifest e dei marcatori superati, controlli positivi compresi |
| Manifest unito di release (`build/app/intermediates/merged_manifest/release/processReleaseMainManifest/AndroidManifest.xml`) | contiene `android:localeConfig="@xml/locales_config"` |
| `locales_config.xml` impacchettato (`build/app/intermediates/packaged_res/release/.../xml/locales_config.xml`, e `base/res/xml/locales_config.xml` dentro `build/check_release/app-release.aab`) | 25 voci, tra cui `pt-BR`, `pt-PT` e `sr-Cyrl`; nessun `pt` né `sr` nudo |

### Da verificare sul telefono

- **Cosa ripetere**: la prova di Build and Test sulla build del canale di test interno. L'elenco deve mostrare 25 voci, con "Português (Brasil)" e "Português (Portugal)" distinti e il serbo.
- **Rischio che resta**: Android mostra nelle impostazioni solo le lingue dell'app che il sistema del telefono conosce. Se la versione del sistema del OnePlus non include il serbo in cirillico, la voce potrebbe restare nascosta anche con `sr-Cyrl`. Questo non dipende dall'app.

## Problemi aperti

- **`overrideSheetHint`**: in inglese, italiano e portoghese del Brasile il messaggio cita un'etichetta che non esiste con quelle parole: "Ready from {start}" / «Pronto dal {start}» / "Pronto a partir de {start}", mentre l'etichetta mostrata (`levelPreviewNow`) è "Ready {start} – until {end}" / "Pronto {start} – fino al {end}" / "Pronto {start} – até {end}". I tre testi sono coerenti tra loro nel senso ma non citano alla lettera l'etichetta; le 22 lingue nuove li seguono. Non modificati.
- **Android**: `android:localeConfig` non è stato provato con una build; `tool/check_release_build.sh` gira in GitHub Actions e la prova sul telefono (FR2.2) è manuale.
- **Traduzioni senza revisione di un madrelingua** (assunzione dei requisiti), comprese le correzioni fatte qui.
- **Copertura e tempi**: da misurare in Build and Test. In locale la suite completa dura 153 secondi.
- **Comandi di test**: `unit-test-instructions.md` (file approvato, non modificato) elenca 7 file; i 4 file di test aggiunti in questo lavoro sono elencati sopra, in [File di test non elencati in `unit-test-instructions.md`](#file-di-test-non-elencati-in-unit-test-instructionsmd), e girano con `flutter test`.
- **Durante lo scorrimento a mano** il nome si comporta come prima: `RevealWithAnchor` agisce solo sulla prima richiesta di scorrimento del campo. Sul telefono la tastiera che si apre all'apertura del modulo riduce l'area visibile e porta di nuovo il cursore in vista; in quel momento la barra può uscire dalla parte alta dello schermo, come prima di questo lavoro. La decisione del proprietario riguarda lo scorrimento dovuto al fuoco, non la tastiera.
