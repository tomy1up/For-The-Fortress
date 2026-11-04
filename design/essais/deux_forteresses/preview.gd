extends SceneTree
const Geometry = preload("res://scripts/route_geometry.gd")
const View = preload("res://scripts/valley_view.gd")
const Maps = preload("res://scripts/map_definition.gd")

class Board extends View:
	var routes: Array[Dictionary] = []
	var destinations := {}

	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1280, 800), Color("0b1814"))
		draw_string(ThemeDB.fallback_font, Vector2(32, 52), "Les Deux Bastions", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("e0dbbf"))
		draw_string(ThemeDB.fallback_font, Vector2(32, 84), "Étude de carte et de lisibilité", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("aabbb0"))
		var ground := PackedVector2Array([project(Vector2.ZERO), project(Vector2(18, 0)), project(Vector2(18, 10)), project(Vector2(0, 10))])
		draw_colored_polygon(ground, Color("344939"))
		for x in range(19):
			draw_line(project(Vector2(x, 0)), project(Vector2(x, 10)), Color("425849"))
		for y in range(11):
			draw_line(project(Vector2(0, y)), project(Vector2(18, y)), Color("425849"))
		for index in range(routes.size()):
			var route: Dictionary = routes[index]
			var line := PackedVector2Array()
			for point in route.path_points:
				line.append(project(point))
			draw_polyline(line, Color("192a21"), 20, true)
			draw_polyline(line, entry_color(index), 11, true)
			draw_circle(line[0], 9, entry_color(index))
			draw_string(ThemeDB.fallback_font, line[0]+Vector2(-35, -16), "Entrée %d" % (index+1), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, entry_color(index))
			_draw_fortress(project(destinations[route.destination_id]))
			draw_string(ThemeDB.fallback_font, fortress_center(line[-1])+Vector2(-40, 58), "Bastion %s" % route.destination_id, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, entry_color(index))

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(1280, 800)
	var board := Board.new()
	board.font = ThemeDB.fallback_font
	board.destinations = {"Nord": Vector2(16, 2), "Sud": Vector2(16, 8)}
	for spec in [["upper", "Nord", [Vector2(0, 1), Vector2(5, 1), Vector2(5, 4), Vector2(11, 4), Vector2(11, 2), Vector2(16, 2)]],
			["lower", "Sud", [Vector2(0, 9), Vector2(4, 9), Vector2(4, 6), Vector2(10, 6), Vector2(10, 8), Vector2(16, 8)]]]:
		board.routes.append({"id": spec[0], "destination_id": spec[1], "path_points": spec[2], "path_length": Maps.measured_length(spec[2])})
	assert(Geometry.destinations_error(board.routes, board.destinations).is_empty())
	root.add_child(board)
	await process_frame
	await RenderingServer.frame_post_draw
	var output := ProjectSettings.globalize_path("res://../design/essais/deux_forteresses/les_deux_bastions.png")
	var status := root.get_texture().get_image().save_png(output)
	print("BASTIONS_CAPTURE=", status)
	quit(status)
