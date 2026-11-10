extends RefCounted
## Missions 61–70 : cartes volcaniques du chapitre 7 (ambiance seulement, sans règle propre).
## Tracés et emplacements sont des propositions de prototype à confirmer ; l'habillage revient à Codex.
const IDS: Array[String] = ["volcano_threshold", "volcano_flows", "volcano_caldera", "volcano_vents", "volcano_forges", "volcano_bridge", "volcano_organs", "volcano_twin", "volcano_road", "volcano_core"]
const TITLES: Dictionary = {"volcano_threshold":"Le Seuil des Cendres", "volcano_flows":"Les Coulées Figées", "volcano_caldera":"La Caldeira", "volcano_vents":"Les Fumerolles", "volcano_forges":"Les Forges Noires", "volcano_bridge":"Le Pont d'Obsidienne", "volcano_organs":"Les Orgues de Basalte", "volcano_twin":"Le Cratère Jumeau", "volcano_road":"La Route des Cendres", "volcano_core":"Le Cœur du Volcan"}

static func board(id: String) -> Dictionary:
	match id:
		"volcano_threshold": return _board(id,[["",[Vector2(0,1),Vector2(5,1),Vector2(5,8),Vector2(9,8),Vector2(9,3),Vector2(13,3),Vector2(13,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(14.5,4.5),Vector2(3,3.5),Vector2(11,5.5),Vector2(7,3),Vector2(7,5),Vector2(11,7.5)],false)
		"volcano_flows": return _board(id,[["",[Vector2(0,1),Vector2(6,1),Vector2(6,4),Vector2(2,4),Vector2(2,8),Vector2(9,8),Vector2(9,5),Vector2(17,5),Vector2(17,6)]]],[Vector2(3,2.5),Vector2(10.5,6.5),Vector2(1,3),Vector2(5,6),Vector2(7,5.5),Vector2(7.5,3.5)],false)
		"volcano_caldera": return _board(id,[["upper",[Vector2(0,2),Vector2(5,2),Vector2(5,5),Vector2(9,5),Vector2(9,2),Vector2(13,2),Vector2(13,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(5,8),Vector2(5,5),Vector2(9,5),Vector2(9,2),Vector2(13,2),Vector2(13,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(7.5,3),Vector2(14.5,4.5),Vector2(3.5,5),Vector2(11,6.5),Vector2(11,4.5),Vector2(7,6.5)],true)
		"volcano_vents": return _board(id,[["",[Vector2(0,8),Vector2(3,8),Vector2(3,3),Vector2(7,3),Vector2(7,7),Vector2(12,7),Vector2(12,3),Vector2(17,3),Vector2(17,6)]]],[Vector2(9.5,4.5),Vector2(1.5,5),Vector2(14,5),Vector2(5,7.5),Vector2(5,5.5),Vector2(9.5,8.5)],false)
		"volcano_forges": return _board(id,[["upper",[Vector2(0,1),Vector2(4,1),Vector2(4,3),Vector2(8,3),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(4,9),Vector2(4,7),Vector2(8,7),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]]],[Vector2(16.5,3),Vector2(9.5,6.5),Vector2(13,6.5),Vector2(13,4.5),Vector2(9.5,3.5),Vector2(9.5,1.5)],false)
		"volcano_bridge": return _board(id,[["upper",[Vector2(0,2),Vector2(7,2),Vector2(7,5),Vector2(10,5),Vector2(10,2),Vector2(14,2),Vector2(14,6),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(7,8),Vector2(7,5),Vector2(10,5),Vector2(10,2),Vector2(14,2),Vector2(14,6),Vector2(17,6)]]],[Vector2(5.5,5),Vector2(8.5,6.5),Vector2(15.5,3),Vector2(12,4.5),Vector2(8.5,3),Vector2(11,6)],true)
		"volcano_organs": return _board(id,[["",[Vector2(0,2),Vector2(3,2),Vector2(3,8),Vector2(7,8),Vector2(7,3),Vector2(11,3),Vector2(11,6),Vector2(17,6)]]],[Vector2(12.5,4.5),Vector2(1.5,5),Vector2(9,5.5),Vector2(5,3),Vector2(5,5),Vector2(10,7)],false)
		"volcano_twin": return _board(id,[["upper",[Vector2(0,2),Vector2(4,2),Vector2(4,4),Vector2(8,4),Vector2(8,5),Vector2(12,5),Vector2(12,2),Vector2(15,2),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(4,8),Vector2(4,6),Vector2(8,6),Vector2(8,5),Vector2(12,5),Vector2(12,2),Vector2(15,2),Vector2(15,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(10.5,2),Vector2(12.5,6.5),Vector2(16.5,4),Vector2(13.5,5),Vector2(9.5,3.5),Vector2(9.5,6.5)],true)
		"volcano_road": return _board(id,[["upper",[Vector2(0,1),Vector2(5,1),Vector2(5,5),Vector2(9,5),Vector2(9,2),Vector2(14,2),Vector2(14,6),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(5,5),Vector2(9,5),Vector2(9,2),Vector2(14,2),Vector2(14,6),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(5,9),Vector2(5,5),Vector2(9,5),Vector2(9,2),Vector2(14,2),Vector2(14,6),Vector2(17,6)]]],[Vector2(15.5,3),Vector2(6.5,6.5),Vector2(3.5,3.5),Vector2(11.5,4.5),Vector2(7.5,3),Vector2(16.5,4.5)],false)
		"volcano_core": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,4),Vector2(6,4),Vector2(6,5),Vector2(10,5),Vector2(10,3),Vector2(14,3),Vector2(14,6),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(6,5),Vector2(10,5),Vector2(10,3),Vector2(14,3),Vector2(14,6),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,6),Vector2(6,6),Vector2(6,5),Vector2(10,5),Vector2(10,3),Vector2(14,3),Vector2(14,6),Vector2(17,6)]]],[Vector2(15.5,3),Vector2(7.5,6.5),Vector2(6,2.5),Vector2(12,5.5),Vector2(8.5,3.5),Vector2(12,1.5)],false)
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
	var board: Dictionary = {"id":id,"title":TITLES[id],"size":Vector2i(18,10),"path_points":routes[0].path_points,"path_length":routes[0].path_length,"slots":slot_points,"trees":[],"decoration":"volcanic"}
	if routes.size() > 1: board.routes = routes
	if alternating: board.route_pattern = "alternating_pressure"
	return board
