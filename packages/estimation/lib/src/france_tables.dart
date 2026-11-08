// Hand-written French rows (label-autofill-windows D2, BR3.6, world-tables.md
// "Francia", owner decision 94dc0883): the crus and communal AOCs of
// Bordeaux, Burgundy, the Rhône, the Loire and Alsace, Champagne, and the
// main AOCs of the other regions. The rows of world-tables.md that listed
// several AOCs under one key are written one per AOC with the same values,
// so the detail can name the AOC the estimate comes from.
//
// Values are wine knowledge decided by the team (project.md correction of
// 2026-11-04), with the reason of each family above it.

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

const _bdx = 'Bordeaux';
const _bgn = 'Bourgogne';
const _bjl = 'Beaujolais';
const _rho = 'Vallée du Rhône';
const _loi = 'Vallée de la Loire';

/// Grand cru classé offsets of the Médoc communes and of Saint-Émilion.
const _gcc = {Qualifier.grandCru: _Y(10, 18, 35)};

/// Côte de Nuits: village 5/10/20, premier cru 6/12/22, grand cru 8/15/30.
const _nuits = {
  Qualifier.premierCru: _Y(6, 12, 22),
  Qualifier.grandCru: _Y(8, 15, 30),
};

/// Côte de Beaune reds: premier cru 5/10/18, grand cru 7/12/25.
const _beaune = {
  Qualifier.premierCru: _Y(5, 10, 18),
  Qualifier.grandCru: _Y(7, 12, 25),
};

/// Côte de Beaune whites: premier cru 4/8/18, grand cru 5/10/25.
const _beauneBlanc = {
  Qualifier.premierCru: _Y(4, 8, 18),
  Qualifier.grandCru: _Y(5, 10, 25),
};

/// The French dedicated rows.
const List<DenominationProfile> frenchDenominations = [
  // Bordeaux, regional and right bank: tannic Merlot-Cabernet reds; plain
  // Bordeaux lasts about 10 years, the classified growths 30-40. The
  // satellites of Saint-Émilion and the Côtes are lighter than the
  // communes.
  _D.world(
    'FR',
    _bdx,
    'Bordeaux',
    _rs,
    _Y(2, 5, 10),
    key: 'bordeauxRouge',
    aliases: ['bordeaux superieur'],
    otherTypes: {_w: _Y(1, 2, 5), _ro: _Y(0, 1, 2)},
    weakAliases: ['bordeaux'],
  ),
  _D.world('FR', _bdx, 'Crémant de Bordeaux', _spc, _Y(1, 2, 5)),
  _D.world('FR', _bdx, 'Entre-Deux-Mers', _w, _Y(0, 2, 4)),
  _D.world('FR', _bdx, 'Côtes de Bordeaux', _rs, _Y(3, 6, 12)),
  _D.world(
    'FR',
    _bdx,
    'Blaye Côtes de Bordeaux',
    _rs,
    _Y(3, 6, 12),
    aliases: ['blaye', 'cotes de blaye'],
  ),
  _D.world(
    'FR',
    _bdx,
    'Castillon Côtes de Bordeaux',
    _rs,
    _Y(3, 6, 12),
    aliases: ['castillon'],
  ),
  _D.world('FR', _bdx, 'Francs Côtes de Bordeaux', _rs, _Y(3, 6, 12)),
  _D.world('FR', _bdx, 'Cadillac Côtes de Bordeaux', _rs, _Y(3, 6, 12)),
  _D.world('FR', _bdx, 'Côtes de Bourg', _rs, _Y(3, 6, 12)),
  _D.world(
    'FR',
    _bdx,
    'Saint-Émilion',
    _rs,
    _Y(5, 10, 20),
    aliases: ['st emilion'],
    qualifierOffsets: {Qualifier.grandCru: _Y(8, 15, 30)},
  ),
  _D.world('FR', _bdx, 'Lussac-Saint-Émilion', _rs, _Y(4, 8, 15)),
  _D.world('FR', _bdx, 'Montagne-Saint-Émilion', _rs, _Y(4, 8, 15)),
  _D.world('FR', _bdx, 'Puisseguin-Saint-Émilion', _rs, _Y(4, 8, 15)),
  _D.world('FR', _bdx, 'Saint-Georges-Saint-Émilion', _rs, _Y(4, 8, 15)),
  _D.world('FR', _bdx, 'Pomerol', _rs, _Y(6, 12, 25)),
  _D.world('FR', _bdx, 'Lalande-de-Pomerol', _rs, _Y(4, 8, 15)),
  _D.world('FR', _bdx, 'Fronsac', _rs, _Y(4, 8, 15)),
  _D.world('FR', _bdx, 'Canon-Fronsac', _rs, _Y(4, 8, 16)),
  // Bordeaux, left bank: the Médoc communes, Graves and Pessac-Léognan.
  _D.world('FR', _bdx, 'Médoc', _rs, _Y(5, 10, 20)),
  _D.world('FR', _bdx, 'Haut-Médoc', _rs, _Y(5, 10, 20)),
  _D.world(
    'FR',
    _bdx,
    'Listrac-Médoc',
    _rs,
    _Y(5, 10, 20),
    aliases: ['listrac'],
  ),
  _D.world(
    'FR',
    _bdx,
    'Moulis-en-Médoc',
    _rs,
    _Y(5, 10, 20),
    aliases: ['moulis'],
  ),
  _D.world(
    'FR',
    _bdx,
    'Pauillac',
    _rs,
    _Y(8, 15, 30),
    qualifierOffsets: {Qualifier.grandCru: _Y(10, 20, 40)},
  ),
  _D.world('FR', _bdx, 'Margaux', _rs, _Y(7, 14, 28), qualifierOffsets: _gcc),
  _D.world(
    'FR',
    _bdx,
    'Saint-Julien',
    _rs,
    _Y(7, 14, 28),
    aliases: ['st julien'],
    qualifierOffsets: _gcc,
  ),
  _D.world(
    'FR',
    _bdx,
    'Saint-Estèphe',
    _rs,
    _Y(8, 15, 30),
    aliases: ['st estephe'],
    qualifierOffsets: _gcc,
  ),
  _D.world(
    'FR',
    _bdx,
    'Pessac-Léognan',
    _rs,
    _Y(6, 12, 25),
    otherTypes: {_w: _Y(3, 8, 20)},
    qualifierOffsets: {Qualifier.grandCru: _Y(8, 15, 30)},
  ),
  _D.world(
    'FR',
    _bdx,
    'Graves',
    _rs,
    _Y(6, 12, 25),
    otherTypes: {_w: _Y(2, 5, 12)},
  ),
  // Bordeaux sweet wines: botrytis sugar and acidity keep Sauternes and
  // Barsac for 40 years; the right-bank sweet wines are lighter.
  _D.world('FR', _bdx, 'Sauternes', _sw, _Y(5, 15, 40)),
  _D.world('FR', _bdx, 'Barsac', _sw, _Y(5, 15, 40)),
  _D.world('FR', _bdx, 'Loupiac', _sw, _Y(3, 10, 25)),
  _D.world('FR', _bdx, 'Sainte-Croix-du-Mont', _sw, _Y(3, 10, 25)),
  _D.world('FR', _bdx, 'Cérons', _sw, _Y(3, 10, 25)),
  _D.world(
    'FR',
    _bdx,
    'Cadillac',
    _sw,
    _Y(3, 8, 20),
    weakAliases: ['cadillac'],
  ),
  // Burgundy, regional: Pinot Noir lasts less than Cabernet; Aligoté and
  // Passe-tout-grains are for early drinking; the Hautes-Côtes are the
  // cooler hills behind the Côte.
  _D.world(
    'FR',
    _bgn,
    'Bourgogne',
    _rl,
    _Y(2, 4, 8),
    otherTypes: {_w: _Y(1, 3, 6)},
    weakAliases: ['bourgogne'],
  ),
  _D.world(
    'FR',
    _bgn,
    'Bourgogne Rouge',
    _rl,
    _Y(2, 4, 8),
    aliases: ['bourgogne pinot noir'],
  ),
  _D.world(
    'FR',
    _bgn,
    'Bourgogne Blanc',
    _w,
    _Y(1, 3, 6),
    aliases: ['bourgogne chardonnay'],
  ),
  _D.world('FR', _bgn, 'Bourgogne Aligoté', _w, _Y(0, 2, 4)),
  _D.world(
    'FR',
    _bgn,
    'Bourgogne Passe-Tout-Grains',
    _rl,
    _Y(0, 2, 4),
    aliases: ['passe tout grains'],
  ),
  _D.world('FR', _bgn, 'Coteaux Bourguignons', _rl, _Y(1, 2, 4)),
  _D.world('FR', _bgn, 'Crémant de Bourgogne', _spc, _Y(1, 3, 6)),
  _D.world(
    'FR',
    _bgn,
    'Bourgogne Hautes-Côtes de Nuits',
    _rl,
    _Y(2, 4, 8),
    aliases: ['hautes cotes de nuits'],
    otherTypes: {_w: _Y(1, 3, 6)},
  ),
  _D.world(
    'FR',
    _bgn,
    'Bourgogne Hautes-Côtes de Beaune',
    _rl,
    _Y(2, 4, 8),
    aliases: ['hautes cotes de beaune'],
    otherTypes: {_w: _Y(1, 3, 6)},
  ),
  // Chablis and the Mâconnais: Chablis Premier and Grand Cru age far more
  // than the village wine; Petit Chablis and the Mâcon whites are fresh.
  _D.world(
    'FR',
    _bgn,
    'Chablis',
    _w,
    _Y(2, 4, 8),
    qualifierOffsets: {
      Qualifier.premierCru: _Y(3, 6, 12),
      Qualifier.grandCru: _Y(4, 10, 20),
    },
  ),
  _D.world('FR', _bgn, 'Petit Chablis', _w, _Y(0, 2, 4)),
  _D.world('FR', _bgn, 'Mâcon', _w, _Y(1, 3, 6), aliases: ['macon villages']),
  _D.world('FR', _bgn, 'Pouilly-Fuissé', _w, _Y(1, 3, 6)),
  _D.world('FR', _bgn, 'Saint-Véran', _w, _Y(1, 3, 6)),
  _D.world('FR', _bgn, 'Viré-Clessé', _w, _Y(1, 3, 6)),
  _D.world('FR', _bgn, 'Pouilly-Loché', _w, _Y(1, 3, 6)),
  _D.world('FR', _bgn, 'Pouilly-Vinzelles', _w, _Y(1, 3, 6)),
  // Côte Chalonnaise: lighter, earlier than the Côte d'Or.
  _D.world(
    'FR',
    _bgn,
    'Rully',
    _w,
    _Y(1, 3, 7),
    otherTypes: {_rl: _Y(2, 4, 8)},
  ),
  _D.world(
    'FR',
    _bgn,
    'Mercurey',
    _rl,
    _Y(2, 5, 10),
    otherTypes: {_w: _Y(2, 4, 8)},
  ),
  _D.world('FR', _bgn, 'Givry', _rl, _Y(2, 4, 8)),
  _D.world('FR', _bgn, 'Montagny', _w, _Y(1, 3, 7)),
  _D.world('FR', _bgn, 'Bouzeron', _w, _Y(0, 2, 5)),
  // Côte de Nuits: the great Pinot Noir communes; premier and grand crus
  // lengthen the window.
  _D.world(
    'FR',
    _bgn,
    'Côte de Nuits-Villages',
    _rs,
    _Y(5, 10, 20),
    key: 'coteDeNuits',
    aliases: ['cote de nuits'],
    qualifierOffsets: _nuits,
  ),
  _D.world('FR', _bgn, 'Marsannay', _rl, _Y(2, 5, 10)),
  _D.world('FR', _bgn, 'Fixin', _rl, _Y(3, 7, 14)),
  _D.world(
    'FR',
    _bgn,
    'Gevrey-Chambertin',
    _rs,
    _Y(5, 10, 20),
    qualifierOffsets: _nuits,
  ),
  _D.world(
    'FR',
    _bgn,
    'Morey-Saint-Denis',
    _rs,
    _Y(5, 10, 20),
    qualifierOffsets: _nuits,
  ),
  _D.world(
    'FR',
    _bgn,
    'Chambolle-Musigny',
    _rs,
    _Y(5, 10, 20),
    qualifierOffsets: _nuits,
  ),
  _D.world('FR', _bgn, 'Vougeot', _rl, _Y(4, 8, 16)),
  _D.world(
    'FR',
    _bgn,
    'Vosne-Romanée',
    _rs,
    _Y(5, 10, 20),
    qualifierOffsets: _nuits,
  ),
  _D.world(
    'FR',
    _bgn,
    'Nuits-Saint-Georges',
    _rs,
    _Y(5, 10, 20),
    qualifierOffsets: _nuits,
  ),
  // Côte de Nuits grand crus: the longest-lived Pinot Noir, 8/15/30 as the
  // grand cru of world-tables.md.
  _D.world(
    'FR',
    _bgn,
    'Chambertin',
    _rs,
    _Y(8, 15, 30),
    aliases: [
      'chambertin clos de beze',
      'charmes chambertin',
      'mazis chambertin',
      'latricieres chambertin',
      'griotte chambertin',
      'chapelle chambertin',
      'ruchottes chambertin',
      'mazoyeres chambertin',
    ],
  ),
  _D.world(
    'FR',
    _bgn,
    'Clos de Vougeot',
    _rs,
    _Y(8, 15, 30),
    aliases: ['clos vougeot'],
  ),
  _D.world('FR', _bgn, 'Musigny', _rs, _Y(8, 15, 30)),
  _D.world('FR', _bgn, 'Bonnes-Mares', _rs, _Y(8, 15, 30)),
  _D.world('FR', _bgn, 'Clos de la Roche', _rs, _Y(8, 15, 30)),
  _D.world('FR', _bgn, 'Clos Saint-Denis', _rs, _Y(8, 15, 30)),
  _D.world('FR', _bgn, 'Clos de Tart', _rs, _Y(8, 15, 30)),
  _D.world('FR', _bgn, 'Clos des Lambrays', _rs, _Y(8, 15, 30)),
  _D.world(
    'FR',
    _bgn,
    'Échezeaux',
    _rs,
    _Y(8, 15, 30),
    aliases: ['grands echezeaux'],
  ),
  _D.world('FR', _bgn, 'Richebourg', _rs, _Y(8, 15, 30)),
  _D.world('FR', _bgn, 'Romanée-Saint-Vivant', _rs, _Y(8, 15, 30)),
  _D.world('FR', _bgn, 'Romanée-Conti', _rs, _Y(8, 15, 30)),
  _D.world('FR', _bgn, 'La Tâche', _rs, _Y(8, 15, 30)),
  _D.world('FR', _bgn, 'La Romanée', _rs, _Y(8, 15, 30)),
  _D.world('FR', _bgn, 'La Grande Rue', _rs, _Y(8, 15, 30)),
  // Côte de Beaune reds: rounder than the Côte de Nuits, a few years
  // earlier; Corton is the only red grand cru.
  _D.world(
    'FR',
    _bgn,
    'Côte de Beaune-Villages',
    _rs,
    _Y(4, 8, 15),
    key: 'coteDeBeauneRouge',
    aliases: ['cote de beaune'],
    qualifierOffsets: _beaune,
  ),
  _D.world('FR', _bgn, 'Pommard', _rs, _Y(4, 8, 15), qualifierOffsets: _beaune),
  _D.world('FR', _bgn, 'Volnay', _rs, _Y(4, 8, 15), qualifierOffsets: _beaune),
  _D.world('FR', _bgn, 'Beaune', _rs, _Y(4, 8, 15), qualifierOffsets: _beaune),
  _D.world('FR', _bgn, 'Corton', _rs, _Y(4, 8, 15), qualifierOffsets: _beaune),
  _D.world('FR', _bgn, 'Aloxe-Corton', _rs, _Y(4, 8, 15)),
  _D.world('FR', _bgn, 'Ladoix', _rl, _Y(3, 6, 12)),
  _D.world(
    'FR',
    _bgn,
    'Pernand-Vergelesses',
    _rl,
    _Y(3, 6, 12),
    otherTypes: {_w: _Y(2, 5, 10)},
  ),
  _D.world('FR', _bgn, 'Savigny-lès-Beaune', _rl, _Y(3, 6, 12)),
  _D.world('FR', _bgn, 'Chorey-lès-Beaune', _rl, _Y(2, 5, 10)),
  _D.world('FR', _bgn, 'Monthélie', _rl, _Y(3, 6, 12)),
  _D.world(
    'FR',
    _bgn,
    'Auxey-Duresses',
    _rl,
    _Y(3, 6, 12),
    otherTypes: {_w: _Y(2, 4, 8)},
  ),
  _D.world('FR', _bgn, 'Santenay', _rl, _Y(3, 6, 12)),
  _D.world('FR', _bgn, 'Maranges', _rl, _Y(3, 6, 12)),
  // Côte de Beaune whites: Meursault, Puligny and Chassagne age 10-15 years,
  // the Montrachet grand crus and Corton-Charlemagne more than 20.
  _D.world(
    'FR',
    _bgn,
    'Meursault',
    _w,
    _Y(3, 7, 15),
    qualifierOffsets: _beauneBlanc,
  ),
  _D.world(
    'FR',
    _bgn,
    'Puligny-Montrachet',
    _w,
    _Y(3, 7, 15),
    qualifierOffsets: _beauneBlanc,
  ),
  _D.world(
    'FR',
    _bgn,
    'Chassagne-Montrachet',
    _w,
    _Y(3, 7, 15),
    otherTypes: {_rs: _Y(4, 8, 15)},
    qualifierOffsets: _beauneBlanc,
  ),
  _D.world(
    'FR',
    _bgn,
    'Saint-Aubin',
    _w,
    _Y(2, 5, 10),
    otherTypes: {_rl: _Y(2, 5, 10)},
  ),
  _D.world('FR', _bgn, 'Saint-Romain', _w, _Y(2, 4, 8)),
  _D.world(
    'FR',
    _bgn,
    'Montrachet',
    _w,
    _Y(6, 12, 25),
    aliases: [
      'le montrachet',
      'chevalier montrachet',
      'batard montrachet',
      'bienvenues batard montrachet',
      'criots batard montrachet',
    ],
  ),
  _D.world(
    'FR',
    _bgn,
    'Corton-Charlemagne',
    _w,
    _Y(5, 10, 20),
    aliases: ['charlemagne'],
  ),
  // Beaujolais: Gamay of fruit, drunk within 2-3 years; Nouveau within one;
  // the crus on granite (Morgon, Moulin-à-Vent) keep up to ten.
  _D.world('FR', _bjl, 'Beaujolais', _rl, _Y(0, 1, 3)),
  _D.world('FR', _bjl, 'Beaujolais-Villages', _rl, _Y(0, 1, 3)),
  _D.world('FR', _bjl, 'Beaujolais Nouveau', _rl, _Y(0, 0, 1)),
  _D.world('FR', _bjl, 'Morgon', _rl, _Y(2, 4, 10)),
  _D.world('FR', _bjl, 'Fleurie', _rl, _Y(2, 4, 10)),
  _D.world('FR', _bjl, 'Moulin-à-Vent', _rl, _Y(2, 4, 10)),
  _D.world('FR', _bjl, 'Brouilly', _rl, _Y(2, 4, 10)),
  _D.world('FR', _bjl, 'Côte de Brouilly', _rl, _Y(2, 4, 10)),
  _D.world('FR', _bjl, 'Chénas', _rl, _Y(2, 5, 10)),
  _D.world('FR', _bjl, 'Juliénas', _rl, _Y(2, 4, 8)),
  _D.world('FR', _bjl, 'Chiroubles', _rl, _Y(1, 3, 6)),
  _D.world('FR', _bjl, 'Saint-Amour', _rl, _Y(1, 3, 6)),
  _D.world('FR', _bjl, 'Régnié', _rl, _Y(1, 3, 6)),
  // Northern Rhône: Syrah of Hermitage, Côte-Rôtie and Cornas is tannic and
  // lasts 25 years; Crozes and Saint-Joseph are the softer neighbours;
  // Condrieu (Viognier) is a perfumed white to drink young.
  _D.world(
    'FR',
    _rho,
    'Hermitage',
    _rs,
    _Y(7, 12, 25),
    otherTypes: {_w: _Y(4, 10, 25)},
  ),
  _D.world('FR', _rho, 'Côte-Rôtie', _rs, _Y(7, 12, 25)),
  _D.world('FR', _rho, 'Cornas', _rs, _Y(7, 12, 25)),
  _D.world('FR', _rho, 'Crozes-Hermitage', _rl, _Y(2, 4, 8)),
  _D.world(
    'FR',
    _rho,
    'Saint-Joseph',
    _rl,
    _Y(3, 6, 12),
    otherTypes: {_w: _Y(1, 3, 6)},
  ),
  _D.world('FR', _rho, 'Condrieu', _w, _Y(1, 3, 6)),
  _D.world('FR', _rho, 'Château-Grillet', _w, _Y(3, 8, 15)),
  _D.world(
    'FR',
    _rho,
    'Saint-Péray',
    _w,
    _Y(1, 3, 6),
    otherTypes: {_spc: _Y(1, 2, 5)},
  ),
  // Southern Rhône: Grenache blends; Châteauneuf keeps 20 years, the crus
  // (Gigondas, Rasteau...) 8-12, Côtes du Rhône 4-8; Tavel is a rosé with
  // body; the Muscat of Beaumes-de-Venise is a fortified sweet wine.
  _D.world(
    'FR',
    _rho,
    'Châteauneuf-du-Pape',
    _rs,
    _Y(5, 10, 20),
    otherTypes: {_w: _Y(2, 5, 12)},
  ),
  _D.world('FR', _rho, 'Gigondas', _rl, _Y(2, 4, 8)),
  _D.world('FR', _rho, 'Vacqueyras', _rl, _Y(2, 4, 8)),
  _D.world(
    'FR',
    _rho,
    'Côtes du Rhône',
    _rl,
    _Y(2, 4, 8),
    otherTypes: {_w: _Y(0, 2, 4), _ro: _Y(0, 1, 2)},
  ),
  _D.world('FR', _rho, 'Côtes du Rhône Villages', _rl, _Y(2, 5, 10)),
  _D.world(
    'FR',
    _rho,
    'Rasteau',
    _rs,
    _Y(3, 6, 12),
    otherTypes: {_sw: _Y(3, 10, 25)},
  ),
  _D.world('FR', _rho, 'Cairanne', _rl, _Y(2, 5, 10)),
  _D.world('FR', _rho, 'Vinsobres', _rl, _Y(2, 5, 10)),
  _D.world('FR', _rho, 'Lirac', _rl, _Y(2, 5, 10)),
  _D.world('FR', _rho, 'Tavel', _ro, _Y(0, 2, 4)),
  _D.world('FR', _rho, 'Beaumes-de-Venise', _rl, _Y(2, 5, 10)),
  _D.world('FR', _rho, 'Muscat de Beaumes-de-Venise', _sw, _Y(0, 2, 5)),
  _D.world(
    'FR',
    _rho,
    'Ventoux',
    _rl,
    _Y(1, 2, 5),
    aliases: ['cotes du ventoux'],
  ),
  _D.world(
    'FR',
    _rho,
    'Luberon',
    _rl,
    _Y(1, 2, 5),
    aliases: ['cotes du luberon'],
    otherTypes: {_ro: _Y(0, 1, 2)},
  ),
  _D.world('FR', _rho, 'Costières de Nîmes', _rl, _Y(1, 3, 6)),
  _D.world('FR', _rho, 'Grignan-les-Adhémar', _rl, _Y(1, 2, 4)),
  _D.world('FR', _rho, 'Clairette de Die', _spt, _Y(0, 1, 2)),
  // Loire: Sauvignon (Sancerre, Pouilly-Fumé) and Muscadet are fresh
  // whites; Chenin (Vouvray, Savennières, Montlouis) keeps long, above all
  // sweet (Layon, Quarts de Chaume, Bonnezeaux); Cabernet Franc of Chinon
  // and Bourgueil is a medium red that ages ten years.
  _D.world(
    'FR',
    _loi,
    'Sancerre',
    _w,
    _Y(1, 3, 6),
    otherTypes: {_rl: _Y(2, 4, 8), _ro: _Y(0, 1, 2)},
  ),
  _D.world(
    'FR',
    _loi,
    'Pouilly-Fumé',
    _w,
    _Y(1, 3, 6),
    aliases: ['blanc fume de pouilly'],
  ),
  _D.world(
    'FR',
    _loi,
    'Muscadet',
    _w,
    _Y(1, 3, 6),
    aliases: ['muscadet sevre et maine'],
  ),
  _D.world(
    'FR',
    _loi,
    'Vouvray',
    _w,
    _Y(1, 3, 6),
    otherTypes: {_sw: _Y(3, 10, 30), _spc: _Y(1, 3, 6)},
  ),
  _D.world('FR', _loi, 'Savennières', _w, _Y(3, 8, 20)),
  _D.world(
    'FR',
    _loi,
    'Montlouis-sur-Loire',
    _w,
    _Y(1, 4, 12),
    aliases: ['montlouis'],
    otherTypes: {_sw: _Y(3, 10, 25)},
  ),
  _D.world('FR', _loi, 'Jasnières', _w, _Y(2, 6, 15)),
  _D.world('FR', _loi, 'Coteaux du Layon', _sw, _Y(3, 10, 25)),
  _D.world('FR', _loi, 'Quarts de Chaume', _sw, _Y(5, 15, 40)),
  _D.world('FR', _loi, 'Bonnezeaux', _sw, _Y(5, 15, 35)),
  _D.world("FR", _loi, "Coteaux de l'Aubance", _sw, _Y(3, 8, 20)),
  _D.world(
    'FR',
    _loi,
    'Anjou',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(1, 3, 8)},
  ),
  _D.world("FR", _loi, "Rosé d'Anjou", _ro, _Y(0, 1, 2)),
  _D.world("FR", _loi, "Cabernet d'Anjou", _ro, _Y(0, 1, 3)),
  _D.world(
    'FR',
    _loi,
    'Saumur',
    _rl,
    _Y(1, 3, 6),
    otherTypes: {_w: _Y(1, 3, 6), _spc: _Y(1, 2, 5)},
  ),
  _D.world('FR', _loi, 'Saumur-Champigny', _rl, _Y(2, 4, 8)),
  _D.world('FR', _loi, 'Chinon', _rl, _Y(2, 5, 12)),
  _D.world('FR', _loi, 'Bourgueil', _rl, _Y(2, 5, 12)),
  _D.world('FR', _loi, 'Saint-Nicolas-de-Bourgueil', _rl, _Y(2, 4, 10)),
  _D.world('FR', _loi, 'Menetou-Salon', _w, _Y(1, 2, 5)),
  _D.world('FR', _loi, 'Quincy', _w, _Y(0, 2, 4)),
  _D.world('FR', _loi, 'Reuilly', _w, _Y(0, 2, 4)),
  _D.world(
    'FR',
    _loi,
    'Touraine',
    _w,
    _Y(0, 2, 4),
    otherTypes: {_rl: _Y(1, 2, 5)},
  ),
  _D.world('FR', _loi, 'Cheverny', _w, _Y(0, 2, 4)),
  _D.world('FR', _loi, 'Crémant de Loire', _spc, _Y(1, 2, 5)),
  // Alsace: Riesling, Gewurztraminer and Pinot Gris with acidity that keeps
  // 10 years, the grand crus nearly 20; the late harvests are sweet wines
  // that last decades.
  _D.world(
    'FR',
    'Alsace',
    'Alsace',
    _w,
    _Y(1, 4, 10),
    aliases: ['vin d alsace'],
    qualifierOffsets: {Qualifier.grandCru: _Y(4, 8, 18)},
  ),
  _D.world("FR", 'Alsace', "Crémant d'Alsace", _spc, _Y(1, 2, 5)),
  _D.world(
    'FR',
    'Alsace',
    'Alsace Vendanges Tardives',
    _sw,
    _Y(3, 10, 25),
    aliases: ['vendanges tardives'],
  ),
  _D.world(
    'FR',
    'Alsace',
    'Alsace Sélection de Grains Nobles',
    _sw,
    _Y(5, 15, 35),
    aliases: ['selection de grains nobles'],
  ),
  // Champagne: at least 15 months on the lees, best within 8 years; the
  // vintage ones rest three years and keep 20.
  _D.world(
    'FR',
    'Champagne',
    'Champagne',
    _spc,
    _Y(1, 3, 8),
    qualifierOffsets: {Qualifier.vintage: _Y(5, 10, 20)},
  ),
  _D.world('FR', 'Champagne', 'Coteaux Champenois', _rl, _Y(2, 4, 8)),
  _D.world('FR', 'Champagne', 'Rosé des Riceys', _ro, _Y(2, 4, 8)),
  // Provence and Languedoc-Roussillon: rosés to drink within two years;
  // Bandol (Mourvèdre) is a long-lived red; the Languedoc reds are warm and
  // ready early; Banyuls, Maury and Rivesaltes are fortified sweet wines
  // that keep for decades.
  _D.world(
    'FR',
    'Provence',
    'Bandol',
    _rs,
    _Y(4, 8, 15),
    otherTypes: {_ro: _Y(0, 2, 4)},
  ),
  _D.world(
    'FR',
    'Provence',
    'Côtes de Provence',
    _ro,
    _Y(0, 1, 2),
    otherTypes: {_rl: _Y(1, 3, 6), _w: _Y(0, 1, 3)},
  ),
  _D.world(
    'FR',
    'Provence',
    'Cassis',
    _w,
    _Y(0, 2, 5),
    weakAliases: ['cassis'],
  ),
  _D.world(
    'FR',
    'Provence',
    'Palette',
    _rl,
    _Y(3, 6, 12),
    weakAliases: ['palette'],
  ),
  _D.world('FR', 'Provence', "Coteaux d'Aix-en-Provence", _ro, _Y(0, 1, 2)),
  _D.world(
    'FR',
    'Languedoc-Roussillon',
    'Languedoc',
    _rl,
    _Y(1, 3, 6),
    weakAliases: ['languedoc'],
  ),
  _D.world('FR', 'Languedoc-Roussillon', 'Pic Saint-Loup', _rl, _Y(2, 5, 10)),
  _D.world('FR', 'Languedoc-Roussillon', 'Faugères', _rl, _Y(2, 4, 8)),
  _D.world('FR', 'Languedoc-Roussillon', 'Saint-Chinian', _rl, _Y(2, 4, 8)),
  _D.world('FR', 'Languedoc-Roussillon', 'Minervois', _rl, _Y(2, 4, 8)),
  _D.world('FR', 'Languedoc-Roussillon', 'Corbières', _rl, _Y(2, 4, 8)),
  _D.world('FR', 'Languedoc-Roussillon', 'Fitou', _rl, _Y(2, 4, 8)),
  _D.world(
    'FR',
    'Languedoc-Roussillon',
    'Terrasses du Larzac',
    _rs,
    _Y(3, 6, 12),
  ),
  _D.world(
    'FR',
    'Languedoc-Roussillon',
    'Crémant de Limoux',
    _spc,
    _Y(1, 2, 5),
    aliases: ['blanquette de limoux', 'limoux'],
  ),
  _D.world('FR', 'Languedoc-Roussillon', 'Collioure', _rl, _Y(2, 4, 8)),
  _D.world('FR', 'Languedoc-Roussillon', 'Banyuls', _fo, _Y(3, 10, 30)),
  _D.world(
    'FR',
    'Languedoc-Roussillon',
    'Maury',
    _fo,
    _Y(3, 10, 30),
    weakAliases: ['maury'],
  ),
  _D.world('FR', 'Languedoc-Roussillon', 'Rivesaltes', _fo, _Y(3, 10, 30)),
  _D.world(
    'FR',
    'Languedoc-Roussillon',
    'Muscat de Rivesaltes',
    _sw,
    _Y(0, 2, 5),
  ),
  _D.world(
    'FR',
    'Languedoc-Roussillon',
    'Côtes du Roussillon',
    _rl,
    _Y(1, 3, 6),
  ),
  // South-West: Cahors (Malbec) and Madiran (Tannat) are among the most
  // tannic reds of France; Jurançon and Monbazillac are sweet wines; the
  // others are medium reds.
  _D.world('FR', 'Sud-Ouest', 'Cahors', _rs, _Y(4, 8, 15)),
  _D.world('FR', 'Sud-Ouest', 'Madiran', _rs, _Y(4, 8, 15)),
  _D.world(
    'FR',
    'Sud-Ouest',
    'Jurançon',
    _w,
    _Y(1, 4, 10),
    otherTypes: {_sw: _Y(3, 10, 25)},
  ),
  _D.world('FR', 'Sud-Ouest', 'Monbazillac', _sw, _Y(3, 10, 25)),
  _D.world('FR', 'Sud-Ouest', 'Gaillac', _rl, _Y(1, 3, 6)),
  _D.world('FR', 'Sud-Ouest', 'Bergerac', _rl, _Y(1, 3, 6)),
  _D.world('FR', 'Sud-Ouest', 'Pécharmant', _rl, _Y(3, 6, 12)),
  _D.world('FR', 'Sud-Ouest', 'Buzet', _rl, _Y(2, 4, 8)),
  _D.world('FR', 'Sud-Ouest', 'Fronton', _rl, _Y(0, 2, 4)),
  _D.world('FR', 'Sud-Ouest', 'Irouléguy', _rl, _Y(3, 6, 12)),
  // Jura, Savoie and Corsica: the vin jaune of Château-Chalon rests six
  // years under flor and keeps for half a century; the other Jura whites
  // are oxidative and long-lived; Savoie whites are alpine and fresh.
  _D.world(
    'FR',
    'Jura',
    'Arbois',
    _rl,
    _Y(2, 5, 10),
    otherTypes: {_w: _Y(2, 5, 12)},
  ),
  _D.world('FR', 'Jura', 'Côtes du Jura', _w, _Y(2, 5, 12)),
  _D.world('FR', 'Jura', 'Château-Chalon', _w, _Y(10, 25, 60)),
  _D.world('FR', 'Jura', 'Crémant du Jura', _spc, _Y(1, 2, 5)),
  _D.world(
    "FR",
    'Jura',
    "L'Étoile",
    _w,
    _Y(2, 5, 12),
    weakAliases: ['l etoile'],
  ),
  _D.world('FR', null, 'Vin de Savoie', _w, _Y(0, 2, 4)),
  _D.world('FR', null, 'Patrimonio', _rl, _Y(2, 4, 8)),
  _D.world('FR', null, 'Ajaccio', _rl, _Y(2, 4, 8), weakAliases: ['ajaccio']),
];
