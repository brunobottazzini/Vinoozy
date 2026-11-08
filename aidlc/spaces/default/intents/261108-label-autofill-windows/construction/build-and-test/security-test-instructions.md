# Istruzioni dei test di sicurezza e privacy

## Fonti

- `construction/nfr-requirements/security-requirements.md` (NFR1.x, NFR3.1–NFR3.9)

## Controlli automatici

- **Appunti** (NFR3.1): test con canale finto; il contenuto si legge solo al tocco di "Incolla da Lens" o una volta al ritorno da Lens entro 5 minuti.
- **Testo dell'etichetta e guida** (NFR3.2, NFR3.8): test del logger: gli eventi accettano solo enum e numeri; una guida completa con logger finto e `debugPrint` catturato non lascia nessun testo dell'etichetta né valore scritto a mano.
- **Testo non fidato** (NFR3.4, NFR3.9): test con testi molto lunghi, caratteri di controllo e markup; i valori composti o scritti passano la validazione del modulo.
- **Manifest** (NFR3.3): `tool/check_lens_manifest.sh`, nessun permesso nuovo.
- **Regole Firestore** (NFR1.2–NFR1.4): `test:rules` con casi validi, non validi e di compatibilità.
- **Segreti**: la scansione gitleaks esistente in CI; nessuna credenziale nel repository.

## Controlli manuali prima dello store

- Scheda "Sicurezza dei dati" di Google Play per Lens e appunti.
- Pubblicazione delle regole solo con l'OK del proprietario.
