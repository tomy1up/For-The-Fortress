extends RefCounted
## Illustrations originales de boutique ; aucune donnée de combat.
const TEXTURES: Dictionary = {
	6: preload("res://assets/units/shop/rodeur_v001.png"),
	7: preload("res://assets/units/shop/mousquetaire_v002.png"),
	8: preload("res://assets/units/shop/traqueur_v001.png"),
	9: preload("res://assets/units/shop/grenadier_v001.png"),
}
const FRAMES: Dictionary = {
	6: {"source":Rect2(53,20,1159,1231),"foot":Vector2(622.0,1251),"height":66.0},
	7: {"source":Rect2(157,20,1293,984),"foot":Vector2(598.5,1004),"height":50.0},
	8: {"source":Rect2(57,42,1297,1066),"foot":Vector2(590.5,1108),"height":60.0},
	9: {"source":Rect2(62,52,1194,1102),"foot":Vector2(637.5,1154),"height":48.0},
}
const MUZZLES: Dictionary = {6:Vector2(30,-40),7:Vector2(43,-31),8:Vector2(-27,-41),9:Vector2(-18,-39)}

static func destination(type: int) -> Rect2:
	var frame: Dictionary = FRAMES[type]
	var scale: float = frame.height/frame.source.size.y
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)
