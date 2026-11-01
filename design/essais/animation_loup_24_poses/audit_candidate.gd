extends SceneTree
const CandidateView = preload("C:/Projet/For the Fortress!/design/essais/animation_loup_24_poses/candidate_view.gd")
const Simulation = preload("res://scripts/valley_model.gd")
const OUTPUT := "C:/Projet/.tools/wolf24_candidate/audit"
var checks: Array[Dictionary] = []
func _initialize() -> void: call_deferred("audit")
func pixels(view: Node2D) -> Image:
	view.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()
func digest(picture: Image) -> String:
	return picture.get_data().hex_encode().sha256_text()
func verify(condition: bool, label: String) -> void:
	checks.append({"name":label,"passed":condition})
	if not condition: push_error(label)
func audit() -> void:
	root.size=Vector2i(1280,800)
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	for faction in [0,1]:
		var model := Simulation.new()
		verify(model.select_faction(faction),"faction_%d_selection"%faction)
		model.wave=4
		model.spawn_schedule.assign([{"time":0.0,"type":0}])
		verify(model.start(),"faction_%d_start"%faction)
		model.advance(0.45)
		var enemy: Dictionary=model.enemies[0]
		verify(CandidateView.enemy_art_id(enemy,faction)=="enemy.neutral.wolf","faction_%d_neutral_wolf_identity"%faction)
		var view := CandidateView.new();view.model=model;root.add_child(view);view.set_process(false)
		view.scale=Vector2.ONE*3.0
		view.position=Vector2(640,430)-CandidateView.project(model.point_on_path(enemy.distance))*3.0
		var baseline := await pixels(view)
		baseline.save_png(OUTPUT+"/faction_%d_normal.png"%faction)
		var distance: float=enemy.distance
		var stopped: bool=true
		for frame in range(12):
			stopped=stopped and digest(await pixels(view))==digest(baseline)
		verify(stopped and enemy.distance==distance,"faction_%d_pause_pixels_stable"%faction)
		view.inspected_enemy_id=enemy.id
		var inspected := await pixels(view)
		inspected.save_png(OUTPUT+"/faction_%d_inspection.png"%faction)
		verify(digest(inspected)!=digest(baseline),"faction_%d_inspection_visible"%faction)
		view.inspected_enemy_id=-1
		verify(digest(await pixels(view))==digest(baseline),"faction_%d_inspection_reversible"%faction)
		model.damage_events.assign([{"enemy_id":enemy.id,"time":model.elapsed-0.045,"hp_before":12.0,"hp_after":8.0}])
		var hit := await pixels(view)
		hit.save_png(OUTPUT+"/faction_%d_hit_fixture.png"%faction)
		verify(digest(hit)!=digest(baseline) and enemy.distance==distance,"faction_%d_hit_visible_without_logical_displacement"%faction)
		model.damage_events.clear()
		verify(digest(await pixels(view))==digest(baseline),"faction_%d_hit_reversible"%faction)
		model.advance(0.25)
		verify(digest(await pixels(view))!=digest(baseline) and enemy.distance>distance,"faction_%d_resume_changes_position_and_image"%faction)
		model.advance(3.0)
		view.position=Vector2(640,430)-CandidateView.project(model.point_on_path(enemy.distance))*3.0
		var facing := CandidateView.enemy_facing(enemy,model.path_points,model.path_length)
		verify(facing<0.0,"faction_%d_turn_left"%faction)
		(await pixels(view)).save_png(OUTPUT+"/faction_%d_left.png"%faction)
		root.remove_child(view);view.queue_free();await process_frame
	var failed: int=checks.filter(func(check: Dictionary)->bool:return not check.passed).size()
	var report := {"checks":checks,"passed":checks.size()-failed,"failed":failed,"scope":"isolated visual workshop; two factions; pause, inspection, injected visual hit fixture, resume, left turn; not an artistic approval or full game regression","profile_loaded":false}
	var file := FileAccess.open(OUTPUT+"/report.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"));file.close()
	print("WOLF24_VISUAL_AUDIT passed=",checks.size()-failed," failed=",failed)
	quit(0 if failed==0 else 1)
