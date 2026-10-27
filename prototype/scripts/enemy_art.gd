extends RefCounted
## Premier lot illustré : profils 0, 1 et 2. Aucune caractéristique de combat.
const TEXTURES: Dictionary = {
	0: preload("res://assets/enemies/grouillant_v001.png"),
	1: preload("res://assets/enemies/pillard_v001.png"),
	2: preload("res://assets/enemies/sprinter_v001.png"),
}
# Zone visible alpha > 8/255, marge de 2 px. Hauteur avant l’échelle du profil.
const FRAMES: Dictionary = {
	0: {"source":Rect2(234,53,1079,1036),"foot":Vector2(669.064,1089),"height":34.0},
	1: {"source":Rect2(127,101,1112,1037),"foot":Vector2(682.084,1138),"height":34.0},
	2: {"source":Rect2(110,131,1204,936),"foot":Vector2(814.833,1067),"height":34.0},
}

static func destination(type: int) -> Rect2:
	var frame: Dictionary = FRAMES[type]
	var scale: float = frame.height/frame.source.size.y
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)

static func tint(hit_strength: float) -> Color:
	var brightness: float = 1.0+clampf(hit_strength,0.0,1.0)*0.55
	return Color(brightness,brightness,brightness,1.0)
