extends RefCounted
## Premier cycle dessiné : loup neutre. Aucun état de simulation n'est modifié.
const WOLF_ID := "enemy.neutral.wolf"
const TEXTURE = preload("res://assets/enemies/animations/loup_marche_v001.png")
const STRIDE := 0.9 # Unités logiques parcourues pour un cycle ; réglage visuel H.
const SCALE := 34.0/278.0 # Échelle commune : aucune normalisation par pose.
const BOUNDS := Rect2(-26,-35,52,36)
const FRAMES := [
	Rect2(17,137,397,279), Rect2(449,136,409,285),
	Rect2(893,137,408,279), Rect2(1337,135,412,286),
	Rect2(15,540,410,281), Rect2(451,538,418,278),
	Rect2(896,540,416,281), Rect2(1342,539,406,283),
]

static func supports(id: String) -> bool:
	return id == WOLF_ID

static func frame_index(distance: float, enemy_id: int = 0) -> int:
	# Lier le cycle à la distance évite de marcher sur place à l'arrêt.
	# Le décalage déterministe désynchronise les animaux d'une même meute.
	var cycle: float = maxf(0.0,distance)/STRIDE+maxi(0,enemy_id)*0.137
	return int(floor(fposmod(cycle,1.0)*FRAMES.size()))%FRAMES.size()

static func destination(frame: int) -> Rect2:
	var source: Rect2 = FRAMES[clampi(frame,0,FRAMES.size()-1)]
	# Chaque cadre inclut quatre pixels de marge autour de la silhouette.
	return Rect2(Vector2(-source.size.x/2.0,-source.size.y+4.0)*SCALE,source.size*SCALE)
