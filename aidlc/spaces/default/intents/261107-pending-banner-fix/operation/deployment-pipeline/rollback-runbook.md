# Procedura di rollback — pending-banner-fix

## Fonti

- `team.md` → Deployment (rollback su Google Play); `deployment-strategy.md` e `cd-config.md` di questa fase.

## Principio

Google Play non permette di tornare a una build già pubblicata. Si **ferma il rilascio graduale** e si pubblica una **nuova versione** corretta, che passa dal test interno come ogni altra. La correzione non cambia dati, regole o indici di Firestore, quindi sul server non c'è nulla da annullare.

## Passi

1. **Fermare il rilascio.** Nella Play Console, sezione produzione, sospendi il rilascio graduale. Chi ha già l'aggiornamento lo tiene, gli altri no.
2. **Valutare.** Controlla Crashlytics (errori `cellar_*`) e prova sul telefono lo scenario segnalato.
3. **Correggere in avanti.** Hai due strade, poi la versione corretta passa da CI, test interno, smoke test e promozione:
   - un `git revert` del commit della correzione su un ramo breve;
   - una correzione nuova, per esempio il `reset()` della sonda per R-01.
4. **Dati.** Nessuna azione: le bevute restano nella coda di Firestore sul telefono e si sincronizzano normalmente. La correzione cambia solo la fascia visibile.

## Contatti ed escalation

Una sola persona: il proprietario (Bruno Bottazzini), che decide la sospensione e la nuova versione.
