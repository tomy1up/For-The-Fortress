extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
var checks := 0
var failures := 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	for age in [-0.1, 0.0, 0.08, 0.16, 0.32, 1.0]:
		var expected: float = 0.0 if age < 0.0 else clampf(1.0-age/0.32,0.0,1.0)
		check(is_equal_approx(View.impact_opacity(age),expected),"Extinction progressive et absence de tir futur ou ancien")
	for type in [2,3,4]:
		var shot: Dictionary = {"type":type,"to":Vector2(3,4),"secondary":[Vector2(4,4),Vector2(4,5),Vector2(5,5)]}
		var before: Dictionary = shot.duplicate(true)
		var segments = View.secondary_segments(shot)
		check(segments.size() == 3,"Aucune victime visuelle supplémentaire")
		for index in range(3):
			var origin: Vector2 = shot.secondary[index-1] if type == 3 and index > 0 else shot.to
			check(segments[index][0].is_equal_approx(View.project(origin)),"Rebonds successifs ; explosions centrées sur le premier impact")
			check(segments[index][1].is_equal_approx(View.project(shot.secondary[index])),"Marque au véritable point d'impact secondaire")
		check(shot == before,"La géométrie ne modifie pas l'événement de combat")
	for radius in [0.7,1.0,1.2,1.7]:
		var center := Vector2(5,7)
		var ring = View.range_outline(center,radius)
		check(ring[0].is_equal_approx(View.project(center+Vector2(radius,0))),"Rayon réel, même avec Propagation")
		check(ring[16].is_equal_approx(View.project(center+Vector2(0,radius))),"Explosion projetée sur le sol isométrique")
	# Les calculs visuels répétés n'altèrent ni les dégâts ni le générateur aléatoire.
	for type in [2,3,4,5]:
		var m = Model.new(); m.select_faction(0 if type < 3 else 1); m.gold = 1000
		m.buy(1,type); m.wave = 8; m.spawn_schedule = Model.Campaign.schedule(8); m.start(); m.advance(10.0)
		var before: Array = [m.gold,m.total_killed,m.rng.state,m.enemies.duplicate(true),m.curses.duplicate(true),m.shots.duplicate(true)]
		for shot in m.shots:
			View.secondary_segments(shot); View.impact_opacity(m.elapsed-shot.time)
		check(not m.shots.is_empty(),"Contrôle sur de vrais événements d'attaque")
		check(before == [m.gold,m.total_killed,m.rng.state,m.enemies,m.curses,m.shots],"Lecture visuelle sans mutation du modèle")
	print("COMBAT_FEEDBACK_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
