extends RefCounted
## Illustrations originales de boutique ; aucune donnée de combat.
## Types 10 et suivants (boutique étendue) : illustration provisoire de la famille de l'unité, en attendant les visuels de Codex.
const AllianceArt = preload("res://scripts/alliance_art.gd")
const HordeArt = preload("res://scripts/horde_art.gd")
const PROVISIONAL_FROM := 10
## Types de la boutique étendue qui ont déjà leur illustration propre (validée par le porteur le 14 novembre 2026).
const OWN_ART: Array[int] = [10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]
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
	13: preload("res://assets/units/shop/bombarde_naine_v001.png"),
	14: preload("res://assets/units/shop/piquier_humain_v001.png"),
	15: preload("res://assets/units/shop/pyromancien_humain_v001.png"),
	16: preload("res://assets/units/shop/veilleur_cendres_v001.png"),
	17: preload("res://assets/units/shop/javelinier_troll_v001.png"),
	18: preload("res://assets/units/shop/lance_eclats_gobelin_v001.png"),
	19: preload("res://assets/units/shop/catapulte_gobeline_v001.png"),
	20: preload("res://assets/units/shop/lance_epieu_orc_v001.png"),
	21: preload("res://assets/units/shop/bruleur_cendres_v001.png"),
	22: preload("res://assets/units/shop/mage_foudre_humain_v001.png"),
	23: preload("res://assets/units/shop/archer_double_v001.png"),
	24: preload("res://assets/units/shop/arbalete_lourde_v001.png"),
	25: preload("res://assets/units/shop/fronde_elfe_v001.png"),
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
	13: {"source":Rect2(0,0,1313,1001),"foot":Vector2(654.0,1001),"height":58.0},
	14: {"source":Rect2(0,0,678,1398),"foot":Vector2(317.0,1398),"height":69.0},
	15: {"source":Rect2(0,0,1076,1195),"foot":Vector2(430.0,1195),"height":60.0},
	16: {"source":Rect2(0,0,1174,1029),"foot":Vector2(600.0,1029),"height":57.0},
	17: {"source":Rect2(0,0,894,1031),"foot":Vector2(347.0,1031),"height":64.0},
	18: {"source":Rect2(0,0,1026,1111),"foot":Vector2(560.0,1111),"height":53.0},
	19: {"source":Rect2(0,0,1503,1008),"foot":Vector2(758.0,1008),"height":58.0},
	20: {"source":Rect2(0,0,1424,977),"foot":Vector2(602.0,977),"height":51.0},
	21: {"source":Rect2(0,0,1176,1246),"foot":Vector2(420.0,1246),"height":58.0},
	22: {"source":Rect2(0,0,914,1278),"foot":Vector2(355.0,1278),"height":60.0},
	23: {"source":Rect2(0,0,1125,1349),"foot":Vector2(510.0,1349),"height":60.0},
	24: {"source":Rect2(0,0,1329,1119),"foot":Vector2(565.0,1119),"height":55.0},
	25: {"source":Rect2(0,0,1092,1085),"foot":Vector2(586.0,1085),"height":56.0},
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
const MUZZLES: Dictionary = {6:Vector2(30,-40),7:Vector2(43,-31),8:Vector2(-27,-41),9:Vector2(-18,-39),10:Vector2(11.0,-22.5), 11:Vector2(29.25,-32.25), 12:Vector2(40.5,-41.25), 13:Vector2(31.25,-39.25), 14:Vector2(7.0,-36.0), 15:Vector2(24.5,-47.0), 16:Vector2(-3.25,-8.0), 17:Vector2(-3.25,-25.5), 18:Vector2(-22.0,-43.0), 19:Vector2(28.75,-49.0), 20:Vector2(-14.0,-30.0), 21:Vector2(28.75,-17.5),22:Vector2(20.0,-47.5),23:AllianceArt.MUZZLES[0],24:Vector2(31.5,-19.5),25:Vector2(-12.0,-51.0),26:HordeArt.MUZZLES[3],27:HordeArt.MUZZLES[3],28:HordeArt.MUZZLES[3],29:HordeArt.MUZZLES[3],30:AllianceArt.MUZZLES[2],31:AllianceArt.MUZZLES[0],32:AllianceArt.MUZZLES[2],33:HordeArt.MUZZLES[5],34:HordeArt.MUZZLES[3],35:HordeArt.MUZZLES[3],36:AllianceArt.MUZZLES[0],37:AllianceArt.MUZZLES[1],38:AllianceArt.MUZZLES[1],39:AllianceArt.MUZZLES[2],40:AllianceArt.MUZZLES[1],41:HordeArt.MUZZLES[3],42:HordeArt.MUZZLES[4],43:HordeArt.MUZZLES[3],44:HordeArt.MUZZLES[4],45:HordeArt.MUZZLES[3]}

static func portrait(type: int) -> Texture2D:
	return PORTRAITS.get(type,TEXTURES[type])

static func destination(type: int) -> Rect2:
	var frame: Dictionary = FRAMES[type]
	var scale: float = frame.height/frame.source.size.y
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)
