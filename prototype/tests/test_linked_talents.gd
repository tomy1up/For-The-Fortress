extends SceneTree
const Linked = preload("res://scripts/meta_talents_linked.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
static func spend_to(ranks: Array, tree: int, target: int) -> bool:
	while Linked.tree_spent(ranks,tree) < target:
		var advanced: bool = false
		for local in range(21):
			if local in [9,18]: continue
			var index: int = Linked.index_for(tree,local)
			if Linked.allocation_error(ranks,index,51).is_empty():
				ranks[index] += 1;advanced = true;break
		if not advanced: return false
	return true
static func invest(ranks: Array, tree: int, local: int, target: int) -> bool:
	var index: int = Linked.index_for(tree,local)
	while ranks[index] < target:
		if not Linked.allocation_error(ranks,index,51).is_empty(): return false
		ranks[index] += 1
	return true
static func build(tree: int) -> Array:
	var ranks: Array = Linked.empty_ranks()
	for target_tree in [tree,(tree+1)%3]:
		if not invest(ranks,target_tree,5,3) or not invest(ranks,target_tree,0,2) or not invest(ranks,target_tree,7,3): return []
		if not spend_to(ranks,target_tree,15) or not invest(ranks,target_tree,9,1): return []
		if target_tree != tree:
			if not spend_to(ranks,target_tree,20): return []
			continue
		if not invest(ranks,tree,11,3) or not spend_to(ranks,tree,25) or not invest(ranks,tree,16,3): return []
		if not spend_to(ranks,tree,30) or not invest(ranks,tree,18,1): return []
	return ranks
func run_checks() -> void:
	for tree in range(3):
		var cells: Dictionary = {};var counts: Array = [0,0,0,0,0,0,0]
		for local in range(21):
			var index: int = Linked.index_for(tree,local);var cell: Vector2i = Linked.layout(index)
			check(cell.x >= 0 and cell.x < 4 and cell.y >= 0 and cell.y < 7 and not cells.has(cell),"Chaque talent occupe une cellule unique dans les quatre colonnes")
			cells[cell] = true;counts[cell.y] += 1
			var parent: int = Linked.parent_index(index)
			if parent >= 0: check(Linked.coordinates(parent).x == tree and Linked.layout(parent).y < cell.y,"Dépendance dans le même arbre, strictement descendante, sans cycle")
		check(counts == [3,3,3,4,4,3,1] and cells.size() < 28,"Lignes irrégulières et cellules réellement vides, dernier majeur isolé")
		var partial: Array = Linked.empty_ranks()
		partial[Linked.index_for(tree,5)] = 2;partial[Linked.index_for(tree,0)] = 3
		var child: int = Linked.index_for(tree,7)
		check(Linked.valid(partial) and Linked.lower_spent(partial,tree,1) == 5 and Linked.allocation_error(partial,child,51).contains("rang maximum"),"Palier ouvert mais enfant verrouillé tant que le parent n’est pas maximal")
		partial[child] = 1;check(not Linked.valid(partial),"Investissement enfant avec parent partiel refusé par le validateur")
		partial[child] = 0;partial[Linked.index_for(tree,5)] = 3
		check(Linked.allocation_error(partial,child,51).is_empty(),"Dernier rang du parent : enfant disponible si son palier est ouvert")
		for faction in range(2):
			var ranks: Array = build(tree)
			check(not ranks.is_empty() and Linked.valid(ranks) and Linked.spent(ranks) == 51 and Linked.tree_spent(ranks,tree) == 31,"Deux chaînes de prérequis compatibles avec la répartition 31/20")
			if ranks.is_empty(): continue
			for type in ([3,4,5] if faction == 0 else [0,1,2]): check(Linked.effects(faction,ranks,type) == {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0},"Aucun talent lié ne renforce la faction opposée")
			for local in Linked.PARENTS:
				var parent: int = Linked.index_for(tree,Linked.PARENTS[local])
				var bad: Array = ranks.duplicate();bad[parent] -= 1
				check(not Linked.valid(bad),"Chaque lien exige tous les rangs du parent, sans exception pour les majeurs")
			var optional: Array = ranks.duplicate();optional[Linked.index_for(tree,9)] = 0;optional[Linked.index_for(tree,8)] += 1
			check(Linked.valid(optional) and optional[Linked.index_for(tree,18)] == 1,"Le majeur intermédiaire reste facultatif pour atteindre le majeur final")
			if Linked.Base.valid(ranks):
				for type in range(6): check(Linked.effects(faction,ranks,type) == Linked.Base.effects(faction,ranks,type),"Calcul des effets identique au catalogue historique pour les mêmes rangs")
	print("LINKED_TALENTS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
