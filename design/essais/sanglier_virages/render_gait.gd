extends SceneTree
## Directional gait study on the first straight and corner of the GuÃ©.
const View = preload("res://scripts/valley_view.gd")
const Model = preload("res://scripts/valley_model.gd")
const SCALE := 28.9 / 925.0
const STRIDE := 8.5
const DUTY := 0.56
const PIVOT := Vector2(700, 890)
const FRONT_SCALE := 28.9 / 1105.0
const FRONT_PIVOT := Vector2(626.5, 1082)
const FRONT_HOOVES := [Vector2(920, 990), Vector2(330, 990), Vector2(810, 1120), Vector2(435, 1120)]
const FRONT_ORDER := [1, 3, 2, 0]
const PROJECTED_UNIT := 30.186917696
const CORNERS := [4.0, 8.0, 13.0, 17.0, 22.0, 25.0]
const SEGMENT_VIEWS := [0, 2, 0, 3, 0, 2, 0]
const REAR_SCALE := 28.9 / 968.0
const REAR_PIVOT := Vector2(755, 830)
const REAR_HOOVES := [Vector2(588, 960), Vector2(453, 882), Vector2(965, 783), Vector2(1043, 661)]
const REAR_ORDER := [1, 0, 2, 3]
const TURN_HALF_WIDTH := 0.215
const ROUNDING_RADIUS := 0.45
const HOOVES := [Vector2(581, 793), Vector2(398, 840), Vector2(1004, 861), Vector2(789, 925)]
const OFFSETS := [0.5, 0.0, 0.0, 0.5]
const STEP := 24
const FOOT_ORDER := [1, 0, 3, 2]

class GaitView extends View:
	var skin: Texture2D
	var mesh: ArrayMesh
	var travel := 0.0
	var distance := 0.0
	var turning := false
	var full_route := false
	var rear_skin: Texture2D
	var schedule: Array[Dictionary] = []
	var front_skin: Texture2D
	var quarter_skin: Texture2D
	var view_index := -1
	var view_changes: Array[Dictionary] = []
	var contact_corrections: Dictionary = {}
	var correction_peak := 0.0
	var maximum_path_deviation := 0.0
	var stance_samples := 0
	var weights := PackedVector4Array()
	var rest := PackedVector2Array()
	var uv := PackedVector2Array()
	var indices := PackedInt32Array()
	var minimum_ratio := 1.0
	var worst: Dictionary = {}
	var native_contact := 0.0
	var previous_contacts: Dictionary = {}

	var contact_indices := PackedInt32Array([-1, -1, -1, -1])
	var triangle_areas := PackedFloat32Array()

	func rear_weights(point: Vector2) -> Vector4:
		# Across the direction of travel, near and far hooves remain separated
		# even when the two front hooves overlap on the horizontal axis.
		var across := Vector2(0.25, 1.0)
		var lateral := point.dot(across)
		var hind := clampf(inverse_lerp(REAR_HOOVES[1].dot(across), REAR_HOOVES[0].dot(across), lateral), 0.0, 1.0)
		var fore := clampf(inverse_lerp(REAR_HOOVES[3].dot(across), REAR_HOOVES[2].dot(across), lateral), 0.0, 1.0)
		var forward := smoothstep(REAR_HOOVES[0].x, REAR_HOOVES[2].x, point.x)
		var weight := Vector4(hind * (1.0 - forward), (1.0 - hind) * (1.0 - forward),
			fore * forward, (1.0 - fore) * forward)
		var soles := Vector4(REAR_HOOVES[0].y, REAR_HOOVES[1].y, REAR_HOOVES[2].y, REAR_HOOVES[3].y)
		return weight * smoothstep(330.0, weight.dot(soles) - 24.0, point.y)

	func prepare(texture_size: Vector2i, hooves: Array, order: Array) -> void:
		weights.clear()
		rest.clear()
		uv.clear()
		indices.clear()
		triangle_areas.clear()
		contact_indices.fill(-1)
		var columns: Array[float] = []
		var rows: Array[float] = []
		for x in range(0, texture_size.x, STEP):
			columns.append(float(x))
		for y in range(0, texture_size.y, STEP):
			rows.append(float(y))
		rows.append(float(texture_size.y))
		columns.append(float(texture_size.x))
		for hoof in hooves:
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
				uv.append(point / Vector2(texture_size))
				for foot in range(4):
					if point == hooves[foot]:
						contact_indices[foot] = rest.size() - 1
				var influence := Vector4.ZERO
				var left: int = order[0]
				var right: int = order[-1]
				for pair in range(3):
					left = order[pair]
					right = order[pair + 1]
					if point.x <= hooves[right].x:
						break
				var mix_value := clampf(inverse_lerp(hooves[left].x, hooves[right].x, point.x), 0.0, 1.0)
				var sole_y := lerpf(hooves[left].y, hooves[right].y, mix_value)
				var blend_start := 445.0 if full_route else 540.0
				var height := smoothstep(blend_start, sole_y - 24.0, point.y)
				influence[left] = (1.0 - mix_value) * height
				influence[right] = mix_value * height
				weights.append(rear_weights(point) if hooves == REAR_HOOVES else influence)
				if row < rows.size() - 1 and column < columns.size() - 1:
					var a := row * columns.size() + column
					var below := a + columns.size()
					indices.append_array([a, a + 1, below, a + 1, below + 1, below])
					var area := (columns[column + 1] - point.x) * (rows[row + 1] - point.y)
					triangle_areas.append_array([area, area])
		for index in contact_indices:
			assert(index >= 0)

	func switch_distance(wanted: float, phase: float) -> float:
		var cycle_length := STRIDE / PROJECTED_UNIT
		return (roundf(wanted / cycle_length - phase) + phase) * cycle_length

	func prepare_route() -> void:
		if not turning:
			return
		for corner_index in range(CORNERS.size() if full_route else 1):
			var distance_at_corner: float = CORNERS[corner_index]
			var before: int = SEGMENT_VIEWS[corner_index]
			var after: int = SEGMENT_VIEWS[corner_index + 1]
			var use_face := before == 2 or after == 2
			if use_face:
				var first := distance_at_corner - TURN_HALF_WIDTH
				var second := distance_at_corner + TURN_HALF_WIDTH
				if full_route:
					first = switch_distance(first, 0.32 if before == 0 else 0.82)
					second = switch_distance(second, 0.32 if after == 0 else 0.82)
				schedule.append({"at": first, "view": 1})
				schedule.append({"at": second, "view": after})
			else:
				schedule.append({"at": switch_distance(distance_at_corner, 0.32), "view": after})

	func visual_position(progress: float) -> Vector2:
		var point: Vector2 = model.point_on_path(progress)
		if progress < 0.0:
			point = model.path_points[0] + Vector2(progress, 0)
		var screen := project(point)
		if turning:
			for corner_index in range(CORNERS.size() if full_route else 1):
				var delta := absf(progress - float(CORNERS[corner_index]))
				if delta >= ROUNDING_RADIUS:
					continue
				var corner: Vector2 = model.path_points[corner_index + 1]
				var from: Vector2 = model.path_points[corner_index]
				var to: Vector2 = model.path_points[corner_index + 2]
				var incoming := project(corner) - project(from)
				incoming /= from.distance_to(corner)
				var outgoing := project(to) - project(corner)
				outgoing /= to.distance_to(corner)
				screen += (outgoing - incoming) * pow(ROUNDING_RADIUS - delta, 2) / (4.0 * ROUNDING_RADIUS)
				break
		return screen

	func offsets(center: Vector2, local_scale: Vector2, mirrored: bool) -> Array[Vector2]:
		var result: Array[Vector2] = []
		for foot in range(4):
			var logical_foot := foot ^ int(mirrored)
			var phase := fposmod(travel / STRIDE + OFFSETS[logical_foot], 1.0)
			var step_distance := STRIDE * (DUTY * 0.5 - phase)
			var lift := 0.0
			if phase >= DUTY:
				var swing := (phase - DUTY) / (1.0 - DUTY)
				step_distance += STRIDE * smoothstep(0.0, 1.0, swing)
				lift = 1.2 * pow(sin(PI * swing), 2)
			# Extrapolate past the entrance so the first planted step can begin behind it.
			var target := distance + step_distance / PROJECTED_UNIT
			result.append((visual_position(target) - center - Vector2(0, lift)) / local_scale)
		return result

	func _draw_pillager(center: Vector2, _enemy: Dictionary, _hit: float = 0.0, _pose: Dictionary = {}) -> void:
		var next_view := 0
		for entry in schedule:
			if distance < entry.at:
				break
			next_view = entry.view
		var changed := next_view != view_index
		var front := next_view == 1
		var mirrored := next_view == 2
		var rear := next_view == 3
		var hooves := FRONT_HOOVES if front else REAR_HOOVES if rear else HOOVES
		var order := FRONT_ORDER if front else REAR_ORDER if rear else FOOT_ORDER
		if changed:
			skin = front_skin if front else rear_skin if rear else quarter_skin
			prepare(skin.get_size(), hooves, order)
		var scale_value := FRONT_SCALE if front else REAR_SCALE if rear else SCALE
		var local_scale := Vector2(-scale_value if mirrored else scale_value, scale_value)
		var pivot := FRONT_PIVOT if front else REAR_PIVOT if rear else PIVOT
		var visual_center := visual_position(distance)
		maximum_path_deviation = maxf(maximum_path_deviation, center.distance_to(visual_center))
		var feet := offsets(visual_center, local_scale, mirrored)
		var phase := travel / STRIDE
		if changed:
			contact_corrections.clear()
			var largest_gap := 0.0
			for foot in range(4):
				var logical_foot := foot ^ int(mirrored)
				var foot_phase: float = phase + OFFSETS[logical_foot]
				var cycle := floori(foot_phase)
				if fposmod(foot_phase, 1.0) >= DUTY or not previous_contacts.has(logical_foot):
					continue
				if previous_contacts[logical_foot].cycle != cycle:
					continue
				var position := visual_center + (rest[contact_indices[foot]] - pivot + feet[foot]) * local_scale
				var correction: Vector2 = previous_contacts[logical_foot].point - position
				largest_gap = maxf(largest_gap, correction.length())
				contact_corrections[logical_foot] = {"offset": correction, "cycle": cycle}
			if view_index >= 0:
				view_changes.append({"from": view_index, "to": next_view, "distance": distance,
					"shared_contacts": contact_corrections.size(), "uncorrected_gap_px": largest_gap,
					"residual_gap_px": 0.0})
			# Carry the change across adjacent limbs so a correction does not
			# concentrate in the narrow strip between two hooves.
			var anchors: Array[int] = []
			for foot in order:
				if contact_corrections.has(foot ^ int(mirrored)):
					anchors.append(foot)
			if anchors.size() >= 2:
				for foot in range(4):
					var logical_foot := foot ^ int(mirrored)
					if contact_corrections.has(logical_foot):
						continue
					var left := anchors[0]
					var right := anchors[1]
					for pair in range(anchors.size() - 1):
						left = anchors[pair]
						right = anchors[pair + 1]
						if hooves[foot].x <= hooves[right].x:
							break
					var blend := clampf(inverse_lerp(hooves[left].x, hooves[right].x, hooves[foot].x), 0.0, 1.0)
					var start: Vector2 = contact_corrections[left ^ int(mirrored)].offset
					var finish: Vector2 = contact_corrections[right ^ int(mirrored)].offset
					contact_corrections[logical_foot] = {"offset": start.lerp(finish, blend),
						"cycle": floori(phase + OFFSETS[logical_foot]) + int(fposmod(phase + OFFSETS[logical_foot], 1.0) >= DUTY)}
		view_index = next_view
		for foot in range(4):
			var logical_foot := foot ^ int(mirrored)
			if not contact_corrections.has(logical_foot):
				continue
			var correction: Dictionary = contact_corrections[logical_foot]
			var foot_phase: float = phase + OFFSETS[logical_foot] - correction.cycle
			if foot_phase >= 1.0:
				contact_corrections.erase(logical_foot)
				continue
			var shift: Vector2 = correction.offset * (1.0 - smoothstep(DUTY, 1.0, foot_phase))
			correction_peak = maxf(correction_peak, shift.length())
			feet[foot] += shift / local_scale
		var body := Vector2(0.22 * sin(TAU * phase), -0.55 * pow(sin(TAU * phase), 2)) / local_scale
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
			var ratio := (b - a).cross(c - a) / triangle_areas[index / 3]
			if ratio < minimum_ratio:
				minimum_ratio = ratio
				var at := rest[indices[index]]
				worst = {"view": next_view, "distance": distance, "xy": [at.x, at.y]}
		var contacts: Dictionary = {}
		for foot in range(4):
			var logical_foot := foot ^ int(mirrored)
			var foot_phase: float = phase + OFFSETS[logical_foot]
			if fposmod(foot_phase, 1.0) < DUTY:
				var contact := visual_center + (vertices[contact_indices[foot]] - pivot) * local_scale
				contacts[logical_foot] = {"point": contact, "cycle": floori(foot_phase)}
		for foot in contacts:
			if previous_contacts.has(foot) and previous_contacts[foot].cycle == contacts[foot].cycle:
				var gap: float = contacts[foot].point.distance_to(previous_contacts[foot].point)
				if changed:
					view_changes[-1].residual_gap_px = maxf(view_changes[-1].residual_gap_px, gap)
				else:
					native_contact = maxf(native_contact, gap)
					stance_samples += 1
		previous_contacts = contacts
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_TEX_UV] = uv
		arrays[Mesh.ARRAY_INDEX] = indices
		mesh = ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		draw_circle(visual_center, 8.0, Color(0, 0, 0, 0.25))
		draw_mesh(mesh, skin, Transform2D(0.0, local_scale, 0.0, visual_center - pivot * local_scale))

class Preview extends Node2D:
	var board: SubViewport
	var focus := Vector2.ZERO
	var turning := false
	var full_route := false
	func _draw() -> void:
		draw_texture(board.get_texture(), Vector2.ZERO)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(24, 40), "Sanglier · Traversée du Gué" if full_route else "Sanglier · Premier virage du Gué" if turning else "Sanglier · Cycle de trois quarts avant", HORIZONTAL_ALIGNMENT_LEFT, -1, 26)
		draw_string(font, Vector2(24, 72), "Essai hors campagne · Passage par la vue de face" if turning else "Essai hors campagne · Première diagonale du Gué", HORIZONTAL_ALIGNMENT_LEFT, -1, 17)
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
	var full_route := "--route" in OS.get_cmdline_user_args()
	var turning := full_route or "--turn" in OS.get_cmdline_user_args()
	var frames: String = folder.path_join("captures/full_route" if full_route else "captures/turn" if turning else "captures/gait")
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
	view.turning = turning
	view.full_route = full_route
	view.prepare_route()
	var source := Image.load_from_file(folder.path_join("sanglier_trois_quarts_source_v001.png"))
	source.generate_mipmaps()
	view.quarter_skin = ImageTexture.create_from_image(source)
	if turning:
		var front := Image.load_from_file(folder.path_join("sanglier_face_source_v001.png"))
		front.generate_mipmaps()
		view.front_skin = ImageTexture.create_from_image(front)
	if full_route:
		var rear := Image.load_from_file(folder.path_join("sanglier_arriere_trois_quarts_source_v001.png"))
		rear.generate_mipmaps()
		view.rear_skin = ImageTexture.create_from_image(rear)
	view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	board.add_child(view)
	var preview := Preview.new()
	preview.board = board
	preview.turning = turning
	preview.full_route = full_route
	view.full_route = full_route
	view.prepare_route()
	root.add_child(preview)
	var frame_count := 1019 if full_route else 240 if turning else 144
	for frame in range(frame_count):
		if frame > 0:
			model.advance(1.0 / 60.0)
		var enemy: Dictionary = model.enemies[0]
		view.distance = enemy.distance
		view.travel = view.distance * PROJECTED_UNIT
		preview.focus = View.project(model.enemy_position(enemy))
		view.queue_redraw()
		preview.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(frames.path_join("%04d.png" % frame)) == OK)
	var expected_switches := 10 if full_route else 2 if turning else 0
	var switches_valid := view.view_changes.size() == expected_switches
	for change in view.view_changes:
		switches_valid = switches_valid and change.shared_contacts >= 2 and change.residual_gap_px < 0.001
	var passed := view.minimum_ratio > 0.1 and view.native_contact < 0.001 and view.stance_samples > 0 and switches_valid
	var report_name := "controle_traversee.json" if full_route else "controle_premier_virage.json" if turning else "controle_cycle_avant.json"
	var proof := FileAccess.open(folder.path_join(report_name), FileAccess.WRITE)
	proof.store_string(JSON.stringify({
		"passed": passed,
		"frames": frame_count,
		"fps": 60,
		"stride_px": STRIDE,
		"final_distance": view.distance,
		"minimum_triangle_ratio": view.minimum_ratio,
		"maximum_contact_drift_px": view.native_contact,
		"worst": view.worst,
		"stance_samples": view.stance_samples,
		"view_changes": view.view_changes,
		"maximum_contact_correction_px": view.correction_peak,
		"maximum_visual_path_deviation_px": view.maximum_path_deviation,
	}, "  ") + "\n")
	proof.close()
	print("BOAR_GAIT frames=", frame_count, " minimum_ratio=", view.minimum_ratio,
		" contact=", view.native_contact, " switches=", view.view_changes.size(), " passed=", passed)
	quit(0 if passed else 1)
