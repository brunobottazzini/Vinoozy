# Frontend Components — u7-sharing

Fonti: `functional-spec.md` e `rules.md` di U7 (BR1.1–BR1.12), `requirements.md` (FR8.1–FR8.4), `stories.md` (US8.1–US8.4), riepilogo confermato in `functional-design-questions.md`. Tutti i testi stanno nei file di traduzione (it, en, pt-BR). Ogni elemento interattivo ha una chiave di test (`Key`).

## Gerarchia

```text
HomeShell (U1, modificata da U5)
├── CellarSwitcher                 (barra in alto di Cruscotto e Cantina, BR1.5)
├── DashboardScreen / CellarScreen (cantina attiva; comandi secondo il permesso, BR1.6)
└── SharedCellarNotice             (avviso "Mario ti ha condiviso la sua cantina", BR1.4)

SharingScreen ("Persone", dal menu della cantina)
├── vista del proprietario
│   ├── InviteForm                 (BR1.2, BR1.3, BR1.11)
│   └── MemberTile × n             (BR1.8, BR1.9, BR1.12)
│       ├── PermissionMenu
│       └── RevokeDialog
└── vista della persona invitata
    ├── proprietario e proprio permesso
    └── LeaveCellarDialog          (BR1.10)
```

## Componenti

| Componente | Responsabilità | Dati | Interazioni | Chiave di test |
|---|---|---|---|---|
| `CellarSwitcher` | Mostra la cantina attiva e, se ce n'è più di una, permette di cambiarla (BR1.5) | `listAccessibleCellars`: nome, proprietario, permesso | Tocco → elenco; scelta → cambia `activeCellarProvider` | `cellar-switcher`, `cellar-option-<cellarId>` |
| `SharedCellarNotice` | Avviso una volta per cantina nuova (BR1.4) e messaggio di accesso perso (BR1.8) | nome del proprietario | "OK" chiude | `shared-cellar-notice` |
| `SharingScreen` | Schermata "Persone": vista diversa per proprietario e persona invitata (BR1.1, BR1.12) | membri della cantina attiva, permesso dell'utente, stato della rete | — | `sharing-screen` |
| `InviteForm` | Campo email, scelta del permesso (due opzioni con spiegazione), pulsante "Invita". Mostra gli errori di BR1.2 e il limite. Disattivato senza rete (BR1.11) | numero di posti usati (x/2) | "Invita" → `invite` → condivisione di Android (BR1.3) | `invite-email`, `invite-permission-read`, `invite-permission-edit`, `invite-submit` |
| `MemberTile` | Nome o email, permesso, stato. Elenco principale: invitata o attiva. Sezione chiusa "Accessi chiusi": revocata o uscita (BR1.12) | un membro | Elenco principale: cambia permesso, revoca. Accessi chiusi: reinvita, elimina definitivamente | `member-<memberKey>` |
| `PermissionMenu` | Passa tra "solo lettura" e "può modificare" (BR1.9) | permesso attuale | scelta → `changePermission` | `member-permission-<memberKey>` |
| `RevokeDialog` | Conferma scrivendo il nome (o l'email) della persona (BR1.8) | nome atteso | "Revoca" si attiva solo con il testo corretto | `revoke-confirm-field`, `revoke-confirm` |
| `LeaveCellarDialog` | Conferma dell'uscita (BR1.10) | nome del proprietario | "Esci" → `leave` → torna alla cantina personale | `leave-cellar`, `leave-confirm` |

## Stati

- **Caricamento:** scheletro dell'elenco.
- **Senza rete:** elenco visibile dalla cache; comandi di gestione disattivati con la spiegazione (BR1.11).
- **Operazione in corso:** pulsante con indicatore, doppio tocco ignorato.
- **Errore del server:** messaggio "Invito non riuscito. Riprova" o equivalente, senza cambiare l'elenco.
- **Accesso perso:** la cantina sparisce dal selettore, si torna alla personale e compare il messaggio (BR1.8).

## Permessi nelle schermate esistenti (BR1.6)

- `CellarScreen` e le schermate di U4 nascondono i comandi di aggiunta, modifica, eliminazione e bevuta con `read`. Con `edit` nascondono solo l'eliminazione.
- Il Cruscotto (U5) con `read` nasconde "Aggiungi il primo vino" nello stato vuoto.
- Il menu della cantina mostra "Persone" a tutti, e "Rinomina" solo al proprietario.

## Accessibilità

- Il selettore e ogni menu hanno etichette per TalkBack ("Cantina di Mario, può modificare").
- Il permesso si legge sempre come testo, mai solo come icona o colore.
- Aree di tocco di almeno 48×48 dp.
