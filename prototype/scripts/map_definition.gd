extends RefCounted
## Données géométriques. La seule carte de production reste La Vallée du Gué.
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
	if data.decoration not in ["valley","none"]: return "Décor de carte inconnu."
	return ""

static func to_data(definition: Dictionary) -> Dictionary:
	if not validation_error(definition).is_empty(): return {}
	var data: Dictionary = definition.duplicate(true)
	data.size = [definition.size.x,definition.size.y]
	for key in ["path_points","slots","trees"]:
		var coordinates: Array = []
		for point in definition[key]: coordinates.append([point.x,point.y])
		data[key] = coordinates
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
	return definition if validation_error(definition).is_empty() else {}
