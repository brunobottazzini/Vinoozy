# Panoramica di business

## Scopo

Vinoozy è un'app Android (Flutter) per gestire la propria cantina di vini: si
inseriscono le bottiglie (a mano, dalla foto dell'etichetta, da testo condiviso
da Google Lens), l'app stima la finestra ideale di consumo e mostra quando
bere cosa. I dati vivono prima sul telefono e si sincronizzano su Firebase
(Firestore) quando c'è rete. Interfaccia in italiano, inglese e portoghese
brasiliano; package Google Play `com.vinoozy.app`.

## Dominio e concetti chiave

| Concetto | Significato nel codice |
|---|---|
| Cantina personale | `cellars/{uid}`: una per account, creata all'accesso (`CellarRepository.ensurePersonalCellar`). |
| Cantina condivisa | Cantina di un altro proprietario visibile tramite un invito `active` (`AccessibleCellar.shared`), con ruolo `read` o `edit`. |
| Scheda vino | `cellars/{id}/wines/{wineId}`: nome, produttore, annata, tipo, regione, denominazione, paese, livello, stile, finestra, abbinamenti, `quantity`. |
| Scheda attiva / archiviata | Attiva se `quantity > 0` (listener quotidiano); archiviata ("Bevuti") se `quantity <= 0`. Il valore memorizzato può essere negativo per decrementi concorrenti e si mostra come 0. |
| Bevuta (drinking record) | `cellars/{id}/drinkingRecords/{id}`: data, voto 1-5, note, "Com'era?" (`tooYoung`/`justRight`/`pastPeak`), che corregge la finestra. |
| Invito | `cellars/{id}/members/{email}`: stati `invited` → `active` → `revoked`; al massimo 2 posti aperti per cantina (`memberSlots`). |
| Stima | Pacchetto puro `estimation`: finestra, stato (`WineStatus`), abbinamenti, livello e stile; correggibile dal proprietario (`windowOverride`). |

## Funzionalità principali

- Accesso solo con Google; presentazione al primo avvio; profilo con uscita,
  eliminazione account e informativa privacy.
- Cantina: elenco con ricerca e filtri, aggiunta (tre vie: modulo, foto
  etichetta, testo condiviso), modifica, +/− bottiglie, "Bevuto" con annulla,
  archivio, duplicati e unione, eliminazione (solo proprietario).
- Dashboard di sola lettura: totale, "da bere presto", da confermare, grafici
  per stato, anno di picco e tipo/regione; in fondo il footer del marchio che
  apre "Informazioni".
- Storico delle bevute a pagine.
- Condivisione con fino a 2 persone, permessi lettura/modifica, uscita e revoca.
- Informazioni: versione dell'app (riga `about-version`), base dati offline dei
  vini, licenze, tabella delle denominazioni, privacy della foto.
- Eliminazione dell'account in-app e pagina web di cancellazione (GitHub Pages).

## Stato rispetto all'intent freemium/Plus

Lo studio `docs/vinoozy-studio-monetizzazione.md` (sezioni 4, 5, 7, 9) chiede:
repository dei diritti e risoluzione delle capacità, limite gratuito di 15
schede attive con migrazione `legacyActiveWineLimit`, `CloudUsageMeter`,
soglia pubblicitaria, Play Billing con verifica server, menu sviluppatore
nascosto (7 tocchi su `about-version`), gating tramite `firebase_env.dart` e
controllo dei marker in `tool/check_release_build.sh`. **Nel codice attuale
non esiste nessuno di questi elementi**: niente piani, diritti, contatori
d'uso, Billing, annunci o backend. Oggi tutte le funzioni sono gratuite e
senza limiti, salvo il tetto di 99 bottiglie per scheda e di 2 invitati per
cantina. Le superfici su cui l'intent si innesta sono indicate in
`component-inventory.md` e `architecture.md`.

## Vincoli di business rilevanti

- Budget Firebase 0 €/mese con avviso a 1 € (team.md); progetto su Spark:
  un backend Cloud Functions richiederebbe Blaze.
- Le chiavi di produzione stanno solo nei segreti di GitHub Actions; le build
  senza `FIREBASE_ENV=prod` usano sempre l'emulatore `demo-vinoozy`.
- Ogni regola Firestore nuova deve continuare ad accettare le scritture della
  versione già in produzione (`test/rules/compat/`).
