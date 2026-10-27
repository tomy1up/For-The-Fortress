extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
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
func run_checks() -> void:
	for age in [-1.0,0.0,0.08,0.16,0.32,0.4,1.0]:
		check(is_equal_approx(View.damage_opacity(age),0.0 if age < 0 else clampf(1.0-age/0.4,0,1)),"Extinction de la portion perdue et absence d’événement futur")
		check(is_equal_approx(View.damage_opacity(age,0.16),0.0 if age < 0 else clampf(1.0-age/0.16,0,1)),"Éclaircissement plus bref que la trace de jauge")
	check(View.damage_span({"hp_before":40.0,"hp_after":32.0},40.0).is_equal_approx(Vector2(0.8,1.0)),"Seuls les huit PV perdus sont représentés")
	check(View.damage_span({"hp_before":40.0,"hp_after":0.0},40.0) == Vector2(0,1),"Dégât létal borné aux PV restants, sans dépassement de jauge")
	check(View.damage_span({"hp_before":60.0,"hp_after":-5.0},40.0) == Vector2(0,1) and View.damage_span({"hp_before":1.0,"hp_after":0.0},0.0) == Vector2.ZERO,"Bornes finies pour données extrêmes")
	var m = Model.new();m.phase = "combat";m.elapsed = 1.0
	var enemy: Dictionary = Model.make_enemy(0,1,0.0);m.enemies.assign([enemy])
	m._apply_damage({0:8.0})
	check(m.damage_events.size() == 1 and m.damage_events[0] == {"time":1.0,"enemy_id":0,"hp_before":40.0,"hp_after":32.0},"Observation exacte de la perte réelle, sans arrondi")
	m._apply_damage({});check(m.damage_events.size() == 1,"Aucun effet sur une cible non touchée")
	m._apply_damage({0:100.0});check(m.damage_events.size() == 2 and m.damage_events[-1].hp_before == 32.0 and m.damage_events[-1].hp_after == 0.0 and m.enemies.is_empty(),"Surplus de dégâts sans faux PV perdus ni ennemi conservé")
	check(m.killed == 1 and m.gold == Model.INITIAL_GOLD+3,"Une élimination et une seule récompense")
	m.phase = "finished";m.prepare_next_wave()
	check(m.damage_events.is_empty(),"Nouvelle vague : effacer les identifiants qui seront réutilisés")
	m.damage_events.append({"time":0.0});m.reset();check(m.damage_events.is_empty(),"Nouvelle partie : aucun ancien coup visible")
	m.enemies.assign([Model.make_enemy(0,1,0.0)]);m._apply_damage({0:8.0});m._apply_damage({0:4.8})
	check(m.damage_events.size() == 2 and is_equal_approx(m.damage_events[1].hp_before,32.0) and is_equal_approx(m.damage_events[1].hp_after,27.2),"Deux dégâts au même instant conservent leurs pertes successives")
	check(is_equal_approx(View.damage_span(m.damage_events[1],40.0).y,View.damage_span(m.damage_events[0],40.0).x),"Les portions perdues successives se rejoignent sans se superposer")
	m = Model.new();m.start();m.advance(80.0)
	check(m.escaped == 10 and m.damage_events.is_empty(),"Les ennemis passés sans être touchés ne produisent pas de réaction de dégâts")
	for type in range(6):
		var scene = Main.new();root.add_child(scene);scene.set_process(false);scene._choose_faction(0 if type<3 else 1)
		scene.model.gold = 1000;scene.model.buy(1,type);scene.model.wave = 8;scene.model.spawn_schedule = Model.Campaign.schedule(8);scene.model.start()
		for step in range(6000):
			scene.model.advance(0.01)
			if not scene.model.damage_events.is_empty(): break
		check(not scene.model.damage_events.is_empty(),"Chaque classe produit une observation depuis un vrai dégât")
		if not scene.model.damage_events.is_empty():
			var event: Dictionary = scene.model.damage_events[-1]
			check(event.hp_before > event.hp_after and event.hp_after >= 0.0,"Perte strictement positive et PV après coup bornés à zéro")
			var before: String = JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.enemies,scene.model.damage_events])
			for frame in range(3):scene.map_view.queue_redraw();await process_frame
			check(JSON.stringify([Report.build(scene.model),str(scene.model.rng.state),scene.model.enemies,scene.model.damage_events]) == before,"Lire les réactions ne modifie ni modèle, effets, RNG ni rapport")
		scene.model.elapsed = 10.0;scene.model.damage_events.assign([
			{"time":9.8,"enemy_id":9,"hp_before":40.0,"hp_after":32.0},
			{"time":9.99,"enemy_id":10,"hp_before":40.0,"hp_after":20.0},
			{"time":10.1,"enemy_id":9,"hp_before":32.0,"hp_after":24.0}])
		var recent: Array[Dictionary] = scene.map_view.recent_enemy_damage(9)
		check(recent.size() == 1 and recent[0].hp_after == 32.0,"Ne pas emprunter un coup futur ou reçu par un voisin")
		check(scene.map_view.enemy_hit_strength(recent) == 0.0,"La traînée peut subsister après la fin de l’éclaircissement")
		scene.model.phase = "finished";check(scene.map_view.recent_enemy_damage(9).is_empty(),"Aucun éclaircissement figé dans les panneaux entre les vagues")
		scene.queue_free();await process_frame
	# Le chaman produit également des événements lors de ses ticks, sans nouveau tir.
	m = Model.new();m.select_faction(1);m.gold = 1000;m.buy(1,5);m.wave = 8;m.spawn_schedule = Model.Campaign.schedule(8);m.start()
	var tick_found: bool = false
	for step in range(6000):
		m.advance(0.01)
		if not m.damage_events.is_empty() and not m.shots.is_empty() and m.elapsed-m.damage_events[-1].time < 0.01 and m.elapsed-m.shots[-1].time > 0.5:
			tick_found = true;break
	check(tick_found,"Les dégâts périodiques réels déclenchent aussi une réaction, sans nouveau tir")
	print("DAMAGE_REACTION_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)
