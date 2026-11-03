extends SceneTree
## Directional gait study. Coordinates refer to the original quarter-view drawing.
const View = preload("res://scripts/valley_view.gd")
const Model = preload("res://scripts/valley_model.gd")
const SCALE := 28.9 / 925.0
const STRIDE := 8.5
const DUTY := 0.56
const PIVOT := Vector2(700, 890)
const DIRECTION := Vector2(0.894427191, 0.4472135955)
const HOOVES := [Vector2(581, 793), Vector2(398, 840), Vector2(1004, 861), Vector2(789, 925)]
const OFFSETS := [0.5, 0.0, 0.0, 0.5]
const STEP := 24
const FOOT_ORDER := [1, 0, 3, 2]

class GaitView extends View:
	var skin: Texture2D
	var mesh: ArrayMesh
	var travel := 0.0
	var weights := PackedVector4Array()
	var rest := PackedVector2Array()
	var uv := PackedVector2Array()
	var indices := PackedInt32Array()
	var minimum_ratio := 1.0
	var native_contact := 0.0
	var previous_contacts: Dictionary = {}

	var contact_indices := PackedInt32Array([-1, -1, -1, -1])
	var triangle_areas := PackedFloat32Array()

	func prepare() -> void:
		var columns: Array[float] = []
		var rows: Array[float] = []
		for x in range(0, 1537, STEP):
			columns.append(float(x))
		for y in range(0, 1025, STEP):
			rows.append(float(y))
		rows.append(1024.0)
		for hoof in HOOVES:
			if not columns.has(hoof.x):
				columns.append(hoof.x)
			if not rows.has(hoof.y):
				rows.append(hoof.y)
		columns.sort()
		rows.sort()
		for row in range(rows.size()):
			for column in range(columns.size()):
				var point := Vector2(columns[column], rows[row])
				rest.append(point)
				uv.append(point / Vector2(1536, 1024))
				for foot in range(4):
					if point == HOOVES[foot]:
						contact_indices[foot] = rest.size() - 1
				var influence := Vector4.ZERO
				var left: int = FOOT_ORDER[0]
				var right: int = FOOT_ORDER[-1]
				for pair in range(3):
					left = FOOT_ORDER[pair]
					right = FOOT_ORDER[pair + 1]
					if point.x <= HOOVES[right].x:
						break
				var mix_value := clampf(inverse_lerp(HOOVES[left].x, HOOVES[right].x, point.x), 0.0, 1.0)
				var sole_y := lerpf(HOOVES[left].y, HOOVES[right].y, mix_value)
				var height := smoothstep(540.0, sole_y - 24.0, point.y)
				influence[left] = (1.0 - mix_value) * height
				influence[right] = mix_value * height
				weights.append(influence)
				if row < rows.size() - 1 and column < columns.size() - 1:
					var a := row * columns.size() + column
					var below := a + columns.size()
					indices.append_array([a, a + 1, below, a + 1, below + 1, below])
					var area := (columns[column + 1] - point.x) * (rows[row + 1] - point.y)
					triangle_areas.append_array([area, area])
		for index in contact_indices:
			assert(index >= 0)

	func offsets() -> Array[Vector2]:
		var result: Array[Vector2] = []
		for offset in OFFSETS:
			var phase := fposmod(travel / STRIDE + offset, 1.0)
			var step_distance := STRIDE * (DUTY * 0.5 - phase)
			var lift := 0.0
			if phase >= DUTY:
				var swing := (phase - DUTY) / (1.0 - DUTY)
				step_distance += STRIDE * smoothstep(0.0, 1.0, swing)
				lift = 1.2 * pow(sin(PI * swing), 2)
			result.append((DIRECTION * step_distance - Vector2(0, lift)) / SCALE)
		return result

	func _draw_pillager(center: Vector2, _enemy: Dictionary, _hit: float = 0.0, _pose: Dictionary = {}) -> void:
		var feet := offsets()
		var phase := travel / STRIDE
		var body := Vector2(0.22 * sin(TAU * phase), -0.55 * pow(sin(TAU * phase), 2)) / SCALE
		var vertices := PackedVector2Array()
		for index in range(rest.size()):
			var point := rest[index]
			var influence := weights[index]
			var offset: Vector2 = body * (1.0 - influence.dot(Vector4.ONE))
			for foot in range(4):
				offset += feet[foot] * influence[foot]
			vertices.append(point + offset)
		for index in range(0, indices.size(), 3):
			var a := vertices[indices[index]]
			var b := vertices[indices[index + 1]]
			var c := vertices[indices[index + 2]]
			minimum_ratio = minf(minimum_ratio, (b - a).cross(c - a) / triangle_areas[index / 3])
		for foot in range(4):
			var contact_phase := fposmod(phase + OFFSETS[foot], 1.0)
			var contact := center + (vertices[contact_indices[foot]] - PIVOT) * SCALE
			var cycle := floori(phase + OFFSETS[foot])
			if contact_phase < DUTY and previous_contacts.has(foot) and previous_contacts[foot].cycle == cycle:
				native_contact = maxf(native_contact, contact.distance_to(previous_contacts[foot].point))
			if contact_phase < DUTY:
				previous_contacts[foot] = {"point": contact, "cycle": cycle}
			else:
				previous_contacts.erase(foot)
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_TEX_UV] = uv
		arrays[Mesh.ARRAY_INDEX] = indices
		mesh = ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		draw_circle(center, 8.0, Color(0, 0, 0, 0.25))
		draw_mesh(mesh, skin, Transform2D(0.0, Vector2.ONE * SCALE, 0.0, center - PIVOT * SCALE))

class Preview extends Node2D:
	var board: SubViewport
	var focus := Vector2.ZERO
	func _draw() -> void:
		draw_texture(board.get_texture(), Vector2.ZERO)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(24, 40), "Sanglier · Cycle de trois quarts avant", HORIZONTAL_ALIGNMENT_LEFT, -1, 26)
		draw_string(font, Vector2(24, 72), "Essai d’animation · Première diagonale du Gué · Vitesse ×1", HORIZONTAL_ALIGNMENT_LEFT, -1, 17)
		draw_string(font, Vector2(24, 376), "Agrandissement ×4 du rendu", HORIZONTAL_ALIGNMENT_LEFT, -1, 17)
		draw_texture_rect_region(board.get_texture(), Rect2(24, 390, 320, 224), Rect2(focus - Vector2(40, 40), Vector2(80, 56)))
		draw_rect(Rect2(24, 390, 320, 224), Color("58715f"), false)
		draw_string(font, Vector2(24, 690), "Foulée expérimentale de 8,5 px · Appuis en paires diagonales", HORIZONTAL_ALIGNMENT_LEFT, -1, 17)

func _initialize() -> void:
	call_deferred("record")

func record() -> void:
	root.size = Vector2i(1280, 800)
	root.content_scale_size = root.size
	var folder: String = get_script().resource_path.get_base_dir()
	var frames: String = folder.path_join("captures/gait")
	DirAccess.make_dir_recursive_absolute(frames)
	var model := Model.new()
	model.spawn_schedule.assign([{"type": 2, "time": 0.0}])
	assert(model.start())
	var board := SubViewport.new()
	board.size = root.size
	board.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(board)
	var view := GaitView.new()
	view.model = model
	view.prepare()
	var source := Image.load_from_file(folder.path_join("sanglier_trois_quarts_source_v001.png"))
	source.generate_mipmaps()
	view.skin = ImageTexture.create_from_image(source)
	view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	board.add_child(view)
	var preview := Preview.new()
	preview.board = board
	root.add_child(preview)
	for frame in range(144):
		if frame > 0:
			model.advance(1.0 / 60.0)
		var enemy: Dictionary = model.enemies[0]
		view.travel = enemy.distance * Vector2(27, 13.5).length()
		preview.focus = View.project(model.enemy_position(enemy))
		view.queue_redraw()
		preview.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(frames.path_join("%04d.png" % frame)) == OK)
	var proof := FileAccess.open(folder.path_join("controle_cycle_avant.json"), FileAccess.WRITE)
	proof.store_string(JSON.stringify({"frames": 144, "fps": 60, "stride_px": STRIDE, "minimum_triangle_ratio": view.minimum_ratio, "maximum_contact_drift_px": view.native_contact}, "  ") + "\n")
	proof.close()
	print("BOAR_QUARTER_GAIT frames=144 minimum_ratio=", view.minimum_ratio, " contact=", view.native_contact)
	quit(0 if view.minimum_ratio > 0.1 and view.native_contact < 0.001 else 1)
