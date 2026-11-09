# Specifica di interazione — profili di stile

## Fonti

- `requirements.md` FR1–FR4; `style-mockups.html` S1–S6.

## Preselezione (S1)

- Tipologia, Livello e Stile preselezionati mostrano accanto all'etichetta del campo il segno "✦ suggerito" (stessa coppia di colori del segno "✦ dal testo").
- Un tocco su un'altra opzione la sceglie: il segno sparisce e il campo diventa "scelto da te" (origine `user`). Una nuova compilazione automatica (incolla, foto, cambio di nome) non cambia mai un campo scelto da te.
- Cambiare la Tipologia ricalcola lo Stile suggerito; cambiare lo Stile ricalcola il Livello suggerito solo se il Livello non è stato scelto.

## Stile (S2, S4)

- Gruppo di scelte singole (chip), sotto la Tipologia, visibile solo quando la Tipologia ha più stili per quel vino.
- Etichette: Spumante → "Fresco", "Da evoluzione"; Charmat → "Fresco", "Lambrusco"; Dolce → "Aromatico", "Passito", "Botritizzato"; Liquoroso → "Porto Vintage", "Porto LBV", "Porto Tawny/Colheita", "Fino/Manzanilla", "Amontillado", "Oloroso/Cream", "Pedro Ximénez", "Altro"; Rosso → "Fresco", "Medio", "Da evoluzione", "Di lunga evoluzione"; Bianco → "Fresco", "Medio", "Da evoluzione".
- Nel dettaglio di un vino con "Stile da confermare" (S4) lo stesso gruppo compare sotto l'avviso: un tocco salva lo stile e aggiorna la stima subito.

## Data di sboccatura / imbottigliamento (S2)

- Due campi affiancati: mese (gennaio–dicembre) e anno (dal 1950 all'anno corrente). Facoltativi. "Sboccatura" per metodo classico, "Imbottigliamento" per Charmat, Lambrusco, Porto LBV/Tawny/Colheita e Sherry.
- Una nota piccola sotto spiega dove trovarla ("di solito sull'etichetta posteriore").

## Finestre in mesi (S3, S5, S6)

- Formato "marzo 2027" (mese per esteso nella lingua dell'app) nel dettaglio, "mar 2027" nelle liste e nel cruscotto.
- Senza picco: la riga "Al meglio" non compare. Senza fine: "nessuna fine stimata" al posto di "Consigliato fino al".
- Porto LBV/Tawny: stato "Da bere" sempre. Sherry: "Bevi presto" negli ultimi 3 mesi prima della fine.

## Stile da confermare (S4, S6)

- Banda gialla "⚠︎ Stile da confermare: la stima è indicativa" in cima al dettaglio.
- Nel cruscotto un riquadro "Da confermare" elenca questi vini e quelli "Da stimare"; un tocco apre il dettaglio.

## Accessibilità

- Il segno "✦ suggerito" è letto dal lettore di schermo ("Tipologia, Rosso strutturato, suggerito").
- I chip dello Stile sono un gruppo a scelta singola ("Stile, Fresco, 1 di 2, suggerito"), alti almeno 48 dp.
- I campi mese e anno hanno etichette proprie; le date in mesi sono lette per esteso.

## Precisazioni dopo la revisione

- **Vino senza Tipologia** (R-01): il dettaglio mostra "Da stimare" se non c'è nessun indizio, oppure la stima indicativa di FR1.4 con l'avviso; sotto c'è "Scegli la tipologia" con i chip delle tipologie. Scelta la tipologia compare lo Stile.
- **Madeira** (R-01): tra gli stili del Liquoroso c'è "Madeira" (profilo FORT_UNKNOWN): sceglierlo toglie "Da stimare" e mostra una stima indicativa con "Stile da confermare"; lo studio non dà numeri per il Madeira e non ne inventiamo.
- **Mese e anno** (R-02): anno da 1950 all'anno corrente; non nel futuro rispetto al mese corrente; non prima dell'annata, se c'è. Un mese senza anno o un anno senza mese mostrano "Indica mese e anno". Se lo Stile cambia, la data resta salvata ma è usata solo dai profili in mesi; cambia solo l'etichetta (Sboccatura/Imbottigliamento).
- **Chip** (R-03): alti 48 dp, come prevede A2.
- **Grafico e barra senza picco o fine** (R-05): nel grafico degli anni al meglio compaiono solo i vini con un picco; la barra "Momento ideale" senza fine è aperta a destra con la scritta "nessuna fine stimata", senza picco non ha il segno del picco.
- **Vini già in cantina** (R-06): la migrazione è silenziosa, come quella di oggi; i campi compilati da lei portano "✦ suggerito"; scegliere un'altra opzione la rende "scelta da te"; per tornare al valore automatico c'è "Ripristina suggerimento" sotto il campo.
- **Un solo segno** (R-07): "✦ suggerito" solo accanto all'etichetta del campo; il chip scelto è evidenziato come ogni chip scelto. Toccare l'opzione già suggerita la conferma come "scelta da te".
- **Lettore di schermo** (R-08): dopo la scelta dello Stile viene annunciata la stima aggiornata ("Stima aggiornata: pronto da marzo 2026"). L'anno si sceglie con la ruota già usata per l'annata (tocco per scriverlo) invece di un elenco da 76 voci.
