extends RefCounted
## Identités des attaquants, séparées des huit profils statistiques et des défenseurs.
const NEUTRALS: Dictionary = {
	0: {"id":"enemy.neutral.wolf","name":"Loup de meute","origin":"neutral","profile":0},
	2: {"id":"enemy.neutral.boar","name":"Sanglier sauvage","origin":"neutral","profile":2},
	8: {"id":"enemy.neutral.turtle","name":"Tortue gardienne des berges","origin":"neutral","profile":8},
	9: {"id":"enemy.neutral.drowned","name":"Noyé","origin":"neutral","profile":9},
	3: {"id":"enemy.neutral.bear","name":"Ours sauvage","origin":"neutral","profile":3},
}
const ALLIANCE: Dictionary = {
	1: {"id":"enemy.alliance.infantry","name":"Fantassin humain","origin":"alliance","profile":1},
	4: {"id":"enemy.alliance.scout","name":"Éclaireur elfe","origin":"alliance","profile":4},
	5: {"id":"enemy.alliance.siegebreaker","name":"Brise-remparts nain","origin":"alliance","profile":5},
	6: {"id":"enemy.alliance.guard","name":"Garde royal humain","origin":"alliance","profile":6},
	7: {"id":"enemy.alliance.marshal","name":"Maréchal de l’Alliance","origin":"alliance","profile":7},
	10: {"id":"enemy.alliance.garrison","name":"Capitaine de garnison humain","origin":"alliance","profile":10},
}
const HORDE: Dictionary = {
	1: {"id":"enemy.horde.warrior","name":"Guerrier orc","origin":"horde","profile":1},
	4: {"id":"enemy.horde.scout","name":"Éclaireur gobelin","origin":"horde","profile":4},
	5: {"id":"enemy.horde.colossus","name":"Colosse troll","origin":"horde","profile":5},
	6: {"id":"enemy.horde.guard","name":"Garde noir mort-vivant","origin":"horde","profile":6},
	7: {"id":"enemy.horde.warchief","name":"Chef de guerre orc","origin":"horde","profile":7},
	10: {"id":"enemy.horde.garrison","name":"Capitaine de garnison orc","origin":"horde","profile":10},
}

static func for_profile(profile: int, defending_faction: int) -> Dictionary:
	if defending_faction not in [0,1] or profile < 0 or profile > 10: return {}
	if NEUTRALS.has(profile): return NEUTRALS[profile].duplicate(true)
	return (HORDE if defending_faction == 0 else ALLIANCE)[profile].duplicate(true)

static func available(defending_faction: int, wave_set: String = "ford") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if defending_faction not in [0,1]: return result
	var profiles: Array[int] = [0,1,2,3,4,5,6,7]
	if wave_set == "ford_banks": profiles.append(8)
	if wave_set == "marsh_drowned": profiles.append(9)
	if wave_set == "citadel_garrison": profiles.append(10)
	for profile in profiles: result.append(for_profile(profile,defending_faction))
	return result

static func by_id(id: String, defending_faction: int) -> Dictionary:
	for set_id in ["ford_banks","marsh_drowned","citadel_garrison"]:
		for identity in available(defending_faction,set_id):
			if identity.id == id: return identity
	return {}

static func origin_label(origin: String) -> String:
	return {"neutral":"Neutre","alliance":"Alliance","horde":"Horde"}.get(origin,"")

static func robust_names(defending_faction: int) -> String:
	if defending_faction not in [0,1]: return ""
	var names: Array[String] = []
	for profile in [3,5,6,7]: names.append(for_profile(profile,defending_faction).name)
	return ", ".join(names)
