# Istruzioni dei test di integrazione ed end-to-end

## Fonti

- `construction/code-generation/unit-test-instructions.md`
- `integration_test/`

## Firebase Emulator Suite

Progetto `demo-vinoozy`, Firestore sulla porta 8080 e Auth sulla 9099. Se è già avviata (anche da un'altra sessione) si usa così com'è.

```bash
npm run test:rules
# con la porta 8080 già occupata:
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix test/rules test -- u1.rules.test.mjs u7.rules.test.mjs u4.rules.test.mjs u8.rules.test.mjs label_autofill.rules.test.mjs compat/
```

## End-to-end su emulatore Android

L'emulatore deve avere la dimensione del testo al 100% (con il 200% falliscono test che non dipendono dal codice).

```bash
flutter test integration_test/u1_skeleton_test.dart integration_test/account_test.dart \
  integration_test/cellar_test.dart integration_test/concurrent_drink_test.dart \
  integration_test/sharing_test.dart integration_test/label_test.dart \
  integration_test/autofill_test.dart integration_test/override_test.dart \
  -d emulator-5554 --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true
```

- Nessun test chiama Google o Open Food Facts reali: Open Food Facts è finto, la fotocamera e Lens passano da canali finti.
- `autofill_test.dart` usa la base e2e (`integration_test/support/e2e_wine_db.dart`) e, per il caso dei 2 secondi, la base reale aperta a freddo.

## Prova manuale sul telefono

Dopo l'installazione (vedi `build-instructions.md`), secondo `docs/release-checklist.md` §1-decies:
1. Lens → seleziona il testo → "Copia" → Vinoozy → "Incolla da Lens": "Leggo il testo…" subito, risultato entro 2 secondi.
2. Guida: Sì, No, composizione con le parole, ruota dell'annata e "Senza annata".
3. Interruzioni: Indietro, Chiudi, "Conferma guidata", nuovo testo a guida aperta.
