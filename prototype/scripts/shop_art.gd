extends RefCounted
## Illustrations originales de boutique ; aucune donnée de combat.
## Types 10 et suivants (boutique étendue) : illustration provisoire de la famille de l'unité, en attendant les visuels de Codex.
const AllianceArt = preload("res://scripts/alliance_art.gd")
const HordeArt = preload("res://scripts/horde_art.gd")
const PROVISIONAL_FROM := 10
## Types de la boutique étendue qui ont déjà leur illustration propre (validée par le porteur le 14 novembre 2026).
const OWN_ART: Array[int] = [10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46]
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
	26: preload("res://assets/units/shop/hache_en_chaine_v001.png"),
	27: preload("res://assets/units/shop/lanceur_double_troll_v001.png"),
	28: preload("res://assets/units/shop/lanceur_masse_orc_v001.png"),
	29: preload("res://assets/units/shop/sarbacane_gobeline_v001.png"),
	36: preload("res://assets/units/shop/marchand_mercenaire_v001.png"),
	37: preload("res://assets/units/shop/piegeur_nain_v001.png"),
	38: preload("res://assets/units/shop/balliste_royale_v001.png"),
	39: preload("res://assets/units/shop/alchimiste_gnome_v001.png"),
	40: preload("res://assets/units/shop/veteran_royal_v001.png"),
	41: preload("res://assets/units/shop/pillard_gobelin_v001.png"),
	42: preload("res://assets/units/shop/poseur_mines_v001.png"),
	43: preload("res://assets/units/shop/baliste_guerre_v001.png"),
	44: preload("res://assets/units/shop/gobelin_kamikaze_v001.png"),
	45: preload("res://assets/units/shop/chef_guerre_veteran_v001.png"),
	46: preload("res://assets/units/shop/fantassin_squelette_v001.png"),
	47: AllianceArt.TEXTURES[0], # Provisoire : tirailleur gnome.
	30: preload("res://assets/units/shop/mage_givre_v001.png"),
	31: preload("res://assets/units/shop/eclaireur_observateur_v001.png"),
	32: preload("res://assets/units/shop/pretre_guerrier_v001.png"),
	33: preload("res://assets/units/shop/chaman_marais_v001.png"),
	34: preload("res://assets/units/shop/totem_guerre_v001.png"),
	35: preload("res://assets/units/shop/ancien_tribus_v001.png"),
}
const FRAMES: Dictionary = {
	6: {"source":Rect2(53,20,1159,1231),"foot":Vector2(622.0,1251),"height":66.0},
	7: {"source":Rect2(157,20,1293,984),"foot":Vector2(598.5,1004),"height":50.0},
	8: {"source":Rect2(57,42,1297,1066),"foot":Vector2(590.5,1108),"height":61.0},
	9: {"source":Rect2(62,52,1194,1102),"foot":Vector2(637.5,1154),"height":53.0},
	10: {"source":Rect2(0,0,543,871),"foot":Vector2(232.0,871),"height":64.0},
	11: {"source":Rect2(0,0,1284,1110),"foot":Vector2(445.0,1110),"height":58.0},
	12: {"source":Rect2(0,0,1209,999),"foot":Vector2(440.0,999),"height":57.0},
	13: {"source":Rect2(0,0,1313,1001),"foot":Vector2(654.0,1001),"height":58.0},
	14: {"source":Rect2(0,0,678,1398),"foot":Vector2(317.0,1398),"height":69.0},
	15: {"source":Rect2(0,0,1076,1195),"foot":Vector2(430.0,1195),"height":66.0},
	16: {"source":Rect2(0,0,1174,1029),"foot":Vector2(600.0,1029),"height":64.0},
	17: {"source":Rect2(0,0,894,1031),"foot":Vector2(347.0,1031),"height":66.0},
	18: {"source":Rect2(0,0,1026,1111),"foot":Vector2(560.0,1111),"height":58.0},
	19: {"source":Rect2(0,0,1503,1008),"foot":Vector2(758.0,1008),"height":58.0},
	20: {"source":Rect2(0,0,1424,977),"foot":Vector2(602.0,977),"height":52.0},
	21: {"source":Rect2(0,0,1176,1246),"foot":Vector2(420.0,1246),"height":64.0},
	22: {"source":Rect2(0,0,914,1278),"foot":Vector2(355.0,1278),"height":66.0},
	23: {"source":Rect2(0,0,1125,1349),"foot":Vector2(510.0,1349),"height":65.0},
	24: {"source":Rect2(0,0,1329,1119),"foot":Vector2(565.0,1119),"height":61.0},
	25: {"source":Rect2(0,0,1092,1085),"foot":Vector2(586.0,1085),"height":62.0},
	26: {"source":Rect2(0,0,1182,1205),"foot":Vector2(462.0,1205),"height":63.0},
	27: {"source":Rect2(0,0,905,1128),"foot":Vector2(462.0,1128),"height":63.0},
	28: {"source":Rect2(0,0,1233,1030),"foot":Vector2(580.0,1030),"height":66.0},
	29: {"source":Rect2(0,0,1303,1014),"foot":Vector2(480.0,1014),"height":54.0},
	36: {"source":Rect2(0,0,857,1006),"foot":Vector2(446.0,1006),"height":61.0},
	37: {"source":Rect2(0,0,1051,936),"foot":Vector2(452.0,936),"height":58.0},
	38: {"source":Rect2(0,0,1429,875),"foot":Vector2(729.0,875),"height":51.0},
	39: {"source":Rect2(0,0,1188,1257),"foot":Vector2(511.0,1257),"height":58.0},
	40: {"source":Rect2(0,0,1022,1496),"foot":Vector2(460.0,1496),"height":66.0},
	41: {"source":Rect2(0,0,1256,919),"foot":Vector2(565.0,919),"height":58.0},
	42: {"source":Rect2(0,0,1101,1001),"foot":Vector2(473.0,1001),"height":59.0},
	43: {"source":Rect2(0,0,1583,820),"foot":Vector2(791.0,820),"height":44.0},
	44: {"source":Rect2(0,0,1115,1113),"foot":Vector2(401.0,1113),"height":58.0},
	45: {"source":Rect2(0,0,925,1149),"foot":Vector2(520.0,1149),"height":66.0},
	46: {"source":Rect2(0,0,1290,1116),"foot":Vector2(470.0,1116),"height":59.0},
	47: AllianceArt.FRAMES[0],
	30: {"source":Rect2(0,0,957,1197),"foot":Vector2(287.0,1197),"height":64.0},
	31: {"source":Rect2(0,0,1293,1072),"foot":Vector2(556.0,1072),"height":59.0},
	32: {"source":Rect2(0,0,965,1452),"foot":Vector2(492.0,1452),"height":64.0},
	33: {"source":Rect2(0,0,1096,1246),"foot":Vector2(482.0,1246),"height":64.0},
	34: {"source":Rect2(0,0,675,1282),"foot":Vector2(317.0,1282),"height":62.0},
	35: {"source":Rect2(0,0,952,1175),"foot":Vector2(447.0,1175),"height":64.0},
}
const MUZZLES: Dictionary = {6:Vector2(30,-40),7:Vector2(43,-31),8:Vector2(-27.5,-41.75),9:Vector2(-20.0,-43.0),10:Vector2(12.0,-24.5), 11:Vector2(30.25,-33.5), 12:Vector2(42.0,-42.75), 13:Vector2(31.25,-39.25), 14:Vector2(7.0,-36.0), 15:Vector2(27.0,-51.75), 16:Vector2(-3.75,-9.0), 17:Vector2(-3.25,-26.25), 18:Vector2(-24.0,-47.0), 19:Vector2(28.75,-49.0), 20:Vector2(-14.25,-30.5), 21:Vector2(31.75,-19.25),22:Vector2(22.0,-52.25),23:AllianceArt.MUZZLES[0],24:Vector2(35.0,-21.75),25:Vector2(-13.25,-56.5),26:Vector2(22.75,-19.5),27:Vector2(20.0,-41.0),28:Vector2(-18.5,-56.75),29:Vector2(43.25,-31.5),30:Vector2(33.0,-51.25),31:AllianceArt.MUZZLES[0],32:Vector2(-15.5,-50.75),33:Vector2(25.5,-58.0),34:Vector2(0.0,-51.5),35:Vector2(16.5,-32.0),36:Vector2(17.75,-48.75),37:Vector2(27.25,-24.0),38:Vector2(40.0,-31.0),39:Vector2(28.5,-35.0),40:Vector2(23.0,-38.75),41:Vector2(35.0,-41.5),42:Vector2(30.0,-26.25),43:Vector2(41.25,-27.5),44:Vector2(30.75,-43.75),45:Vector2(-25.5,-46.25),46:Vector2(38.0,-35.0),47:AllianceArt.MUZZLES[0]}

static func portrait(type: int) -> Texture2D:
	return PORTRAITS.get(type,TEXTURES[type])

static func destination(type: int) -> Rect2:
	var frame: Dictionary = FRAMES[type]
	var scale: float = frame.height/frame.source.size.y
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)
