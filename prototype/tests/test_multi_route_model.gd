extends SceneTree
const Model=preload("res://scripts/valley_model.gd")
const Maps=Model.Maps
const Report=preload("res://scripts/run_report.gd")
const Replay=preload("res://tests/report_replay.gd")
const View=preload("res://scripts/valley_view.gd")
const Main=preload("res://scripts/main.gd")
var checks:=0
var failures:=0
func check(value: bool, label: String) -> void:
	checks+=1
	if not value: failures+=1;push_error(label)
static func terrain() -> Dictionary:
	var upper: Array[Vector2]=[Vector2(0,2),Vector2(4,2),Vector2(4,4),Vector2(10,4)]
	var lower: Array[Vector2]=[Vector2(0,8),Vector2(4,8),Vector2(4,4),Vector2(10,4)]
	return {"id":"test_converging","title":"Deux entrées (test)","size":Vector2i(18,10),"path_points":upper,"path_length":12.0,"slots":[Vector2(1,1),Vector2(1,9),Vector2(4,5),Vector2(7,5),Vector2(9,2),Vector2(9,6)],"trees":[],"decoration":"none","routes":[{"id":"upper","path_points":upper,"path_length":12.0},{"id":"lower","path_points":lower,"path_length":14.0}]}
func _initialize() -> void: call_deferred("run_checks")
func fighter(faction: int, type: int) -> RefCounted:
	var model:=Model.new(true,terrain())
	model.select_faction(faction)
	check(model.buy(2,type),"Achat sur le réseau de test")
	model.phase="combat";model.elapsed=10.0;model.spawn_schedule=[]
	return model
static func enemy(id: int, type: int, route: String, progress: float, now: float=10.0) -> Dictionary:
	var result:=Model.make_enemy(id,type,now-progress/Model.enemy_definition(type).speed)
	result.route_id=route
	return result
func run_checks() -> void:
	var definition:=terrain()
	check(Maps.validation_error(definition).is_empty(),"Carte à deux trajets valide")
	var encoded: Dictionary=Maps.to_data(definition)
	check(Maps.from_data(JSON.parse_string(JSON.stringify(encoded)))==definition,"Aller-retour JSON des deux trajets")
	check(definition.routes[0].path_points[0] is Vector2,"La sérialisation ne modifie pas la carte source")
	check(Maps.validation_error(Maps.converging_workshop()).is_empty() and Maps.for_id("workshop_confluence").is_empty(),"Atelier valide sans nouvelle mission de campagne")
	var historical:=Model.new(true,definition)
	for invalid in [null,1,true,[],{},"unknown"]:
		check(not historical.configure_route_target_policy(invalid),"Règle de ciblage mal formée refusée")
	check(historical.configure_route_target_policy("remaining_distance"),"Sélection historique avant toute décision")
	historical.select_faction(0);historical.buy(2,0)
	check(not historical.configure_route_target_policy("arrival_time"),"Règle figée dès le choix de faction")
	historical.phase="combat";historical.elapsed=10.0;historical.spawn_schedule=[]
	historical.enemies.assign([enemy(0,1,"upper",8.0),enemy(1,2,"lower",8.0)])
	historical._resolve_instant()
	check(historical.shots[0].target_id==0,"Ancien diagnostic : le pillard plus proche garde la priorité malgré le sprinter")
	historical.reset()
	check(historical.route_target_policy=="remaining_distance","Reset conserve la configuration historique")
	var single:=Model.new()
	check(not single.configure_route_target_policy("remaining_distance") and not Report.build(single).has("route_target_policy"),"Rapport à trajet unique inchangé")
	for camp in ["alliance","horde"]:
		var source: String=FileAccess.get_file_as_string("res://tests/fixtures/routes_v0106/%s.json"%camp)
		var old: Dictionary=JSON.parse_string(source)
		check(Replay.verify(old).ok,"Rapport produit et vérifié par le paquet v0.106 rejouable : "+camp)
		check(JSON.stringify(old)==JSON.stringify(JSON.parse_string(source)),"Relecture historique sans modification du rapport")
		var changed:=old.duplicate(true);changed.route_target_policy="arrival_time"
		check(not Replay.verify(changed).ok,"La fixture distingue effectivement les résultats des deux ciblages : "+camp)
	for mutation in ["main_mismatch","outside","duplicate","different_exit","wrong_length","bad_coordinates"]:
		var broken:=encoded.duplicate(true)
		match mutation:
			"main_mismatch": broken.path_points[0]=[0,1]
			"outside": broken.routes[1].path_points[0]=[0,11]
			"duplicate": broken.routes[1].id="upper"
			"different_exit": broken.routes[1].path_points[-1]=[11,4];broken.routes[1].path_length=15
			"wrong_length": broken.routes[1].path_length=12
			"bad_coordinates": broken.routes[1].path_points[0]=["x",8]
		check(Maps.from_data(broken).is_empty(),"Définition de réseau falsifiée refusée : "+mutation)
	for faction in [0,1]:
		var arrival:=Model.new(true,definition)
		arrival.select_faction(faction)
		arrival.spawn_schedule.assign([{"time":0.0,"type":1},{"time":0.0,"type":1}])
		check(arrival.start(),"Départ des deux entrées")
		check(arrival.enemies[0].route_id=="upper" and arrival.enemies[1].route_id=="lower","Affectation alternée provisoire, stable par apparition")
		arrival.advance(12.0)
		check(arrival.escaped==1 and arrival.enemies.size()==1 and arrival.enemies[0].route_id=="lower" and arrival.fortress_hp==19,"Arrivée sur le trajet court à douze secondes")
		arrival.advance(2.0)
		check(arrival.escaped==2 and arrival.fortress_hp==18 and arrival.gold==150 and arrival.phase=="finished","Trajet long : arrivée à quatorze secondes, aucune récompense")
		check(arrival.wave_arrivals_by_route=={"upper": 1, "lower": 1},"Les deux entrees comptent une arrivee dans la vague")
		arrival.reset()
		check(arrival.wave_arrivals_by_route.is_empty(),"Un nouvel essai vide les compteurs par entree")
		check(arrival.routes.size()==2 and arrival.enemies.is_empty(),"Reset conserve le réseau et retire les ennemis")
		arrival.spawn_schedule.assign([{"time":0.0,"type":1,"route_id":"absent"}])
		check(not arrival.start() and arrival.phase=="preparation" and arrival.enemies.is_empty(),"Trajet explicite inconnu refusé avant le combat")
		var ranged:=Model.new(true,definition);ranged.select_faction(faction)
		check(ranged.buy(0,0 if faction==0 else 3),"Défenseur sur la seule entrée haute")
		ranged.spawn_schedule.assign([{"time":0.0,"type":1},{"time":0.0,"type":1}]);ranged.start()
		check(ranged.shots.size()==1 and ranged.shots[0].target_id==0 and ranged.enemies[1].hp==40.0,"La portée de l'entrée haute ne touche pas l'entrée basse")
		check(ranged.defenders[0].route_windows.lower.is_empty(),"Fenêtres de tir séparées par trajet")
		var priority:=fighter(faction,0 if faction==0 else 3)
		priority.enemies.assign([enemy(0,1,"upper",8.0),enemy(1,1,"lower",9.0)])
		priority._resolve_instant()
		check(priority.shots[0].target_id==0,"À vitesse égale : temps restant selon la longueur propre au trajet")
		var urgent:=fighter(faction,0 if faction==0 else 3)
		urgent.enemies.assign([enemy(0,1,"upper",8.0),enemy(1,2,"lower",8.0)])
		urgent._resolve_instant()
		check(urgent.shots[0].target_id==1,"Le sprinter plus éloigné passe devant le pillard plus proche s'il arrive avant lui")
		check(urgent.enemy_arrival_delay(urgent.enemies[1])<urgent.enemy_arrival_delay(urgent.enemies[0]),"Urgence calculée avec la vitesse et la distance restante")
		var tied:=Model.new(true,definition);tied.select_faction(faction);tied.buy(3,0 if faction==0 else 3)
		tied.phase="combat";tied.elapsed=10.0;tied.spawn_schedule=[]
		tied.enemies.assign([enemy(9,5,"upper",11.0),enemy(1,1,"lower",12.0)])
		tied._resolve_instant()
		check(tied.shots[0].target_id==1,"Arrivées à égalité : ancienneté, indépendamment de la route et de l'ordre du tableau")
		var area:=fighter(faction,2 if faction==0 else 3)
		area.enemies.assign([enemy(0,1,"upper",6.25),enemy(1,1,"lower",8.5)])
		area._resolve_instant()
		check(area.shots.size()==1 and area.shots[0].target_id==1 and area.shots[0].secondary.size()==1,"Explosion ou rebond entre les deux trajets après jonction")
		check(area.shots[0].to==Vector2(4.5,4) and area.shots[0].secondary[0]==Vector2(4.25,4),"Points d'impact situés sur les trajets réels")
		var distant:=fighter(faction,2 if faction==0 else 3)
		distant.enemies.assign([enemy(0,1,"upper",3.0),enemy(1,1,"lower",3.0)])
		distant._resolve_instant()
		check(distant.shots.size()==1 and distant.shots[0].secondary.is_empty(),"Pas de dégâts secondaires fictifs entre entrées éloignées")
		var guardian:=Model.new(true,definition);guardian.phase="combat";guardian.elapsed=10.0;guardian.spawn_schedule=[]
		guardian.enemies.assign([enemy(0,1,"upper",2.0),enemy(1,8,"lower",2.0)])
		guardian._update_positions();guardian._apply_damage({0:40.0})
		check(guardian.killed==1 and guardian.enemies[0].hp==180.0 and guardian.protection_events.is_empty(),"La tortue de l'autre entrée ne protège pas à six unités")
		guardian.enemies.assign([enemy(2,1,"upper",7.0),enemy(3,8,"lower",9.0)])
		guardian._update_positions();guardian._apply_damage({2:20.0})
		check(guardian.enemies[0].hp==25.0 and guardian.enemies[1].hp==175.0 and guardian.protection_events.size()==1,"La tortue protège réellement après la jonction")
		var complete:=Model.new(true,definition);complete.select_faction(faction)
		complete.buy(2,0 if faction==0 else 3);complete.buy(3,1 if faction==0 else 4)
		while complete.phase not in ["victory","defeat"]:
			if complete.phase=="bonus": complete.choose_bonus(complete.bonus_offer[0])
			if complete.phase=="finished": complete.prepare_next_wave()
			complete.start();complete.advance(10000)
		var report: Dictionary=JSON.parse_string(JSON.stringify(Report.build(complete)))
		check(report.route_target_policy=="arrival_time","Nouveau rapport : règle de ciblage explicite")
		var entries: Array = report.arrivals_by_entry
		check(entries.size()==2 and entries[0].route_id=="upper" and entries[1].route_id=="lower","Le bilan conserve l'identite des deux entrees")
		check(entries[0].arrivals+entries[1].arrivals==report.total_escaped,"Les arrivees par entree correspondent au total du combat")
		check(Replay.verify(report).ok,"Rapport multitrajet rejouable avec affectation identique")
		var wrong_arrivals := report.duplicate(true)
		wrong_arrivals.arrivals_by_entry[0].arrivals += 1
		check(not Replay.verify(wrong_arrivals).ok,"Le rejeu rejette un effectif falsifie par entree")
		for invalid in [null,1,"unknown",{}]:
			var malformed:=report.duplicate(true);malformed.route_target_policy=invalid
			check(not Replay.verify(malformed).ok,"Règle de ciblage invalide rejetée avant relecture")
		check(Report.markdown(report).contains("Atelier multitrajet : 2 entrées"),"Rapport lisible explicitant le contexte d'atelier")
		var forged:=report.duplicate(true);forged.map_definition.routes[1].path_length=12.0
		check(not Replay.verify(forged).ok,"Rapport multitrajet à longueur falsifiée rejeté")
		var view:=View.new();view.model=ranged;get_root().add_child(view);view.set_process(false)
		for target in ranged.enemies:
			var point: Vector2=View.enemy_bounds(target,faction,ranged.enemy_route_points(target),ranged.enemy_route_length(target)).get_center()
			check(view.enemy_at(point)==target.id,"Survol sur la bonne entrée")
		check(view.map_covered_routes(ranged.slots[0],ranged.get_stats(0).range).size()==ranged.defenders[0].route_windows.upper.size(),"Aperçu de portée limité à l'entrée effectivement couverte")
		view.free()
	var curse:=fighter(1,5)
	curse.enemies.assign([enemy(0,1,"upper",6.25),enemy(1,1,"lower",8.5)])
	curse._resolve_instant();curse.advance(1.0)
	check(curse.curses.size()==1 and curse.curses[0].enemy_id==1 and is_equal_approx(curse.enemies[1].hp,23.2),"La malédiction suit l'identifiant de sa victime sur la deuxième route")
	var reference: Dictionary={}
	for step in [0.1,1.0,10.0,10000.0]:
		var simulation:=fighter(1,3)
		simulation.phase="preparation";simulation.elapsed=0.0
		simulation.spawn_schedule.assign([{"time":0.0,"type":1},{"time":0.0,"type":1},{"time":0.3,"type":1},{"time":0.3,"type":1}])
		simulation.start()
		while simulation.active: simulation.advance(step)
		var observed: Dictionary={"log":simulation.event_log,"hp":simulation.fortress_hp,"gold":simulation.gold,"killed":simulation.killed,"escaped":simulation.escaped,"time":simulation.elapsed}
		if reference.is_empty(): reference=observed.duplicate(true)
		check(observed==reference,"Combat multitrajet identique pour le pas de temps %s"%str(step))
	var scene:=Main.new()
	scene.model=Model.new(true,Maps.converging_workshop());scene.mission_definition={}
	get_root().add_child(scene);scene.set_process(false)
	check(scene.meta_profile==null and scene.model.routes.size()==2,"Interface d'atelier sans profil joueur")
	scene.faction_buttons[1].pressed.emit()
	check(not scene.choosing_faction and not scene.campaign_menu.visible and scene.model.faction==1 and scene.meta_run_id==-1,"Bouton de faction : accès direct à l'atelier sans parcours indisponible")
	check(scene._select_slot(1) and scene.model.buy(1,3),"Sélection et recrutement sur l'interface de l'atelier")
	check(not scene.start_button.disabled,"Bouton de départ autorisé dans l'atelier")
	scene.start_button.pressed.emit();scene.model.advance(3.0);scene._update_interface()
	check(scene.model.spawned>=2 and scene.model.enemies.any(func(target):return target.route_id=="lower"),"Combat via l'interface avec la deuxième entrée active")
	scene.free()
	print("MULTI_ROUTE_MODEL_TESTS checks=%d failures=%d"%[checks,failures])
	quit(0 if failures==0 else 1)
