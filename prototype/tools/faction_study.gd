extends SceneTree
## Étude de l'équilibre entre factions (v0.232) : pour chaque mission, chaque faction, chacun des trois arbres de talents (points réels de la mission, dépensés dans cet arbre) et chacune des dix compositions
## de trois unités de base (combinaisons avec répétition des trois unités de la faction, achetées de la moins chère à la plus chère : deux à l'ouverture, la troisième à la vague 2 ; emplacements 3, 4 puis 2 ; mêmes améliorations
## que les tests de chapitre), relève le résultat, les PV de forteresse restants et les PV maximaux. 30 parties par faction et par mission au lieu d'une seule composition.
## Avec AUX=1 et MISSIONS=3,8,13,… : mode unités de boutique (voir `run_auxiliary`).
## Usage : FIRST=1 LAST=200 [FACTIONS=0,1] [SAME_HP=1] godot --headless --path prototype --script res://tools/faction_study.gd
## Sortie : lignes « STUDY mission faction arbre composition résultat PV_restants PV_maximaux ».
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Experience = preload("res://scripts/talent_experience.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const Reference = preload("res://tests/reference_army.gd")

func ranks_for(tree: int, faction: int, mission: int) -> Array:
	var first: int = Talents.index_for(tree,0)
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

func play(mission: int, faction: int, tree: int, types: Array, auxiliary: int = -1) -> Dictionary:
	var catalogue: Dictionary = Catalogue.definition(mission)
	var m = Model.new(true,Model.Maps.for_id(str(catalogue.map_id)))
	m.configure_wave_set(catalogue.get("wave_set_id","ford"))
	# SAME_HP=1 : mêmes PV d'ennemis pour les deux factions (sans la réduction propre à la Horde), pour mesurer ce que cette réduction change.
	m.configure_enemy_hp(Catalogue.faction_hp_percent(mission,0 if OS.get_environment("SAME_HP") == "1" else faction))
	# HPMUL=150 : multiplie les PV d'ennemis de la mission (calibrage du rééquilibrage, sans passer par la validation 100-264 %).
	# (le multiplicateur s'applique aux PV d'avant rééquilibrage : on retire d'abord le coefficient de `Catalogue.rebalance_percent`)
	if OS.get_environment("HPMUL") != "":
		var played_faction: int = 0 if OS.get_environment("SAME_HP") == "1" else faction
		var before: float = float(m.enemy_hp_percent)*100.0/Catalogue.rebalance_percent(mission,played_faction)
		m.enemy_hp_percent = int(round(before*float(OS.get_environment("HPMUL"))/100.0))
	m.configure_combat_affix(catalogue.get("combat_affix",{}))
	if auxiliary >= 0: m.configure_auxiliary(auxiliary)
	m.meta_ranks = ranks_for(tree,faction,mission)
	m.select_faction(faction)
	m.rng.seed = int(OS.get_environment("SEED")) if OS.get_environment("SEED") != "" else 7
	if OS.get_environment("LEGACY") == "1": m.rules_v232 = false # anciennes règles : douze bonus, choix après les vagues 3, 6 et 9
	if OS.get_environment("V232") == "1": m.rules_v233 = false # règles de la v0.232 : 36 bonus tirés uniformément, sans rareté ni relance
	var slots := [3,4,2]
	types = types.duplicate()
	types.sort_custom(func(x, y): return m.purchase_cost(x) < m.purchase_cost(y)) # les deux moins chères à l'ouverture, la plus chère à la vague 2
	if not (m.buy(slots[0],types[0]) and m.buy(slots[1],types[1])): return {"result":"refus","hp":-1,"max":m.max_hp}
	for wave in range(1,11):
		if wave == 2: m.upgrade(slots[0])
		if wave >= 2 and m.defenders[slots[2]].is_empty(): m.buy(slots[2],types[2])
		if wave >= 5:
			for slot in slots:
				if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		if not m.start(): break
		m.advance(10000)
		if m.phase == "defeat": break
		if m.phase == "bonus": m.choose_bonus(_pick(m))
		if wave < 10: m.prepare_next_wave()
	return {"result":m.phase,"hp":m.fortress_hp,"max":m.max_hp}

## POLICY=safe : écarte les bonus à contrepartie (Pari risqué, Forteresse blindée, Élite sacrifiée : codes 19, 23 et 24) quand une autre offre existe ; sinon la première offre, comme avant.
func _pick(m) -> int:
	if OS.get_environment("POLICY") == "ref": return Model.reference_bonus(m.bonus_offer) # choix de bonus des tests de chapitre
	if OS.get_environment("POLICY") == "safe":
		for code in m.bonus_offer:
			if not int(code) in [19,23,24]: return int(code)
	return int(m.bonus_offer[0])

func run_auxiliary(missions: Array, factions: Array) -> void:
	# AUX=1 : avec une unité de boutique (déjà débloquée à cette mission : `unlock_missions` <= missions précédentes réussies), compositions de trois unités parmi les trois de base et l'unité de boutique,
	# contenant au moins une unité de boutique (10 compositions), pour chaque arbre. Sortie : « STUDYAUX mission faction arbre type_boutique composition résultat PV_restants PV_maximaux » (indices 0 à 2 : unités de base, 3 : boutique).
	for mission in missions:
		for faction in factions:
			var base: int = 0 if faction == 0 else 3
			for card in Shop.for_faction(faction):
				if int(card.get("unlock_missions",0)) > mission-1: continue
				for tree in range(3):
					for a in range(4):
						for b in range(a,4):
							for c in range(b,4):
								if c != 3: continue # au moins une unité de boutique (indice 3, le plus grand)
								var types: Array = []
								for index in [a,b,c]: types.append(int(card.type) if index == 3 else base+index)
								var outcome: Dictionary = play(mission,faction,tree,types,int(card.type))
								print("STUDYAUX %d %d %d %d %d%d%d %s %d %d" % [mission,faction,tree,int(card.type),a,b,c,outcome.result,outcome.hp,outcome.max])

func _initialize() -> void:
	var first: int = int(OS.get_environment("FIRST"))
	var last: int = int(OS.get_environment("LAST"))
	var factions: Array = [0,1]
	if OS.get_environment("FACTIONS") != "":
		factions = []
		for part in OS.get_environment("FACTIONS").split(","): factions.append(int(part))
	if OS.get_environment("AUX") == "1":
		var missions: Array = []
		for part in OS.get_environment("MISSIONS").split(","): missions.append(int(part))
		run_auxiliary(missions,factions)
		quit()
		return
	var list: Array = range(first,last+1)
	if OS.get_environment("MISSIONS") != "":
		list = []
		for part in OS.get_environment("MISSIONS").split(","): list.append(int(part))
	if OS.get_environment("REFONLY") == "1":
		# REFONLY=1 : seulement la composition de référence des tests de chapitre (`tests/reference_army.gd`), dans l'arbre qu'ils emploient ; OLDREF=1 : deux haches et un chaman (arbre 0) sur toute la campagne, référence de la Horde jusqu'à la v0.234.
		# Sortie : « REF mission faction résultat PV_restants PV_maximaux ».
		for mission in list:
			for faction in factions:
				var old_reference: bool = faction == 1 and OS.get_environment("OLDREF") == "1"
				var reference_tree: int = Talents.coordinates(0 if old_reference else Reference.first_talent(faction,mission)).x
				var outcome: Dictionary = play(mission,faction,reference_tree,[3,3,5] if old_reference else Reference.types(faction,mission))
				print("REF %d %d %s %d %d" % [mission,faction,outcome.result,outcome.hp,outcome.max])
		quit()
		return
	for mission in list:
		for faction in factions:
			var base: int = 0 if faction == 0 else 3
			for tree in range(3):
				for a in range(3):
					for b in range(a,3):
						for c in range(b,3):
							var outcome: Dictionary = play(mission,faction,tree,[base+a,base+b,base+c])
							print("STUDY %d %d %d %d%d%d %s %d %d" % [mission,faction,tree,a,b,c,outcome.result,outcome.hp,outcome.max])
	quit()
