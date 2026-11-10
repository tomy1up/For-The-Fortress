extends RefCounted
## Missions 52–60 : cartes des marais avec tronçons inondés, où le Noyé régénère ses PV.
## Tracés, emplacements, bassins et eau sont des propositions de prototype à confirmer.
const IDS: Array[String] = ["marsh_banks", "marsh_currents", "marsh_abyss", "marsh_delta", "marsh_overflow", "marsh_pillars", "marsh_crossroads", "marsh_cathedral", "marsh_heart"]
const TITLES: Dictionary = {"marsh_banks":"Les Berges Noyées", "marsh_currents":"Les Gués du Double Courant", "marsh_abyss":"La Mare Sans Fond", "marsh_delta":"Le Delta des Noyés", "marsh_overflow":"La Crue", "marsh_pillars":"Les Piliers Engloutis", "marsh_crossroads":"Le Carrefour des Eaux", "marsh_cathedral":"La Cathédrale Noyée", "marsh_heart":"Le Cœur du Marais"}

static func board(id: String) -> Dictionary:
	match id:
		"marsh_banks": return _board(id,[["",[Vector2(0,8),Vector2(5,8),Vector2(5,3),Vector2(9,3),Vector2(9,7),Vector2(13,7),Vector2(13,2),Vector2(17,2),Vector2(17,6)]]],[Vector2(11,4.5),Vector2(3,5.5),Vector2(7,5.5),Vector2(14.5,4.5),Vector2(11,2.5),Vector2(7,7.5)],[Rect2(0.5,0.5,2.5,2.5),Rect2(14,7,2.5,2.5),Rect2(3.5,0.5,4,1.2),Rect2(8,8,4,1.2)],[["",Vector2(5,8),Vector2(9,3)]],false)
		"marsh_currents": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,5),Vector2(7,5),Vector2(7,2),Vector2(11,2),Vector2(11,8),Vector2(15,8),Vector2(15,4),Vector2(17,4),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,5),Vector2(7,5),Vector2(7,2),Vector2(11,2),Vector2(11,8),Vector2(15,8),Vector2(15,4),Vector2(17,4),Vector2(17,6)]]],[Vector2(9,4.5),Vector2(13,3),Vector2(5.5,3),Vector2(9,6.5),Vector2(13,5),Vector2(1.5,5)],[Rect2(4,6,2.5,2.5),Rect2(14,0.5,2.5,2.5),Rect2(7,7.5,3,1.5),Rect2(16,7,1.5,2.6)],[["upper",Vector2(7,2),Vector2(11,8)],["lower",Vector2(7,2),Vector2(11,8)]],true)
		"marsh_abyss": return _board(id,[["",[Vector2(0,5),Vector2(3,5),Vector2(3,1),Vector2(7,1),Vector2(7,8),Vector2(11,8),Vector2(11,3),Vector2(14,3),Vector2(14,8),Vector2(17,8),Vector2(17,6)]]],[Vector2(9,5),Vector2(15.5,5),Vector2(5,4),Vector2(9,3),Vector2(12.5,6),Vector2(12.5,8)],[Rect2(0.5,6,2.5,2.5),Rect2(3.5,6,2.5,2.5),Rect2(15,0.5,2.5,2.5),Rect2(8,0.5,4,1.2)],[["",Vector2(7,1),Vector2(11,3)]],false)
		"marsh_delta": return _board(id,[["upper",[Vector2(0,1),Vector2(5,1),Vector2(5,3),Vector2(9,3),Vector2(9,5),Vector2(12,5),Vector2(12,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(9,5),Vector2(12,5),Vector2(12,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(4,9),Vector2(4,7),Vector2(9,7),Vector2(9,5),Vector2(12,5),Vector2(12,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]]],[Vector2(10.5,3.5),Vector2(16.5,3),Vector2(3.5,3.5),Vector2(13.5,5),Vector2(12,6.5),Vector2(10.5,1.5)],[Rect2(13,7,2.5,2.5),Rect2(5,8,4,1.2),Rect2(6,0.5,3,1.5),Rect2(9.5,8,3,1.5)],[["upper",Vector2(9,5),Vector2(12,2)],["middle",Vector2(9,5),Vector2(12,2)],["lower",Vector2(9,5),Vector2(12,2)]],false)
		"marsh_overflow": return _board(id,[["upper",[Vector2(0,1),Vector2(4,1),Vector2(4,3),Vector2(8,3),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(14,2),Vector2(14,8),Vector2(16,8),Vector2(16,6),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(4,9),Vector2(4,7),Vector2(8,7),Vector2(8,5),Vector2(11,5),Vector2(11,2),Vector2(14,2),Vector2(14,8),Vector2(16,8),Vector2(16,6),Vector2(17,6)]]],[Vector2(9.5,3.5),Vector2(15.5,4.5),Vector2(4.5,5),Vector2(12.5,5),Vector2(11,6.5),Vector2(6.5,5)],[Rect2(0.5,2,2.5,2.5),Rect2(0.5,5,2.5,2.5),Rect2(15,0.5,2.5,2.5),Rect2(5,0.5,4,1.2)],[["upper",Vector2(14,2),Vector2(16,8)],["lower",Vector2(14,2),Vector2(16,8)]],true)
		"marsh_pillars": return _board(id,[["",[Vector2(0,2),Vector2(4,2),Vector2(4,6),Vector2(7,6),Vector2(7,2),Vector2(10,2),Vector2(10,6),Vector2(13,6),Vector2(13,2),Vector2(16,2),Vector2(16,6),Vector2(17,6)]]],[Vector2(14.5,5),Vector2(2.5,4.5),Vector2(5.5,3),Vector2(8.5,5),Vector2(11.5,3),Vector2(5.5,1)],[Rect2(0.5,5.5,2.5,2.5),Rect2(3.5,7,2.5,2.5),Rect2(6.5,7,2.5,2.5),Rect2(9.5,7,2.5,2.5)],[["",Vector2(4,6),Vector2(7,2)],["",Vector2(10,6),Vector2(13,2)]],false)
		"marsh_crossroads": return _board(id,[["upper",[Vector2(0,1),Vector2(6,1),Vector2(6,5),Vector2(9,5),Vector2(12,5),Vector2(12,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(9,5),Vector2(12,5),Vector2(12,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(6,9),Vector2(6,5),Vector2(9,5),Vector2(12,5),Vector2(12,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]]],[Vector2(9,3.5),Vector2(10.5,2.5),Vector2(4.5,3.5),Vector2(13.5,5),Vector2(12,6.5),Vector2(16.5,3)],[Rect2(7,6,2.5,2.5),Rect2(13,7,2.5,2.5),Rect2(0.5,6,4,1.2),Rect2(0.5,2,3,1.5)],[["upper",Vector2(6,1),Vector2(6,5)],["lower",Vector2(6,9),Vector2(6,5)]],false)
		"marsh_cathedral": return _board(id,[["upper",[Vector2(0,1),Vector2(4,1),Vector2(4,4),Vector2(8,4),Vector2(8,2),Vector2(11,2),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,3),Vector2(17,3),Vector2(17,6)]],["lower",[Vector2(0,9),Vector2(3,9),Vector2(3,6),Vector2(8,6),Vector2(8,5),Vector2(11,5),Vector2(11,8),Vector2(14,8),Vector2(14,3),Vector2(17,3),Vector2(17,6)]]],[Vector2(15.5,6),Vector2(9.5,6.5),Vector2(6.5,2.5),Vector2(12.5,5),Vector2(12.5,3),Vector2(9.5,3.5)],[Rect2(0.5,2,2.5,2.5),Rect2(4,7,2.5,2.5),Rect2(15,7,2.5,2.5),Rect2(12,0.5,4,1.2)],[["upper",Vector2(11,8),Vector2(14,3)],["lower",Vector2(11,8),Vector2(14,3)]],true)
		"marsh_heart": return _board(id,[["upper",[Vector2(0,2),Vector2(3,2),Vector2(3,5),Vector2(8,5),Vector2(8,8),Vector2(12,8),Vector2(12,2),Vector2(15,2),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["middle",[Vector2(0,5),Vector2(3,5),Vector2(8,5),Vector2(8,8),Vector2(12,8),Vector2(12,2),Vector2(15,2),Vector2(15,7),Vector2(17,7),Vector2(17,6)]],["lower",[Vector2(0,8),Vector2(3,8),Vector2(3,5),Vector2(8,5),Vector2(8,8),Vector2(12,8),Vector2(12,2),Vector2(15,2),Vector2(15,7),Vector2(17,7),Vector2(17,6)]]],[Vector2(5.5,6.5),Vector2(16.5,4),Vector2(10,5.5),Vector2(13.5,7),Vector2(13.5,5),Vector2(6.5,8)],[Rect2(4,0.5,2.5,2.5),Rect2(7,0.5,2.5,2.5),Rect2(13,8,4,1.2)],[["upper",Vector2(3,2),Vector2(3,5)],["lower",Vector2(3,8),Vector2(3,5)],["upper",Vector2(8,5),Vector2(17,6)],["middle",Vector2(8,5),Vector2(17,6)],["lower",Vector2(8,5),Vector2(17,6)]],false)
	return {}

static func _length(points: Array) -> float:
	var total: float = 0.0
	for index in range(1,points.size()): total += points[index-1].distance_to(points[index])
	return total

static func _board(id: String, route_data: Array, slots: Array, pools: Array, flood: Array, alternating: bool) -> Dictionary:
	var routes: Array[Dictionary] = []
	for entry in route_data:
		var points: Array[Vector2] = []
		points.assign(entry[1])
		routes.append({"id":entry[0],"path_points":points,"path_length":_length(points)})
	var stretches: Array[Dictionary] = []
	for spec in flood:
		var points: Array[Vector2] = routes[0].path_points
		for route in routes:
			if route.id == spec[0]: points = route.path_points
		var first: int = points.find(spec[1])
		var last: int = points.find(spec[2],first+1)
		if first < 0 or last < 0: return {}
		stretches.append({"route":spec[0],"from":_length(points.slice(0,first+1)),"to":_length(points.slice(0,last+1))})
	var slot_points: Array[Vector2] = []
	slot_points.assign(slots)
	var pool_rects: Array[Rect2] = []
	pool_rects.assign(pools)
	var board: Dictionary = {"id":id,"title":TITLES[id],"size":Vector2i(18,10),"path_points":routes[0].path_points,"path_length":routes[0].path_length,"slots":slot_points,"trees":[],"decoration":"marsh","flooded":stretches,"water_areas":pool_rects}
	if routes.size() > 1: board.routes = routes
	if alternating: board.route_pattern = "alternating_pressure"
	return board
