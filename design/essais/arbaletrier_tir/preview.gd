extends SceneTree

const View = preload("res://scripts/valley_view.gd")
const Model = View.Model

class CrossbowPreview extends View:
	var reload_texture: ImageTexture
	var shot: Dictionary

	func _draw_illustrated_defender(center: Vector2, type: int, pose: Dictionary, art: GDScript) -> void:
		var age: float = model.elapsed-shot.time
		if type == 1 and age < 0.0:
			pose = pose.duplicate()
			pose.direction = shot_facing(shot)
		if type != 1 or age < 0.14 or age >= 0.62:
			super._draw_illustrated_defender(center, type, pose, art)
			return
		draw_set_transform(center+Vector2(0,2),0,Vector2(1,0.45))
		draw_circle(Vector2.ZERO,12,Color(0,0,0,0.25),true,-1,true)
		draw_set_transform(center,0,Vector2(shot_facing(shot),1))
		draw_texture_rect_region(reload_texture, art.destination(type), art.FRAMES[type].source)
		draw_set_transform(Vector2.ZERO)

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(1280,800)
	var right := "--right" in OS.get_cmdline_user_args()
	var view := CrossbowPreview.new()
	var image := Image.load_from_file(ProjectSettings.globalize_path("res://../design/essais/arbaletrier_tir/arbaletrier_rearmement_v001.png"))
	assert(image != null and image.get_size() == Vector2i(1261,1247))
	assert(image.generate_mipmaps() == OK)
	view.reload_texture = ImageTexture.create_from_image(image)
	view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	view.font = ThemeDB.fallback_font
	view.model = Model.new()
	view.model.select_faction(0)
	view.model.buy(1 if right else 0,1)
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
	DirAccess.make_dir_recursive_absolute(output)
	for frame in range(60):
		view.model.elapsed = view.shot.time+(frame-12)/60.0
		view.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var status := root.get_texture().get_image().save_png(output.path_join("%04d.png" % frame))
		if status != OK:
			quit(status)
			return
	print("CROSSBOW_RELOAD frames=60 facing=", View.shot_facing(view.shot), " output=", output)
	quit()
