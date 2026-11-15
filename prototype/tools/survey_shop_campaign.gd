extends SceneTree
## Mesure O-016 : les unités de boutique changent-elles la tenue des finales de la campagne ?
## Pour chaque mission et faction : armée naturelle de chaque arbre de talents (tous les points gagnés dans un arbre), la troisième unité
## est soit celle de l'armée de base, soit une alternative de boutique débloquée à cette mission. Mesure : victoires et PV de forteresse restants.
## Usage : MISSIONS=178,190,200 godot --headless --path prototype --script res://tools/survey_shop_campaign.gd
## Sortie : lignes « SC mission=<n> faction=<f> unit=<id|base> runs=<n> wins=<n> hp=<moyenne des PV restants sur les victoires> ». Aucun profil joueur n'est lu.
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Experience = preload("res://scripts/talent_experience.gd")
const Shop = preload("res://scripts/shop_catalogue.gd")
const Survey = preload("res://tools/survey_campaign_sample.gd")
const LAYOUTS: Array = [[1,3,4],[2,4,5]]
## Emplacements des trois renforts (un joueur remplit ses six emplacements) : mêmes familles que les deux premières unités, recrutés aux vagues 3, 5 et 7 si l'or le permet.
const EXTRA_SLOTS: Array = [[0,2,5],[0,1,3]]
const EXTRA_WAVES: Array = [3,5,7]
var six_defenders := false
const SEED := 42

func ranks_for(faction: int, mission: int, tree: int) -> Array:
	var ranks: Array = Talents.empty_ranks()
	var xp := 0
	for previous in range(1,mission): xp += int(Catalogue.definition(previous).xp)
	var available: int = Experience.points_for_xp(xp)
	var first: int = Talents.index_for(tree,0)
	if not Talents.allocation_error(ranks,first,available,faction).is_empty(): return []
	ranks[first] += 1
	var priority: Array = [5,7,9,16,18]
	priority.append_array(range(21))
	for _remaining in range(available-Talents.spent(ranks)):
		for local in priority:
			var index: int = Talents.index_for(tree,local)
			if Talents.allocation_error(ranks,index,available,faction).is_empty():
				ranks[index] += 1
				break
	return ranks

## Retourne les PV de forteresse restants (-1 en cas de défaite, -2 si la configuration est refusée).
func play(faction: int, mission: int, tree: int, layout: Array, alternative: int) -> int:
	var definition: Dictionary = Catalogue.definition(mission)
	var m = Model.new(true,Model.Maps.for_id(definition.map_id))
	if not m.configure_wave_set(definition.get("wave_set_id","ford")) or not m.configure_enemy_hp(definition.hp_percent) or not m.configure_combat_affix(definition.get("combat_affix",{})): return -2
	if alternative >= 0 and not m.configure_auxiliary(alternative): return -2
	var ranks: Array = ranks_for(faction,mission,tree)
	if ranks.is_empty() or not Talents.valid(ranks): return -2
	m.meta_ranks = ranks
	if not m.select_faction(faction): return -2
	m.rng.seed = SEED
	var types: Array = Survey.natural_compositions(faction,tree)[0].duplicate()
	var third: int = alternative if alternative >= 0 else faction*3+int(types[2])
	if not m.buy(layout[0],faction*3+int(types[0])) or not m.buy(layout[1],faction*3+int(types[1])): return -2
	var extras: Array = EXTRA_SLOTS[LAYOUTS.find(layout)] if six_defenders else []
	var extra_types: Array = [int(types[0]),int(types[1]),int(types[0])]
	var army: Array = layout.duplicate()
	army.append_array(extras)
	for wave in range(1,11):
		if wave == 2: m.upgrade(layout[0])
		if wave >= 4 and m.defenders[layout[2]].is_empty(): m.buy(layout[2],third)
		for index in range(extras.size()):
			if wave >= EXTRA_WAVES[index] and m.defenders[extras[index]].is_empty(): m.buy(extras[index],faction*3+extra_types[index])
		if wave >= 5:
			for slot in army:
				if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		if not m.start(): return -2
		while m.active: m.advance(300.0)
		if m.phase == "defeat": return -1
		if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
		if wave < 10 and not m.prepare_next_wave(): return -2
	return m.fortress_hp if m.phase == "victory" else -1

func _initialize() -> void:
	six_defenders = OS.get_environment("SIX") == "1"
	var missions: PackedStringArray = OS.get_environment("MISSIONS").split(",",false)
	if missions.is_empty(): missions = PackedStringArray(["178","190","200"])
	for text in missions:
		var mission: int = int(text)
		for faction in range(2):
			var units: Array = [{"id":"base","type":-1}]
			for card in Shop.for_faction(faction):
				if int(card.type) >= 10 and int(card.get("unlock_missions",0)) <= mission: units.append({"id":card.id,"type":int(card.type)})
			for unit in units:
				var runs := 0
				var wins := 0
				var hp_total := 0
				var refused := 0
				for tree in range(3):
					for layout in LAYOUTS:
						var result: int = play(faction,mission,tree,layout,int(unit.type))
						if result == -2: refused += 1;continue
						runs += 1
						if result >= 0:
							wins += 1
							hp_total += result
				print("SC mission=%d faction=%d unit=%s runs=%d wins=%d hp=%.2f refused=%d" % [mission,faction,unit.id,runs,wins,float(hp_total)/maxf(1.0,float(wins)),refused])
	quit()
