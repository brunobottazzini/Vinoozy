# Frontend Components — u8-account

Fonti: `functional-spec.md` di U8, mockup S0 e profilo, riepilogo confermato in `functional-design-questions.md`.

## Gerarchia

```text
App
├── OnboardingScreen           tre pagine, Salta, Inizia (solo al primo avvio)
├── SignInScreen (U1)
├── AccountDeletionResumeGate  riprende una cancellazione interrotta prima di HomeShell
└── HomeShell (U1)
    └── menu → ProfileScreen   nome, email, Esci, Cancella account, informativa
        ├── SignOutConfirmDialog
        ├── SignOutWarningDialog   N modifiche in coda
        └── DeleteAccountScreen    elenco, parola di conferma, riautenticazione
            └── DeletionProgressView  passi, Riprova
```

Testo equivalente: la presentazione precede l'accesso al primo avvio; dopo l'accesso, una cancellazione interrotta riprende prima della shell; dal menu si apre il profilo con uscita e cancellazione.

## Componenti

| Componente | Contenuto | Regole |
|---|---|---|
| `OnboardingScreen` | `PageView` con tre pagine, indicatore, "Salta", "Inizia" | BR1.1 |
| `ProfileScreen` | Foto, nome, email, "Esci", "Cancella account", "Informativa sulla privacy" | BR1.2 |
| `SignOutConfirmDialog` | "Vuoi uscire?", "Annulla", "Esci" | BR1.3 |
| `SignOutWarningDialog` | Testo con N, "Resta e sincronizza", "Esci comunque" | BR1.4 |
| `DeleteAccountScreen` | Elenco di cosa si cancella, avviso sulle N modifiche in coda che andranno perse, campo della parola di conferma, "Cancella per sempre" attivo solo con la parola giusta, messaggio senza rete | BR1.5, BR1.6 |
| `DeletionProgressView` | Passi con stato, "Riprova" in caso di errore, nessuna altra navigazione | BR1.7, BR1.8 |
| `AccountDeletionResumeGate` | Dentro `AccountGate`, prima di `ensureProfile` e `ensurePersonalCellar`: con il segnale locale o `deletionStartedAt` mostra `DeletionProgressView` e non ricrea profilo e cantina | BR1.8, BR1.13 |

## Stati

| Schermata | Caricamento | Vuoto | Errore | Parziale |
|---|---|---|---|---|
| Profilo | Nome ed email dalla cache dell'accesso | — | — | Senza foto: iniziale del nome |
| Cancellazione | Avanzamento dei passi | — | Senza rete; riautenticazione annullata; regole che rifiutano | Interrotta: ripresa |

## Accessibilità

- Etichette per TalkBack su tutti i pulsanti; l'indicatore di pagina della presentazione annuncia "Pagina N di 3".
- L'avanzamento della cancellazione è annunciato a ogni passo.
- Testo al 200% senza tagli, contrasto ≥ 4,5:1, aree di tocco ≥ 48 dp, tre lingue.
- Chiavi di prova: `onboarding-skip`, `onboarding-start`, `profile-sign-out`, `profile-delete`, `sign-out-anyway`, `sign-out-stay`, `delete-confirm-word`, `delete-forever`, `deletion-retry`.
