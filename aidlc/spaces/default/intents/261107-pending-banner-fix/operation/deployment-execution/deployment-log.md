# Registro del rilascio — pending-banner-fix

## Fonti

- `operation/deployment-pipeline/cd-config.md` e `deployment-strategy.md`.
- `construction/build-and-test/test-results.md`.

## Cosa è stato fatto (2026-11-07)

| Ora (circa) | Azione | Esito |
|---|---|---|
| 1 | `npx firebase deploy --only firestore:rules,firestore:indexes --project vinoozy-d6f45`, con il via del proprietario (messaggio f17e05ca) | `rules file firestore.rules compiled successfully`, indici pubblicati, `Deploy complete!` |
| 2 | `flutter build apk --debug --dart-define-from-file=config/firebase_prod.json` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` |
| 3 | `adb -s c56aa1ad install -r …/app-debug.apk` sul telefono del proprietario (OnePlus CPH2581) e avvio | `Success`; `com.vinoozy.app/com.vinoozy.vinoozy.MainActivity` in primo piano |

## Cosa non è stato fatto

- **Nessun rilascio dal percorso Google Play.** La correzione non è ancora in un commit né in `main`: è nella cartella di lavoro, senza commit e senza push. Quindi `ci.yml`, `release.yml` e `promote.yml` non sono partiti per questa correzione. Il canale di test interno richiede anche i segreti di firma e di Play, che il proprietario deve ancora configurare su GitHub.
- **Tag `v0.1.0`:** non creato. Sarà creato da `promote.yml` alla prima pubblicazione in produzione (Q1 di Deployment Pipeline).

## Prossimo passo per arrivare in `main`

Commit della correzione su un ramo breve, push, 7 controlli di `ci.yml`, squash merge. Il job `e2e` può fallire per il doppione nello Storico (vedi Build and Test).
