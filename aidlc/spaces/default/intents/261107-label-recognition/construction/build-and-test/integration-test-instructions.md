# Istruzioni dei test di integrazione e end-to-end — riconoscimento delle etichette

## Preparazione

- Emulatore Android avviato con 4 core e 4 GB:
  ```bash
  emulator -avd Medium_Phone_API_36.1 -cores 4 -memory 4096
  ```
- L'emulatore deve avere **testo al 100% e densità di default**. Con testo al 200% i pulsanti escono dallo schermo e i test falliscono senza che ci sia un difetto. Per ripristinare:
  ```bash
  adb shell settings put system font_scale 1.0
  adb shell wm density reset
  ```
- Firebase Emulator Suite (`demo-vinoozy`), avviata dal comando stesso oppure già accesa sulle porte 8080 e 9099.

## Comandi

```bash
# solo il riconoscimento delle etichette (5 scenari, circa 45 s)
npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
  "flutter test integration_test/label_test.dart -d <emulatore> --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"

# suite completa (circa 8 minuti)
npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
  "flutter test integration_test -d <emulatore> --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
```

## Confini provati

| Confine | Come |
|---|---|
| Fotocamera e galleria | `FakeImageSource` passata attraverso `LabelServices` (mai la fotocamera reale) |
| Lettura ML Kit | reale, sul dispositivo, con etichette disegnate dal test |
| Base offline | la base vera degli asset (oggi quella di prova) |
| Open Food Facts | `MockClient`; si controlla che nessuna richiesta esca davvero |
| Rete | `SwitchableNetwork`, accesa e spenta dal test |
| Google Lens | `RecordingLensLauncher`; si controlla che senza conferma non venga chiamato |
| Firestore e Auth | Firebase Emulator Suite |
| File temporanei | alla fine di ogni scenario `cache/label/` è vuota |

## Test di widget sui confini

`test/label/ui/label_scope_test.dart` controlla che fronte, retro, ricerca, "Cerca online" e Lens usino i servizi della schermata che ha avviato la lettura (regressione trovata in Build and Test).
