# Monitoring Design — u6-label-recognition

Fonti: `security-design.md` di U6 (§5 report degli errori), `performance-design.md` di U6 (§6 misure), `logical-components.md` di U6, `functional-spec.md` di U6, riepilogo confermato in `infrastructure-design-questions.md`.

## 1. Metriche

| Metrica | Origine | Soglia | Perché conta |
|---|---|---|---|
| Errori della foto (non fatali) | `LabelErrorReporter` → Crashlytics: `label_read_failed`, `label_pick_failed`, `label_lookup_failed`, `label_cleanup_failed` | > 10 eventi o > 3 utenti in 7 giorni | Senza testo letto, codici o percorsi (NFR8.2) |
| Crash nativi di ML Kit o del preparatore | Crashlytics (solo lo stack) | Qualsiasi nuovo crash | La lettura non deve mai far chiudere l'app |
| Tempi foto → proposta | Checklist §1-sexies | ≤ 3 s con rete, ≤ 2 s senza | NFR1.1 |
| Riconoscimento | 20 etichette reali, checklist | ≥ 14 su 20 | NFR2.1 |
| Dimensione dell'app | `tool/check_app_size.sh` in CI e `bundletool` nella checklist | ≤ +15 MB | NFR2.3, blocca il merge |
| Lettura sull'emulatore | Test end-to-end in CI | ≤ 10 s | NFR1.2, blocca il merge |

## 2. Avvisi

| Avviso | Condizione | Gravità | Destinatario |
|---|---|---|---|
| Errori della foto | Soglia di §1, letta nel controllo mensile | Bassa | Nessuna email: Crashlytics |
| Crash nuovi | Avviso standard di Crashlytics sui nuovi problemi | Media | Email al proprietario (già attivo) |

Nessun avviso nuovo in Cloud Monitoring: U6 non usa il cloud.

## 3. SLI e obiettivi

| Indicatore | Obiettivo | Finestra |
|---|---|---|
| Sessioni senza crash (Crashlytics) | ≥ 99% | 30 giorni |
| Utenti con `label_read_failed` | ≤ 3 | 7 giorni |
| Misure della checklist entro le soglie | 100% | Ogni versione |

## 4. Log e cruscotti

- Nessun log sul server. Gli eventi sono i non fatali di Crashlytics con il motivo fisso e il tipo dell'eccezione.
- Il cruscotto è la vista "Non fatali" di Crashlytics filtrata per `label_`.
- Un aumento di `label_read_failed` indica etichette difficili o un problema di ML Kit dopo un aggiornamento: si confronta con la misura delle 20 etichette.

## 5. Aggiunte alla checklist (`docs/release-checklist.md`)

- **§1-sexies Foto dell'etichetta (u6-label-recognition):** sulla build del test interno:
  - foto → proposta, 10 prove con rete e 10 senza, mediane entro le soglie;
  - 20 etichette reali di vini italiani, almeno 14 corrette;
  - "Importa una foto" dalla galleria e "Condividi → Vinoozy", anche ad app chiusa;
  - etichetta illeggibile, codice senza risultato, fotocamera chiusa senza scatto;
  - nessun file rimasto nella cartella `label/` dopo una lettura (con `adb shell run-as`);
  - dimensione di download con `bundletool get-size total`, confrontata con la versione precedente;
  - limite noto: HEIC non letto su Android più vecchi della versione 9.
- **§1-bis:** codice e parole lette dalla foto vanno a Open Food Facts come per i suggerimenti.
- **§2 Data Safety:** foto non raccolte; dati di ML Kit verificati sulla guida di Google, con data; informativa aggiornata.
- **Prima build iPhone:** spiegazioni dei permessi di fotocamera e foto tradotte in it, en, pt-BR.
- **§5 Controllo mensile:** una riga per gli eventi `label_*`.
