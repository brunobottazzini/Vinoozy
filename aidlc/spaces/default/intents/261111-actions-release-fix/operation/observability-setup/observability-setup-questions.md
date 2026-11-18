# Domande sull'osservabilità

Superficie osservata in questo lavoro: la catena di consegna (CI su `main`,
`release.yml`, `promote.yml`). L'osservabilità dell'app in produzione
(Crashlytics, budget Firebase, avvisi) è già definita in
`docs/firebase-setup.md` §7 e resta invariata. Nessun servizio AWS è in uso.

## Q1. [Proprietario] Come vuoi essere avvisato quando la CI o la release su `main` falliscono?

Oggi GitHub manda un'email all'autore del push quando un workflow fallisce
(impostazioni di notifica dell'account). Una release che non parte resta
altrimenti visibile solo nella pagina Actions.

A. Bastano le email di GitHub: nessuna modifica, controllo le impostazioni di notifica
B. In più, un'issue GitHub aperta automaticamente quando `release.yml` fallisce, con il link al run e lo step fallito (chiusa a mano)
C. Nessun avviso: guardo io la pagina Actions dopo ogni push
X. Other (please specify)

[Answer]: A
