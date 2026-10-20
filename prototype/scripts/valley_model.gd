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

const WAVE_COUNT: int = 10
const SPAWN_INTERVAL: float = 2.5
const EPS: float = 0.000000001
const ROSTER: Array[Dictionary] = [
	{"name": "Archer elfe", "price": 50, "damage": 8.0, "interval": 1.0, "range": 4.0},
	{"name": "Arbalétrier nain", "price": 75, "damage": 24.0, "interval": 2.5, "range": 5.0},
	{"name": "Mage humain", "price": 100, "damage": 27.0, "interval": 2.5, "range": 3.5},
]

var gold: int = INITIAL_GOLD
var fortress_hp: int = INITIAL_HP
var elapsed: float = 0.0
var phase: String = "preparation"
var active: bool:
	get:
		return phase == "combat"
var spawned: int = 0
var killed: int = 0
var escaped: int = 0
var enemies: Array[Dictionary] = []
var defenders: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var event_log: Array[String] = []

func _init() -> void:
	reset()

func reset() -> void:
	gold = INITIAL_GOLD
	fortress_hp = INITIAL_HP
	elapsed = 0.0
	phase = "preparation"
	spawned = 0
	killed = 0
	escaped = 0
	enemies.clear()
	shots.clear()
	event_log.clear()
	defenders.clear()
	for index in range(SLOTS.size()):
		defenders.append({})

func can_build() -> bool:
	return phase == "preparation" or phase == "finished"

func count_type(type: int) -> int:
	var count: int = 0
	for defender in defenders:
		if not defender.is_empty() and defender.type == type:
			count += 1
	return count

func purchase_error(slot: int, type: int) -> String:
	if not can_build():
		return "Achats possibles uniquement entre les vagues."
	if slot < 0 or slot >= SLOTS.size():
		return "Sélectionnez un emplacement."
	if type < 0 or type >= ROSTER.size():
		return "Défenseur inconnu."
	if not defenders[slot].is_empty():
		return "Cet emplacement est occupé."
	if count_type(type) >= 2:
		return "Deux exemplaires de ce type sont déjà déployés."
	if gold < ROSTER[type].price:
		return "Or insuffisant."
	return ""

func buy(slot: int, type: int) -> bool:
	if not purchase_error(slot, type).is_empty():
		return false
	var stats: Dictionary = ROSTER[type]
	defenders[slot] = {"type": type, "paid": stats.price, "ready_at": 0.0,
		"windows": coverage_windows(SLOTS[slot], stats.range)}
	gold -= stats.price
	return true

func refund(slot: int) -> int:
	if slot < 0 or slot >= defenders.size() or defenders[slot].is_empty():
		return 0
	return int(floor(defenders[slot].paid * 70.0 / 100.0))

func sell(slot: int) -> bool:
	if not can_build() or refund(slot) <= 0:
		return false
	gold += refund(slot)
	defenders[slot] = {}
	return true

func start() -> bool:
	if phase != "preparation":
		return false
	phase = "combat"
	for defender in defenders:
		if not defender.is_empty():
			defender.ready_at = 0.0
	_resolve_instant()
	return true

func advance(seconds: float) -> void:
	if not active or seconds <= 0.0 or not is_finite(seconds):
		return
	var target_time: float = elapsed + seconds
	# Résoudre les événements à leur instant exact, même si un écran saute une image.
	while active:
		var next_time: float = _next_event_time()
		if next_time > target_time + EPS:
			elapsed = target_time
			_update_positions()
			return
		elapsed = maxf(elapsed, next_time)
		_resolve_instant()

func _next_event_time() -> float:
	var next_time: float = INF
	if spawned < WAVE_COUNT:
		next_time = spawned * SPAWN_INTERVAL
	for enemy in enemies:
		next_time = minf(next_time, enemy.spawn_time + PATH_LENGTH)
	for defender in defenders:
		if defender.is_empty():
			continue
		for enemy in enemies:
			for window in defender.windows:
				var first: float = maxf(defender.ready_at, enemy.spawn_time + window.first)
				var last: float = enemy.spawn_time + window.last
				if first > elapsed + EPS and first <= last + EPS:
					next_time = minf(next_time, first)
	return next_time

func _update_positions() -> void:
	for enemy in enemies:
		enemy.distance = clampf(elapsed - enemy.spawn_time, 0.0, PATH_LENGTH)

func _resolve_instant() -> void:
	# 1. Apparitions et déplacement ; les arrivants restent ciblables jusqu'aux tirs.
	while spawned < WAVE_COUNT and spawned * SPAWN_INTERVAL <= elapsed + EPS:
		enemies.append({"id": spawned, "spawn_time": spawned * SPAWN_INTERVAL,
			"distance": 0.0, "hp": 40.0})
		spawned += 1
	_update_positions()
	# Pas de malédiction dans ce lot Alliance N1. Tous les tirs partagent cet état.
	var damage: Dictionary = {}
	for slot in range(defenders.size()):
		var defender: Dictionary = defenders[slot]
		if defender.is_empty() or defender.ready_at > elapsed + EPS:
			continue
		var stats: Dictionary = ROSTER[defender.type]
		var targets: Array[Dictionary] = []
		for enemy in enemies:
			for window in defender.windows:
				if enemy.distance >= window.first - EPS and enemy.distance <= window.last + EPS:
					targets.append(enemy)
					break
		if targets.is_empty():
			continue
		targets.sort_custom(_progress_priority)
		var primary: Dictionary = targets[0]
		var impact: Vector2 = position_at(primary.distance)
		_add_damage(damage, primary.id, stats.damage)
		shots.append({"time": elapsed, "slot": slot, "type": defender.type,
			"target_id": primary.id, "from": SLOTS[slot], "to": impact})
		event_log.append("%.9f tir E%d cible %d" % [elapsed, slot + 1, primary.id])
		if defender.type == 2:
			var secondary: Array[Dictionary] = []
			for enemy in enemies:
				var squared: float = impact.distance_squared_to(position_at(enemy.distance))
				if enemy.id != primary.id and squared < 1.0:
					secondary.append({"enemy": enemy, "squared": squared})
			secondary.sort_custom(_secondary_priority)
			for index in range(mini(2, secondary.size())):
				_add_damage(damage, secondary[index].enemy.id, 10.8)
		defender.ready_at = elapsed + stats.interval
	# 3. Additionner les impacts avant de retirer les morts et créditer une seule prime.
	var survivors: Array[Dictionary] = []
	for enemy in enemies:
		enemy.hp -= damage.get(enemy.id, 0.0)
		if enemy.hp <= 0.0:
			killed += 1
			gold += 3
			event_log.append("%.9f mort %d +3" % [elapsed, enemy.id])
		else:
			survivors.append(enemy)
	enemies = survivors
	# 4. Les survivants arrivés infligent leurs dégâts sans récompense.
	survivors = []
	var arrival_damage: int = 0
	for enemy in enemies:
		if enemy.distance >= PATH_LENGTH - EPS:
			escaped += 1
			arrival_damage += 1
			event_log.append("%.9f arrivee %d -1PV" % [elapsed, enemy.id])
		else:
			survivors.append(enemy)
	enemies = survivors
	fortress_hp = maxi(0, fortress_hp - arrival_damage)
	# 5. Défaite prioritaire ; finir cette vague n'est pas gagner la partie complète.
	if fortress_hp == 0:
		phase = "defeat"
	elif spawned == WAVE_COUNT and enemies.is_empty():
		phase = "finished"

static func _add_damage(damage: Dictionary, id: int, amount: float) -> void:
	damage[id] = damage.get(id, 0.0) + amount

static func _progress_priority(a: Dictionary, b: Dictionary) -> bool:
	if a.distance != b.distance:
		return a.distance > b.distance
	return a.id < b.id

static func _secondary_priority(a: Dictionary, b: Dictionary) -> bool:
	if a.squared != b.squared:
		return a.squared < b.squared
	return _progress_priority(a.enemy, b.enemy)

static func coverage_windows(center: Vector2, radius: float) -> Array[Dictionary]:
	# Les bornes restent des float 64 bits ; Vector2 réduirait leur précision.
	var windows: Array[Dictionary] = []
	var cumulative: float = 0.0
	for index in range(PATH_POINTS.size() - 1):
		var start_point: Vector2 = PATH_POINTS[index]
		var vector: Vector2 = PATH_POINTS[index + 1] - start_point
		var length: float = vector.length()
		var direction: Vector2 = vector / length
		var offset: Vector2 = center - start_point
		var projected: float = offset.dot(direction)
		var perpendicular_squared: float = maxf(0.0, offset.length_squared() - projected * projected)
		var discriminant: float = radius * radius - perpendicular_squared
		if discriminant >= 0.0:
			var half_width: float = sqrt(discriminant)
			var first: float = maxf(0.0, projected - half_width)
			var last: float = minf(length, projected + half_width)
			if first <= last:
				var window: Dictionary = {"first": cumulative + first, "last": cumulative + last}
				if not windows.is_empty() and window.first <= windows[-1].last + EPS:
					windows[-1].last = maxf(windows[-1].last, window.last)
				else:
					windows.append(window)
		cumulative += length
	return windows

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
