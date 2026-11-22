extends RefCounted
## Habillage vectoriel du prototype. Aucun accès au modèle de combat.
const POOLS: Array[Rect2] = [Rect2(0.5,4.7,2.8,3.8),Rect2(5,0.5,4.8,1.6),Rect2(9,7.8,5.4,1.7),Rect2(13.3,1,3.9,2.4)]
const GROUND := Color("40594d")
const DecorArt = preload("res://scripts/decor_art.gd")
## Habillage dessiné par Codex pour les missions 41 à 50 (lots 5ae3c06 et 65638f3, validés par le porteur le 22 novembre 2026) :
## un calque de bassins par carte, en coordonnées d'écran du plateau, à la place des bassins vectoriels, et quatre pièces
## (saule, roseaux, arche, mur effondré) dans les cadres de `bounds`. Les autres cartes des marais gardent le dessin vectoriel.
const POOL_LAYERS := {
	"marsh_threshold":["marais/bassins_marsh_threshold.png",Rect2(441,243,656,255)],
	"marsh_basins":["marais/bassins_marsh_basins.png",Rect2(511,186,475,309)],
	"marsh_court":["marais/bassins_marsh_court.png",Rect2(481,247,629,234)],
	"marsh_channels":["marais/bassins_marsh_channels.png",Rect2(519,237,599,241)],
	"marsh_cloister":["marais/bassins_marsh_cloister.png",Rect2(567,186,541,311)],
	"marsh_causeway":["marais/bassins_marsh_causeway.png",Rect2(430,186,675,259)],
	"marsh_fords":["marais/bassins_marsh_fords.png",Rect2(524,244,594,255)],
	"marsh_islets":["marais/bassins_marsh_islets.png",Rect2(551,262,570,273)],
	"marsh_nave":["marais/bassins_marsh_nave.png",Rect2(414,275,518,61)],
	"marsh_sanctuary":["marais/bassins_marsh_sanctuary.png",Rect2(554,200,570,299)]}
const PROP_FILES := {"ruin":"marais/ruin.png","ruin_fallen":"marais/ruin_fallen.png","willow":"marais/willow.png","reeds":"marais/reeds.png"}

## Calque de bassins de la carte : {"texture", "area"} ou {} (bassins vectoriels).
static func pool_layer(map_id: String) -> Dictionary:
	if not POOL_LAYERS.has(map_id): return {}
	var texture: Texture2D = DecorArt.texture(str(POOL_LAYERS[map_id][0]))
	return {"texture":texture,"area":POOL_LAYERS[map_id][1]} if texture != null else {}

## Pièce dessinée d'un objet de décor : l'arche au Cloître submergé, le mur effondré à la Nef, sinon l'un ou l'autre selon la parité de l'ordre de placement.
static func prop_key(map_id: String, kind: String, order: int) -> String:
	if kind != "ruin" or map_id == "marsh_cloister": return kind
	return "ruin_fallen" if map_id == "marsh_nave" or order%2 == 0 else "ruin"

static func prop_texture(map_id: String, kind: String, order: int) -> Texture2D:
	if not POOL_LAYERS.has(map_id): return null
	return DecorArt.texture(str(PROP_FILES.get(prop_key(map_id,kind,order),"")))
const ROAD := Color("b8b69c")

static func draw_ground(canvas: CanvasItem, projection: Callable, miniature: bool = false, pools: Array = POOLS) -> void:
	for pool: Rect2 in pools:
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
