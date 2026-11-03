extends SceneTree
## Deterministic visual recording using the real game scene, no player profile.
const Main=preload("res://scripts/main.gd")
const Model=preload("res://scripts/valley_model.gd")
const Walk=preload("res://scripts/enemy_walk_art.gd")
const View=preload("res://scripts/valley_view.gd")
var front_candidate: ImageTexture
var rear_candidate: ImageTexture
func _initialize() -> void: call_deferred("record")
func record() -> void:
	root.size=Vector2i(1280,800)
	var game:=Main.new();root.add_child(game);game.set_process(false)
	assert(game.meta_profile == null or game.meta_profile.path.is_empty())
	game._choose_faction(0);game.model.buy(0,0);game.model.phase="combat"
	game.model.enemies.clear();game.model.spawn_schedule.clear()
	var preview := "--wolf-pivot" in OS.get_cmdline_user_args()
	var start_distances: Array[float] = []
	if preview:
		var corner_distance := 0.0
		for corner in range(1, game.model.path_points.size()-1):
			corner_distance += game.model.path_points[corner-1].distance_to(game.model.path_points[corner])
			start_distances.append(corner_distance-1.0)
	else:
		for index in range(8):
			start_distances.append(1.0+index*2.5)
	for index in range(start_distances.size()):
		var enemy: Dictionary=Model.make_enemy(index,0,0.0,0)
		enemy.distance=start_distances[index]
		game.model.enemies.append(enemy)
	game.model.spawned=start_distances.size()
	if preview:
		var folder := ProjectSettings.globalize_path("res://../design/essais/loup_virages")
		front_candidate = ImageTexture.create_from_image(Image.load_from_file(folder.path_join("loup_face_candidat_v001.png")))
		rear_candidate = ImageTexture.create_from_image(Image.load_from_file(folder.path_join("loup_dos_candidat_v001.png")))
		game.map_view.wolf_turn_preview = preview_pose
	report_corner_displacement(game.model.path_points)
	var directory:=ProjectSettings.globalize_path("user://qa_wolf_pivot" if preview else "user://qa_wolf_ingame")
	DirAccess.make_dir_recursive_absolute(directory)
	for frame in range(144):
		for enemy in game.model.enemies: enemy.distance+=enemy.speed/60.0
		game.model.elapsed=frame/60.0;game._update_interface();game.map_view.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(directory.path_join("%04d.png"%frame))==OK)
	print("WOLF_GAME_RECORDING frames=144 isolated=",game.meta_profile==null," directory=",directory)
	quit()

# Compare the same gait phase on both sides of each corner, isolating orientation.
func report_corner_displacement(points: Array[Vector2]) -> void:
	var distance := 0.0
	for corner in range(1, points.size()-1):
		distance += points[corner-1].distance_to(points[corner])
		report_rounded_corner(corner, points[corner-1], points[corner], points[corner+1])
		var incoming: Vector2 = Walk.path_motion(distance-0.0001, points, View.AXIS).direction
		var outgoing: Vector2 = Walk.path_motion(distance+0.0001, points, View.AXIS).direction
		var trial_incoming := trial_direction(-0.0001, incoming, outgoing)
		var trial_outgoing := trial_direction(0.0001, incoming, outgoing)
		print("WOLF_TRIAL corner=%d remaining_turn_deg=%.1f" % [
			corner, absf(rad_to_deg(trial_incoming.angle_to(trial_outgoing)))])
		if incoming.x*outgoing.x > 0.0:
			report_pivot_slip(corner, distance, points)
		var max_jump := 0.0
		for step in range(16):
			var before := Walk.sample_vertices(step/16.0, incoming)
			var after := Walk.sample_vertices(step/16.0, outgoing)
			for index in range(before.size()):
				var a := before[index]*Vector2(signf(incoming.x), 1.0)
				var b := after[index]*Vector2(signf(outgoing.x), 1.0)
				max_jump = maxf(max_jump, a.distance_to(b))
		print("WOLF_CORNER index=%d turn_deg=%.1f max_unscaled_vertex_jump_px=%.2f" % [
			corner, absf(rad_to_deg(incoming.angle_to(outgoing))), max_jump])

# Evaluate a rigid pivot over 0.4 route units around the corner.
func trial_direction(offset: float, incoming: Vector2, outgoing: Vector2) -> Vector2:
	if incoming.x*outgoing.x <= 0.0:
		return incoming if offset < 0.0 else outgoing
	return incoming.slerp(outgoing, smoothstep(-0.2, 0.2, offset))

func preview_direction(distance: float, points: Array[Vector2]) -> Vector2:
	var corner_distance := 0.0
	for corner in range(1, points.size()-1):
		corner_distance += points[corner-1].distance_to(points[corner])
		var offset := distance-corner_distance
		if absf(offset) < 0.2:
			var incoming: Vector2 = Walk.path_motion(corner_distance-0.0001, points, View.AXIS).direction
			var outgoing: Vector2 = Walk.path_motion(corner_distance+0.0001, points, View.AXIS).direction
			return trial_direction(offset, incoming, outgoing)
	return Walk.path_motion(distance, points, View.AXIS).direction

func report_pivot_slip(corner: int, distance: float, points: Array[Vector2]) -> void:
	var max_slip := 0.0
	var max_world_slip := 0.0
	var radii := [0.3, 0.45, 0.6, 0.75]
	var rounded_slip := [0.0, 0.0, 0.0, 0.0]
	var rounded_anchors := [{}, {}, {}, {}]
	var max_single_anchor_slip := 0.0
	var max_translation := 0.0
	var inverted_triangles := 0
	var anchors := {}
	var remaining := distance-0.85
	var segment := 0
	while remaining >= points[segment].distance_to(points[segment+1]):
		remaining -= points[segment].distance_to(points[segment+1])
		segment += 1
	var stance_starts := [62.0, 52.0, 34.0, 20.0]
	var stance_lengths := [37.0, 39.0, 34.0, 39.0]
	for step in range(171):
		var sample_distance := distance-0.85+step*0.01
		var offset := remaining+step*0.01
		while offset >= points[segment].distance_to(points[segment+1]):
			remaining -= points[segment].distance_to(points[segment+1])
			offset = remaining+step*0.01
			segment += 1
		var center := View.project(points[segment].move_toward(points[segment+1], offset))
		var motion: Dictionary = Walk.path_motion(sample_distance, points, View.AXIS)
		var phase := Walk.phase_for(motion.travel, 0, 0.7)
		var reference := Walk.sample_vertices(phase, motion.direction)
		var pivot := Walk.sample_vertices(phase, preview_direction(sample_distance, points))
		var rounded_positions: Array[PackedVector2Array] = []
		var rounded_phases := PackedFloat32Array()
		for radius in radii:
			var rounded := preview_pose(sample_distance, points, radius)
			var rounded_phase := Walk.phase_for(rounded.get("travel", motion.travel), 0, 0.7)
			rounded_phases.append(rounded_phase)
			var vertices := Walk.sample_vertices(rounded_phase, rounded.get("direction", motion.direction))
			var origin: Vector2 = rounded.get("center", center)
			for index in range(vertices.size()):
				vertices[index] = origin+vertices[index]*Vector2(signf(motion.direction.x), 1.0)*0.7
			rounded_positions.append(vertices)
		var planted := PackedVector2Array()
		var corrections := {}
		for group in range(4):
			var stance_phase := fposmod(phase-stance_starts[group]/64.0, 1.0)
			if stance_phase < stance_lengths[group]/64.0:
				var index: int = Walk.DATA.feet.find(group)
				var position := center+pivot[index]*Vector2(signf(motion.direction.x), 1.0)*0.7
				if not anchors.has(group):
					anchors[group] = position
				var error: Vector2 = position-anchors[group]
				planted.append(error)
				corrections[group] = -error*Vector2(signf(motion.direction.x), 1.0)/0.7
				max_world_slip = maxf(max_world_slip, error.length())
				max_slip = maxf(max_slip, reference[index].distance_to(pivot[index])*0.7)
			else:
				anchors.erase(group)
			for trial in range(radii.size()):
				var rounded_stance := fposmod(rounded_phases[trial]-stance_starts[group]/64.0, 1.0)
				if rounded_stance >= stance_lengths[group]/64.0:
					rounded_anchors[trial].erase(group)
					continue
				var foot: int = Walk.DATA.feet.find(group)
				var rounded_position := rounded_positions[trial][foot]
				if not rounded_anchors[trial].has(group):
					rounded_anchors[trial][group] = rounded_position
				rounded_slip[trial] = maxf(rounded_slip[trial], rounded_position.distance_to(rounded_anchors[trial][group]))

		inverted_triangles += count_pivot_inversions(pivot, corrections)
		if not planted.is_empty():
			var translation := planted[0]
			max_translation = maxf(max_translation, translation.length())
			for error in planted:
				max_single_anchor_slip = maxf(max_single_anchor_slip, (error-translation).length())
	for trial in range(radii.size()):
		print("WOLF_ROUNDED_STANCE corner=%d radius=%.2f max_world_drift_px=%.2f" % [
			corner, radii[trial], rounded_slip[trial]])
	print("WOLF_LOCAL_ANCHORS corner=%d inverted_triangle_samples=%d" % [corner, inverted_triangles])
	print("WOLF_SINGLE_ANCHOR corner=%d other_paws_max_drift_px=%.2f max_body_shift_px=%.2f" % [
		corner, max_single_anchor_slip, max_translation])
	print("WOLF_PIVOT_STANCE corner=%d max_offset_from_reference_px=%.2f max_world_drift_px=%.2f" % [
		corner, max_slip, max_world_slip])

# Check whether the existing skin tolerates corrections confined to the lower legs.
func count_pivot_inversions(vertices: PackedVector2Array, corrections: Dictionary) -> int:
	var corrected := vertices.duplicate()
	for index in range(vertices.size()):
		var uv: Vector2 = Walk.DATA.uv[index]
		var group := (0 if uv.x > 850.0/1536.0 else 1) + (2 if Walk.DATA.colors[index].r < 0.9 else 0)
		var correction: Vector2 = corrections.get(group, Vector2.ZERO)
		corrected[index] += correction*smoothstep(760.0, 900.0, uv.y*1024.0)
	var inverted := 0
	for triangle in range(0, Walk.DATA.indices.size(), 3):
		var a: int = Walk.DATA.indices[triangle]
		var b: int = Walk.DATA.indices[triangle+1]
		var c: int = Walk.DATA.indices[triangle+2]
		var before := (vertices[b]-vertices[a]).cross(vertices[c]-vertices[a])
		var after := (corrected[b]-corrected[a]).cross(corrected[c]-corrected[a])
		if before*after < 0.0:
			inverted += 1
	return inverted

# Measure how far a quadratic corner cut moves the visual center off the route.
func report_rounded_corner(corner: int, previous: Vector2, vertex: Vector2, next: Vector2) -> void:
	var start := View.project(vertex.move_toward(previous, 0.45))
	var control := View.project(vertex)
	var finish := View.project(vertex.move_toward(next, 0.45))
	var maximum := 0.0
	for step in range(33):
		var phase := step/32.0
		var point := start.lerp(control, phase).lerp(control.lerp(finish, phase), phase)
		var on_incoming := Geometry2D.get_closest_point_to_segment(point, start, control)
		var on_outgoing := Geometry2D.get_closest_point_to_segment(point, control, finish)
		maximum = maxf(maximum, minf(point.distance_to(on_incoming), point.distance_to(on_outgoing)))
	print("WOLF_ROUNDED_ROUTE corner=%d max_centerline_offset_px=%.2f" % [corner, maximum])

func preview_pose(distance: float, points: Array[Vector2], radius: float = 0.45) -> Dictionary:
	var corner_distance := 0.0
	for corner in range(1, points.size()-1):
		var vertex := points[corner]
		corner_distance += points[corner-1].distance_to(vertex)
		var offset := distance-corner_distance
		if absf(offset) < radius:
			var start := View.project(vertex.move_toward(points[corner-1], radius))
			var middle := View.project(vertex)
			var finish := View.project(vertex.move_toward(points[corner+1], radius))
			var phase := inverse_lerp(-radius, radius, offset)
			var a := start.lerp(middle, phase)
			var b := middle.lerp(finish, phase)
			var direction := preview_direction(distance, points)
			if (middle-start).x*(finish-middle).x > 0.0:
				direction = (b-a).normalized()
			var travel: float = Walk.path_motion(distance, points, View.AXIS).travel
			var partial_arc := 0.0
			var full_arc := 0.0
			var previous := start
			for step in range(1, 17):
				var t := step/16.0
				var position := start.lerp(middle, t).lerp(middle.lerp(finish, t), t)
				var length := previous.distance_to(position)
				full_arc += length
				partial_arc += length*clampf((phase-(t-1.0/16.0))*16.0, 0.0, 1.0)
				previous = position
			travel += partial_arc-full_arc*phase
			var result := {"center": a.lerp(b, phase), "direction": direction, "travel": travel}
			if front_candidate != null and (middle-start).x*(finish-middle).x < 0.0 and absf(phase-0.5) < 0.14:
				var towards := (b-a).y > 0.0
				var source := Rect2(265, 23, 607, 1186) if towards else Rect2(389, 76, 391, 1095)
				var size := source.size*(34.0/source.size.y)
				result["texture"] = front_candidate if towards else rear_candidate
				result["source"] = source
				result["destination"] = Rect2(Vector2(-size.x/2.0, -size.y+4.0), size)
			return result
	return {}
