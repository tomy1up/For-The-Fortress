extends SceneTree
## Mesure de l'équilibre de cartes candidates (refonte des cartes, v0.224) : joue la composition de référence des tests de chapitre (emplacements 3, 4 puis 2 ; Alliance archer, arbalétrier, arbalétrier ;
## Horde deux haches et un chaman ; talents réels de la mission) sur chaque carte d'un fichier JSON et imprime les PV de forteresse restants.
## Usage : CANDIDATES=chemin.json MISSION=114 [AFFIX=sandstorm] godot --headless --path prototype --script res://tools/sim_map_candidates.gd
## Entrée : [{"id":"c0","routes":[[[x,y],...],...],"slots":[[x,y],...6],"alternating":true|false}] ; ou {"old":"dune_arches"} pour mesurer une carte existante.
## Sortie : lignes « SIM index faction résultat pv vague ».
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Experience = preload("res://scripts/talent_experience.gd")

func vectors(points: Array) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for p in points: result.append(Vector2(float(p[0]),float(p[1])))
	return result

func definition_for(entry: Dictionary) -> Dictionary:
	if entry.has("old"): return Model.Maps.for_id(str(entry.old))
	var route_data: Array = []
	var names: Array = [""] if entry.routes.size() == 1 else ["upper","lower"] if entry.routes.size() == 2 else ["upper","middle","lower"]
	for index in range(entry.routes.size()): route_data.append([names[index],vectors(entry.routes[index])])
	var routes: Array[Dictionary] = []
	for entry_route in route_data:
		var points: Array[Vector2] = []
		points.assign(entry_route[1])
		routes.append({"id":entry_route[0],"path_points":points,"path_length":Model.Maps.measured_length(points)})
	var slot_points: Array[Vector2] = vectors(entry.slots)
	var board: Dictionary = {"id":"candidate_%s" % str(entry.id),"title":"Candidate","size":Vector2i(18,10),"path_points":routes[0].path_points,"path_length":routes[0].path_length,"slots":slot_points,"trees":[],"decoration":"desert"}
	if routes.size() > 1: board.routes = routes
	if bool(entry.get("alternating",false)): board.route_pattern = "alternating_pressure"
	return board

func ranks_for(faction: int, mission: int) -> Array:
	# Mêmes talents que les tests de chapitre : cinq rangs de la première ligne du premier arbre, puis la priorité habituelle.
	var first: int = 5 if faction == 0 else 0
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

func play(definition: Dictionary, faction: int, mission: int) -> Dictionary:
	var m = Model.new(true,definition)
	var catalogue: Dictionary = Catalogue.definition(mission)
	m.configure_wave_set(catalogue.get("wave_set_id","ford"))
	m.configure_enemy_hp(Catalogue.faction_hp_percent(mission,faction))
	m.configure_combat_affix(catalogue.get("combat_affix",{}))
	m.meta_ranks = ranks_for(faction,mission)
	m.select_faction(faction)
	m.rng.seed = 7
	var types: Array = [0,1,1] if faction == 0 else [3,3,5]
	var slots := [3,4,2]
	if not (m.buy(slots[0],types[0]) and m.buy(slots[1],types[1])): return {"result":"refus","hp":-1,"wave":0}
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
	return {"result":m.phase,"hp":m.fortress_hp,"wave":m.wave}

func _initialize() -> void:
	var mission: int = int(OS.get_environment("MISSION"))
	var file := FileAccess.open(OS.get_environment("CANDIDATES"),FileAccess.READ)
	var entries: Array = JSON.parse_string(file.get_as_text())
	for index in range(entries.size()):
		var definition: Dictionary = definition_for(entries[index])
		if definition.is_empty() or not Model.Maps.validation_error(definition).is_empty():
			print("SIM %d invalide" % index);continue
		for faction in range(2):
			var outcome: Dictionary = play(definition,faction,mission)
			print("SIM %d %d %s %d %d" % [index,faction,outcome.result,outcome.hp,outcome.wave])
	quit()
