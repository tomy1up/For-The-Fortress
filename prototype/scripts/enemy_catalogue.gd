extends RefCounted
## Identités des attaquants, séparées des huit profils statistiques et des défenseurs.
const NEUTRALS: Dictionary = {
	0: {"id":"enemy.neutral.wolf","name":"Loup de meute","origin":"neutral","profile":0},
	2: {"id":"enemy.neutral.boar","name":"Sanglier sauvage","origin":"neutral","profile":2},
	8: {"id":"enemy.neutral.turtle","name":"Tortue gardienne des berges","origin":"neutral","profile":8},
	9: {"id":"enemy.neutral.drowned","name":"Gueule-de-Vase","origin":"neutral","profile":9},
	3: {"id":"enemy.neutral.bear","name":"Ours sauvage","origin":"neutral","profile":3},
	11: {"id":"enemy.neutral.eagle","name":"Aigle des cimes","origin":"neutral","profile":11},
	12: {"id":"enemy.neutral.revenant","name":"Revenant","origin":"neutral","profile":12},
	13: {"id":"enemy.neutral.ibex","name":"Bouquetin des crêtes","origin":"neutral","profile":13},
	14: {"id":"enemy.neutral.magma_golem","name":"Golem de magma","origin":"neutral","profile":14},
	15: {"id":"enemy.neutral.ember","name":"Braise","origin":"neutral","profile":15},
	16: {"id":"enemy.neutral.scorpion","name":"Scorpion des dunes","origin":"neutral","profile":16},
	17: {"id":"enemy.neutral.mole","name":"Taupe des galeries","origin":"neutral","profile":17},
	18: {"id":"enemy.neutral.crab","name":"Crabe pilleur","origin":"neutral","profile":18},
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
	if defending_faction not in [0,1] or profile < 0 or profile > 18: return {}
	if NEUTRALS.has(profile): return NEUTRALS[profile].duplicate(true)
	return (HORDE if defending_faction == 0 else ALLIANCE)[profile].duplicate(true)

static func available(defending_faction: int, wave_set: String = "ford") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if defending_faction not in [0,1]: return result
	var profiles: Array[int] = [0,1,2,3,4,5,6,7]
	if wave_set == "ford_banks": profiles.append(8)
	if wave_set == "marsh_drowned": profiles.append(9)
	if wave_set == "citadel_garrison": profiles.append(10)
	if wave_set == "sky_eagles": profiles.append(11)
	if wave_set == "necro_revenants": profiles.append(12)
	if wave_set == "slate_ibex": profiles.append(13)
	if wave_set == "ash_golems": profiles.append_array([14,15])
	if wave_set == "dune_scorpions": profiles.append(16)
	if wave_set == "mine_moles": profiles.append(17)
	if wave_set == "coast_crabs": profiles.append(18)
	for profile in profiles: result.append(for_profile(profile,defending_faction))
	return result

static func by_id(id: String, defending_faction: int) -> Dictionary:
	for set_id in ["ford_banks","marsh_drowned","citadel_garrison","sky_eagles","necro_revenants","slate_ibex","ash_golems","dune_scorpions","mine_moles","coast_crabs"]:
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
