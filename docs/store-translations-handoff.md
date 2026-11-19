# Handoff — Traduzioni della scheda Google Play e Alpha 0.3.0 (5)

Destinatario: un agente che opera in Google Play Console con l'account del proprietario.
Data: 18 novembre 2026.

## Obiettivo

1. Aggiungere 22 lingue alla scheda principale di Vinoozy e incollare titolo, descrizione breve e descrizione completa di ognuna.
2. Promuovere la build **0.3.0 (5)** dal test interno al test chiuso **Alpha**, con le note di rilascio in tutte le 25 lingue.
3. Inviare tutte le modifiche per la revisione, ma solo dopo la conferma esplicita del proprietario.

## Riferimenti

- App: Vinoozy, pacchetto `com.vinoozy.app`.
- Account sviluppatore `7355456641864294998`, app `4974010218208182861`.
- Console: https://play.google.com/console/u/1/developers/7355456641864294998/app/4974010218208182861/app-dashboard
- La pubblicazione gestita è **disattivata**: niente diventa pubblico finché non si preme «Invia modifiche per la revisione».

## Regole

- **Testi**: copiare i testi dai file indicati così come sono. Non tradurre, non riscrivere, non accorciare.
- **Lingua predefinita**: resta **italiano (it-IT)**. Non cambiarla.
- **Cosa non toccare**:
  - le tre lingue già presenti (it-IT, en-US, pt-BR): i loro testi sono già in Console;
  - le catture di schermo e la grafica;
  - la sicurezza dei dati, il pubblico di destinazione, i prezzi e i paesi.
- **Account dei revisori**: la password è solo in Console. Non chiederla, non leggerla, non scriverla da nessuna parte.
- **Spese**: non acquistare nulla e non avviare servizi a pagamento.
- **Conferme**: prima di «Invia modifiche per la revisione» fermarsi e chiedere la conferma esplicita al proprietario, mostrandogli l'elenco delle modifiche in sospeso.
- **Blocchi**: se Play Console rifiuta un testo (lunghezza, parole vietate), non modificarlo. Annotare lingua, campo e messaggio e passare alla lingua successiva.

## Dove sono i testi

Repository: `distribution/google-play/`. Ogni cartella porta il codice di lingua di Google Play e contiene tre file:

| File | Campo in Play Console | Massimo |
|---|---|---|
| `title.txt` | Nome dell'app | 30 caratteri |
| `short-description.txt` | Descrizione breve | 80 caratteri |
| `full-description.txt` | Descrizione completa | 4000 caratteri |

I testi sono stati controllati con `node tool/check_publication.mjs --draft`: tutti esistono e sono entro i limiti.

## Parte 1 — Aggiungere le 22 lingue alla scheda

Percorso: **Fai crescere gli utenti → Presenza sul Play Store → Schede dello Store → Scheda dello Store principale**. La voce del menu può chiamarsi anche «Crescita» o «Presenza nello store».

1. Premere **Gestisci traduzioni → Gestisci le tue traduzioni** (non le traduzioni a pagamento).
2. Selezionare le 22 lingue della tabella e confermare.
3. Per ogni lingua: sceglierla nel selettore in alto, incollare i tre testi, **Salva**. Spuntare la riga nella tabella.

| ✓ | Lingua in Play Console | Codice | Cartella |
|---|---|---|---|
| ☐ | Portoghese (Portogallo) | pt-PT | `distribution/google-play/pt-PT/` |
| ☐ | Francese (Francia) | fr-FR | `distribution/google-play/fr-FR/` |
| ☐ | Spagnolo (Spagna) | es-ES | `distribution/google-play/es-ES/` |
| ☐ | Tedesco | de-DE | `distribution/google-play/de-DE/` |
| ☐ | Catalano | ca | `distribution/google-play/ca/` |
| ☐ | Greco | el-GR | `distribution/google-play/el-GR/` |
| ☐ | Rumeno | ro | `distribution/google-play/ro/` |
| ☐ | Ungherese | hu-HU | `distribution/google-play/hu-HU/` |
| ☐ | Croato | hr | `distribution/google-play/hr/` |
| ☐ | Sloveno | sl | `distribution/google-play/sl/` |
| ☐ | Ceco | cs-CZ | `distribution/google-play/cs-CZ/` |
| ☐ | Slovacco | sk | `distribution/google-play/sk/` |
| ☐ | Bulgaro | bg | `distribution/google-play/bg/` |
| ☐ | Serbo | sr | `distribution/google-play/sr/` (scrittura cirillica) |
| ☐ | Georgiano | ka-GE | `distribution/google-play/ka-GE/` |
| ☐ | Olandese | nl-NL | `distribution/google-play/nl-NL/` |
| ☐ | Polacco | pl-PL | `distribution/google-play/pl-PL/` |
| ☐ | Ucraino | uk | `distribution/google-play/uk/` |
| ☐ | Danese | da-DK | `distribution/google-play/da-DK/` |
| ☐ | Svedese | sv-SE | `distribution/google-play/sv-SE/` |
| ☐ | Norvegese | no-NO | `distribution/google-play/no-NO/` |
| ☐ | Finlandese | fi-FI | `distribution/google-play/fi-FI/` |

### Catture di schermo e grafica

Per le lingue nuove non caricare nulla: Google Play mostra le catture e la grafica della lingua predefinita (italiano).

Se Play Console segna una lingua come incompleta per la grafica, verificare se è un errore che blocca l'invio o solo un avviso.
- **Se è solo un avviso**: andare avanti.
- **Se blocca l'invio**: fermarsi e chiedere al proprietario. Le catture inglesi sono in `distribution/google-play/assets/screenshots/`.

### Descrizione completa di it-IT, en-US, pt-BR

Il repository ha una versione aggiornata della frase sulle lingue ("25 lingue"). Aggiornare anche queste tre schede, incollando `full-description.txt` delle cartelle `it-IT`, `en-US`, `pt-BR`. È l'unico campo da cambiare in queste tre lingue.

## Parte 2 — Promuovere 0.3.0 (5) ad Alpha

1. **Test e rilascio → Test → Test interno**: verificare che l'ultima release sia **5 (0.3.0)**.
2. Nella release premere **Promuovi release → Test chiuso – Alpha**. Si crea una bozza Alpha con lo stesso app bundle: non caricare file.
3. **Nome della release**: `5 (0.3.0)`.
4. **Note di rilascio**: incollare l'intero contenuto di `distribution/google-play/release-notes.txt`, 25 blocchi del tipo `<fr-FR>…</fr-FR>`.
   - Va fatto **dopo** la Parte 1: Play Console accetta solo i blocchi delle lingue presenti nella scheda.
   - Se un blocco viene rifiutato, annotare il codice e chiedere al proprietario. Non togliere il blocco di nascosto.
5. **Avanti → Salva**. Controllare gli avvisi e annotarli. Non inviare ancora.
6. Non cambiare i tester (gruppo `testers-community@googlegroups.com`) né i paesi (178).

## Parte 3 — Invio per la revisione

1. **Panoramica della pubblicazione**: copiare l'elenco delle modifiche in sospeso.
2. Mostrare l'elenco al proprietario e chiedere la conferma esplicita.
3. Solo dopo la conferma: **Invia modifiche per la revisione**.

## Verifiche dopo l'approvazione di Google

- Per ogni lingua aprire `https://play.google.com/store/apps/details?id=com.vinoozy.app&hl=<codice>`, per esempio `hl=fr`, `hl=el`, `hl=ka`, `hl=sr`. Titolo e descrizione devono essere nella lingua giusta.
- Canale Alpha: release **5 (0.3.0)** «Disponibile per tester selezionati».

## Cosa riportare al proprietario

- Le lingue aggiunte e quelle eventualmente rifiutate, con il messaggio di Play Console.
- Lo stato della release Alpha 5 (0.3.0) e gli eventuali avvisi.
- L'elenco delle modifiche inviate e l'ora dell'invio.
- Aggiornare `docs/play-console-handoff.md` con una sezione datata che riassume quanto sopra.

## Fuori da questo compito

- **Produzione**: si fa solo con `promote.yml` su GitHub Actions e con l'approvazione del proprietario. In più Google concede l'accesso alla produzione solo dopo 12 tester attivi per 14 giorni consecutivi.
- **Pagine web di privacy e cancellazione dell'account**: restano in tre lingue.
- **Testers Community**: non reinviare l'app e non acquistare crediti.
