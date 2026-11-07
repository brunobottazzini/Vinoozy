# Monitoring Design — u4-cellar

Fonti: `security-design.md` di U4 (§2 privacy, §4 affidabilità), `performance-design.md` di U4 (§4 costo, §6 misure), `logical-components.md` di U4, `functional-spec.md` di U4, `docs/firebase-setup.md` §7, riepilogo confermato in `infrastructure-design-questions.md`.

## 1. Metriche

| Metrica | Origine | Soglia | Perché conta |
|---|---|---|---|
| Letture giornaliere di Firestore | Cloud Monitoring, avviso esistente di U7 | 35.000 al giorno | La quota gratuita è di 50.000 per tutto il progetto. |
| Rifiuti delle regole | Cloud Monitoring, avviso esistente di U1 | > 50 in 1 ora | Un rifiuto ripetuto indica regole e app non allineate. |
| Errori della Cantina (non fatali) | `ErrorReporter` → Crashlytics, con motivi fissi: `cellar_save_failed`, `cellar_drink_failed`, `cellar_undo_failed`, `cellar_record_update_failed`, `cellar_delete_failed`, `cellar_merge_failed`, `cellar_reconcile_failed`, `estimate_refresh_failed`, `match_key_backfill_failed`, `pending_probe_failed` | > 10 eventi o > 3 utenti in 7 giorni | Senza nomi, produttori, denominazioni o note (NFR8.2). |
| Tempi sul telefono | Checklist §1-quinquies | Inserimento < 30 s; salvataggio ≤ 300 ms; dettaglio ≤ 500 ms; scorrimento sotto il periodo dello schermo | NFR1.1, NFR1.3, NFR2.2, NFR2.3. |
| Benchmark | `cellar_benchmark.dart` nel job `unit` | Filtri ≤ 20 ms; finestra effettiva ≤ 5 ms | NFR2.1, NFR2.4: blocca il merge. |

## 2. Avvisi

| Avviso | Condizione | Gravità | Destinatario |
|---|---|---|---|
| Letture giornaliere (esistente) | Somma mobile su 24 ore > 35.000 | Media | Email al proprietario |
| Rifiuti delle regole (esistente) | > 50 in 1 ora | Media | Email al proprietario |
| Errori della Cantina | Soglia di §1, letta nel controllo mensile | Bassa | Nessuna email: Crashlytics |

Nessun avviso nuovo. Dopo la pubblicazione di U4 alcuni rifiuti sono attesi:
- "Annulla" arrivato al server dopo 10 minuti o dopo un'altra cancellazione;
- parti di un'eliminazione con una bevuta già cancellata.

Sono gestiti dall'app e non contano come "accesso perso". Si indaga solo se il numero resta alto per più ore.

## 3. SLI e obiettivi

| Indicatore | Obiettivo | Finestra |
|---|---|---|
| Sessioni senza crash (Crashlytics) | ≥ 99% | 30 giorni |
| Utenti con un errore `cellar_*` | ≤ 3 | 7 giorni |
| Misure della checklist entro le soglie | 100% | Ogni versione |

## 4. Log e cruscotti

- Nessun log sul server: non ci sono funzioni nel cloud. I log sono gli eventi non fatali di Crashlytics, con il solo motivo fisso e il tipo dell'errore.
- Il cruscotto è la pagina "Utilizzo" della console Firebase più la vista "Non fatali" di Crashlytics filtrata per `cellar_`.
- `match_key_backfill_failed` ripetuto per lo stesso utente nel controllo mensile indica un backfill che non finisce. La cantina funziona comunque; si corregge con una nuova versione.

## 5. Aggiunte alla checklist (`docs/release-checklist.md`)

- **§1-quinquies Cantina (u4-cellar):** sulla build del test interno:
  - inserimento di un vino dai suggerimenti, 10 prove, mediana < 30 s;
  - salvataggio fino all'elenco ≤ 300 ms; dettaglio ≤ 500 ms; scorrimento fluido con 500 vini;
  - doppione: avviso, aggiunta di bottiglie, unione;
  - bevuta con "Annulla" e con "Aggiungi voto e note"; Storico e "Aggiungi di nuovo";
  - offline: bevuta dell'ultima bottiglia, banner "in attesa", poi sincronizzazione al ritorno della rete;
  - riscontro "era ancora buono": finestra ricalcolata con l'avviso sulla stima.
  
  Una versione va in produzione solo con le misure entro le soglie, o con lo scostamento accettato per iscritto.
- **§2 Data Safety:** verificare che note e voti rientrino già nei dati della cantina dichiarati (NFR8.3).
- **§3 Promozione:** prima `firebase-deploy.yml`, poi l'indice di `drinkingRecords` "Abilitato" (passo manuale: nessun workflow lo verifica), poi la promozione.
- **§4 Rollback:** le regole si riportano indietro solo prima della promozione; dopo, si corregge in avanti.
- **§5 Controllo mensile:** una riga per gli eventi `cellar_*`, `estimate_refresh_failed`, `match_key_backfill_failed` e `pending_probe_failed`.
