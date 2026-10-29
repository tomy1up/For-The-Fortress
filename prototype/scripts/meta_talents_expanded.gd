extends RefCounted
## Prototype enrichi : contenu et valeurs H, plafond provisoire 51, aucun prix définitif.
const Previous = preload("res://scripts/meta_talents_v068.gd")
const NODE_COUNT: int = 63
const NODES_PER_TREE: int = 21
const MAX_POINTS: int = 51
const ROWS: Array[int] = [0,1,1,2,2,0,0,1,2,3,3,3,4,4,4,5,5,5,6,6,6]
const MAX_RANKS: Array[int] = [5,3,3,1,1,3,3,3,3,1,3,3,2,2,2,3,3,3,1,3,3]
const THRESHOLDS: Array[int] = [0,5,10,15,20,25,30]
const EXCLUSIONS: Array = [[3,4],[15,16,17],[18,19,20]]
const UNIT_NAMES: Array[String] = ["Archer elfe","Arbalétrier nain","Mage humain","Lanceur de haches","Sapeur gobelin","Chaman orc"]
const CORE: Array = [
	[
		[
			{
				"hp": 1
			},
			{
				"hp": 1
			},
			{
				"types": [
					0,
					1,
					2
				],
				"range": 0.05
			},
			{
				"hp": 3
			},
			{
				"types": [
					0,
					1,
					2
				],
				"range": 0.15
			}
		],
		[
			{
				"types": [
					0,
					1
				],
				"direct": 0.03
			},
			{
				"types": [
					0,
					1
				],
				"direct": 0.02
			},
			{
				"types": [
					0,
					1
				],
				"range": 0.1
			},
			{
				"types": [
					0,
					1
				],
				"direct": 0.08
			},
			{
				"types": [
					0,
					1
				],
				"range": 0.3
			}
		],
		[
			{
				"types": [
					2
				],
				"direct": 0.03,
				"secondary": 0.03
			},
			{
				"types": [
					2
				],
				"direct": 0.02
			},
			{
				"types": [
					2
				],
				"secondary": 0.03
			},
			{
				"types": [
					2
				],
				"direct": 0.08
			},
			{
				"types": [
					2
				],
				"secondary": 0.15
			}
		]
	],
	[
		[
			{
				"types": [
					3
				],
				"direct": 0.03
			},
			{
				"types": [
					3
				],
				"direct": 0.02
			},
			{
				"types": [
					3
				],
				"secondary": 0.03
			},
			{
				"types": [
					3
				],
				"direct": 0.08
			},
			{
				"types": [
					3
				],
				"secondary": 0.15
			}
		],
		[
			{
				"types": [
					5
				],
				"direct": 0.03,
				"curse": 0.03
			},
			{
				"types": [
					5
				],
				"direct": 0.02
			},
			{
				"types": [
					5
				],
				"curse": 0.03
			},
			{
				"types": [
					5
				],
				"direct": 0.08
			},
			{
				"types": [
					5
				],
				"curse": 0.15
			}
		],
		[
			{
				"types": [
					4
				],
				"direct": 0.03,
				"secondary": 0.03
			},
			{
				"types": [
					4
				],
				"direct": 0.02
			},
			{
				"types": [
					4
				],
				"secondary": 0.03
			},
			{
				"types": [
					4
				],
				"direct": 0.08
			},
			{
				"types": [
					4
				],
				"secondary": 0.15
			}
		]
	]
]
const EXTRAS: Array = [
	[
		[
			{
				"name": "Postes de garde",
				"effect": {
					"range": 0.04,
					"types": [
						0,
						1,
						2
					]
				}
			},
			{
				"name": "Réserves royales",
				"effect": {
					"hp": 1
				}
			},
			{
				"name": "Garnison vigilante",
				"effect": {
					"direct": 0.01,
					"types": [
						0,
						1
					]
				}
			},
			{
				"name": "Réseau de veille",
				"effect": {
					"range": 0.05,
					"types": [
						0,
						1,
						2
					]
				}
			},
			{
				"name": "Remparts sacrés",
				"effect": {
					"hp": 5,
					"range": 0.1,
					"types": [
						0,
						1,
						2
					]
				}
			},
			{
				"name": "Arbalètes de rempart",
				"effect": {
					"direct": 0.025,
					"types": [
						1
					]
				}
			},
			{
				"name": "Gardiens arcanistes",
				"effect": {
					"range": 0.08,
					"types": [
						2
					]
				}
			},
			{
				"name": "Tours de guet",
				"effect": {
					"range": 0.1,
					"types": [
						0,
						1,
						2
					]
				}
			},
			{
				"name": "Défense tenace",
				"effect": {
					"hp": 2
				}
			},
			{
				"name": "Soutien de la garnison",
				"effect": {
					"direct": 0.035,
					"types": [
						0
					]
				}
			},
			{
				"name": "Forteresse vivante",
				"effect": {
					"hp": 2
				}
			},
			{
				"name": "Vigie du royaume",
				"effect": {
					"range": 0.1,
					"types": [
						0,
						1,
						2
					]
				}
			},
			{
				"name": "Garnison d’élite",
				"effect": {
					"direct": 0.025,
					"types": [
						0,
						1,
						2
					]
				}
			},
			{
				"name": "Citadelle éveillée",
				"effect": {
					"hp": 5,
					"range": 0.3,
					"types": [
						0,
						1,
						2
					]
				}
			},
			{
				"name": "Murs inébranlables",
				"effect": {
					"hp": 3
				}
			},
			{
				"name": "Horizon du royaume",
				"effect": {
					"range": 0.15,
					"types": [
						0,
						1,
						2
					]
				}
			}
		],
		[
			{
				"name": "Archers appliqués",
				"effect": {
					"direct": 0.02,
					"types": [
						0
					]
				}
			},
			{
				"name": "Visée naine",
				"effect": {
					"direct": 0.02,
					"types": [
						1
					]
				}
			},
			{
				"name": "Observateurs elfes",
				"effect": {
					"range": 0.07,
					"types": [
						0
					]
				}
			},
			{
				"name": "Trait perforant",
				"effect": {
					"direct": 0.025,
					"types": [
						1
					]
				}
			},
			{
				"name": "Discipline de garnison",
				"effect": {
					"direct": 0.1,
					"range": 0.1,
					"types": [
						0,
						1
					]
				}
			},
			{
				"name": "Longue-vue naine",
				"effect": {
					"range": 0.1,
					"types": [
						1
					]
				}
			},
			{
				"name": "Volées du gué",
				"effect": {
					"direct": 0.025,
					"types": [
						0
					]
				}
			},
			{
				"name": "Posture du tireur",
				"effect": {
					"range": 0.1,
					"types": [
						0,
						1
					]
				}
			},
			{
				"name": "Flèches précises",
				"effect": {
					"direct": 0.04,
					"types": [
						0
					]
				}
			},
			{
				"name": "Mécanique de siège",
				"effect": {
					"direct": 0.04,
					"types": [
						1
					]
				}
			},
			{
				"name": "Discipline elfique",
				"effect": {
					"direct": 0.03,
					"types": [
						0
					]
				}
			},
			{
				"name": "Maître arbalétrier",
				"effect": {
					"direct": 0.03,
					"types": [
						1
					]
				}
			},
			{
				"name": "Réseau de tireurs",
				"effect": {
					"range": 0.1,
					"types": [
						0,
						1
					]
				}
			},
			{
				"name": "Maîtrise balistique",
				"effect": {
					"direct": 0.12,
					"range": 0.2,
					"types": [
						0,
						1
					]
				}
			},
			{
				"name": "Précision elfique",
				"effect": {
					"direct": 0.07,
					"types": [
						0
					]
				}
			},
			{
				"name": "Artillerie naine",
				"effect": {
					"direct": 0.07,
					"types": [
						1
					]
				}
			}
		],
		[
			{
				"name": "Formules incisives",
				"effect": {
					"direct": 0.02,
					"types": [
						2
					]
				}
			},
			{
				"name": "Fragments d’arcane",
				"effect": {
					"secondary": 0.03,
					"types": [
						2
					]
				}
			},
			{
				"name": "Cristaux de veille",
				"effect": {
					"range": 0.07,
					"types": [
						2
					]
				}
			},
			{
				"name": "Sceaux protecteurs",
				"effect": {
					"hp": 1
				}
			},
			{
				"name": "Convergence arcanique",
				"effect": {
					"direct": 0.08,
					"secondary": 0.08,
					"types": [
						2
					]
				}
			},
			{
				"name": "Gerbes d’étincelles",
				"effect": {
					"secondary": 0.04,
					"types": [
						2
					]
				}
			},
			{
				"name": "Observatoire arcanique",
				"effect": {
					"range": 0.08,
					"types": [
						2
					]
				}
			},
			{
				"name": "Rayon concentré",
				"effect": {
					"direct": 0.04,
					"types": [
						2
					]
				}
			},
			{
				"name": "Échos de déflagration",
				"effect": {
					"secondary": 0.06,
					"types": [
						2
					]
				}
			},
			{
				"name": "Barrière du royaume",
				"effect": {
					"hp": 2
				}
			},
			{
				"name": "Maître du trait",
				"effect": {
					"types": [
						2
					],
					"direct": 0.03
				}
			},
			{
				"name": "Maître des explosions",
				"effect": {
					"types": [
						2
					],
					"secondary": 0.04
				}
			},
			{
				"name": "Vigie arcanique",
				"effect": {
					"types": [
						2
					],
					"range": 0.1
				}
			},
			{
				"name": "Archimage du gué",
				"effect": {
					"direct": 0.12,
					"secondary": 0.16,
					"types": [
						2
					]
				}
			},
			{
				"name": "Veille supérieure",
				"effect": {
					"range": 0.15,
					"types": [
						2
					]
				}
			},
			{
				"name": "Protection arcanique",
				"effect": {
					"hp": 2
				}
			}
		]
	],
	[
		[
			{
				"name": "Poigne troll",
				"effect": {
					"direct": 0.02,
					"types": [
						3
					]
				}
			},
			{
				"name": "Haches jumelles",
				"effect": {
					"secondary": 0.03,
					"types": [
						3
					]
				}
			},
			{
				"name": "Éclaireurs de guerre",
				"effect": {
					"range": 0.07,
					"types": [
						3
					]
				}
			},
			{
				"name": "Palisades de guerre",
				"effect": {
					"hp": 1
				}
			},
			{
				"name": "Furie des Cendres",
				"effect": {
					"direct": 0.08,
					"secondary": 0.08,
					"types": [
						3
					]
				}
			},
			{
				"name": "Rebonds sauvages",
				"effect": {
					"secondary": 0.04,
					"types": [
						3
					]
				}
			},
			{
				"name": "Postes avancés",
				"effect": {
					"range": 0.08,
					"types": [
						3
					]
				}
			},
			{
				"name": "Tranchant d’acier",
				"effect": {
					"direct": 0.04,
					"types": [
						3
					]
				}
			},
			{
				"name": "Chaînes de haches",
				"effect": {
					"secondary": 0.06,
					"types": [
						3
					]
				}
			},
			{
				"name": "Bannière de guerre",
				"effect": {
					"hp": 2
				}
			},
			{
				"name": "Briseur de lignes",
				"effect": {
					"types": [
						3
					],
					"direct": 0.03
				}
			},
			{
				"name": "Tempête de haches",
				"effect": {
					"types": [
						3
					],
					"secondary": 0.04
				}
			},
			{
				"name": "Vigie des Cendres",
				"effect": {
					"types": [
						3
					],
					"range": 0.1
				}
			},
			{
				"name": "Seigneur des haches",
				"effect": {
					"direct": 0.12,
					"secondary": 0.16,
					"types": [
						3
					]
				}
			},
			{
				"name": "Chasse lointaine",
				"effect": {
					"range": 0.15,
					"types": [
						3
					]
				}
			},
			{
				"name": "Remparts des Cendres",
				"effect": {
					"hp": 2
				}
			}
		],
		[
			{
				"name": "Choc rituel",
				"effect": {
					"direct": 0.02,
					"types": [
						5
					]
				}
			},
			{
				"name": "Présages persistants",
				"effect": {
					"curse": 0.03,
					"types": [
						5
					]
				}
			},
			{
				"name": "Totems de veille",
				"effect": {
					"range": 0.07,
					"types": [
						5
					]
				}
			},
			{
				"name": "Protection des esprits",
				"effect": {
					"hp": 1
				}
			},
			{
				"name": "Pacte des esprits",
				"effect": {
					"direct": 0.08,
					"curse": 0.08,
					"types": [
						5
					]
				}
			},
			{
				"name": "Malédiction profonde",
				"effect": {
					"curse": 0.04,
					"types": [
						5
					]
				}
			},
			{
				"name": "Rituels lointains",
				"effect": {
					"range": 0.08,
					"types": [
						5
					]
				}
			},
			{
				"name": "Volonté du chaman",
				"effect": {
					"direct": 0.04,
					"types": [
						5
					]
				}
			},
			{
				"name": "Liens funestes",
				"effect": {
					"curse": 0.06,
					"types": [
						5
					]
				}
			},
			{
				"name": "Gardien des ancêtres",
				"effect": {
					"hp": 2
				}
			},
			{
				"name": "Maître du choc",
				"effect": {
					"types": [
						5
					],
					"direct": 0.03
				}
			},
			{
				"name": "Maître des maléfices",
				"effect": {
					"types": [
						5
					],
					"curse": 0.04
				}
			},
			{
				"name": "Veille des esprits",
				"effect": {
					"types": [
						5
					],
					"range": 0.1
				}
			},
			{
				"name": "Voix des ancêtres",
				"effect": {
					"direct": 0.12,
					"curse": 0.16,
					"types": [
						5
					]
				}
			},
			{
				"name": "Horizon des esprits",
				"effect": {
					"range": 0.15,
					"types": [
						5
					]
				}
			},
			{
				"name": "Protection des ancêtres",
				"effect": {
					"hp": 2
				}
			}
		],
		[
			{
				"name": "Mèche concentrée",
				"effect": {
					"direct": 0.02,
					"types": [
						4
					]
				}
			},
			{
				"name": "Éclats acérés",
				"effect": {
					"secondary": 0.03,
					"types": [
						4
					]
				}
			},
			{
				"name": "Calcul balistique",
				"effect": {
					"range": 0.07,
					"types": [
						4
					]
				}
			},
			{
				"name": "Renforts gobelins",
				"effect": {
					"hp": 1
				}
			},
			{
				"name": "Charge magistrale",
				"effect": {
					"direct": 0.08,
					"secondary": 0.08,
					"types": [
						4
					]
				}
			},
			{
				"name": "Shrapnels",
				"effect": {
					"secondary": 0.04,
					"types": [
						4
					]
				}
			},
			{
				"name": "Tables de tir",
				"effect": {
					"range": 0.08,
					"types": [
						4
					]
				}
			},
			{
				"name": "Impact renforcé",
				"effect": {
					"direct": 0.04,
					"types": [
						4
					]
				}
			},
			{
				"name": "Pluie d’éclats",
				"effect": {
					"secondary": 0.06,
					"types": [
						4
					]
				}
			},
			{
				"name": "Abri des sapeurs",
				"effect": {
					"hp": 2
				}
			},
			{
				"name": "Briseur de cuirasses",
				"effect": {
					"types": [
						4
					],
					"direct": 0.03
				}
			},
			{
				"name": "Maître artificier",
				"effect": {
					"types": [
						4
					],
					"secondary": 0.04
				}
			},
			{
				"name": "Artillerie lointaine",
				"effect": {
					"types": [
						4
					],
					"range": 0.1
				}
			},
			{
				"name": "Génie de démolition",
				"effect": {
					"direct": 0.12,
					"secondary": 0.16,
					"types": [
						4
					]
				}
			},
			{
				"name": "Tirs lointains",
				"effect": {
					"range": 0.15,
					"types": [
						4
					]
				}
			},
			{
				"name": "Abris fortifiés",
				"effect": {
					"hp": 2
				}
			}
		]
	]
]

static func index_for(tree: int, local: int) -> int:
	return tree*5+local if local < 5 else 15+tree*16+local-5

static func coordinates(index: int) -> Vector2i:
	return Vector2i(int(index/5),index%5) if index < 15 else Vector2i(int((index-15)/16),5+(index-15)%16)

static func tree_capacity() -> int:
	var total: int = 0
	for value in MAX_RANKS: total += value
	for group in EXCLUSIONS:
		var group_total: int = 0;var greatest: int = 0
		for local in group:
			group_total += MAX_RANKS[local];greatest = maxi(greatest,MAX_RANKS[local])
		total -= group_total-greatest
	return total

static func empty_ranks() -> Array:
	var result: Array = [];result.resize(NODE_COUNT);result.fill(0);return result

static func normalize(ranks: Array) -> Array:
	if valid(ranks): return ranks.duplicate()
	if not Previous.current_valid(ranks): return []
	var result: Array = empty_ranks()
	for index in range(15): result[index] = ranks[index]
	return result

static func spent(ranks: Array) -> int:
	return Previous.spent(ranks)

static func tree_spent(ranks: Array, tree: int) -> int:
	var total: int = 0
	for local in range(NODES_PER_TREE): total += int(ranks[index_for(tree,local)])
	return total

static func lower_spent(ranks: Array, tree: int, row: int) -> int:
	var total: int = 0
	for local in range(NODES_PER_TREE):
		if ROWS[local] < row: total += int(ranks[index_for(tree,local)])
	return total

static func valid(ranks: Variant) -> bool:
	if not ranks is Array or ranks.size() != NODE_COUNT: return false
	for index in range(NODE_COUNT):
		if not Previous.integer(ranks[index],0,MAX_RANKS[coordinates(index).y]): return false
	if spent(ranks) > MAX_POINTS: return false
	for tree in range(3):
		for group in EXCLUSIONS:
			var total: int = 0
			for local in group:
				if ranks[index_for(tree,local)] > 0: total += 1
			if total > 1: return false
		for local in range(NODES_PER_TREE):
			if ranks[index_for(tree,local)] > 0 and lower_spent(ranks,tree,ROWS[local]) < THRESHOLDS[ROWS[local]]: return false
	return true

static func allocation_error(ranks: Array, index: int, points: int) -> String:
	if not valid(ranks) or index < 0 or index >= NODE_COUNT: return "Configuration de talents invalide."
	var position: Vector2i = coordinates(index);var tree: int = position.x;var local: int = position.y
	if ranks[index] >= MAX_RANKS[local]: return "Talent au rang maximum."
	var missing: int = THRESHOLDS[ROWS[local]]-lower_spent(ranks,tree,ROWS[local])
	if missing > 0: return "Encore %d points à dépenser dans les lignes précédentes de cet arbre." % missing
	for group in EXCLUSIONS:
		if local not in group: continue
		for other in group:
			if other != local and ranks[index_for(tree,other)] > 0: return "L’autre spécialité de cette ligne est déjà choisie."
	if spent(ranks) >= MAX_POINTS: return "Plafond provisoire de %d points investis atteint." % MAX_POINTS
	if spent(ranks) >= points: return "Aucun point disponible : gagnez de l’XP en réussissant des missions avec cette faction."
	return ""

static func effect_for(faction: int, index: int) -> Dictionary:
	var position: Vector2i = coordinates(index)
	return (CORE[faction][position.x][position.y] if position.y < 5 else EXTRAS[faction][position.x][position.y-5].effect).duplicate(true)

static func _core_effects(faction: int, ranks: Array, type: int) -> Dictionary:
	var result: Dictionary = {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0}
	if type not in ([0,1,2] if faction == 0 else [3,4,5]): return result
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


static func effects(faction: int, ranks: Array, type: int) -> Dictionary:
	var result: Dictionary = {"direct":0.0,"secondary":0.0,"curse":0.0,"range":0.0}
	if faction not in [0,1] or not valid(ranks) or type not in ([0,1,2] if faction == 0 else [3,4,5]): return result
	result = _core_effects(faction,ranks.slice(0,15),type)
	for index in range(15,NODE_COUNT):
		if ranks[index] == 0: continue
		var effect: Dictionary = effect_for(faction,index)
		if type not in effect.get("types",[]): continue
		for component in result: result[component] += float(effect.get(component,0))*int(ranks[index])
	return result

static func extra_hp(faction: int, ranks: Array) -> int:
	if faction not in [0,1] or not valid(ranks): return 0
	var total: int = int(ranks[0])+int(ranks[1])+3*int(ranks[3]) if faction == 0 else 0
	for index in range(15,NODE_COUNT):
		if ranks[index] > 0: total += int(effect_for(faction,index).get("hp",0))*int(ranks[index])
	return total

static func node(faction: int, index: int) -> Dictionary:
	if faction not in [0,1] or index < 0 or index >= NODE_COUNT: return {}
	var position: Vector2i = coordinates(index);var local: int = position.y
	var name: String = Previous.TREES[faction][position.x][local+1][0] if local < 5 else EXTRAS[faction][position.x][local-5].name
	var effect: Dictionary = effect_for(faction,index)
	var lines: Array[String] = []
	if effect.has("hp"): lines.append("Forteresse : +%d PV maximum par rang." % effect.hp)
	var units: Array[String] = []
	for type in effect.get("types",[]): units.append(UNIT_NAMES[type])
	for component in ["direct","secondary","curse","range"]:
		if not effect.has(component): continue
		var title: String = {"direct":"tirs directs","secondary":"rebonds" if effect.get("types",[]) == [3] else "explosions","curse":"malédictions","range":"portée"}[component]
		lines.append("%s : %s +%s%s par rang." % [" / ".join(units),title,Previous.number(effect[component]*(1 if component == "range" else 100)),"" if component == "range" else " %"])
	return {"index":index,"tree":position.x,"local":local,"major":local in [9,18],"name":name,"description":"\n".join(lines),"row":ROWS[local],"maximum":MAX_RANKS[local],"effect":effect}

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
		trees.append({"name":Previous.TREES[faction][tree][0],"points":tree_spent(ranks,tree),"nodes":nodes})
	var units: Array[Dictionary] = []
	for type in ([0,1,2] if faction == 0 else [3,4,5]): units.append({"type":type,"bonuses":effects(faction,ranks,type)})
	return {"points":spent(ranks),"hp":extra_hp(faction,ranks),"trees":trees,"units":units,"rules":"expanded_51_prototype"}
