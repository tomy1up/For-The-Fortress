extends RefCounted
## Chargeur générique d'animations par planches d'images (format version 1).
## Chaque unité dépose `res://assets/animations/<id>/animation.json` et ses planches PNG ; aucun code par unité.
## Sans description valide, le rendu retombe sur l'illustration fixe actuelle. Voir design/Format_animations.md.
const ROOT := "res://assets/animations/"
const VERSION := 1
## Noms d'animations connus, tous pilotés par le jeu depuis la v0.175.
## Ennemis : walk, hurt, spawn, death. Défenseurs : idle, attack, disabled, buy, level_up, sell.
## Variantes de marche selon la pente du trajet à l'écran (`walk_up` : le trajet monte, `walk_down` : il descend) ; `warning` : effet d'avertissement lié à un événement de jeu (mode progress).
const NAMES: Array[String] = ["walk","walk_up","walk_down","idle","attack","disabled","death","hurt","spawn","buy","sell","level_up","warning","regen","storm","blocked","mist","rise"]
## Animations jouées une seule fois sur un événement : le mode `event` est obligatoire.
const EVENT_ONLY: Array[String] = ["death","hurt","spawn","buy","sell","level_up","rise"]
const MODES: Array[String] = ["distance","time","event","progress"]
const MAX_FRAMES := 64
const MAX_FRAME_SIDE := 1024
## Identifiants de défenseurs, dans l'ordre de `Model.ROSTER`.
const DEFENDER_IDS: Array[String] = [
	"defender.alliance.archer","defender.alliance.crossbow","defender.alliance.mage",
	"defender.horde.axe","defender.horde.sapper","defender.horde.shaman",
	"defender.alliance.ranger","defender.alliance.musketeer","defender.horde.stalker","defender.horde.grenadier",
	"defender.alliance.sentinel","defender.alliance.marksman","defender.alliance.arquebusier","defender.alliance.bombard","defender.alliance.pikeman","defender.alliance.pyromancer",
	"defender.horde.watcher","defender.horde.javelin","defender.horde.shardthrower","defender.horde.catapult","defender.horde.spearman","defender.horde.cinderburner",
	"defender.alliance.lightning","defender.alliance.doublearcher","defender.alliance.heavycrossbow","defender.alliance.sling","defender.horde.chainaxe","defender.horde.doublethrower","defender.horde.maceman","defender.horde.blowgun",
	"defender.alliance.frostmage","defender.alliance.observer","defender.alliance.priest","defender.horde.swampshaman","defender.horde.wartotem","defender.horde.elder",
	"defender.alliance.mercenary","defender.alliance.trapper","defender.alliance.ballista","defender.alliance.alchemist","defender.alliance.veteran","defender.horde.pillager","defender.horde.minelayer","defender.horde.warballista","defender.horde.kamikaze","defender.horde.warveteran","defender.horde.skeleton","defender.alliance.gnome",
]

static var _specs: Dictionary = {}
static var _textures: Dictionary = {}

static func defender_id(type: int) -> String:
	return DEFENDER_IDS[type] if type >= 0 and type < DEFENDER_IDS.size() else ""

static func description_path(id: String) -> String:
	return ROOT + id + "/animation.json"

static func _is_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func _is_whole(value: Variant) -> bool:
	return _is_number(value) and float(value) == floorf(float(value))

static func _point(value: Variant) -> bool:
	return value is Array and value.size() == 2 and _is_number(value[0]) and _is_number(value[1])

## Valide une description et renvoie une chaîne vide si elle est correcte, sinon la première erreur.
static func validation_error(data: Variant, expected_id: String = "") -> String:
	if not data is Dictionary: return "Description d'animation absente ou mal formée."
	for key in ["version","id","display_height","foot","animations"]:
		if not data.has(key): return "Champ obligatoire absent : %s." % key
	for key in data:
		if key not in ["version","id","display_height","foot","facing","muzzle","animations"]: return "Champ inconnu : %s." % str(key)
	if not _is_whole(data.version) or int(data.version) != VERSION: return "Version de format non prise en charge."
	if not data.id is String or (expected_id != "" and data.id != expected_id): return "Identifiant d'animation différent du dossier."
	if not _is_number(data.display_height) or float(data.display_height) <= 0.0 or float(data.display_height) > 400.0: return "Hauteur d'affichage invalide."
	if not _point(data.foot): return "Point d'appui invalide."
	if data.has("facing") and data.facing not in ["right","left"]: return "Côté regardé par défaut invalide."
	if data.has("muzzle") and not _point(data.muzzle): return "Point de départ des projectiles invalide."
	if not data.animations is Dictionary or data.animations.is_empty(): return "Aucune animation décrite."
	for name in data.animations:
		if name not in NAMES: return "Nom d'animation inconnu : %s." % str(name)
		var error: String = _animation_error(data.animations[name])
		if error != "": return "%s : %s" % [name,error]
		if name == "storm" and data.animations[name].mode != "time": return "storm : la rafale de sable boucle sur le temps de combat (mode time obligatoire)."
		if name == "mist" and data.animations[name].mode != "time": return "mist : la brume marine boucle sur le temps de combat (mode time obligatoire)."
		if name == "blocked" and data.animations[name].mode != "time": return "blocked : l'entrée bloquée boucle sur le temps de combat (mode time obligatoire)."
		if name == "regen" and data.animations[name].mode != "time": return "regen : les remous de régénération bouclent sur le temps de combat (mode time obligatoire)."
		if name == "warning" and data.animations[name].mode != "progress": return "warning : l'avertissement suit la progression d'un événement du jeu (mode progress obligatoire)."
		if name != "warning" and data.animations[name].mode == "progress": return "%s : le mode progress est réservé à l'animation warning." % name
		if name in EVENT_ONLY and data.animations[name].mode != "event": return "%s : cette animation se joue une fois sur un événement (mode event obligatoire)." % name
		if name in ["death","hurt","spawn","buy","sell","level_up","rise"] and float(data.animations[name].duration) > 3.0: return "%s : durée limitée à 3 s." % name
	for variant in ["walk_up","walk_down"]:
		if not data.animations.has(variant): continue
		if not data.animations.has("walk"): return "%s : la marche de base walk est obligatoire (repli quand la pente est nulle)." % variant
		var base: Dictionary = data.animations.walk
		var other: Dictionary = data.animations[variant]
		if other.mode != base.mode or int(other.frames) != int(base.frames) or other.get("stride",0) != base.get("stride",0) or other.get("fps",0) != base.get("fps",0): return "%s : même mode, même nombre d'images et même foulée que walk (la phase du pas se conserve au virage)." % variant
	var first_size: Array = data.animations.values()[0].frame_size
	for name in data.animations:
		var size: Array = data.animations[name].frame_size
		if int(size[0]) != int(first_size[0]) or int(size[1]) != int(first_size[1]): return "%s : toutes les animations d'une unité partagent la même taille d'image (le point d'appui en dépend)." % name
	return ""

static func _animation_error(anim: Variant) -> String:
	if not anim is Dictionary: return "description mal formée."
	for key in ["file","frames","frame_size","mode"]:
		if not anim.has(key): return "champ obligatoire absent : %s." % key
	for key in anim:
		if key not in ["file","frames","frame_size","mode","loop","stride","fps","duration"]: return "champ inconnu : %s." % str(key)
	if not anim.file is String or anim.file == "" or not anim.file.ends_with(".png") or "/" in anim.file or "\\" in anim.file or anim.file.begins_with("."): return "fichier invalide (un nom de PNG du dossier de l'unité)."
	if not _is_whole(anim.frames) or int(anim.frames) < 1 or int(anim.frames) > MAX_FRAMES: return "nombre d'images invalide (1 à %d)." % MAX_FRAMES
	var size: Variant = anim.frame_size
	if not size is Array or size.size() != 2 or not _is_whole(size[0]) or not _is_whole(size[1]) or int(size[0]) < 1 or int(size[1]) < 1 or int(size[0]) > MAX_FRAME_SIDE or int(size[1]) > MAX_FRAME_SIDE: return "taille d'image invalide."
	if anim.mode not in MODES: return "mode invalide."
	if anim.has("loop") and not anim.loop is bool: return "indicateur de boucle invalide."
	var loops: bool = anim.get("loop",anim.mode not in ["event","progress"])
	if anim.mode in ["event","progress"] and loops: return "une animation événementielle ou de progression ne boucle pas."
	if anim.mode not in ["event","progress"] and not loops: return "une animation en distance ou en temps boucle."
	if anim.mode == "distance" and (not anim.has("stride") or not _is_number(anim.stride) or float(anim.stride) <= 0.0 or float(anim.stride) > 1000.0): return "foulée absente ou invalide."
	if anim.mode == "time" and (not anim.has("fps") or not _is_number(anim.fps) or float(anim.fps) <= 0.0 or float(anim.fps) > 60.0): return "cadence absente ou invalide."
	if anim.mode == "progress" and (anim.has("duration") or anim.has("stride") or anim.has("fps")): return "le mode progress n'a ni durée, ni foulée, ni cadence (la progression vient du jeu)."
	if anim.mode == "event" and (not anim.has("duration") or not _is_number(anim.duration) or float(anim.duration) <= 0.0 or float(anim.duration) > 10.0): return "durée absente ou invalide."
	return ""

## Une planche est une bande horizontale d'images de même taille.
static func sheet_size_error(anim: Dictionary, image_size: Vector2i) -> String:
	var expected := Vector2i(int(anim.frames)*int(anim.frame_size[0]),int(anim.frame_size[1]))
	if image_size != expected: return "planche de %dx%d px au lieu de %dx%d px attendus." % [image_size.x,image_size.y,expected.x,expected.y]
	return ""

static func frames_of(anim: Dictionary) -> int:
	return int(anim.frames)

## Phase dans [0, 1) pour une boucle ; pour un événement, de 0 à 1 puis maintenue à 1.
static func phase(anim: Dictionary, travel: float, time: float, age: float, offset: float = 0.0) -> float:
	match anim.mode:
		"distance": return fposmod(travel/float(anim.stride)+offset,1.0)
		"time": return fposmod(time*float(anim.fps)/float(anim.frames)+offset,1.0)
		"progress": return clampf(age,0.0,1.0)
	return clampf(age/float(anim.duration),0.0,1.0)

static func frame_index(anim: Dictionary, phase_value: float) -> int:
	var frames: int = int(anim.frames)
	if anim.mode in ["event","progress"]: return clampi(floori(phase_value*frames),0,frames-1)
	return clampi(floori(fposmod(phase_value,1.0)*frames),0,frames-1)

static func frame_region(anim: Dictionary, index: int) -> Rect2:
	var size := Vector2(float(anim.frame_size[0]),float(anim.frame_size[1]))
	return Rect2(Vector2(size.x*clampi(index,0,int(anim.frames)-1),0.0),size)

## Rectangle de dessin, pieds sur l'origine : l'échelle fait atteindre `display_height` à la hauteur d'une image.
static func destination(spec: Dictionary, anim: Dictionary) -> Rect2:
	var size := Vector2(float(anim.frame_size[0]),float(anim.frame_size[1]))
	var scale: float = float(spec.display_height)/size.y
	var foot := Vector2(float(spec.foot[0]),float(spec.foot[1]))
	return Rect2(-foot*scale,size*scale)

## Le dessin d'origine regarde à droite par défaut ; `-1` si la planche regarde à gauche.
static func base_facing(spec: Dictionary) -> float:
	return -1.0 if spec.get("facing","right") == "left" else 1.0

static func muzzle(spec: Dictionary) -> Vector2:
	if not spec.has("muzzle"): return Vector2.ZERO
	var scale: float = float(spec.display_height)/float(spec.animations.values()[0].frame_size[1])
	return (Vector2(float(spec.muzzle[0]),float(spec.muzzle[1]))-Vector2(float(spec.foot[0]),float(spec.foot[1])))*scale

## Animation à jouer pour un défenseur, par priorité : revente, désactivé, tir en cours, achat, passage de niveau, repos.
## Chaque état peut manquer : on prend le premier disponible.
static func defender_state(spec: Dictionary, pose: Dictionary) -> String:
	var wanted: Array[String] = []
	if pose.has("sell_age") and _event_running(spec,"sell",float(pose.sell_age)): return "sell"
	if pose.get("disabled",false): wanted.append("disabled")
	if pose.has("attack_age") and spec.animations.has("attack"):
		var attack: Dictionary = spec.animations.attack
		# Une animation d'attaque événementielle va au bout de sa durée ; sinon elle suit l'impulsion de tir (0,26 s).
		if (attack.mode == "event" and float(pose.attack_age) < float(attack.duration)) or (attack.mode != "event" and float(pose.get("pulse",0.0)) > 0.0): wanted.append("attack")
	if pose.has("buy_age") and _event_running(spec,"buy",float(pose.buy_age)): wanted.append("buy")
	if pose.has("level_up_age") and _event_running(spec,"level_up",float(pose.level_up_age)): wanted.append("level_up")
	wanted.append("idle")
	for name in wanted:
		if spec.animations.has(name): return name
	return ""

static func _event_running(spec: Dictionary, name: String, age: float) -> bool:
	return spec.animations.has(name) and age >= 0.0 and age < float(spec.animations[name].duration)

## Animation à jouer pour un ennemi : coup reçu, apparition, sinon marche (variante selon la pente du trajet à l'écran si elle existe).
## `direction` est la direction du déplacement à l'écran : y négatif = le trajet monte, y positif = il descend.
static func enemy_state(spec: Dictionary, info: Dictionary) -> String:
	if info.has("rise_age") and _event_running(spec,"rise",float(info.rise_age)): return "rise"
	if info.has("hurt_age") and _event_running(spec,"hurt",float(info.hurt_age)): return "hurt"
	if info.has("spawn_age") and _event_running(spec,"spawn",float(info.spawn_age)): return "spawn"
	if not spec.animations.has("walk"): return ""
	var direction: Vector2 = info.get("direction",Vector2.ZERO)
	if direction.y < -0.000001 and spec.animations.has("walk_up"): return "walk_up"
	if direction.y > 0.000001 and spec.animations.has("walk_down"): return "walk_down"
	return "walk"

## Durée de la plus longue animation de mort chargée : fenêtre pendant laquelle un ennemi éliminé reste dessiné.
static func death_window() -> float:
	var longest: float = 0.0
	for spec in _specs.values():
		if not spec.is_empty() and spec.animations.has("death"): longest = maxf(longest,float(spec.animations.death.duration))
	return longest

## Description chargée et contrôlée, ou `{}` : absente, invalide, ou planche manquante / de mauvaise taille.
static func spec_for(id: String) -> Dictionary:
	if id == "": return {}
	if _specs.has(id): return _specs[id]
	var spec: Dictionary = {}
	var path: String = description_path(id)
	if FileAccess.file_exists(path):
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if validation_error(data,id) == "":
			spec = data
			for name in spec.animations:
				var image_size: Vector2i = sheet_size(id,spec.animations[name])
				if image_size == Vector2i.ZERO or sheet_size_error(spec.animations[name],image_size) != "":
					spec = {}
					break
	_specs[id] = spec
	return spec

static func has_animation(id: String, name: String) -> bool:
	var spec: Dictionary = spec_for(id)
	return not spec.is_empty() and spec.animations.has(name)

static func sheet_size(id: String, anim: Dictionary) -> Vector2i:
	var texture: Texture2D = texture_for(id,anim)
	return Vector2i(texture.get_size()) if texture != null else Vector2i.ZERO

## Planche déjà importée si elle existe, sinon le PNG brut (inclus tel quel dans le paquet).
static func texture_for(id: String, anim: Dictionary) -> Texture2D:
	var path: String = ROOT + id + "/" + str(anim.file)
	if _textures.has(path): return _textures[path]
	var texture: Texture2D = null
	if ResourceLoader.exists(path):
		texture = load(path) as Texture2D
	if texture == null and FileAccess.file_exists(path):
		var image := Image.load_from_file(path)
		if image != null and not image.is_empty():
			image.generate_mipmaps()
			texture = ImageTexture.create_from_image(image)
	_textures[path] = texture
	return texture

## Injection pour les tests : enregistre une description et ses planches sans fichier.
static func register_for_test(id: String, spec: Dictionary, sheets: Dictionary = {}) -> void:
	_specs[id] = spec
	for name in sheets: _textures[ROOT + id + "/" + str(spec.animations[name].file)] = sheets[name]

static func clear_cache() -> void:
	_specs.clear()
	_textures.clear()
