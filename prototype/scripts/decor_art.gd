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
const REWORKED_MAPS: Array[String] = ["dune_mirage","dune_scorpion","dune_ruins","dune_arches","dune_cistern","dune_sphinx","dune_wind","dune_sarcophagus","dune_crater","dune_pyramid","mine_entrance","mine_shaft","mine_gallery","mine_crystals","mine_cart","mine_forge","mine_lake","mine_vault","mine_collapse","mine_heart","mine_pillars","mine_vein","mine_tunnel","mine_arch","mine_twins","mine_abyss","mine_sluice","mine_crossing","mine_crypt","mine_core","garrison_breach","garrison_siege","garrison_machicolations","garrison_hall","garrison_barracks","garrison_watchtower","garrison_armoury","garrison_stairs","garrison_throne","garrison_heart","dune_first","dune_oasis","dune_canyon","dune_columns","dune_caravans","dune_temple","dune_well","dune_obelisks","dune_sea","dune_necropolis","sky_pontoon","sky_mistbridge","sky_cloudgate","sky_spires","sky_gardens","sky_belvedere","sky_updrafts","sky_dome","sky_fallen","sky_summit","sky_aerie","sky_nest","sky_twinpeaks","sky_triplenest","sky_ledge","sky_col","sky_raptors","sky_roost","sky_azurefall","sky_throne"]

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
