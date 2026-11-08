# Requisiti di prestazione — riconoscimento delle etichette

## Fonti

- `inception/requirements-analysis/requirements.md` (NFR1, NFR2).
- `construction/functional-design/functional-spec.md` (D1, D3), `rules.md` (BR1.2, BR2.5, BR3.6).
- `tool/check_app_size.sh`, `tool/app_size_baseline.txt` (valore oggi `UNSET`).

## Telefono di riferimento

Si misura sul OnePlus CPH2581 del proprietario, con build release, base completa e la mediana di 5 prove dopo un primo avvio di riscaldamento. In CI vale un benchmark Dart sullo stesso algoritmo (`lib/catalog/core`, codice puro) con una base sintetica di 20.000 vini.

## Requisiti

| ID | Requisito | Soglia telefono | Soglia benchmark CI | Verifica |
|---|---|---|---|---|
| NFR2.1 | Ricerca per codice a barre nella base offline | ≤ 50 ms | tempo totale di 1.000 ricerche ≤ 50 ms (media ≤ 0,05 ms per ricerca) | benchmark + misura a mano in B&T |
| NFR2.2 | Confronto del testo (4000 caratteri, BR1.2) con tutta la base, punteggio BR3.6 compreso | ≤ 300 ms | ≤ 600 ms (margine ×2 per le macchine CI) | benchmark + misura a mano |
| NFR2.3 | Apertura della base al primo uso (decompressione gzip + indici) | ≤ 1,5 s | ≤ 3 s | misura a mano + test che controlla che l'apertura giri in un isolate |
| NFR2.4 | L'apertura non blocca l'interfaccia: decompressione e indicizzazione passano da una funzione `runInBackground` iniettata, che in produzione è `Isolate.run` | nessun blocco visibile (prova a mano in modalità profile, schermata Cantina che scorre durante l'apertura) | test unitario: il caricatore chiama la funzione iniettata con decompressione e indicizzazione, e non le esegue direttamente | test + prova a mano |
| NFR2.5 | Memoria della base aperta | ≤ 40 MB in più rispetto alla Cantina senza base | — | misura a mano con `adb shell dumpsys meminfo com.vinoozy.app` (PSS totale prima e dopo l'apertura) |
| NFR2.6 | La base si apre una volta sola per processo; due richieste contemporanee aspettano la stessa apertura | — | test unitario: il lettore del file viene chiamato una sola volta | test |
| NFR1.1 | Aumento del bundle dovuto alla base ≤ 15 MB, cioè il controllo bloccante già esistente di `tool/check_app_size.sh`, più severo del tetto di 40 MB del requisito di inception | — | — | in B&T: si misura il bundle di `0d99791` (costruito in un worktree pulito) con `--measure`, si scrive il numero in `tool/app_size_baseline.txt`, poi si esegue il controllo sul bundle nuovo. Se `bundletool` non può girare in locale, la misura si fa in CI |
| NFR1.2 | Il file della base compresso (`assets/wine_db/wines.jsonl.gz`) è ≤ 3 MB, cioè tre volte la stima di D1 | — | test dello strumento | oltre la soglia lo strumento esce con errore e non scrive la base; si decide col proprietario |

## Motivazioni (decise da me)

- **Margine ×2 in CI.** Le macchine GitHub Actions sono più lente e variabili di un telefono recente. Un margine doppio evita test che falliscono a caso. Il controllo vero resta la misura sul telefono.
- **20.000 vini sintetici.** Gli export reali danno circa 17.000 prodotti prima dei filtri di BR2.1. Il benchmark copre quindi il caso peggiore realistico.
- **Memoria 40 MB.** La stima di D1 è di qualche MB. Il tetto lascia spazio agli indici delle parole senza mettere a rischio telefoni con 4 GB.
- **Baseline delle dimensioni.** `tool/app_size_baseline.txt` è ancora `UNSET`, quindi `check_app_size.sh` oggi fallisce. B&T la fissa misurando il bundle dell'ultimo commit pubblicato (`0d99791`). Il limite che vale è quello già esistente di +15 MB: con una base sotto 1 MB compressa il margine è ampio, e il tetto di 40 MB dell'inception non scatta mai prima.

## Registrazione delle misure sul telefono

Le misure di NFR2.1, NFR2.2, NFR2.3 e NFR2.5 si fanno in B&T sul OnePlus CPH2581, con build release e 5 prove (mediana). Si scrivono in una tabella in `construction/build-and-test/` di questo lavoro: data, versione della build, numero di vini, valore misurato, soglia, esito. Per NFR2.3 la durata si legge dall'evento `wine_db_opened` in console (NFR4.13). Per gli altri si usa un'azione di prova nascosta, presente solo nelle build di debug e profile e mai in release.

## Fuori da questi requisiti

- La lettura del testo e del codice a barre nella foto (ML Kit) ha già i suoi tempi della U6 e non cambia, a parte che si fa due volte (fronte e retro). Il tempo totale della lettura si riporta in B&T ma non ha una soglia nuova.
