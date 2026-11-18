# Requirements Analysis — Domande

Richiesta di partenza: "aggiungere lingue supportate obbligatorio francese, spagnolo, tedesco e tutti i paesi con cultura di "vino". Mi suggeriesci tutte le lingue che pensi che sia necesasrio suportare. Vorrei qualcosina minimo 20 lingue"

Oggi l'app parla italiano, inglese e portoghese del Brasile. Le lingue qui sotto sono la mia proposta, come hai chiesto: le ho scelte guardando dove il vino si produce e dove si compra e si colleziona di più.

## Q1. [Responsabile di prodotto] Quali lingue aggiungiamo

Tutte le proposte tengono le tre lingue di oggi e aggiungono francese, spagnolo e tedesco, che hai indicato come obbligatorie. Cambia quanto ci allarghiamo.

- **Paesi produttori d'Europa**: francese, spagnolo, tedesco, portoghese del Portogallo, catalano, greco, rumeno (copre anche la Moldavia), ungherese, croato, sloveno, ceco, slovacco, bulgaro, serbo, georgiano (la Georgia è la culla del vino).
- **Grandi mercati di chi compra e colleziona**: olandese, polacco, ucraino, danese, svedese, norvegese, finlandese.
- **Mercati lontani e scritture più impegnative**: russo, turco, giapponese, cinese semplificato, coreano.

A. 25 lingue: le 3 di oggi + i 15 paesi produttori d'Europa + i 7 grandi mercati (olandese, polacco, ucraino, danese, svedese, norvegese, finlandese). È la mia raccomandazione: copre tutta l'Europa del vino e chi la compra, con scritture (latina, greca, cirillica, georgiana) che l'app mostra senza modifiche all'impaginazione.

B. 20 lingue: le 3 di oggi + i 15 paesi produttori d'Europa + olandese e polacco. Il minimo che hai chiesto, meno lavoro di traduzione e di test.

C. 30 lingue: le 25 della proposta A + russo, turco, giapponese, cinese semplificato, coreano. Massima copertura, ma più testi da tradurre e da tenere aggiornati a ogni rilascio, e le lingue asiatiche chiedono un controllo in più su caratteri e lunghezze dei testi.

X. Other (please specify)

[Answer]: A

## Q2. [Responsabile di prodotto] Come sceglie la lingua chi usa l'app

Oggi l'app segue la lingua del telefono e non ha una scelta propria. Con molte lingue può capitare che qualcuno voglia l'app in una lingua diversa da quella del telefono (per esempio telefono in inglese, app in francese).

A. L'app continua a seguire il telefono, e in più dichiariamo le lingue ad Android: da Android 13 in poi la persona può scegliere la lingua di Vinoozy dalle impostazioni di sistema dell'app, senza schermate nuove. È la mia raccomandazione: poco lavoro, nessuna schermata da mantenere.

B. Aggiungiamo anche una scelta della lingua dentro l'app, nel profilo, che vale su ogni versione di Android. Più comoda da trovare, ma è una schermata in più da costruire e provare.

C. Lasciamo tutto com'è: solo la lingua del telefono, nessuna scelta.

X. Other (please specify)

[Answer]: A

## Q3. [Responsabile di prodotto] Cosa traduciamo oltre all'app

Oltre ai testi dell'app, oggi sono in tre lingue anche la scheda di Google Play (titolo, descrizioni, note di rilascio, che carichi a mano) e le pagine web pubbliche di privacy e cancellazione dell'account.

A. App + testi della scheda di Google Play in tutte le lingue nuove, pronti nel repository; le pagine web restano nelle tre lingue di oggi e chi usa un'altra lingua vede quella inglese. È la mia raccomandazione: la scheda tradotta è ciò che fa trovare l'app nei nuovi paesi, mentre le pagine legali tradotte in automatico senza una revisione sono un rischio.

B. Solo l'app. La scheda di Google Play e le pagine web restano nelle tre lingue di oggi.

C. Tutto: app, scheda di Google Play e pagine web di privacy e cancellazione in tutte le lingue.

X. Other (please specify)

[Answer]: A

## Q4. [Sviluppatore] Quanto proviamo ogni lingua nei test automatici

Oggi ogni schermata principale viene provata in ognuna delle tre lingue, con due dimensioni del testo e due temi. Fare lo stesso per 20 o più lingue moltiplica i tempi dei controlli su GitHub Actions (il limite attuale è 40 minuti) e la regola di squadra parla di "tre lingue (it, en, pt-BR)". La copertura dell'80% senza esclusioni resta comunque obbligatoria.

A. Prova completa (schermate × dimensioni × temi) per italiano, inglese, portoghese del Brasile, francese, spagnolo e tedesco, più la lingua con i testi più lunghi e una per ogni scrittura non latina; per tutte le altre lingue un controllo automatico che ogni testo esista, sia completo e venga mostrato senza errori. È la mia raccomandazione: tiene i tempi sotto controllo e copre i casi che di solito rompono l'impaginazione.

B. Prova completa per tutte le lingue, accettando controlli molto più lunghi e, se serve, alzando il limite di tempo.

C. Prova completa solo per le tre lingue di oggi; per tutte le lingue nuove solo il controllo automatico dei testi.

X. Other (please specify)

[Answer]: A
