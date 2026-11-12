extends RefCounted
## Missions 141–150 : îles flottantes et cité céleste (chapitre 15, sans règle propre ; habillage à produire par Codex).
## Tracés et emplacements sont des propositions de prototype à confirmer ; l'habillage revient à Codex.
const IDS: Array[String] = ["sky_pontoon", "sky_mistbridge", "sky_cloudgate", "sky_spires", "sky_gardens", "sky_belvedere", "sky_updrafts", "sky_dome", "sky_fallen", "sky_summit"]
const TITLES: Dictionary = {"sky_pontoon":"Le Ponton des Nuées", "sky_mistbridge":"Le Pont de Brume", "sky_cloudgate":"La Porte des Nuages", "sky_spires":"Les Flèches d'Azur", "sky_gardens":"Les Jardins Suspendus", "sky_belvedere":"Le Belvédère", "sky_updrafts":"Les Courants Ascendants", "sky_dome":"Le Dôme Céleste", "sky_fallen":"L'Île Effondrée", "sky_summit":"La Citadelle des Cimes"}

static func board(id: String) -> Dictionary:
	match id:
		"sky_pontoon": return _board(id,[["",[Vector2(0,1),Vector2(3,1),Vector2(3,8),Vector2(6,8),Vector2(6,2),Vector2(9,2),Vector2(9,6),Vector2(17,6)]]],[Vector2(4.5,3),Vector2(7.5,7),Vector2(1.5,6),Vector2(4.5,5),Vector2(7.5,5),Vector2(10.5,4)],false)
		"sky_mistbridge": return _board(id,[["",[Vector2(0,8),Vector2(3,8),Vector2(3,3),Vector2(6,3),Vector2(6,7),Vector2(9,7),Vector2(9,2),Vector2(14,2),Vector2(14,6),Vector2(17,6)]]],[Vector2(11.5,4.5),Vector2(4.5,8),Vector2(1.5,5),Vector2(4.5,6),Vector2(7.5,4),Vector2(7.5,2)],false)
		"sky_cloudgate": return _board(id,[["upper",[Vector2(0,1),Vector2(4,1),Vector2(4,4),Vector2(6,4),Vector2(6,2),Vector2(8,2),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(4,9),Vector2(4,6),Vector2(6,6),Vector2(6,8),Vector2(8,8),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(9.5,7),Vector2(15.5,7),Vector2(15.5,5),Vector2(11,3.5),Vector2(12.5,5),Vector2(12.5,2.5)],true)
		"sky_spires": return _board(id,[["upper",[Vector2(0,1),Vector2(4,1),Vector2(4,3),Vector2(6,3),Vector2(6,2),Vector2(8,2),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(3,5),Vector2(3,6),Vector2(5,6),Vector2(5,5),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(4,9),Vector2(4,7),Vector2(6,7),Vector2(6,8),Vector2(8,8),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(15.5,5),Vector2(11,3.5),Vector2(15.5,7),Vector2(12.5,5),Vector2(9.5,6.5),Vector2(12.5,2.5)],false)
		"sky_gardens": return _board(id,[["",[Vector2(0,2),Vector2(3,2),Vector2(3,8),Vector2(6,8),Vector2(6,3),Vector2(9,3),Vector2(9,6),Vector2(17,6)]]],[Vector2(7.5,6),Vector2(10.5,4.5),Vector2(9,7.5),Vector2(4.5,5),Vector2(4.5,3),Vector2(1.5,5)],false)
		"sky_belvedere": return _board(id,[["upper",[Vector2(0,2),Vector2(4,2),Vector2(4,4),Vector2(6,4),Vector2(6,3),Vector2(8,3),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(4,8),Vector2(4,6),Vector2(6,6),Vector2(6,7),Vector2(8,7),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(15.5,7),Vector2(11,3.5),Vector2(12.5,5),Vector2(15.5,5),Vector2(3,5)],true)
		"sky_updrafts": return _board(id,[["upper",[Vector2(0,2),Vector2(4,2),Vector2(4,3),Vector2(6,3),Vector2(6,2),Vector2(8,2),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(2,5),Vector2(2,6),Vector2(4,6),Vector2(4,5),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(4,8),Vector2(4,7),Vector2(6,7),Vector2(6,8),Vector2(8,8),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(15.5,7),Vector2(15.5,5),Vector2(11,3.5),Vector2(12.5,5),Vector2(12.5,2.5)],false)
		"sky_dome": return _board(id,[["upper",[Vector2(0,1),Vector2(3,1),Vector2(3,4),Vector2(6,4),Vector2(6,2),Vector2(8,2),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(3,9),Vector2(3,6),Vector2(6,6),Vector2(6,8),Vector2(8,8),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(9.5,7),Vector2(15.5,7),Vector2(11,3.5),Vector2(12.5,5),Vector2(15.5,5),Vector2(12.5,2.5)],true)
		"sky_fallen": return _board(id,[["",[Vector2(0,3),Vector2(3,3),Vector2(3,8),Vector2(6,8),Vector2(6,2),Vector2(9,2),Vector2(9,5),Vector2(17,5),Vector2(17,6)]]],[Vector2(1.5,6),Vector2(10.5,3.5),Vector2(4.5,3),Vector2(4.5,5),Vector2(7.5,5),Vector2(8.5,6.5)],false)
		"sky_summit": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(3,5),Vector2(3,6),Vector2(5,6),Vector2(5,5),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(15.5,7),Vector2(15.5,5),Vector2(11,3.5),Vector2(12.5,5),Vector2(8,7.5)],false)
	return {}

static func _length(points: Array) -> float:
	var total: float = 0.0
	for index in range(1,points.size()): total += points[index-1].distance_to(points[index])
	return total

static func _board(id: String, route_data: Array, slots: Array, alternating: bool) -> Dictionary:
	var routes: Array[Dictionary] = []
	for entry in route_data:
		var points: Array[Vector2] = []
		points.assign(entry[1])
		routes.append({"id":entry[0],"path_points":points,"path_length":_length(points)})
	var slot_points: Array[Vector2] = []
	slot_points.assign(slots)
	var board: Dictionary = {"id":id,"title":TITLES[id],"size":Vector2i(18,10),"path_points":routes[0].path_points,"path_length":routes[0].path_length,"slots":slot_points,"trees":[],"decoration":"sky"}
	if routes.size() > 1: board.routes = routes
	if alternating: board.route_pattern = "alternating_pressure"
	return board
