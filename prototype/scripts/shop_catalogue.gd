extends RefCounted
## Catalogue d'essai. Identités, prix et valeurs H, à équilibrer.
const CARDS: Array[Dictionary] = [
	{"id":"alliance.scout","faction":0,"type":6,"family":0,"name":"Rôdeur elfe","po":180,"role":"Tirs rapides à courte portée","tradeoff":"Plus rapide, mais moins de portée et plus cher à recruter que l’archer.","stats":{"price":60,"damage":6.0,"interval":0.7,"range":3.5}},
	{"id":"alliance.musketeer","faction":0,"type":7,"family":1,"name":"Mousquetaire nain","po":240,"role":"Tir lourd à longue portée","tradeoff":"Atteint plus loin, mais recharge lentement et coûte plus cher que l’arbalétrier.","stats":{"price":90,"damage":38.0,"interval":4.0,"range":6.0}},
	{"id":"horde.tracker","faction":1,"type":8,"family":3,"name":"Traqueur troll","po":180,"role":"Haches rapides et rebond léger","tradeoff":"Tire plus vite et plus loin, mais chaque impact et rebond est moins puissant.","stats":{"price":65,"damage":10.0,"interval":1.25,"range":4.0,"secondary_damage":4.0,"secondary_cap":1,"radius":1.0}},
	{"id":"horde.grenadier","faction":1,"type":9,"family":4,"name":"Grenadier gobelin","po":240,"role":"Explosions plus fréquentes et étendues","tradeoff":"Touche davantage de voisins, mais frappe moins fort, porte moins loin et coûte plus cher.","stats":{"price":90,"damage":18.0,"interval":2.0,"range":2.7,"secondary_damage":6.0,"secondary_cap":4,"radius":1.15}}
]
const BRANCHES: Dictionary = {
	6:[{"name":"Tir fulgurant","description":"Impact et portée renforcés, tirs moins fréquents.","damage":29.25,"interval":1.0,"range":4.5},{"name":"Éclaireur de volée","description":"Cadence renforcée, portée encore réduite.","damage":14.625,"interval":0.42,"range":3.0}],
	7:[{"name":"Tireur de précision","description":"Impact renforcé, rechargement plus long.","damage":180.0,"interval":4.8,"range":6.0},{"name":"Guetteur des crêtes","description":"Portée renforcée, dégâts et cadence conservés.","damage":123.5,"interval":4.0,"range":7.5}],
	8:[{"name":"Chasseur de têtes","description":"Impact principal renforcé au détriment du rebond.","damage":42.5,"secondary_damage":6.5},{"name":"Pisteur des ricochets","description":"Trois rebonds plus légers, impact principal réduit.","damage":30.0,"secondary_damage":9.2,"secondary_cap":3}],
	9:[{"name":"Bombardier de siège","description":"Impact renforcé, éclats moins puissants.","damage":78.0,"secondary_damage":16.9},{"name":"Éclats dispersés","description":"Explosion étendue à six voisins, impact principal réduit.","damage":48.75,"secondary_damage":19.5,"secondary_cap":6,"radius":1.4}]
}

static func family(type: int) -> int:
	if type >= 0 and type < 6: return type
	var entry: Dictionary = for_type(type)
	return int(entry.family) if not entry.is_empty() else -1

static func family_label(type: int) -> String:
	var names: Array[String] = ["Archer elfe","Arbalétrier nain","Mage humain","Lanceur de haches troll","Sapeur gobelin","Chaman orc"]
	var base: int = family(type)
	if base < 0: return "Unité inconnue"
	var label: String = names[base]
	for entry in CARDS:
		if entry.family == base: label += " / "+entry.name
	return label

static func talent_description(text: String, faction: int) -> String:
	var names: Array[String] = ["Archer elfe","Arbalétrier nain","Mage humain","Lanceur de haches","Sapeur gobelin","Chaman orc"]
	for base in ([0,1,2] if faction == 0 else [3,4,5]): text = text.replace(names[base],family_label(base))
	return text

static func card(id: Variant) -> Dictionary:
	if not id is String: return {}
	for entry in CARDS:
		if entry.id == id: return entry.duplicate(true)
	return {}

static func for_faction(faction: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in CARDS:
		if entry.faction == faction: result.append(entry.duplicate(true))
	return result

static func for_type(type: int) -> Dictionary:
	for entry in CARDS:
		if entry.type == type: return entry.duplicate(true)
	return {}

static func valid_inventory(faction: int, owned: Variant, selected: Variant) -> bool:
	if faction not in [0,1] or not owned is Dictionary or not selected is String or owned.size() > CARDS.size(): return false
	for id in owned:
		var entry: Dictionary = card(id)
		var paid: Variant = owned[id]
		if entry.is_empty() or entry.faction != faction or not (paid is int or paid is float) or not is_finite(float(paid)) or paid != floorf(float(paid)) or paid < 0 or paid > 1000000000: return false
	return selected.is_empty() or owned.has(selected)
