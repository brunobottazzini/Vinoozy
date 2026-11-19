# API Documentation

Il progetto non espone un'API REST propria. Le sue superfici sono: funzioni callable e a evento, il modello dei dati Firestore protetto dalle regole, due contratti interni in Dart, alcuni canali di piattaforma e un servizio esterno.

## External API Surfaces

### Cloud Functions (`functions/src/index.ts`)

Regione `europe-west8`, al massimo 2 istanze. Le callable prendono l'uid da Firebase Auth e richiedono App Check (`enforceAppCheck: true`). Nessuna è distribuita dalla CI.

| Nome | Tipo | Scopo |
|---|---|---|
| `verifyPurchase` | callable | Lega un acquisto Play a chi chiama e concede Plus se pagato |
| `reportUsage` | callable | Applica la differenza dei contatori cumulativi di un'installazione |
| `reserveAdSlot` | callable | Riserva l'unico tentativo di annuncio del giorno (UTC) |
| `recordAdOutcome` | callable | Registra richiesta, caricamento, impressione, errore e ricavo di un tentativo |
| `onPlayRtdn` | Pub/Sub, con ripetizione | Notifiche in tempo reale di Google Play |
| `onBudgetAlert` | Pub/Sub | Scollega la fatturazione quando il budget è superato |
| `reconcileEntitlements` | pianificata, ogni giorno 03:00 UTC | Riallinea gli acquisti che possono ancora cambiare |
| `purgeOldUsage` | pianificata, ogni giorno 04:00 UTC | Elimina i dettagli di misura oltre 90 giorni |
| `onUserDeleted` | trigger Auth | Rimuove diritti, uso e slot annunci dell'account cancellato |

I contratti delle callable lato app sono verificati in `test/plan/billing/callable_contracts_test.dart`. Nessuna funzione riceve o restituisce testi tradotti.

### Firestore Data Model (`firestore.rules`, contratto C3)

| Percorso | Contenuto |
|---|---|
| `users/{userId}` | Profilo dell'account, compreso il campo `onboardingSeen` (parte `false`; la presentazione è decisa dal flag locale, vedi sotto) |
| `cellars/{cellarId}` | Cantina |
| `cellars/{cellarId}/wines/{wineId}` | Vino: nome, produttore, annata, tipo, regione, denominazione, quantità, finestra, abbinamenti |
| `cellars/{cellarId}/drinkingRecords/{recordId}` | Bevuta |
| `cellars/{cellarId}/members/{memberKey}` | Invito o appartenenza; la chiave è l'email in minuscolo |
| `{path=**}/members/{memberKey}` | Collection group degli inviti ricevuti |
| `entitlements/{userId}`, `purchases/{tokenHash}` | Diritti Plus e acquisti |
| `config/{configId}` | Politica del piano |
| `usage/{userId}/…`, `adSlots/{userId}/…` | Misura d'uso e slot annunci |

Nessun campo salva la lingua dell'utente. I valori legati alla lingua non vengono salvati tradotti: paese come codice ISO, regione come nome canonico, tipo, stile e livello come chiavi. Fa eccezione il nome della cantina predefinita, scritto nella lingua del telefono al primo accesso.

### Open Food Facts (`lib/catalog/core/off/open_food_facts_source.dart`)

Richieste HTTP di ricerca e di prodotto per codice a barre, raggiunte solo attraverso cache, interruttore di circuito e budget di richieste. Il parametro `lc` porta il codice di lingua di `CatalogLocale`. I risultati vanno mostrati con l'attribuzione ODbL.

### Google Play

- **Developer API** (`tool/play_api.sh`): comandi `next-version-code`, `promote`, `complete`, `halt`, usati da `release.yml` e `promote.yml`. Nessun comando gestisce le schede dello store: i testi in `distribution/google-play/` si caricano a mano.
- **Pagina dell'app**: `https://play.google.com/store/apps/details?id=com.vinoozy.app` (`playStoreLink`).
- **In-App Review API**: non usata.

### Public Web Pages

`docs/privacy/` e `docs/account-deletion/`, ciascuna in italiano (radice), `en/` e `pt-BR/`, pubblicate da `pages.yml`. `docs/account-deletion/account-deletion.js` esegue dal browser gli stessi passi cloud della cancellazione dell'app.

## Internal API Surfaces

### Contract C1: `WineCatalog` (`lib/catalog/core/wine_catalog.dart`)

Operazioni di suggerimento, ricerca per codice a barre, confronto con il testo di un'etichetta (`matchLabel`) e ricerca online (`searchOnline`). Tipi principali: `WineCandidate`, `CandidateSource` (ordine: cantina, database offline, interno, Open Food Facts), `CatalogWineType`, `CatalogLocale`. L'unica eccezione è `CatalogArgumentError`.

### Contract C2: `estimation` (`packages/estimation/lib/estimation.dart`)

Unico file di esportazione del pacchetto. Gruppi di funzioni:

| Gruppo | Simboli principali |
|---|---|
| Stima | `estimateWindow`, `statusOf`, `pairingsFor`, `effectiveWindow`, `windowOfResolution` |
| Stile e classificazione | `resolveStyle`, `classifyWine`, `suggestedLevel`, `StyleProfile`, `WineStyle`, `WineLevel` |
| Denominazioni e vitigni | `appellations`, `findAppellation`, `appellationOf`, `grapeNameOf`, `denominationCatalog`, `recognizeDenomination`, `appellationsSource` |
| Testo d'etichetta | `extractLabelFields`, `analyzeLabelText`, `LabelLinePicker`, `VintageParser`, `normalizeWineText` |
| Paesi sulle etichette | `countryCodeOfName`, `wineCountryNames` |
| Tipi | `DrinkingWindow`, `WineFacts`, `WineType`, `WineStatus`, `Confidence`, `Pairings`, `PairingCategory`, `Qualifier` |
| Errori | `EstimationArgumentError`, `EstimationErrorCode` |

Il pacchetto restituisce chiavi e nomi propri, mai frasi tradotte: la traduzione avviene nell'app.

### App Services for Onboarding, Profile and Links

Dalla scansione del 2026-11-19.

| Simbolo | File | Contratto |
|---|---|---|
| `OnboardingFlag(PreferencesOpener)`, `read()`, `markSeen()`, `key = 'onboarding.seen'` | `lib/account/onboarding_flag.dart` | `read()` restituisce `true` se l'archivio non si legge; `markSeen()` restituisce `false` se la scrittura è rifiutata |
| `onboardingFlagProvider` | `lib/account/account_providers.dart` | `null` per predefinito, sovrascritto in `bootstrap.dart` |
| `onboardingSeenProvider` (`OnboardingSeen.markSeen()`) | `lib/account/account_providers.dart` | `true` immediato senza flag; imposta lo stato prima di scrivere |
| `privacyPolicyUrlFor(languageTag)`, `privacyPolicyUrlProvider` | `lib/account/account_providers.dart` | it, pt-BR, altrimenti en; `--dart-define=PRIVACY_POLICY_URL` vince |
| `openExternalLink(url)`, `externalLinkOpenerProvider` | `lib/app/external_links.dart` | `Future<bool>`; `false` se lo schema non è `https`, se manca l'host o se la piattaforma fallisce |
| `ShareLauncher.share({text, subject})`, `shareLauncherProvider`, `SharePlusLauncher` | `lib/sharing/ui/share_launcher.dart` | Apre il foglio di condivisione Android; sostituibile nei test |
| `playStoreLink` | `lib/sharing/ui/share_launcher.dart` | `https://play.google.com/store/apps/details?id=com.vinoozy.app` |
| `ProfileScreen.open(context, user)`, `AboutScreen.open(context)` | `lib/account/ui/profile_screen.dart`, `lib/app/ui/about_screen.dart` | Navigazione imperativa |
| `appVersionLabelProvider` | `lib/app/ui/brand_footer.dart` | Versione e numero di build, `null` se non disponibile |

### Localization API (`lib/l10n/app_localizations.dart`, `lib/app/locale_resolution.dart`)

| Simbolo | Uso |
|---|---|
| `AppLocalizations.of(context)` | Testi nei widget; mai nullo (`nullable-getter: false`) |
| `AppLocalizations.localizationsDelegates` | Delegate dell'app più Material, Cupertino e Widgets |
| `lookupAppLocalizations(locale)` | Testi fuori dai widget e nei test; lancia `FlutterError` per una lingua non generata |
| `appLocales`, `fallbackLocale`, `resolveAppLocale(preferred)` | 25 lingue offerte e scelta dalla lista del telefono |
| `androidLocaleTagOf(locale)`, `intlLocaleNameOf(locale)` | Tag per `locales_config.xml` e nome per `intl` |
| `appLocaleOverride`, `e2eLocale` | Lingua forzata delle build E2E |
| `OriginCountry.nameIn`, `WineRegion.nameIn`, `regionDisplayName` | Nomi di paesi e regioni nella lingua data (non riverificato) |

### Platform Channels (Flutter ↔ Kotlin)

| Canale | File Dart | Scopo |
|---|---|---|
| `com.vinoozy.app/links`, metodo `open` | `lib/app/external_links.dart`, `MainActivity.kt` | Apre un URL `https` con `ACTION_VIEW` e `CATEGORY_BROWSABLE` |
| Canale delle immagini condivise | `lib/label/platform/shared_image_channel.dart` | Preparazione delle immagini e ricezione di immagini e testi condivisi |
| Canale di Lens | `lib/label/platform/lens_channel.dart` | Apre Google Lens con l'immagine |

### Android Intents (`android/app/src/main/AndroidManifest.xml`)

`MainActivity` riceve `MAIN`/`LAUNCHER`, `SEND`/`SEND_MULTIPLE` di `image/*` e `SEND` di `text/plain`. Le `queries` dichiarano solo `PROCESS_TEXT`, le app Google e Lens e `SEND` di `image/*`.
