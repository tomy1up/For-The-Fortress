extends SceneTree
## Géométrie réservée aux tests ; ce script est exclu de la distribution.
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const Fixture = preload("res://tests/test_map_definition.gd")
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	var output: String = ""
	var faction: int = 0
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=")
		if argument == "--faction=horde": faction = 1
	assert(not output.is_empty())
	var scene = Main.new();scene.model = Model.new(true,Fixture.synthetic());root.add_child(scene);scene.set_process(false);scene._choose_faction(faction)
	scene._select_slot(2);scene.buy_buttons[0].mouse_entered.emit()
	assert(scene.meta_profile == null and scene.model.next_instance_id == 0)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output) == OK)
	print("MAP_CAPTURE=",JSON.stringify({"map":scene.model.map_definition.id,"faction":faction,"slots":scene.model.slots.size(),"path_length":scene.model.path_length,"profile_isolated":scene.meta_profile == null,"ghost_type":scene.map_view.purchase_ghost().type,"instances":scene.model.next_instance_id}))
	scene.free();quit()
