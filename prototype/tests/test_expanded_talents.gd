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
static func deep_build(tree: int, ending: int = 18) -> Array:
	var ranks: Array = Expanded.empty_ranks()
	if not spend_to(ranks,tree,15): return []
	ranks[Expanded.index_for(tree,9)] += 1
	if not spend_to(ranks,tree,30): return []
	var index: int = Expanded.index_for(tree,ending)
	if not Expanded.allocation_error(ranks,index,51).is_empty(): return []
	ranks[index] += 1
	if not spend_to(ranks,(tree+1)%3,15): return []
	ranks[Expanded.index_for((tree+1)%3,9)] += 1
	if not spend_to(ranks,(tree+1)%3,20): return []
	return ranks
func run_checks() -> void:
	check(Expanded.NODE_COUNT == 63 and Expanded.NODES_PER_TREE == 21 and Expanded.THRESHOLDS.size() == 7,"Trois arbres enrichis de vingt-et-un talents sur sept lignes")
	check(Expanded.tree_capacity() == 43 and Expanded.MAX_POINTS < 3*Expanded.tree_capacity(),"51 points provisoires pour 129 rangs légaux : impossible de tout remplir")
	var indices: Dictionary = {}
	for tree in range(3):
		for local in range(21):
			var index: int = Expanded.index_for(tree,local);indices[index] = true
			check(Expanded.coordinates(index) == Vector2i(tree,local),"Correspondance stable du talent et de son arbre")
	check(indices.size() == 63 and indices.has(0) and indices.has(62),"Tous les emplacements couverts sans collision")
	for tree in range(3):
		var major_count: int = 0
		for local in range(21):
			var definition: Dictionary = Expanded.node(0,Expanded.index_for(tree,local))
			if definition.major:
				major_count += 1
				check(definition.maximum == 1 and Expanded.THRESHOLDS[definition.row] in [15,30],"Talents majeurs à un rang aux seuils 15 et 30")
		check(major_count == 2,"Exactement deux talents majeurs par arbre")
		var optional: Array = Expanded.empty_ranks()
		while Expanded.tree_spent(optional,tree) < 30:
			var advanced: bool = false
			for local in range(21):
				if local == 9: continue
				var index: int = Expanded.index_for(tree,local)
				if Expanded.allocation_error(optional,index,51).is_empty():
					optional[index] += 1;advanced = true;break
			if not advanced: break
		check(Expanded.tree_spent(optional,tree) == 30 and Expanded.allocation_error(optional,Expanded.index_for(tree,18),51).is_empty(),"Le talent majeur intermédiaire est facultatif pour atteindre le dernier palier")
		optional[Expanded.index_for(tree,18)] += 1
		check(Expanded.valid(optional),"Dernier talent majeur accessible au 31e point")
		var alternate: Array = optional.duplicate();alternate[Expanded.index_for(tree,18)] = 0
		alternate[Expanded.index_for(tree,19)] = 3
		check(Expanded.valid(alternate),"Une alternative exclusive peut atteindre ses trois rangs sans être confondue avec trois choix différents")
	var hybrid: Array = Expanded.empty_ranks()
	check(spend_to(hybrid,0,19) and spend_to(hybrid,1,16) and spend_to(hybrid,2,16) and Expanded.valid(hybrid) and Expanded.spent(hybrid) == 51,"Répartition hybride 19/16/16 autorisée")
	check(2*31 > Expanded.MAX_POINTS,"Deux talents de dernier palier nécessitent davantage que les 51 points disponibles")
	for old in [Previous.empty_ranks(),[5,3,3,1,0,5,3,3,0,1,5,3,3,1,0],[5,3,2,1,0,5,3,2,1,0,5,3,2,1,0],[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]:
		var normalized: Array = Expanded.normalize(old)
		check(Expanded.valid(normalized) and normalized.slice(0,15) == old and Expanded.spent(normalized) == Previous.spent(old),"Ancien investissement conservé aux quinze identifiants historiques")
		for faction in range(2):
			for type in range(6): check(Expanded.effects(faction,normalized,type) == Previous.effects(faction,old,type),"Effets des anciens talents préservés exactement, y compris le refus du camp opposé")
			check(Expanded.extra_hp(faction,normalized) == Previous.extra_hp(faction,old),"PV des configurations historiques préservés")
	for faction in range(2):
		for index in range(63):
			var node: Dictionary = Expanded.node(faction,index)
			check(not node.name.is_empty() and not node.description.is_empty() and node.maximum > 0,"Chaque talent possède nom, description, nombre de rangs et effet")
			for type in node.effect.get("types",[]): check(type in ([0,1,2] if faction == 0 else [3,4,5]),"Les talents ciblent exclusivement les unités de leur faction")
		for tree in range(3):
			for ending in [18,19,20]:
				var ranks: Array = deep_build(tree,ending)
				check(not ranks.is_empty() and Expanded.valid(ranks) and Expanded.spent(ranks) == 51 and Expanded.tree_spent(ranks,tree) == 31,"Investissement profond et appui d’un second arbre réalisables dans le plafond")
				for other in [18,19,20]:
					if other == ending: continue
					var candidate: Array = ranks.duplicate()
					for local in range(21): candidate[Expanded.index_for((tree+1)%3,local)] = 0
					candidate[Expanded.index_for(tree,other)] = 1
					check(not Expanded.valid(candidate),"Dernières spécialités exclusives même avec des points supplémentaires")
				var extra: int = Expanded.index_for((tree+2)%3,0)
				check(Expanded.allocation_error(ranks,extra,1000).contains("Plafond"),"Même un compte très riche ne contourne pas le plafond investi")
				for type in ([3,4,5] if faction == 0 else [0,1,2]): check(Expanded.effects(faction,ranks,type) == {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0},"Un build complet ne renforce jamais l’autre faction")
				check(Expanded.loadout_summary(faction,ranks).points == 51,"Résumé issu des mêmes rangs et effets")
	var invalid: Array = Expanded.empty_ranks();invalid[Expanded.index_for(1,18)] = 1
	check(not Expanded.valid(invalid),"Spécialité profonde impossible sans paliers investis dans cet arbre")
	invalid = Expanded.empty_ranks();invalid[0] = -1;check(not Expanded.valid(invalid),"Rang négatif refusé")
	invalid = Expanded.empty_ranks();invalid[0] = 6;check(not Expanded.valid(invalid),"Rang supérieur au maximum refusé")
	var first: Array = Expanded.normalize(Previous.empty_ranks());first[0] = 1
	check(Expanded.spent(Previous.empty_ranks()) == 0,"Normaliser ne mutile pas la configuration d’origine")
	print("EXPANDED_TALENTS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
