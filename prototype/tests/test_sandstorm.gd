extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const View = preload("res://scripts/valley_view.gd")
const Library = preload("res://scripts/animation_library.gd")
const AFFIX := {"id":"sandstorm","interval":15,"warning":3,"duration":5,"range_percent":25}
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
	verify_timeline()
	verify_windows()
	verify_effect()
	verify_step_independence()
	verify_replay()
	await verify_rendering()
	await verify_eruption_ash()
	print("SANDSTORM_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func stormy(types: Array = [0,1], slots: Array = [3,4]) -> Model:
	var model := Model.new(true)
	check(model.configure_combat_affix(AFFIX),"Affixe Tempête de sable accepté")
	model.rng.seed = 7
	model.gold = 600 # Essai de la règle seule : trois défenseurs sans attendre les revenus.
	for index in range(types.size()): check(model.buy(slots[index],types[index]),"Défenseur acheté pour l'essai")
	return model

func verify_validation() -> void:
	for valid in [AFFIX,{"id":"sandstorm","interval":10,"warning":1,"duration":2,"range_percent":5},{"id":"sandstorm","interval":40,"warning":4,"duration":12,"range_percent":60},{"id":"sandstorm","interval":15.0,"warning":3.0,"duration":5.0,"range_percent":25.0}]:
		var model := Model.new(true)
		check(model.configure_combat_affix(valid),"Affixe valide accepté : %s" % JSON.stringify(valid))
	var invalid: Array = [{"id":"sandstorm"},{"id":"sandstorm","interval":15,"warning":3,"duration":5},{"id":"sandstorm","interval":15,"warning":3,"duration":5,"range_percent":25,"extra":1},
		{"id":"sandstorm","interval":9,"warning":3,"duration":5,"range_percent":25},{"id":"sandstorm","interval":41,"warning":3,"duration":5,"range_percent":25},
		{"id":"sandstorm","interval":15,"warning":0,"duration":5,"range_percent":25},{"id":"sandstorm","interval":15,"warning":5,"duration":5,"range_percent":25},
		{"id":"sandstorm","interval":15,"warning":3,"duration":1,"range_percent":25},{"id":"sandstorm","interval":15,"warning":3,"duration":13,"range_percent":25},
		{"id":"sandstorm","interval":15,"warning":3,"duration":5,"range_percent":4},{"id":"sandstorm","interval":15,"warning":3,"duration":5,"range_percent":61},
		{"id":"sandstorm","interval":10,"warning":4,"duration":6,"range_percent":25},{"id":"sandstorm","interval":15.5,"warning":3,"duration":5,"range_percent":25},
		{"id":"sandstorm","interval":15,"warning":3,"duration":5,"range_percent":25.5},{"id":"sandstorm","interval":15,"warning":3,"duration":5,"range_percent":"25"},
		{"id":"sandstorm","interval":15,"warning":3,"duration":5,"range_percent":INF},{"id":"sandstorm","interval":15,"warning":NAN,"duration":5,"range_percent":25}]
	for bad in invalid:
		var model := Model.new(true)
		check(not model.configure_combat_affix(bad) and model.combat_affix.is_empty(),"Affixe mal formé refusé sans effet : %s" % str(bad))
	var started := Model.new(true);started.buy(3,0)
	check(not started.configure_combat_affix(AFFIX),"Affixe refusé après une action")
	check(Model.valid_enemy_hp_percent(259) and not Model.valid_enemy_hp_percent(260),"PV ennemis acceptés jusqu'à 259 %")

func verify_texts() -> void:
	var model := stormy()
	check(model.affix_description() == "Tempête de sable · portée −25 % pendant 5 s toutes les 15 s","Description courte de l'affixe")
	check(model.affix_tooltip().contains("15 s") and model.affix_tooltip().contains("25 %") and model.affix_tooltip().contains("5 s") and model.affix_tooltip().contains("3 s") and model.affix_tooltip().contains("Réglage d’essai"),"Infobulle de l'affixe")
	var plain := Model.new(true)
	check(not plain.storm_enabled() and plain.storm_status().is_empty() and not plain.storm_active_now() and plain.range_factor_now() == 1.0,"Sans affixe : aucune tempête")

func verify_timeline() -> void:
	var model := stormy()
	model.start()
	check(model.storm_status().is_empty() and not model.storm_active_now(),"Rien au début du combat")
	model.advance(11.9)
	check(model.storm_status().is_empty(),"Rien avant le délai d'annonce")
	model.advance(0.1)
	var warning: Dictionary = model.storm_status()
	check(warning.get("state") == "warning" and warning.number == 1 and is_equal_approx(warning.remaining,3.0) and model.range_factor_now() == 1.0,"Annonce 3 s avant la première rafale, portée intacte")
	model.advance(3.0)
	var active: Dictionary = model.storm_status()
	check(active.get("state") == "active" and active.number == 1 and is_equal_approx(active.remaining,5.0) and is_equal_approx(model.range_factor_now(),0.75),"Rafale de 5 s à 15 s, portée à 75 %")
	model.advance(4.9)
	check(model.storm_status().get("state") == "active" and model.storm_active_now(),"Toujours en rafale à 19,9 s")
	model.advance(0.1)
	check(model.storm_status().is_empty() and not model.storm_active_now() and model.range_factor_now() == 1.0,"Fin de la rafale à 20 s")
	model.advance(7.0)
	check(model.storm_status().get("state") == "warning" and model.storm_status().number == 2,"Seconde annonce à 27 s")
	var before: String = JSON.stringify(model.storm_status())
	check(before == JSON.stringify(model.storm_status()),"Lire l'état ne modifie rien")
	check(is_equal_approx(model.storm_boundary_time(0),15.0) and is_equal_approx(model.storm_boundary_time(1),20.0) and is_equal_approx(model.storm_boundary_time(2),30.0) and is_equal_approx(model.storm_boundary_time(3),35.0),"Frontières de rafale")

func verify_windows() -> void:
	var model := stormy([0,1,2],[3,4,2])
	model.start()
	var enemy := {"route_id":"","id":1}
	for slot in [2,3,4]:
		model.elapsed = 5.0
		var normal: Array = model._windows_for(model.defenders[slot],enemy)
		var stormy_windows: Array = model.defenders[slot].storm_windows
		check(model._windows_for(model.defenders[slot],enemy) == normal,"Hors rafale : fenêtres normales (emplacement %d)" % slot)
		model.elapsed = 16.0
		check(model._windows_for(model.defenders[slot],enemy) == stormy_windows,"En rafale : fenêtres de portée réduite (emplacement %d)" % slot)
		var total_normal := 0.0
		var total_storm := 0.0
		for window in normal: total_normal += float(window.last)-float(window.first)
		for window in stormy_windows: total_storm += float(window.last)-float(window.first)
		check(total_storm < total_normal,"La couverture réduite est plus courte (emplacement %d)" % slot)
	var other := Model.new(true)
	other.buy(3,0);other.start()
	check(not other.defenders[3].has("storm_windows"),"Sans affixe : aucune fenêtre de tempête")

func play_wave(affix: Dictionary, step: float, hp: int = 150) -> Dictionary:
	var model := Model.new(true)
	model.configure_combat_affix(affix)
	model.configure_enemy_hp(hp)
	model.rng.seed = 7
	model.buy(3,0);model.buy(4,1)
	model.wave = 1
	model.start()
	var guard := 0
	while model.active and guard < 300000:
		model.advance(step);guard += 1
	var storms := 0
	for line in model.event_log: if line.contains("tempête"): storms += 1
	return {"killed":model.killed,"escaped":model.escaped,"gold":model.gold,"hp":model.fortress_hp,"elapsed":model.elapsed,"log":model.event_log.duplicate(),"log_count":storms}

func verify_effect() -> void:
	var with_storm: Dictionary = play_wave(AFFIX,10000.0)
	var without: Dictionary = play_wave({},10000.0)
	check(with_storm.killed <= without.killed and with_storm.escaped >= without.escaped,"La tempête ne renforce jamais la défense")
	check(with_storm.log_count >= 2 and without.log_count == 0,"Des frontières de tempête seulement avec l'affixe")
	var strong: Dictionary = {"id":"sandstorm","interval":10,"warning":1,"duration":9,"range_percent":60}
	var harsh: Dictionary = play_wave(strong,10000.0)
	check(harsh.killed <= with_storm.killed and harsh.hp <= with_storm.hp,"Une tempête plus longue et plus forte affaiblit davantage la défense")

func verify_step_independence() -> void:
	var big: Dictionary = play_wave(AFFIX,10000.0)
	var small: Dictionary = play_wave(AFFIX,0.05)
	var odd: Dictionary = play_wave(AFFIX,0.731)
	check(big.log_count >= 2,"La vague de contrôle contient plusieurs frontières")
	check(big.log == small.log and big.killed == small.killed and big.escaped == small.escaped and big.gold == small.gold and big.hp == small.hp,"Même déroulement avec un grand pas et des pas de 50 ms")
	check(big.log == odd.log and big.killed == odd.killed and big.escaped == odd.escaped and big.gold == odd.gold,"Même déroulement avec des pas irréguliers")

func verify_replay() -> void:
	var model := Model.new(true)
	model.configure_combat_affix(AFFIX)
	model.rng.seed = 7
	model.select_faction(0)
	model.buy(3,0);model.buy(4,1)
	for wave in range(1,11):
		if wave == 2: model.upgrade(3)
		if wave >= 2 and model.defenders[2].is_empty(): model.buy(2,2)
		if wave >= 5:
			for slot in [3,4,2]:
				if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level == 3 else -1)
		model.start();model.advance(10000)
		if model.phase == "defeat": break
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if wave < 10: model.prepare_next_wave()
	var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
	check(report.combat_affix == JSON.parse_string(JSON.stringify(AFFIX)),"Le rapport enregistre l'affixe")
	check(Replay.verify(report).ok,"Le rapport d'une partie avec tempêtes se rejoue à l'identique")
	check(Report.markdown(report).contains("Tempête de sable · toutes les 15 s"),"Le rapport lisible décrit l'affixe")
	var tampered: Dictionary = report.duplicate(true);tampered.combat_affix.interval = 10
	check(not Replay.verify(tampered).ok,"Un affixe modifié ne se rejoue pas à l'identique")
	var broken: Dictionary = report.duplicate(true);broken.combat_affix.range_percent = 1
	check(not Replay.verify(broken).ok,"Un affixe invalide interdit le rejeu")
	var removed: Dictionary = report.duplicate(true);removed.erase("combat_affix")
	check(not Replay.verify(removed).ok,"Un rapport dont l'affixe a été retiré n'est plus rejouable à l'identique")

func verify_rendering() -> void:
	Library.clear_cache()
	var spec := {"version":1,"id":"effect.sandstorm","display_height":100,"foot":[0,0],"animations":{
		"warning":{"file":"warning.png","frames":6,"frame_size":[64,40],"mode":"progress"},
		"storm":{"file":"storm.png","frames":8,"frame_size":[64,40],"mode":"time","fps":8}}}
	check(Library.validation_error(spec) == "","Description de l'effet de tempête valide")
	var wrong: Dictionary = spec.duplicate(true);wrong.animations.storm = {"file":"s.png","frames":4,"frame_size":[64,40],"mode":"event","duration":1.0}
	check(Library.validation_error(wrong) != "","La rafale boucle : mode time obligatoire")
	var warning_strip := Image.create(6*64,40,false,Image.FORMAT_RGBA8);warning_strip.fill(Color(1,0.8,0.4,0.3))
	var storm_strip := Image.create(8*64,40,false,Image.FORMAT_RGBA8);storm_strip.fill(Color(1,0.8,0.4,0.5))
	Library.register_for_test("effect.sandstorm",spec,{"warning":ImageTexture.create_from_image(warning_strip),"storm":ImageTexture.create_from_image(storm_strip)})
	var model := stormy()
	model.start()
	var view := View.new();view.model = model;root.add_child(view)
	for time in [12.5,16.0]:
		model.advance(time-model.elapsed)
		var before: String = JSON.stringify([model.gold,model.rng.state,model.defenders,model.storm_status()])
		view.queue_redraw()
		await process_frame
		await process_frame
		check(before == JSON.stringify([model.gold,model.rng.state,model.defenders,model.storm_status()]) and not model.storm_status().is_empty(),"Dessiner la tempête à %.1f s (planches) ne modifie pas le jeu" % time)
	view.free()
	Library.clear_cache()
	var bare := View.new();bare.model = model;root.add_child(bare)
	await process_frame
	bare.queue_redraw()
	await process_frame
	check(not model.storm_status().is_empty(),"Sans planche : repère provisoire dessiné sans erreur")
	bare.free()

## Désactivation d'une éruption par planche (`effect.eruption/disabled`) : dessinée sans modifier le jeu, repli sur le repère sans planche.
func verify_eruption_ash() -> void:
	Library.clear_cache()
	var spec := {"version":1,"id":"effect.eruption","display_height":60,"foot":[40,40],"animations":{
		"warning":{"file":"warning.png","frames":24,"frame_size":[80,60],"mode":"progress"},
		"disabled":{"file":"disabled.png","frames":60,"frame_size":[80,60],"mode":"event","duration":5.0}}}
	check(Library.validation_error(spec) == "","Description de l'effet d'éruption valide")
	var warning_strip := Image.create(24*80,60,false,Image.FORMAT_RGBA8);warning_strip.fill(Color(1,0.4,0.1,0.4))
	var ash_strip := Image.create(60*80,60,false,Image.FORMAT_RGBA8);ash_strip.fill(Color(0.4,0.4,0.4,0.6))
	Library.register_for_test("effect.eruption",spec,{"warning":ImageTexture.create_from_image(warning_strip),"disabled":ImageTexture.create_from_image(ash_strip)})
	var model := Model.new(true)
	model.configure_combat_affix({"id":"eruptions","interval":14,"warning":3,"duration":5})
	model.rng.seed = 7
	model.buy(3,0)
	model.start()
	model.advance(16.0)
	var view := View.new();view.model = model;root.add_child(view)
	var before: String = JSON.stringify([model.gold,model.rng.state,model.defenders,model.eruption_status()])
	view.queue_redraw()
	await process_frame
	await process_frame
	check(model.eruption_status().get("state","") == "active" and before == JSON.stringify([model.gold,model.rng.state,model.defenders,model.eruption_status()]),"Cendres dessinées pendant la désactivation sans modifier le jeu")
	view.free()
	Library.clear_cache()
	Library.register_for_test("effect.eruption",{})
	var bare := View.new();bare.model = model;root.add_child(bare)
	await process_frame
	bare.queue_redraw()
	await process_frame
	check(model.eruption_status().get("state","") == "active","Sans planche : repère provisoire de désactivation")
	bare.free()
	Library.clear_cache()
