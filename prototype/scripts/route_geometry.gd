extends RefCounted
## Géométrie des trajets. Les progressions et distances restent en float 64 bits.
## Le réseau multitrajet prépare le futur combat ; aucune mission ne l'utilise encore.
const EPS := 0.000000001

static func coverage_windows(center: Vector2, radius: float, points: Array[Vector2]) -> Array[Dictionary]:
	var windows: Array[Dictionary] = []
	var cumulative: float = 0.0
	for index in range(points.size()-1):
		var start_point: Vector2 = points[index]
		var vector: Vector2 = points[index+1]-start_point
		var length: float = vector.length()
		var direction: Vector2 = vector/length
		var offset: Vector2 = center-start_point
		var projected: float = offset.dot(direction)
		var perpendicular_squared: float = maxf(0.0,offset.length_squared()-projected*projected)
		var discriminant: float = radius*radius-perpendicular_squared
		if discriminant >= 0.0:
			var half_width: float = sqrt(discriminant)
			var first: float = maxf(0.0,projected-half_width)
			var last: float = minf(length,projected+half_width)
			if first <= last:
				var window: Dictionary = {"first":cumulative+first,"last":cumulative+last}
				if not windows.is_empty() and window.first <= windows[-1].last+EPS:
					windows[-1].last=maxf(windows[-1].last,window.last)
				else: windows.append(window)
		cumulative+=length
	return windows

static func position_components(progress: float, points: Array[Vector2], route_length: float) -> Dictionary:
	var remaining: float = clampf(progress,0.0,route_length)
	for index in range(points.size()-1):
		var a: Vector2=points[index]
		var b: Vector2=points[index+1]
		var length: float=a.distance_to(b)
		if remaining <= length:
			var ratio: float=remaining/length
			return {"x":float(a.x)+(float(b.x)-a.x)*ratio,"y":float(a.y)+(float(b.y)-a.y)*ratio}
		remaining-=length
	return {"x":float(points[-1].x),"y":float(points[-1].y)}

static func position_at(progress: float, points: Array[Vector2], route_length: float) -> Vector2:
	var point: Dictionary=position_components(progress,points,route_length)
	return Vector2(point.x,point.y)

static func separation_squared(first: float, second: float, points: Array[Vector2], route_length: float) -> float:
	return cross_separation_squared(first,points,route_length,second,points,route_length)

static func cross_separation_squared(first: float, first_points: Array[Vector2], first_length: float, second: float, second_points: Array[Vector2], second_length: float) -> float:
	# Deux progressions identiques sur deux entrées ne désignent pas le même lieu.
	# Ne pas reconvertir les composantes en Vector2 avant la comparaison de rayon.
	var a: Dictionary=position_components(first,first_points,first_length)
	var b: Dictionary=position_components(second,second_points,second_length)
	return (a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y)

static func network_error(routes: Variant) -> String:
	if not routes is Array or routes.is_empty(): return "Le réseau doit contenir au moins un trajet."
	var ids: Dictionary={}
	for route in routes:
		if not route is Dictionary: return "Trajet invalide."
		var id: Variant=route.get("id")
		if not id is String or id.strip_edges().is_empty() or id != id.strip_edges(): return "Identifiant de trajet invalide."
		if ids.has(id): return "Identifiant de trajet répété."
		ids[id]=true
		var points: Variant=route.get("path_points")
		if not points is Array or points.size()<2 or points.size()>512: return "Points de trajet invalides."
		var measured: float=0.0
		for index in range(points.size()):
			if not points[index] is Vector2 or not points[index].is_finite(): return "Coordonnée de trajet invalide."
			if index==0: continue
			if points[index]==points[index-1]: return "Segment de trajet nul."
			measured+=points[index-1].distance_to(points[index])
		var length: Variant=route.get("path_length")
		if not (length is int or length is float) or not is_finite(float(length)) or float(length)<=0.0 or absf(float(length)-measured)>EPS: return "Longueur de trajet incohérente."
	return ""

static func common_exit_error(routes: Variant) -> String:
	var error: String=network_error(routes)
	if not error.is_empty(): return error
	var exit_point: Vector2=routes[0].path_points[-1]
	for route in routes:
		if route.path_points[-1]!=exit_point: return "Les trajets doivent rejoindre la même forteresse."
	return ""

# Validate the map geometry independently of fortress HP and defeat rules.
static func destinations_error(routes: Variant, destinations: Dictionary) -> String:
	var error := network_error(routes)
	if not error.is_empty():
		return error
	if destinations.is_empty():
		return "Le reseau doit definir au moins une destination."
	var positions := {}
	for id in destinations:
		if not id is String or id.is_empty() or id != id.strip_edges():
			return "Identifiant de destination invalide."
		var position: Variant = destinations[id]
		if not position is Vector2 or not position.is_finite() or positions.has(position):
			return "Position de destination invalide ou repetee."
		positions[position] = id
	var used := {}
	for route in routes:
		var id: Variant = route.get("destination_id")
		if not id is String or not destinations.has(id):
			return "Destination de trajet inconnue."
		if route.path_points[-1] != destinations[id]:
			return "La sortie du trajet ne rejoint pas sa destination."
		used[id] = true
	if used.size() != destinations.size():
		return "Une destination ne possede aucun trajet."
	return ""

static func network_copy(routes: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary]=[]
	if not network_error(routes).is_empty(): return result
	for route in routes: result.append(route.duplicate(true))
	return result

static func route_for(routes: Array[Dictionary], id: String) -> Dictionary:
	if not network_error(routes).is_empty(): return {}
	for route in routes:
		if route.id==id: return route.duplicate(true)
	# Ne jamais diriger silencieusement un ennemi inconnu vers le premier chemin.
	return {}

static func network_coverage(center: Vector2, radius: float, routes: Array[Dictionary]) -> Dictionary:
	var result: Dictionary={}
	if not center.is_finite() or not is_finite(radius) or radius<0.0 or not network_error(routes).is_empty(): return result
	for route in routes:
		var points: Array[Vector2]=[];points.assign(route.path_points)
		result[route.id]=coverage_windows(center,radius,points)
	return result
