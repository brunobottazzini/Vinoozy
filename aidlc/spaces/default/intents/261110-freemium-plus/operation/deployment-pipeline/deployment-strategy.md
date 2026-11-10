# Strategia di rilascio — Freemium e Plus

## Principio

Si pubblica prima il codice spento, poi si accendono le funzioni con gli interruttori di `config/policy`, uno alla volta (studio §7.10). Gli interruttori sono feature flag lato server e si cambiano con `tool/admin/set_policy.mjs`, senza una nuova build.

## Ordine

1. **Regole Firestore**: `firebase-deploy.yml`, con approvazione. Vanno pubblicate **prima** dell'app, perché la nuova app scrive il contatore e le regole vecchie lo rifiutano. Le regole nuove accettano ancora le scritture dell'app in produzione (`test/rules/compat/`).
2. **App** sul test interno, poi `promote.yml` in produzione con rilascio graduale: 20%, poi 100%. Smoke test prima della promozione, come da team.md: avvio, login Google, sincronizzazione, riga «Gratuito» nel Profilo, nessun annuncio.
3. **Passaggio a Blaze** con budget e protezioni, e **funzioni**, la prima volta dal Mac e poi con `functions-deploy.yml`.
4. **Plus in vendita**: configurazione di Play Console, smoke test con account tester, poi `set_policy.mjs --purchases-enabled true`.
5. **Limite di 15 schede**: quando quasi tutte le installazioni hanno la versione con Freemium, eseguire `migrate_capacity.mjs` e poi `--capacity-limit-enabled true`.
6. **Annunci**: solo dopo almeno due settimane di misurazione, con dichiarazioni Play e consenso UMP pronti. Poi `--ads-enabled true`, eventualmente a rilascio limitato.

## Ambienti

| Ambiente | App | Firebase |
|---|---|---|
| Sviluppo e CI | build demo | Emulator Suite `demo-vinoozy` |
| Staging | test interno di Play | progetto `vinoozy-d6f45` |
| Produzione | produzione di Play, rilascio graduale | progetto `vinoozy-d6f45` |

## Controlli dopo ogni passo

- **Regole:** nessun aumento di errori `permission-denied` in Crashlytics dopo la pubblicazione.
- **Funzioni:** le 9 funzioni attive in `europe-west8`; budget di prova sotto soglia, che non fa nulla.
- **Plus:** acquisto di prova, Profilo «Plus», ripristino, annullamento con Plus valido fino alla scadenza.
- **Limite:** dopo la migrazione, il contatore di una cantina di prova coincide con le schede attive.
