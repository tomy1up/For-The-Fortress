extends RefCounted
## Illustrations originales de boutique ; aucune donnée de combat.
## Types 10 et suivants (boutique étendue) : illustration provisoire de la famille de l'unité, en attendant les visuels de Codex.
const AllianceArt = preload("res://scripts/alliance_art.gd")
const HordeArt = preload("res://scripts/horde_art.gd")
const PROVISIONAL_FROM := 10
## Types de la boutique étendue qui ont déjà leur illustration propre (validée par le porteur le 14 novembre 2026).
const OWN_ART: Array[int] = [10,11,12,16,17]
## Portrait de boutique, quand il diffère du sprite posé sur le plateau (la sentinelle porte sa longue-vue à deux mains en boutique).
const PORTRAITS: Dictionary = {
	10: preload("res://assets/units/shop/sentinelle_elfe_guet_v001.png"),
	16: preload("res://assets/units/shop/veilleur_cendres_guet_v001.png"),
}
const TEXTURES: Dictionary = {
	6: preload("res://assets/units/shop/rodeur_v001.png"),
	7: preload("res://assets/units/shop/mousquetaire_v002.png"),
	8: preload("res://assets/units/shop/traqueur_v001.png"),
	9: preload("res://assets/units/shop/grenadier_v001.png"),
	10: preload("res://assets/units/shop/sentinelle_elfe_v001.png"),
	11: preload("res://assets/units/shop/tireur_elite_elfe_v001.png"),
	12: preload("res://assets/units/shop/arquebusier_nain_v001.png"),
	13: AllianceArt.TEXTURES[2],
	14: AllianceArt.TEXTURES[0],
	15: AllianceArt.TEXTURES[2],
	16: preload("res://assets/units/shop/veilleur_cendres_v001.png"),
	17: preload("res://assets/units/shop/javelinier_troll_v001.png"),
	18: HordeArt.TEXTURES[3],
	19: HordeArt.TEXTURES[4],
	20: HordeArt.TEXTURES[3],
	21: HordeArt.TEXTURES[5],
	22: AllianceArt.TEXTURES[2],
	23: AllianceArt.TEXTURES[0],
	24: AllianceArt.TEXTURES[1],
	25: AllianceArt.TEXTURES[0],
	26: HordeArt.TEXTURES[3],
	27: HordeArt.TEXTURES[3],
	28: HordeArt.TEXTURES[3],
	29: HordeArt.TEXTURES[3],
	36: AllianceArt.TEXTURES[0],
	37: AllianceArt.TEXTURES[1],
	38: AllianceArt.TEXTURES[1],
	39: AllianceArt.TEXTURES[2],
	40: AllianceArt.TEXTURES[1],
	41: HordeArt.TEXTURES[3],
	42: HordeArt.TEXTURES[4],
	43: HordeArt.TEXTURES[3],
	44: HordeArt.TEXTURES[4],
	45: HordeArt.TEXTURES[3],
	30: AllianceArt.TEXTURES[2],
	31: AllianceArt.TEXTURES[0],
	32: AllianceArt.TEXTURES[2],
	33: HordeArt.TEXTURES[5],
	34: HordeArt.TEXTURES[3],
	35: HordeArt.TEXTURES[3],
}
const FRAMES: Dictionary = {
	6: {"source":Rect2(53,20,1159,1231),"foot":Vector2(622.0,1251),"height":66.0},
	7: {"source":Rect2(157,20,1293,984),"foot":Vector2(598.5,1004),"height":50.0},
	8: {"source":Rect2(57,42,1297,1066),"foot":Vector2(590.5,1108),"height":60.0},
	9: {"source":Rect2(62,52,1194,1102),"foot":Vector2(637.5,1154),"height":48.0},
	10: {"source":Rect2(0,0,543,871),"foot":Vector2(232.0,871),"height":59.0},
	11: {"source":Rect2(0,0,1284,1110),"foot":Vector2(445.0,1110),"height":56.0},
	12: {"source":Rect2(0,0,1209,999),"foot":Vector2(440.0,999),"height":55.0},
	13: AllianceArt.FRAMES[2],
	14: AllianceArt.FRAMES[0],
	15: AllianceArt.FRAMES[2],
	16: {"source":Rect2(0,0,1174,1029),"foot":Vector2(600.0,1029),"height":57.0},
	17: {"source":Rect2(0,0,894,1031),"foot":Vector2(347.0,1031),"height":64.0},
	18: HordeArt.FRAMES[3],
	19: HordeArt.FRAMES[4],
	20: HordeArt.FRAMES[3],
	21: HordeArt.FRAMES[5],
	22: AllianceArt.FRAMES[2],
	23: AllianceArt.FRAMES[0],
	24: AllianceArt.FRAMES[1],
	25: AllianceArt.FRAMES[0],
	26: HordeArt.FRAMES[3],
	27: HordeArt.FRAMES[3],
	28: HordeArt.FRAMES[3],
	29: HordeArt.FRAMES[3],
	36: AllianceArt.FRAMES[0],
	37: AllianceArt.FRAMES[1],
	38: AllianceArt.FRAMES[1],
	39: AllianceArt.FRAMES[2],
	40: AllianceArt.FRAMES[1],
	41: HordeArt.FRAMES[3],
	42: HordeArt.FRAMES[4],
	43: HordeArt.FRAMES[3],
	44: HordeArt.FRAMES[4],
	45: HordeArt.FRAMES[3],
	30: AllianceArt.FRAMES[2],
	31: AllianceArt.FRAMES[0],
	32: AllianceArt.FRAMES[2],
	33: HordeArt.FRAMES[5],
	34: HordeArt.FRAMES[3],
	35: HordeArt.FRAMES[3],
}
const MUZZLES: Dictionary = {6:Vector2(30,-40),7:Vector2(43,-31),8:Vector2(-27,-41),9:Vector2(-18,-39),10:Vector2(11.0,-22.5), 11:Vector2(29.25,-32.25), 12:Vector2(40.5,-41.25), 13:AllianceArt.MUZZLES[2], 14:AllianceArt.MUZZLES[0], 15:AllianceArt.MUZZLES[2], 16:Vector2(-3.25,-8.0), 17:Vector2(-3.25,-25.5), 18:HordeArt.MUZZLES[3], 19:HordeArt.MUZZLES[4], 20:HordeArt.MUZZLES[3], 21:HordeArt.MUZZLES[5],22:AllianceArt.MUZZLES[2],23:AllianceArt.MUZZLES[0],24:AllianceArt.MUZZLES[1],25:AllianceArt.MUZZLES[0],26:HordeArt.MUZZLES[3],27:HordeArt.MUZZLES[3],28:HordeArt.MUZZLES[3],29:HordeArt.MUZZLES[3],30:AllianceArt.MUZZLES[2],31:AllianceArt.MUZZLES[0],32:AllianceArt.MUZZLES[2],33:HordeArt.MUZZLES[5],34:HordeArt.MUZZLES[3],35:HordeArt.MUZZLES[3],36:AllianceArt.MUZZLES[0],37:AllianceArt.MUZZLES[1],38:AllianceArt.MUZZLES[1],39:AllianceArt.MUZZLES[2],40:AllianceArt.MUZZLES[1],41:HordeArt.MUZZLES[3],42:HordeArt.MUZZLES[4],43:HordeArt.MUZZLES[3],44:HordeArt.MUZZLES[4],45:HordeArt.MUZZLES[3]}

static func portrait(type: int) -> Texture2D:
	return PORTRAITS.get(type,TEXTURES[type])

static func destination(type: int) -> Rect2:
	var frame: Dictionary = FRAMES[type]
	var scale: float = frame.height/frame.source.size.y
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)
