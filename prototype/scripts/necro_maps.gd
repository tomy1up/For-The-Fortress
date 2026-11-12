extends RefCounted
## Missions 181–200 : nécropole et terres maudites (chapitre 19 sans règle propre ; habillage à produire par Codex).
## Tracés et emplacements sont des propositions de prototype à confirmer ; l'habillage revient à Codex.
const IDS: Array[String] = ["necro_gate", "necro_road", "necro_graveyard", "necro_crypts", "necro_fen", "necro_hill", "necro_mausoleums", "necro_ossuary", "necro_stelae", "necro_royal"]
const TITLES: Dictionary = {"necro_gate":"Le Portail des Ossements", "necro_road":"La Route des Tombes", "necro_graveyard":"Le Cimetière Oublié", "necro_crypts":"Les Cryptes Basses", "necro_fen":"Le Marais des Défunts", "necro_hill":"La Colline des Pendus", "necro_mausoleums":"Les Mausolées Jumeaux", "necro_ossuary":"L'Ossuaire", "necro_stelae":"Le Champ des Stèles", "necro_royal":"La Nécropole Royale"}

static func board(id: String) -> Dictionary:
	match id:
		"necro_gate": return _board(id,[["",[Vector2(0,1),Vector2(3,1),Vector2(3,8),Vector2(6,8),Vector2(6,2),Vector2(9,2),Vector2(9,6),Vector2(12,6),Vector2(12,2),Vector2(14,2),Vector2(14,8),Vector2(17,8),Vector2(17,6)]]],[Vector2(4.5,5),Vector2(15.5,5),Vector2(10.5,3),Vector2(4.5,3),Vector2(7.5,5),Vector2(12.5,7.5)],false)
		"necro_road": return _board(id,[["",[Vector2(0,8),Vector2(3,8),Vector2(3,3),Vector2(6,3),Vector2(6,7),Vector2(9,7),Vector2(9,2),Vector2(12,2),Vector2(12,7),Vector2(14,7),Vector2(14,1),Vector2(16,1),Vector2(16,6),Vector2(17,6)]]],[Vector2(10.5,7),Vector2(1.5,5),Vector2(4.5,6),Vector2(7.5,4),Vector2(10.5,5),Vector2(4.5,8)],false)
		"necro_graveyard": return _board(id,[["upper",[Vector2(0,1),Vector2(4,1),Vector2(4,4),Vector2(6,4),Vector2(6,2),Vector2(8,2),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(4,9),Vector2(4,6),Vector2(6,6),Vector2(6,8),Vector2(8,8),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(16.5,4),Vector2(10,2),Vector2(9.5,7.5),Vector2(14.5,8.5),Vector2(11,3.5),Vector2(16.5,2)],true)
		"necro_crypts": return _board(id,[["upper",[Vector2(0,1),Vector2(4,1),Vector2(4,3),Vector2(6,3),Vector2(6,2),Vector2(8,2),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(3,5),Vector2(3,6),Vector2(5,6),Vector2(5,5),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(4,9),Vector2(4,7),Vector2(6,7),Vector2(6,8),Vector2(8,8),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(9.5,7.5),Vector2(16.5,4),Vector2(11.5,1.5),Vector2(11,3.5),Vector2(14.5,8.5),Vector2(16.5,2)],false)
		"necro_fen": return _board(id,[["",[Vector2(0,5),Vector2(3,5),Vector2(3,1),Vector2(6,1),Vector2(6,8),Vector2(9,8),Vector2(9,3),Vector2(12,3),Vector2(12,8),Vector2(14,8),Vector2(14,1),Vector2(16,1),Vector2(16,6),Vector2(17,6)]]],[Vector2(7.5,5),Vector2(4.5,6),Vector2(4.5,4),Vector2(7.5,3),Vector2(10.5,6),Vector2(10.5,8)],false)
		"necro_hill": return _board(id,[["upper",[Vector2(0,2),Vector2(4,2),Vector2(4,4),Vector2(6,4),Vector2(6,3),Vector2(8,3),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(4,8),Vector2(4,6),Vector2(6,6),Vector2(6,7),Vector2(8,7),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(16.5,4),Vector2(10,2),Vector2(14.5,8.5),Vector2(11,3.5),Vector2(9.5,7.5),Vector2(3,5)],true)
		"necro_mausoleums": return _board(id,[["upper",[Vector2(0,2),Vector2(4,2),Vector2(4,3),Vector2(6,3),Vector2(6,2),Vector2(8,2),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(2,5),Vector2(2,6),Vector2(4,6),Vector2(4,5),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(4,8),Vector2(4,7),Vector2(6,7),Vector2(6,8),Vector2(8,8),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(9.5,7.5),Vector2(16.5,4),Vector2(11.5,1.5),Vector2(11,3.5),Vector2(14.5,8.5),Vector2(16.5,2)],false)
		"necro_ossuary": return _board(id,[["upper",[Vector2(0,1),Vector2(3,1),Vector2(3,4),Vector2(6,4),Vector2(6,2),Vector2(8,2),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(3,9),Vector2(3,6),Vector2(6,6),Vector2(6,8),Vector2(8,8),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(16.5,4),Vector2(10,2),Vector2(9.5,7.5),Vector2(14.5,8.5),Vector2(11,3.5),Vector2(16.5,2)],true)
		"necro_stelae": return _board(id,[["",[Vector2(0,3),Vector2(3,3),Vector2(3,8),Vector2(6,8),Vector2(6,2),Vector2(9,2),Vector2(9,6),Vector2(12,6),Vector2(12,2),Vector2(14,2),Vector2(14,8),Vector2(17,8),Vector2(17,6)]]],[Vector2(15.5,5),Vector2(4.5,3),Vector2(10.5,3),Vector2(4.5,5),Vector2(7.5,5),Vector2(12.5,7.5)],false)
		"necro_royal": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(3,5),Vector2(3,6),Vector2(5,6),Vector2(5,5),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,9),Vector2(13,9),Vector2(13,1),Vector2(15,1),Vector2(15,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(14.5,8.5),Vector2(10,2),Vector2(16.5,4),Vector2(11,3.5),Vector2(9,7),Vector2(16.5,2)],false)
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
	var board: Dictionary = {"id":id,"title":TITLES[id],"size":Vector2i(18,10),"path_points":routes[0].path_points,"path_length":routes[0].path_length,"slots":slot_points,"trees":[],"decoration":"necro"}
	if routes.size() > 1: board.routes = routes
	if alternating: board.route_pattern = "alternating_pressure"
	return board
