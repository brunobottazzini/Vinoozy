# Domande — Functional Design (label-recognition)

Non ci sono domande per il proprietario. Le scelte di prodotto sono state prese in Requirements Analysis (Q1 = A, Q2 = A, Q3 = A) e nei mockup approvati.

Il proprietario ha chiesto di lavorare in autonomia fino alla consegna, con escalation solo per i problemi (messaggi 1f343d5c e 8e132010). Le decisioni tecniche di questa fase le prendo io, con le motivazioni in `functional-spec.md`, e restano correggibili.

Il dato raccolto per decidere: la ricerca su Open Food Facts del 2026-11-07 (`/api/v2/search?categories_tags_en=wines`) conta **16.973 prodotti** nella categoria vini. I dati sono rumorosi: ci sono marmellate e succhi etichettati anche come vino.
