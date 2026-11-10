# Materiale per la prima scheda Google Play

Testi estratti dall'appendice C di `docs/vinoozy-pubblicazione-checklist.md`.
Ogni cartella contiene titolo, descrizione breve ed estesa già entro i limiti
30/80/4000 caratteri. `reviewer-instructions.txt` è una bozza in inglese:
le credenziali dimostrative si compilano solo in Play Console.

| Campo | Valore preparato |
|---|---|
| Nome italiano | Vinoozy: la tua cantina |
| Package Android | `com.vinoozy.app` |
| Lingua predefinita | Italiano — it-IT |
| Tipo / prezzo iniziale | App / senza costi |
| Categoria proposta | Cibo e bevande |
| Email supporto | bottazzinibruno@gmail.com |
| Privacy prevista | https://brunobottazzini.github.io/Vinoozy/privacy/ |
| Cancellazione prevista | https://brunobottazzini.github.io/Vinoozy/account-deletion/ |

Gli URL sono destinazioni preparate, non pagine già pubblicate e verificate.
Pubblico 18+, Italia al primo rilascio e assenza di annunci sono le proposte
dell'handoff: verificare le dichiarazioni sulla build effettivamente scelta.

## Grafica disponibile

- Icona store: `assets/icon-512.png`, copia invariata dell'icona ufficiale
  `assets/icon/play_store_512.png` del progetto; PNG RGB 512×512, 29 KB.
- Feature graphic italiana: `assets/feature-graphic-it-IT-v1.jpg`, JPEG
  RGB 1024×500 senza trasparenza. Generata con image_gen integrato, a
  partire dall'icona come riferimento di marca. Originale e prompt completo
  conservati in `assets/feature-source-it-IT-v1.png` e
  `assets/imagegen-prompt.txt`.
- Quattro catture 1080×1920 per lingua in `assets/screenshots/{it,en,pt-BR}/`:
  Cantina, Cruscotto, dettaglio della stima, Storico. Sono render dei widget
  Flutter effettivi, con tema Android e dati fittizi, prodotti dal comando
  `flutter test tool/render_store_screenshots_test.dart`. Non sono immagini
  generate né prove di installazione della futura release firmata.
  I font Roboto/Material Icons sono quelli dell'SDK; Noto Serif regular/bold
  provengono dal repository ufficiale `notofonts/noto-fonts` e vanno salvati
  in `/tmp/vinoozy-NotoSerif-{Regular,Bold}.ttf` per rigenerare. Su questo Mac
  il renderer usa le emoji e i simboli di sistema perché il font bitmap
  Android non è supportato dal renderer locale. La forma delle emoji può
  variare sul dispositivo Android.
- Usare solo dati fittizi e funzioni realmente distribuite. Testi immagine
  e specifiche sono nell'appendice C4 dell'handoff.

## Controllo locale

`npm run check:publication` controlla testi, pagine privacy, link locali e
configurazione Firebase web. Fallisce finché restano placeholder o valori
Firebase/reCAPTCHA da completare. `--draft` consente di verificare
la struttura senza scambiare le bozze per materiale già pubblicabile.

Il controllo non verifica grafica, console, dichiarazioni legali, accesso
dei reviewer, firma, test su dispositivi o conformità complessiva.
