extends SceneTree

const View = preload("res://scripts/valley_view.gd")
const Model = View.Model

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(1280,800)
	var board := Model.Maps.mountain_workshop()
	var model := Model.new(true,board)
	assert(model.map_definition.decoration == "mountain" and model.routes.size() == 2)
	assert(model.routes[0].path_length == 28.0 and model.routes[1].path_length == 33.0)
	var view := View.new()
	view.model = model
	view.font = ThemeDB.fallback_font
	view.highlighted_entries.assign([0,1])
	root.add_child(view)
	view.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var output := ProjectSettings.globalize_path("user://qa_col_des_ardoises.png")
	var result := root.get_texture().get_image().save_png(output)
	print("MOUNTAIN_CAPTURE=",output)
	quit(result)
