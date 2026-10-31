extends SceneTree
const View = preload("res://scripts/valley_view.gd")
const Model = View.Model
const Main = preload("res://scripts/main.gd")
const Art = View.EnemyArt
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func signature(scene: Node) -> String:
	return JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.enemies,scene.model.damage_events,scene.model.protection_events,scene.model.shots])
func run_checks() -> void:
	check(View.hit_reaction_pulse(0) == 0.0 and is_equal_approx(View.hit_reaction_pulse(0.045),1.0),"L’impact commence sans saut et atteint son maximum après 45 ms simulées")
	for age in [-1.0,View.HIT_REACTION_DURATION,1.0,INF,NAN]: check(View.hit_reaction_pulse(age) == 0.0,"Aucune pose future, résiduelle ou non finie")
	var scene = Main.new();root.add_child(scene);scene.set_process(false)
	for faction in [0,1]:
		for type in range(9):
			var enemy: Dictionary = Model.make_enemy(7,type,0,faction)
			var events: Array[Dictionary] = [{"time":1.0,"enemy_id":7,"hp_before":enemy.hp,"hp_after":enemy.hp*0.5}]
			var snapshot: String = str([enemy,events])
			for age in [0.0,0.0225,0.045,0.08,0.16,0.24,0.28,1.0]:
				var pose: Dictionary = View.enemy_reaction_pose(enemy,events,1.0+age)
				check(pose.strength >= 0 and pose.strength <= View.enemy_reaction_weight(type),"Intensité bornée selon le poids de chaque silhouette")
				for distance in [1.0,5.0,9.0,23.0]:
					enemy.distance = distance
					var facing: float = View.enemy_facing(enemy)
					var transform: Transform2D = View.enemy_body_transform(enemy,facing,pose,1.0+age,true)
					check(transform.is_finite() and is_equal_approx(absf(transform.determinant()),pow(View._enemy_scale(enemy),2)),"Illustration rigide, sans étirement ni changement de proportions")
					var region: Rect2 = Art.destination(View.enemy_art_id(enemy,faction))
					var bounds: Rect2 = View.enemy_bounds(enemy,faction)
					var center: Vector2 = View.project(Model.position_at(distance))
					for corner in [region.position,Vector2(region.end.x,region.position.y),region.end,Vector2(region.position.x,region.end.y)]:
						check(bounds.has_point(center+transform*corner),"Toutes les poses restent dans le survol stable, dans les deux sens")
				var right: Transform2D = View.enemy_body_transform(enemy,1.0,pose,1.0+age,false)
				var left: Transform2D = View.enemy_body_transform(enemy,-1.0,pose,1.0+age,false)
				var point := Vector2(15,-30)
				check((left*point).is_equal_approx(Vector2(-(right*point).x,(right*point).y)),"Réaction tournée avec le personnage, sans partir de l’ancien côté")
				if age == 0.28 or age == 1.0: check(pose.offset == Vector2.ZERO and pose.rotation == 0.0,"Retour exact au repos, sans dérive après le coup")
			enemy.distance = 0.0
			check(str([enemy,events]) == snapshot,"Calcul de pose sans modification des entrées")
			var single: Dictionary = View.enemy_reaction_pose(enemy,events,1.045)
			events.append(events[0].duplicate())
			check(View.enemy_reaction_pose(enemy,events,1.045) == single,"Les dégâts simultanés ne font pas trembler ou sortir l’unité du chemin")
			events.assign([{"time":1.0,"enemy_id":8,"hp_before":enemy.hp,"hp_after":0.0}])
			check(View.enemy_reaction_pose(enemy,events,1.045).strength == 0.0,"Le coup d’un voisin n’est pas emprunté")
			# Un dégât du vrai modèle déclenche la pose sans nouveaux champs de combat.
			scene.model = Model.new();scene.map_view.model = scene.model
			scene.model.faction = faction;scene.model.phase = "combat";scene.model.elapsed = 1.0
			scene.model.enemies.assign([enemy]);scene.model._apply_damage({7:enemy.hp*0.1})
			scene.model.elapsed = 1.045
			var feedback: Array[Dictionary] = scene.map_view.recent_enemy_damage(7)
			check(View.enemy_reaction_pose(enemy,feedback,scene.model.elapsed).strength > 0,"Les neuf profils réagissent à une perte réelle de PV, y compris la tortue")
			var before: String = signature(scene)
			for frame in range(2):scene.map_view.queue_redraw();await process_frame
			check(signature(scene) == before,"Dessiner la réaction ne touche ni trajet, vitesse, PV, gains, RNG ni rapport")
			scene.model.phase = "finished"
			check(View.enemy_reaction_pose(enemy,scene.map_view.recent_enemy_damage(7),scene.model.elapsed).strength == 0.0,"Aucune pose figée après le combat")
	scene.queue_free();await process_frame
	print("ENEMY_HIT_MOTION_TESTS checks=%d failures=%d" % [checks,failures]);quit(0 if failures == 0 else 1)
