extends RefCounted
## Assets individuels issus de la planche cartoon validée. Aucune donnée de combat.
const TEXTURES: Dictionary = {
	3: preload("res://assets/units/horde/troll_v001.png"),
	4: preload("res://assets/units/horde/gobelin_v001.png"),
	5: preload("res://assets/units/horde/chaman_v001.png"),
}
# Cadres opaques avec marge de 2 px ; ancrage horizontal mesuré sur les pieds.
const FRAMES: Dictionary = {
	3: {"source":Rect2(144,15,1016,1172),"foot":Vector2(647.355,1187),"height":66.0},
	4: {"source":Rect2(119,76,1190,1032),"foot":Vector2(682.016,1108),"height":48.0},
	5: {"source":Rect2(158,24,1042,1187),"foot":Vector2(655.470,1211),"height":66.0},
}
const MUZZLES: Dictionary = {3:Vector2(-18,-37),4:Vector2(34,-27),5:Vector2(22,-47)}

static func destination(type: int) -> Rect2:
	var frame: Dictionary = FRAMES[type]
	var scale: float = frame.height/frame.source.size.y
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)
