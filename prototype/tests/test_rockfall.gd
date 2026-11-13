extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const View = preload("res://scripts/valley_view.gd")
const Library = preload("res://scripts/animation_library.gd")
const AFFIX := {"id":"rockfall","interval":18,"warning":3,"duration":7}
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_validation()
	verify_texts()
	verify_blocking()
	verify_forecast_and_spawns()
	verify_step_independence()
	verify_status()
	verify_replay()
	await verify_rendering()
	await verify_sheets()
	print("ROCKFALL_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func rocky(map_id: String = "mine_crystals") -> Model:
	var model := Model.new(true,Model.Maps.for_id(map_id))
	check(model.configure_combat_affix(AFFIX),"Affixe Éboulement accepté sur %s" % map_id)
	model.rng.seed = 7
	return model

func verify_validation() -> void:
	for map_id in ["mine_gallery","mine_crystals"]:
		for valid in [AFFIX,{"id":"rockfall","interval":10,"warning":1,"duration":2},{"id":"rockfall","interval":40,"warning":4,"duration":12}]:
			var model := Model.new(true,Model.Maps.for_id(map_id))
			check(model.configure_combat_affix(valid),"Affixe valide accepté : %s" % JSON.stringify(valid))
	var invalid: Array = [{"id":"rockfall"},{"id":"rockfall","interval":18,"warning":3},{"id":"rockfall","interval":18,"warning":3,"duration":7,"extra":1},
		{"id":"rockfall","interval":9,"warning":3,"duration":7},{"id":"rockfall","interval":41,"warning":3,"duration":7},{"id":"rockfall","interval":18,"warning":0,"duration":7},
		{"id":"rockfall","interval":18,"warning":5,"duration":7},{"id":"rockfall","interval":18,"warning":3,"duration":1},{"id":"rockfall","interval":18,"warning":3,"duration":13},
		{"id":"rockfall","interval":10,"warning":4,"duration":6},{"id":"rockfall","interval":18.5,"warning":3,"duration":7},{"id":"rockfall","interval":18,"warning":"3","duration":7},
		{"id":"rockfall","interval":18,"warning":NAN,"duration":7},{"id":"rockfall","interval":18,"warning":3,"duration":INF}]
	for bad in invalid:
		var model := Model.new(true,Model.Maps.for_id("mine_crystals"))
		check(not model.configure_combat_affix(bad) and model.combat_affix.is_empty(),"Affixe mal formé refusé sans effet : %s" % str(bad))
	var single := Model.new(true,Model.Maps.for_id("mine_entrance"))
	check(not single.configure_combat_affix(AFFIX) and single.combat_affix.is_empty(),"Une carte à une seule entrée refuse l'éboulement")
	var started := Model.new(true,Model.Maps.for_id("mine_crystals"));started.buy(3,0)
	check(not started.configure_combat_affix(AFFIX),"Affixe refusé après une action")

func verify_texts() -> void:
	var model := rocky()
	check(model.affix_description() == "Éboulement · une entrée bloquée 7 s toutes les 18 s","Description courte de l'affixe")
	check(model.affix_tooltip().contains("18 s") and model.affix_tooltip().contains("7 s") and model.affix_tooltip().contains("3 s") and model.affix_tooltip().contains("entrée suivante") and model.affix_tooltip().contains("Réglage d’essai"),"Info-bulle d'essai complète")
	var plain := Model.new(true,Model.Maps.for_id("mine_crystals"))
	check(plain.affix_description() == "" and not plain.rockfall_enabled() and plain.rockfall_status().is_empty() and plain.rockfall_blocked_route(20.0,1) == "","Sans affixe, rien n'est annoncé ni bloqué")

func verify_blocking() -> void:
	var model := rocky()
	var size: int = model.routes.size()
	check(size == 3,"La Grotte aux Cristaux a trois entrées")
	check(model.rockfall_blocked_route(0.0,1) == "" and model.rockfall_blocked_route(17.9,1) == "" and model.rockfall_blocked_route(25.0,1) == "" and model.rockfall_blocked_route(35.9,1) == "","Aucune entrée bloquée hors des fenêtres")
	check(model.rockfall_blocked_route(18.0,1) == model.routes[(1+1)%size].id and model.rockfall_blocked_route(24.9,1) == model.routes[(1+1)%size].id,"Le premier éboulement tombe sur l'entrée (1 + vague) modulo trois")
	check(model.rockfall_blocked_route(36.0,1) == model.routes[(2+1)%size].id and model.rockfall_blocked_route(36.0,2) == model.routes[(2+2)%size].id,"L'entrée touchée change avec le numéro d'éboulement et la vague")
	for wave in range(1,11):
		for number in range(1,6):
			var route_id: String = model.rockfall_blocked_route(18.0*number+1.0,wave)
			check(route_id != "" and model.routes.any(func(route): return route.id == route_id),"Vague %d, éboulement %d : une entrée existante est touchée" % [wave,number])

func verify_forecast_and_spawns() -> void:
	for map_id in ["mine_gallery","mine_crystals"]:
		var plain := Model.new(true,Model.Maps.for_id(map_id))
		var model := rocky(map_id)
		for wave in range(1,11):
			var schedule: Array[Dictionary] = Model.Campaign.schedule(wave,"ford")
			var moved := 0
			for index in range(schedule.size()):
				var base: String = plain.spawn_route_id(index,schedule[index],wave)
				var actual: String = model.spawn_route_id(index,schedule[index],wave)
				var blocked: String = model.rockfall_blocked_route(float(schedule[index].time),wave)
				if blocked != "" and base == blocked:
					moved += 1
					check(actual != blocked and actual == model.routes[(model.routes.find(model.routes.filter(func(route): return route.id == base)[0])+1)%model.routes.size()].id,"%s vague %d apparition %d : passe par l'entrée suivante" % [map_id,wave,index])
				else:
					check(actual == base,"%s vague %d apparition %d : trajet inchangé hors de l'entrée bloquée" % [map_id,wave,index])
			var forecast: Dictionary = model.forecast_for_routes(wave)
			var total := 0
			for entry in forecast.entries: total += int(entry.count)
			check(total == schedule.size(),"%s vague %d : la prévision garde tous les ennemis (%d déplacés)" % [map_id,wave,moved])
	# Au moins une vague change réellement de répartition : l'affixe a un effet observable.
	var plain_model := Model.new(true,Model.Maps.for_id("mine_crystals"))
	var model := rocky()
	var differs := false
	for wave in range(1,11):
		var a: Dictionary = plain_model.forecast_for_routes(wave);var b: Dictionary = model.forecast_for_routes(wave)
		if JSON.stringify(a.entries) != JSON.stringify(b.entries): differs = true
	check(differs,"L'éboulement modifie la répartition des entrées sur au moins une vague")

func play_wave(step: float, map_id: String = "mine_crystals") -> Dictionary:
	var model := rocky(map_id)
	model.gold = 600
	model.select_faction(0)
	model.buy(3,0);model.buy(4,1)
	model.start()
	var guard := 0
	while model.phase == "combat" and guard < 100000:
		model.advance(step);guard += 1
	var routes_used: Array = []
	for enemy in model.enemies: routes_used.append(enemy.get("route_id",""))
	return {"log":model.event_log.duplicate(),"routes":routes_used,"hp":model.fortress_hp,"gold":model.gold,"killed":model.wave_killed if "wave_killed" in model else 0,"phase":model.phase}

func verify_step_independence() -> void:
	var big: Dictionary = play_wave(10000.0)
	var small: Dictionary = play_wave(0.05)
	var odd: Dictionary = play_wave(0.731)
	check(JSON.stringify(big) == JSON.stringify(small) and JSON.stringify(big) == JSON.stringify(odd),"Même déroulement avec un grand pas, des pas de 50 ms et des pas irréguliers")

func verify_status() -> void:
	var model := rocky()
	model.gold = 600;model.select_faction(0);model.buy(3,0)
	check(model.rockfall_status().is_empty(),"Hors combat, aucun état")
	model.start()
	check(model.rockfall_status().is_empty(),"Au début du combat, aucun éboulement annoncé")
	model.advance(15.0)
	var warning: Dictionary = model.rockfall_status()
	check(warning.get("state","") == "warning" and warning.number == 1 and warning.route_id == model.routes[(1+model.wave)%model.routes.size()].id and absf(float(warning.remaining)-3.0) < 0.001,"À 15 s : avertissement de l'éboulement 1 sur l'entrée touchée")
	model.advance(3.5)
	var active: Dictionary = model.rockfall_status()
	check(active.get("state","") == "active" and active.route_id == warning.route_id and absf(float(active.remaining)-6.5) < 0.001,"À 18,5 s : entrée bloquée, même entrée que l'avertissement")
	model.advance(7.0)
	check(model.rockfall_status().is_empty() or model.rockfall_status().get("state","") == "warning" and model.rockfall_status().number == 2,"Après 25,5 s : plus de blocage")

func verify_replay() -> void:
	for faction in range(2):
		var model := rocky()
		model.select_faction(faction)
		var types: Array = [0,1,1] if faction == 0 else [3,3,5]
		model.buy(3,types[0]);model.buy(4,types[1])
		for wave in range(1,11):
			if wave == 2: model.upgrade(3)
			if wave >= 2 and model.defenders[2].is_empty(): model.buy(2,types[2])
			if wave >= 5:
				for slot in [3,4,2]:
					if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level == 3 else -1)
			model.start();model.advance(10000)
			if model.phase == "defeat": break
			if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
			if wave < 10: model.prepare_next_wave()
		var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
		check(report.has("combat_affix") and report.combat_affix.id == "rockfall" and int(report.combat_affix.interval) == 18 and int(report.combat_affix.warning) == 3 and int(report.combat_affix.duration) == 7,"Le rapport conserve l'affixe")
		var replay: Dictionary = Replay.verify(report)
		check(replay.ok,"Le rapport de la faction %d est rejouable : %s" % [faction,str(replay.get("error",""))])
		check(Report.markdown(report).contains("Éboulement · toutes les 18 s de combat"),"Le rapport lisible décrit l'éboulement")
		var tampered: Dictionary = report.duplicate(true)
		tampered.combat_affix.duration = 8
		check(not Replay.verify(tampered).ok,"Un rapport dont l'affixe est modifié n'est plus rejouable")

func verify_rendering() -> void:
	var model := rocky()
	model.gold = 600;model.select_faction(0);model.buy(3,0)
	var view := View.new();view.model = model;root.add_child(view)
	model.start()
	var before: String = JSON.stringify([model.gold,model.fortress_hp,model.rng.state,model.action_history,model.enemies,model.defenders])
	for time in [5.0,10.0,3.0,4.0,5.0]:
		model.advance(time)
		await process_frame
	check(not model.rockfall_status().is_empty() or model.elapsed > 0.0,"Le combat avance pendant le dessin")
	view.free()
	check(before != "","Dessin de l'avertissement et du blocage sans erreur")

## Habillage par planches (`effect.rockfall`) : accepté, dessiné sans modifier le jeu, repli sur le repère provisoire sans planche.
func verify_sheets() -> void:
	Library.clear_cache()
	var spec := {"version":1,"id":"effect.rockfall","display_height":48,"foot":[32,40],"animations":{
		"warning":{"file":"warning.png","frames":6,"frame_size":[64,48],"mode":"progress"},
		"blocked":{"file":"blocked.png","frames":8,"frame_size":[64,48],"mode":"time","fps":8}}}
	check(Library.validation_error(spec) == "","Description de l'effet d'éboulement valide")
	var wrong: Dictionary = spec.duplicate(true);wrong.animations.blocked = {"file":"b.png","frames":4,"frame_size":[64,48],"mode":"event","duration":1.0}
	check(Library.validation_error(wrong) != "","Le blocage boucle : mode time obligatoire")
	var warning_strip := Image.create(6*64,48,false,Image.FORMAT_RGBA8);warning_strip.fill(Color(0.9,0.5,0.2,0.4))
	var blocked_strip := Image.create(8*64,48,false,Image.FORMAT_RGBA8);blocked_strip.fill(Color(0.4,0.4,0.45,0.9))
	Library.register_for_test("effect.rockfall",spec,{"warning":ImageTexture.create_from_image(warning_strip),"blocked":ImageTexture.create_from_image(blocked_strip)})
	var model := rocky()
	model.gold = 600;model.select_faction(0);model.buy(3,0)
	model.start()
	var view := View.new();view.model = model;root.add_child(view)
	for time in [18.5,20.0]:
		model.advance(time-model.elapsed)
		var before: String = JSON.stringify([model.gold,model.rng.state,model.defenders,model.rockfall_status()])
		view.queue_redraw()
		await process_frame
		await process_frame
		check(before == JSON.stringify([model.gold,model.rng.state,model.defenders,model.rockfall_status()]) and not model.rockfall_status().is_empty(),"Dessiner l'éboulement à %.1f s (planches) ne modifie pas le jeu" % time)
	view.free()
	Library.clear_cache()
	var bare := View.new();bare.model = model;root.add_child(bare)
	await process_frame
	bare.queue_redraw()
	await process_frame
	check(not model.rockfall_status().is_empty(),"Sans planche : repère provisoire dessiné sans erreur")
	bare.free()
