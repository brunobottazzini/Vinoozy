# Team-Level Rules

> This team's affirmed practices and corrections. Loaded after `org.md` as
> strict-additive guidance; contradictions with broader policy are rejected.
> Populated by the practices-discovery affirmation gate. Edit at the gate,
> not directly.

## Way of Working

- Lavoriamo in **trunk-based development** su un solo ramo stabile, `main` (Q2).
- Ogni blocco di lavoro (Bolt) parte da `main` su un ramo di breve durata e rientra in `main` con uno **squash merge**: un solo commit per blocco, con il nome del blocco.
- Non usiamo rami `develop` o `release/*` di lunga durata. Marchiamo i rilasci con tag di versione su `main` (es. `v0.1.0`).
- Il codice sta su **GitHub** e i controlli automatici girano su **GitHub Actions** nel piano gratuito (Q3).
- Siamo una persona sola, quindi nessuno sviluppatore fa una seconda revisione. A fare da revisione ci sono i gate di AI-DLC e i controlli di GitHub Actions, che devono passare prima di ogni merge in `main`.
- I commit chiesti fuori dai blocchi vanno sul ramo su cui ci troviamo.

## Walking Skeleton

- Sì: prima di tutto costruiamo uno **scheletro funzionante**, cioè la fetta più sottile che attraversa tutto il sistema, per dimostrare che i pezzi si collegano prima di aggiungere le funzioni vere (Q4; lo scope `mvp` lo prevede con `skeleton: on`).
- La fetta comprende: app Android avviata, login con account Google, inserimento di un vino scritto a mano, salvataggio sul telefono anche offline e sincronizzazione su Firebase al ritorno della rete.
- Lo scheletro si verifica con un comando di verifica scelto e autorizzato da noi in Construction, che deve dimostrare il risultato reale da capo a fondo. Poi serve la nostra approvazione esplicita prima di passare agli altri Unit.

## Testing Posture

- **Methodology**: test-after
- **Methodology evidence**: scelta in Q5 ("Dopo il codice, strato per strato"); coincide con il default di `org.md`.
- **Ordering**: Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.
- **Copertura**: almeno l'**80% delle righe**, calcolato su tutto il codice **senza esclusioni**, compresi codice generato e file di traduzione (Q6). La soglia viene verificata in GitHub Actions e se non è raggiunta il merge in `main` è bloccato.
- **Strumenti**: `flutter test` con `--coverage` per unit test e test dei widget. Unit test sulla logica (in particolare la stima del momento ideale e l'indice di fiducia), test dei widget per le schermate principali nelle tre lingue dell'interfaccia (it, en, pt-BR).
- **Integrazione con Firebase**: i test di integrazione girano sulla **Firebase Emulator Suite**, in locale e in GitHub Actions, così non usano il progetto di produzione e non costano nulla (Q9).
- **End-to-end**: i test che simulano l'uso reale dell'app girano in GitHub Actions su un **emulatore Android** (es. `integration_test` di Flutter), collegato alla Firebase Emulator Suite (Q7). Se falliscono, il merge è bloccato.
- **Gate prima del merge**: formattazione, analisi statica, test, copertura ed end-to-end devono passare tutti. Un controllo rosso non si aggira e la soglia non si abbassa per far passare un blocco.

## Guard Policy

<!-- Affirmed by the team. Mode: strict, relaxed, or off. Strict here holds for every intent, whatever one person asks in chat; relaxed or off here applies to every intent whose policy came from its scope, unless project.md or the person sets another; changing this line changes it. A section under the retired Change Control heading, written by an earlier release, is still read. -->

## Deployment

- Ogni merge in `main` fa costruire a GitHub Actions un bundle Android firmato (AAB), che viene pubblicato sul **canale di test interno** di Google Play. Questo canale è il nostro ambiente di staging (Q8).
- La promozione in **produzione** su Google Play richiede la **nostra approvazione manuale** (del proprietario), dopo aver provato sul telefono la build del test interno. Avviene con **rilascio graduale** (es. 20%, poi 100%).
- Le versioni seguono il semantic versioning nel nome. Il numero di build cresce a ogni build ed è generato da GitHub Actions.
- **Rollback**: Google Play non permette di tornare a una build già pubblicata. In produzione rientriamo fermando il rilascio graduale, poi pubblichiamo una nuova versione con la correzione, che passa dal test interno come ogni altra.
- **Smoke test dopo il rilascio**: installiamo la build dal canale di test interno e verifichiamo che avvio, login Google e sincronizzazione funzionino prima di approvare la produzione.
- **Firebase**: usiamo la Firebase Emulator Suite in locale e in GitHub Actions, più **un solo progetto di produzione** (Q9). Le regole di sicurezza e gli indici stanno nel repository e si distribuiscono in produzione solo con approvazione manuale. Il budget è 0 €/mese, con un avviso di spesa a 1 € (constraint-register C6).
- La chiave di firma Android, le credenziali di pubblicazione su Google Play e quelle di Firebase stanno solo nei segreti di GitHub Actions, mai nel repository.

## Code Style

- Codice, identificatori e commenti nel codice sono **sempre in inglese**.
- Formattazione: `dart format`, il formattatore standard di Dart.
- Analisi statica: `flutter analyze` con le regole raccomandate (`flutter_lints`) configurate in `analysis_options.yaml`. Non aggiungiamo regole oltre a queste finché il team non ne afferma altre.
- Nomi idiomatici di Dart: `lowerCamelCase` per variabili e funzioni, `UpperCamelCase` per tipi, `snake_case` per i nomi dei file.
- Formattazione e analisi girano in GitHub Actions prima del merge: un errore blocca il merge.
- I testi dell'interfaccia non stanno nel codice: vanno nei file di localizzazione (it, en, pt-BR).
## Forbidden

<!-- Team-specific forbidden patterns -->

## Mandated

<!-- Team-specific mandates -->

## Corrections

<!-- Self-learning loop appends here. -->
