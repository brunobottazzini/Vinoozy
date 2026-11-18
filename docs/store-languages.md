# Lingue di Vinoozy e scheda di Google Play

Vinoozy è disponibile in 25 lingue. Questa guida elenca le lingue, dice dove stanno i testi di ognuna, spiega come caricare a mano i testi della scheda su Google Play e come aggiungere una lingua in futuro.

L'app segue la lingua del telefono. Da Android 13 la persona può anche scegliere la lingua di Vinoozy nelle impostazioni di sistema dell'app. Non c'è una scelta della lingua dentro l'app.

## Le 25 lingue

| # | Lingua | Lingua dell'app | Testi dell'app | Cartella dei testi di Google Play |
|---|---|---|---|---|
| 1 | Inglese (lingua di ripiego) | `en` | `lib/l10n/app_en.arb` | `distribution/google-play/en-US/` |
| 2 | Italiano (lingua predefinita della scheda) | `it` | `lib/l10n/app_it.arb` | `distribution/google-play/it-IT/` |
| 3 | Portoghese del Brasile | `pt-BR` | `lib/l10n/app_pt_BR.arb` | `distribution/google-play/pt-BR/` |
| 4 | Portoghese del Portogallo | `pt` | `lib/l10n/app_pt.arb` | `distribution/google-play/pt-PT/` |
| 5 | Francese | `fr` | `lib/l10n/app_fr.arb` | `distribution/google-play/fr-FR/` |
| 6 | Spagnolo | `es` | `lib/l10n/app_es.arb` | `distribution/google-play/es-ES/` |
| 7 | Tedesco | `de` | `lib/l10n/app_de.arb` | `distribution/google-play/de-DE/` |
| 8 | Catalano | `ca` | `lib/l10n/app_ca.arb` | `distribution/google-play/ca/` |
| 9 | Greco | `el` | `lib/l10n/app_el.arb` | `distribution/google-play/el-GR/` |
| 10 | Rumeno | `ro` | `lib/l10n/app_ro.arb` | `distribution/google-play/ro/` |
| 11 | Ungherese | `hu` | `lib/l10n/app_hu.arb` | `distribution/google-play/hu-HU/` |
| 12 | Croato | `hr` | `lib/l10n/app_hr.arb` | `distribution/google-play/hr/` |
| 13 | Sloveno | `sl` | `lib/l10n/app_sl.arb` | `distribution/google-play/sl/` |
| 14 | Ceco | `cs` | `lib/l10n/app_cs.arb` | `distribution/google-play/cs-CZ/` |
| 15 | Slovacco | `sk` | `lib/l10n/app_sk.arb` | `distribution/google-play/sk/` |
| 16 | Bulgaro | `bg` | `lib/l10n/app_bg.arb` | `distribution/google-play/bg/` |
| 17 | Serbo (cirillico) | `sr` | `lib/l10n/app_sr.arb` | `distribution/google-play/sr/` |
| 18 | Georgiano | `ka` | `lib/l10n/app_ka.arb` | `distribution/google-play/ka-GE/` |
| 19 | Olandese | `nl` | `lib/l10n/app_nl.arb` | `distribution/google-play/nl-NL/` |
| 20 | Polacco | `pl` | `lib/l10n/app_pl.arb` | `distribution/google-play/pl-PL/` |
| 21 | Ucraino | `uk` | `lib/l10n/app_uk.arb` | `distribution/google-play/uk/` |
| 22 | Danese | `da` | `lib/l10n/app_da.arb` | `distribution/google-play/da-DK/` |
| 23 | Svedese | `sv` | `lib/l10n/app_sv.arb` | `distribution/google-play/sv-SE/` |
| 24 | Norvegese (bokmål) | `nb` | `lib/l10n/app_nb.arb` | `distribution/google-play/no-NO/` |
| 25 | Finlandese | `fi` | `lib/l10n/app_fi.arb` | `distribution/google-play/fi-FI/` |

Il nome di ogni cartella è il codice che Google Play usa per quella lingua. La corrispondenza tra lingua dell'app e cartella è scritta in `distribution/google-play/languages.json`.

Ogni cartella contiene tre file:

| File | Campo di Google Play | Lunghezza massima |
|---|---|---|
| `title.txt` | Nome dell'app | 30 caratteri |
| `short-description.txt` | Descrizione breve | 80 caratteri |
| `full-description.txt` | Descrizione completa | 4000 caratteri |

Le note di rilascio di tutte le lingue stanno in un solo file, `distribution/google-play/release-notes.txt`: un blocco per lingua, con il codice di Google Play tra parentesi angolari (per esempio `<fr-FR>` e `</fr-FR>`), di al massimo 500 caratteri.

Che cosa resta in tre lingue:

- Le pagine web della privacy e della cancellazione dell'account sono in italiano, inglese e portoghese del Brasile. Dalle altre lingue l'app apre la pagina inglese.
- Le catture di schermo sono in italiano, inglese e portoghese del Brasile. Per le altre lingue Google Play mostra quelle della lingua predefinita.

## Caricare i testi su Google Play

Il caricamento è manuale: nessuno strumento del repository scrive sulla scheda di Google Play.

1. Controllare i testi nel repository:

   ```bash
   node tool/check_publication.mjs --draft
   ```

   Il controllo fallisce se in una cartella manca un file o un testo supera la lunghezza massima.

2. Aprire [Google Play Console](https://play.google.com/console), scegliere Vinoozy, poi **Fai crescere gli utenti → Presenza sul Play Store → Scheda dello Store principale**.
3. Aggiungere le lingue: **Gestisci traduzioni → Gestisci le tue traduzioni**, selezionare le lingue della tabella che mancano e confermare. La lingua predefinita resta l'italiano (`it-IT`).
4. Per ogni lingua, scegliere la lingua nel selettore in alto e incollare:
   - **Nome dell'app**: il contenuto di `title.txt`;
   - **Descrizione breve**: il contenuto di `short-description.txt`;
   - **Descrizione completa**: il contenuto di `full-description.txt`.
5. Salvare. Ripetere il passo 4 per tutte le lingue: conviene seguire l'ordine della tabella e spuntare ogni riga.
6. Inviare le modifiche della scheda in revisione (**Panoramica della pubblicazione → Invia modifiche per la revisione**). Google controlla i testi di ogni lingua; una lingua rifiutata non blocca le altre.
7. A ogni rilascio, nella pagina del rilascio (**Test → Test interni** o **Produzione**, **Crea nuova release**), incollare nel campo **Note di rilascio** il contenuto di `distribution/google-play/release-notes.txt` così com'è: Google Play legge i blocchi per lingua.

Verifiche dopo il caricamento:

- Aprire la scheda con l'indirizzo `https://play.google.com/store/apps/details?id=com.vinoozy.app&hl=<codice>` (per esempio `hl=fr`, `hl=el`, `hl=ka`) e controllare titolo e descrizione.
- Su un telefono con Android 13 o successivo, con la build del canale di test interno: **Impostazioni → App → Vinoozy → Lingua** deve elencare le 25 lingue, e la scelta deve cambiare la lingua dell'app.

## Aggiungere una lingua

L'elenco delle lingue è scritto in un solo punto del codice: `appLocales` in `lib/app/locale_resolution.dart`. Da lì derivano la scelta della lingua, i test e i nomi dei paesi. Gli altri file elencati qui sotto sono file di testi o di dati: un test (`test/app/language_consistency_test.dart`) fallisce finché non elencano le stesse lingue.

1. **Elenco**: aggiungere la lingua ad `appLocales` in `lib/app/locale_resolution.dart`.
2. **Testi dell'app**: creare `lib/l10n/app_<lingua>.arb` con tutti i messaggi di `lib/l10n/app_en.arb`, gli stessi segnaposto e le forme di plurale della lingua, seguendo `docs/l10n-glossary.md`. Poi eseguire `flutter gen-l10n` e salvare in git i file `lib/l10n/app_localizations*.dart`. Il file `l10n_untranslated.json` deve risultare vuoto (`{}`).
3. **Glossario**: aggiungere la lingua a `docs/l10n-glossary.md`.
4. **Nomi dei paesi**: scaricare i dati Unicode CLDR e rigenerare i nomi. Lo strumento legge l'elenco del passo 1.

   ```bash
   mkdir -p .cache/cldr && (cd .cache/cldr && npm pack cldr-localenames-modern)
   node tool/gen_origin_names.mjs
   ```

5. **Nomi delle regioni vinicole** (facoltativo): in `lib/cellar/domain/wine_origins.dart` aggiungere il nome di una regione nella mappa `names`, solo dove la lingua ha un nome d'uso comune. Se la lingua usa una scrittura nuova (né latina, né greca, cirillica o georgiana), estendere anche `foldOriginText` nello stesso file, altrimenti la ricerca di paesi e regioni non funziona in quella lingua.
6. **Android**: aggiungere la lingua a `android/app/src/main/res/xml/locales_config.xml` con un tag BCP 47 (lingua, scrittura facoltativa, paese facoltativo, separati da `-`, per esempio `pt-PT` o `sr-Cyrl`; mai la forma `b+sr+Cyrl` delle cartelle di risorse). Android completa un tag senza paese né scrittura con i valori più probabili: se due lingue dell'app hanno la stessa lingua (come `pt` e `pt-BR`), quella senza paese va dichiarata con il suo paese o la sua scrittura. In quel caso aggiungerla anche alla mappa di `androidLocaleTagOf` in `lib/app/locale_resolution.dart`.
7. **Google Play**: aggiungere la lingua a `distribution/google-play/languages.json`, creare la cartella con i tre file di testo e aggiungere il blocco delle note di rilascio in `distribution/google-play/release-notes.txt`.
8. **Prova delle schermate**: se la lingua usa una scrittura nuova, aggiungerla a `matrixLocales` in `test/helpers/ui_harness.dart`. Lo stesso file contiene `longestTextLocale`, la lingua con i testi più lunghi: un test dice se va cambiata.
9. **Questa guida**: aggiungere la riga alla tabella delle lingue.
10. **Controlli**:

    ```bash
    dart format --output=none --set-exit-if-changed .
    flutter analyze --fatal-infos
    dart run tool/gen_coverage_helper.dart && dart run tool/gen_l10n_exercise.dart
    flutter test --coverage && tool/check_coverage.sh 80
    node tool/check_publication.mjs --draft
    ```

Una lingua con una variante regionale propria (come `pt-BR` accanto a `pt`) si aggiunge allo stesso modo, con il paese nell'elenco (`Locale('pt', 'BR')`) e nel nome del file (`app_pt_BR.arb`). Le varianti non elencate ricevono la lingua base: per esempio `fr-CA` riceve `fr`.
