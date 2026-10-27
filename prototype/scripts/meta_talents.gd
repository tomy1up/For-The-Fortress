extends RefCounted
## Barème de prototype, non équilibré. Indices locaux à chaque faction.
const POINT_PRICE: int = 10
const RESET_PRICES: Array[int] = [2,4,6,8,10]
const TREES: Array = [
	[
		["Bastion",["Remparts renforcés","+1 PV maximum par rang."],["Résistance","+3 PV maximum."],["Vigilance","+0,15 de portée pour tous."]],
		["Maîtrise du tir",["Entraînement","Archer et arbalétrier : +3 % aux tirs par rang."],["Tirs concentrés","Archer et arbalétrier : +8 % aux tirs."],["Couverture","Archer et arbalétrier : +0,3 de portée."]],
		["Arts arcaniques",["Étude des arcanes","Mage : +3 % à tous ses dégâts par rang."],["Puissance directe","Mage : +8 % au tir principal."],["Déflagration","Mage : +15 % aux explosions."]]
	],
	[
		["Fureur de guerre",["Entraînement","Lanceur de haches : +3 % au tir par rang."],["Frappe précise","Lanceur de haches : +8 % au tir principal."],["Ricochets","Lanceur de haches : +15 % aux rebonds."]],
		["Voie des maléfices",["Rituels","Chaman : +3 % à tous ses dégâts par rang."],["Choc initial","Chaman : +8 % au tir principal."],["Usure","Chaman : +15 % aux malédictions."]],
		["Démolition",["Explosifs","Sapeur : +3 % à tous ses dégâts par rang."],["Impact","Sapeur : +8 % au tir principal."],["Détonation","Sapeur : +15 % aux explosions."]]
	]
]

static func integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floorf(float(value)) and value >= minimum and value <= maximum

static func valid(ranks: Variant) -> bool:
	if not ranks is Array or ranks.size() != 9: return false
	for tree in range(3):
		var index: int = tree*3
		if not integer(ranks[index],0,3) or not integer(ranks[index+1],0,1) or not integer(ranks[index+2],0,1): return false
		if ranks[index+1]+ranks[index+2] > 1: return false
		if ranks[index+1]+ranks[index+2] > 0 and ranks[index] != 3: return false
	return true

static func spent(ranks: Array) -> int:
	var total: int = 0
	for rank in ranks: total += int(rank)
	return total

static func can_allocate(ranks: Array, index: int, points: int) -> bool:
	if not valid(ranks) or index < 0 or index >= 9 or spent(ranks) >= points: return false
	var base: int = int(index/3)*3
	if index == base: return ranks[index] < 3
	return ranks[base] == 3 and ranks[base+1]+ranks[base+2] == 0

static func effects(faction: int, ranks: Array, type: int) -> Dictionary:
	var result: Dictionary = {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0}
	if not valid(ranks) or type not in ([0,1,2] if faction == 0 else [3,4,5]): return result
	if faction == 0:
		result.range = 0.15*int(ranks[2])
		if type in [0,1]:
			result.direct = 0.03*int(ranks[3])+0.08*int(ranks[4])
			result.range += 0.3*int(ranks[5])
		else:
			result.direct = 0.03*int(ranks[6])+0.08*int(ranks[7])
			result.secondary = 0.03*int(ranks[6])+0.15*int(ranks[8])
	else:
		var base: int = {3:0,5:3,4:6}[type]
		result.direct = 0.03*int(ranks[base])+0.08*int(ranks[base+1])
		if type == 3: result.secondary = 0.15*int(ranks[base+2])
		elif type == 4: result.secondary = 0.03*int(ranks[base])+0.15*int(ranks[base+2])
		else: result.curse = 0.03*int(ranks[base])+0.15*int(ranks[base+2])
	return result

static func extra_hp(faction: int, ranks: Array) -> int:
	return int(ranks[0])+3*int(ranks[1]) if faction == 0 and valid(ranks) else 0
