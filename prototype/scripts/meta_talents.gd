extends RefCounted
## Barème de prototype. Les rangs historiques restent lisibles pour le rejeu v0.67.
const Legacy = preload("res://scripts/meta_talents_v067.gd")
const POINT_PRICE: int = 10
const RESET_PRICES: Array[int] = [2,4,6,8,10]
const NODES_PER_TREE: int = 5
const MAX_POINTS: int = 36
const MAX_RANKS: Array[int] = [5,3,3,1,1]
const ROWS: Array[int] = [0,1,1,2,2]
const THRESHOLDS: Array[int] = [0,5,10]
const TREES: Array = [
	[
		["Bastion",["Remparts renforcés","+1 PV maximum par rang."],["Fondations","+1 PV maximum par rang."],["Veille","+0,05 de portée pour tous par rang."],["Résistance","+3 PV maximum."],["Vigilance","+0,15 de portée pour tous."]],
		["Maîtrise du tir",["Entraînement","Archer et arbalétrier : +3 % aux tirs par rang."],["Pointes affûtées","Archer et arbalétrier : +2 % aux tirs par rang."],["Ligne de mire","Archer et arbalétrier : +0,1 de portée par rang."],["Tirs concentrés","Archer et arbalétrier : +8 % aux tirs."],["Couverture","Archer et arbalétrier : +0,3 de portée."]],
		["Arts arcaniques",["Étude des arcanes","Mage : +3 % à tous ses dégâts par rang."],["Concentration","Mage : +2 % au tir principal par rang."],["Étincelles","Mage : +3 % aux explosions par rang."],["Puissance directe","Mage : +8 % au tir principal."],["Déflagration","Mage : +15 % aux explosions."]]
	],
	[
		["Fureur de guerre",["Entraînement","Lanceur de haches : +3 % au tir par rang."],["Haches affûtées","Lanceur de haches : +2 % au tir par rang."],["Rebonds précis","Lanceur de haches : +3 % aux rebonds par rang."],["Frappe précise","Lanceur de haches : +8 % au tir principal."],["Ricochets","Lanceur de haches : +15 % aux rebonds."]],
		["Voie des maléfices",["Rituels","Chaman : +3 % à tous ses dégâts par rang."],["Focalisation","Chaman : +2 % au tir principal par rang."],["Mauvais présage","Chaman : +3 % aux malédictions par rang."],["Choc initial","Chaman : +8 % au tir principal."],["Usure","Chaman : +15 % aux malédictions."]],
		["Démolition",["Explosifs","Sapeur : +3 % à tous ses dégâts par rang."],["Charge concentrée","Sapeur : +2 % au tir principal par rang."],["Éclats renforcés","Sapeur : +3 % aux explosions par rang."],["Impact","Sapeur : +8 % au tir principal."],["Détonation","Sapeur : +15 % aux explosions."]]
	]
]

static func empty_ranks() -> Array:
	var ranks: Array = [];ranks.resize(15);ranks.fill(0);return ranks

static func integer(value: Variant, minimum: int, maximum: int) -> bool:
	return Legacy.integer(value,minimum,maximum)

static func spent(ranks: Array) -> int:
	return Legacy.spent(ranks)

static func tree_spent(ranks: Array, tree: int) -> int:
	var total: int = 0
	for node in range(NODES_PER_TREE): total += int(ranks[tree*NODES_PER_TREE+node])
	return total

static func lower_spent(ranks: Array, tree: int, row: int) -> int:
	var total: int = 0
	for node in range(NODES_PER_TREE):
		if ROWS[node] < row: total += int(ranks[tree*NODES_PER_TREE+node])
	return total

static func current_valid(ranks: Variant) -> bool:
	if not ranks is Array or ranks.size() != 15: return false
	for tree in range(3):
		var base: int = tree*NODES_PER_TREE
		for node in range(NODES_PER_TREE):
			if not integer(ranks[base+node],0,MAX_RANKS[node]): return false
		if ranks[base+3]+ranks[base+4] > 1: return false
		for node in range(1,NODES_PER_TREE):
			if ranks[base+node] > 0 and lower_spent(ranks,tree,ROWS[node]) < THRESHOLDS[ROWS[node]]: return false
	return true

static func valid(ranks: Variant) -> bool:
	return current_valid(ranks) or Legacy.valid(ranks)

static func allocation_error(ranks: Array, index: int, points: int) -> String:
	if not current_valid(ranks) or index < 0 or index >= 15: return "Configuration de talents invalide."
	var tree: int = int(index/NODES_PER_TREE);var node: int = index%NODES_PER_TREE
	if ranks[index] >= MAX_RANKS[node]: return "Talent au rang maximum."
	var missing: int = THRESHOLDS[ROWS[node]]-lower_spent(ranks,tree,ROWS[node])
	if missing > 0: return "Encore %d points à dépenser dans les lignes précédentes de cet arbre." % missing
	if node >= 3 and ranks[tree*NODES_PER_TREE+3]+ranks[tree*NODES_PER_TREE+4] > 0: return "L’autre spécialité de cet arbre est déjà choisie."
	if spent(ranks) >= points: return "Aucun point disponible : achetez un point avec la ressource de cette faction."
	return ""

static func can_allocate(ranks: Array, index: int, points: int) -> bool:
	return allocation_error(ranks,index,points).is_empty()

static func effects(faction: int, ranks: Array, type: int) -> Dictionary:
	if Legacy.valid(ranks): return Legacy.effects(faction,ranks,type)
	var result: Dictionary = {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0}
	if not current_valid(ranks) or type not in ([0,1,2] if faction == 0 else [3,4,5]): return result
	if faction == 0:
		result.range = 0.05*int(ranks[2])+0.15*int(ranks[4])
		if type in [0,1]:
			result.direct = 0.03*int(ranks[5])+0.02*int(ranks[6])+0.08*int(ranks[8])
			result.range += 0.1*int(ranks[7])+0.3*int(ranks[9])
		else:
			result.direct = 0.03*int(ranks[10])+0.02*int(ranks[11])+0.08*int(ranks[13])
			result.secondary = 0.03*int(ranks[10])+0.03*int(ranks[12])+0.15*int(ranks[14])
	else:
		var base: int = {3:0,5:5,4:10}[type]
		result.direct = 0.03*int(ranks[base])+0.02*int(ranks[base+1])+0.08*int(ranks[base+3])
		var secondary: float = (0.0 if type == 3 else 0.03*int(ranks[base]))+0.03*int(ranks[base+2])+0.15*int(ranks[base+4])
		if type == 5: result.curse = secondary
		else: result.secondary = secondary
	return result

static func extra_hp(faction: int, ranks: Array) -> int:
	if Legacy.valid(ranks): return Legacy.extra_hp(faction,ranks)
	return int(ranks[0])+int(ranks[1])+3*int(ranks[3]) if faction == 0 and current_valid(ranks) else 0
