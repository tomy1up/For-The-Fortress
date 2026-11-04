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
		var shot: Dictionary = {"type":type,"from":Vector2(2,6),"to":Vector2(3,3)}
		var origin: Vector2 = View.project(shot.from)
		var right: Vector2 = View.shot_origin(shot)-origin
		check(View.shot_facing(shot) == 1.0,"Cible projetée à droite")
		shot.to = Vector2(1,7)
		var left: Vector2 = View.shot_origin(shot)-origin
		check(View.shot_facing(shot) == -1.0 and left.is_equal_approx(Vector2(-right.x,right.y)),"Le projectile part de l’arme retournée, pas de l’ancien côté")
		check(View.projectile_position(shot,View.PROJECTILE_FLIGHT).is_equal_approx(View.project(shot.to)+Vector2(0,-12)),"Retourner le tireur conserve le vrai point d’impact")
		shot.to = shot.from
		check(View.shot_facing(shot) == 1.0,"Égalité horizontale déterministe, sans division par zéro")
		for age in [-1.0,0.0,View.ATTACK_POSE_DURATION/2,View.ATTACK_POSE_DURATION,1.0]:
			var pulse: float = View.attack_pulse(age)
			var a: Transform2D = View.attack_transform(type,{"pulse":pulse,"direction":1.0})
			var b: Transform2D = View.attack_transform(type,{"pulse":pulse,"direction":-1.0})
			var point := Vector2(17,-40)
			var right_point: Vector2 = a*point
			var art := View.defender_art(type)
			var muzzle: Vector2 = art.MUZZLES[type]
			check(View.shot_origin(shot, age).is_equal_approx(origin+a*muzzle),"Le point d'effet suit la pose de l'arme")
			check(View.projectile_position(shot,0.0).is_equal_approx(View.shot_origin(shot)),"Le projectile conserve son point de depart")
			check((b*point).is_equal_approx(Vector2(-right_point.x,right_point.y)),"Mouvement symétrique, même côté que le tir")
			check(is_equal_approx(absf(a.determinant()),1.0) and is_equal_approx(absf(b.determinant()),1.0),"Les illustrations ne sont ni étirées ni écrasées")
			check(a.origin.length() <= 5.0 and a.is_finite() and b.is_finite(),"Déplacement bref borné et fini, sans quitter l’emplacement")
			if pulse == 0.0:
				check(a.is_equal_approx(Transform2D.IDENTITY) and b.origin.is_zero_approx(),"Retour exact au repos sans translation résiduelle")
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(0 if type<3 else 1)
		scene.model.gold = 1000;scene.model.buy(0,type);scene.model.start()
		scene.model.elapsed = 10.0
		scene.model.shots.assign([
			{"type":type,"time":8.0,"slot":0,"from":Vector2(2,6),"to":Vector2(1,7)},
			{"type":type,"time":9.99,"slot":1,"from":Vector2(2,6),"to":Vector2(3,3)},
			{"type":type,"time":10.1,"slot":0,"from":Vector2(2,6),"to":Vector2(3,3)}])
		var before: String = signature(scene)
		var pose: Dictionary = scene.map_view.defender_pose(0)
		check(pose.direction == -1.0 and pose.pulse == 0.0,"Conserver le dernier côté entre deux tirs, sans emprunter le tir voisin ou futur")
		check(scene.map_view.defender_pose(2).direction == 1.0,"Un emplacement sans tir garde son orientation de repos")
		for frame in range(3):scene.map_view.queue_redraw();await process_frame
		check(signature(scene) == before,"Le rendu animé ne modifie ni combat, or, cibles, RNG ni rapport")
		scene.model.shots.append({"type":type,"time":10.0,"slot":0,"from":Vector2(2,6),"to":Vector2(3,3)})
		check(scene.map_view.defender_pose(0).direction == 1.0,"Le prochain vrai tir peut changer le côté")
		if type == 0:
			scene.model.defenders[0].ready_at = 10.5
			for sample in [[0.0,1],[0.15,2],[0.33,3],[0.41,0]]:
				scene.model.elapsed = 10.0+sample[0]
				check(scene.map_view.defender_pose(0).archer_stage == sample[1],"Le cycle de l’archer revient à la visée avant le prochain tir")
			scene.model.elapsed = 10.0
		else:
			check(not scene.map_view.defender_pose(0).has("archer_stage"),"Les autres défenseurs gardent leurs poses propres")
		scene.model.defenders[0].last_target_position = scene.model.slots[0]+Vector2(-1,0)
		scene.model.phase = "finished"
		check(scene.map_view.defender_pose(0) == {"pulse":0.0,"direction":-1.0},"Fin de vague : repos du dernier cote vise")
		scene.model.shots.clear()
		check(scene.map_view.defender_pose(0).direction == -1.0,"La suppression des effets ne retourne pas le defenseur")
		scene.model.reset();scene.model.select_faction(0 if type<3 else 1)
		check(scene.map_view.defender_pose(0) == {"pulse":0.0,"direction":1.0},"Nouvelle partie : aucun état d’animation conservé")
		scene.queue_free();await process_frame
	print("ATTACK_MOTION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
