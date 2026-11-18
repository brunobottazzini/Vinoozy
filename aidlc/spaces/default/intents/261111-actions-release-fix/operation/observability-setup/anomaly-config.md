# Rilevamento di anomalie

Nessun rilevamento automatico basato su modelli: il volume (un proprietario,
pochi push al giorno) è troppo basso perché abbia senso. Le anomalie da
riconoscere a mano, con il segnale che le indica:

| Anomalia | Segnale | Riferimento di oggi |
|---|---|---|
| SDK di Flutter cambiato senza volerlo | `analyze` rosso con molte deprecazioni; il nuovo controllo di allineamento nel job `format` | CI `43190709684`: Flutter 3.50.0 invece di 3.47.9 |
| Test E2E intermittente | lo stesso test rosso in run diverse senza modifiche al codice | test di cancellazione account rosso in 5 CI prima di `6f76475` |
| Credenziale sbagliata o scaduta | release rossa con "configuration is incomplete", `play_api` uscita 3/4, o "signed with the wrong key" | release `43207310918` tentativo 1 |
| versionCode inatteso | valore nello step `Versions` non uguale al precedente + 1 | atteso 4, ottenuto 4 |
| Chiave pubblica segnalata come segreto | nuova segnalazione di secret scanning su `docs/account-deletion/` | alert #1, chiuso come falso positivo |

Per l'app in produzione valgono gli avvisi di velocity di Crashlytics e le
soglie di Cloud Monitoring già definite (`docs/firebase-setup.md` §7).
