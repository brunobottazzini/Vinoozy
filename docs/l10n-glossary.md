# Glossario dei termini del vino

Questo glossario fissa come si traducono i termini del vino usati in Vinoozy, così lo stesso termine è tradotto allo stesso modo in tutta l'app e nei testi di Google Play (requisito NFR6 del lavoro "Lingue dei paesi del vino").

- Il modello è l'inglese (`lib/l10n/app_en.arb`). Le colonne italiano e portoghese del Brasile riportano i testi già presenti in `lib/l10n/app_it.arb` e `lib/l10n/app_pt_BR.arb`.
- La colonna "Messaggio" indica un messaggio dei file ARB in cui il termine compare, per ritrovarlo.
- Le altre 22 lingue hanno una colonna ciascuna nella sezione [Traduzioni per lingua](#traduzioni-per-lingua).
- Chi traduce un messaggio nuovo cerca prima qui il termine. Se manca, lo aggiunge per tutte le lingue.

## Termini

### La cantina e le bottiglie

| Termine (en) | Italiano | Portoghese del Brasile | Messaggio | Nota |
|---|---|---|---|---|
| cellar | cantina | adega | `cellarTitle` | La raccolta di vini di una persona, non l'azienda che produce il vino |
| bottle, bottles | bottiglia, bottiglie | garrafa, garrafas | `bottleCount` | Ha un plurale: usare le forme di plurale della lingua |
| wine | vino | vinho | `wineNameLabel` | |
| producer | produttore | produtor | `producerLabel` | L'azienda che produce il vino |
| quantity | quantità | quantidade | `quantityLabel` | Numero di bottiglie |
| dashboard | cruscotto | painel | `dashboardTitle` | La schermata di riepilogo |
| History | Storico | Histórico | `historyTitle` | Elenco delle bevute; nome di schermata, con la maiuscola dove la lingua la usa |

### Il vino

| Termine (en) | Italiano | Portoghese del Brasile | Messaggio | Nota |
|---|---|---|---|---|
| vintage | annata | safra | `vintageLabel` | L'anno della vendemmia |
| no vintage | senza annata | sem safra | `noVintage` | Vino senza anno in etichetta |
| grape | vitigno | uva | `estimateFromGrape` | La varietà d'uva |
| appellation | denominazione | denominação | `denominationLabel` | La denominazione d'origine (DOC, AOC, DO e simili) |
| region | regione | região | `uxRegionLabel` | La regione vinicola |
| type | tipologia | tipo | `wineTypeLabel` | Rosso, bianco, rosato, spumante, dolce, liquoroso |
| style | stile | estilo | `styleLabel` | Il profilo di evoluzione dentro una tipologia |
| level | livello | nível | `levelLabel` | La fascia del vino: quotidiano, buono, da invecchiamento |
| red | rosso | tinto | `uxFamilyRed` | |
| white | bianco | branco | `uxFamilyWhite` | |
| rosé | rosato | rosé | `uxFamilyRose` | |
| sparkling | spumante | espumante | `familySparkling` | In italiano il filtro breve è "Bollicine" (`uxFamilySparkling`) |
| sweet | dolce | doce | `typeSweet` | |
| fortified | liquoroso | fortificado | `typeFortified` | Vino a cui è stato aggiunto alcol (Porto, Sherry, Marsala) |
| classic-method sparkling | spumante metodo classico | espumante método clássico | `typeSparklingClassic` | Seconda fermentazione in bottiglia |
| tank-method sparkling | spumante metodo Charmat | espumante método Charmat | `typeSparklingTank` | Seconda fermentazione in autoclave |
| dried-grape (wine) | passito | passito | `styleSweetPassito` | Da uve appassite |
| botrytised | botritizzato | botritizado | `styleSweetBotrytis` | Da uve con muffa nobile |
| for ageing | da evoluzione, da invecchiamento | para envelhecer | `styleRedAge`, `levelAging` | |
| long ageing | di lunga evoluzione | longa guarda | `styleRedLong` | |
| disgorgement | sboccatura | dégorgement | `agingStartDisgorgement` | Data in cui uno spumante metodo classico viene liberato dai lieviti |
| bottling | imbottigliamento | engarrafamento | `agingStartBottling` | |
| label | etichetta | rótulo | `labelReading` | L'etichetta della bottiglia |

### La stima del momento ideale

| Termine (en) | Italiano | Portoghese del Brasile | Messaggio | Nota |
|---|---|---|---|---|
| estimate | stima | estimativa | `estimatePending` | La stima di quando bere il vino |
| (drinking) window | finestra (di consumo) | janela | `statusPastWindow` | Il periodo in cui il vino è buono da bere |
| start | inizio | início | `windowStartLabel` | Inizio della finestra |
| peak | picco | pico, auge | `windowPeakLabel`, `peakChartTitle` | Il momento migliore dentro la finestra (l'apice) |
| end | fine | fim | `windowEndLabel` | Fine della finestra |
| ideal moment | momento ideale | momento ideal | `uxIdealTitle` | |
| confidence | fiducia | confiança | `confidenceLabel` | Quanto è affidabile la stima: alta, media, bassa |
| to wait | da aspettare | aguardar | `statusWaiting` | Stato: la finestra non è ancora iniziata |
| ready | pronte | prontas | `statusReady` | Stato: dentro la finestra; concorda con "bottiglie" |
| drink soon | da bere presto | beber em breve | `statusDrinkSoon` | Stato: la finestra sta per finire |
| past the window | oltre la finestra | fora da janela | `statusPastWindow` | Stato: la finestra è finita |
| still too young | ancora troppo giovane | ainda muito jovem | `conditionTooYoung` | Giudizio dato a una bevuta |
| just right | al punto giusto | no ponto certo | `conditionJustRight` | Giudizio dato a una bevuta |
| past its best | già in declino | já em declínio | `conditionPastPeak` | Giudizio dato a una bevuta |

### Le bevute e gli abbinamenti

| Termine (en) | Italiano | Portoghese del Brasile | Messaggio | Nota |
|---|---|---|---|---|
| drink (noun) | bevuta | consumo, degustação | `sharingPermissionReadHint`, `estimateSourceCorrected` | Una bottiglia bevuta e registrata |
| I drank one | ho bevuto | bebi uma | `uxDrinkAction` | Il pulsante che registra una bevuta |
| drunk | bevuta, bevuti | bebida, bebidos | `wineDrink`, `cellarArchiveTitle` | Concorda con "bottiglia" o con "vini" |
| rating | voto | nota | `recordRatingLabel` | Da 1 a 5 stelle |
| pairings | abbinamenti | harmonizações | `pairingsTitle` | Abbinamenti con il cibo |
| dried fruit (pairing) | frutta secca | frutas secas | `pairingDriedFruit` | Il senso è quello italiano: frutta a guscio e frutta essiccata insieme (noci, mandorle, fichi secchi), l'abbinamento classico di passiti, Vin Santo e Marsala. L'inglese "Dried fruit" è più stretto |

### Il piano e Google Play

| Termine (en) | Italiano | Portoghese del Brasile | Messaggio | Nota |
|---|---|---|---|---|
| plan | piano | plano | `planTitle` | Il piano dell'app (gratuito o Plus) |
| free plan | piano gratuito | plano gratuito | `freeIntroTitle` | |
| subscription | abbonamento | assinatura | `plusManage` | L'abbonamento pagato su Google Play. Dove la lingua ha due parole, "piano" e "abbonamento" non usano la stessa |

## Termini che non si traducono

Restano uguali in ogni lingua, anche in greco, cirillico e georgiano (requisito FR1.6).

- **Il nome dell'app e del piano**: `Vinoozy`, `Vinoozy Plus`, `Plus`.
- **I termini di legge del vino**, scritti nel codice in `qualifierDisplayName` (`lib/cellar/ui/wine_labels.dart`) e non nei file ARB: `Riserva`, `Superiore`, `Gran Selezione`, `Crianza`, `Reserva`, `Gran Reserva`, `Premier Cru`, `Grand Cru`, `Kabinett`, `Spätlese`, `Auslese`, `Beerenauslese`, `Trockenbeerenauslese`, `Eiswein`, `Vintage` (riferito al Porto), `LBV`, `Colheita`.
- **I nomi di stile che sono nomi propri del vino**: `Lambrusco`, `Fino`, `Manzanilla`, `Tawny`, `Ruby`, `Charmat`, `Porto Vintage` (in inglese `Vintage Port`: cambia solo l'ordine delle parole).
- **Le sigle delle denominazioni**: `DOC`, `DOCG`, `IGT`, `AOC`, `AOP`, `DO`, `DOCa`, `DOP`, `IGP`, `AVA` e simili.
- **I nomi delle denominazioni e dei vitigni**: `Barolo`, `Chablis`, `Rioja`, `Nebbiolo`, `Riesling` e gli altri. Vengono dal catalogo, non dai file ARB.
- **I nomi di prodotti e servizi**: `Google`, `Google Play`, `Google Lens` (in breve `Lens`), `Open Food Facts`, `ODbL`, `Firebase`.
- **I segnaposto e le chiavi dei messaggi**: il testo tra graffe (`{count}`, `{name}`) e le chiavi di `plural` e `select` (`one`, `few`, `many`, `other`, `denomination`, `producer`, `vintage`).

I nomi dei paesi non stanno nei file ARB: vengono dai dati Unicode CLDR (`tool/gen_origin_names.mjs`). I nomi delle regioni vinicole sono tradotti solo dove la lingua ha un nome d'uso comune (`lib/cellar/domain/wine_origins.dart`).

## Traduzioni per lingua

Una colonna per ognuna delle 22 lingue nuove; `pt` è il portoghese del Portogallo. Le lingue sono divise in quattro tabelle solo per leggibilità. I valori vengono dai glossari dei traduttori e, dove il glossario non nominava il termine, dal file ARB della lingua. Tra parentesi: le varianti d'uso ("breve" è la forma usata nelle etichette corte, "profilo" quella dei nomi dei profili di stile).

### Lingue romanze

| Termine (en) | `pt` | `fr` | `es` | `ca` | `ro` |
|---|---|---|---|---|---|
| cellar | garrafeira | cave | bodega | celler | pivniță |
| bottle | garrafa | bouteille | botella | ampolla | sticlă (1 sticlă, 2 sticle, 20 de sticle) |
| wine | vinho | vin | vino | vi | vin |
| producer | produtor | producteur | productor | productor | producător |
| dashboard | Painel | Aperçu | Panel | Tauler | panou |
| History | Histórico | Historique | Historial | Historial | istoric |
| vintage | colheita | millésime | añada | anyada | recoltă (nelle frasi: anul de recoltă) |
| grape | casta | cépage | variedad | varietat | soi |
| appellation | denominação | appellation | denominación | denominació | denumire de origine |
| label | rótulo | étiquette | etiqueta | etiqueta | etichetă |
| type | tipo | type | tipo | tipus | tip |
| style | estilo | style | estilo | estil | stil |
| level | nível | niveau | nivel | nivell | nivel |
| red | tinto | rouge | tinto | negre | roșu |
| white | branco | blanc | blanco | blanc | alb |
| rosé | rosé | rosé | rosado | rosat | rosé |
| sparkling | espumante | effervescent | espumoso | escumós | spumant |
| sweet | doce | doux | dulce | dolç | dulce |
| fortified | fortificado | muté | generoso | generós | fortificat |
| classic method | método clássico | méthode traditionnelle | método tradicional | mètode tradicional | metoda tradițională |
| tank method | método Charmat | méthode Charmat | método Charmat | mètode Charmat | metoda Charmat |
| dried-grape | uvas passas | passerillé | uvas pasificadas | raïm pansificat | din struguri stafidiți |
| botrytised | botritizado | botrytisé | botritizado | botritzat | botritizat |
| for ageing | de guarda | de garde | de guarda | de guarda | de învechire |
| disgorgement | dégorgement | dégorgement | degüelle | desgorjament | degorjare |
| bottling | engarrafamento | mise en bouteille | embotellado | embotellament | îmbuteliere |
| estimate | estimativa | estimation | estimación | estimació | estimare |
| drinking window | janela de consumo | fenêtre de dégustation | ventana de consumo | finestra de consum | fereastră de consum |
| peak | apogeu | apogée | apogeo | apogeu | apogeu |
| ready | pronto / prontas | prêt / prêtes | listo / listas | a punt | gata |
| drink soon | beber em breve | à boire bientôt | beber pronto | per beure aviat | de băut curând |
| to wait | a aguardar | à attendre | esperar | per esperar | de așteptat |
| past the window | janela ultrapassada | fenêtre dépassée | ventana superada | finestra superada | după fereastră |
| confidence | confiança | confiance | confianza | confiança | încredere |
| drink (record) | consumo | dégustation | consumo | consum | degustare |
| I drank one | Bebi uma | J'en ai bu une | Me he bebido una | N'he begut una | Am băut una |
| rating | classificação | note | valoración | valoració | evaluare |
| pairing | harmonização | accord | maridaje | maridatge | asociere |
| dried fruit (pairing) | frutos secos | fruits secs | frutos secos | fruita seca | nuci și fructe uscate |
| sharing | partilha | partage | uso compartido | compartició | partajare |
| owner | proprietário | propriétaire | propietario | propietari | proprietar |
| plan | plano | formule | plan | pla | plan |
| free plan | plano gratuito | formule gratuite | plan gratuito | pla gratuït | plan gratuit |
| subscription | subscrição | abonnement | suscripción | subscripció | abonament |
| sync | sincronização | synchronisation | sincronización | sincronització | sincronizare |
| wine database | base de vinhos | base de vins | base de vinos | base de vins | baza de date de vinuri |

### Lingue germaniche

| Termine (en) | `de` | `nl` | `da` | `sv` | `nb` |
|---|---|---|---|---|---|
| cellar | Keller (Weinkeller nello slogan, nella presentazione e nei testi dello store) | kelder (wijnkelder, come in tedesco) | kælder (vinkælder, come in tedesco) | källare (vinkällare, come in tedesco) | kjeller (vinkjeller, come in tedesco) |
| bottle | Flasche | fles | flaske | flaska | flaske |
| wine | Wein | wijn | vin | vin | vin |
| producer | Erzeuger | producent | producent | producent | produsent |
| dashboard | Übersicht | Overzicht | Oversigt | Översikt | Oversikt |
| History | Verlauf | Geschiedenis | Historik | Historik | Historikk |
| vintage | Jahrgang | jaargang | årgang | årgång | årgang |
| grape | Rebsorte | druivenras | druesort | druva | druesort |
| appellation | Appellation | appellatie | appellation | appellation | appellasjon |
| label | Etikett | etiket | etiket | etikett | etikett |
| type | Typ (Weintyp) | type | type | typ | type |
| style | Stil | stijl | stil | stil | stil |
| level | Stufe | niveau | niveau | nivå | nivå |
| red | rot | rood | rød | rött | rød |
| white | weiß | wit | hvid | vitt | hvit |
| rosé | rosé | rosé | rosé | rosé | rosé |
| sparkling | Schaumwein | mousserend | mousserende | mousserande | musserende |
| sweet | Süßwein | zoet | sød | sött | søt |
| fortified | Likörwein | versterkt | hedvin | starkvin | sterkvin |
| classic method | Flaschengärung | traditionele methode | traditionel metode | traditionell metod | tradisjonell metode |
| tank method | Tankgärung | tankmethode | tankmetode | tankmetod | tankmetode |
| dried-grape | Strohwein (profilo: Süßwein aus getrockneten Trauben) | gedroogde druiven | tørrede druer | torkade druvor | tørkede druer |
| botrytised | Botrytis (profilo: edelsüßer Botrytis-Wein) | botrytis (profilo: zoete botrytiswijn) | botrytis (profilo: sød botrytisvin) | botrytis (profilo: sött botrytisvin) | botrytis (profilo: søt botrytisvin) |
| for ageing | zum Lagern | om te bewaren (profilo: bewaarwijn) | til lagring | för lagring | til lagring |
| disgorgement | Degorgierung | dégorgement | degorgering | degorgering | degorgering |
| bottling | Abfüllung | botteling | aftapning | buteljering | tapping |
| estimate | Schätzung | schatting | estimat | uppskattning | anslag |
| drinking window | Trinkfenster | drinkvenster | drikkevindue | drickfönster | drikkevindu |
| peak | Höhepunkt | hoogtepunt | toppunkt | topp | topp |
| ready | trinkreif | op dronk | drikkeklar | drickfärdig | drikkeklar |
| drink soon | bald trinken | binnenkort drinken | drik snart | drick snart | drikk snart |
| to wait | noch lagern | nog bewaren | skal vente | bör vänta | bør vente |
| past the window | Fenster vorbei | venster voorbij | vindue forbi | fönstret passerat | vinduet er over |
| confidence | Sicherheit | zekerheid | sikkerhed | säkerhet | sikkerhet |
| drink (record) | getrunkene Flasche | gedronken fles | drukket flaske | drucken flaska | drukket flaske |
| I drank one | Eine getrunken | Eén gedronken | Drak en | Drack en | Drakk en |
| rating | Bewertung | beoordeling | bedømmelse | betyg | vurdering |
| pairing | Speiseempfehlung (titolo: Passt zu) | wijn-spijscombinatie (titolo: Past bij) | madforslag (titolo: Passer til) | matförslag (titolo: Passar till) | matforslag (titolo: Passer til) |
| dried fruit (pairing) | Nüsse und Trockenfrüchte | noten en gedroogd fruit | nødder og tørret frugt | nötter och torkad frukt | nøtter og tørket frukt |
| sharing | Freigabe | delen | deling | delning | deling |
| owner | Inhaber | eigenaar | ejer | ägare | eier |
| plan | Tarif | pakket | pakke | abonnemang | pakke |
| free plan | kostenloser Tarif | gratis pakket | gratispakke | gratisabonnemang | gratispakke |
| subscription | Abo | abonnement | abonnement | prenumeration | abonnement |
| sync | Synchronisierung | synchronisatie | synkronisering | synkronisering | synkronisering |
| wine database | Weindatenbank | wijndatabase | vindatabase | vindatabas | vindatabase |

### Lingue slave

| Termine (en) | `pl` | `cs` | `sk` | `hr` | `sl` | `bg` | `sr` | `uk` |
|---|---|---|---|---|---|---|---|---|
| cellar | piwniczka | sklep | pivnica | podrum | klet | изба | подрум | льох |
| bottle | butelka (butelki, butelek) | láhev (lahve, lahví) | fľaša (fľaše, fliaš) | boca (boce, boca) | steklenica (steklenici, steklenice, steklenic) | бутилка | боца | пляшка |
| wine | wino | víno | víno | vino | vino | вино | вино | вино |
| producer | producent | vinařství | vinárstvo | vinarija | pridelovalec | производител | произвођач | виробник |
| dashboard | Pulpit | Přehled | Prehľad | Pregled | Pregled | Табло | Преглед | Огляд |
| History | Historia | Historie | História | Povijest | Zgodovina | История | Историја | Історія |
| vintage | rocznik | ročník | ročník | berba | letnik | реколта | берба | рік урожаю |
| grape | szczep | odrůda | odroda | sorta | sorta | сорт | сорта | сорт винограду |
| appellation | apelacja | apelace | apelácia | apelacija | apelacija | апелация | апелација | апелласьйон |
| label | etykieta | etiketa | etiketa | etiketa | etiketa | етикет | етикета | етикетка |
| type | typ | typ | typ | vrsta | vrsta | тип | врста | тип |
| style | styl | styl | štýl | stil | slog | стил | стил | стиль |
| level | poziom | úroveň | úroveň | razina | raven | ниво | ниво | рівень |
| red | czerwone | červené | červené | crno | rdeče | червено | црвено | червоне |
| white | białe | bílé | biele | bijelo | belo | бяло | бело | біле |
| rosé | różowe | růžové | ružové | ružičasto | rosé | розе | розе | рожеве |
| sparkling | musujące | šumivé | šumivé | pjenušavo | peneče | пенливо | пенушаво | ігристе |
| sweet | słodkie | sladké | sladké | slatko | sladko | сладко | слатко | солодке |
| fortified | wzmacniane | fortifikované | fortifikované | likersko | likersko | подсилено | ликерско | кріплене |
| classic method | metoda klasyczna | klasická metoda | klasická metóda | klasična metoda | klasična metoda | класически метод | класична метода | класичний метод |
| tank method | metoda Charmata | metoda Charmat | metóda Charmat | metoda Charmat | metoda Charmat | метод Шарма | шарма метода | метод Шарма |
| dried-grape | z podsuszanych gron | slámové | slamové | prosušeno grožđe | sušeno grozdje | Passito (profilo: от стафидирано грозде) | Passito (profilo: од просушеног грожђа) | Passito (profilo: з підв’яленого винограду) |
| botrytised | botrytyzowane | botrytické | botrytické | plemenita plijesan | plemenita plesen | ботритизирано | ботритизовано | ботритизоване |
| for ageing | do leżakowania | k archivaci | na archiváciu | za čuvanje | za staranje | за отлежаване | за одлежавање | для витримки |
| disgorgement | degorżowanie | degoržáž | degoržáž | degoržiranje | degoržiranje | дегоржиране | дегоржирање | дегоржаж |
| bottling | butelkowanie | lahvování | fľašovanie | punjenje | polnitev | бутилиране | пуњење | розлив |
| estimate | szacunek | odhad | odhad | procjena | napoved | прогноза | процена | прогноз |
| drinking window | okno picia | okno pitelnosti | okno pitnosti | prozor pitkosti | okno pitnosti | прозорец за консумация (breve: прозорец) | прозор испијања (breve: прозор) | вікно споживання (breve: вікно) |
| peak | szczyt | vrchol | vrchol | vrhunac | vrhunec | връх | врхунац | пік |
| ready | gotowe | připravené | pripravené | spremne | pripravljene | готови | спремне | готові |
| drink soon | wypić wkrótce | vypít brzy | vypiť čoskoro | popiti uskoro | popiti kmalu | за пиене скоро | попити ускоро | випити незабаром |
| to wait | poczekać | počkat | počkať | pričekati | počakati | за изчакване | за чекање | зачекати |
| past the window | po oknie picia | po okně pitelnosti | po okne pitnosti | nakon prozora | po oknu pitnosti | след прозореца | после прозора | після вікна |
| confidence | pewność | spolehlivost | spoľahlivosť | pouzdanost | zanesljivost | сигурност | поузданост | надійність |
| drink (record) | wypita butelka | vypitá láhev | vypitá fľaša | popijena boca | popita steklenica | изпита бутилка | попијена боца | випита пляшка |
| I drank one | Wypita | Vypito | Vypité | Popijeno | Popito | Изпих една | Попијено | Випито |
| rating | ocena | hodnocení | hodnotenie | ocjena | ocena | оценка | оцена | оцінка |
| pairing | łączenie z potrawami (titolo: Pasuje do) | párování s jídlem | párovanie s jedlom | sljubljivanje s hranom | ujemanje s hrano | съчетание | слагање с храном | поєднання |
| dried fruit (pairing) | bakalie | ořechy a sušené ovoce | orechy a sušené ovocie | orašasti plodovi i suho voće | oreščki in suho sadje | ядки и сушени плодове | орашасти плодови и сушено воће | горіхи та сухофрукти |
| sharing | udostępnianie | sdílení | zdieľanie | dijeljenje | deljenje | споделяне | дељење | спільний доступ |
| owner | właściciel | vlastník | vlastník | vlasnik | lastnik | собственик | власник | власник |
| plan | plan | tarif | plán | plan | paket | план | план | план |
| free plan | plan bezpłatny | bezplatný tarif | bezplatný plán | besplatni plan | brezplačni paket | безплатен план | бесплатан план | безплатний план |
| subscription | subskrypcja | předplatné | predplatné | pretplata | naročnina | абонамент | претплата | підписка |
| sync | synchronizacja | synchronizace | synchronizácia | sinkronizacija | sinhronizacija | синхронизиране | синхронизација | синхронізація |
| wine database | baza win | databáze vín | databáza vín | baza vina | zbirka vin | база данни за вина | база вина | база вин |

### Greco, georgiano, ungherese, finlandese

| Termine (en) | `el` | `ka` | `hu` | `fi` |
|---|---|---|---|---|
| cellar | κάβα | მარანი | pince | kellari (testi dello store: viinikellari) |
| bottle | φιάλη | ბოთლი | palack (singolare dopo un numero: 5 palack) | pullo (1 pullo, 5 pulloa) |
| wine | κρασί | ღვინო | bor | viini |
| producer | παραγωγός | მწარმოებელი | termelő | tuottaja |
| dashboard | Επισκόπηση | მიმოხილვა | Áttekintés | Yleiskuva |
| History | Ιστορικό | ისტორია | Előzmények | Historia |
| vintage | χρονιά | მოსავლის წელი | évjárat | vuosikerta |
| grape | ποικιλία | ყურძნის ჯიში | szőlőfajta | rypälelajike |
| appellation | ονομασία προέλευσης | ადგილწარმოშობა | eredetmegjelölés | appellaatio |
| label | ετικέτα | ეტიკეტი | címke | etiketti |
| type | τύπος | ტიპი | típus | tyyppi |
| style | στιλ | სტილი | stílus | tyyli |
| level | επίπεδο | დონე | szint | taso |
| red | ερυθρό | წითელი | vörös | punaviini |
| white | λευκό | თეთრი | fehér | valkoviini |
| rosé | ροζέ | ვარდისფერი | rozé | roseeviini |
| sparkling | αφρώδες | ცქრიალა | pezsgő | kuohuviini |
| sweet | γλυκό | ტკბილი | édes | makea |
| fortified | ενισχυμένο | შემაგრებული | erősített | väkevöity |
| classic method | παραδοσιακή μέθοδος | კლასიკური მეთოდი | tradicionális pezsgő | perinteinen menetelmä |
| tank method | μέθοδος δεξαμενής | რეზერვუარული მეთოდი | tankpezsgő | tankkimenetelmä |
| dried-grape | λιαστό | Passito (profilo: შემჭკნარი ყურძნისგან) | töppedt szőlőből | kuivatuista rypäleistä |
| botrytised | ευγενής σήψη | ბოტრიტისიანი | aszúsodott | jalohomeinen |
| for ageing | για παλαίωση | დასაძველებელი | érlelhető | kellaroitava |
| disgorgement | ντεγκορζάρισμα | დეგორჟაჟი | degorzsálás | degorgointi |
| bottling | εμφιάλωση | ჩამოსხმა | palackozás | pullotus |
| estimate | εκτίμηση | პროგნოზი | becslés | arvio |
| drinking window | παράθυρο κατανάλωσης (breve: παράθυρο) | დალევის პერიოდი (breve: პერიოდი) | ivási ablak | juonti-ikkuna |
| peak | κορύφωση | პიკი | csúcs | huippu |
| ready | έτοιμες | მზადაა | iható | valmis |
| drink soon | να πιωθούν σύντομα | მალე დასალევი | idd meg hamar | juo pian |
| to wait | σε αναμονή | მოსაცდელი | várni kell | odota |
| past the window | εκτός παραθύρου | პერიოდი გასულია | ablakon túl | ikkuna ohi |
| confidence | αξιοπιστία | სანდოობა | megbízhatóság | luotettavuus |
| drink (record) | κατανάλωση | დალეული ბოთლი | kóstolás | maistelu |
| I drank one | Ήπια μία | დავლიე | Megittam egyet | Join yhden |
| rating | βαθμολογία | შეფასება | értékelés | arvosana |
| pairing | συνδυασμός | შეხამება | párosítás | ruokapari |
| dried fruit (pairing) | ξηροί καρποί | თხილეული და ჩირი | diófélék és aszalt gyümölcs | pähkinät ja kuivatut hedelmät |
| sharing | κοινή χρήση | გაზიარება | megosztás | jakaminen |
| owner | κάτοχος | მფლობელი | tulajdonos | omistaja |
| plan | πρόγραμμα | გეგმა | csomag | paketti |
| free plan | δωρεάν πρόγραμμα | უფასო გეგმა | ingyenes csomag | ilmaispaketti |
| subscription | συνδρομή | გამოწერა | előfizetés | tilaus |
| sync | συγχρονισμός | სინქრონიზაცია | szinkronizálás | synkronointi |
| wine database | βάση κρασιών | ღვინოების ბაზა | boradatbázis | viinitietokanta |

### Note per lingua

- **Forma di cortesia**: `fr` vous; `es`, `ca` tú; `pt` terza persona formale senza "você"; `de`, `nl` (je), `da`, `sv`, `nb` du; `pl` tu; `cs`, `sk`, `hr`, `sl` voi; `hu` tu; per `ro`, `bg`, `sr`, `uk`, `el`, `ka`, `fi` vale quello che usano già i file ARB.
- **Ceco, slovacco, polacco, serbo, ucraino**: le frasi al passato riferite a chi usa l'app sono impersonali ("Vypito", "Попијено"), perché il participio dipende dal genere.
- **Georgiano**: dopo un numero il nome resta al singolare (5 ბოთლი); le desinenze si attaccano ai nomi non tradotti con un trattino (Google-ით).
- **Piano e abbonamento**: dove la lingua usa la stessa parola per le due cose, il piano ha una parola sua e l'abbonamento a pagamento di Google Play tiene l'altra: `nl` pakket / abonnement, `da` e `nb` pakke / abonnement, `fi` paketti / tilaus ("Plus-tilaus" resta, perché Plus è l'abbonamento di Google Play).
- **Termini non tradotti in più**: oltre all'elenco qui sopra, i traduttori hanno lasciato in originale `Prosecco`, `Bardolino`, `Vinho Verde`, `Chianti Classico`, `Amarone`, `Brunello`, `Amontillado`, `Oloroso`, `Cream`, `Pedro Ximénez`, `Madeira`, `DbCL`, `eAmbrosia`, `Android`, `Bottazzini Softworks`. In francese "Sherry" è `Xérès` e "Port" è `Porto`, come nell'uso del vino in Francia.
