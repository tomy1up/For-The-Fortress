extends RefCounted
const Routes = preload("res://scripts/route_geometry.gd")
## Dix terrains de prototype du premier chapitre. Géométries à éprouver en jeu.
const CHAPTER_ONE_MAPS: Dictionary = {
	"ford_turns": {
		"id": "ford_turns",
		"title": "Les Détours du Gué",
		"size": [
			18,
			10
		],
		"path_points": [
			[
				0,
				2
			],
			[
				4,
				2
			],
			[
				4,
				8
			],
			[
				10,
				8
			],
			[
				10,
				3
			],
			[
				15,
				3
			],
			[
				15,
				6
			],
			[
				17,
				6
			]
		],
		"slots": [
			[
				2,
				3.5
			],
			[
				5.5,
				3.5
			],
			[
				6,
				6
			],
			[
				8.5,
				6
			],
			[
				12,
				4.5
			],
			[
				16.5,
				7.5
			]
		],
		"path_length": 31.0,
		"trees": [],
		"decoration": "none"
	},
	"ford_glade": {
		"id": "ford_glade",
		"title": "La Clairière du Gué",
		"size": [
			18,
			10
		],
		"path_points": [
			[
				0,
				4
			],
			[
				5,
				4
			],
			[
				5,
				1
			],
			[
				10,
				1
			],
			[
				10,
				7
			],
			[
				14,
				7
			],
			[
				14,
				3
			],
			[
				17,
				3
			],
			[
				17,
				6
			]
		],
		"slots": [
			[
				2.5,
				2.5
			],
			[
				6.5,
				2.5
			],
			[
				7.5,
				5.8
			],
			[
				11.5,
				5
			],
			[
				12.5,
				8.5
			],
			[
				15.5,
				4.2
			]
		],
		"path_length": 33.0,
		"trees": [],
		"decoration": "none"
	},
	"ford_pass": {
		"id": "ford_pass",
		"title": "Le Défilé du Gué",
		"size": [
			18,
			10
		],
		"path_points": [
			[
				0,
				7
			],
			[
				4,
				7
			],
			[
				4,
				2
			],
			[
				9,
				2
			],
			[
				9,
				8
			],
			[
				14,
				8
			],
			[
				14,
				4
			],
			[
				17,
				4
			],
			[
				17,
				6
			]
		],
		"slots": [
			[
				2,
				5
			],
			[
				5.5,
				4
			],
			[
				7.5,
				6
			],
			[
				10.5,
				5
			],
			[
				12.5,
				6
			],
			[
				15.5,
				6
			]
		],
		"path_length": 34.0,
		"trees": [],
		"decoration": "none"
	},
	"ford_switchbacks": {
		"id": "ford_switchbacks",
		"title": "Les Lacets du Gué",
		"size": [
			18,
			10
		],
		"path_points": [
			[
				0,
				3
			],
			[
				6,
				3
			],
			[
				6,
				8
			],
			[
				11,
				8
			],
			[
				11,
				2
			],
			[
				15,
				2
			],
			[
				15,
				6
			],
			[
				17,
				6
			]
		],
		"slots": [
			[
				3.5,
				4.5
			],
			[
				7.5,
				4.5
			],
			[
				8.5,
				6
			],
			[
				12.5,
				4.5
			],
			[
				13.5,
				7.5
			],
			[
				16.5,
				7.5
			]
		],
		"path_length": 32.0,
		"trees": [],
		"decoration": "none"
	},
	"ford_trail": {
		"id": "ford_trail",
		"title": "Le Sentier du Gué",
		"size": [
			18,
			10
		],
		"path_points": [
			[
				0,
				2
			],
			[
				3,
				2
			],
			[
				3,
				7
			],
			[
				8,
				7
			],
			[
				8,
				2
			],
			[
				13,
				2
			],
			[
				13,
				7
			],
			[
				17,
				7
			],
			[
				17,
				6
			]
		],
		"slots": [
			[
				1.5,
				4
			],
			[
				4.5,
				4.5
			],
			[
				6.5,
				5
			],
			[
				9.5,
				4.5
			],
			[
				11.5,
				5
			],
			[
				15.5,
				5
			]
		],
		"path_length": 33.0,
		"trees": [],
		"decoration": "none"
	},
	"ford_approach": {
		"id": "ford_approach",
		"title": "Les Abords du Gué",
		"size": [
			18,
			10
		],
		"path_points": [
			[
				0,
				6
			],
			[
				5,
				6
			],
			[
				5,
				2
			],
			[
				11,
				2
			],
			[
				11,
				8
			],
			[
				15,
				8
			],
			[
				15,
				4
			],
			[
				17,
				4
			],
			[
				17,
				6
			]
		],
		"slots": [
			[
				2.5,
				4.5
			],
			[
				6.5,
				4.5
			],
			[
				8.5,
				3.5
			],
			[
				9.5,
				6
			],
			[
				13,
				6
			],
			[
				16.5,
				8
			]
		],
		"path_length": 33.0,
		"trees": [],
		"decoration": "none"
	},
	"ford_ramparts": {
		"id": "ford_ramparts",
		"title": "Les Remparts du Gué",
		"size": [
			18,
			10
		],
		"path_points": [
			[
				0,
				3
			],
			[
				4,
				3
			],
			[
				4,
				8
			],
			[
				9,
				8
			],
			[
				9,
				2
			],
			[
				14,
				2
			],
			[
				14,
				7
			],
			[
				17,
				7
			],
			[
				17,
				6
			]
		],
		"slots": [
			[
				2,
				5
			],
			[
				5.5,
				5
			],
			[
				7.5,
				6
			],
			[
				10.5,
				5
			],
			[
				12.5,
				4
			],
			[
				15.5,
				5
			]
		],
		"path_length": 34.0,
		"trees": [],
		"decoration": "none"
	}
}

const VALLEY_PATH: Array[Vector2] = [
	Vector2(0,3),Vector2(4,3),Vector2(4,7),Vector2(9,7),
	Vector2(9,3),Vector2(14,3),Vector2(14,6),Vector2(17,6)
]
const VALLEY_SLOTS: Array[Vector2] = [
	Vector2(3,1.5),Vector2(2,6),Vector2(6,5),
	Vector2(8,9),Vector2(11,4.5),Vector2(15.5,4.5)
]
const VALLEY_LENGTH: float = 28.0
const VALLEY_TREES: Array[Vector2] = [Vector2(1,1),Vector2(1.4,8.5),Vector2(4.6,9),Vector2(10,1),Vector2(12,8.7),Vector2(16.8,2),Vector2(17,8.7)]

static func valley() -> Dictionary:
	return {"id":"valley_ford","title":"La Vallée du Gué","size":Vector2i(18,10),"path_points":VALLEY_PATH.duplicate(),"slots":VALLEY_SLOTS.duplicate(),"path_length":VALLEY_LENGTH,"trees":VALLEY_TREES.duplicate(),"decoration":"valley"}

static func mountain_workshop() -> Dictionary:
	var board := converging_workshop()
	board.id = "workshop_mountain"
	board.title = "Le Col des Ardoises"
	board.decoration = "mountain"
	board.route_pattern = "alternating_pressure"
	var shared: Array[Vector2] = [Vector2(7,5),Vector2(11,5),Vector2(11,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]
	var upper: Array[Vector2] = [Vector2(0,1),Vector2(7,1)]
	var lower: Array[Vector2] = [Vector2(0,8),Vector2(2,8),Vector2(2,6),Vector2(4,6),Vector2(4,9),Vector2(7,9)]
	upper.append_array(shared)
	lower.append_array(shared)
	board.path_points = upper
	board.path_length = measured_length(upper)
	board.routes = [
		{"id":"upper","path_points":upper,"path_length":board.path_length},
		{"id":"lower","path_points":lower,"path_length":measured_length(lower)},
	]
	board.slots = [Vector2(3,2.8),Vector2(1.2,5),Vector2(5.5,6.8),Vector2(9,3.2),Vector2(12.8,4.2),Vector2(15.8,7.6)]
	return board

static func converging_workshop() -> Dictionary:
	# Atelier isolé : tracé et alternance des entrées sont des propositions H.
	var upper: Array[Vector2] = [Vector2(0,2),Vector2(5,2),Vector2(5,5),Vector2(10,5),Vector2(10,2),Vector2(14,2),Vector2(14,6),Vector2(17,6)]
	var lower: Array[Vector2] = [Vector2(0,9),Vector2(3,9),Vector2(3,5),Vector2(5,5),Vector2(10,5),Vector2(10,2),Vector2(14,2),Vector2(14,6),Vector2(17,6)]
	return {"id":"workshop_confluence","title":"La Confluence — Atelier","size":Vector2i(18,10),"path_points":upper,"path_length":measured_length(upper),"slots":[Vector2(2.5,3.5),Vector2(2,7),Vector2(6.8,3.5),Vector2(8,7),Vector2(11.8,3.5),Vector2(15.5,4.5)],"trees":[],"decoration":"none","routes":[{"id":"upper","path_points":upper,"path_length":measured_length(upper)},{"id":"lower","path_points":lower,"path_length":measured_length(lower)}]}

static func for_id(id: String) -> Dictionary:
	if id == "valley_ford": return valley()
	if id == "marsh_threshold":
		var points: Array[Vector2] = [Vector2(0,2),Vector2(4,2),Vector2(4,6),Vector2(8,6),Vector2(8,3),Vector2(12,3),Vector2(12,7),Vector2(16,7),Vector2(16,6),Vector2(17,6)]
		return {"id":id,"title":"Le Seuil des Marais","size":Vector2i(18,10),"path_points":points,"path_length":measured_length(points),"slots":[Vector2(2,3.8),Vector2(5.8,3.8),Vector2(6,7.8),Vector2(9.8,4.8),Vector2(13.8,5.3),Vector2(16,8.5)],"trees":[],"decoration":"marsh"}
	if id in ["slate_crossing","slate_high_passages"]:
		var board := mountain_workshop()
		board.id = id
		board.title = "Les Trois Passages des Ardoises"
		board.erase("route_pattern")
		var shared: Array[Vector2] = [Vector2(7,5),Vector2(11,5),Vector2(11,2),Vector2(15,2),Vector2(15,6),Vector2(17,6)]
		var upper: Array[Vector2] = [Vector2(0,1),Vector2(7,1)]
		var middle: Array[Vector2] = [Vector2(0,5)]
		var lower: Array[Vector2] = [Vector2(0,9),Vector2(3,9),Vector2(3,7),Vector2(7,7)]
		if id == "slate_high_passages":
			board.title = "Les Hauts Passages des Ardoises"
			shared.assign([Vector2(9,5),Vector2(12,5),Vector2(12,2),Vector2(16,2),Vector2(16,6),Vector2(17,6)])
			upper.assign([Vector2(0,1),Vector2(5,1),Vector2(5,3),Vector2(9,3)])
			middle.assign([Vector2(0,5)])
			lower.assign([Vector2(0,9),Vector2(5,9),Vector2(5,7),Vector2(9,7)])
		upper.append_array(shared)
		middle.append_array(shared)
		lower.append_array(shared)
		board.path_points = upper
		board.path_length = measured_length(upper)
		board.routes = [
			{"id":"upper","path_points":upper,"path_length":board.path_length},
			{"id":"middle","path_points":middle,"path_length":measured_length(middle)},
			{"id":"lower","path_points":lower,"path_length":measured_length(lower)},
		]
		board.slots = [Vector2(3,2.8),Vector2(2,6.8),Vector2(6,3),Vector2(9,3.3),Vector2(12.8,4.2),Vector2(15.8,7.6)]
		if id == "slate_high_passages":
			board.slots = [Vector2(3,2.8),Vector2(3,7.2),Vector2(6.8,5.8),Vector2(10.5,3.3),Vector2(14,4.5),Vector2(16,8)]
		return board
	if id in ["slate_scree","slate_ravine","slate_gates","slate_laces","slate_cirque","slate_bastion"]:
		var board := mountain_workshop()
		board.id = id
		var upper: Array[Vector2] = []
		var lower: Array[Vector2] = []
		var shared: Array[Vector2] = []
		match id:
			"slate_bastion":
				board.title = "Le Bastion des Ardoises"
				upper.assign([Vector2(0,1),Vector2(4,1),Vector2(4,3),Vector2(8,3),Vector2(8,1),Vector2(11,1)])
				lower.assign([Vector2(0,9),Vector2(3,9),Vector2(3,6),Vector2(7,6),Vector2(7,8),Vector2(11,8)])
				shared.assign([Vector2(11,5),Vector2(14,5),Vector2(14,2),Vector2(17,2),Vector2(17,6)])
				board.slots = [Vector2(2,3),Vector2(1.5,7),Vector2(6,4.5),Vector2(10,3.2),Vector2(15.5,3.5),Vector2(15.5,7.6)]
			"slate_laces":
				board.title = "Les Lacets des Ardoises"
				board.path_points = [Vector2(0,1),Vector2(3,1),Vector2(3,7),Vector2(7,7),Vector2(7,2),Vector2(11,2),Vector2(11,8),Vector2(15,8),Vector2(15,4),Vector2(17,4),Vector2(17,6)]
				board.path_length = measured_length(board.path_points)
				board.slots = [Vector2(1.5,3.2),Vector2(5,4.5),Vector2(5,8.5),Vector2(9,4.5),Vector2(13,5),Vector2(16.5,8.5)]
				board.erase("routes")
				board.erase("route_pattern")
				return board
			"slate_cirque":
				board.title = "Le Cirque des Ardoises"
				upper.assign([Vector2(0,2),Vector2(5,2),Vector2(5,5)])
				lower.assign([Vector2(0,9),Vector2(2,9),Vector2(2,7),Vector2(9,7)])
				shared.assign([Vector2(9,5),Vector2(9,1),Vector2(14,1),Vector2(14,6),Vector2(17,6)])
				board.slots = [Vector2(2.5,3.8),Vector2(1,7),Vector2(6.8,6.2),Vector2(10.8,3),Vector2(12.2,4.5),Vector2(15.5,7.8)]
			"slate_scree":
				board.title = "Les Éboulis des Ardoises"
				upper.assign([Vector2(0,1),Vector2(5,1)])
				lower.assign([Vector2(0,9),Vector2(2,9),Vector2(2,5)])
				shared.assign([Vector2(5,5),Vector2(9,5),Vector2(9,2),Vector2(13,2),Vector2(13,7),Vector2(17,7),Vector2(17,6)])
				board.slots = [Vector2(2.5,2.8),Vector2(1,6.8),Vector2(6.8,3.3),Vector2(10.8,4),Vector2(14.8,5),Vector2(15,8.5)]
			"slate_ravine":
				board.title = "Le Ravin des Ardoises"
				board.path_points = [Vector2(0,2),Vector2(4,2),Vector2(4,8),Vector2(8,8),Vector2(8,3),Vector2(12,3),Vector2(12,7),Vector2(15,7),Vector2(15,4),Vector2(17,4),Vector2(17,6)]
				board.path_length = measured_length(board.path_points)
				board.slots = [Vector2(2,4),Vector2(6,5),Vector2(6,1.5),Vector2(10,5.2),Vector2(13.5,5),Vector2(16.5,8)]
				board.erase("routes")
				board.erase("route_pattern")
				return board
			"slate_gates":
				board.title = "Les Portes des Ardoises"
				upper.assign([Vector2(0,1),Vector2(4,1),Vector2(4,4),Vector2(8,4),Vector2(8,1),Vector2(12,1)])
				lower.assign([Vector2(0,9),Vector2(4,9),Vector2(4,6),Vector2(9,6),Vector2(9,8),Vector2(12,8)])
				shared.assign([Vector2(12,5),Vector2(15,5),Vector2(15,2),Vector2(17,2),Vector2(17,6)])
				board.slots = [Vector2(2,3),Vector2(2,7),Vector2(6,5),Vector2(10,3),Vector2(13.5,3),Vector2(15.5,7.5)]
		upper.append_array(shared)
		lower.append_array(shared)
		board.path_points = upper
		board.path_length = measured_length(upper)
		board.routes = [
			{"id":"upper","path_points":upper,"path_length":board.path_length},
			{"id":"lower","path_points":lower,"path_length":measured_length(lower)},
		]
		return board
	if id == "slate_ridges":
		var board := mountain_workshop()
		board.id = id
		board.title = "Les Crêtes des Ardoises"
		var shared: Array[Vector2] = [Vector2(9,5),Vector2(13,5),Vector2(13,2),Vector2(16,2),Vector2(16,6),Vector2(17,6)]
		var upper: Array[Vector2] = [Vector2(0,1),Vector2(5,1),Vector2(5,4),Vector2(9,4)]
		var lower: Array[Vector2] = [Vector2(0,9),Vector2(3,9),Vector2(3,7),Vector2(9,7)]
		upper.append_array(shared)
		lower.append_array(shared)
		board.path_points = upper
		board.path_length = measured_length(upper)
		board.routes = [
			{"id":"upper","path_points":upper,"path_length":board.path_length},
			{"id":"lower","path_points":lower,"path_length":measured_length(lower)},
		]
		board.slots = [Vector2(3,2.8),Vector2(1.5,7.2),Vector2(6.8,5.5),Vector2(11,3.2),Vector2(14.5,4),Vector2(16,8)]
		return board
	if id == "slate_pass":
		var board := mountain_workshop()
		board.id = id
		return board
	if CHAPTER_ONE_MAPS.has(id): return from_data(CHAPTER_ONE_MAPS[id])
	var result: Dictionary = valley()
	if id == "ford_woods":
		result.merge({"id":id,"title":"Le Bois du Gué","path_points":[Vector2(0,2),Vector2(5,2),Vector2(5,7),Vector2(11,7),Vector2(11,3),Vector2(15,3),Vector2(15,6),Vector2(17,6)],"slots":[Vector2(3,3.8),Vector2(6.5,3.7),Vector2(3.5,6),Vector2(8,5),Vector2(12.8,5.4),Vector2(15.7,4.2)],"trees":[Vector2(1,1),Vector2(2,8.5),Vector2(7,1),Vector2(9,9),Vector2(12,1),Vector2(17,2),Vector2(16,8.8)],"decoration":"none"},true)
	elif id == "ford_heights":
		result.merge({"id":id,"title":"Les Hauts du Gué","path_points":[Vector2(0,5),Vector2(3,5),Vector2(3,2),Vector2(8,2),Vector2(8,8),Vector2(13,8),Vector2(13,5),Vector2(17,5)],"slots":[Vector2(1.5,3),Vector2(4.5,3.8),Vector2(6.5,5.3),Vector2(9.5,4.7),Vector2(11,6.2),Vector2(15,6.5)],"trees":[Vector2(1,1),Vector2(1,8),Vector2(6,9),Vector2(10,1),Vector2(15,2),Vector2(17,8)],"decoration":"none"},true)
	else: return {}
	result.path_length = measured_length(result.path_points)
	return result

static func measured_length(points: Array) -> float:
	var total: float = 0.0
	for index in range(1,points.size()): total += points[index-1].distance_to(points[index])
	return total

static func validation_error(data: Dictionary) -> String:
	for key in ["id","title","size","path_points","slots","path_length","trees","decoration"]:
		if not data.has(key): return "Donnée de carte absente : "+key
	if not data.id is String or data.id.strip_edges().is_empty() or not data.title is String or data.title.strip_edges().is_empty(): return "Identité de carte invalide."
	if not data.size is Vector2i or data.size.x < 1 or data.size.y < 1 or data.size.x > 64 or data.size.y > 64: return "Dimensions de carte invalides."
	if not data.path_points is Array or (data.path_points.size() < 2 or data.path_points.size() > 512): return "Le chemin doit comporter au moins deux points."
	if not data.slots is Array or data.slots.size() != 6: return "Le prototype nécessite six emplacements."
	if not data.trees is Array or data.trees.size() > 128: return "Décor de carte invalide."
	for list in [data.path_points,data.slots,data.trees]:
		for point in list:
			if not point is Vector2 or not point.is_finite(): return "Coordonnée de carte invalide."
			if point.x < 0 or point.y < 0 or point.x > data.size.x or point.y > data.size.y: return "Coordonnée hors de la carte."
	for index in range(1,data.path_points.size()):
		if data.path_points[index] == data.path_points[index-1]: return "Segment de chemin nul."
	for index in range(data.slots.size()):
		for other in range(index):
			if data.slots[index] == data.slots[other]: return "Emplacements superposés."
	if not (data.path_length is float or data.path_length is int) or not is_finite(float(data.path_length)) or float(data.path_length) <= 0.0 or absf(float(data.path_length)-measured_length(data.path_points)) > 0.000000001: return "Longueur de chemin incohérente."
	if data.decoration not in ["valley","none","mountain","marsh"]: return "Décor de carte inconnu."
	if data.has("route_pattern"):
		if data.route_pattern != "alternating_pressure" or not data.get("routes") is Array or data.routes.size() != 2:
			return "Répartition des entrées invalide."
	if data.has("routes"):
		var error: String = Routes.common_exit_error(data.routes)
		if not error.is_empty(): return error
		if data.routes[0].path_points != data.path_points or data.routes[0].path_length != data.path_length: return "Le chemin principal doit correspondre au premier trajet."
		for route in data.routes:
			for point in route.path_points:
				if point.x < 0 or point.y < 0 or point.x > data.size.x or point.y > data.size.y: return "Trajet hors de la carte."
	return ""

static func to_data(definition: Dictionary) -> Dictionary:
	if not validation_error(definition).is_empty(): return {}
	var data: Dictionary = definition.duplicate(true)
	data.size = [definition.size.x,definition.size.y]
	for key in ["path_points","slots","trees"]:
		var coordinates: Array = []
		for point in definition[key]: coordinates.append([point.x,point.y])
		data[key] = coordinates
	if definition.has("routes"):
		for index in range(definition.routes.size()):
			var coordinates: Array = []
			for point in definition.routes[index].path_points: coordinates.append([point.x,point.y])
			data.routes[index].path_points = coordinates
	return data

static func from_data(data: Variant) -> Dictionary:
	if not data is Dictionary: return {}
	var definition: Dictionary = data.duplicate(true)
	var size_value: Variant = data.get("size")
	if not size_value is Array or size_value.size() != 2: return {}
	for value in size_value:
		if not (value is int or value is float) or not is_finite(float(value)) or value != floorf(value) or value < 1 or value > 64: return {}
	definition.size = Vector2i(int(size_value[0]),int(size_value[1]))
	for key in ["path_points","slots","trees"]:
		var coordinates: Variant = data.get(key)
		if not coordinates is Array or coordinates.size() > 512: return {}
		var points: Array[Vector2] = []
		for coordinate in coordinates:
			if not coordinate is Array or coordinate.size() != 2: return {}
			for value in coordinate:
				if not (value is int or value is float) or not is_finite(float(value)) or absf(value) > 64: return {}
			points.append(Vector2(coordinate[0],coordinate[1]))
		definition[key] = points
	if data.has("routes"):
		if not data.routes is Array or data.routes.is_empty(): return {}
		for route in definition.routes:
			if not route is Dictionary or not route.get("path_points") is Array or route.path_points.size()>512: return {}
			var points: Array[Vector2] = []
			for coordinate in route.path_points:
				if not coordinate is Array or coordinate.size()!=2: return {}
				for value in coordinate:
					if not (value is int or value is float) or not is_finite(float(value)) or absf(value)>64: return {}
				points.append(Vector2(coordinate[0],coordinate[1]))
			route.path_points = points
	return definition if validation_error(definition).is_empty() else {}
