extends SceneTree
const CandidateMain=preload("C:/Projet/For the Fortress!/design/essais/animation_loup_24_poses/play_candidate_main.gd")
func _initialize() -> void: call_deferred("start_workshop")
func start_workshop() -> void:
	root.size=Vector2i(1280,800)
	var game:=CandidateMain.new()
	root.add_child(game)
	for argument in OS.get_cmdline_user_args():
		if not argument.begins_with("--check-candidate="): continue
		var faction: int=1 if argument.ends_with("horde") else 0
		game.set_process(false);game._choose_faction(faction)
		game.model.wave=4
		game.model.spawn_schedule=CandidateMain.Model.Campaign.schedule(4)
		assert(game.model.start());game.model.advance(15.0);game._update_interface()
		await process_frame;await RenderingServer.frame_post_draw
		var wolves: int=game.model.enemies.filter(func(enemy: Dictionary)->bool:return enemy.type==0).size()
		assert(wolves>0 and game.meta_profile==null and game.map_view.candidate!=null)
		var path: String="C:/Projet/.tools/wolf24_candidate/playable_wolves_%s.png"%("horde" if faction==1 else "alliance")
		assert(root.get_texture().get_image().save_png(path)==OK)
		print("WOLF24_CHECK=",JSON.stringify({"faction":faction,"wolves":wolves,"profile_loaded":game.meta_profile!=null,"candidate_enabled":true,"capture":path}))
		game.free();quit();return
