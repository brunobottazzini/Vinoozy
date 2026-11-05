# Performance Requirements — u1-skeleton

Fonti: `requirements.md` (NFR1, NFR2, NFR3, NFR5), `functional-spec.md` e `rules.md` di U1, `contract-summary.md` (C3), `team.md` (Testing Posture).

Telefono di riferimento: Android di fascia media (8 core, 4 GB di RAM, Android 10 o successivo). In CI si usa l'emulatore Android di GitHub Actions; i tempi in CI hanno limiti più larghi perché l'emulatore è più lento.

## Tempi

| ID | Requisito | Misura |
|----|-----------|--------|
| NFR2.1 | Avvio a freddo con sessione salvata, anche offline: la Cantina con i vini è visibile entro **2 s** sul telefono di riferimento ed entro 4 s nell'emulatore di CI. Requisito derivato: NFR2 fissa 2 s per il Cruscotto con 500 bottiglie; in U1 la prima schermata è la Cantina e vale lo stesso limite. | In CI: test end-to-end con cronometro tra avvio e primo elenco visibile, mediana di 5 avvii (blocca il merge). Su telefono: misura manuale prima della promozione in produzione. |
| NFR2.2 | Elenco della Cantina con 500 vini: lo scorrimento resta fluido, con meno del 5% di fotogrammi oltre 16 ms. L'elenco si costruisce in modo pigro (`ListView.builder`). | Profilo di prestazioni in modalità profile su telefono reale, prima della promozione in produzione. |
| NFR1.1 | Requisito derivato da NFR1 (velocità di inserimento): dopo il tocco su "Salva" con dati validi, il vino compare nell'elenco entro **300 ms**, con o senza rete (scrittura locale, BR2.4). | Test end-to-end offline. |
| NFR1.2 | La misura dei 30 secondi per un vino presente nei suggerimenti (NFR1) non si applica a U1 (delivered by u4-cellar). | — |
| NFR2.3 | Il Cruscotto entro 2 s con 500 bottiglie (NFR2) non si applica a U1 (delivered by u5-dashboard). | — |

## Interfaccia e accessibilità

| ID | Requisito | Misura |
|----|-----------|--------|
| NFR3.1 | Contrasto del testo ≥ 4.5:1 nei temi chiaro e scuro (token di `design-system-mapping.md`). | Test dei widget con la guida `textContrastGuideline`. |
| NFR3.2 | Aree toccabili ≥ 48x48 dp. | Test dei widget con `androidTapTargetGuideline`. |
| NFR3.3 | Ogni controllo ha un'etichetta per TalkBack. | Test dei widget con `labeledTapTargetGuideline`. |
| NFR3.4 | Testo di sistema al 200%: nessun testo tagliato né sovrapposto in Accesso, Cantina e Scrivi. | Test dei widget con `textScaler` 2.0 nelle tre lingue (it, en, pt-BR). |

## Consumo del servizio (costo 0 €)

| ID | Requisito | Misura |
|----|-----------|--------|
| NFR5.1 | Un solo ascoltatore attivo sui vini della cantina aperta e uno sul documento della cantina; nessuna lettura ripetuta a ogni ricostruzione della schermata. | Revisione del codice; contatore delle letture nell'emulatore in un test end-to-end. |
| NFR5.2 | Uso stimato per una persona con 100 bottiglie: meno di 1.000 letture e 100 scritture al giorno, comprese le letture fatte dalle regole (un `get()` della cantina per ogni scrittura di un vino, NFR4.4) e quelle del giornale delle creazioni (NFR6.3). Resta molto sotto la quota gratuita (50.000 letture e 20.000 scritture al giorno). | Pannello Firestore dopo una settimana di test interno. |
| NFR5.3 | Avviso di spesa a 1 € configurato sul progetto di produzione (piano Blaze, NFR5.4) prima della prima pubblicazione. | Controllo manuale prima del rilascio. |

## Stato della rete

| ID | Requisito | Misura |
|----|-----------|--------|
| NFR2.4 | Requisito derivato da NFR2 (prestazioni anche offline). L'indicatore della sincronizzazione legge `hasPendingWrites` e `isFromCache` dai metadati degli snapshot (con `includeMetadataChanges`). Un solo ascoltatore, nella radice della Cantina, fornisce lo stato a `OfflineBanner`. L'indicatore cambia entro 1 s dal cambio dei metadati. | Test end-to-end: rete disattivata e riattivata nell'emulatore. |
| NFR2.5 | Requisito derivato da NFR2 (prestazioni anche offline). Per il primo accesso senza rete (BR1.1) si usa lo stato di connessione del telefono, solo per mostrare subito "Serve la connessione per il primo accesso". | Test dei widget con connessione simulata assente. |
