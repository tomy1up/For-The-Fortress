extends SceneTree
## Deterministic visual recording using the real game scene, no player profile.
const Main=preload("res://scripts/main.gd")
const Model=preload("res://scripts/valley_model.gd")
const Walk=preload("res://scripts/enemy_walk_art.gd")
const View=preload("res://scripts/valley_view.gd")
const STANCE_STARTS := [62.0, 52.0, 34.0, 20.0]
const STANCE_LENGTHS := [37.0, 39.0, 34.0, 39.0]
var minimum_turn_triangle_area := INF
var capture_frame := 0
var turn_contacts := {}
var max_turn_contact_drift := 0.0
var max_uncorrected_contact_drift := 0.0
var min_contact_correction_weight := 1.0
var max_contact_step := 0.0
var max_contact_switch := 0.0
var corrected_contacts := {}
var max_corrected_switch := 0.0
var max_corrected_step := 0.0
var worst_contact_switch := {}
var use_quarters := true
var front_half_window := 0.10
var previous_front := false
var turn_meshes: Array[ArrayMesh] = []
var rear_quarter_candidate: ImageTexture
var quarter_candidate: ImageTexture
var front_candidate: ImageTexture
var rear_candidate: ImageTexture
func _initialize() -> void: call_deferred("record")
func record() -> void:
	root.size=Vector2i(1280,800)
	var game:=Main.new();root.add_child(game);game.set_process(false)
	assert(game.meta_profile == null or game.meta_profile.path.is_empty())
	var faction := 1 if "--horde" in OS.get_cmdline_user_args() else 0
	game._choose_faction(faction);game.model.buy(0,0);game.model.phase="combat"
	game.model.enemies.clear();game.model.spawn_schedule.clear()
	var preview := "--wolf-pivot" in OS.get_cmdline_user_args()
	var hit_preview := "--wolf-hit" in OS.get_cmdline_user_args()
	previous_front = "--previous-front" in OS.get_cmdline_user_args()
	var id_offset := 0
	use_quarters = not "--no-quarters" in OS.get_cmdline_user_args()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--front-window="):
			front_half_window = clampf(argument.trim_prefix("--front-window=").to_float(), 0.04, 0.20)
		if argument.begins_with("--id-offset="):
			id_offset = maxi(0, argument.trim_prefix("--id-offset=").to_int())
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
		var enemy: Dictionary=Model.make_enemy(index+id_offset,0,0.0,faction)
		enemy.distance=start_distances[index]
		game.model.enemies.append(enemy)
	game.model.spawned=start_distances.size()
	if preview:
		var folder := ProjectSettings.globalize_path("res://../design/essais/loup_virages")
		rear_quarter_candidate = load_turn_texture(folder.path_join("loup_trois_quarts_arriere_v001.png"))
		quarter_candidate = load_turn_texture(folder.path_join("loup_trois_quarts_avant_v002.png"))
		var front_file := "loup_face_candidat_v002.png" if previous_front else "loup_face_candidat_v003.png"
		front_candidate = load_turn_texture(folder.path_join(front_file))
		rear_candidate = load_turn_texture(folder.path_join("loup_dos_candidat_v001.png"))
		game.map_view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		game.map_view.wolf_turn_preview = preview_enemy_pose
	report_corner_displacement(game.model.path_points)
	var directory:=ProjectSettings.globalize_path("user://qa_wolf_pivot" if preview else "user://qa_wolf_ingame")
	if hit_preview:
		directory += "_hit"
	if preview and not use_quarters:
		directory += "_without_quarters"
	if faction == 1:
		directory += "_horde"
	if preview and previous_front:
		directory += "_previous_front"
	if id_offset != 0:
		directory += "_offset_%d" % id_offset
	DirAccess.make_dir_recursive_absolute(directory)
	for frame in range(144):
		for enemy in game.model.enemies: enemy.distance+=enemy.speed/60.0
		capture_frame = frame
		turn_meshes.clear()
		game.model.elapsed = frame/60.0
		if hit_preview and frame == 42:
			var damage := {}
			for enemy in game.model.enemies:
				damage[enemy.id] = enemy.max_hp*0.5
			game.model._apply_damage(damage)
			assert(game.model.damage_events.size() == game.model.enemies.size())
			print("WOLF_HITS events=", game.model.damage_events.size(), " faction=", faction)
		game._update_interface()
		game.map_view.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(directory.path_join("%04d.png"%frame))==OK)
	if preview:
		assert(is_finite(minimum_turn_triangle_area) and minimum_turn_triangle_area > 0.0)
		print("WOLF_TURN_CONTACT max_drift_px=%.3f before_translation_px=%.3f" % [max_turn_contact_drift, max_uncorrected_contact_drift])
		print("WOLF_TURN_STEPS same_pose_px=%.3f change_pose_px=%.3f" % [max_contact_step, max_contact_switch])
		print("WOLF_CORRECTED_STEPS same_pose_px=%.3f change_pose_px=%.3f" % [max_corrected_step, max_corrected_switch])
		print("WOLF_WORST_SWITCH ", JSON.stringify(worst_contact_switch))
		print("WOLF_CORRECTION min_weight=%.3f" % min_contact_correction_weight)
		print("WOLF_TURN_MESH min_triangle_double_area_px2=%.3f" % minimum_turn_triangle_area)
	print("WOLF_GAME_RECORDING frames=144 isolated=",game.meta_profile==null," faction=",faction," directory=",directory)
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
			var stance_phase := fposmod(phase-STANCE_STARTS[group]/64.0, 1.0)
			if stance_phase < STANCE_LENGTHS[group]/64.0:
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
				var rounded_stance := fposmod(rounded_phases[trial]-STANCE_STARTS[group]/64.0, 1.0)
				if rounded_stance >= STANCE_LENGTHS[group]/64.0:
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
	var travel: float = Walk.path_motion(distance, points, View.AXIS).travel
	for corner in range(1, points.size()-1):
		var vertex := points[corner]
		corner_distance += points[corner-1].distance_to(vertex)
		var offset := distance-corner_distance
		if offset < -radius:
			break
		var start := View.project(vertex.move_toward(points[corner-1], radius))
		var middle := View.project(vertex)
		var finish := View.project(vertex.move_toward(points[corner+1], radius))
		var phase := clampf(inverse_lerp(-radius, radius, offset), 0.0, 1.0)
		var a := start.lerp(middle, phase)
		var b := middle.lerp(finish, phase)
		var direction := preview_direction(distance, points)
		var tangent := (b-a).normalized()
		var changes_side := (middle-start).x*(finish-middle).x < 0.0
		if changes_side:
			# Tilt the side pose towards the curve, within its readable profile.
			var turn := clampf(direction.angle_to(tangent), -PI/15.0, PI/15.0)
			direction = direction.rotated(turn)
		else:
			direction = tangent
		var partial_arc := 0.0
		var previous := start
		for step in range(1, 17):
			var t := step/16.0
			var position := start.lerp(middle, t).lerp(middle.lerp(finish, t), t)
			var length := previous.distance_to(position)
			partial_arc += length*clampf((phase-(t-1.0/16.0))*16.0, 0.0, 1.0)
			previous = position
		var incoming_length := start.distance_to(middle)
		var outgoing_length := middle.distance_to(finish)
		travel += partial_arc-incoming_length*minf(phase*2.0, 1.0)
		travel -= outgoing_length*maxf(phase*2.0-1.0, 0.0)
		if phase >= 1.0:
			continue
		var result := {"center": a.lerp(b, phase), "direction": direction, "travel": travel}
		var towards := tangent.y > 0.0
		var turn_center := absf(phase-0.5)
		var quarter := use_quarters and turn_center >= (front_half_window if towards else 0.10)
		if front_candidate != null and changes_side and turn_center < (0.26 if use_quarters else 0.14):
			var source := Rect2(214, 272, 773, 672) if towards else Rect2(389, 76, 391, 1095)
			if towards and previous_front:
				source = Rect2(245, 12, 650, 1185)
			if quarter:
				source = Rect2(141, 274, 942, 652) if towards else Rect2(226, 61, 1092, 886)
			var image_scale := 34.0/1055.0 if quarter and towards else (34.0/1177.0 if towards else 34.0/source.size.y)
			var size := source.size*image_scale
			# Center on the visible diagonal support pair, independent of tail and ears.
			var support := Vector2(601, 866) if towards else Vector2(612, 895)
			if towards and previous_front:
				support = Vector2(525, 974)
			result["texture"] = front_candidate if towards else rear_candidate
			if quarter:
				support = Vector2(610, 880) if towards else Vector2(837, 831)
				result["texture"] = quarter_candidate if towards else rear_quarter_candidate
			result["quarter"] = quarter
			result["label"] = ("front" if towards else "rear") + ("_quarter" if quarter else "")
			result["facing"] = signf((middle-start).x) if towards else signf((finish-middle).x)
			if quarter:
				result["facing"] = signf(tangent.x)
			result["source"] = source
			result["destination"] = Rect2((source.position-support)*image_scale, size)
			result["towards"] = towards
		return result
	return {"travel": travel}

func preview_enemy_pose(distance: float, points: Array[Vector2], enemy_id: int, scale: float) -> Dictionary:
	var pose := preview_pose(distance, points)
	if pose.has("texture"):
		var mesh := animated_turn_mesh(pose, Walk.phase_for(pose.travel, enemy_id, scale), enemy_id, scale)
		turn_meshes.append(mesh)
		pose["mesh"] = mesh
	return pose

func animated_turn_mesh(pose: Dictionary, gait: float, enemy_id: int, scale: float) -> ArrayMesh:
	var source: Rect2 = pose.source
	var destination: Rect2 = pose.destination
	var texture: Texture2D = pose.texture
	var paws: Array = [Vector2(447, 780), Vector2(521, 707), Vector2(633, 820), Vector2(754, 913)] if pose.towards else [Vector2(650, 950), Vector2(505, 1140), Vector2(720, 612), Vector2(424, 710)]
	if pose.towards and previous_front:
		paws = [Vector2(350, 790), Vector2(500, 930), Vector2(574, 990), Vector2(700, 1180)]
	if pose.quarter:
		paws = [Vector2(420, 831), Vector2(497, 790), Vector2(643, 832), Vector2(798, 895)] if pose.towards else [Vector2(541, 915), Vector2(761, 786), Vector2(886, 687), Vector2(1134, 710)]
	# The drawings list the rear pair first. Select anatomical groups in
	# the same order as the side rig, accounting for the mirrored drawing.
	var groups := [1, 3, 0, 2] if pose.towards else [3, 1, 2, 0]
	if pose.quarter:
		groups = [1, 3, 0, 2]
	var offsets := PackedVector2Array()
	var forward: Vector2 = pose.direction*Vector2(pose.facing, 1.0)
	for foot in range(paws.size()):
		var group: int = groups[foot] ^ (2 if pose.facing < 0.0 else 0)
		var stance: float = STANCE_LENGTHS[group]/64.0
		var phase := fposmod(gait-STANCE_STARTS[group]/64.0, 1.0)
		var swing := clampf(inverse_lerp(stance, 1.0, phase), 0.0, 1.0)
		var step := lerpf(0.65, -0.65, phase/stance) if phase < stance else lerpf(-0.65, 0.65, smoothstep(0.0, 1.0, swing))
		offsets.append(forward*step-Vector2(0.0, pow(sin(PI*swing), 2.0)*1.15))
	var points := PackedVector2Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	const GRID := 24
	for row in range(GRID+1):
		for column in range(GRID+1):
			var relative := Vector2(column, row)/float(GRID)
			var pixel := source.position+relative*source.size
			var point := destination.position+relative*destination.size
			for index in range(paws.size()):
				var delta: Vector2 = (pixel-paws[index])/Vector2(52, 96)
				var influence := exp(-delta.length_squared()*1.5)
				point += offsets[index]*influence
			points.append(point)
			uvs.append(pixel/texture.get_size())
			if row < GRID and column < GRID:
				var a := row*(GRID+1)+column
				var b := a+GRID+1
				indices.append_array([a, a+1, b, a+1, b+1, b])
	var errors := PackedVector2Array()
	var contact_feet := PackedInt32Array()
	var contact_weights := PackedFloat32Array()
	var correction := Vector2.ZERO
	var total_contact_weight := 0.0
	for foot in range(paws.size()):
		var group: int = groups[foot] ^ (2 if pose.facing < 0.0 else 0)
		var phase := fposmod(gait-STANCE_STARTS[group]/64.0, 1.0)
		var key := Vector2i(enemy_id, group)
		if phase >= STANCE_LENGTHS[group]/64.0:
			turn_contacts.erase(key)
			continue
		var cell: Vector2 = (paws[foot]-source.position)/source.size*GRID
		var column := clampi(floori(cell.x), 0, GRID-1)
		var row := clampi(floori(cell.y), 0, GRID-1)
		var u := cell.x-column
		var v := cell.y-row
		var a := row*(GRID+1)+column
		var b := a+GRID+1
		var point := points[a]*(1.0-u-v)+points[a+1]*u+points[b]*v
		if u+v > 1.0:
			point = points[b+1]*(u+v-1.0)+points[a+1]*(1.0-v)+points[b]*(1.0-u)
		var position: Vector2 = pose.center+point*Vector2(pose.facing, 1.0)*scale
		var contact: Dictionary = turn_contacts.get(key, {})
		if contact.get("frame", -2) < capture_frame-1:
			contact = {"anchor": position}
		var error: Vector2 = position-contact.anchor
		errors.append(error)
		contact_feet.append(foot)
		var stance: float = STANCE_LENGTHS[group]/64.0
		var contact_weight := smoothstep(0.0, 0.08, minf(phase, stance-phase))
		contact_weights.append(contact_weight)
		total_contact_weight += contact_weight
		correction -= error*contact_weight
		max_uncorrected_contact_drift = maxf(max_uncorrected_contact_drift, error.length())
		if contact.get("frame", -2) == capture_frame-1:
			var step := position.distance_to(contact.position)
			if contact.texture == texture:
				max_contact_step = maxf(max_contact_step, step)
			elif step > max_contact_switch:
				max_contact_switch = step
				worst_contact_switch = {"from": contact.label, "to": pose.label, "group": group,
					"wolf": enemy_id, "frame": capture_frame, "dx": position.x-contact.position.x,
					"dy": position.y-contact.position.y}
		contact["frame"] = capture_frame
		contact["position"] = position
		contact["texture"] = texture
		contact["label"] = pose.label
		turn_contacts[key] = contact
	if not errors.is_empty():
		correction = (correction/maxf(1.0, total_contact_weight)).limit_length(2.0)
		var local_shift := correction*Vector2(pose.facing, 1.0)/scale
		var local_corrections := PackedVector2Array()
		var facing := Vector2(pose.facing, 1.0)
		for index in range(errors.size()):
			local_corrections.append(-(errors[index]+correction).limit_length(1.6)*facing/scale*contact_weights[index])
		var base_points := points.duplicate()
		for index in range(points.size()):
			var pixel := uvs[index]*texture.get_size()
			points[index] += local_shift
			for contact_index in range(contact_feet.size()):
				var delta: Vector2 = (pixel-paws[contact_feet[contact_index]])/Vector2(110, 210)
				points[index] += local_corrections[contact_index]*exp(-delta.length_squared()*1.5)
		var weight := 1.0
		for triangle in range(0, indices.size(), 3):
			var a := indices[triangle]
			var b := indices[triangle+1]
			var c := indices[triangle+2]
			var base_ab := base_points[b]-base_points[a]
			var base_ac := base_points[c]-base_points[a]
			var delta_ab := points[b]-points[a]-base_ab
			var delta_ac := points[c]-points[a]-base_ac
			var base_area := base_ab.cross(base_ac)
			var loss := absf(delta_ab.cross(base_ac)+base_ab.cross(delta_ac))+absf(delta_ab.cross(delta_ac))
			if loss > 0.0:
				weight = minf(weight, 0.8*base_area/loss)
		min_contact_correction_weight = minf(min_contact_correction_weight, weight)
		for index in range(points.size()):
			var translated := base_points[index]+local_shift
			points[index] = translated.lerp(points[index], weight)
		for contact_index in range(errors.size()):
			var cell: Vector2 = (paws[contact_feet[contact_index]]-source.position)/source.size*GRID
			var column := clampi(floori(cell.x), 0, GRID-1)
			var row := clampi(floori(cell.y), 0, GRID-1)
			var u := cell.x-column
			var v := cell.y-row
			var a := row*(GRID+1)+column
			var b := a+GRID+1
			var point := points[a]*(1.0-u-v)+points[a+1]*u+points[b]*v
			if u+v > 1.0:
				point = points[b+1]*(u+v-1.0)+points[a+1]*(1.0-v)+points[b]*(1.0-u)
			var group: int = groups[contact_feet[contact_index]] ^ (2 if pose.facing < 0.0 else 0)
			var anchor: Vector2 = turn_contacts[Vector2i(enemy_id, group)].anchor
			var world_point: Vector2 = pose.center+point*facing*scale
			max_turn_contact_drift = maxf(max_turn_contact_drift, world_point.distance_to(anchor))
			var key := Vector2i(enemy_id, group)
			var previous: Dictionary = corrected_contacts.get(key, {})
			if previous.get("frame", -2) == capture_frame-1:
				var step := world_point.distance_to(previous.position)
				if previous.texture == texture:
					max_corrected_step = maxf(max_corrected_step, step)
				else:
					max_corrected_switch = maxf(max_corrected_switch, step)
			corrected_contacts[key] = {"frame": capture_frame, "texture": texture, "position": world_point}

	for triangle in range(0, indices.size(), 3):
		var a := points[indices[triangle]]
		var b := points[indices[triangle+1]]
		var c := points[indices[triangle+2]]
		minimum_turn_triangle_area = minf(minimum_turn_triangle_area, (b-a).cross(c-a))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func load_turn_texture(path: String) -> ImageTexture:
	var source := Image.load_from_file(path)
	assert(source != null and not source.is_empty())
	var status := source.generate_mipmaps()
	assert(status == OK)
	return ImageTexture.create_from_image(source)
