extends RefCounted
## Illustrations originales ; aucun état de combat ni générateur aléatoire.
const BUILDINGS: Array = [preload("res://assets/fortresses/forteresse_alliance_v001.png"),preload("res://assets/fortresses/forteresse_horde_v001.png")]
const KINGS: Array = [preload("res://assets/fortresses/roi_alliance_v001.png"),preload("res://assets/fortresses/roi_horde_v001.png")]
## Calques de dégâts (lot c81b52a de Codex, validé par le porteur le 22 novembre 2026) : un par faction et par état (endommagée, en danger,
## détruite), au cadre de la région `SOURCES` de l'illustration, posés sur le bâtiment avec sa luminosité, sous la fumée et le roi.
const DAMAGE: Array = [
	[preload("res://assets/fortresses/degats_alliance_1.png"),preload("res://assets/fortresses/degats_alliance_2.png"),preload("res://assets/fortresses/degats_alliance_3.png")],
	[preload("res://assets/fortresses/degats_horde_1.png"),preload("res://assets/fortresses/degats_horde_2.png"),preload("res://assets/fortresses/degats_horde_3.png")]]
static func damage_overlay(faction: int, condition: int) -> Texture2D:
	return DAMAGE[side(faction)][condition-1] if condition >= 1 and condition <= 3 else null
const SOURCES: Array = [Rect2(103,86,1115,1054),Rect2(57,53,1213,1128)]
const ROOFS: Array[Vector2] = [Vector2(700,320),Vector2(700,325)]
const KING_HEIGHT := 33.0
const KING_REFERENCE: Array[float] = [593.0,597.0]
const KING_FRAMES: Array = [
	[
		{"source":Rect2(29,86,481,593),"foot":Vector2(242.334,679)},
		{"source":Rect2(586,85,499,595),"foot":Vector2(836.419,680)},
		{"source":Rect2(1130,134,455,538),"foot":Vector2(1382.472,672)},
		{"source":Rect2(1741,141,413,538),"foot":Vector2(1937.537,679)},
	],
	[
		{"source":Rect2(24,80,535,597),"foot":Vector2(250.189,677)},
		{"source":Rect2(581,81,552,596),"foot":Vector2(854.667,677)},
		{"source":Rect2(1144,129,491,544),"foot":Vector2(1410.172,673)},
		{"source":Rect2(1699,142,465,534),"foot":Vector2(1929.777,676)},
	],
 ]

static func side(faction: int) -> int: return 1 if faction == 1 else 0

static func building_rect(faction: int) -> Rect2:
	var source: Rect2 = SOURCES[side(faction)]
	var height: float = 92.0*source.size.y/source.size.x
	return Rect2(-46,14-height,92,height)

static func king_anchor(faction: int) -> Vector2:
	var index: int = side(faction)
	var source: Rect2 = SOURCES[index]
	return building_rect(index).position+(ROOFS[index]-source.position)*(92.0/source.size.x)

static func king_rect(faction: int, pose: int) -> Rect2:
	var index: int = side(faction)
	var frame: Dictionary = KING_FRAMES[index][clampi(pose,0,3)]
	var scale: float = KING_HEIGHT/KING_REFERENCE[index]
	return Rect2((frame.source.position-frame.foot)*scale,frame.source.size*scale)

static func king_pose(hp: int, hurt_age: float, rally_age: float) -> int:
	if hurt_age >= 0.0 and hurt_age < 0.65: return 2
	if hp <= 0: return 3
	return 1 if rally_age >= 0.0 and rally_age < 1.1 else 0

static func shake(age: float) -> Vector2:
	if age < 0.0 or age >= 0.35: return Vector2.ZERO
	return Vector2(sin(age*55)*2.0*(1.0-age/0.35),0)

static func king_transform(pose: int, phase: float, hurt_age: float) -> Transform2D:
	if pose == 3: return Transform2D.IDENTITY
	if pose == 2:
		var pulse: float = sin(clampf(hurt_age/0.65,0,1)*PI)
		return Transform2D(-0.045*pulse,Vector2.ONE,0.0,Vector2(-1.5*pulse,0))
	return Transform2D(sin(phase*2)*0.012,Vector2.ONE,0.0,Vector2(0,-0.35*sin(phase*2)))
