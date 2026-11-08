import 'wine_card.dart';

/// The wine row of the cellar became [WineCard] in ux-redesign
/// (design-system-mapping.md: "WineCard replaces wine_list_tile.dart").
/// This name is kept only so that older imports keep compiling; new code
/// uses [WineCard]. The file can be removed once nothing imports it.
typedef WineListTile = WineCard;
