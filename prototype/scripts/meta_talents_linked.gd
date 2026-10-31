extends RefCounted
const Shop = preload("res://scripts/shop_catalogue.gd")
## Structure du prototype v0.88 ; liens et positions proposés, effets historiques conservés.
const Base = preload("res://scripts/meta_talents_expanded.gd")
const NODE_COUNT: int = Base.NODE_COUNT
const NODES_PER_TREE: int = Base.NODES_PER_TREE
const COLUMN_COUNT: int = 4
const MAX_POINTS: int = Base.MAX_POINTS
const MAX_RANKS: Array[int] = Base.MAX_RANKS
const THRESHOLDS: Array[int] = Base.THRESHOLDS
const ROWS: Array[int] = [0,1,1,2,2,0,0,1,2,3,3,3,4,4,4,5,5,5,6,4,3]
const PARENTS: Dictionary = {7:5,9:7,16:11,18:16}
const EXCLUSIONS: Array = [[3,4]]
const COLUMNS: Array = [
	[0,0,3,0,2,1,3,1,3,1,0,2,0,1,3,0,2,3,2,0,3],
	[3,3,0,3,1,2,0,2,0,2,3,1,3,2,0,3,1,0,1,3,0],
	[3,3,1,3,0,2,1,2,1,2,3,0,3,2,1,3,0,1,0,3,1]
]
const VISUAL_ROWS: Array[int] = [0,1,1,2,2,0,0,1,2,3,3,3,4,4,4,6,6,6,7,5,3]
const TIER_VISUAL_ROWS: Array[int] = [0,1,2,3,4,6,7]

static func index_for(tree: int, local: int) -> int: return Base.index_for(tree,local)
static func coordinates(index: int) -> Vector2i: return Base.coordinates(index)
static func empty_ranks() -> Array: return Base.empty_ranks()
static func spent(ranks: Array) -> int: return Base.spent(ranks)
static func tree_spent(ranks: Array, tree: int) -> int: return Base.tree_spent(ranks,tree)
static func tree_capacity() -> int:
	var total: int = 0
	for maximum in MAX_RANKS: total += maximum
	return total-1 # Les deux choix historiques à un rang restent exclusifs.

static func layout(index: int) -> Vector2i:
	var position: Vector2i = coordinates(index)
	return Vector2i(COLUMNS[position.x][position.y],VISUAL_ROWS[position.y])

static func parent_index(index: int) -> int:
	var position: Vector2i = coordinates(index)
	return index_for(position.x,PARENTS[position.y]) if PARENTS.has(position.y) else -1

static func parent_complete(ranks: Array, index: int) -> bool:
	var parent: int = parent_index(index)
	return parent < 0 or ranks[parent] == MAX_RANKS[coordinates(parent).y]

static func lower_spent(ranks: Array, tree: int, row: int) -> int:
	var total: int = 0
	for local in range(NODES_PER_TREE):
		if ROWS[local] < row: total += int(ranks[index_for(tree,local)])
	return total

static func valid(ranks: Variant) -> bool:
	if not ranks is Array or ranks.size() != NODE_COUNT: return false
	for index in range(NODE_COUNT):
		if not Base.Previous.integer(ranks[index],0,MAX_RANKS[coordinates(index).y]): return false
	if spent(ranks) > MAX_POINTS: return false
	for tree in range(3):
		if ranks[index_for(tree,3)] > 0 and ranks[index_for(tree,4)] > 0: return false
		for local in range(NODES_PER_TREE):
			var index: int = index_for(tree,local)
			if ranks[index] > 0 and (not parent_complete(ranks,index) or lower_spent(ranks,tree,ROWS[local]) < THRESHOLDS[ROWS[local]]): return false
	return true

static func normalize(ranks: Array) -> Array:
	if valid(ranks): return ranks.duplicate()
	if Base.Previous.current_valid(ranks):
		var converted: Array = Base.normalize(ranks)
		if valid(converted): return converted
	return [] # Une ancienne configuration incompatible exige une migration explicite.

static func allocation_error(ranks: Array, index: int, points: int, faction: int = 0) -> String:
	if not valid(ranks) or index < 0 or index >= NODE_COUNT: return "Configuration de talents invalide."
	var position: Vector2i = coordinates(index);var local: int = position.y
	if ranks[index] >= MAX_RANKS[local]: return "Talent au rang maximum."
	var parent: int = parent_index(index)
	if parent >= 0 and not parent_complete(ranks,index):
		return "Requiert %s au rang maximum : %d/%d actuellement." % [Base.node(faction,parent).name,ranks[parent],MAX_RANKS[coordinates(parent).y]]
	var missing: int = THRESHOLDS[ROWS[local]]-lower_spent(ranks,position.x,ROWS[local])
	if missing > 0: return "Encore %d points à dépenser dans les lignes précédentes de cet arbre." % missing
	if local in [3,4] and ranks[index_for(position.x,7-local)] > 0: return "L’autre spécialité de cette ligne est déjà choisie."
	if spent(ranks) >= MAX_POINTS: return "Plafond de 51 points investis atteint."
	if spent(ranks) >= points: return "Aucun point disponible : gagnez de l’XP en réussissant des missions avec cette faction."
	return ""

static func node(faction: int, index: int) -> Dictionary:
	var definition: Dictionary = Base.node(faction,index)
	if definition.is_empty(): return {}
	definition.description = Shop.talent_description(definition.description,faction)
	definition.row = ROWS[definition.local]
	definition.column = COLUMNS[definition.tree][definition.local]
	definition.parent = parent_index(index)
	return definition

static func effects(faction: int, ranks: Array, type: int) -> Dictionary:
	type = Shop.family(type)
	var result: Dictionary = {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0}
	if faction not in [0,1] or not valid(ranks) or type not in ([0,1,2] if faction == 0 else [3,4,5]): return result
	result = Base._core_effects(faction,ranks.slice(0,15),type)
	for index in range(15,NODE_COUNT):
		if ranks[index] == 0: continue
		var effect: Dictionary = Base.effect_for(faction,index)
		if type not in effect.get("types",[]): continue
		for component in result: result[component] += float(effect.get(component,0))*int(ranks[index])
	return result

static func extra_hp(faction: int, ranks: Array) -> int:
	if faction not in [0,1] or not valid(ranks): return 0
	var total: int = int(ranks[0])+int(ranks[1])+3*int(ranks[3]) if faction == 0 else 0
	for index in range(15,NODE_COUNT):
		if ranks[index] > 0: total += int(Base.effect_for(faction,index).get("hp",0))*int(ranks[index])
	return total

static func rank_preview(faction: int, ranks: Array, index: int) -> Dictionary:
	if faction not in [0,1] or not valid(ranks) or index < 0 or index >= NODE_COUNT: return {}
	var candidate: Array = ranks.duplicate();candidate[index] += 1
	if not valid(candidate): return {}
	var units: Array[Dictionary] = []
	for type in ([0,1,2] if faction == 0 else [3,4,5]):
		var before: Dictionary = effects(faction,ranks,type);var after: Dictionary = effects(faction,candidate,type)
		if before != after: units.append({"type":type,"before":before,"after":after})
	return {"hp_before":extra_hp(faction,ranks),"hp_after":extra_hp(faction,candidate),"units":units}

static func loadout_summary(faction: int, ranks: Array) -> Dictionary:
	if faction not in [0,1] or not valid(ranks): return {}
	var trees: Array[Dictionary] = []
	for tree in range(3):
		var nodes: Array[Dictionary] = []
		for local in range(NODES_PER_TREE):
			var index: int = index_for(tree,local)
			if ranks[index] == 0: continue
			var definition: Dictionary = node(faction,index)
			nodes.append({"name":definition.name,"rank":ranks[index],"maximum":definition.maximum,"description":definition.description})
		trees.append({"name":Base.Previous.TREES[faction][tree][0],"points":tree_spent(ranks,tree),"nodes":nodes})
	var units: Array[Dictionary] = []
	for type in ([0,1,2] if faction == 0 else [3,4,5]): units.append({"type":type,"bonuses":effects(faction,ranks,type)})
	return {"points":spent(ranks),"hp":extra_hp(faction,ranks),"trees":trees,"units":units,"rules":"linked_prototype"}
