extends RefCounted
## Distances dans le plan logique du GDD, avant projection isométrique.

const PATH_POINTS: Array[Vector2] = [
	Vector2(0, 3), Vector2(4, 3), Vector2(4, 7), Vector2(9, 7),
	Vector2(9, 3), Vector2(14, 3), Vector2(14, 6), Vector2(17, 6),
]
const SLOTS: Array[Vector2] = [
	Vector2(3, 1.5), Vector2(2, 6), Vector2(6, 5),
	Vector2(8, 9), Vector2(11, 4.5), Vector2(15.5, 4.5),
]
const PATH_LENGTH: float = 28.0
const INITIAL_GOLD: int = 150
const INITIAL_HP: int = 20

var gold: int = INITIAL_GOLD
var fortress_hp: int = INITIAL_HP
var distance: float = 0.0
var elapsed: float = 0.0
var active: bool = false
var arrived: bool = false

func reset() -> void:
	gold = INITIAL_GOLD
	fortress_hp = INITIAL_HP
	distance = 0.0
	elapsed = 0.0
	active = false
	arrived = false

func start() -> void:
	if not active and not arrived and fortress_hp > 0:
		active = true

func advance(seconds: float) -> void:
	if not active or seconds <= 0.0:
		return
	# Un Pillard à vitesse 1 parcourt exactement une unité par seconde.
	var remaining: float = PATH_LENGTH - distance
	var step: float = minf(seconds, remaining)
	distance += step
	elapsed += step
	if distance >= PATH_LENGTH - 0.000000001:
		distance = PATH_LENGTH
		elapsed = PATH_LENGTH
		active = false
		arrived = true
		fortress_hp = maxi(0, fortress_hp - 1)
		# Une arrivée ne donne aucune récompense et n'est résolue qu'une fois.

func enemy_position() -> Vector2:
	return position_at(distance)

static func position_at(progress: float) -> Vector2:
	var remaining: float = clampf(progress, 0.0, PATH_LENGTH)
	for index in range(PATH_POINTS.size() - 1):
		var start_point: Vector2 = PATH_POINTS[index]
		var end_point: Vector2 = PATH_POINTS[index + 1]
		var length: float = start_point.distance_to(end_point)
		if remaining <= length:
			return start_point.lerp(end_point, remaining / length)
		remaining -= length
	return PATH_POINTS[-1]
