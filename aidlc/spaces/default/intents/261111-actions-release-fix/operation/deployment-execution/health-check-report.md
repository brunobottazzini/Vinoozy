# Controllo di salute della consegna

| Controllo | Atteso | Esito | Evidenza |
|---|---|---|---|
| CI su `main` | 7 job verdi | ✅ 7/7 | run `43202895608` |
| Versione Flutter in CI | 3.47.9 | ✅ | job `format` (controllo di allineamento) e cache `flutter-linux-stable-3.47.9` |
| Verifica dei segreti di `play-internal` | completa | ✅ | step `Check the play-internal configuration` |
| Autenticazione Play e lettura delle tracce | versionCode > 3 | ✅ 4 | step `Versions` |
| Firma dell'AAB | chiave di caricamento registrata | ✅ dopo la sostituzione del keystore | step `Upload to the internal testing track` |
| Canale di test interno | build caricata | ✅ 0.2.1 (4) | release `43207310918` tentativo 2 |
| Tag | `build-4` sul commit della CI | ✅ `6f76475` | `git tag` |
| Segreti nei log | assenti | ✅ | solo nomi nei messaggi; file rimossi con `if: always()` |
| Segnalazioni secret scanning aperte | 0 | ✅ | alert #1 chiusa come falso positivo |
| E2E test 8 (FR7.4) | verde in CI | ✅ in 2 CI (`43192173893`, `43202895608`) | non ripetuto 10 volte: limite accettato in Build and Test |
| Smoke test sul telefono | avvio, accesso, sincronizzazione | in attesa del proprietario | `smoke-test-results.md` |

Requisiti verificati in questa fase: FR1-FR4 in CI reale, FR6.1 (versionCode,
AAB firmato, canale interno, tag), FR6.2 (push solo con il consenso del
proprietario).
