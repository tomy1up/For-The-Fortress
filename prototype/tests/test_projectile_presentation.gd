extends SceneTree
const Main = preload("res://scripts/main.gd")
const View = preload("res://scripts/valley_view.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.defenders,scene.model.shots])
func run_checks() -> void:
	for type in range(6):
		var delayed: float = View.launch_delay({"type":type})
		check(is_equal_approx(delayed,0.12 if type in [4,5] else 0.0),"Seuls le sapeur gobelin et le chaman orc différeront leur lâcher de 0,12 s (type %d)" % type)
	var shaman_shot: Dictionary = {"type":5,"from":Vector2(2,6),"to":Vector2(3,3),"secondary":[]}
	check(is_equal_approx(View.shot_origin(shaman_shot).x-View.project(shaman_shot.from).x,51.625) and is_equal_approx(View.shot_origin(shaman_shot).y-View.project(shaman_shot.from).y,-58.875),"Départ visuel de l’éclair du chaman à (±51,625, −58,875) des pieds")
	check(is_equal_approx(View.curse_applied_at({"next_at":11.0,"ticks_left":2}),10.0) and is_equal_approx(View.curse_applied_at({"next_at":12.0,"ticks_left":1}),10.0),"L’instant de pose de la malédiction se déduit de ses tics")
	var sapper_right: Dictionary = {"type":4,"from":Vector2(2,6),"to":Vector2(3,3),"secondary":[]}
	var sapper_left: Dictionary = {"type":4,"from":Vector2(3,3),"to":Vector2(2,6),"secondary":[]}
	check(is_equal_approx(View.shot_origin(sapper_right).x-View.project(sapper_right.from).x,34.0) and is_equal_approx(View.project(sapper_left.from).x-View.shot_origin(sapper_left).x,34.0) and is_equal_approx(View.shot_origin(sapper_right).y-View.project(sapper_right.from).y,-27.0),"Départ visuel du sapeur à (±34, −27) des pieds")
	for type in range(6):
		var shot: Dictionary = {"type":type,"from":Vector2(2,6),"to":Vector2(3,3),"secondary":[]}
		var before: Dictionary = shot.duplicate(true)
		var origin: Vector2 = View.shot_origin(shot)
		var target: Vector2 = View.project(shot.to)+Vector2(0,-12)
		check(View.projectile_position(shot,0).is_equal_approx(origin),"Départ au défenseur réel")
		check(View.projectile_position(shot,View.PROJECTILE_FLIGHT).is_equal_approx(target),"Arrivée au point d’impact réel")
		check(View.projectile_position(shot,-1).is_equal_approx(origin) and View.projectile_position(shot,10).is_equal_approx(target),"Pas d’extrapolation avant ou après le mouvement")
		var middle: Vector2 = View.projectile_position(shot,View.PROJECTILE_FLIGHT/2)
		check(middle.is_finite() and is_equal_approx(middle.x,origin.lerp(target,0.5).x),"Trajectoire finie et centrée sur la liaison réelle")
		if type in [3,4]: check(middle.y < origin.lerp(target,0.5).y,"Hache et bombe en cloche")
		else: check(middle.is_equal_approx(origin.lerp(target,0.5)),"Flèches et sorts suivent la liaison directe")
		check(shot == before,"La trajectoire ne réécrit ni cible ni victimes")
		shot.to = shot.from
		check(View.projectile_position(shot,View.PROJECTILE_FLIGHT/2).is_finite(),"Points logiques identiques sans division par zéro")
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(0 if type < 3 else 1)
		scene.model.gold = 1000;scene.model.buy(1,type)
		scene.model.wave = 8;scene.model.spawn_schedule = scene.model.Campaign.schedule(8);scene.model.start()
		for step in range(6000):
			scene.model.advance(0.01)
			if not scene.model.shots.is_empty(): break
		check(not scene.model.shots.is_empty(),"Tir réel disponible pour chaque classe")
		if not scene.model.shots.is_empty():
			var latest: Dictionary = scene.model.shots[-1]
			check(scene.model.elapsed-latest.time < View.PROJECTILE_FLIGHT,"Le modèle a déjà résolu le tir avant la fin de l’habillage")
			var state: String = signature(scene)
			for age in [0.0,0.06,0.13,0.25,0.32]:
				View.projectile_position(latest,age);View.secondary_segments(latest)
				scene.map_view.queue_redraw();await process_frame
			check(signature(scene) == state,"Redessiner ne retarde ni ne rejoue dégâts, malédictions, revenus ou tirages aléatoires")
		scene.queue_free();await process_frame
	print("PROJECTILE_PRESENTATION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
