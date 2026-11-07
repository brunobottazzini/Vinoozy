# Infrastructure Specification — u6-label-recognition

Fonti:
- `logical-components.md`, `security-design.md` e `performance-design.md` di U6;
- `components.md` (inception, LabelRecognition), `functional-spec.md` di U6, `contract-summary.md` (C1);
- `ci.yml`, `release.yml`, `promote.yml`, `firebase-deploy.yml`, `docs/release-checklist.md`;
- riepilogo confermato in `infrastructure-design-questions.md`.

Per un'unità di interfaccia il design non funzionale non ha file separati `scalability-design.md`, `reliability-design.md` e `observability-design.md`:
- la scala è una foto alla volta, sul telefono;
- l'affidabilità è in `security-design.md` §7;
- l'osservabilità è descritta qui e in `monitoring-design.md`.

## 1. Deployment

| Aspetto | Scelta | Motivo |
|---|---|---|
| Calcolo | Tutto sul telefono: ML Kit con modelli inclusi, preparatore nativo Android delle immagini | Budget 0 €, privacy (Q1), lettura senza rete |
| Rete | Solo le richieste a Open Food Facts già fatte da U3 | Nessun servizio nuovo |
| Archiviazione | Solo `cacheDir/label/` sul telefono, file di vita breve | La foto non si conserva (Q1, NFR8.1) |
| Ambienti | Emulatore Android in CI, test interno e produzione di Google Play | Come team.md |
| Configurazione | `pubspec.yaml` (tre librerie), `AndroidManifest.xml` (filtro di condivisione, permessi rimossi), codice Kotlin in `android/app/src/main/kotlin/` | Nessuna configurazione nel cloud |
| Dimensioni | +15 MB al più sulla dimensione di download | NFR2.3 |

## 2. Risorse

| Risorsa | Ruolo | Configurazione | Note |
|---|---|---|---|
| Progetto Firebase `vinoozy-d6f45` | Database e servizi | Invariato | U6 non legge né scrive Firestore |
| `firestore.rules`, `firestore.indexes.json` | Regole e indici | Invariati | Nessuna pubblicazione con `firebase-deploy.yml` |
| Open Food Facts | Ricerca per codice e testo | Tramite U3, nei suoi limiti | Al più 2 richieste per foto |
| ML Kit (testo, codici a barre) | Lettura sul telefono | Modelli inclusi nell'app | Gratuito |
| Workflow | CI e rilascio | Passi aggiunti a `ci.yml` (`cicd-pipeline.md`); `release.yml`, `promote.yml`, `firebase-deploy.yml` invariati | — |
| Segreti GitHub | — | Invariati | Nessun segreto nuovo |

Nessuna risorsa condivisa nuova tra unità: U6 usa il catalogo di U3 e il salvataggio di U4 dentro l'app.

## 3. Costi

| Voce | Costo |
|---|---|
| ML Kit sul telefono | 0 € |
| Open Food Facts | 0 €, servizio pubblico, nei limiti di U3 |
| Firestore | Nessuna lettura o scrittura da U6; il salvataggio di U4 costa come un inserimento scritto |
| **Totale** | **0 €/mese**, avviso di spesa a 1 € invariato |

## 4. Pubblicazione

1. Merge su `main` con tutti i controlli verdi.
2. `release.yml` pubblica la build sul test interno.
3. Prova della checklist §1-sexies sul telefono.
4. Promozione con `promote.yml` e la tua approvazione.

Non serve pubblicare regole: il controllo di `promote.yml` sulle regole passa da solo, perché U6 non le cambia.

## 5. Sicurezza

- Nessun permesso Android nuovo: il manifest finale non contiene `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE` (verificato in `tool/check_release_build.sh`).
- Filtro di condivisione solo per `ACTION_SEND`/`ACTION_SEND_MULTIPLE` e `image/*`.
- Nessun segreto nuovo; nessuna immagine nel cloud.

## 6. Rollback

| Cosa | Come | Effetto |
|---|---|---|
| App | Fermare il rilascio graduale e pubblicare una correzione | Come per le altre unità |
| Regole, indici, dati | Nessuna azione | U6 non li cambia |
