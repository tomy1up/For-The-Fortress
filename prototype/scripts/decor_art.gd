extends RefCounted
## Habillage de décor par données : palettes de sol, calque de cendres et pièces posées (portails, remparts, basalte…).
## Les images et `decor.json` sont déposés dans res://assets/decor/ (lus bruts, inclus tels quels dans le paquet).
## Sans fichier valide, le jeu garde les repères de couleur neutres. Voir design/Format_decor.md.
const ROOT := "res://assets/decor/"
const FILE := "decor.json"

static var _data: Dictionary = {}
static var _loaded := false
static var _textures: Dictionary = {}

static func data() -> Dictionary:
	if not _loaded:
		_loaded = true
		var path: String = ROOT + FILE
		if FileAccess.file_exists(path):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
			if parsed is Dictionary and parsed.get("version") == 1: _data = parsed
	return _data

## Ensemble de décor d'une carte : `citadel` prend l'architecture du camp adverse, `volcanic` est commun aux deux camps.
static func set_for(decoration: String) -> Dictionary:
	var sets: Dictionary = data()
	return sets.get(decoration,{}) if decoration in ["citadel","volcanic","marsh","desert","mine","sky","coast","necro"] else {}

## Camp de la citadelle affichée : le camp adverse de celui qui joue (0 = Alliance jouée, donc citadelle de la Horde).
static func citadel_faction(played_faction: int) -> String:
	return "horde" if played_faction == 0 else "alliance"

static func _color(value: Variant) -> Color:
	return Color(float(value[0])/255.0,float(value[1])/255.0,float(value[2])/255.0)

## {"ground": Color, "face_right": Color, "face_left": Color} ou {} si le décor n'a pas de palette.
static func palette(decoration: String, played_faction: int) -> Dictionary:
	var set: Dictionary = set_for(decoration)
	if set.is_empty(): return {}
	var entry: Dictionary = set.get("palette",{})
	if decoration == "citadel": entry = entry.get(citadel_faction(played_faction),{})
	if entry.is_empty() or not entry.has("ground") or not entry.has("faces"): return {}
	return {"ground":_color(entry.ground),"face_right":_color(entry.faces[0]),"face_left":_color(entry.faces[1])}

static func texture(file: String) -> Texture2D:
	var path: String = ROOT + file
	if _textures.has(path): return _textures[path]
	var result: Texture2D = null
	if ResourceLoader.exists(path): result = load(path) as Texture2D
	if result == null and FileAccess.file_exists(path):
		var image := Image.load_from_file(path)
		if image != null and not image.is_empty(): result = ImageTexture.create_from_image(image)
	_textures[path] = result
	return result

## Calque posé sur le sol, avant la chaussée : {"texture", "position"} ou {}.
static func overlay(decoration: String) -> Dictionary:
	var entry: Dictionary = set_for(decoration).get("overlay",{})
	if entry.is_empty(): return {}
	var image: Texture2D = texture(str(entry.file))
	if image == null: return {}
	return {"texture":image,"position":Vector2(float(entry.position[0]),float(entry.position[1]))}

## Pièces de décor d'une carte, dans l'ordre de dessin : {"texture", "point" (logique), "destination" (pieds sur l'origine)}.
## Cartes refondues (v0.224, tracés nouveaux) : les pièces de décor posées à la main pour les anciens tracés ne leur conviennent plus ; elles sont désactivées
## jusqu'à ce que Codex en propose de nouvelles (voir ECHANGES_CLAUDE_VERS_CODEX.md).
const REWORKED_MAPS: Array[String] = [] # Toutes les cartes refondues ont leur décor depuis la v0.242.

## Pins et ardoises des missions 21 à 40 (lot 6ecb5d3 de Codex, validé par le porteur le 22 novembre 2026) : sur les onze cartes des Ardoises, les pins et
## rochers de `scenery_for` prennent les pièces dessinées de leur carte (pin pour les pins, rocher selon la parité de l'ordre de placement), réduites
## (1, 0,89 ou 0,95 selon l'ordre modulo 3) et parfois tournées en miroir (ordre modulo 5 inférieur à 2), dans les cadres de `scenery_bounds`.
const SLATE_ASSETS := {"pin_ardoises":["ardoises/pin_ardoises.png",Rect2(-16,-46,32,60)], "pin_des_cretes":["ardoises/pin_des_cretes.png",Rect2(-16,-46,32,60)], "cairn":["ardoises/cairn.png",Rect2(-13,-14,26,23)], "eboulis":["ardoises/eboulis.png",Rect2(-13,-14,26,23)], "dalles":["ardoises/dalles.png",Rect2(-13,-14,26,23)], "lichen":["ardoises/lichen.png",Rect2(-13,-14,26,23)]}
const SLATE_MAPS := {
	"slate_pass":["lichen","dalles","pin_ardoises"],
	"slate_ridges":["dalles","eboulis","pin_des_cretes"],
	"slate_scree":["eboulis","dalles","pin_des_cretes"],
	"slate_ravine":["dalles","lichen","pin_ardoises"],
	"slate_gates":["cairn","dalles","pin_des_cretes"],
	"slate_crossing":["cairn","lichen","pin_ardoises"],
	"slate_laces":["eboulis","lichen","pin_des_cretes"],
	"slate_cirque":["lichen","dalles","pin_ardoises"],
	"slate_high_passages":["cairn","eboulis","pin_des_cretes"],
	"slate_bastion":["cairn","dalles","pin_ardoises"],
	"slate_bastion_winds":["eboulis","cairn","pin_des_cretes"]}
const SLATE_SCALES: Array[float] = [1.0,0.89,0.95]

## Pièce dessinée d'un pin ou d'un rocher des Ardoises : {"texture", "rect" (autour du point d'appui), "scale", "facing"} ou {} (dessin vectoriel).
static func slate_prop(map_id: String, kind: String, order: int) -> Dictionary:
	if not SLATE_MAPS.has(map_id) or kind not in ["pine","rock"]: return {}
	var options: Array = SLATE_MAPS[map_id]
	var asset: Array = SLATE_ASSETS[options[2] if kind == "pine" else options[order%2]]
	var image: Texture2D = texture(str(asset[0]))
	if image == null: return {}
	return {"texture":image,"rect":asset[1],"scale":SLATE_SCALES[order%3],"facing":-1.0 if order%5 < 2 else 1.0}

## Décor du Gué, missions 1 à 20 (lot 3feb9b09 de Codex, validé par le porteur le 23 novembre 2026) : sur les dix cartes des chapitres 1 et 2, les pins,
## rochers et buissons de `scenery_for` et les arbres fixes des cartes prennent cinq pièces dessinées (deux pins, roche moussue, buisson fleuri, fougères),
## réduites à 0,91, 0,955 ou 1 selon leur ordre modulo 3 et tournées en miroir si l'ordre modulo 5 est inférieur à 2. Sur la carte d'ouverture
## (`valley_ford`, missions 1 et 11), la rivière dessinée passe sous la chaussée et le pont au-dessus, avant les unités.
const FORD_ASSETS := {"pin_du_gue":["gue/pin_du_gue.png",Rect2(-16,-46,32,60)], "pin_du_bois":["gue/pin_du_bois.png",Rect2(-16,-46,32,60)], "rocher_moussu":["gue/rocher_moussu.png",Rect2(-13,-14,26,23)], "buisson_fleuri":["gue/buisson_fleuri.png",Rect2(-13,-14,26,23)], "fougeres":["gue/fougeres.png",Rect2(-13,-14,26,23)]}
const FORD_OVERLAYS := {"riviere_du_gue":["gue/riviere_du_gue.png",Rect2(540,245,318,166)], "pont_du_gue":["gue/pont_du_gue.png",Rect2(605,327,80,56)]}

static func ford_map(map_id: String) -> bool:
	return map_id == "valley_ford" or map_id.begins_with("ford_")

static func _ford_piece(key: String, order: int) -> Dictionary:
	var image: Texture2D = texture(str(FORD_ASSETS[key][0]))
	if image == null: return {}
	return {"texture":image,"rect":FORD_ASSETS[key][1],"scale":0.91+0.045*float(posmod(order,3)),"facing":-1.0 if posmod(order,5) < 2 else 1.0}

## Pièce d'un objet de `scenery_for` : pin du bois ou du gué selon la parité de l'ordre, roche moussue, buisson fleuri ou fougères ; {} hors du Gué.
static func ford_prop(map_id: String, kind: String, order: int) -> Dictionary:
	if not ford_map(map_id) or kind not in ["pine","rock","shrub"]: return {}
	var key: String = ("pin_du_bois" if order%2 == 0 else "pin_du_gue") if kind == "pine" else "rocher_moussu" if kind == "rock" else "buisson_fleuri" if order%2 == 0 else "fougeres"
	return _ford_piece(key,order)

## Pièce d'un arbre fixe de la carte (`definition.trees`), selon son rang.
static func ford_tree(map_id: String, index: int) -> Dictionary:
	if not ford_map(map_id): return {}
	return _ford_piece("pin_du_gue" if index%2 == 0 else "pin_du_bois",index)

## Calque de la carte d'ouverture (rivière ou pont), en coordonnées d'écran : {"texture", "rect"} ou {}.
static func ford_overlay(map_id: String, key: String) -> Dictionary:
	if map_id != "valley_ford" or not FORD_OVERLAYS.has(key): return {}
	var image: Texture2D = texture(str(FORD_OVERLAYS[key][0]))
	return {"texture":image,"rect":FORD_OVERLAYS[key][1]} if image != null else {}

static func props(map_id: String, decoration: String, played_faction: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if map_id in REWORKED_MAPS: return result
	var set: Dictionary = set_for(decoration)
	if set.is_empty(): return result
	var assets: Dictionary = set.get("assets",{})
	if decoration == "citadel": assets = assets.get(citadel_faction(played_faction),{})
	for placement in set.get("placements",{}).get(map_id,[]):
		var asset: Dictionary = assets.get(str(placement.object),{})
		if asset.is_empty(): continue
		var image: Texture2D = texture(str(asset.file))
		if image == null: continue
		var size := Vector2(float(asset.size[0]),float(asset.size[1]))
		var scale: float = float(asset.height)/size.y
		var anchor := Vector2(float(asset.anchor[0]),float(asset.anchor[1]))
		result.append({"texture":image,"point":Vector2(float(placement.xy[0]),float(placement.xy[1])),"destination":Rect2(-anchor*scale,size*scale),"object":str(placement.object)})
	return result

## Calque d'eau des tronçons inondés d'une carte des marais : {"texture", "position"} ou {}. Remplace le repère bleu provisoire.
static func water_overlay(map_id: String) -> Dictionary:
	var entry: Dictionary = set_for("marsh").get("overlays",{}).get(map_id,{})
	if entry.is_empty(): return {}
	var image: Texture2D = texture(str(entry.file))
	if image == null: return {}
	return {"texture":image,"position":Vector2(float(entry.position[0]),float(entry.position[1]))}

## Le calque d'eau n'est utilisé que si la carte a la géométrie sur laquelle il a été dessiné (routes et tronçons inondés) :
## une carte de même identifiant mais de tracé différent (ancien rapport, carte modifiée) garde le repère calculé.
static var _water_checks: Dictionary = {}

static func water_overlay_for(definition: Dictionary) -> Dictionary:
	var id: String = str(definition.get("id",""))
	var entry: Dictionary = set_for("marsh").get("overlays",{}).get(id,{})
	if entry.is_empty(): return {}
	var key: String = "%s:%d" % [id,hash(definition.get("routes",[]))+31*hash(definition.get("path_points",[]))+97*hash(definition.get("flooded",[]))]
	if not _water_checks.has(key): _water_checks[key] = water_geometry_matches(definition,entry)
	return water_overlay(id) if _water_checks[key] else {}

static func water_geometry_matches(definition: Dictionary, entry: Dictionary) -> bool:
	var routes: Array = definition.routes if definition.has("routes") else [{"id":"main","path_points":definition.get("path_points",[])}]
	if routes.size() != entry.routes.size(): return false
	for index in range(routes.size()):
		var expected: Array = entry.routes[index].path_points
		var actual: Array = routes[index].path_points
		if expected.size() != actual.size(): return false
		for point in range(expected.size()):
			if not is_equal_approx(float(expected[point][0]),actual[point].x) or not is_equal_approx(float(expected[point][1]),actual[point].y): return false
	var flooded: Array = definition.get("flooded",[])
	if flooded.size() != entry.flooded.size(): return false
	for index in range(flooded.size()):
		if str(flooded[index].route) != str(entry.flooded[index].route) or not is_equal_approx(float(flooded[index].from),float(entry.flooded[index].from)) or not is_equal_approx(float(flooded[index].to),float(entry.flooded[index].to)): return false
	return true

static func clear_cache() -> void:
	_water_checks.clear()
	_data.clear()
	_loaded = false
	_textures.clear()
