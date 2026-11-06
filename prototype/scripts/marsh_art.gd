extends RefCounted
## Habillage vectoriel du prototype. Aucun accès au modèle de combat.
const POOLS: Array[Rect2] = [Rect2(0.5,4.7,2.8,3.8),Rect2(5,0.5,4.8,1.6),Rect2(9,7.8,5.4,1.7),Rect2(13.3,1,3.9,2.4)]
const GROUND := Color("40594d")
const ROAD := Color("b8b69c")

static func draw_ground(canvas: CanvasItem, projection: Callable, miniature: bool = false) -> void:
	for pool in POOLS:
		var points := PackedVector2Array()
		for point in [pool.position,Vector2(pool.end.x,pool.position.y),pool.end,Vector2(pool.position.x,pool.end.y)]: points.append(projection.call(point))
		canvas.draw_colored_polygon(points,Color("244b4b"))
		points.append(points[0]);canvas.draw_polyline(points,Color("6b8a71"),0.8 if miniature else 1.5,true)
		for index in range(3):
			var start: Vector2 = projection.call(pool.position+Vector2(pool.size.x*0.2,pool.size.y*(0.25+index*0.23)))
			var finish: Vector2 = projection.call(pool.position+Vector2(pool.size.x*0.75,pool.size.y*(0.25+index*0.23)))
			canvas.draw_line(start,finish,Color("3d6a61"),0.6 if miniature else 1.2,true)

static func draw_joints(canvas: CanvasItem, projection: Callable, paths: Array) -> void:
	for path in paths:
		for index in range(1,path.size()):
			var first: Vector2 = projection.call(path[index-1])
			var last: Vector2 = projection.call(path[index])
			var side := (last-first).normalized().orthogonal()*8.5
			var count: int = floori(path[index-1].distance_to(path[index]))
			for step in range(1,count):
				var center: Vector2 = first.lerp(last,float(step)/count)
				canvas.draw_line(center-side,center+side,Color("8a9680"),1.0,true)

static func bounds(center: Vector2, kind: String) -> Rect2:
	if kind=="willow": return Rect2(center+Vector2(-16,-46),Vector2(32,60))
	if kind=="ruin": return Rect2(center+Vector2(-13,-30),Vector2(26,38))
	return Rect2(center+Vector2(-13,-19),Vector2(26,27))

static func draw_detail(canvas: CanvasItem, center: Vector2, kind: String) -> void:
	if kind=="ruin":
		canvas.draw_colored_polygon(PackedVector2Array([center+Vector2(-12,1),center+Vector2(0,-5),center+Vector2(12,1),center+Vector2(0,7)]),Color("718371"))
		canvas.draw_colored_polygon(PackedVector2Array([center+Vector2(-7,-4),center+Vector2(-7,-25),center+Vector2(-1,-29),center+Vector2(7,-25),center+Vector2(7,-4),center+Vector2(0,0)]),Color("a5b29a"))
		canvas.draw_colored_polygon(PackedVector2Array([center+Vector2(0,-22),center+Vector2(7,-25),center+Vector2(7,-4),center]),Color("718671"))
		canvas.draw_line(center+Vector2(-6,-15),center+Vector2(0,-12),Color("556e58"),1.5,true)
		canvas.draw_line(center+Vector2(-2,-27),center+Vector2(0,-22),Color("526552"),1.5,true)
		canvas.draw_line(center+Vector2(-8,-1),center+Vector2(6,3),Color("4c6e4e"),3,true)
	elif kind=="willow":
		canvas.draw_line(center+Vector2(0,4),center+Vector2(0,-29),Color("5c6350"),5,true)
		canvas.draw_colored_polygon(PackedVector2Array([center+Vector2(-14,-21),center+Vector2(-11,-34),center+Vector2(-3,-43),center+Vector2(8,-39),center+Vector2(15,-29),center+Vector2(12,-17),center+Vector2(5,-23),center+Vector2(-4,-19)]),Color("426447"))
		canvas.draw_colored_polygon(PackedVector2Array([center+Vector2(-11,-31),center+Vector2(-3,-43),center+Vector2(8,-39),center+Vector2(10,-33),center+Vector2(2,-30)]),Color("668057"))
		for x in [-10,-5,6,12]: canvas.draw_line(center+Vector2(x,-29),center+Vector2(x-1,-12),Color("58764d"),2,true)
	else:
		canvas.draw_line(center+Vector2(-11,4),center+Vector2(10,4),Color("314e3c"),4,true)
		for x in [-8,-3,3,8]:
			var top := center+Vector2(x-2,-17+absi(x)/2.0)
			canvas.draw_line(center+Vector2(x,3),top,Color("83a16b"),1.5,true)
			canvas.draw_line(top,top+Vector2(1,5),Color("bca36d"),2.5,true)
