extends SceneTree

const View = preload("res://scripts/valley_view.gd")
const Model = View.Model

class CrossbowPreview extends View:
	var shot: Dictionary

	func _draw_illustrated_defender(center: Vector2, type: int, pose: Dictionary, art: GDScript) -> void:
		var age: float = model.elapsed-shot.time
		if type == 1 and age < 0.0:
			pose = pose.duplicate()
			pose.direction = shot_facing(shot)
		super._draw_illustrated_defender(center, type, pose, art)

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(1280,800)
	var right := "--right" in OS.get_cmdline_user_args()
	var repeat := "--repeat" in OS.get_cmdline_user_args()
	var view := CrossbowPreview.new()
	view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	view.font = ThemeDB.fallback_font
	view.model = Model.new()
	view.model.select_faction(0)
	var slot := 1 if right else 0
	view.model.buy(slot,1)
	if repeat:
		view.model.bonuses.append(1)
	view.model.start()
	for step in range(2000):
		view.model.advance(0.01)
		if not view.model.shots.is_empty(): break
	assert(not view.model.shots.is_empty())
	view.shot = view.model.shots[0]
	assert(view.shot.type == 1 and View.shot_facing(view.shot) == (1.0 if right else -1.0))
	root.add_child(view)
	view.set_process(false)
	var output := ProjectSettings.globalize_path("user://qa_crossbow_reload_right" if right else "user://qa_crossbow_reload_left")
	if repeat:
		output += "_repeat"
	DirAccess.make_dir_recursive_absolute(output)
	var frame_count := 240 if repeat else 60
	var last_shot_time: float = view.shot.time
	var reloaded := false
	var recovered := false
	var complete_cycles := 0
	for frame in range(frame_count):
		if repeat:
			view.model.advance(2.0/60.0)
			var latest: Dictionary = view.model.shots.back()
			if latest.time != last_shot_time:
				assert(reloaded and recovered)
				complete_cycles += 1
				last_shot_time = latest.time
				reloaded = false
				recovered = false
			var pose := view.defender_pose(slot)
			if pose.get("crossbow_reload", false):
				reloaded = true
			elif reloaded:
				recovered = true
		else:
			view.model.elapsed = view.shot.time+(frame-12)/60.0
		view.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var status := root.get_texture().get_image().save_png(output.path_join("%04d.png" % frame))
		if status != OK:
			quit(status)
			return
	assert(not repeat or complete_cycles >= 2)
	print("CROSSBOW_RELOAD frames=", frame_count, " facing=", View.shot_facing(view.shot), " complete_cycles=", complete_cycles, " output=", output)
	quit()
