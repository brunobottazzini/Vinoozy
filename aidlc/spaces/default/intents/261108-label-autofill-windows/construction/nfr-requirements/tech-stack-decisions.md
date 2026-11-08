# Scelte tecniche

## Fonti

- `construction/functional-design/`: D1–D6, BR3.6, BR6.
- `inception/requirements-analysis/requirements.md`: NFR2, NFR5, NFR6, FR6.

## Decisioni

### TS1 — Nessun pacchetto nuovo

Bastano gli strumenti che ci sono già:
- `Clipboard` di Flutter;
- `MethodChannel` (`vinoozy/lens`);
- `AppLifecycleListener`;
- la libreria standard di Dart.

### TS2 — Strumento `tool/build_appellations.dart`

Usa solo la libreria standard di Dart, come `build_wine_db`. Ha questi ingressi:
- l'export CSV di eAmbrosia (vini, DOP e IGP);
- i file CSV in `tool/data/appellations/`, scritti nel repository con fonte e data nell'intestazione. Contengono le AVA di TTB, che sono di pubblico dominio, e le GI ufficiali di AU, NZ, ZA, AR, CL, BR, UY e CH.

L'uscita è `packages/estimation/lib/src/generated/appellations.g.dart`, formattato con `dart format`.

### TS3 — Licenze dei dati

- **eAmbrosia.** È un dato pubblico della Commissione UE, che ne consente il riuso citando la fonte (decisione 2011/833/UE). La citazione va in `README` e nella schermata Informazioni.
- **AVA statunitensi.** Sono di pubblico dominio.
- **Altri registri.** Prima di includerli, in Code Generation si verifica la licenza di ciascuno e la si annota nell'intestazione del CSV. Si usano solo i nomi, cioè dati geografici pubblici, mai descrizioni o testi. Il diritto sui generis UE sulle banche dati non si applica all'estrazione di nomi isolati dagli elenchi pubblici ufficiali. Un registro con una licenza che vieta il riuso si esclude, e quel paese prende la finestra dai vitigni o dal tipo.
- **Attribuzioni.** La schermata Informazioni mantiene l'attribuzione ODbL di Open Food Facts già presente e aggiunge quella dei registri (NFR5.7).
- **Requisito derivato NFR5.7.** La schermata Informazioni cita la fonte delle denominazioni: "Denominazioni: registro eAmbrosia (UE) e registri ufficiali nazionali".

### TS4 — Test

| ID | Requisito |
|---|---|
| NFR5.1 | Copertura ≥ 80% delle righe sul progetto, senza esclusioni. Il file generato `appellations.g.dart` è sotto `packages/estimation`, quindi conta nella copertura del pacchetto (≥ 90%), e i test di BR3.9 lo percorrono tutto. |
| NFR5.2 | Un test per ogni riga dedicata e per ogni modello, più l'insieme di riferimento dell'estrattore (BR1.10). |
| NFR5.3 | Test delle regole e di compatibilità (NFR1.2–NFR1.4). |
| NFR5.4 | Due e2e senza servizi reali: uno per "Incolla da Lens" o "Condividi" (testo finto) e uno per la correzione manuale. |
| NFR5.5 | La suite esistente resta verde. |
| NFR6.1 | Codice e commenti in inglese; testi nei 3 file ARB; matrice di accessibilità (3 lingue × testo 1,0/2,0 × chiaro/scuro) per i componenti nuovi; `dart format` e `flutter analyze --fatal-infos` puliti. |
| NFR2.2 | Nessun costo e nessun servizio a pagamento. Gli export di eAmbrosia e Open Food Facts si scaricano gratuitamente, a mano, in Build and Test (FR6, BR6.3). |
| NFR6.2 (FR7.8) | La scheda della guida, le parole e la ruota dell'annata passano la matrice di accessibilità (3 lingue × testo 1,0/2,0 × chiaro/scuro); controlli A15–A22 di `inception/refined-mockups/accessibility-checklist.md`; `meetsGuideline` per tap target e contrasto. |
| NFR5.10 (NFR5.8, NFR5.9) | Test della guida: unitari sull'insieme di riferimento di `label-reference-set.md` (fixture JSON, D13), widget nella matrice di NFR6.2, e2e della guida e dei 2 secondi in CI senza Google e con Open Food Facts finto. Nessun nuovo pacchetto: la ruota usa `ListWheelScrollView` di Flutter. |
