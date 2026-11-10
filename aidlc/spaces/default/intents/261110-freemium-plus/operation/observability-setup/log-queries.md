# Query sui log — Freemium e Plus

Le query si eseguono in Cloud Console → **Esplora log** (Logging), progetto `vinoozy-d6f45`, regione delle funzioni `europe-west8`. Si possono salvare come «query salvate», senza costi. I messaggi sono quelli scritti dalle funzioni (`functions/src/handlers/`). I log non contengono mai token d'acquisto: solo un'etichetta derivata dall'hash (`purchase`), uid e contatori.

Conservazione: 30 giorni, il default gratuito di Cloud Logging.

## Verifica degli acquisti

```
resource.type="cloud_run_revision"
resource.labels.service_name="verifypurchase"
jsonPayload.message="verifyPurchase"
```

Per vedere solo gli esiti problematici:

```
resource.labels.service_name="verifypurchase"
(jsonPayload.message="verifyPurchase: unknown token" OR severity>=ERROR)
```

## Notifiche di Play (RTDN)

```
resource.labels.service_name="onplayrtdn"
jsonPayload.message="Play notification"
```

`jsonPayload.outcome` vale `ignored-test`, `ignored-unknown-token`, `ignored-package`, `duplicate` oppure il nuovo stato.

## Conferme (acknowledge) e riconciliazione

```
(jsonPayload.message="Purchase acknowledgement failed; the reconciliation retries"
 OR jsonPayload.message="Reconciliation of one purchase failed")
```

## Spesa e fatturazione

```
resource.labels.service_name="onbudgetalert"
(jsonPayload.message="Budget exceeded: billing disabled" OR jsonPayload.message="Malformed budget notification" OR jsonPayload.message="Billing event not stored")
```

## Errori di qualsiasi funzione

```
resource.type="cloud_run_revision"
severity>=ERROR
```

Il messaggio `<nome> failed` riporta il nome della callable fallita.

## Pulizie

```
(jsonPayload.message="Deleted account cleaned up" OR jsonPayload.message="Old details purged")
```

## App (Crashlytics)

Non ci sono query: i problemi si filtrano per versione nella console di Crashlytics. Non si inviano dettagli d'uso o d'inventario a Crashlytics (studio §4).
