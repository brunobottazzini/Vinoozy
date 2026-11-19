# Smoke test — Lingue dei paesi del vino

## Già eseguiti

| Prova | Dove | Esito |
|---|---|---|
| Avvio, accesso Google, cantina sincronizzata da Firebase | Telefono del proprietario (CPH2581, Android 16), build di prova con la configurazione Firebase reale | Superato: Cruscotto con 6 bottiglie, 1 vino da confermare |
| Cambio di lingua (francese, greco, georgiano, ucraino) | Stesso telefono | Superato, senza riavvio |
| Elenco delle lingue nelle impostazioni di Android | Stesso telefono | 23 voci su 25: limite del menu di OxygenOS, accettato in Build and Test |
| Avvio della build di rilascio ridotta con R8 (`tool/check_release_launch.sh`) | Emulatore della CI, job `e2e` | Superato |

## Ancora da fare (proprietario)

Smoke test sulla build **0.3.0 (5) installata dal canale di test interno** (`team.md`): avvio, accesso Google, sincronizzazione.

- Va fatto prima di promuovere la build ad Alpha e, più avanti, prima della produzione.
- Prima di installarla, disinstallare la build di prova presente sul telefono, che ha una firma diversa, dopo aver controllato che sia tutto sincronizzato.
