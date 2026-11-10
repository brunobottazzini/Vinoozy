# Observability Setup — domande

In questa fase non ho posto domande nuove. Le decisioni si ricavano da risposte e regole che ci sono già:

- **Spesa zero** (Requirements Analysis, Q8 e Q9): «solo SE NON SPENDO NIENTE», Blaze con protezioni. Si usano quindi solo strumenti gratuiti: Crashlytics, Android vitals di Play Console, la pagina Utilizzo di Firestore, i log di Cloud Functions con la quota gratuita, gli avvisi di budget e le notifiche email. I criteri di avviso a pagamento di Cloud Monitoring restano esclusi.
- **Canale degli avvisi**: l'email del proprietario, unica persona del team (team.md).
- **Soglie di partenza**: quelle dello studio, cioè §4 (99,5% di utenti senza crash), §7.2 (avviso all'80% delle quote giornaliere) e §8.7 (preparazione al 70%, intervento all'80%), oltre al budget di 1 € di team.md.
- **Conservazione dei log**: 30 giorni, il default gratuito di Cloud Logging. I dettagli della misurazione durano 90 giorni (NFR6).

Se vuoi cambiare una di queste scelte, chiedilo al momento dell'approvazione.
