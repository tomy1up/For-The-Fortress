extends RefCounted
## Champions mutants de l'Héroïque (v0.258, lot 2 du cadrage ; liste et valeurs validées par le porteur le 25 novembre 2026, « Tout valider » ; réglages de prototype à confirmer en jeu).
## Un champion par vague à partir de la vague 3 : un ennemi ordinaire de la vague (types de base 0 à 5, jamais le boss), +50 % de PV, or doublé, un trait tiré parmi ceux
## débloqués par le chapitre (deux au chapitre 1, puis un de plus par chapitre jusqu'au chapitre 11) ; du chapitre 16 au chapitre 20, deux traits aux vagues 7 à 10.
## Fiche : `design/Champions_mutants_v0258.md`.

## Ordre d'introduction, un trait par chapitre (les deux premiers au chapitre 1).
const TRAITS: Array[String] = ["haste","shield","regen","colossus","split","armored","healer","avenger","immune","galvanizing","plunderer","revenant"]
const NAMES: Dictionary = {"haste":"Hâte","shield":"Bouclier","regen":"Régénération","colossus":"Colosse","split":"Scission","armored":"Blindé","healer":"Soigneur",
	"avenger":"Vengeur","immune":"Insensible","galvanizing":"Galvanisant","plunderer":"Pillard","revenant":"Revenant"}
const RULES: Dictionary = {"haste":"se déplace 35 % plus vite","shield":"bouclier de 30 % de ses PV, qui absorbe les dégâts en premier",
	"regen":"regagne 3 % de ses PV par seconde s'il n'est pas touché pendant 2 s","colossus":"PV doublés, plus grand, 15 % plus lent",
	"split":"se divise à sa mort en deux petits ennemis à 25 % de ses PV","armored":"subit 30 % de dégâts en moins des tirs directs",
	"healer":"soigne les ennemis proches de 2 % de leurs PV par seconde","avenger":"à sa mort, les ennemis proches gagnent 25 % de vitesse pendant 3 s",
	"immune":"ignore les ralentissements et les marques","galvanizing":"les ennemis proches avancent 15 % plus vite tant qu'il vit",
	"plunderer":"double ses dégâts à la forteresse","revenant":"se relève une fois avec 40 % de ses PV"}
## Couleur de l'aura et lettre de l'icône, dessinées par le code en attendant les icônes de Codex.
const COLORS: Dictionary = {"haste":Color("f2d36b"),"shield":Color("8fc7ff"),"regen":Color("7fe08a"),"colossus":Color("c98a5a"),"split":Color("e0a0ff"),"armored":Color("b8c0c8"),
	"healer":Color("9ff0c8"),"avenger":Color("ff8a6a"),"immune":Color("ffffff"),"galvanizing":Color("ffb347"),"plunderer":Color("e8c15a"),"revenant":Color("b48cff")}
const GLYPHS: Dictionary = {"haste":"H","shield":"B","regen":"R","colossus":"C","split":"S","armored":"A","healer":"+","avenger":"V","immune":"I","galvanizing":"G","plunderer":"P","revenant":"†"}

const FIRST_WAVE := 3
const DOUBLE_FROM_CHAPTER := 16
const DOUBLE_FROM_WAVE := 7
const ELIGIBLE_TYPES: Array[int] = [0,1,2,3,4,5]
const HP_FACTOR := 1.5
const COLOSSUS_HP_FACTOR := 2.0
const REWARD_FACTOR := 2
const HASTE_SPEED := 1.35
const COLOSSUS_SPEED := 0.85
const COLOSSUS_SCALE := 1.3
const SHIELD_FRACTION := 0.30
const REGEN_FRACTION := 0.03
const REGEN_QUIET := 2.0
const SPLIT_PARTS := 2
const SPLIT_FRACTION := 0.25
const SPLIT_TYPE := 0
const ARMOR_FACTOR := 0.70
const HEAL_FRACTION := 0.02
const NEAR_RADIUS := 1.5
const AVENGER_RADIUS := 2.0
const AVENGER_RATE := 0.25
const AVENGER_SECONDS := 3.0
const GALVANIZE_RATE := 0.15
const PULSE := 1.0
const PLUNDER_FACTOR := 2
const REVENANT_FRACTION := 0.40

## Traits débloqués au chapitre `chapter` (1 à 20) : deux au chapitre 1, un de plus par chapitre, les douze à partir du chapitre 11.
static func traits_for(chapter: int) -> Array[String]:
	var result: Array[String] = []
	if chapter < 1: return result
	for index in range(mini(TRAITS.size(),chapter+1)): result.append(TRAITS[index])
	return result

static func trait_count(chapter: int, wave: int) -> int:
	return 2 if chapter >= DOUBLE_FROM_CHAPTER and wave >= DOUBLE_FROM_WAVE else 1

## Champion de la vague : indice d'apparition et traits, tirés avec un générateur propre (graine de la partie, vague, chapitre) pour ne pas changer les offres de bonus.
## Vide avant la vague 3, sans chapitre ou sans ennemi admissible.
static func plan(schedule: Array, wave: int, chapter: int, seed: int) -> Dictionary:
	if chapter < 1 or wave < FIRST_WAVE: return {}
	var candidates: Array[int] = []
	for index in range(schedule.size()):
		if int(schedule[index].type) in ELIGIBLE_TYPES: candidates.append(index)
	if candidates.is_empty(): return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed,wave,chapter,"champion"])
	var index: int = candidates[rng.randi_range(0,candidates.size()-1)]
	var pool: Array[String] = traits_for(chapter)
	var chosen: Array[String] = []
	for _n in range(mini(trait_count(chapter,wave),pool.size())):
		var pick: String = pool[rng.randi_range(0,pool.size()-1)]
		chosen.append(pick)
		pool.erase(pick)
	return {"index":index,"traits":chosen}

static func has_trait(enemy: Dictionary, id: String) -> bool:
	return enemy.get("champion",false) and id in enemy.get("traits",[])

static func describe(traits: Array) -> String:
	var parts: Array[String] = []
	for id in traits: parts.append("%s : %s" % [NAMES.get(id,id),RULES.get(id,"")])
	return "\n".join(parts)
