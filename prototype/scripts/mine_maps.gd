extends RefCounted
## Missions 121–130 : souterrains et mines (chapitre 13, sans règle propre ; habillage à produire par Codex).
## Tracés et emplacements sont des propositions de prototype à confirmer ; l'habillage revient à Codex.
const IDS: Array[String] = ["mine_entrance", "mine_shaft", "mine_gallery", "mine_crystals", "mine_cart", "mine_forge", "mine_lake", "mine_vault", "mine_collapse", "mine_heart"]
const TITLES: Dictionary = {"mine_entrance":"L'Entrée de la Mine", "mine_shaft":"Le Puits Principal", "mine_gallery":"La Galerie des Échos", "mine_crystals":"La Grotte aux Cristaux", "mine_cart":"Les Rails Abandonnés", "mine_forge":"La Forge Souterraine", "mine_lake":"Le Lac Noir", "mine_vault":"La Chambre Forte", "mine_collapse":"L'Éboulis", "mine_heart":"Le Cœur de la Montagne"}

static func board(id: String) -> Dictionary:
	match id:
		"mine_entrance": return _board(id,[["",[Vector2(0,1),Vector2(3,1),Vector2(3,8),Vector2(6,8),Vector2(6,2),Vector2(9,2),Vector2(9,6),Vector2(17,6)]]],[Vector2(4.5,3),Vector2(10.5,4),Vector2(7.5,5),Vector2(7.5,7),Vector2(4.5,5),Vector2(4.5,1)],false)
		"mine_shaft": return _board(id,[["",[Vector2(0,8),Vector2(3,8),Vector2(3,3),Vector2(6,3),Vector2(6,7),Vector2(9,7),Vector2(9,2),Vector2(14,2),Vector2(14,6),Vector2(17,6)]]],[Vector2(1.5,5),Vector2(4.5,8),Vector2(11.5,4.5),Vector2(4.5,6),Vector2(7.5,4),Vector2(7.5,2)],false)
		"mine_gallery": return _board(id,[["upper",[Vector2(0,2),Vector2(4,2),Vector2(4,4),Vector2(6,4),Vector2(6,3),Vector2(8,3),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(4,8),Vector2(4,6),Vector2(6,6),Vector2(6,7),Vector2(8,7),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(11,3.5),Vector2(9.5,8.5),Vector2(12.5,5),Vector2(15.5,5),Vector2(15.5,7)],true)
		"mine_crystals": return _board(id,[["upper",[Vector2(0,1),Vector2(4,1),Vector2(4,3),Vector2(6,3),Vector2(6,2),Vector2(8,2),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(3,5),Vector2(3,6),Vector2(5,6),Vector2(5,5),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(4,9),Vector2(4,7),Vector2(6,7),Vector2(6,8),Vector2(8,8),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(15.5,7),Vector2(15.5,5),Vector2(11,3.5),Vector2(12.5,5),Vector2(12.5,2.5)],false)
		"mine_cart": return _board(id,[["",[Vector2(0,2),Vector2(3,2),Vector2(3,8),Vector2(6,8),Vector2(6,3),Vector2(9,3),Vector2(9,6),Vector2(17,6)]]],[Vector2(10.5,4.5),Vector2(1.5,5),Vector2(7.5,6),Vector2(4.5,3),Vector2(4.5,5),Vector2(8.5,7.5)],false)
		"mine_forge": return _board(id,[["upper",[Vector2(0,1),Vector2(3,1),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,7),Vector2(14,7),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(3,9),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,7),Vector2(14,7),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(15.5,7),Vector2(15.5,5),Vector2(12.5,4),Vector2(9.5,3.5),Vector2(11.5,2.5)],true)
		"mine_lake": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(14,2),Vector2(14,7),Vector2(17,7),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(14,2),Vector2(14,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(14,2),Vector2(14,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(9.5,3.5),Vector2(8,2.5),Vector2(11,6.5),Vector2(12.5,5),Vector2(15.5,4),Vector2(12.5,7.5)],false)
		"mine_vault": return _board(id,[["upper",[Vector2(0,1),Vector2(3,1),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,3),Vector2(17,3),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(3,9),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,3),Vector2(17,3),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(8,7.5),Vector2(15.5,6),Vector2(11,3.5),Vector2(12.5,5),Vector2(9,3)],true)
		"mine_collapse": return _board(id,[["",[Vector2(0,3),Vector2(3,3),Vector2(3,8),Vector2(6,8),Vector2(6,2),Vector2(9,2),Vector2(9,5),Vector2(17,5),Vector2(17,6)]]],[Vector2(4.5,3),Vector2(1.5,6),Vector2(3,1.5),Vector2(4.5,5),Vector2(7.5,5),Vector2(10.5,3.5)],false)
		"mine_heart": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,4),Vector2(8,4),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(3,5),Vector2(3,6),Vector2(5,6),Vector2(5,5),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(9.5,6.5),Vector2(15.5,7),Vector2(15.5,5),Vector2(11,3.5),Vector2(12.5,5),Vector2(8,7.5)],false)
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
	var board: Dictionary = {"id":id,"title":TITLES[id],"size":Vector2i(18,10),"path_points":routes[0].path_points,"path_length":routes[0].path_length,"slots":slot_points,"trees":[],"decoration":"mine"}
	if routes.size() > 1: board.routes = routes
	if alternating: board.route_pattern = "alternating_pressure"
	return board
