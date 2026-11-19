# Dependencies

Versioni e scopo di ogni libreria: `technology-stack.md`. Qui stanno le relazioni.

## External Dependencies

### Runtime services

| Servizio | Usato da | Note |
|---|---|---|
| Firebase Auth | Account, Account Deletion Web, Cloud Functions | Accesso con Google |
| Cloud Firestore | Cellar, Sharing, Account, Sync, Plan, Cloud Functions, Account Deletion Web | Coda offline sul telefono; regole nel repository |
| Firebase App Check | App Shell, Cloud Functions | Play Integrity in rilascio; obbligatorio per le callable |
| Firebase Crashlytics | App Shell | Solo build di rilascio del progetto reale |
| Cloud Functions | Plan, Ads, Usage | Mai distribuite dalla CI |
| Google Play Billing | Plan, Cloud Functions | Acquisto e verifica di Plus |
| Google Play Store (pagina dell'app) | Sharing (messaggio d'invito) | Link `https` in `playStoreLink` |
| Google Mobile Ads | Ads | Un tentativo al giorno |
| ML Kit sul telefono | Label | Modelli inclusi nell'app; testo solo in scrittura latina |
| Google Lens (app Google) | Label | Avviato su richiesta esplicita |
| Open Food Facts | Catalog | Solo con rete; licenza ODbL, attribuzione obbligatoria |
| Browser di sistema | App Shell, Account | Link `https` dal canale `com.vinoozy.app/links` |
| Foglio di condivisione Android | Sharing | Attraverso `share_plus` |
| Google Play Developer API | CI/CD Workflows | Rilascio e promozione |
| GitHub Pages | CI/CD Workflows | Pagine pubbliche |

### Build-time data sources

| Fonte | Usata da | Risultato |
|---|---|---|
| Esportazione di Open Food Facts, scaricata a mano | `tool/build_wine_db.dart` | `assets/wine_db/wines.jsonl.gz`, `manifest.json` |
| Registro eAmbrosia e file CSV in `tool/data/appellations/` | `tool/build_appellations.dart` | `packages/estimation/lib/src/generated/appellations.g.dart` |
| File ARB | `flutter gen-l10n` | `lib/l10n/app_localizations*.dart` |
| `lib/l10n/app_en.arb` | `tool/gen_l10n_exercise.dart` | `test/l10n/l10n_exercise_test.dart` |

### Package manifests

| Manifest | Gestore | Aggiornamenti |
|---|---|---|
| `pubspec.yaml`, `pubspec.lock` | pub | Dependabot settimanale |
| `packages/estimation/pubspec.yaml` | pub | Nessuna dipendenza di produzione, verificato in CI |
| `package.json`, `package-lock.json` | npm | Versioni esatte |
| `functions/package.json`, `tool/admin/package.json`, `test/rules/package.json` | npm | Pacchetti separati |
| `android/**/*.kts` | Gradle | Plugin di Flutter e di Firebase |
| `.github/workflows/*.yml` | GitHub Actions | Azioni fissate per SHA, Dependabot settimanale |

## Internal Dependencies

```mermaid
flowchart LR
  Shell["App Shell"] --> Account
  Shell --> Cellar
  Shell --> Dashboard
  Shell --> Sharing
  Shell --> Label
  Shell --> Plan
  Shell --> Ads
  Shell --> L10n["Localization"]
  Account --> Sync
  Account --> Cellar
  Account --> Plan
  Account --> Shell
  Cellar --> Estimation["Estimation Package"]
  Cellar --> Catalog
  Cellar --> Sync
  Cellar --> Usage
  Cellar --> Account
  Catalog --> Estimation
  Label --> Catalog
  Label --> Estimation
  Dashboard --> Cellar
  Dashboard --> Estimation
  Sharing --> Cellar
  Sharing --> Account
  Sharing --> Usage
  Plan --> Usage
  Plan --> Dev["Dev Tools"]
  Ads --> Sync
```

<!-- Text fallback: App Shell dipende da Account, Cellar, Dashboard, Sharing, Label, Plan, Ads e Localization. Account dipende da Sync, Cellar, Plan (ProfilePlanRow) e App Shell (link esterni, HomeShell). Cellar dipende da Estimation Package, Catalog, Sync, Usage e Account (il menu apre ProfileScreen). Catalog dipende da Estimation Package. Label dipende da Catalog ed Estimation Package. Dashboard dipende da Cellar ed Estimation Package. Sharing dipende da Cellar, Account e Usage. Plan dipende da Usage e Dev Tools. Ads dipende da Sync per l'archivio chiave-valore. -->

Osservazioni:

- `Estimation Package` è una foglia: non importa nulla del resto.
- `Localization` è importata da tutte le cartelle `ui/` e da `lib/app/bootstrap.dart`; non importa nessun modulo.
- App Shell e Account si importano a vicenda (`account_gate_view.dart` importa `home_shell.dart`; `profile_screen.dart` importa `app/external_links.dart`; `home_shell.dart` importa `account/app_user.dart`), e Cellar e Account pure (`cellar_screen.dart` apre `ProfileScreen`). Sono cicli tra moduli, non tra file; nessun ciclo tra file è stato cercato.
- `playStoreLink` e `ShareLauncher` stanno in Sharing: una voce "Condividi l'app" nell'App Shell o nel Profilo li importerebbe da lì.
- `lib/cellar/domain/wine_origins.dart` è il punto condiviso dei nomi di paesi e regioni (non riverificato).
- `lib/sync/ledger/key_value_store.dart` è l'archivio chiave-valore riusato da Plan, Ads, Usage e Dev Tools; il flag `onboarding.seen` invece usa `SharedPreferences` direttamente.

## Dependency Rules Enforced by CI

| Regola | Controllo |
|---|---|
| `packages/estimation` senza dipendenze di produzione, senza Flutter | `tool/check_estimation_purity.sh` |
| `lib/dashboard/` sola lettura, `domain/` in Dart puro | `tool/check_dashboard_readonly.sh` |
| `lib/label/` senza Firestore né Storage | `tool/check_label_imports.sh` |
| `lib/catalog/` senza Firestore, `core/` in Dart puro, nessun contatto Open Food Facts nel repository | `tool/check_off_config.sh` |
| Manifest di rilascio senza CAMERA, permessi foto e AD_ID | `tool/check_release_build.sh` |
| Bundle web ricostruibile identico, solo script locali | `tool/check_web_pins.sh` |

## Localization Dependencies

| Chi dipende | Da cosa |
|---|---|
| Ogni schermata | `AppLocalizations` generato |
| `VinoozyApp`, `AppBootstrap` | `appLocales`, `resolveAppLocale` |
| Android | `locales_config.xml`, allineato ad `appLocales` con `androidLocaleTagOf` |
| Test dei widget | `testLocales` e `pumpScreen` di `test/helpers/ui_harness.dart` |
| Test di allineamento | `test/app/language_consistency_test.dart`, `test/l10n/l10n_exercise_test.dart` |
| Test end-to-end | Build E2E in italiano |
| Store Listing | `languages.json`, 25 cartelle, `release-notes.txt`, `tool/check_publication.mjs` |
| Account Deletion Web | Pagine `it`, `en`, `pt-BR` |
| Copertura di CI | Numero di righe del codice di localizzazione generato |
