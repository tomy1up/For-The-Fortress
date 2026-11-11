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
	return sets.get(decoration,{}) if decoration in ["citadel","volcanic"] else {}

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
static func props(map_id: String, decoration: String, played_faction: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
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

static func clear_cache() -> void:
	_data.clear()
	_loaded = false
	_textures.clear()
