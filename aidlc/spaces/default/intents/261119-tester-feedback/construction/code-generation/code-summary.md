# Code Generation — Riepilogo

Intent: `261119-tester-feedback` (express, profondità Minimal, strategia di test Minimal).
Fonte: report dei tester e `inception/requirements-analysis/requirements.md`, eseguito secondo `code-generation-plan.md` (17 step, tutti spuntati). Nessun commit.

## Cosa è stato costruito

| Requisito | Dove |
|---|---|
| FR1 Impostazioni | `lib/settings/ui/settings_screen.dart`, voce `cellar-menu-settings` in `lib/cellar/ui/cellar_screen.dart` |
| FR2 Guida | `lib/guide/guide_state_store.dart`, `guide_providers.dart`, `guide_policy.dart`, `ui/guide_tour.dart`, `ui/first_visit_hint.dart`; agganci in Cantina, Cruscotto, Bevuti, Aggiungi vino, `home_shell.dart` |
| FR3 ASO | `distribution/google-play/*/full-description.txt` e `short-description.txt` (25 schede), titoli it-IT ed en-US |
| FR4 Condividi | `lib/app/store_links.dart`, `lib/sharing/ui/share_launcher.dart`, voce nelle Impostazioni |
| FR5 Valuta | `lib/settings/app_review.dart`, `lib/guide/review_prompt_policy.dart`, `lib/guide/review_prompter.dart`, `lib/cellar/ui/drink_flow.dart`; dipendenza `in_app_review: ^2.0.12` |
| FR6 Feedback | `lib/settings/feedback_email.dart`, `lib/settings/ui/feedback_flow.dart`, `lib/app/device_info.dart`, `lib/app/external_links.dart`, `android/.../LinksChannelHandler.kt`, `MainActivity.kt` |
| FR7 FAQ | `lib/settings/ui/faq_screen.dart` |
| NFR1 Lingue | 46 chiavi nuove in ciascuno dei 25 ARB; `flutter gen-l10n` senza testi mancanti |
| Versione | `pubspec.yaml` → `0.4.0+3`; `distribution/google-play/release-notes.txt` con le note 0.4.0 |

## Verifiche eseguite

- Test di questo lavoro (14 file di `unit-test-instructions.md`): 217 superati, 0 falliti.
- Non regressione `test/cellar test/account test/sharing`: 2329 superati, 0 falliti.
- Suite completa con copertura: 5177 superati, 3 saltati, 0 falliti; copertura **97,35%** delle righe (soglia 80%, invariata).
- Test Kotlin `LinksChannelHandlerTest`: 5 superati.
- `flutter analyze`: nessun problema. `dart format`: stabile.
- `node tool/check_publication.mjs`: "Publication files OK" (limiti di lunghezza rispettati, note di rilascio 179–228 caratteri su 500).

## Verifiche non completate

- **Build di rilascio** (`tool/check_release_build.sh`): fermata in `:app:compileReleaseJavaWithJavac` perché il `GeneratedPluginRegistrant.java` locale (ignorato da git) conteneva `integration_test`, lasciato dall'esecuzione Gradle diretta dei test Kotlin. Problema dell'ambiente locale, non del codice. Va rieseguita in Build and Test dopo `flutter clean`. Il manifest unito non mostra permessi nuovi.
- **E2E su emulatore**: non eseguiti in questo stadio; spettano a Build and Test.
- **Prove sul telefono** (giro guidato, finestra di recensione da Play, email): richiedono la build del canale di test interno.

## Deviazioni dal piano

1. Il giro guidato usa una route trasparente invece di un `OverlayEntry`: il tasto Indietro lo chiude senza codice in più (NFR5).
2. Le chiavi dei pulsanti del giro sono `tour-next`, `tour-skip`, `tour-done`, perché `guide-skip` esiste già nella conferma guidata dell'etichetta.
3. Il passo "foto dell'etichetta" indica lo stesso pulsante "Aggiungi" con un testo proprio; il giro ha 4 passi.
4. Firme: `buildFeedbackBody` riceve l'intestazione già tradotta; `shouldShowHint` riceve un `GuideProgress`.
5. Titoli dello store riscritti solo per it-IT ("Vinoozy: gestione cantina") ed en-US ("Vinoozy: Wine Cellar Manager"); le altre 23 schede contengono già "cantina di vino" nella loro lingua.
6. `release-notes.txt` conteneva modifiche non salvate del proprietario (note 0.3.0), sostituite dalle note 0.4.0 come previsto dal piano.

## Rischi aperti

- **"Valuta l'app" dal pulsante usa In-App Review.** Google lo sconsiglia: per la quota, a volte il tocco non mostra nulla e non dà errore. Il ripiego sulla pagina del Play Store scatta solo se la chiamata fallisce.
- **Indirizzo di supporto in due posti** (`lib/app/store_links.dart` e `SUPPORT_EMAIL` in `LinksChannelHandler.kt`), senza un test che li confronti.
- **Testi in 23 lingue e parole chiave ASO** scritti senza rilettura madrelingua.

## Loop-back 1 da Build and Test (2026-11-19, Step 18–20)

Origine: sul telefono del proprietario il riquadro del giro sul passo "Aggiungi" era spostato in alto a sinistra; il proprietario ha chiesto di correggere anche R-02 e R-04 (decisione 453206ce).

- **Step 18** (`lib/guide/ui/guide_tour.dart`): un `Ticker` rilegge a ogni fotogramma la posizione del comando e ridisegna il buco solo quando cambia. **Deviazione:** il ticker si ferma dopo 1 secondo di comando fermo e riparte al cambio di passo o di dimensione dello schermo, invece di restare attivo fino al `dispose`: un ticker sempre attivo consuma batteria e blocca `pumpAndSettle` nei test esistenti. Limite: un comando che si sposta dopo più di 1 secondo fermo, senza cambio di passo, non viene seguito. 3 test nuovi in `test/guide/guide_tour_test.dart` (comando in movimento, che sparisce, che compare dopo); falliscono tutti senza la correzione.
- **Step 19** (`lib/guide/review_prompter.dart`, R-02): la recensione parte solo se `markPrompted` restituisce `true`. 3 test nuovi in `test/cellar/drink_review_prompt_test.dart` (scrittura rifiutata, eccezione segnalata come `GuideStateNotSaved`, scrittura riuscita).
- **Step 20** (R-04): nuovo `test/app/support_email_consistency_test.dart` confronta `SUPPORT_EMAIL` di `LinksChannelHandler.kt` con `supportEmail`; 4 test.
- Verifiche: 182 test delle aree toccate superati, `dart format` stabile, `flutter analyze --fatal-infos` senza problemi. R-02 e R-04 non sono più rischi aperti.

## Loop-back 2 dalla CI (2026-11-19, Step 21)

Origine: dopo il push di `7830428` il job `analyze` di GitHub Actions è fallito in `tool/check_off_config.sh`, perché `lib/app/store_links.dart` conteneva l'indirizzo di supporto (decisione e000ed61).

- **Step 21**: l'indirizzo resta solo in `LinksChannelHandler.kt` (`SUPPORT_EMAIL`), che lo restituisce con il metodo di canale `supportEmail`; Dart lo legge con `readSupportEmail` / `supportEmailReaderProvider` (`lib/app/external_links.dart`) solo nel dialogo "nessuna app email" di `feedback_flow.dart`. Se la lettura fallisce (caso quasi impossibile, errore segnalato come `SupportEmailReadFailed`) il dialogo mostra solo titolo e "Chiudi", senza testi nuovi negli ARB. Eliminato `test/app/support_email_consistency_test.dart` (una sola copia); aggiornati `external_links_test.dart`, `settings_screen_test.dart`, `faq_screen_test.dart`, `LinksChannelHandlerTest.kt` (6 test).
- Verifiche: `check_off_config.sh` OK, tutti i controlli del job `analyze` di `ci.yml` OK, `dart format` stabile, `flutter analyze --fatal-infos` senza problemi, 568 test delle aree toccate superati. Revisione `reviews/review-03.md`: READY, tre osservazioni minori.

## Decisioni di dettaglio

- R-02: al primo avvio dopo l'aggiornamento, se la cantina ha già vini, giro e suggerimenti contano come visti; "Rivedi la guida" li riattiva.
- R-03: il giro parte solo con la scheda Cantina visibile (`CellarScreen.isActiveTab`); i suggerimenti solo a giro concluso.
- R-05/R-06: soglie 4 stelle, 5 vini, 7 giorni, 120 giorni, motivate in `review_prompt_policy.dart`; nessuna lettura in più da Firestore; data salvata prima della richiesta; spento in debug ed E2E.
- R-01: destinatario fisso lato Android; `false` dal canale apre il dialogo con indirizzo e "Copia".
- R-07: la FAQ usa `PlanPolicy.defaultFreeActiveWineLimit` (15) e parla di "vini diversi".
