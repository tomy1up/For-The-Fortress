extends RefCounted
## Silhouettes dans quatre atlas transparents, sans données de combat.
## Capitaine de garnison humain (face à la Horde) : visuel de Codex (v0.176). Le capitaine orc réutilise provisoirement la silhouette du chef de guerre.
## Gueule-de-Vase (ex-Noyé) : visuel de Codex (v0.176). Les cadres sont rognés au pied (quelques pixels transparents) et la hauteur ajustée pour garder l'échelle du cadre complet (34 px).
const TEXTURES: Dictionary = {
	"enemy.neutral.turtle": preload("res://assets/enemies/rosters/tortue_gardienne_v001.png"),
	"enemy.neutral.drowned": preload("res://assets/enemies/rosters/gueule_de_vase_v001.png"),
	"enemy.neutral.wolf": preload("res://assets/enemies/rosters/neutres_v001.png"),
	"enemy.neutral.boar": preload("res://assets/enemies/rosters/neutres_v001.png"),
	"enemy.neutral.bear": preload("res://assets/enemies/rosters/neutres_v001.png"),
	"enemy.alliance.infantry": preload("res://assets/enemies/rosters/alliance_v002.png"),
	"enemy.alliance.scout": preload("res://assets/enemies/rosters/alliance_v002.png"),
	"enemy.alliance.siegebreaker": preload("res://assets/enemies/rosters/alliance_v002.png"),
	"enemy.alliance.guard": preload("res://assets/enemies/rosters/alliance_v002.png"),
	"enemy.alliance.marshal": preload("res://assets/enemies/rosters/alliance_v002.png"),
	"enemy.alliance.garrison": preload("res://assets/enemies/rosters/capitaine_humain_v001.png"),
	"enemy.horde.warrior": preload("res://assets/enemies/rosters/horde_v003.png"),
	"enemy.horde.scout": preload("res://assets/enemies/rosters/horde_v003.png"),
	"enemy.horde.colossus": preload("res://assets/enemies/rosters/horde_v003.png"),
	"enemy.horde.guard": preload("res://assets/enemies/rosters/horde_v003.png"),
	"enemy.horde.warchief": preload("res://assets/enemies/rosters/horde_v003.png"),
	"enemy.horde.garrison": preload("res://assets/enemies/rosters/horde_v003.png"),
}
const FRAMES: Dictionary = {
	"enemy.neutral.turtle": {"source":Rect2(90,265,1075,732),"foot":Vector2(650,997),"height":34.0},
	"enemy.neutral.drowned": {"source":Rect2(0,0,1000,1076),"foot":Vector2(415,1076),"height":33.84},
	"enemy.neutral.wolf": {"source":Rect2(27,208,633,437),"foot":Vector2(354.164,645),"height":34.0},
	"enemy.neutral.boar": {"source":Rect2(742,198,618,452),"foot":Vector2(1026.745,650),"height":34.0},
	"enemy.neutral.bear": {"source":Rect2(1412,100,741,553),"foot":Vector2(1758.409,653),"height":34.0},
	"enemy.alliance.infantry": {"source":Rect2(64,314,246,308),"foot":Vector2(176.077,622),"height":34.0},
	"enemy.alliance.scout": {"source":Rect2(492,316,283,305),"foot":Vector2(607.628,621),"height":34.0},
	"enemy.alliance.siegebreaker": {"source":Rect2(904,304,312,317),"foot":Vector2(1059.396,621),"height":34.0},
	"enemy.alliance.guard": {"source":Rect2(1355,225,298,398),"foot":Vector2(1497.032,623),"height":34.0},
	"enemy.alliance.marshal": {"source":Rect2(1776,165,356,463),"foot":Vector2(1947.885,628),"height":34.0},
	"enemy.alliance.garrison": {"source":Rect2(0,0,1295,1173),"foot":Vector2(478,1173),"height":33.83},
	"enemy.horde.warrior": {"source":Rect2(51,275,302,324),"foot":Vector2(195.647,599),"height":34.0},
	"enemy.horde.scout": {"source":Rect2(495,342,261,256),"foot":Vector2(614.592,598),"height":34.0},
	"enemy.horde.colossus": {"source":Rect2(866,200,370,399),"foot":Vector2(1045.418,599),"height":34.0},
	"enemy.horde.guard": {"source":Rect2(1349,282,295,316),"foot":Vector2(1478.468,598),"height":34.0},
	"enemy.horde.warchief": {"source":Rect2(1716,182,416,417),"foot":Vector2(1920.095,599),"height":34.0},
	"enemy.horde.garrison": {"source":Rect2(1716,182,416,417),"foot":Vector2(1920.095,599),"height":34.0},
}

static func destination(id: String) -> Rect2:
	var frame: Dictionary = FRAMES[id]
	var scale: float = frame.height/frame.source.size.y
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)

static func tint(hit_strength: float) -> Color:
	var brightness: float = 1.0+clampf(hit_strength,0.0,1.0)*0.55
	return Color(brightness,brightness,brightness,1.0)
