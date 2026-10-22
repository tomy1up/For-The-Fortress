extends Node2D

const Model = preload("res://scripts/valley_model.gd")
const ORIGIN := Vector2(658, 174)
const AXIS := Vector2(27, 13.5)
const INK := Color("d9e4d7")
const SLOT_FILL := Color("213e3b")
var model: RefCounted
var selected: int = -1
var font: Font = ThemeDB.fallback_font

static func project(point: Vector2) -> Vector2:
	return ORIGIN + Vector2((point.x - point.y) * AXIS.x, (point.x + point.y) * AXIS.y)

func polygon(points: Array[Vector2], color: Color) -> void:
	var projected := PackedVector2Array()
	for point in points:
		projected.append(project(point))
	draw_colored_polygon(projected, color)

func _draw() -> void:
	var corners: Array[Vector2] = [Vector2.ZERO, Vector2(18, 0), Vector2(18, 10), Vector2(0, 10)]
	var base := PackedVector2Array()
	for corner in corners:
		base.append(project(corner) + Vector2(0, 16))
	draw_colored_polygon(base, Color("172c2b"))
	polygon(corners, Color("354b3c"))
	for x in range(19):
		draw_line(project(Vector2(x, 0)), project(Vector2(x, 10)), Color(0.75, 0.86, 0.7, 0.055), 1)
	for y in range(11):
		draw_line(project(Vector2(0, y)), project(Vector2(18, y)), Color(0.75, 0.86, 0.7, 0.055), 1)
	# La rivière et le pont sont des éléments visuels, sans collision.
	polygon([Vector2(6, 0), Vector2(7, 0), Vector2(7, 10), Vector2(6, 10)], Color("396968"))
	for y in range(10):
		draw_line(project(Vector2(6.2, y + 0.2)), project(Vector2(6.75, y + 0.65)), Color("5b8b80"), 1.5)
	var route := PackedVector2Array()
	for point in Model.PATH_POINTS:
		route.append(project(point))
	draw_polyline(route, Color("26372e"), 28, true)
	draw_polyline(route, Color("b3a17b"), 20, true)
	for point in route:
		draw_circle(point, 10, Color("b3a17b"))
	draw_polyline(route, Color("c7b58d"), 2, true)
	polygon([Vector2(5.8, 6.55), Vector2(7.2, 6.55), Vector2(7.2, 7.45), Vector2(5.8, 7.45)], Color("77654c"))
	for plank in range(8):
		var x: float = 5.85 + plank * 0.18
		draw_line(project(Vector2(x, 6.6)), project(Vector2(x, 7.4)), Color("b29a6b"), 2)
	for tree in [Vector2(1, 1), Vector2(1.4, 8.5), Vector2(4.6, 9), Vector2(10, 1), Vector2(12, 8.7), Vector2(16.8, 2), Vector2(17, 8.7)]:
		_draw_tree(project(tree))
	if model != null and selected >= 0 and not model.defenders[selected].is_empty():
		var stats: Dictionary = model.get_stats(selected)
		var ring := PackedVector2Array()
		for step in range(65):
			var angle: float = TAU * step / 64.0
			ring.append(project(Model.SLOTS[selected] + Vector2(cos(angle), sin(angle)) * stats.range))
		draw_colored_polygon(ring, Color(0.8, 0.85, 0.5, 0.05))
		draw_polyline(ring, Color(0.8, 0.85, 0.5, 0.35), 1.5, true)
		# Montrer uniquement les partenaires actifs du défenseur sélectionné.
		for rule in Model.Campaign.PROXIMITY + Model.Campaign.SPECIALISATIONS:
			var specialised: bool = rule.has("branches")
			var offset := Vector2(0, 4 if specialised else 0)
			var link_color := Color("8cbde0") if specialised else Color("e1bb70")
			for partner_slot in model.synergy_partners(selected, rule):
				var start: Vector2 = project(Model.SLOTS[selected]) + offset
				var finish: Vector2 = project(Model.SLOTS[partner_slot]) + offset
				draw_line(start, finish, Color(link_color, 0.65), 2, true)
				draw_circle(finish, 5, link_color, false, 2, true)
	for index in range(Model.SLOTS.size()):
		var center: Vector2 = project(Model.SLOTS[index])
		var diamond := PackedVector2Array([center + Vector2(-26, 0), center + Vector2(0, -13), center + Vector2(26, 0), center + Vector2(0, 13)])
		draw_colored_polygon(diamond, SLOT_FILL)
		draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color("ddbd78") if selected == index else Color("779b89"), 2, true)
		var occupied: bool = model != null and not model.defenders[index].is_empty()
		draw_string(font, center + Vector2(-9, 22 if occupied else 5), "E%d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, INK)
	_draw_fortress(project(Vector2(17, 6)))
	var entrance: Vector2 = project(Model.PATH_POINTS[0])
	draw_circle(entrance, 5, Color("debd7f"))
	draw_string(font, entrance + Vector2(-48, -20), "ENTRÉE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("a7b8aa"))
	if model != null:
		var actors: Array[Dictionary] = []
		for slot in range(model.defenders.size()):
			if not model.defenders[slot].is_empty():
				actors.append({"point": project(Model.SLOTS[slot]), "defender": model.defenders[slot]})
		for enemy in model.enemies:
			actors.append({"point": project(Model.position_at(enemy.distance)), "enemy": enemy})
		actors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.point.y < b.point.y)
		for actor in actors:
			if actor.has("defender"):
				_draw_defender(actor.point, actor.defender.type, actor.defender.get("level", 1), actor.defender.get("branch", -1))
			else:
				_draw_pillager(actor.point, actor.enemy)
				var ratio: float = clampf(actor.enemy.hp / actor.enemy.get("max_hp", 40.0), 0.0, 1.0)
				var bar_position: Vector2 = actor.point + Vector2(-12, -36 * _enemy_scale(actor.enemy))
				draw_rect(Rect2(bar_position, Vector2(24, 4)), Color("472f2a"))
				draw_rect(Rect2(bar_position, Vector2(24 * ratio, 4)), Color("a1ba75"))
		if model.active:
			for shot in model.shots:
				if model.elapsed - shot.time <= 0.18:
					var color: Color = {2: Color("9cc4e4"), 3: Color("a1d6ab"), 4: Color("e3a56d"), 5: Color("cfa4e3")}.get(shot.type, Color("e8ce92"))
					draw_line(project(shot.from) + Vector2(0, -17), project(shot.to) + Vector2(0, -12), color, 2, true)
					var last_point: Vector2 = shot.to
					for secondary_point in shot.get("secondary", []):
						draw_line(project(last_point) + Vector2(0, -12), project(secondary_point) + Vector2(0, -12), color, 1.5, true)
						if shot.type == 3:
							last_point = secondary_point
					if shot.type in [2, 4]:
						draw_arc(project(shot.to), 20 * shot.get("radius", 1.0), 0, TAU, 24, Color(0.5, 0.7, 0.9, 0.7), 2, true)

func _draw_defender(center: Vector2, type: int, level: int = 1, branch: int = -1) -> void:
	var color: Color = [Color("6f9c6b"), Color("b79a64"), Color("668db5"), Color("72a392"), Color("b8a16a"), Color("a782b7")][type]
	draw_circle(center + Vector2(0, 3), 9, Color(0, 0, 0, 0.25))
	draw_rect(Rect2(center + Vector2(-6, -17), Vector2(12, 19)), color)
	draw_circle(center + Vector2(0, -23), 6, Color("e4d0a5"))
	match type:
		0:
			draw_arc(center + Vector2(6, -14), 9, -PI / 2, PI / 2, 12, Color("e0c99e"), 2, true)
			draw_line(center + Vector2(6, -23), center + Vector2(6, -5), Color("e0c99e"), 1)
			draw_colored_polygon(PackedVector2Array([center + Vector2(-8, -25), center + Vector2(1, -34), center + Vector2(8, -25)]), color)
		1:
			draw_line(center + Vector2(-10, -15), center + Vector2(10, -15), Color("eee0b7"), 3)
			draw_line(center + Vector2(0, -20), center + Vector2(0, -7), Color("463e33"), 3)
			draw_line(center + Vector2(-6, -26), center + Vector2(6, -26), Color("c3c8b7"), 4)
		2:
			draw_colored_polygon(PackedVector2Array([center + Vector2(-9, -26), center + Vector2(0, -40), center + Vector2(9, -26)]), color)
			draw_line(center + Vector2(11, -28), center + Vector2(11, 1), Color("c7b080"), 2)
			draw_circle(center + Vector2(11, -30), 4, Color("abcdeb"))

		3:
			draw_line(center + Vector2(8, -25), center + Vector2(8, -3), Color("d2c295"), 2)
			draw_colored_polygon(PackedVector2Array([center + Vector2(8, -27), center + Vector2(19, -22), center + Vector2(8, -15)]), Color("b8d1c1"))
			draw_line(center + Vector2(-6, -22), center + Vector2(-10, -15), Color("e0d8b8"), 2)
		4:
			draw_circle(center + Vector2(10, -10), 7, Color("6c7043"))
			draw_line(center + Vector2(10, -17), center + Vector2(12, -23), Color("e0c578"), 2)
			draw_line(center + Vector2(-7, -26), center + Vector2(7, -26), Color("a4bc85"), 4)
		5:
			draw_line(center + Vector2(11, -29), center + Vector2(11, 1), Color("c7b080"), 2)
			draw_circle(center + Vector2(11, -31), 5, Color("dabbe6"))
			draw_line(center + Vector2(-6, -27), center + Vector2(-11, -32), Color("d6c59b"), 3)
			draw_line(center + Vector2(6, -27), center + Vector2(11, -32), Color("d6c59b"), 3)

	if level > 1:
		var badge: Vector2 = center + Vector2(14, 4)
		draw_circle(badge, 11 if level == 4 else 9, Color("7b6c41") if level == 4 else Color("304d42"))
		var badge_text: String = str(level) + ("A" if branch == 0 else "B") if level == 4 else str(level)
		draw_string(font, badge + Vector2(-7 if level == 4 else -3, 4), badge_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("efe0b8"))

func _draw_tree(center: Vector2) -> void:
	draw_circle(center + Vector2(0, 3), 10, Color(0, 0, 0, 0.1))
	draw_line(center, center + Vector2(0, -22), Color("80755a"), 3)
	draw_colored_polygon(PackedVector2Array([center + Vector2(-13, -8), center + Vector2(0, -38), center + Vector2(13, -8)]), Color("244237"))
	draw_line(center + Vector2(0, -37), center + Vector2(10, -10), Color("4b6750"), 2)

func _draw_fortress(anchor: Vector2) -> void:
	# Décaler le bâtiment dans sa cour pour laisser le repère E6 visible.
	# Le point d'arrivée logique demeure H (17 ; 6).
	var center: Vector2 = anchor + Vector2(52, 26)
	draw_colored_polygon(PackedVector2Array([anchor + Vector2(-12, 0), anchor + Vector2(36, -5), center + Vector2(37, 0), center + Vector2(0, 21)]), Color("576650"))
	draw_colored_polygon(PackedVector2Array([center + Vector2(-31, -8), center + Vector2(0, -23), center + Vector2(31, -8), center + Vector2(0, 9)]), Color("64766a"))
	for offset in [-23, 23]:
		var tower: Vector2 = center + Vector2(offset, -8)
		draw_rect(Rect2(tower + Vector2(-9, -39), Vector2(18, 39)), Color("a9b5a4"))
		draw_rect(Rect2(tower + Vector2(1, -39), Vector2(8, 39)), Color("7e9285"))
		draw_colored_polygon(PackedVector2Array([tower + Vector2(-13, -39), tower + Vector2(0, -57), tower + Vector2(13, -39)]), Color("315b68"))
	draw_rect(Rect2(center + Vector2(-17, -34), Vector2(34, 29)), Color("8b9e8e"))
	draw_rect(Rect2(center + Vector2(-6, -24), Vector2(12, 19)), Color("233c36"))
	draw_line(center + Vector2(0, -36), center + Vector2(0, -68), Color("d0bc8c"), 2)
	draw_colored_polygon(PackedVector2Array([center + Vector2(1, -68), center + Vector2(20, -62), center + Vector2(1, -55)]), Color("d3b676"))
	draw_string(font, center + Vector2(-42, 32), "FORTERESSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, INK)

func _enemy_scale(enemy: Dictionary) -> float:
	return [0.7, 1.0, 0.85, 1.2, 1.0, 1.5, 1.3, 1.7][enemy.get("type", 1)]

func _draw_pillager(center: Vector2, enemy: Dictionary) -> void:
	var type: int = enemy.get("type", 1)
	var armor: Color = [Color("789263"), Color("b45f4c"), Color("c6a16a"), Color("9e6659"), Color("967556"), Color("838e85"), Color("9777a6"), Color("aca384")][type]
	draw_set_transform(center, 0.0, Vector2.ONE * _enemy_scale(enemy))
	center = Vector2.ZERO
	for curse in model.curses:
		if curse.enemy_id == enemy.id:
			draw_arc(center + Vector2(0, -13), 19, 0, TAU, 24, Color("be83d3"), 1.5, true)
			break
	draw_circle(center + Vector2(0, 3), 8, Color(0, 0, 0, 0.3))
	draw_line(center + Vector2(-3, -2), center + Vector2(-5, 5), Color("b5a68a"), 3)
	draw_line(center + Vector2(3, -2), center + Vector2(5, 5), Color("b5a68a"), 3)
	draw_rect(Rect2(center + Vector2(-6, -15), Vector2(12, 16)), armor)
	draw_circle(center + Vector2(0, -20), 6, Color("dbc3a1"))
	draw_line(center + Vector2(-6, -23), center + Vector2(6, -23), Color("77695a"), 3)
	draw_line(center + Vector2(10, -21), center + Vector2(10, 0), Color("dac494"), 2)

	if type == 7:
		draw_line(center + Vector2(-7, -26), center + Vector2(7, -26), Color("e4c980"), 4)
	draw_set_transform(Vector2.ZERO)
