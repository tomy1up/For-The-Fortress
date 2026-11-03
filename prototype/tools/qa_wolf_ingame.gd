extends SceneTree
## Deterministic visual recording using the real game scene, no player profile.
const Main=preload("res://scripts/main.gd")
const Model=preload("res://scripts/valley_model.gd")
const Walk=preload("res://scripts/enemy_walk_art.gd")
const View=preload("res://scripts/valley_view.gd")
func _initialize() -> void: call_deferred("record")
func record() -> void:
	root.size=Vector2i(1280,800)
	var game:=Main.new();root.add_child(game);game.set_process(false)
	assert(game.meta_profile == null or game.meta_profile.path.is_empty())
	game._choose_faction(0);game.model.buy(0,0);game.model.phase="combat"
	game.model.enemies.clear();game.model.spawn_schedule.clear()
	for index in range(8):
		var enemy: Dictionary=Model.make_enemy(index,0,0.0,0)
		enemy.distance=1.0+index*2.5;game.model.enemies.append(enemy)
	game.model.spawned=8
	report_corner_displacement(game.model.path_points)
	var directory:=ProjectSettings.globalize_path("user://qa_wolf_ingame")
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
		var incoming: Vector2 = Walk.path_motion(distance-0.0001, points, View.AXIS).direction
		var outgoing: Vector2 = Walk.path_motion(distance+0.0001, points, View.AXIS).direction
		var trial_incoming := trial_direction(-0.0001, incoming, outgoing)
		var trial_outgoing := trial_direction(0.0001, incoming, outgoing)
		print("WOLF_TRIAL corner=%d remaining_turn_deg=%.1f" % [
			corner, absf(rad_to_deg(trial_incoming.angle_to(trial_outgoing)))])
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
