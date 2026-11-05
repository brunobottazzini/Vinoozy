# Performance Design — u1-skeleton

Fonti: `performance-requirements.md` (NFR1.1, NFR1.2, NFR2.1–NFR2.5, NFR3.1–NFR3.4, NFR5.1–NFR5.3), `tech-stack-decisions.md`, `functional-spec.md`, `frontend-components.md`.

## Avvio (NFR2.1: 2 s su telefono, 4 s in CI)

| Fase | Budget | Scelta |
|------|--------|--------|
| `Firebase.initializeApp`, poi App Check, poi Crashlytics e lettura del registro in parallelo | 600 ms | App Check prima di ogni chiamata ad Auth e Firestore (security-design.md §7); Crashlytics non blocca il primo fotogramma |
| `AccountGate` (sessione + registro) | 100 ms | `currentUser` è sincrono dopo l'inizializzazione; `shared_preferences` viene letto una sola volta |
| Prima lettura della Cantina | 500 ms | Primo snapshot dalla cache (`Source.cache` implicito offline); con rete il server aggiorna dopo |
| Primo fotogramma dell'elenco | 300 ms | `ListView.builder`, nessuna immagine in U1 |

Al primo fotogramma si mostra una splash nativa (`flutter_native_splash`), non un indicatore Flutter. `ensurePersonalCellar` gira in parallelo alla lettura della cache e non blocca l'elenco già presente.

Misura: il test end-to-end `startup_test.dart` registra il tempo tra `main()` e la prima `WineListTile` visibile (`Timeline`/`Stopwatch`), mediana di 5 avvii. Il job fallisce sopra 4 s.

## Salvataggio (NFR1.1: 300 ms)

- `AddWineScreen` chiama `WineRepository.create()`. Il metodo attende `LocalLedger.beginWrite` (circa 5–20 ms) e poi `doc.set()` **senza** attenderne il Future. Il Future viene agganciato a `SyncErrorBus` e al giornale.
- L'elenco si aggiorna dallo snapshot locale, che Firestore emette subito con `hasPendingWrites = true`.
- Il modulo si chiude subito dopo `beginWrite`.
- Misura: il test end-to-end offline cronometra il tempo tra il tocco su Salva e la `WineListTile` con il nome nuovo.

## Elenco con 500 vini (NFR2.2)

- `ListView.builder` con `itemExtent` fisso per righe a una sola riga di testo. Con il testo al 200% si usa `prototypeItem` per non perdere la virtualizzazione.
- Ordinamento per nome sul client (U1 non ha filtri). Su 500 elementi resta sotto 1 ms.
- `WineListTile` è `const` dove possibile; la ricostruzione avviene solo per i documenti cambiati, con le chiavi `ValueKey(wineId)`.

## Ascoltatori e letture (NFR5.1, NFR5.2)

| Provider (Riverpod) | Sorgente | Note |
|---------------------|----------|------|
| `cellarStreamProvider` | `cellars/{uid}.snapshots(includeMetadataChanges: true)` | Unico ascoltatore della cantina, `keepAlive` |
| `winesStreamProvider` | `cellars/{uid}/wines.snapshots(includeMetadataChanges: true)` | Unico ascoltatore dei vini |
| `syncStatusProvider` | Derivato dai due precedenti | Calcola in attesa, offline e sincronizzato; non apre nuovi ascoltatori |

`includeMetadataChanges` non genera letture in più sul server. Le letture del giornale (`Source.server`) avvengono solo per le voci aperte, dopo `drain()`.

## Stato della rete (NFR2.4, NFR2.5)

- `syncStatusProvider` calcola:
  - **in attesa:** almeno uno dei due snapshot ha `hasPendingWrites`;
  - **offline:** in attesa e l'ultimo snapshot ha `isFromCache = true` da almeno 2 s. La tolleranza evita un falso "offline" nei primi istanti dell'ascolto, quando il primo snapshot arriva sempre dalla cache;
  - **in corso:** in attesa e `isFromCache = false`.
- `OfflineBanner` legge solo `syncStatusProvider` e si aggiorna entro 1 s da ogni nuovo snapshot di metadati, come chiede NFR2.4. Il momento in cui Firestore si accorge della perdita di rete dipende dall'SDK (può volerci qualche secondo) e non dipende dall'app. Il test end-to-end misura il ritardo tra lo snapshot e l'indicatore, non quello tra lo spegnimento della rete e l'indicatore.
- `connectivity_plus` si usa solo in `SignInScreen` per il messaggio del primo accesso.

## Accessibilità (NFR3.1–NFR3.4)

- Colori dai token di `design-system-mapping.md` in `ThemeData` chiaro e scuro. Nessun colore scritto direttamente nei widget.
- Ogni schermata ha un test dei widget con `meetsGuideline` per contrasto, aree toccabili ed etichette, ripetuto per it, en e pt-BR e con `textScaler` 1.0 e 2.0.
- `OfflineBanner` usa `Semantics(liveRegion: true)` per essere annunciato da TalkBack.

## Non applicabile a U1

- NFR1.2 (30 secondi con i suggerimenti) → u4-cellar.
- NFR2.3 (Cruscotto) → u5-dashboard.
