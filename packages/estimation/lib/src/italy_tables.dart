// Hand-written Italian rows added by label-autofill-windows (D2, BR3.6,
// owner decision 94dc0883): every DOCG of the 2024 register that the 47 rows
// of tables.dart do not already cover, and the main DOCs. Offsets count from
// the vintage, as in tables.dart.
//
// Values are wine knowledge decided by the team (project.md correction of
// 2026-11-04): the minimum ageing of the production rules plus the typical
// bottle evolution of an average vintage. Each family has its reason above
// it; a correction is a code change with its per-row test
// (test/world_tables_test.dart).

import 'models.dart';
import 'tables.dart';

typedef _D = DenominationProfile;
typedef _Y = YearOffsets;

const _rl = WineType.redLight;
const _rs = WineType.redStructured;
const _w = WineType.white;
const _ro = WineType.rose;
const _spc = WineType.sparklingClassic;
const _spt = WineType.sparklingTank;
const _sw = WineType.sweet;
const _fo = WineType.fortified;

/// The Italian dedicated rows of label-autofill-windows.
const List<DenominationProfile> italianWorldDenominations = [
  // Piemonte, Langhe and Roero. Alta Langa rests at least 30 months on the
  // lees, so it keeps longer than most classic-method wines; Roero is
  // Nebbiolo on sand, softer than Barolo; Arneis and the Langhe whites are
  // fresh wines.
  _D.world(
    'IT',
    'Piemonte',
    'Alta Langa',
    _spc,
    _Y(2, 4, 8),
    qualifierOffsets: {Qualifier.riserva: _Y(3, 6, 12)},
  ),
  _D.world(
    'IT',
    'Piemonte',
    'Roero',
    _rs,
    _Y(3, 6, 12),
    qualifierOffsets: {Qualifier.riserva: _Y(5, 8, 15)},
  ),
  _D.world('IT', 'Piemonte', 'Roero Arneis', _w, _Y(0, 2, 4)),
  _D.world(
    'IT',
    'Piemonte',
    'Langhe',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(0, 2, 4)},
    weakAliases: ['langhe'],
  ),
  _D.world(
    'IT',
    'Piemonte',
    'Dogliani',
    _rl,
    _Y(1, 3, 6),
    aliases: ['dolcetto di dogliani'],
    qualifierOffsets: {Qualifier.superiore: _Y(2, 4, 8)},
  ),
  _D.world(
    'IT',
    'Piemonte',
    "Diano d'Alba",
    _rl,
    _Y(1, 2, 5),
    aliases: ['dolcetto di diano d alba'],
  ),
  _D.world(
    'IT',
    'Piemonte',
    'Ovada',
    _rl,
    _Y(2, 4, 8),
    aliases: ['dolcetto di ovada'],
  ),
  _D.world(
    'IT',
    'Piemonte',
    'Terre Alfieri',
    _w,
    _Y(1, 2, 5),
    otherTypes: {_rs: _Y(3, 6, 12)},
  ),
  // Piemonte, Monferrato and Asti. Barbera Superiore ages in wood and lasts
  // a decade; Grignolino, Freisa and Ruchè are light reds for early
  // drinking; Brachetto and the Canelli Moscato are sweet and fragrant, best
  // within two or three years.
  _D.world(
    'IT',
    'Piemonte',
    'Barbera del Monferrato Superiore',
    _rs,
    _Y(3, 6, 12),
  ),
  _D.world('IT', 'Piemonte', 'Barbera del Monferrato', _rl, _Y(1, 3, 6)),
  _D.world(
    'IT',
    'Piemonte',
    'Monferrato',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(0, 2, 4)},
    weakAliases: ['monferrato'],
  ),
  _D.world(
    'IT',
    'Piemonte',
    'Ruchè di Castagnole Monferrato',
    _rl,
    _Y(1, 3, 6),
    aliases: ['ruche'],
  ),
  _D.world(
    'IT',
    'Piemonte',
    "Grignolino d'Asti",
    _rl,
    _Y(0, 2, 4),
    aliases: ['grignolino', 'grignolino del monferrato casalese'],
  ),
  _D.world(
    'IT',
    'Piemonte',
    "Freisa d'Asti",
    _rl,
    _Y(1, 3, 6),
    aliases: ['freisa'],
  ),
  _D.world(
    'IT',
    'Piemonte',
    "Brachetto d'Acqui",
    _sw,
    _Y(0, 1, 2),
    aliases: ['acqui'],
  ),
  _D.world('IT', 'Piemonte', 'Canelli', _sw, _Y(0, 1, 3)),
  _D.world('IT', 'Piemonte', 'Loazzolo', _sw, _Y(3, 8, 20)),
  _D.world(
    'IT',
    'Piemonte',
    'Malvasia di Castelnuovo Don Bosco',
    _sw,
    _Y(0, 1, 2),
  ),
  // Piemonte north: Erbaluce is a sharp white that keeps well; its passito
  // lasts decades; the Nebbiolo of the Alto Piemonte (Carema, Boca,
  // Lessona...) is leaner than Barolo but long-lived.
  _D.world('IT', 'Piemonte', 'Erbaluce di Caluso', _w, _Y(1, 3, 6)),
  _D.world('IT', 'Piemonte', 'Caluso Passito', _sw, _Y(4, 10, 25)),
  _D.world('IT', 'Piemonte', 'Carema', _rs, _Y(4, 8, 18)),
  _D.world('IT', 'Piemonte', 'Boca', _rs, _Y(4, 8, 15), weakAliases: ['boca']),
  _D.world('IT', 'Piemonte', 'Bramaterra', _rs, _Y(3, 7, 14)),
  _D.world('IT', 'Piemonte', 'Lessona', _rs, _Y(4, 8, 16)),
  _D.world('IT', 'Piemonte', 'Fara', _rs, _Y(3, 6, 12), weakAliases: ['fara']),
  _D.world('IT', 'Piemonte', 'Sizzano', _rs, _Y(3, 6, 12)),
  // Lombardia: Oltrepò classic method rests 15 months at least; Bonarda,
  // Buttafuoco and Sangue di Giuda are lively reds, the last one sweet;
  // Moscato di Scanzo is a dried-grape red that keeps for decades.
  _D.world(
    'IT',
    'Lombardia',
    'Oltrepò Pavese Metodo Classico',
    _spc,
    _Y(1, 3, 7),
  ),
  _D.world(
    'IT',
    'Lombardia',
    'Oltrepò Pavese',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(0, 2, 4)},
  ),
  _D.world('IT', 'Lombardia', "Bonarda dell'Oltrepò Pavese", _rl, _Y(0, 1, 3)),
  _D.world('IT', 'Lombardia', 'Buttafuoco', _rs, _Y(2, 5, 10)),
  _D.world('IT', 'Lombardia', 'Sangue di Giuda', _sw, _Y(0, 1, 2)),
  _D.world(
    'IT',
    'Lombardia',
    'Moscato di Scanzo',
    _sw,
    _Y(3, 8, 20),
    aliases: ['scanzo'],
  ),
  _D.world(
    'IT',
    'Lombardia',
    'Rosso di Valtellina',
    _rl,
    _Y(2, 4, 8),
    aliases: ['valtellina rosso'],
  ),
  _D.world(
    'IT',
    'Lombardia',
    'Curtefranca',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(0, 2, 4)},
  ),
  _D.world('IT', 'Lombardia', 'Valcalepio', _rl, _Y(2, 4, 8)),
  _D.world('IT', 'Lombardia', 'Botticino', _rl, _Y(2, 4, 8)),
  _D.world('IT', 'Lombardia', 'San Colombano', _rl, _Y(1, 2, 5)),
  _D.world(
    'IT',
    'Lombardia',
    'Valtènesi',
    _ro,
    _Y(0, 1, 2),
    aliases: ['riviera del garda classico'],
  ),
  // Veneto, Garda and the Venetian plain: Bardolino and Custoza are fresh
  // and early; the Superiore and the Colli di Conegliano reds hold longer;
  // Raboso (Friularo, Malanotte) is tannic and needs years; the Recioto
  // are dried-grape sweet wines that keep for decades.
  _D.world('IT', 'Veneto', 'Bardolino', _rl, _Y(0, 2, 4)),
  _D.world('IT', 'Veneto', 'Bardolino Superiore', _rl, _Y(1, 3, 6)),
  _D.world(
    'IT',
    'Veneto',
    'Chiaretto di Bardolino',
    _ro,
    _Y(0, 1, 2),
    aliases: ['bardolino chiaretto'],
  ),
  _D.world(
    'IT',
    'Veneto',
    'Custoza',
    _w,
    _Y(0, 2, 4),
    aliases: ['bianco di custoza'],
  ),
  _D.world(
    'IT',
    'Veneto',
    'Garda',
    _rl,
    _Y(1, 2, 4),
    otherTypes: {_w: _Y(0, 1, 3)},
    weakAliases: ['garda'],
  ),
  _D.world(
    'IT',
    'Veneto',
    'Asolo Prosecco',
    _spt,
    _Y(0, 1, 3),
    aliases: ['colli asolani prosecco'],
  ),
  _D.world(
    'IT',
    'Veneto',
    'Colli di Conegliano',
    _rs,
    _Y(3, 6, 12),
    otherTypes: {_w: _Y(1, 3, 6)},
  ),
  _D.world(
    'IT',
    'Veneto',
    "Colli Euganei Fior d'Arancio",
    _sw,
    _Y(0, 2, 4),
    aliases: ['fior d arancio'],
  ),
  _D.world('IT', 'Veneto', 'Colli Euganei', _rl, _Y(1, 3, 6)),
  _D.world('IT', 'Veneto', 'Colli Berici', _rl, _Y(1, 3, 6)),
  _D.world(
    'IT',
    'Veneto',
    'Bagnoli Friularo',
    _rs,
    _Y(3, 6, 12),
    aliases: ['friularo di bagnoli', 'friularo'],
  ),
  _D.world('IT', 'Veneto', 'Lison', _w, _Y(1, 2, 5)),
  _D.world('IT', 'Veneto', 'Lison-Pramaggiore', _rl, _Y(1, 3, 6)),
  _D.world(
    'IT',
    'Veneto',
    'Montello Rosso',
    _rs,
    _Y(3, 6, 12),
    aliases: ['montello'],
  ),
  _D.world(
    'IT',
    'Veneto',
    'Piave Malanotte',
    _rs,
    _Y(4, 8, 15),
    aliases: ['malanotte del piave', 'malanotte'],
  ),
  _D.world('IT', 'Veneto', 'Piave', _rl, _Y(1, 3, 6), weakAliases: ['piave']),
  _D.world('IT', 'Veneto', 'Recioto di Gambellara', _sw, _Y(3, 8, 20)),
  _D.world('IT', 'Veneto', 'Gambellara', _w, _Y(0, 2, 4)),
  _D.world('IT', 'Veneto', 'Recioto di Soave', _sw, _Y(3, 8, 20)),
  _D.world(
    'IT',
    'Veneto',
    'Lessini Durello',
    _spc,
    _Y(1, 3, 6),
    aliases: ['durello', 'monti lessini'],
  ),
  _D.world(
    'IT',
    'Veneto',
    'Breganze',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(0, 2, 4)},
  ),
  _D.world(
    'IT',
    'Veneto',
    'Breganze Torcolato',
    _sw,
    _Y(4, 10, 25),
    aliases: ['torcolato'],
  ),
  _D.world(
    'IT',
    'Veneto',
    'Valdadige',
    _w,
    _Y(0, 2, 4),
    otherTypes: {_rl: _Y(1, 2, 4)},
  ),
  // Friuli-Venezia Giulia: the Collio and Colli Orientali whites have body
  // and keep 6-8 years; Rosazzo is their selection; Picolit and Ramandolo
  // are late-harvest sweet wines; the plain (Grave, Isonzo) gives fresher
  // wines.
  _D.world(
    'IT',
    'Friuli-Venezia Giulia',
    'Colli Orientali del Friuli Picolit',
    _sw,
    _Y(3, 8, 20),
    aliases: ['picolit'],
  ),
  _D.world('IT', 'Friuli-Venezia Giulia', 'Ramandolo', _sw, _Y(3, 8, 20)),
  _D.world('IT', 'Friuli-Venezia Giulia', 'Rosazzo', _w, _Y(2, 4, 10)),
  _D.world(
    'IT',
    'Friuli-Venezia Giulia',
    'Collio',
    _w,
    _Y(1, 3, 8),
    aliases: ['collio goriziano'],
    otherTypes: {_rs: _Y(3, 6, 12)},
  ),
  _D.world(
    'IT',
    'Friuli-Venezia Giulia',
    'Friuli Colli Orientali',
    _w,
    _Y(1, 3, 7),
    aliases: ['colli orientali del friuli'],
    otherTypes: {_rl: _Y(2, 5, 10)},
  ),
  _D.world(
    'IT',
    'Friuli-Venezia Giulia',
    'Friuli Grave',
    _w,
    _Y(0, 2, 4),
    aliases: ['grave del friuli'],
    otherTypes: {_rl: _Y(1, 2, 5)},
  ),
  _D.world(
    'IT',
    'Friuli-Venezia Giulia',
    'Friuli Isonzo',
    _w,
    _Y(1, 2, 5),
    aliases: ['isonzo del friuli', 'isonzo'],
  ),
  _D.world(
    'IT',
    'Friuli-Venezia Giulia',
    'Carso',
    _w,
    _Y(1, 3, 6),
    otherTypes: {_rl: _Y(1, 3, 6)},
  ),
  // Trentino-Alto Adige: mountain whites with high acidity; Terlano is the
  // longest-lived of them; Santa Maddalena and Caldaro are Schiava, light
  // reds for early drinking.
  _D.world(
    'IT',
    'Trentino-Alto Adige',
    'Alto Adige',
    _w,
    _Y(1, 3, 6),
    aliases: ['sudtirol', 'sudtiroler'],
    otherTypes: {_rl: _Y(1, 3, 6)},
    weakAliases: ['alto adige', 'sudtirol', 'sudtiroler'],
  ),
  _D.world(
    'IT',
    'Trentino-Alto Adige',
    'Santa Maddalena',
    _rl,
    _Y(0, 2, 4),
    aliases: ['st magdalener', 'sankt magdalener'],
  ),
  _D.world(
    'IT',
    'Trentino-Alto Adige',
    'Lago di Caldaro',
    _rl,
    _Y(0, 1, 3),
    aliases: ['caldaro', 'kalterersee', 'kalterer see'],
  ),
  _D.world(
    'IT',
    'Trentino-Alto Adige',
    'Terlano',
    _w,
    _Y(2, 5, 12),
    aliases: ['terlaner'],
  ),
  _D.world(
    'IT',
    'Trentino-Alto Adige',
    'Valle Isarco',
    _w,
    _Y(1, 3, 7),
    aliases: ['eisacktal', 'eisacktaler'],
  ),
  _D.world(
    'IT',
    'Trentino-Alto Adige',
    'Trentino',
    _w,
    _Y(0, 2, 4),
    otherTypes: {_rl: _Y(1, 2, 5)},
    weakAliases: ['trentino'],
  ),
  // Emilia-Romagna: Pignoletto is a fresh white; Albana is the first white
  // DOCG, with body, also made as passito; Romagna Sangiovese is a medium
  // red; Gutturnio is the Barbera-Bonarda red of the Piacenza hills.
  _D.world(
    'IT',
    'Emilia-Romagna',
    'Colli Bolognesi Classico Pignoletto',
    _w,
    _Y(0, 2, 4),
    aliases: ['pignoletto', 'colli bolognesi pignoletto'],
  ),
  _D.world(
    'IT',
    'Emilia-Romagna',
    'Romagna Albana',
    _w,
    _Y(1, 3, 6),
    aliases: ['albana di romagna', 'albana'],
    otherTypes: {_sw: _Y(3, 8, 20)},
  ),
  _D.world(
    'IT',
    'Emilia-Romagna',
    'Romagna Sangiovese',
    _rl,
    _Y(1, 3, 6),
    aliases: ['sangiovese di romagna'],
    qualifierOffsets: {Qualifier.riserva: _Y(3, 5, 10)},
  ),
  _D.world('IT', 'Emilia-Romagna', 'Gutturnio', _rl, _Y(1, 3, 6)),
  // Toscana: Carmignano (Sangiovese with Cabernet) and Suvereto age like a
  // Chianti Classico Riserva; Morellino and the Montecucco DOC are rounder
  // and earlier; Vernaccia is the long-lived white of San Gimignano;
  // Sassicaia is a Cabernet that keeps for decades.
  _D.world(
    'IT',
    'Toscana',
    'Carmignano',
    _rs,
    _Y(4, 8, 15),
    qualifierOffsets: {Qualifier.riserva: _Y(5, 10, 20)},
  ),
  _D.world('IT', 'Toscana', 'Barco Reale di Carmignano', _rl, _Y(1, 2, 5)),
  _D.world(
    'IT',
    'Toscana',
    "Aleatico Passito dell'Elba",
    _sw,
    _Y(3, 8, 20),
    aliases: ['elba aleatico passito'],
  ),
  _D.world(
    'IT',
    'Toscana',
    'Montecucco Sangiovese',
    _rs,
    _Y(3, 6, 12),
    qualifierOffsets: {Qualifier.riserva: _Y(5, 8, 15)},
  ),
  _D.world('IT', 'Toscana', 'Montecucco', _rl, _Y(1, 3, 6)),
  _D.world(
    'IT',
    'Toscana',
    'Morellino di Scansano',
    _rl,
    _Y(1, 3, 6),
    aliases: ['morellino'],
    qualifierOffsets: {Qualifier.riserva: _Y(3, 6, 12)},
  ),
  _D.world('IT', 'Toscana', 'Suvereto', _rs, _Y(4, 8, 15)),
  _D.world(
    'IT',
    'Toscana',
    'Val di Cornia Rosso',
    _rs,
    _Y(3, 6, 12),
    aliases: ['rosso della val di cornia'],
  ),
  _D.world(
    'IT',
    'Toscana',
    'Vernaccia di San Gimignano',
    _w,
    _Y(1, 3, 6),
    qualifierOffsets: {Qualifier.riserva: _Y(2, 5, 10)},
  ),
  _D.world('IT', 'Toscana', 'Rosso di Montepulciano', _rl, _Y(1, 3, 6)),
  _D.world(
    'IT',
    'Toscana',
    'Bolgheri Sassicaia',
    _rs,
    _Y(8, 15, 30),
    aliases: ['sassicaia'],
  ),
  _D.world(
    'IT',
    'Toscana',
    'Maremma Toscana',
    _rl,
    _Y(1, 3, 6),
    aliases: ['maremma'],
    otherTypes: {_w: _Y(0, 2, 4)},
    weakAliases: ['maremma'],
  ),
  _D.world(
    'IT',
    'Toscana',
    'Pomino',
    _rl,
    _Y(2, 4, 8),
    otherTypes: {_w: _Y(1, 3, 6)},
  ),
  _D.world('IT', 'Toscana', 'Orcia', _rl, _Y(2, 4, 8)),
  _D.world(
    'IT',
    'Toscana',
    'Cortona',
    _rl,
    _Y(2, 4, 8),
    weakAliases: ['cortona'],
  ),
  // Umbria: Torgiano Rosso Riserva rests three years before sale; Montefalco
  // Rosso is the softer Sangiovese-Sagrantino blend; Orvieto is a fresh
  // white.
  _D.world('IT', 'Umbria', 'Torgiano Rosso Riserva', _rs, _Y(5, 10, 20)),
  _D.world('IT', 'Umbria', 'Torgiano', _rl, _Y(1, 3, 6)),
  _D.world('IT', 'Umbria', 'Montefalco Rosso', _rl, _Y(2, 5, 10)),
  _D.world(
    'IT',
    'Umbria',
    'Orvieto',
    _w,
    _Y(0, 2, 4),
    aliases: ['orvieto classico'],
  ),
  // Marche: Conero (Montepulciano Riserva) and Offida are structured reds;
  // Verdicchio di Matelica is a mountain white that ages; Lacrima and the
  // Rosso Piceno are lighter reds.
  _D.world('IT', 'Marche', 'Conero', _rs, _Y(4, 8, 15)),
  _D.world('IT', 'Marche', 'Rosso Conero', _rl, _Y(2, 4, 8)),
  _D.world(
    'IT',
    'Marche',
    'Offida',
    _rs,
    _Y(3, 6, 12),
    otherTypes: {_w: _Y(1, 3, 6)},
  ),
  _D.world(
    'IT',
    'Marche',
    'Verdicchio di Matelica',
    _w,
    _Y(1, 3, 8),
    qualifierOffsets: {Qualifier.riserva: _Y(3, 6, 12)},
  ),
  _D.world('IT', 'Marche', 'Vernaccia di Serrapetrona', _spt, _Y(0, 2, 4)),
  _D.world(
    'IT',
    'Marche',
    'Rosso Piceno',
    _rl,
    _Y(1, 3, 6),
    qualifierOffsets: {Qualifier.superiore: _Y(2, 5, 10)},
  ),
  _D.world(
    'IT',
    'Marche',
    "Lacrima di Morro d'Alba",
    _rl,
    _Y(0, 2, 4),
    aliases: ['lacrima di morro'],
  ),
  // Lazio: Frascati is a fresh white, Cannellino its sweet version;
  // Cesanese del Piglio is a medium red.
  _D.world('IT', 'Lazio', 'Frascati', _w, _Y(0, 2, 4)),
  _D.world('IT', 'Lazio', 'Cannellino di Frascati', _sw, _Y(1, 3, 6)),
  _D.world(
    'IT',
    'Lazio',
    'Cesanese del Piglio',
    _rl,
    _Y(2, 4, 8),
    aliases: ['piglio'],
  ),
  _D.world(
    'IT',
    'Lazio',
    'Est! Est!! Est!!! di Montefiascone',
    _w,
    _Y(0, 1, 3),
    aliases: ['est est est'],
  ),
  // Abruzzo and Molise: Colline Teramane is the selected Montepulciano,
  // longer-lived than the DOC; Cerasuolo is its rosé; Tullum and Tintilia
  // are medium reds.
  _D.world(
    'IT',
    'Abruzzo',
    "Montepulciano d'Abruzzo Colline Teramane",
    _rs,
    _Y(4, 7, 15),
    aliases: ['colline teramane'],
  ),
  _D.world(
    'IT',
    'Abruzzo',
    'Terre Tollesi',
    _rl,
    _Y(2, 4, 8),
    aliases: ['tullum'],
  ),
  _D.world('IT', 'Abruzzo', "Cerasuolo d'Abruzzo", _ro, _Y(0, 1, 2)),
  _D.world(
    'IT',
    'Molise',
    'Tintilia del Molise',
    _rl,
    _Y(1, 3, 6),
    aliases: ['tintilia'],
  ),
  _D.world('IT', 'Molise', 'Biferno', _rl, _Y(1, 3, 6)),
  // Campania: Aglianico del Taburno is close to Taurasi; Falanghina, Campi
  // Flegrei and Costa d'Amalfi are coastal whites to drink within a few
  // years; Lacryma Christi is the light wine of the Vesuvius.
  _D.world(
    'IT',
    'Campania',
    'Aglianico del Taburno',
    _rs,
    _Y(4, 8, 15),
    aliases: ['taburno'],
    qualifierOffsets: {Qualifier.riserva: _Y(5, 10, 20)},
  ),
  _D.world(
    'IT',
    'Campania',
    'Falanghina del Sannio',
    _w,
    _Y(0, 2, 4),
    aliases: ['sannio falanghina'],
  ),
  _D.world(
    'IT',
    'Campania',
    'Sannio',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(0, 2, 4)},
    weakAliases: ['sannio'],
  ),
  _D.world(
    'IT',
    'Campania',
    'Irpinia',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(0, 2, 5)},
    weakAliases: ['irpinia'],
  ),
  _D.world(
    'IT',
    'Campania',
    'Lacryma Christi del Vesuvio',
    _rl,
    _Y(0, 2, 4),
    aliases: ['lacryma christi', 'vesuvio'],
    otherTypes: {_w: _Y(0, 2, 4)},
  ),
  _D.world(
    'IT',
    'Campania',
    'Campi Flegrei',
    _w,
    _Y(0, 2, 4),
    otherTypes: {_rl: _Y(1, 2, 5)},
  ),
  _D.world("IT", 'Campania', "Costa d'Amalfi", _w, _Y(1, 2, 5)),
  // Puglia: the Castel del Monte DOCGs (Nero di Troia, Rosso Riserva) are
  // structured reds, Bombino Nero a rosé; Salice Salentino and Gioia del
  // Colle (Primitivo) are warm reds for 5-10 years; the sweet Primitivo
  // keeps longer.
  _D.world('IT', 'Puglia', 'Castel del Monte Nero di Troia', _rs, _Y(4, 8, 15)),
  _D.world('IT', 'Puglia', 'Castel del Monte Rosso Riserva', _rs, _Y(4, 7, 14)),
  _D.world('IT', 'Puglia', 'Castel del Monte Bombino Nero', _ro, _Y(0, 1, 3)),
  _D.world(
    'IT',
    'Puglia',
    'Castel del Monte',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(0, 1, 3), _ro: _Y(0, 1, 2)},
  ),
  _D.world(
    'IT',
    'Puglia',
    'Primitivo di Manduria Dolce Naturale',
    _sw,
    _Y(2, 6, 15),
  ),
  _D.world(
    'IT',
    'Puglia',
    'Salice Salentino',
    _rl,
    _Y(2, 4, 8),
    qualifierOffsets: {Qualifier.riserva: _Y(3, 6, 12)},
  ),
  _D.world('IT', 'Puglia', 'Gioia del Colle', _rs, _Y(2, 5, 10)),
  _D.world(
    'IT',
    'Puglia',
    'Brindisi',
    _rl,
    _Y(2, 4, 8),
    weakAliases: ['brindisi'],
  ),
  _D.world('IT', 'Puglia', 'Copertino', _rl, _Y(2, 4, 8)),
  // Calabria: Cirò is the Gaglioppo red, tannic; Greco di Bianco a
  // dried-grape sweet wine.
  _D.world(
    'IT',
    'Calabria',
    'Cirò',
    _rl,
    _Y(2, 4, 8),
    otherTypes: {_w: _Y(0, 1, 3), _ro: _Y(0, 1, 2)},
    qualifierOffsets: {Qualifier.riserva: _Y(3, 6, 12)},
  ),
  _D.world('IT', 'Calabria', 'Greco di Bianco', _sw, _Y(3, 8, 20)),
  // Sicilia: Cerasuolo di Vittoria (Nero d'Avola and Frappato) is a medium
  // red; Faro is a small, structured red of Messina; Malvasia delle Lipari
  // is a sweet wine that keeps; the Sicilia DOC and Noto are broad, early
  // areas.
  _D.world('IT', 'Sicilia', 'Cerasuolo di Vittoria', _rl, _Y(2, 4, 8)),
  _D.world(
    'IT',
    'Sicilia',
    'Vittoria',
    _rl,
    _Y(1, 3, 6),
    weakAliases: ['vittoria'],
  ),
  _D.world(
    'IT',
    'Sicilia',
    'Sicilia',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(0, 2, 4)},
    weakAliases: ['sicilia'],
  ),
  _D.world('IT', 'Sicilia', 'Malvasia delle Lipari', _sw, _Y(2, 6, 15)),
  _D.world('IT', 'Sicilia', 'Faro', _rs, _Y(3, 6, 12), weakAliases: ['faro']),
  _D.world('IT', 'Sicilia', 'Noto', _rl, _Y(2, 4, 8), weakAliases: ['noto']),
  // Sardegna: Vermentino di Sardegna and Nuragus are fresh whites;
  // Carignano del Sulcis is a warm red; Vernaccia di Oristano ages under
  // flor like a sherry and keeps for decades.
  _D.world('IT', 'Sardegna', 'Vermentino di Sardegna', _w, _Y(0, 2, 4)),
  _D.world(
    'IT',
    'Sardegna',
    'Carignano del Sulcis',
    _rl,
    _Y(2, 4, 8),
    qualifierOffsets: {Qualifier.riserva: _Y(3, 6, 12)},
  ),
  _D.world('IT', 'Sardegna', 'Monica di Sardegna', _rl, _Y(0, 2, 4)),
  _D.world('IT', 'Sardegna', 'Nuragus di Cagliari', _w, _Y(0, 1, 3)),
  _D.world('IT', 'Sardegna', 'Vernaccia di Oristano', _fo, _Y(3, 10, 25)),
  // Liguria and Valle d'Aosta: coastal and mountain whites for early
  // drinking; Sciacchetrà is the dried-grape sweet wine of the Cinque
  // Terre; Rossese and Donnas are light reds.
  _D.world('IT', 'Liguria', 'Cinque Terre', _w, _Y(0, 2, 4)),
  _D.world(
    'IT',
    'Liguria',
    'Cinque Terre Sciacchetrà',
    _sw,
    _Y(3, 8, 20),
    aliases: ['sciacchetra'],
  ),
  _D.world(
    'IT',
    'Liguria',
    'Rossese di Dolceacqua',
    _rl,
    _Y(1, 3, 6),
    aliases: ['dolceacqua'],
  ),
  _D.world('IT', 'Liguria', 'Colli di Luni', _w, _Y(0, 2, 4)),
  _D.world(
    'IT',
    "Valle d'Aosta",
    "Valle d'Aosta",
    _rl,
    _Y(1, 3, 6),
    aliases: ['vallee d aoste'],
    otherTypes: {_w: _Y(0, 2, 5)},
    weakAliases: ['valle d aosta', 'vallee d aoste'],
  ),
  _D.world("IT", "Valle d'Aosta", 'Donnas', _rl, _Y(2, 4, 8)),
];
