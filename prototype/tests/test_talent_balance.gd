extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Linked = preload("res://scripts/meta_talents_linked.gd")
const Expanded = preload("res://scripts/meta_talents_expanded.gd")
const Replay = preload("res://tests/report_replay.gd")
## Armée naturelle de chaque arbre [faction][arbre] : l'unité améliorée par l'arbre est achetée à l'ouverture.
const ARMIES: Array = [[[0,1,2],[0,1,2],[2,0,1]],[[3,4,5],[5,3,4],[4,3,5]]]
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_scale()
	verify_legacy_rules()
	verify_parity()
	print("TALENT_BALANCE_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func verify_scale() -> void:
	for table in [Expanded.TREE_SCALE,Expanded.TREE_SCALE_V168]: check(table.size() == 2 and table.all(func(faction):return faction.size() == 3 and faction.all(func(tree):return tree.size() == 2 and tree.all(func(value):return value > 0.0 and value <= 6.0))),"Une échelle de début et de fin par arbre, strictement positive et bornée")
	check(Expanded.TREE_SCALE[1] == Expanded.TREE_SCALE_V168[1],"Les arbres de la Horde ne changent pas entre la v0.168 et la v0.169")
	for faction in range(2):
		for tree in range(3):
			for local in range(Expanded.NODES_PER_TREE):
				var index: int = Expanded.index_for(tree,local)
				var original: Dictionary = Expanded.effect_for(faction,index,Expanded.RULES_HISTORICAL)
				var scaled: Dictionary = Expanded.effect_for(faction,index)
				var factor: float = Expanded.tree_scale(faction,tree,local)
				check(factor == float(Expanded.TREE_SCALE[faction][tree][0 if local in Expanded.EARLY_LOCALS else 1]),"Facteur lu selon la ligne du talent")
				check(original.keys() == scaled.keys() and original.get("types",[]) == scaled.get("types",[]) and original.get("hp",0) == scaled.get("hp",0),"L'échelle ne change ni les unités visées, ni les composantes, ni les PV de forteresse")
				for component in Expanded.SCALED_COMPONENTS:
					if original.has(component): check(absf(float(scaled[component])-float(original[component])*factor) <= 0.0006,"Composante %s de l'arbre %d, talent %d : valeur historique × facteur" % [component,tree,local])
	for faction in range(2):
		var ranks: Array = allocate(faction,1,51,[5,7,9,16,18])
		for type in ([0,1,2] if faction == 0 else [3,4,5]):
			var current: Dictionary = Linked.effects(faction,ranks,type)
			var balanced: Dictionary = Linked.effects(faction,ranks,type,Expanded.RULES_V168)
			for component in Expanded.SCALED_COMPONENTS:
				if faction == 1: check(is_equal_approx(current[component],balanced[component]),"Les talents de la Horde sont identiques en v0.168 et en v0.169")
				else: check(current[component] <= balanced[component]+0.000001,"Les talents de l'Alliance ne dépassent jamais leurs valeurs de la v0.168")
		check(Linked.extra_hp(faction,ranks) == Linked.extra_hp(faction,ranks),"PV de forteresse stables")

func verify_legacy_rules() -> void:
	for version in ["0.167","0.166","0.100","0.99.1","0.99","0.1"]: check(Replay.talent_rules_for(version) == Expanded.RULES_HISTORICAL,"La version %s garde les valeurs historiques des arbres" % version)
	check(Replay.talent_rules_for("0.168") == Expanded.RULES_V168,"La version 0.168 garde ses valeurs équilibrées")
	for version in ["0.169","0.200","1.0","1.0.0","","abc","0","0.x"]: check(Replay.talent_rules_for(version) == Expanded.RULES_CURRENT,"La version « %s » utilise les valeurs en vigueur" % version)
	var ranks: Array = allocate(0,2,51,[5,7,9,16,18])
	var stats: Dictionary = {}
	for rules in [Expanded.RULES_HISTORICAL,Expanded.RULES_V168,Expanded.RULES_CURRENT]:
		var model := Model.new(true);model.talent_rules = rules;model.meta_ranks = ranks.duplicate();model.select_faction(0);model.buy(3,2)
		stats[rules] = model.get_stats(3)
		stats[rules].max_hp = model.max_hp
		var expected: Dictionary = Linked.effects(0,ranks,2,rules)
		check(is_equal_approx(stats[rules].damage,Model.new(true).stats_for(2,1).damage*(1.0+expected.direct)),"Les règles %d donnent exactement les bonus de leur jeu de valeurs" % rules)
	check(stats[Expanded.RULES_V168].damage > stats[Expanded.RULES_HISTORICAL].damage and stats[Expanded.RULES_V168].range > stats[Expanded.RULES_HISTORICAL].range,"La v0.168 renforce le mage de l'arbre Arts arcaniques")
	check(stats[Expanded.RULES_CURRENT].damage < stats[Expanded.RULES_V168].damage and stats[Expanded.RULES_CURRENT].range < stats[Expanded.RULES_V168].range,"La v0.169 aligne les talents de l'Alliance sur ceux de la Horde (valeurs plus basses qu'en v0.168)")
	check(stats[Expanded.RULES_CURRENT].max_hp == stats[Expanded.RULES_HISTORICAL].max_hp,"Les trois jeux de règles donnent la même forteresse de départ")

func allocate(faction: int, tree: int, points: int, priority_head: Array) -> Array:
	var ranks: Array = Linked.empty_ranks()
	var priority: Array = priority_head.duplicate()
	priority.append_array(range(21))
	for step in range(points):
		for local in priority:
			var index: int = Linked.index_for(tree,local)
			if Linked.allocation_error(ranks,index,points,faction).is_empty():
				ranks[index] += 1
				break
	return ranks

func wins(map_id: String, faction: int, tree: int, ranks: Array, hp: int) -> bool:
	var m := Model.new(true,Model.Maps.for_id(map_id))
	m.enemy_hp_percent = hp
	m.meta_ranks = ranks.duplicate()
	m.select_faction(faction)
	m.rng.seed = 7
	var types: Array = ARMIES[faction][tree]
	var order := [3,4,2]
	m.buy(order[0],types[0]);m.buy(order[1],types[1])
	for wave in range(1,11):
		if wave == 2: m.upgrade(order[0])
		if wave >= 2 and m.defenders[order[2]].is_empty(): m.buy(order[2],types[2])
		if wave >= 5:
			for slot in order:
				if not m.defenders[slot].is_empty(): m.upgrade(slot,0 if m.defenders[slot].level == 3 else -1)
		m.start();m.advance(10000)
		if m.phase == "defeat": return false
		if m.phase == "bonus": m.choose_bonus(m.bonus_offer[0])
		if wave < 10: m.prepare_next_wave()
	return m.phase == "victory"

## PV ennemis maximaux (en %) qu'un arbre au maximum de points permet de battre avec son armée naturelle.
func threshold(map_id: String, faction: int, tree: int, ranks: Array) -> int:
	var low := 80
	var high := 700
	if not wins(map_id,faction,tree,ranks,low): return low
	if wins(map_id,faction,tree,ranks,high): return high
	while high-low > 2:
		var middle: int = (low+high)/2
		if wins(map_id,faction,tree,ranks,middle): low = middle
		else: high = middle
	return low

func verify_parity() -> void:
	# Les trois arbres d'une faction se valent à 51 points : puissance moyenne mesurée sur trois cartes à moins de 15 % d'écart.
	for faction in range(2):
		var results: Array[int] = []
		for tree in range(3):
			var ranks: Array = allocate(faction,tree,51,[5,7,9,16,18])
			var total := 0
			for map_id in ["valley_ford","slate_crossing","marsh_basins"]: total += threshold(map_id,faction,tree,ranks)
			results.append(total/3)
		print("TALENT_PARITY faction=",faction," seuils=",results)
		check(results.min() >= 140,"Chaque arbre apporte un gain réel à 51 points (faction %d)" % faction)
		check(float(results.max())/float(results.min()) <= 1.15,"Les trois arbres de la faction %d se valent à 51 points (écart moyen de puissance inférieur à 15 %%, sur trois cartes)" % faction)
