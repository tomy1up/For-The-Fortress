extends RefCounted
## Valeurs de référence du GDD, hors bonus et synergies.

const DAMAGE_MULTIPLIERS: Array[float] = [1.0, 1.5, 2.25, 3.25]
const UPGRADE_COSTS: Array[int] = [50, 100, 150]
# Deux branches par type, dans le même ordre que Model.ROSTER.
const BRANCHES: Array[Dictionary] = [
	{"name":"Veilleur des remparts","description":"Portée et impact renforcés, cadence plus lente.","damage":39,"interval":1.5,"range":5},
	{"name":"Tireur de volée","description":"Tirs plus rapides, portée réduite.","damage":19.5,"interval":0.6,"range":3.5},
	{"name":"Brise-siège","description":"Impact renforcé, délai entre tirs plus long.","damage":117,"interval":3,"range":5},
	{"name":"Sentinelle des tours","description":"Portée accrue, dégâts et cadence conservés.","damage":78,"interval":2.5,"range":6.5},
	{"name":"Arcaniste de concentration","description":"Renforce la cible principale aux dépens de la zone.","damage":110,"secondary_damage":22,"secondary_cap":2,"radius":1},
	{"name":"Maître des déflagrations","description":"Explosion plus large, quatre victimes secondaires.","damage":70,"secondary_damage":28,"secondary_cap":4,"radius":1.3},
	{"name":"Fendeur de crânes","description":"Impact principal renforcé, rebond plus faible.","damage":65,"secondary_damage":16.25,"secondary_cap":1,"radius":1},
	{"name":"Maître des ricochets","description":"Trois rebonds successifs, sans retoucher une victime.","damage":46,"secondary_damage":23,"secondary_cap":3,"radius":1},
	{"name":"Expert en démolition","description":"Impact renforcé, trois victimes secondaires.","damage":104,"secondary_damage":26,"secondary_cap":3,"radius":1},
	{"name":"Artificier des foules","description":"Large explosion, cinq victimes secondaires.","damage":65,"secondary_damage":26,"secondary_cap":5,"radius":1.4},
	{"name":"Chaman de guerre","description":"Impact immédiat renforcé, malédiction plus faible.","damage":58.5,"curse_damage":9.75},
	{"name":"Tisseur de malédictions","description":"Impact réduit, malédiction plus forte.","damage":26,"curse_damage":29.25}
]
