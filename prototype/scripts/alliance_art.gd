extends RefCounted
## Silhouettes Alliance dans le style cartoon validé. Aucune donnée de combat.
const TEXTURES: Dictionary = {
	0: preload("res://assets/units/alliance/archer_v001.png"),
	1: preload("res://assets/units/alliance/arbaletrier_v001.png"),
	2: preload("res://assets/units/alliance/mage_v001.png"),
}
# Cadres visibles (alpha > 8/255) avec marge de 2 px ; ancrage sur les pieds.
const FRAMES: Dictionary = {
	0: {"source":Rect2(109,22,1123,1195),"foot":Vector2(578.258,1217),"height":66.0},
	1: {"source":Rect2(92,112,1148,1075),"foot":Vector2(605.141,1187),"height":56.0},
	2: {"source":Rect2(64,47,1191,1119),"foot":Vector2(630.923,1166),"height":66.0},
}
# La fleche se detache a la hauteur de la poignee de l'arc.
const MUZZLES: Dictionary = {0:Vector2(26,-34),1:Vector2(32,-26),2:Vector2(31,-54)}

static func destination(type: int) -> Rect2:
	var frame: Dictionary = FRAMES[type]
	var scale: float = frame.height/frame.source.size.y
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)
