extends SceneTree
const CandidateView = preload("C:/Projet/For the Fortress!/design/essais/animation_loup_24_poses/candidate_view.gd")
const Simulation = preload("res://scripts/valley_model.gd")
class Labels extends Node2D:
	var zoom := false
	func _draw() -> void:
		var font := ThemeDB.fallback_font
		draw_string(font,Vector2(30,42),"Loup · Candidat de marche, 24 poses",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("e0dbbf"))
		draw_string(font,Vector2(30,74),"Essai visuel hors production · Trajet du jeu · Aucun profil chargé",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("adc4b3"))
		draw_string(font,Vector2(30,765),"Agrandissement ×3" if zoom else "Taille du plateau",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("e5c779"))
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	root.size=Vector2i(1280,800)
	var model := Simulation.new()
	model.wave=4
	model.spawn_schedule.assign([{"time":0.0,"type":0},{"time":1.0,"type":0},{"time":2.0,"type":0}])
	assert(model.start())
	var view := CandidateView.new();view.model=model;root.add_child(view);view.set_process(false)
	var labels := Labels.new();root.add_child(labels)
	var directory := "C:/Projet/.tools/wolf24_candidate/frames"
	DirAccess.make_dir_recursive_absolute(directory)
	for frame in range(480):
		if frame==240:
			labels.zoom=true;model.reset();model.wave=4
			model.spawn_schedule.assign([{"time":0.0,"type":0},{"time":1.0,"type":0},{"time":2.0,"type":0}]);assert(model.start())
		model.advance(1.0/60.0)
		if labels.zoom:
			view.scale=Vector2.ONE*3.0
			view.position=Vector2(640,430)-CandidateView.project(model.point_on_path(model.enemies[0].distance))*3.0
		view.queue_redraw();labels.queue_redraw()
		await process_frame;await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(directory+"/%03d.png"%frame)==OK)
	print("WOLF24_CANDIDATE frames=480 capture_fps=60 poses=24 cadence_at_normal_speed=24 duration=8 profile_loaded=false production_changed=false")
	quit()
