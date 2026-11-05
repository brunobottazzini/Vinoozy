# Practices Discovery — Domande

Progetto nuovo: le proposte vengono dai valori predefiniti (`aidlc/spaces/default/memory/org.md`) e dalla bozza in `team-practices.md`.

## Q1. [Sviluppo] Con quale tecnologia costruire l'app (un solo codice per Android e, poi, iPhone)

Da questa scelta dipendono formattazione, controlli del codice e strumenti di test.

A. Flutter (consigliato: ottimo supporto offline con Firebase)
B. React Native (con Expo)
C. Kotlin Multiplatform
D. Nessuna preferenza: scegli tu
X. Other (please specify)

[Answer]: A

## Q2. [Sviluppo] Come organizzare i rami del codice

A. Un ramo principale `main`; ogni blocco di lavoro su un ramo breve unito in un solo commit (consigliato da sviluppatore singolo)
B. Rami di funzionalità con pull request e commit conservati
C. Commit diretti su `main`, senza rami
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q3. [Sviluppo] Dove tenere il codice e far girare i controlli automatici

A. GitHub con GitHub Actions (piano gratuito)
B. GitLab con la sua CI
C. Nessun controllo automatico per ora
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q4. [Sviluppo] Costruire prima una fetta sottile completa? Un walking skeleton è una versione minima che funziona da capo a fondo, costruita per prima per dimostrare che i pezzi si collegano prima di aggiungere le funzioni vere

Fetta proposta: login Google, un vino scritto a mano, salvataggio sul telefono anche offline, sincronizzazione su Firebase.

A. Sì, con la fetta proposta
B. Sì, ma con una fetta diversa
C. No
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q5. [Qualità] Quando scrivere i test

A. Dopo il codice, strato per strato
B. Prima il test, poi il codice (TDD)
C. Prima gli scenari di comportamento in linguaggio naturale (BDD)
D. Un misto
X. Other (please specify)

[Answer]: A

## Q6. [Qualità] Soglia di copertura dei test

Il piano mvp richiede almeno l'80% delle righe coperte, verificato prima di ogni unione.

A. 80% delle righe, escluso il codice generato e i file di traduzione
B. 80% delle righe, senza esclusioni
C. 90% delle righe
D. Not yet defined
X. Other (please specify)

[Answer]: B

## Q7. [Qualità] Test che simulano l'uso reale dell'app (da capo a fondo)

A. Nei controlli automatici, su emulatore Android
B. Solo in locale, quando serve
C. Per ora nessuno
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q8. [Rilascio] Come rilasciare su Google Play

A. Ogni unione su `main` va al canale di test interno; la produzione richiede la mia approvazione, con rilascio graduale
B. Solo le versioni marcate vanno al test interno; produzione con approvazione
C. Tutto manuale
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q9. [Rilascio] Ambienti Firebase

A. Emulatore Firebase in locale e nei controlli automatici, più un solo progetto di produzione
B. Un progetto di sviluppo separato più quello di produzione
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q10. [Sviluppo] Altre regole rigide oltre al codice sempre in inglese

A. None
B. Not yet defined
X. Other (please specify)

[Answer]: A

## Consolidated Summary Confirmation

- Tecnologia (Q1): Flutter.
- Rami (Q2): ramo principale `main`, ogni blocco su un ramo breve unito con un solo commit.
- Codice e controlli (Q3): GitHub con GitHub Actions (piano gratuito).
- Prima fetta (Q4): sì: login Google, un vino scritto a mano, salvataggio offline, sincronizzazione Firebase.
- Test (Q5): scritti dopo il codice, strato per strato.
- Copertura (Q6): almeno 80% delle righe, senza esclusioni.
- Test da capo a fondo (Q7): nei controlli automatici, su emulatore Android.
- Rilascio (Q8): ogni unione su `main` va al canale di test interno di Google Play; la produzione richiede la tua approvazione, con rilascio graduale.
- Firebase (Q9): emulatore in locale e nei controlli automatici, più un solo progetto di produzione.
- Regole rigide (Q10): solo il codice sempre in inglese.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
