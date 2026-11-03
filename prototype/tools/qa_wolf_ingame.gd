extends SceneTree
## Deterministic visual recording using the real game scene, no player profile.
const Main=preload("res://scripts/main.gd")
const Model=preload("res://scripts/valley_model.gd")
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
	var directory:=ProjectSettings.globalize_path("user://qa_wolf_ingame")
	DirAccess.make_dir_recursive_absolute(directory)
	for frame in range(144):
		for enemy in game.model.enemies: enemy.distance+=enemy.speed/60.0
		game.model.elapsed=frame/60.0;game._update_interface();game.map_view.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(directory.path_join("%04d.png"%frame))==OK)
	print("WOLF_GAME_RECORDING frames=144 isolated=",game.meta_profile==null," directory=",directory)
	quit()
