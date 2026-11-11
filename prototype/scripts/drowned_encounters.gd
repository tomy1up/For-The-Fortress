extends RefCounted
## Chapitre 6 des marais : Gueule-de-Vase (appelée Noyé jusqu'à la v0.175), créature neutre qui régénère ses PV dans l'eau.
## Noms, statistiques, régénération et composition sont des réglages de prototype à confirmer.
const ID := "marsh_drowned"
const TYPE := 9
const DEFINITION := {"name":"Gueule-de-Vase","hp":150.0,"speed":0.85,"fortress_damage":2,"reward":8}
## Part des PV maximum régénérée par seconde tant que Gueule-de-Vase se trouve dans un tronçon inondé.
const REGEN_PER_SECOND := 0.05
const MAX_STRETCHES := 8
## Même rythme que les rencontres du chapitre 2 ; Gueule-de-Vase remplace la tortue.
const WAVES: Array = [
	[[1,10,2.5]],
	[[9,1,0.0],[1,8,2.0],[0,6,0.65]],
	[[1,8,1.8],[2,8,1.4]],
	[[9,2,3.0],[0,16,0.5]],
	[[4,6,2.0],[9,2,3.0],[2,8,1.2]],
	[[5,2,4.0],[9,2,2.2],[0,12,0.5]],
	[[6,1,0.0],[5,2,4.0],[4,8,1.6]],
	[[9,3,2.0],[0,20,0.35],[2,10,1.0],[4,6,1.2]],
	[[6,2,5.0],[5,2,4.0],[9,2,2.2],[4,6,1.4]],
	[[7,1,0.0],[6,2,5.0],[9,1,0.0],[2,6,1.0]]
]

## Longueur du trajet comprise entre deux distances parcourues qui se trouve sous l'eau.
static func flooded_length(stretches: Array, route_id: String, from_distance: float, to_distance: float) -> float:
	var total: float = 0.0
	for stretch in stretches:
		if stretch.route != route_id: continue
		total += maxf(0.0,minf(to_distance,float(stretch.to))-maxf(from_distance,float(stretch.from)))
	return total

static func in_water(stretches: Array, route_id: String, distance: float) -> bool:
	for stretch in stretches:
		if stretch.route == route_id and distance >= float(stretch.from) and distance < float(stretch.to): return true
	return false

## PV rendus pendant un déplacement : calcul exact par tronçon, indépendant du pas de temps.
static func regenerated(stretches: Array, route_id: String, max_hp: float, speed: float, from_distance: float, to_distance: float) -> float:
	if stretches.is_empty() or speed <= 0.0 or to_distance <= from_distance: return 0.0
	return max_hp*REGEN_PER_SECOND*flooded_length(stretches,route_id,from_distance,to_distance)/speed

## Tronçons inondés : {route, from, to} en distance parcourue, sans chevauchement par trajet.
static func stretches_error(stretches: Variant, route_lengths: Dictionary) -> String:
	if not stretches is Array or stretches.size() > MAX_STRETCHES: return "Tronçons inondés invalides."
	var last_end: Dictionary = {}
	for stretch in stretches:
		if not stretch is Dictionary or stretch.size() != 3 or not stretch.get("route") is String: return "Tronçon inondé mal formé."
		var route: String = stretch.route
		if not route_lengths.has(route): return "Tronçon inondé sur un trajet inconnu."
		var from_value: Variant = stretch.get("from")
		var to_value: Variant = stretch.get("to")
		for value in [from_value,to_value]:
			if not (value is int or value is float) or not is_finite(float(value)): return "Distance de tronçon inondé invalide."
		if float(from_value) < 0.0 or float(to_value) <= float(from_value) or float(to_value) > float(route_lengths[route]) + 0.000000001: return "Tronçon inondé hors du trajet."
		if float(from_value) < float(last_end.get(route,0.0)): return "Tronçons inondés superposés ou désordonnés."
		last_end[route] = float(to_value)
	return ""
