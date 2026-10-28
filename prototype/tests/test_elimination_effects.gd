extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Main = preload("res://scripts/main.gd")
const View = preload("res://scripts/valley_view.gd")
const Report = preload("res://scripts/run_report.gd")
var checks: int = 0
var failures: int = 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value: failures += 1;push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var m = Model.new();m.phase = "combat";m.elapsed = 1
	var enemy: Dictionary = Model.make_enemy(0,1,0);enemy.distance = 4;m.enemies.assign([enemy])
	m._apply_damage({0:8.0});check(m.elimination_events.is_empty(),"Pas de dissipation sur un simple coup")
	m._apply_damage({0:100.0});check(m.elimination_events.size() == 1 and m.elimination_events[0].point == Model.position_at(4) and m.elimination_events[0].type == 1,"Une élimination au lieu réel de la cible retirée")
	check(m.enemies.is_empty() and m.killed == 1 and m.gold == Model.INITIAL_GOLD+3,"La cible est immédiatement retirée et sa récompense unique conservée")
	m._apply_damage({0:100.0});check(m.elimination_events.size() == 1,"Aucun doublon sur une cible déjà retirée")
	var event: Dictionary = m.elimination_events[0]
	for age in [-1.0,0.0,0.1,0.3,0.45,1.0]:
		var particles: Array[Dictionary] = View.elimination_particles(event,age)
		check(particles.size() == (5 if age >= 0 and age < View.ELIMINATION_DURATION else 0),"Durée bornée, sans événement futur ni poussière permanente")
		for particle in particles: check(particle.point.is_finite() and particle.radius > 0 and particle.alpha > 0 and particle.alpha <= 0.65,"Particules finies et opacité bornée")
	var v = View.new();v.model = m
	check(v.recent_eliminations().size() == 1,"Élimination visible pendant le combat")
	m.phase = "finished";v._process(0.2);check(v.recent_eliminations().size() == 1,"Dernière élimination continue brièvement après la vague")
	v._process(0.3);check(v.recent_eliminations().is_empty(),"Effet final éteint sans attendre la prochaine vague")
	m.prepare_next_wave();v._process(0);check(m.elimination_events.is_empty() and v.elimination_tail == 0,"Nouvelle vague sans ancienne élimination")
	m.elimination_events.append(event);m.reset();check(m.elimination_events.is_empty(),"Nouvelle partie sans ancien effet")
	m.start();m.advance(100);check(m.escaped == 10 and m.elimination_events.is_empty(),"Arrivées à la forteresse sans faux effet de mort")
	m.phase = "combat";m.elapsed = 1;m.elimination_events.clear()
	for id in range(30): m.elimination_events.append({"time":1.0,"enemy_id":id,"type":1,"point":Vector2(4,3)})
	v._process(0);check(v.recent_eliminations().size() == View.MAX_ELIMINATION_EFFECTS and m.elimination_events.size() == 30,"Nombre de dissipations dessiné borné, observations conservées")
	check(View.elimination_particles(event,0.2) == View.elimination_particles(event,0.2),"Même événement et âge : même dessin sans aléatoire de jeu")
	v.free()
	for type in range(6):
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene.map_view.set_process(false)
		scene._choose_faction(0 if type < 3 else 1);scene.model.gold = 1000;scene.model.buy(1,type);scene.model.start()
		var found: bool = false
		for step in range(12000):
			scene.model.advance(0.01)
			if not scene.model.elimination_events.is_empty(): found = true;break
			if scene.model.phase != "combat": break
		check(found,"Élimination réelle produite par chaque classe")
		if found:
			var before: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.enemies,scene.model.elimination_events])
			scene.map_view.queue_redraw();await process_frame
			check(before == JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.enemies,scene.model.elimination_events]),"Dessiner l'effet ne modifie ni combat, RNG, or ni rapport")
			scene.model.reset();scene.map_view._process(0)
			check(scene.map_view.recent_eliminations().is_empty(),"Rejouer retire les effets de la tentative précédente")
		scene.free()
	# Tick létal du chaman, sans nouveau tir à cet instant.
	m = Model.new();m.select_faction(1);m.gold = 1000;m.buy(1,5);m.start()
	m.enemies[0].hp = 1.0;m.defenders[1].ready_at = 100.0
	m._apply_curse(m.defenders[1].instance_id,0,2.0)
	var shot_count: int = m.shots.size();m.advance(1.0)
	check(m.elimination_events.size() == 1 and m.elimination_events[0].enemy_id == 0 and m.shots.size() == shot_count,"Un tick létal déclenche aussi la dissipation sans nouveau tir")
	print("ELIMINATION_EFFECTS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
