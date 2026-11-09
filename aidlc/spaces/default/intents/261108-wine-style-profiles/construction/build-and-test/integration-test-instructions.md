# Istruzioni dei test di integrazione ed end-to-end

## Fonti

- `construction/code-generation/unit-test-instructions.md`
- `construction/nfr-requirements/security-requirements.md` (NFR2.1–NFR2.3)
- `integration_test/style_profile_flow_test.dart`

## Confini verificati

| Confine | Test | Cosa dimostra |
|---|---|---|
| App → regole Firestore | `test/rules/style_profiles.rules.test.mjs` | campi nuovi validi e non validi, finestra in mesi, `baseWindow` controllata, budget delle 1000 espressioni sulle scritture reali dell'app (creazione, modifica divisa in due update, scelta dello stile, migrazione) |
| Versioni vecchie e nuove dell'app | `test/rules/compat/` (`app-writes.json`, versione `wine-style-profiles`) | una versione vecchia che aggiorna un vino nuovo non cancella i campi nuovi; le regole nuove accettano le scritture di oggi |
| Migrazione → Firestore | `test/cellar/style_migration_test.dart`, `estimates_migration_test.dart` (transazione con i mock) | transazione con `updatedAt`, ripresa, fuori rete non parte, campi `user` e correzioni conservati |
| Studio → mappa → stima | `test/tool/build_profile_map_test.dart`, `packages/estimation/test/profile_map_test.dart` | 24 profili, 5946 combinazioni identiche alla fixture, stima che riproduce la mappa salvo 3 eccezioni fissate |
| Base offline → catalogo → modulo | `test/tool/build_wine_db_classify_test.dart`, `autofill_form_test.dart` | Tipologia, Livello e Stile preselezionati dalla base in formato 2 |
| Percorso reale sul telefono | `integration_test/style_profile_flow_test.dart` | modulo con Stile e data di sboccatura, avviso "Stile da confermare", riquadro "Da confermare", migrazione con le regole vere |

## Firebase Emulator Suite

Progetto `demo-vinoozy`, Firestore sulla porta 8080 e Auth sulla 9099. Se è già avviata (anche da un'altra sessione) si usa così com'è, senza fermarla.

```bash
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix test/rules test -- u1.rules.test.mjs u7.rules.test.mjs u4.rules.test.mjs u8.rules.test.mjs label_autofill.rules.test.mjs compat/
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix test/rules test -- style_profiles.rules.test.mjs
```

L'ultimo file eseguito deve essere `style_profiles`, così nel progetto `demo-vinoozy` restano caricate le regole correnti per l'e2e (`compat/` vi lascia quelle di produzione).

## End-to-end su emulatore Android

Emulatore con dimensione del testo al 100%.

```bash
flutter test integration_test/style_profile_flow_test.dart integration_test/autofill_test.dart integration_test/label_test.dart \
  -d emulator-5554 --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true
```

- Nessun test chiama Google, Open Food Facts o il progetto Firebase reale.
- In questo ambiente il caricamento fallisce prima del primo test (vedi `test-results.md`): va eseguito da un terminale normale del proprietario o in GitHub Actions.

## Prova manuale sul telefono

Secondo `docs/release-checklist.md` §1-undecies, dopo la pubblicazione delle regole e l'installazione:
1. Aggiungi un vino noto (es. Barolo 2016): Tipologia, Livello e Stile preselezionati con "✦ suggerito".
2. Uno spumante metodo classico: data di sboccatura, finestra in mesi.
3. Un vino ambiguo: avviso "Stile da confermare" e riquadro "Da confermare" nel cruscotto.
4. Modifica di un vino con riscontro di bevuta: il salvataggio riesce.
