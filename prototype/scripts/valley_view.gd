extends Node2D

const Model = preload("res://scripts/valley_model.gd")
const ORIGIN := Vector2(658, 174)
const AXIS := Vector2(27, 13.5)
const INK := Color("d9e4d7")
const SLOT_FILL := Color("213e3b")
const IMPACT_DURATION := 0.32 # Secondes de simulation, comme les autres effets du combat.
var model: RefCounted
var selected: int = -1
var purchase_preview: Dictionary = {}
var upgrade_preview: Dictionary = {}
var inspected_enemy_id: int = -1
var breach_feedback: Dictionary = {}
var font: Font = ThemeDB.fallback_font

static func project(point: Vector2) -> Vector2:
	return ORIGIN + Vector2((point.x - point.y) * AXIS.x, (point.x + point.y) * AXIS.y)

static func range_outline(center: Vector2, radius: float) -> PackedVector2Array:
	var ring := PackedVector2Array()
	for step in range(65):
		var angle: float = TAU * step / 64.0
		ring.append(project(center + Vector2(cos(angle), sin(angle)) * radius))
	return ring

static func impact_opacity(age: float) -> float:
	return clampf(1.0 - age / IMPACT_DURATION, 0.0, 1.0) if age >= 0.0 else 0.0

static func secondary_segments(shot: Dictionary) -> Array[PackedVector2Array]:
	var segments: Array[PackedVector2Array] = []
	var origin: Vector2 = shot.to
	for target in shot.get("secondary", []):
		segments.append(PackedVector2Array([project(origin), project(target)]))
		if shot.type == 3: origin = target
	return segments

func _draw_impact(shot: Dictionary, age: float) -> void:
	var alpha: float = impact_opacity(age)
	if alpha <= 0.0: return
	var color: Color = {2: Color("9cc4e4"), 3: Color("a1d6ab"), 4: Color("f2aa64"), 5: Color("d6a1ef")}.get(shot.type, Color("e8ce92"))
	color.a = alpha
	var height := Vector2(0, -12)
	var impact: Vector2 = project(shot.to)
	draw_line(project(shot.from) + Vector2(0, -17), impact + height, color, 2, true)
	draw_circle(impact + height, 4, color, false, 2, true)
	if shot.type in [2, 4]:
		# Le contour montre le rayon logique, sans prétendre toucher tous les ennemis dedans.
		var ring := range_outline(shot.to, shot.get("radius", 1.0))
		draw_colored_polygon(ring, Color(color, alpha * 0.12))
		draw_polyline(ring, color, 2, true)
	for segment in secondary_segments(shot):
		var target: Vector2 = segment[1] + height
		if shot.type == 3:
			var start: Vector2 = segment[0] + height
			draw_line(start, target, color, 2, true)
			if start.distance_to(target) > 8.0:
				var direction: Vector2 = (target - start).normalized()
				var tip: Vector2 = start.lerp(target, 0.65)
				draw_polyline(PackedVector2Array([tip-direction.rotated(0.55)*6, tip, tip-direction.rotated(-0.55)*6]), color, 2, true)
		# Marquer uniquement les victimes réellement enregistrées par le modèle.
		draw_circle(target, 3, color, false, 1.5, true)

static func enemy_bounds(enemy: Dictionary) -> Rect2:
	var center: Vector2 = project(Model.position_at(enemy.distance))
	var scale: float = _enemy_scale(enemy)
	var width: float = maxf(28.0,32.0*scale)
	return Rect2(center+Vector2(-width/2.0,-39.0*scale),Vector2(width,47.0*scale))

func enemy_at(point: Vector2) -> int:
	if model == null: return -1
	var found: int = -1
	var front_y: float = -INF
	for enemy in model.enemies:
		if enemy.hp <= 0.0 or not enemy_bounds(enemy).has_point(point): continue
		var y: float = project(Model.position_at(enemy.distance)).y
		if y >= front_y: # Même priorité visuelle que le dessin, dernier acteur en cas d'égalité.
			front_y = y
			found = enemy.id
	return found

static func covered_route(center: Vector2, radius: float) -> Array[PackedVector2Array]:
	var sections: Array[PackedVector2Array] = []
	for window in Model.coverage_windows(center, radius):
		var points := PackedVector2Array([project(Model.position_at(window.first))])
		var distance: float = 0.0
		for index in range(1, Model.PATH_POINTS.size()):
			distance += Model.PATH_POINTS[index-1].distance_to(Model.PATH_POINTS[index])
			if distance > window.first + Model.EPS and distance < window.last - Model.EPS:
				points.append(project(Model.PATH_POINTS[index]))
		points.append(project(Model.position_at(window.last)))
		sections.append(points)
	return sections

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
	var preview: Dictionary = purchase_preview if not purchase_preview.is_empty() else upgrade_preview
	if model != null and selected >= 0 and not preview.is_empty():
		var preview_ring := range_outline(Model.SLOTS[selected], preview.range)
		draw_colored_polygon(preview_ring, Color(0.35, 0.8, 0.95, 0.12))
		draw_polyline(preview_ring, Color("8bd5e6"), 2.5, true)
		for section in covered_route(Model.SLOTS[selected], preview.range):
			draw_polyline(section, Color("8bd5e6"), 6, true)
	if model != null and selected >= 0 and not model.defenders[selected].is_empty():
		var stats: Dictionary = model.get_stats(selected)
		var ring := range_outline(Model.SLOTS[selected], stats.range)
		draw_colored_polygon(ring, Color(0.8, 0.85, 0.5, 0.05))
		draw_polyline(ring, Color(0.8, 0.85, 0.5, 0.35), 1.5, true)
		if preview.is_empty():
			for section in covered_route(Model.SLOTS[selected],stats.range):
				draw_polyline(section,Color(0.9,0.77,0.48,0.65),4,true)
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
				actors.append({"point": project(Model.SLOTS[slot]), "defender": model.defenders[slot],"order":actors.size()})
		for enemy in model.enemies:
			actors.append({"point": project(Model.position_at(enemy.distance)), "enemy": enemy,"order":actors.size()})
		actors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.order < b.order if a.point.y == b.point.y else a.point.y < b.point.y)
		for actor in actors:
			if actor.has("defender"):
				_draw_defender(actor.point, actor.defender.type, actor.defender.get("level", 1), actor.defender.get("branch", -1))
			else:
				_draw_pillager(actor.point, actor.enemy)
				var ratio: float = clampf(actor.enemy.hp / actor.enemy.get("max_hp", 40.0), 0.0, 1.0)
				var bar_position: Vector2 = actor.point + Vector2(-12, -36 * _enemy_scale(actor.enemy))
				draw_rect(Rect2(bar_position, Vector2(24, 4)), Color("472f2a"))
				draw_rect(Rect2(bar_position, Vector2(24 * ratio, 4)), Color("edcc80") if actor.enemy.id == inspected_enemy_id else Color("a1ba75"))
		if model.active:
			for shot in model.shots:
				_draw_impact(shot, model.elapsed - shot.time)
	if not breach_feedback.is_empty(): _draw_breach_feedback()

static func breach_text(count: int, damage: int) -> String:
	return "−%d PV · %d ennemi%s passé%s" % [damage,count,"" if count == 1 else "s","" if count == 1 else "s"]

func _draw_breach_feedback() -> void:
	var center: Vector2 = project(Vector2(17,6)) + Vector2(52,26)
	var warning := Color("ef9b89")
	draw_rect(Rect2(center+Vector2(-42,-72),Vector2(84,92)),Color(warning,0.75),false,2)
	var text: String = breach_text(breach_feedback.count,breach_feedback.damage)
	var width: float = font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,15).x+24
	var box := Rect2(center+Vector2(-width/2.0,-110),Vector2(width,30))
	draw_rect(box,Color("35241f"))
	draw_rect(box,warning,false,1)
	draw_string(font,box.position+Vector2(12,21),text,HORIZONTAL_ALIGNMENT_LEFT,-1,15,warning)

func _draw_defender(center: Vector2, type: int, level: int = 1, branch: int = -1) -> void:
	var color: Color = [Color("6f9c6b"), Color("b79a64"), Color("668db5"), Color("72a392"), Color("b8a16a"), Color("a782b7")][type]
	var skin: Color = [Color("e4d0a5"),Color("e2bc94"),Color("e4d0a5"),Color("86b49d"),Color("a2b96e"),Color("96ad78")][type]
	draw_circle(center + Vector2(0, 3), 9, Color(0, 0, 0, 0.25))
	var half_width: float = 8.0 if type == 1 else 6.0
	draw_rect(Rect2(center + Vector2(-half_width, -17), Vector2(half_width*2, 19)), color)
	draw_circle(center + Vector2(0, -23), 6, skin)
	if type in [0,3,4,5]:
		for side in [-1,1]:
			draw_colored_polygon(PackedVector2Array([center+Vector2(side*5,-26),center+Vector2(side*10,-24),center+Vector2(side*5,-21)]),skin)
	if type == 1:
		draw_colored_polygon(PackedVector2Array([center+Vector2(-5,-22),center+Vector2(5,-22),center+Vector2(3,-15),center+Vector2(0,-12),center+Vector2(-3,-15)]),Color("9c6c44"))
	elif type in [3,5]:
		for side in [-1,1]:
			draw_line(center+Vector2(side*3,-18),center+Vector2(side*3,-21),Color("ebe4c6"),1.5)
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

static func _enemy_scale(enemy: Dictionary) -> float:
	return [0.7, 1.0, 0.85, 1.2, 1.0, 1.5, 1.3, 1.7][enemy.get("type", 1)]

static func enemy_color(type: int) -> Color:
	return [Color("789263"), Color("b45f4c"), Color("c6a16a"), Color("9e6659"), Color("967556"), Color("838e85"), Color("9777a6"), Color("aca384")][type]

func _draw_pillager(center: Vector2, enemy: Dictionary) -> void:
	var type: int = enemy.get("type", 1)
	var armor: Color = enemy_color(type)
	draw_set_transform(center, 0.0, Vector2.ONE * _enemy_scale(enemy))
	center = Vector2.ZERO
	if enemy.id == inspected_enemy_id:
		draw_arc(center+Vector2(0,3),14,0,TAU,32,Color("edcc80"),2,true)
	for curse in model.curses:
		if curse.enemy_id == enemy.id:
			draw_arc(center + Vector2(0, -13), 19, 0, TAU, 24, Color("be83d3"), 1.5, true)
			var mark: Vector2 = center + Vector2(0, -45)
			draw_colored_polygon(PackedVector2Array([mark+Vector2(0,-5),mark+Vector2(4,0),mark+Vector2(0,5),mark+Vector2(-4,0)]), Color("d6a1ef"))
			break
	draw_circle(center + Vector2(0, 3), 8, Color(0, 0, 0, 0.3))
	var stride: float = sin(model.elapsed*10.0*enemy.get("speed",1.0)+enemy.id)*2.0 if model.active else 0.0
	draw_line(center + Vector2(-3, -2), center + Vector2(-5+stride, 5), Color("b5a68a"), 3)
	draw_line(center + Vector2(3, -2), center + Vector2(5-stride, 5), Color("b5a68a"), 3)
	if type == 7:
		draw_colored_polygon(PackedVector2Array([Vector2(-8,-20),Vector2(8,-20),Vector2(13,3),Vector2(-13,3)]),Color("713b42"))
	var half_width: float = 9.0 if type in [3,5] else 6.0
	draw_rect(Rect2(center + Vector2(-half_width, -15), Vector2(half_width*2, 16)), armor)
	draw_circle(center + Vector2(0, -20), 6, Color("dbc3a1"))
	draw_line(center + Vector2(-6, -23), center + Vector2(6, -23), Color("77695a"), 3)
	match type:
		0: # Petit couteau, silhouette légère.
			draw_line(Vector2(8,-5),Vector2(11,-14),Color("c6c6a4"),2)
		1: # Épée droite du pillard.
			draw_line(Vector2(10,-21),Vector2(10,0),Color("dac494"),2)
			draw_line(Vector2(7,-7),Vector2(13,-7),Color("746043"),2)
		2: # Foulard et lame courte du sprinter.
			draw_colored_polygon(PackedVector2Array([Vector2(-5,-18),Vector2(-14,-14),Vector2(-13,-20)]),Color("af5351"))
			draw_line(Vector2(8,-7),Vector2(13,-16),Color("e1d0a4"),2)
		3: # Massue de la brute.
			draw_line(Vector2(10,-1),Vector2(10,-25),Color("a1865d"),3)
			draw_circle(Vector2(10,-25),4,Color("6d5544"))
		4: # Deux haches courtes du maraudeur.
			for side in [-1,1]:
				draw_line(Vector2(side*10,-3),Vector2(side*10,-23),Color("b69b70"),2)
				draw_colored_polygon(PackedVector2Array([Vector2(side*9,-23),Vector2(side*15,-18),Vector2(side*9,-14)]),Color("c1b49a"))
		5: # Large ceinture et marteau du colosse.
			draw_line(Vector2(-9,-4),Vector2(9,-4),Color("4d5c59"),4)
			draw_line(Vector2(10,0),Vector2(10,-25),Color("aa9470"),3)
			draw_rect(Rect2(Vector2(5,-30),Vector2(10,8)),Color("b2bbb0"))
		6: # Bouclier pointu et crête de l'élite.
			draw_colored_polygon(PackedVector2Array([Vector2(-14,-17),Vector2(-5,-17),Vector2(-5,-8),Vector2(-10,-3),Vector2(-14,-8)]),Color("645d81"))
			draw_line(Vector2(-10,-15),Vector2(-10,-7),Color("d5c495"),2)
			draw_line(Vector2(0,-26),Vector2(0,-32),Color("c0a8cc"),4)
			draw_line(Vector2(10,-24),Vector2(10,-2),Color("d4c8a1"),2)
		7: # Cape et couronne du chef de siège.
			draw_colored_polygon(PackedVector2Array([Vector2(-7,-24),Vector2(-7,-31),Vector2(-3,-27),Vector2(0,-33),Vector2(3,-27),Vector2(7,-31),Vector2(7,-24)]),Color("e4c980"))
			draw_line(Vector2(11,-28),Vector2(11,0),Color("e4c980"),3)
			draw_line(Vector2(7,-8),Vector2(14,-8),Color("c1a565"),2)
	draw_set_transform(Vector2.ZERO)
