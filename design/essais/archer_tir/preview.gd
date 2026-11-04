extends SceneTree
const View = preload("res://scripts/valley_view.gd")
const Model = View.Model

class ArcherPreview extends View:
	var release_texture: ImageTexture
	var reload_texture: ImageTexture
	var nock_texture: ImageTexture
	var shot_time := INF

	func _draw_illustrated_defender(center: Vector2, type: int, pose: Dictionary, art: GDScript) -> void:
		var age: float = model.elapsed-shot_time
		if type == 0 and age < 0.0:
			pose = pose.duplicate()
			pose.direction = shot_facing(model.shots[0])
		if type != 0 or age < 0.0 or age >= 0.52:
			super._draw_illustrated_defender(center, type, pose, art)
			return
		draw_set_transform(center+Vector2(0,2),0,Vector2(1,0.45))
		draw_circle(Vector2.ZERO,12,Color(0,0,0,0.25),true,-1,true)
		var transform := attack_transform(type, pose)
		transform.origin += center
		draw_set_transform_matrix(transform)
		# Both sprites use the original canvas, crop and foot anchor.
		var texture := release_texture if age < 0.14 else reload_texture if age < 0.38 else nock_texture
		draw_texture_rect_region(texture, art.destination(type), art.FRAMES[type].source)
		draw_set_transform(Vector2.ZERO)

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(1280,800)
	var view := ArcherPreview.new()
	var folder := ProjectSettings.globalize_path("res://../design/essais/archer_tir")
	view.release_texture = load_pose(folder.path_join("archer_lacher_v001.png"))
	view.reload_texture = load_pose(folder.path_join("archer_rearmement_v001.png"))
	view.nock_texture = load_pose(folder.path_join("archer_encochage_v001.png"))
	view.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	view.font = ThemeDB.fallback_font
	view.model = Model.new()
	view.model.select_faction(0)
	view.model.buy(0,0)
	view.model.start()
	for step in range(2000):
		view.model.advance(0.01)
		if not view.model.shots.is_empty():
			break
	assert(not view.model.shots.is_empty() and view.model.shots[0].type == 0)
	view.shot_time = view.model.shots[0].time
	root.add_child(view)
	view.set_process(false)
	var output := ProjectSettings.globalize_path("user://qa_archer_lacher")
	DirAccess.make_dir_recursive_absolute(output)
	for frame in range(48):
		view.model.elapsed = view.shot_time+(frame-12)/60.0
		view.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var status := root.get_texture().get_image().save_png(output.path_join("%04d.png" % frame))
		if status != OK:
			quit(status)
			return
	print("ARCHER_RELEASE frames=48 shot_time=", view.shot_time, " output=", output)
	quit()

func load_pose(path: String) -> ImageTexture:
	var image := Image.load_from_file(path)
	assert(image != null and image.get_size() == Vector2i(1263,1246))
	assert(image.generate_mipmaps() == OK)
	return ImageTexture.create_from_image(image)
