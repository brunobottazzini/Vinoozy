# Tracciamento — Freemium e Plus

Il tracciamento distribuito è **escluso** in questo lavoro.

- **Perché:** il percorso è breve, tutto Google: app → callable → Firestore o Play API. Nella dashboard delle funzioni la latenza è già visibile per funzione. Cloud Trace avrebbe una quota gratuita, ma aggiunge una dipendenza e dati in più senza un problema concreto da risolvere.
- **Come si collega una richiesta:** con l'etichetta `purchase` (hash del token) nei log di `verifyPurchase`, `onPlayRtdn` e della riconciliazione, che basta a seguire un acquisto dall'app alla notifica di Play. Per `reportUsage` si usano uid, periodo e `installationId`.
- **Nell'app:** Crashlytics registra i crash con la versione e senza dati personali. Nessuna tracciatura delle prestazioni: Firebase Performance non è integrato e non viene aggiunto.

Da riconsiderare se il tempo di attivazione di Plus (`slo-config.md`) va sotto il 95%.
