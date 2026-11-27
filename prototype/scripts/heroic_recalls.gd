extends RefCounted
## Cumul des nouveautés de l'Héroïque (v0.259, lot 3 du cadrage ; règles et valeurs validées par le porteur le 26 novembre 2026, « Tout valider » ;
## réglages de prototype à confirmer en jeu). Fiche : `design/Cumul_nouveautes_v0259.md`.
## À partir du chapitre 3, chaque mission rappelle une nouveauté d'un biome déjà traversé : un ancien attaquant (missions impaires) ou un ancien affixe
## (missions paires), à tour de rôle. À partir du chapitre 11, deux rappels par mission : un attaquant et un affixe, de deux biomes différents.
## Le rappel est fixe pour chaque mission, sans hasard, et jamais le même deux missions de suite.

const FIRST_CHAPTER := 3
const DOUBLE_FROM_CHAPTER := 11
## Décalage de l'affixe rappelé, en secondes de combat : il tombe entre deux déclenchements de l'affixe du biome.
const AFFIX_OFFSET := 6.0
## Vagues qui reçoivent le groupe de l'attaquant rappelé.
const WAVES: Array[int] = [4,7,10]
const BIOME_NAMES: Array[String] = ["","Gué","Ardoises","Marais","Terres volcaniques","Citadelle","Désert","Mines","Îles flottantes","Côtes","Nécropole"]
## Attaquant rappelé par biome : type, taille du groupe, espacement (s) et vagues. Le Marais (Gueule-de-Vase : régénère seulement dans l'eau du marais) et
## le Désert (Scorpion : accélère seulement dans la tempête) ne rappellent que leur affixe ; la Nécropole, dernier biome, n'est jamais rappelée.
const ATTACKERS := {
	1:{"type":8,"name":"Tortue gardienne","count":2,"interval":3.0,"waves":[4,7,10]},
	2:{"type":13,"name":"Bouquetin des crêtes","count":4,"interval":2.0,"waves":[4,7,10]},
	4:{"type":14,"name":"Golem de magma","count":2,"interval":4.0,"waves":[4,7,10]},
	5:{"type":10,"name":"Capitaine de garnison","count":1,"interval":0.0,"waves":[7,10]},
	7:{"type":17,"name":"Taupe des galeries","count":4,"interval":1.6,"waves":[4,7,10]},
	8:{"type":11,"name":"Aigle des cimes","count":8,"interval":0.6,"waves":[4,7,10]},
	9:{"type":18,"name":"Crabe pilleur","count":3,"interval":2.5,"waves":[4,7,10]},
}
const TYPES: Array[int] = [8,13,14,10,17,11,18]
const MAX_GROUPS := 6

static func chapter_of(number: int) -> int:
	return (number-1)/10+1

static func biome_of_chapter(chapter: int) -> int:
	return (chapter+1)/2

## Rappels de la mission `number` (1 à 200) : {"attacker": biome, "affix": biome}, 0 quand il n'y en a pas.
static func plan(number: int) -> Dictionary:
	var result: Dictionary = {"attacker":0,"affix":0}
	var chapter: int = chapter_of(number)
	if number < 1 or number > 200 or chapter < FIRST_CHAPTER: return result
	var biome: int = biome_of_chapter(chapter)
	var attackers: Array[int] = []
	for key in ATTACKERS.keys():
		if int(key) < biome: attackers.append(int(key))
	attackers.sort()
	var affixes: Array[int] = []
	for key in range(1,biome): affixes.append(key)
	if chapter < DOUBLE_FROM_CHAPTER:
		var turn: int = number/2
		if number%2 == 1: result.attacker = attackers[turn%attackers.size()]
		else: result.affix = affixes[turn%affixes.size()]
		return result
	result.attacker = attackers[number%attackers.size()]
	# Affixe : à partir de la position de la mission, le premier biome différent de l'attaquant et de l'affixe de la mission précédente.
	var previous: int = int(plan(number-1).affix)
	var start: int = number%affixes.size()
	for step in range(affixes.size()):
		var candidate: int = affixes[(start+step)%affixes.size()]
		if candidate != result.attacker and candidate != previous:
			result.affix = candidate
			break
	return result

## Groupes de l'attaquant rappelé, au format des renforts de vague : [vague, type, nombre, espacement].
static func attacker_groups(biome: int) -> Array:
	var result: Array = []
	if not ATTACKERS.has(biome): return result
	var spec: Dictionary = ATTACKERS[biome]
	for wave in spec.waves: result.append([int(wave),int(spec.type),int(spec.count),float(spec.interval)])
	return result

static func valid_attackers(value: Variant) -> bool:
	if not value is Array or value.size() > MAX_GROUPS: return false
	for group in value:
		if not group is Array or group.size() != 4: return false
		for index in range(3):
			if not (group[index] is int or group[index] is float) or float(group[index]) != floorf(float(group[index])): return false
		if not (group[3] is int or group[3] is float) or not is_finite(float(group[3])): return false
		if int(group[0]) < 1 or int(group[0]) > 10 or int(group[1]) not in TYPES or int(group[2]) < 1 or int(group[2]) > 10 or float(group[3]) < 0.0 or float(group[3]) > 5.0: return false
	return true

static func normalized_attackers(value: Array) -> Array:
	var result: Array = []
	for group in value: result.append([int(group[0]),int(group[1]),int(group[2]),float(group[3])])
	return result

## Texte court pour la fiche de mission : « Rappel : Golem de magma (Terres volcaniques) · Crue (Gué) ».
static func describe(number: int, affix_names: Dictionary, affix_ids: Dictionary) -> String:
	var recall: Dictionary = plan(number)
	var parts: Array[String] = []
	if int(recall.attacker) > 0: parts.append("%s (%s)" % [ATTACKERS[int(recall.attacker)].name,BIOME_NAMES[int(recall.attacker)]])
	if int(recall.affix) > 0: parts.append("%s (%s)" % [affix_names.get(affix_ids.get(int(recall.affix),""),"?"),BIOME_NAMES[int(recall.affix)]])
	return "" if parts.is_empty() else "Rappel : " + " · ".join(parts)
