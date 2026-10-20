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
	for index in range(Model.SLOTS.size()):
		var center: Vector2 = project(Model.SLOTS[index])
		var diamond := PackedVector2Array([center + Vector2(-26, 0), center + Vector2(0, -13), center + Vector2(26, 0), center + Vector2(0, 13)])
		draw_colored_polygon(diamond, SLOT_FILL)
		draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color("ddbd78") if selected == index else Color("779b89"), 2, true)
		draw_string(font, center + Vector2(-9, 5), "E%d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, INK)
	_draw_fortress(project(Vector2(17, 6)))
	var entrance: Vector2 = project(Model.PATH_POINTS[0])
	draw_circle(entrance, 5, Color("debd7f"))
	draw_string(font, entrance + Vector2(-48, -20), "ENTRÉE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("a7b8aa"))
	if model != null and model.active:
		_draw_pillager(project(model.enemy_position()))

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

func _draw_pillager(center: Vector2) -> void:
	draw_circle(center + Vector2(0, 3), 8, Color(0, 0, 0, 0.3))
	draw_line(center + Vector2(-3, -2), center + Vector2(-5, 5), Color("b5a68a"), 3)
	draw_line(center + Vector2(3, -2), center + Vector2(5, 5), Color("b5a68a"), 3)
	draw_rect(Rect2(center + Vector2(-6, -15), Vector2(12, 16)), Color("b45f4c"))
	draw_circle(center + Vector2(0, -20), 6, Color("dbc3a1"))
	draw_line(center + Vector2(-6, -23), center + Vector2(6, -23), Color("77695a"), 3)
	draw_line(center + Vector2(10, -21), center + Vector2(10, 0), Color("dac494"), 2)
