extends SceneTree
## Courbe de difficulté de la campagne : pour chaque mission et chaque faction, joue la composition de référence des tests de chapitre (emplacements 3, 4 puis 2 ; Alliance archer, arbalétrier, arbalétrier ;
## Horde deux haches et un chaman, puis deux sapeurs et un chaman à partir de la mission 71 (`tests/reference_army.gd`) ; talents réels de la mission, mêmes règles de partie que le jeu) et relève le résultat, les PV de forteresse restants et la vague atteinte.
## Les PV restants (sur les PV maximaux de la forteresse, 20 plus les bonus de talents de la faction) mesurent la marge : plus ils sont bas, plus la mission est serrée pour cette composition. Un changement d'une carte ou d'un réglage se lit directement sur la courbe.
## Avec ORDERS=all, les six ordres des trois emplacements 2, 3, 4 sont essayés et le meilleur est retenu (les anciens chapitres ont été réglés avec des ordres propres à chaque mission).
## Usage : FIRST=1 LAST=200 [FACTIONS=0,1] [ORDERS=all] godot --headless --path prototype --script res://tools/difficulty_curve.gd
## Sortie : lignes « CURVE mission faction PV_ennemis_% résultat PV_restants vague ordre PV_maximaux ».
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Reference = preload("res://tests/reference_army.gd")
const Experience = preload("res://scripts/talent_experience.gd")

func ranks_for(faction: int, mission: int) -> Array:
	var first: int = Reference.first_talent(faction,mission)
	var tree: int = Talents.coordinates(first).x
	var xp := 0
	for previous in range(1,mission): xp += int(Catalogue.definition(previous).xp)
	var points: int = Experience.points_for_xp(xp)
	var ranks: Array = Talents.empty_ranks()
	var priority: Array = [5,7,9,16,18]
	priority.append_array(range(21))
	for index in [first,first,first,first,first,Talents.index_for(tree,1)]:
		if Talents.allocation_error(ranks,index,points,faction).is_empty(): ranks[index] += 1
	while Talents.spent(ranks) < points:
		var allocated := false
		for local in priority:
			var index: int = Talents.index_for(tree,local)
			if Talents.allocation_error(ranks,index,points,faction).is_empty():
				ranks[index] += 1;allocated = true;break
		if not allocated: break
	return ranks

func play(mission: int, faction: int, slots: Array = [3,4,2]) -> Dictionary:
	var catalogue: Dictionary = Catalogue.definition(mission)
	var m = Model.new(true,Model.Maps.for_id(str(catalogue.map_id)))
	m.configure_wave_set(catalogue.get("wave_set_id","ford"))
	m.configure_enemy_hp(Catalogue.faction_hp_percent(mission,faction))
	m.configure_combat_affix(catalogue.get("combat_affix",{}))
	m.configure_wave_reinforcements(Catalogue.wave_reinforcements(mission,faction)) # renforts de mission (v0.252)
	m.meta_ranks = ranks_for(faction,mission)
	m.select_faction(faction)
	m.rng.seed = 7
	var types: Array = Reference.types(faction,mission)
	if not (m.buy(slots[0],types[0]) and m.buy(slots[1],types[1])): return {"result":"refus","hp":-1,"wave":0,"max":0}
	for wave in range(1,11):
		if wave == 2: m.upgrade(slots[0])
		if wave >= 2 and m.defenders[slots[2]].is_empty(): m.buy(slots[2],types[2])
		if wave >= 5:
			for slot in slots:
				if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		if not m.start(): break
		m.advance(10000)
		if m.phase == "defeat": break
		if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
		if wave < 10: m.prepare_next_wave()
	return {"result":m.phase,"hp":m.fortress_hp,"wave":m.wave,"max":m.max_hp}

func _initialize() -> void:
	var first: int = int(OS.get_environment("FIRST"))
	var last: int = int(OS.get_environment("LAST"))
	var factions: Array = [0,1]
	if OS.get_environment("FACTIONS") != "":
		factions = []
		for part in OS.get_environment("FACTIONS").split(","): factions.append(int(part))
	var orders: Array = [[3,4,2]]
	if OS.get_environment("ORDERS") == "all": orders = [[3,4,2],[4,3,2],[2,3,4],[4,2,3],[2,4,3],[3,2,4]]
	for mission in range(first,last+1):
		for faction in factions:
			var best: Dictionary = {}
			var best_order: Array = []
			for order in orders:
				var outcome: Dictionary = play(mission,faction,order)
				if best.is_empty() or int(outcome.hp) > int(best.hp):
					best = outcome;best_order = order
			print("CURVE %d %d %d %s %d %d %s %d" % [mission,faction,Catalogue.faction_hp_percent(mission,faction),best.result,best.hp,best.wave,"".join(PackedStringArray(best_order.map(func(x): return str(x)))),best.max])
	quit()
