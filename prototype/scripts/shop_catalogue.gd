extends RefCounted
## Catalogue d'essai. Identités, prix et valeurs H, à équilibrer.
const CARDS: Array[Dictionary] = [
	{"id":"alliance.scout","faction":0,"type":6,"family":0,"name":"Rôdeur elfe","po":180,"role":"Tirs rapides à courte portée","tradeoff":"Plus rapide, mais moins de portée et plus cher à recruter que l’archer.","stats":{"price":60,"damage":6.0,"interval":0.7,"range":3.5}},
	{"id":"alliance.musketeer","faction":0,"type":7,"family":1,"name":"Mousquetaire nain","po":240,"role":"Tir lourd à longue portée","tradeoff":"Atteint plus loin, mais recharge lentement et coûte plus cher que l’arbalétrier.","stats":{"price":90,"damage":38.0,"interval":4.0,"range":6.0}},
	{"id":"horde.tracker","faction":1,"type":8,"family":3,"name":"Traqueur troll","po":180,"role":"Haches rapides et rebond léger","tradeoff":"Tire plus vite et plus loin, mais chaque impact et rebond est moins puissant.","stats":{"price":65,"damage":10.0,"interval":1.25,"range":4.0,"secondary_damage":4.0,"secondary_cap":1,"radius":1.0}},
	{"id":"horde.grenadier","faction":1,"type":9,"family":4,"name":"Grenadier gobelin","po":240,"role":"Explosions plus fréquentes et étendues","tradeoff":"Touche davantage de voisins, mais frappe moins fort et porte moins loin.","stats":{"price":75,"damage":18.0,"interval":2.0,"range":2.7,"secondary_damage":6.0,"secondary_cap":4,"radius":1.15}},
	{"id":"alliance.sentinel","faction":0,"type":10,"family":0,"name":"Sentinelle elfe","po":300,"unlock_missions":10,"role":"Longue vue sur les trajets","tradeoff":"Voit très loin, mais ses tirs sont faibles et espacés.","stats":{"price":70,"damage":6.0,"interval":1.6,"range":7.0}},
	{"id":"alliance.marksman","faction":0,"type":11,"family":1,"name":"Tireur d’élite elfe","po":360,"unlock_missions":20,"role":"Un coup décisif","tradeoff":"Un tir très fort, mais une très longue recharge : inefficace contre les groupes.","stats":{"price":110,"damage":60.0,"interval":5.0,"range":6.0}},
	{"id":"alliance.arquebusier","faction":0,"type":12,"family":0,"name":"Arquebusier nain","po":420,"unlock_missions":30,"role":"Rafale continue","tradeoff":"Cadence très élevée, mais chaque tir est minuscule et la portée courte.","stats":{"price":85,"damage":3.2,"interval":0.3,"range":3.0}},
	{"id":"alliance.bombard","faction":0,"type":13,"family":2,"name":"Bombarde naine","po":480,"unlock_missions":40,"role":"Explosion sur les groupes","tradeoff":"Très large zone, mais lente et peu précise sur une cible isolée.","stats":{"price":120,"damage":20.0,"interval":4.0,"range":4.0,"secondary_damage":14.0,"secondary_cap":5,"radius":1.6}},
	{"id":"alliance.pikeman","faction":0,"type":14,"family":0,"name":"Piquier humain","po":540,"unlock_missions":50,"role":"Défense bon marché","tradeoff":"Peu cher et efficace de près, mais sa portée est très courte.","stats":{"price":55,"damage":14.0,"interval":1.2,"range":2.2}},
	{"id":"alliance.pyromancer","faction":0,"type":15,"family":2,"name":"Pyromancien humain","po":600,"unlock_missions":60,"role":"Brûlure prolongée","tradeoff":"Dégâts surtout sur la durée : peu efficace pour achever une cible.","stats":{"price":105,"damage":5.0,"interval":2.0,"range":4.0,"curse_damage":7.0}},
	{"id":"horde.watcher","faction":1,"type":16,"family":3,"name":"Veilleur des cendres","po":300,"unlock_missions":10,"role":"Longue vue sur les trajets","tradeoff":"Voit très loin, mais ses tirs sont faibles et espacés.","stats":{"price":70,"damage":6.0,"interval":1.6,"range":7.0}},
	{"id":"horde.javelin","faction":1,"type":17,"family":3,"name":"Lanceur de javeline troll","po":360,"unlock_missions":20,"role":"Un coup décisif","tradeoff":"Un tir très fort, mais une longue recharge : inefficace contre les groupes.","stats":{"price":105,"damage":56.0,"interval":4.5,"range":5.0}},
	{"id":"horde.shardthrower","faction":1,"type":18,"family":3,"name":"Lance-éclats gobelin","po":420,"unlock_missions":30,"role":"Rafale continue","tradeoff":"Cadence très élevée, mais chaque tir est minuscule et la portée courte.","stats":{"price":85,"damage":3.5,"interval":0.35,"range":3.2}},
	{"id":"horde.catapult","faction":1,"type":19,"family":4,"name":"Catapulte gobeline","po":480,"unlock_missions":40,"role":"Explosion sur les groupes","tradeoff":"Très large zone, mais lente et peu précise sur une cible isolée.","stats":{"price":120,"damage":22.0,"interval":4.2,"range":4.2,"secondary_damage":15.0,"secondary_cap":5,"radius":1.7}},
	{"id":"horde.spearman","faction":1,"type":20,"family":3,"name":"Lance-épieu orc","po":540,"unlock_missions":50,"role":"Défense bon marché","tradeoff":"Peu cher et efficace de près, mais sa portée est très courte.","stats":{"price":55,"damage":15.0,"interval":1.3,"range":2.2}},
	{"id":"horde.cinderburner","faction":1,"type":21,"family":5,"name":"Brûleur de cendres","po":600,"unlock_missions":60,"role":"Brûlure prolongée","tradeoff":"Dégâts surtout sur la durée : peu efficace pour achever une cible.","stats":{"price":105,"damage":5.0,"interval":2.0,"range":4.2,"curse_damage":7.2}}
]
const BRANCHES: Dictionary = {
	6:[{"name":"Tir fulgurant","description":"Impact et portée renforcés, tirs moins fréquents.","damage":29.25,"interval":1.0,"range":4.5},{"name":"Éclaireur de volée","description":"Cadence renforcée, portée encore réduite.","damage":14.625,"interval":0.42,"range":3.0}],
	7:[{"name":"Tireur de précision","description":"Impact renforcé, rechargement plus long.","damage":180.0,"interval":4.8,"range":6.0},{"name":"Guetteur des crêtes","description":"Portée renforcée, dégâts et cadence conservés.","damage":123.5,"interval":4.0,"range":7.5}],
	8:[{"name":"Chasseur de têtes","description":"Impact principal renforcé au détriment du rebond.","damage":42.5,"secondary_damage":6.5},{"name":"Pisteur des ricochets","description":"Trois rebonds plus légers, impact principal réduit.","damage":30.0,"secondary_damage":9.2,"secondary_cap":3}],
	9:[{"name":"Bombardier de siège","description":"Impact renforcé, éclats moins puissants.","damage":78.0,"secondary_damage":16.9},{"name":"Éclats dispersés","description":"Explosion étendue à six voisins, impact principal réduit.","damage":48.75,"secondary_damage":19.5,"secondary_cap":6,"radius":1.4}],
	10:[{"name":"Longue vue","description":"Impact et portée renforcés, tirs moins fréquents.","damage":29.25,"interval":2.288,"range":8.0},{"name":"Veille rapprochée","description":"Cadence renforcée, portée réduite.","damage":14.625,"interval":0.96,"range":6.5}],
	11:[{"name":"Coup décisif","description":"Impact et portée renforcés, tirs moins fréquents.","damage":292.5,"interval":7.15,"range":7.0},{"name":"Tir enchaîné","description":"Cadence renforcée, portée réduite.","damage":146.25,"interval":3.0,"range":5.5}],
	12:[{"name":"Rafale lourde","description":"Impact et portée renforcés, tirs moins fréquents.","damage":15.6,"interval":0.429,"range":4.0},{"name":"Rafale vive","description":"Cadence renforcée, portée réduite.","damage":7.8,"interval":0.18,"range":2.5}],
	13:[{"name":"Pilonnage","description":"Impact renforcé, éclats plus puissants.","damage":97.5,"interval":5.72,"range":5.0,"secondary_damage":42.0},{"name":"Tir tendu","description":"Explosion étendue à plus de voisins, impact réduit.","damage":48.75,"interval":2.4,"range":3.5,"secondary_damage":45.5,"secondary_cap":7,"radius":1.85}],
	14:[{"name":"Pointe lourde","description":"Impact et portée renforcés, tirs moins fréquents.","damage":68.25,"interval":1.716,"range":3.2},{"name":"Estoc rapide","description":"Cadence renforcée, portée réduite.","damage":34.125,"interval":0.72,"range":1.7}],
	15:[{"name":"Brasier profond","description":"Brûlure beaucoup plus forte, impact réduit.","damage":24.375,"interval":2.86,"range":5.0,"curse_damage":34.125},{"name":"Étincelles","description":"Brûlure plus modérée, tirs plus fréquents.","damage":12.188,"interval":1.2,"range":3.5,"curse_damage":17.062}],
	16:[{"name":"Longue vue","description":"Impact et portée renforcés, tirs moins fréquents.","damage":29.25,"interval":2.288,"range":8.0},{"name":"Veille rapprochée","description":"Cadence renforcée, portée réduite.","damage":14.625,"interval":0.96,"range":6.5}],
	17:[{"name":"Coup décisif","description":"Impact et portée renforcés, tirs moins fréquents.","damage":273.0,"interval":6.435,"range":6.0},{"name":"Tir enchaîné","description":"Cadence renforcée, portée réduite.","damage":136.5,"interval":2.7,"range":4.5}],
	18:[{"name":"Rafale lourde","description":"Impact et portée renforcés, tirs moins fréquents.","damage":17.062,"interval":0.5,"range":4.2},{"name":"Rafale vive","description":"Cadence renforcée, portée réduite.","damage":8.531,"interval":0.21,"range":2.7}],
	19:[{"name":"Pilonnage","description":"Impact renforcé, éclats plus puissants.","damage":107.25,"interval":6.006,"range":5.2,"secondary_damage":45.0},{"name":"Tir tendu","description":"Explosion étendue à plus de voisins, impact réduit.","damage":53.625,"interval":2.52,"range":3.7,"secondary_damage":48.75,"secondary_cap":7,"radius":1.95}],
	20:[{"name":"Pointe lourde","description":"Impact et portée renforcés, tirs moins fréquents.","damage":73.125,"interval":1.859,"range":3.2},{"name":"Estoc rapide","description":"Cadence renforcée, portée réduite.","damage":36.562,"interval":0.78,"range":1.7}],
	21:[{"name":"Brasier profond","description":"Brûlure beaucoup plus forte, impact réduit.","damage":24.375,"interval":2.86,"range":5.2,"curse_damage":35.1},{"name":"Étincelles","description":"Brûlure plus modérée, tirs plus fréquents.","damage":12.188,"interval":1.2,"range":3.7,"curse_damage":17.55}]
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
