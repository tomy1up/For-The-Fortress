extends SceneTree
const Expanded = preload("res://scripts/meta_talents_expanded.gd")
const Previous = preload("res://scripts/meta_talents_v068.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
static func spend_to(ranks: Array, tree: int, target: int) -> bool:
	while Expanded.tree_spent(ranks,tree) < target:
		var advanced: bool = false
		for local in range(Expanded.NODES_PER_TREE):
			var index: int = Expanded.index_for(tree,local)
			if Expanded.allocation_error(ranks,index,Expanded.MAX_POINTS).is_empty():
				ranks[index] += 1;advanced = true;break
		if not advanced: return false
	return true
static func deep_build(tree: int, ending: int = 15) -> Array:
	var ranks: Array = Expanded.empty_ranks()
	if not spend_to(ranks,tree,25): return []
	var index: int = Expanded.index_for(tree,ending)
	if not Expanded.allocation_error(ranks,index,36).is_empty(): return []
	ranks[index] += 1
	if not spend_to(ranks,(tree+1)%3,10): return []
	return ranks
func run_checks() -> void:
	check(Expanded.NODE_COUNT == 54 and Expanded.NODES_PER_TREE == 18 and Expanded.THRESHOLDS.size() == 6,"Trois arbres enrichis de dix-huit talents sur six lignes")
	check(Expanded.tree_capacity() == 40 and Expanded.MAX_POINTS < 3*Expanded.tree_capacity(),"36 points provisoires pour 120 rangs légaux : impossible de tout remplir")
	var indices: Dictionary = {}
	for tree in range(3):
		for local in range(18):
			var index: int = Expanded.index_for(tree,local);indices[index] = true
			check(Expanded.coordinates(index) == Vector2i(tree,local),"Correspondance stable du talent et de son arbre")
	check(indices.size() == 54 and indices.has(0) and indices.has(53),"Tous les emplacements couverts sans collision")
	for old in [Previous.empty_ranks(),[5,3,3,1,0,5,3,3,0,1,5,3,3,1,0],[5,3,2,1,0,5,3,2,1,0,5,3,2,1,0],[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]:
		var normalized: Array = Expanded.normalize(old)
		check(Expanded.valid(normalized) and normalized.slice(0,15) == old and Expanded.spent(normalized) == Previous.spent(old),"Ancien investissement conservé aux quinze identifiants historiques")
		for faction in range(2):
			for type in range(6): check(Expanded.effects(faction,normalized,type) == Previous.effects(faction,old,type),"Effets des anciens talents préservés exactement, y compris le refus du camp opposé")
			check(Expanded.extra_hp(faction,normalized) == Previous.extra_hp(faction,old),"PV des configurations historiques préservés")
	for faction in range(2):
		for index in range(54):
			var node: Dictionary = Expanded.node(faction,index)
			check(not node.name.is_empty() and not node.description.is_empty() and node.maximum > 0,"Chaque talent possède nom, description, nombre de rangs et effet")
			for type in node.effect.get("types",[]): check(type in ([0,1,2] if faction == 0 else [3,4,5]),"Les talents ciblent exclusivement les unités de leur faction")
		for tree in range(3):
			for ending in [15,16,17]:
				var ranks: Array = deep_build(tree,ending)
				check(not ranks.is_empty() and Expanded.valid(ranks) and Expanded.spent(ranks) == 36 and Expanded.tree_spent(ranks,tree) == 26,"Investissement profond et appui d’un second arbre réalisables dans le plafond")
				for other in [15,16,17]:
					if other == ending: continue
					var candidate: Array = ranks.duplicate();candidate[Expanded.index_for(tree,other)] = 1
					check(not Expanded.valid(candidate),"Dernières spécialités exclusives même avec des points supplémentaires")
				var extra: int = Expanded.index_for((tree+2)%3,0)
				check(Expanded.allocation_error(ranks,extra,1000).contains("Plafond"),"Même un compte très riche ne contourne pas le plafond investi")
				for type in ([3,4,5] if faction == 0 else [0,1,2]): check(Expanded.effects(faction,ranks,type) == {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0},"Un build complet ne renforce jamais l’autre faction")
				check(Expanded.loadout_summary(faction,ranks).points == 36,"Résumé issu des mêmes rangs et effets")
	var invalid: Array = Expanded.empty_ranks();invalid[Expanded.index_for(1,15)] = 1
	check(not Expanded.valid(invalid),"Spécialité profonde impossible sans paliers investis dans cet arbre")
	invalid = Expanded.empty_ranks();invalid[0] = -1;check(not Expanded.valid(invalid),"Rang négatif refusé")
	invalid = Expanded.empty_ranks();invalid[0] = 6;check(not Expanded.valid(invalid),"Rang supérieur au maximum refusé")
	var first: Array = Expanded.normalize(Previous.empty_ranks());first[0] = 1
	check(Expanded.spent(Previous.empty_ranks()) == 0,"Normaliser ne mutile pas la configuration d’origine")
	print("EXPANDED_TALENTS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
