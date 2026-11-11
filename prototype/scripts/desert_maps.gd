extends RefCounted
## Missions 101–110 : désert et ruines (chapitre 11, sans règle propre ; habillage à produire par Codex).
## Tracés et emplacements sont des propositions de prototype à confirmer ; l'habillage revient à Codex.
const IDS: Array[String] = ["dune_first", "dune_oasis", "dune_canyon", "dune_columns", "dune_caravans", "dune_temple", "dune_well", "dune_obelisks", "dune_sea", "dune_necropolis"]
const TITLES: Dictionary = {"dune_first":"Les Premières Dunes", "dune_oasis":"L'Oasis Asséchée", "dune_canyon":"Le Canyon Rouge", "dune_columns":"Les Colonnes Brisées", "dune_caravans":"La Route des Caravanes", "dune_temple":"Le Temple Ensablé", "dune_well":"Le Puits Perdu", "dune_obelisks":"Les Obélisques", "dune_sea":"La Mer de Sable", "dune_necropolis":"La Nécropole Ancienne"}

static func board(id: String) -> Dictionary:
	match id:
		"dune_first": return _board(id,[["",[Vector2(0,5),Vector2(5,5),Vector2(5,2),Vector2(9,2),Vector2(9,6),Vector2(17,6)]]],[Vector2(3.5,3.5),Vector2(2,2.5),Vector2(10.5,4),Vector2(5,6.5),Vector2(7,4.5),Vector2(12,3)],false)
		"dune_oasis": return _board(id,[["",[Vector2(0,2),Vector2(4,2),Vector2(4,7),Vector2(8,7),Vector2(8,3),Vector2(12,3),Vector2(12,6),Vector2(17,6)]]],[Vector2(2.5,4.5),Vector2(13.5,4.5),Vector2(10,5.5),Vector2(6,2.5),Vector2(6,4.5),Vector2(1,3.5)],false)
		"dune_canyon": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,7),Vector2(14,7),Vector2(14,3),Vector2(17,3),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,7),Vector2(14,7),Vector2(14,3),Vector2(17,3),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(2,5),Vector2(9.5,3.5),Vector2(12.5,4),Vector2(15.5,6),Vector2(8,7.5)],true)
		"dune_columns": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,3),Vector2(14,3),Vector2(14,7),Vector2(17,7),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(8,5),Vector2(11,5),Vector2(11,3),Vector2(14,3),Vector2(14,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,3),Vector2(14,3),Vector2(14,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(15.5,4),Vector2(9.5,3.5),Vector2(6,7.5),Vector2(12.5,6),Vector2(9.5,6.5),Vector2(8,2.5)],false)
		"dune_caravans": return _board(id,[["",[Vector2(0,8),Vector2(3,8),Vector2(3,3),Vector2(6,3),Vector2(6,6),Vector2(9,6),Vector2(17,6)]]],[Vector2(5.5,7.5),Vector2(9,3.5),Vector2(4.5,6),Vector2(1.5,5),Vector2(7.5,4.5),Vector2(8.5,7.5)],false)
		"dune_temple": return _board(id,[["upper",[Vector2(0,1),Vector2(3,1),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,7),Vector2(14,7),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(3,9),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,7),Vector2(14,7),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(15.5,7),Vector2(15.5,5),Vector2(12.5,4),Vector2(9.5,3.5),Vector2(11.5,2.5)],true)
		"dune_well": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(14,2),Vector2(14,7),Vector2(17,7),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(14,2),Vector2(14,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(14,2),Vector2(14,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(15.5,4),Vector2(11.5,6.5),Vector2(12.5,5),Vector2(9.5,3.5),Vector2(15.5,2),Vector2(8,2.5)],false)
		"dune_obelisks": return _board(id,[["upper",[Vector2(0,1),Vector2(3,1),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,3),Vector2(17,3),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(3,9),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,3),Vector2(17,3),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(8,7.5),Vector2(15.5,6),Vector2(11,3.5),Vector2(12.5,5),Vector2(9,3)],true)
		"dune_sea": return _board(id,[["",[Vector2(0,3),Vector2(4,3),Vector2(4,7),Vector2(7,7),Vector2(7,3),Vector2(11,3),Vector2(11,5),Vector2(17,5),Vector2(17,6)]]],[Vector2(2.5,5.5),Vector2(14,3.5),Vector2(3,1.5),Vector2(5.5,4),Vector2(9,5.5),Vector2(5.5,2)],false)
		"dune_necropolis": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,7),Vector2(14,7),Vector2(14,3),Vector2(17,3),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(8,5),Vector2(11,5),Vector2(11,7),Vector2(14,7),Vector2(14,3),Vector2(17,3),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,7),Vector2(14,7),Vector2(14,3),Vector2(17,3),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(8,7.5),Vector2(9.5,3.5),Vector2(12.5,4),Vector2(15.5,6),Vector2(12.5,8.5)],false)
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
	var board: Dictionary = {"id":id,"title":TITLES[id],"size":Vector2i(18,10),"path_points":routes[0].path_points,"path_length":routes[0].path_length,"slots":slot_points,"trees":[],"decoration":"desert"}
	if routes.size() > 1: board.routes = routes
	if alternating: board.route_pattern = "alternating_pressure"
	return board
