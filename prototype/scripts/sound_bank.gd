extends RefCounted
## Catalogue des effets sonores (décision du porteur, 16 novembre 2026 : banques libres de droits uniquement, voir `design/Credits_audio.md`).
## Chaque événement sonore porte une liste de fichiers possibles (tirage au hasard stable, jamais dans le modèle de jeu) ; un fichier absent est ignoré :
## le jeu reste silencieux plutôt que d'échouer tant que les sons ne sont pas installés.
const DIRECTORY := "res://assets/audio/sfx/"
const EXTENSIONS: Array[String] = ["ogg","wav"]
## Événement -> {"files": noms sans extension, "db": gain en décibels}. Réglages de prototype à confirmer à l'écoute par le porteur.
const EVENTS: Dictionary = {
	"shot.bow":{"files":["bow_1","bow_2"],"db":-6.0},
	"shot.crossbow":{"files":["crossbow_1","crossbow_2"],"db":-6.0},
	"shot.magic":{"files":["magic_1","magic_2"],"db":-8.0},
	"shot.throw":{"files":["throw_1","throw_2"],"db":-6.0},
	"shot.gun":{"files":["gun_1"],"db":-4.0},
	"shot.cannon":{"files":["cannon_1"],"db":-3.0},
	"shot.melee":{"files":["melee_1","melee_2"],"db":-6.0},
	"impact.hit":{"files":["hit_1","hit_2","hit_3"],"db":-10.0},
	"impact.blast":{"files":["blast_1"],"db":-6.0},
	"enemy.down":{"files":["down_1","down_2"],"db":-9.0},
	"ui.click":{"files":["click_1"],"db":-8.0},
	"ui.buy":{"files":["buy_1"],"db":-6.0},
}
## Familles de combat : 0 archer, 1 arbalétrier, 2 mage, 3 haches, 4 sapeur (explosion), 5 chaman.
const SHOT_BY_FAMILY: Array[String] = ["shot.bow","shot.crossbow","shot.magic","shot.throw","shot.throw","shot.magic"]
## Exceptions par type de défenseur.
const SHOT_BY_TYPE: Dictionary = {11:"shot.bow",12:"shot.gun",13:"shot.cannon",14:"shot.melee",20:"shot.melee",46:"shot.melee",17:"shot.throw",47:"shot.crossbow"}
const IMPACT_BY_FAMILY: Array[String] = ["impact.hit","impact.hit","impact.blast","impact.hit","impact.blast","impact.blast"]

static func shot_event(type: int, family: int) -> String:
	if SHOT_BY_TYPE.has(type): return SHOT_BY_TYPE[type]
	return SHOT_BY_FAMILY[clampi(family,0,SHOT_BY_FAMILY.size()-1)]

static func impact_event(family: int) -> String:
	return IMPACT_BY_FAMILY[clampi(family,0,IMPACT_BY_FAMILY.size()-1)]

## Chemin du premier fichier existant pour `name`, ou "".
static func resolve(name: String) -> String:
	for extension in EXTENSIONS:
		var path: String = "%s%s.%s" % [DIRECTORY,name,extension]
		if ResourceLoader.exists(path): return path
	return ""

## Fichier choisi pour un événement : `index` choisit parmi les fichiers présents (modulo), sans état aléatoire global.
static func stream_path(event: String, index: int = 0) -> String:
	if not EVENTS.has(event): return ""
	var present: Array[String] = []
	for name in EVENTS[event].files:
		var path: String = resolve(name)
		if not path.is_empty(): present.append(path)
	if present.is_empty(): return ""
	return present[posmod(index,present.size())]

static func gain_db(event: String) -> float:
	return float(EVENTS[event].db) if EVENTS.has(event) else 0.0
