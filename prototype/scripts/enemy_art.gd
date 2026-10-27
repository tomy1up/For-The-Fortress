extends RefCounted
## Treize silhouettes dans trois atlas transparents, sans données de combat.
const TEXTURES: Dictionary = {
	"enemy.neutral.wolf": preload("res://assets/enemies/rosters/neutres_v001.png"),
	"enemy.neutral.boar": preload("res://assets/enemies/rosters/neutres_v001.png"),
	"enemy.neutral.bear": preload("res://assets/enemies/rosters/neutres_v001.png"),
	"enemy.alliance.infantry": preload("res://assets/enemies/rosters/alliance_v002.png"),
	"enemy.alliance.scout": preload("res://assets/enemies/rosters/alliance_v002.png"),
	"enemy.alliance.siegebreaker": preload("res://assets/enemies/rosters/alliance_v002.png"),
	"enemy.alliance.guard": preload("res://assets/enemies/rosters/alliance_v002.png"),
	"enemy.alliance.marshal": preload("res://assets/enemies/rosters/alliance_v002.png"),
	"enemy.horde.warrior": preload("res://assets/enemies/rosters/horde_v002.png"),
	"enemy.horde.scout": preload("res://assets/enemies/rosters/horde_v002.png"),
	"enemy.horde.colossus": preload("res://assets/enemies/rosters/horde_v002.png"),
	"enemy.horde.guard": preload("res://assets/enemies/rosters/horde_v002.png"),
	"enemy.horde.warchief": preload("res://assets/enemies/rosters/horde_v002.png"),
}
const FRAMES: Dictionary = {
	"enemy.neutral.wolf": {"source":Rect2(27,208,633,437),"foot":Vector2(354.164,645),"height":34.0},
	"enemy.neutral.boar": {"source":Rect2(742,198,618,452),"foot":Vector2(1026.745,650),"height":34.0},
	"enemy.neutral.bear": {"source":Rect2(1412,100,741,553),"foot":Vector2(1758.409,653),"height":34.0},
	"enemy.alliance.infantry": {"source":Rect2(64,314,246,308),"foot":Vector2(176.077,622),"height":34.0},
	"enemy.alliance.scout": {"source":Rect2(492,316,283,305),"foot":Vector2(607.628,621),"height":34.0},
	"enemy.alliance.siegebreaker": {"source":Rect2(904,304,312,317),"foot":Vector2(1059.396,621),"height":34.0},
	"enemy.alliance.guard": {"source":Rect2(1355,225,298,398),"foot":Vector2(1497.032,623),"height":34.0},
	"enemy.alliance.marshal": {"source":Rect2(1776,165,356,463),"foot":Vector2(1947.885,628),"height":34.0},
	"enemy.horde.warrior": {"source":Rect2(52,278,295,315),"foot":Vector2(193.146,593),"height":34.0},
	"enemy.horde.scout": {"source":Rect2(514,343,251,247),"foot":Vector2(629.202,590),"height":34.0},
	"enemy.horde.colossus": {"source":Rect2(873,207,358,386),"foot":Vector2(1048.133,593),"height":34.0},
	"enemy.horde.guard": {"source":Rect2(1351,283,288,309),"foot":Vector2(1478.705,592),"height":34.0},
	"enemy.horde.warchief": {"source":Rect2(1714,186,407,407),"foot":Vector2(1912.146,593),"height":34.0},
}

static func destination(id: String) -> Rect2:
	var frame: Dictionary = FRAMES[id]
	var scale: float = frame.height/frame.source.size.y
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)

static func tint(hit_strength: float) -> Color:
	var brightness: float = 1.0+clampf(hit_strength,0.0,1.0)*0.55
	return Color(brightness,brightness,brightness,1.0)
