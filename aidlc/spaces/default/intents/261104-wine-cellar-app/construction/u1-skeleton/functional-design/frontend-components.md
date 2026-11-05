# Frontend Components — u1-skeleton

Fonti: `functional-spec.md`, `rules.md`, `mockups.md` e `interaction-spec.md` (Refined Mockups), `stories.md`, `requirements.md`, `components.md`.

Solo i componenti necessari allo skeleton; gli altri arrivano con le unità successive.

## Gerarchia

```
App (tema e lingua dal sistema)
+-- AuthGate (sessione presente? -> CellarScreen : SignInScreen)
    +-- SignInScreen (M1)
    +-- CellarScreen (M3 semplificata)
        +-- AppBar "Cantina"
        +-- LoadingState / CellarErrorState ("Impossibile preparare la cantina" + Riprova)
        +-- OfflineBanner
        +-- WineList
        |   +-- WineListTile (nome, annata, quantita', "Stima in arrivo")
        +-- EmptyState ("La tua cantina e' vuota" + Aggiungi)
        +-- AddWineButton
    +-- AddWineScreen (M4b semplificata)
        +-- NameField, VintageField + NoVintageSwitch, QuantityStepper
        +-- SaveButton
```

La barra in basso a quattro sezioni arriva con u4-cellar e u5-dashboard; in U1 c'è la sola Cantina.

## Componenti

| Componente | Stato e dati | Interazioni | Regole |
|------------|--------------|-------------|--------|
| AuthGate | stato della sessione, lastUid | apre SignIn o Cantina; blocca un account diverso con modifiche in coda | BR1.1, BR1.2, BR1.4 |
| SignInScreen | caricamento, errore, senza rete | "Continua con Google", "Riprova" | BR1.1 |
| CellarScreen | caricamento, errore della cantina, elenco vini, stato di sincronizzazione | "Aggiungi" (disattivato finché la cantina non esiste), "Riprova" | BR1.3, BR2.4, BR3.2 |
| OfflineBanner | in attesa (sì/no) e rete (sì/no) | nessuna | BR3.2 |
| WineListTile | nome, annata, quantità | nessuna in U1 | BR2.4 |
| AddWineScreen | ID del vino, campi, errori, salvataggio in corso | Salva (disattivato dopo il primo tocco), Indietro | BR2.1–BR2.4 |
| QuantityStepper | valore 1–99 | - e + | BR2.3 |

## Validazione del modulo

- Nome: obbligatorio, 1–120 caratteri (BR2.1); errore mostrato all'uscita dal campo e al Salva.
- Annata: errore mostrato all'uscita dal campo e al Salva (BR2.2).
- Annata: numero di 4 cifre tra 1900 e l'anno corrente oppure interruttore "Senza annata" (BR2.2).
- Quantità: - / + tra 1 e 99 (BR2.3).
- Salva: dopo il primo tocco valido il pulsante si disattiva e il modulo si chiude; l'ID del vino nasce all'apertura del modulo (BR2.4).

## Accessibilità (BR5.3)

Ogni controllo ha un'etichetta per TalkBack; il banner offline è annunciato quando appare; aree toccabili 48x48 dp; nessun testo tagliato con il testo di sistema al 200%; tutti i testi nei file di traduzione it/en/pt-BR.

## Integrazioni

- Account: accesso Google tramite Firebase Authentication.
- Cellar/Sync: lettura e scrittura su Firestore con memoria offline persistente; stato delle modifiche in attesa letto dai metadati di Firestore.
