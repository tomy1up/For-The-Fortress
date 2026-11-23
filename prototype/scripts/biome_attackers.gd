extends RefCounted
## Cinq attaquants neutres des chapitres pairs (décision du porteur, 23 novembre 2026, étape 3 de « un affixe par biome »).
## Noms, statistiques, capacités et compositions sont des réglages de prototype à confirmer. Visuels provisoires (silhouettes existantes teintées) en attendant Codex.
const IBEX := 13
const GOLEM := 14
const EMBER := 15
const SCORPION := 16
const MOLE := 17
const CRAB := 18
const IBEX_ID := "slate_ibex"
const GOLEM_ID := "ash_golems"
const SCORPION_ID := "dune_scorpions"
const MOLE_ID := "mine_moles"
const CRAB_ID := "coast_crabs"
const DEFINITIONS := {
	13:{"name":"Bouquetin des crêtes","hp":70.0,"speed":0.9,"fortress_damage":2,"reward":6},
	14:{"name":"Golem de magma","hp":150.0,"speed":0.6,"fortress_damage":2,"reward":8},
	15:{"name":"Braise","hp":15.0,"speed":1.4,"fortress_damage":1,"reward":1},
	16:{"name":"Scorpion des dunes","hp":90.0,"speed":0.85,"fortress_damage":2,"reward":6},
	17:{"name":"Taupe des galeries","hp":60.0,"speed":1.0,"fortress_damage":1,"reward":5},
	18:{"name":"Crabe pilleur","hp":100.0,"speed":0.8,"fortress_damage":1,"reward":8},
}
## Profils ajoutés au catalogue de chaque jeu de rencontres (la Braise n'apparaît que par l'éclatement du golem).
const PROFILES := {"slate_ibex":[13],"ash_golems":[14,15],"dune_scorpions":[16],"mine_moles":[17],"coast_crabs":[18]}
## Bouquetin : sous cette part de ses PV, il charge une seule fois.
const CHARGE_THRESHOLD := 0.5
const CHARGE_RATE := 0.7
const CHARGE_SECONDS := 2.0
## Golem : Braises libérées à sa mort, et leur écart de départ sur la route.
const EMBERS := 2
const EMBER_SPACING := 0.3
## Identifiants des ennemis créés en combat, hors du calendrier de la vague.
const FIRST_EXTRA_ID := 100000
## Scorpion : vitesse supplémentaire pendant une rafale de la Tempête de sable (+100 % : deux fois plus vite).
const STORM_RATE := 1.0
## Taupe : sur chaque tranche de trois cases, deux en surface puis une sous terre ; elle remonte toujours pour la dernière case avant la forteresse.
const BURROW_CYCLE := 3.0
const BURROW_SURFACE := 2.0
const BURROW_LAST_TILE := 1.0
## Crabe : or volé s'il atteint la forteresse.
const CRAB_THEFT := 20
const WAVES := {
	"slate_ibex":[
		[[1,10,2.5]],
		[[1,10,2.0],[0,8,0.65]],
		[[1,8,1.8],[13,3,2.2]],
		[[3,4,3.0],[0,10,0.5],[13,2,2.5]],
		[[4,6,2.0],[3,2,3.0],[13,4,2.0]],
		[[5,2,4.0],[13,4,2.2],[0,12,0.5]],
		[[6,1,0.0],[5,2,4.0],[13,4,2.0]],
		[[0,24,0.35],[13,5,1.6],[4,6,1.2]],
		[[6,2,5.0],[5,2,4.0],[13,4,2.0],[4,4,1.4]],
		[[7,1,0.0],[6,2,5.0],[13,4,1.8]]
	],
	"ash_golems":[
		[[1,10,2.5]],
		[[1,10,2.0],[0,8,0.65]],
		[[1,8,1.8],[2,8,1.4]],
		[[3,2,3.0],[14,2,4.0],[0,12,0.5]],
		[[4,6,2.0],[14,2,4.0],[2,6,1.2]],
		[[5,1,0.0],[14,3,3.5],[0,12,0.5]],
		[[6,1,0.0],[14,3,3.5],[4,6,1.6]],
		[[0,18,0.35],[14,3,3.0],[4,6,1.2]],
		[[6,2,5.0],[14,4,3.0],[3,2,2.2],[4,4,1.4]],
		[[7,1,0.0],[6,1,0.0],[14,4,3.0],[2,6,1.0]]
	],
	"dune_scorpions":[
		[[1,10,2.5]],
		[[1,10,2.0],[0,8,0.65]],
		[[1,8,1.8],[16,2,3.0]],
		[[3,2,3.0],[16,3,2.5],[0,12,0.5]],
		[[4,6,2.0],[16,4,2.2],[2,4,1.2]],
		[[5,2,4.0],[16,4,2.2],[0,12,0.5]],
		[[6,1,0.0],[5,1,0.0],[16,5,2.0],[4,4,1.6]],
		[[0,20,0.35],[16,5,1.8],[4,6,1.2]],
		[[6,2,5.0],[5,2,4.0],[16,5,1.8]],
		[[7,1,0.0],[6,2,5.0],[16,5,1.8]]
	],
	"mine_moles":[
		[[1,10,2.5]],
		[[1,10,2.0],[0,8,0.65]],
		[[1,8,1.8],[17,4,1.6]],
		[[3,3,3.0],[17,4,1.4],[0,12,0.5]],
		[[4,4,2.0],[3,2,3.0],[17,5,1.2]],
		[[5,2,4.0],[17,6,1.4],[0,10,0.5]],
		[[6,1,0.0],[5,2,4.0],[17,6,1.2]],
		[[0,20,0.35],[17,8,1.0],[4,4,1.2]],
		[[6,2,5.0],[5,2,4.0],[17,6,1.2],[4,2,1.4]],
		[[7,1,0.0],[6,2,5.0],[17,6,1.0]]
	],
	"coast_crabs":[
		[[1,10,2.5]],
		[[1,10,2.0],[0,8,0.65]],
		[[1,8,1.8],[2,8,1.4]],
		[[3,2,3.0],[18,3,2.4],[0,12,0.5]],
		[[4,6,2.0],[18,3,2.6],[2,6,1.2]],
		[[5,2,4.0],[18,4,2.2],[0,12,0.5]],
		[[6,1,0.0],[5,2,4.0],[18,4,2.0]],
		[[0,20,0.35],[18,5,1.8],[4,6,1.2]],
		[[6,2,5.0],[5,2,4.0],[18,4,2.0],[4,4,1.4]],
		[[7,1,0.0],[6,2,5.0],[18,4,2.0]]
	],
}
## Seconde ligne de la fiche de mission.
const SHEET_LINES := {
	"slate_ibex":"Nouveau : bouquetin · charge une fois",
	"ash_golems":"Nouveau : golem de magma · éclate à sa mort",
	"dune_scorpions":"Nouveau : scorpion · rapide en tempête",
	"mine_moles":"Nouveau : taupe · passe sous terre",
	"coast_crabs":"Nouveau : crabe pilleur · vole de l'or",
}
## Règle affichée dans les info-bulles et l'éclaireur.
const RULES := {
	13:"Bouquetin des crêtes : sous la moitié de ses PV, il charge une seule fois, 70 % plus vite pendant 2 s. Réglage d’essai.",
	14:"Golem de magma : à sa mort, il éclate en deux Braises rapides. Réglage d’essai.",
	15:"Braise : éclat rapide et fragile d’un golem de magma. Réglage d’essai.",
	16:"Scorpion des dunes : il avance deux fois plus vite pendant la Tempête de sable. Réglage d’essai.",
	17:"Taupe des galeries : elle parcourt une case sur trois sous terre, où elle est intouchable. Réglage d’essai.",
	18:"Crabe pilleur : s’il atteint la forteresse, il vole 20 or en plus des dégâts. Réglage d’essai.",
}
const SET_RULES := {"slate_ibex":13,"ash_golems":14,"dune_scorpions":16,"mine_moles":17,"coast_crabs":18}

static func valid_set(id: Variant) -> bool:
	return id is String and WAVES.has(id)

static func rule_for_set(id: String) -> String:
	return RULES[SET_RULES[id]] if SET_RULES.has(id) else ""

## Vrai si la taupe est sous terre à cette distance de sa route.
static func underground(distance: float, route_length: float) -> bool:
	if distance >= route_length-BURROW_LAST_TILE: return false
	return fposmod(distance,BURROW_CYCLE) > BURROW_SURFACE+0.000000001 # L'instant exact où elle s'enfouit compte encore en surface, comme la fin d'une fenêtre de tir.

## Parties des fenêtres de portée où la taupe est en surface : elle ne peut être visée que là.
static func surface_windows(windows: Array, route_length: float) -> Array:
	var result: Array = []
	for window in windows:
		var first: float = float(window.first)
		var last: float = float(window.last)
		var start: float = floor(first/BURROW_CYCLE)*BURROW_CYCLE
		while start <= last:
			_clip(result,first,last,start,start+BURROW_SURFACE)
			start += BURROW_CYCLE
		_clip(result,first,last,route_length-BURROW_LAST_TILE,route_length)
	return result

static func _clip(result: Array, first: float, last: float, from: float, to: float) -> void:
	var low: float = maxf(first,from)
	var high: float = minf(last,to)
	if low <= high: result.append({"first":low,"last":high})
