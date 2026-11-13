extends RefCounted
## Illustrations originales de boutique ; aucune donnée de combat.
## Types 10 et suivants (boutique étendue) : illustration provisoire de la famille de l'unité, en attendant les visuels de Codex.
const AllianceArt = preload("res://scripts/alliance_art.gd")
const HordeArt = preload("res://scripts/horde_art.gd")
const PROVISIONAL_FROM := 10
const TEXTURES: Dictionary = {
	6: preload("res://assets/units/shop/rodeur_v001.png"),
	7: preload("res://assets/units/shop/mousquetaire_v002.png"),
	8: preload("res://assets/units/shop/traqueur_v001.png"),
	9: preload("res://assets/units/shop/grenadier_v001.png"),
	10: AllianceArt.TEXTURES[0],
	11: AllianceArt.TEXTURES[1],
	12: AllianceArt.TEXTURES[0],
	13: AllianceArt.TEXTURES[2],
	14: AllianceArt.TEXTURES[0],
	15: AllianceArt.TEXTURES[2],
	16: HordeArt.TEXTURES[3],
	17: HordeArt.TEXTURES[3],
	18: HordeArt.TEXTURES[3],
	19: HordeArt.TEXTURES[4],
	20: HordeArt.TEXTURES[3],
	21: HordeArt.TEXTURES[5],
}
const FRAMES: Dictionary = {
	6: {"source":Rect2(53,20,1159,1231),"foot":Vector2(622.0,1251),"height":66.0},
	7: {"source":Rect2(157,20,1293,984),"foot":Vector2(598.5,1004),"height":50.0},
	8: {"source":Rect2(57,42,1297,1066),"foot":Vector2(590.5,1108),"height":60.0},
	9: {"source":Rect2(62,52,1194,1102),"foot":Vector2(637.5,1154),"height":48.0},
	10: AllianceArt.FRAMES[0],
	11: AllianceArt.FRAMES[1],
	12: AllianceArt.FRAMES[0],
	13: AllianceArt.FRAMES[2],
	14: AllianceArt.FRAMES[0],
	15: AllianceArt.FRAMES[2],
	16: HordeArt.FRAMES[3],
	17: HordeArt.FRAMES[3],
	18: HordeArt.FRAMES[3],
	19: HordeArt.FRAMES[4],
	20: HordeArt.FRAMES[3],
	21: HordeArt.FRAMES[5],
}
const MUZZLES: Dictionary = {6:Vector2(30,-40),7:Vector2(43,-31),8:Vector2(-27,-41),9:Vector2(-18,-39),10:AllianceArt.MUZZLES[0], 11:AllianceArt.MUZZLES[1], 12:AllianceArt.MUZZLES[0], 13:AllianceArt.MUZZLES[2], 14:AllianceArt.MUZZLES[0], 15:AllianceArt.MUZZLES[2], 16:HordeArt.MUZZLES[3], 17:HordeArt.MUZZLES[3], 18:HordeArt.MUZZLES[3], 19:HordeArt.MUZZLES[4], 20:HordeArt.MUZZLES[3], 21:HordeArt.MUZZLES[5]}

static func destination(type: int) -> Rect2:
	var frame: Dictionary = FRAMES[type]
	var scale: float = frame.height/frame.source.size.y
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)
