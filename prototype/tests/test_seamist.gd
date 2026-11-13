extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const View = preload("res://scripts/valley_view.gd")
const AFFIX := {"id":"seamist","interval":22,"warning":3,"duration":6,"gold_percent":30}
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
	verify_rewards()
	verify_status()
	verify_step_independence()
	verify_replay()
	await verify_rendering()
	print("SEAMIST_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func misty(map_id: String = "coast_jetty") -> Model:
	var model := Model.new(true,Model.Maps.for_id(map_id))
	check(model.configure_combat_affix(AFFIX),"Affixe Brume marine accepté sur %s" % map_id)
	model.rng.seed = 7
	return model

func verify_validation() -> void:
	for valid in [AFFIX,{"id":"seamist","interval":10,"warning":1,"duration":2,"gold_percent":10},{"id":"seamist","interval":40,"warning":4,"duration":12,"gold_percent":60}]:
		var model := Model.new(true,Model.Maps.for_id("coast_jetty"))
		check(model.configure_combat_affix(valid),"Affixe valide accepté : %s" % JSON.stringify(valid))
	var single := Model.new(true)
	check(single.configure_combat_affix(AFFIX),"La brume ne dépend pas du nombre d'entrées")
	var invalid: Array = [{"id":"seamist"},{"id":"seamist","interval":22,"warning":3,"duration":6},{"id":"seamist","interval":22,"warning":3,"duration":6,"gold_percent":30,"extra":1},
		{"id":"seamist","interval":9,"warning":3,"duration":6,"gold_percent":30},{"id":"seamist","interval":41,"warning":3,"duration":6,"gold_percent":30},
		{"id":"seamist","interval":22,"warning":0,"duration":6,"gold_percent":30},{"id":"seamist","interval":22,"warning":5,"duration":6,"gold_percent":30},
		{"id":"seamist","interval":22,"warning":3,"duration":1,"gold_percent":30},{"id":"seamist","interval":22,"warning":3,"duration":13,"gold_percent":30},
		{"id":"seamist","interval":22,"warning":3,"duration":6,"gold_percent":9},{"id":"seamist","interval":22,"warning":3,"duration":6,"gold_percent":61},
		{"id":"seamist","interval":10,"warning":4,"duration":6,"gold_percent":30},{"id":"seamist","interval":22.5,"warning":3,"duration":6,"gold_percent":30},
		{"id":"seamist","interval":22,"warning":3,"duration":6,"gold_percent":"30"},{"id":"seamist","interval":22,"warning":3,"duration":6,"gold_percent":INF},{"id":"seamist","interval":22,"warning":NAN,"duration":6,"gold_percent":30}]
	for bad in invalid:
		var model := Model.new(true,Model.Maps.for_id("coast_jetty"))
		check(not model.configure_combat_affix(bad) and model.combat_affix.is_empty(),"Affixe mal formé refusé sans effet : %s" % str(bad))
	var started := Model.new(true,Model.Maps.for_id("coast_jetty"));started.buy(3,0)
	check(not started.configure_combat_affix(AFFIX),"Affixe refusé après une action")

func verify_texts() -> void:
	var model := misty()
	check(model.affix_description() == "Brume marine · or d'élimination −30 % pendant 6 s toutes les 22 s","Description courte de l'affixe")
	check(model.affix_tooltip().contains("22 s") and model.affix_tooltip().contains("30 %") and model.affix_tooltip().contains("6 s") and model.affix_tooltip().contains("3 s") and model.affix_tooltip().contains("Réglage d’essai"),"Info-bulle d'essai complète")
	var plain := Model.new(true)
	check(not plain.mist_enabled() and plain.mist_status().is_empty() and not plain.mist_active_now() and plain.kill_reward(7) == 7,"Sans affixe, aucune brume ni réduction d'or")

func verify_rewards() -> void:
	var model := misty()
	model.gold = 600;model.select_faction(0);model.buy(3,0)
	model.start()
	check(model.kill_reward(7) == 7 and model.kill_reward(1) == 1,"Hors brume, l'or d'élimination est inchangé")
	model.advance(22.0)
	check(model.mist_active_now() and model.kill_reward(1) == 1 and model.kill_reward(3) == 2 and model.kill_reward(7) == 5 and model.kill_reward(14) == 10 and model.kill_reward(20) == 14 and model.kill_reward(40) == 28,"Pendant la brume : −30 % arrondi à l'entier le plus proche, au moins 1 or")
	model.advance(5.9)
	check(model.mist_active_now(),"La brume dure 6 s")
	model.advance(0.2)
	check(not model.mist_active_now() and model.kill_reward(7) == 7,"La brume se dissipe après 6 s")

func verify_status() -> void:
	var model := misty()
	model.gold = 600;model.select_faction(0);model.buy(3,0)
	check(model.mist_status().is_empty(),"Hors combat, aucun état")
	model.start()
	check(model.mist_status().is_empty(),"Au début du combat, aucune brume annoncée")
	model.advance(19.0)
	var warning: Dictionary = model.mist_status()
	check(warning.get("state","") == "warning" and warning.number == 1 and absf(float(warning.remaining)-3.0) < 0.001,"À 19 s : avertissement de la brume 1")
	model.advance(3.5)
	var active: Dictionary = model.mist_status()
	check(active.get("state","") == "active" and absf(float(active.remaining)-5.5) < 0.001,"À 22,5 s : brume en cours")
	model.advance(6.0)
	check(model.mist_status().is_empty() or model.mist_status().get("state","") == "warning" and model.mist_status().number == 2,"Après 28,5 s : brume dissipée")

func play_wave(step: float) -> Dictionary:
	var model := misty()
	model.gold = 600;model.select_faction(0)
	model.buy(3,0);model.buy(4,1)
	model.start()
	var guard := 0
	while model.phase == "combat" and guard < 100000:
		model.advance(step);guard += 1
	return {"log":model.event_log.duplicate(),"gold":model.gold,"income":model.total_income,"hp":model.fortress_hp,"phase":model.phase,"killed":model.total_killed}

func verify_step_independence() -> void:
	var big: Dictionary = play_wave(10000.0)
	var small: Dictionary = play_wave(0.05)
	var odd: Dictionary = play_wave(0.731)
	check(JSON.stringify(big) == JSON.stringify(small) and JSON.stringify(big) == JSON.stringify(odd),"Même déroulement et même or avec un grand pas, des pas de 50 ms et des pas irréguliers")
	var plain := Model.new(true,Model.Maps.for_id("coast_jetty"))
	plain.rng.seed = 7;plain.gold = 600;plain.select_faction(0);plain.buy(3,0);plain.buy(4,1);plain.start();plain.advance(10000.0)
	check(int(big.income) < plain.total_income,"La brume réduit réellement l'or gagné sur une vague longue (%d contre %d)" % [int(big.income),plain.total_income])

func verify_replay() -> void:
	for faction in range(2):
		var model := misty()
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
		check(report.has("combat_affix") and report.combat_affix.id == "seamist" and int(report.combat_affix.gold_percent) == 30,"Le rapport conserve l'affixe")
		var replay: Dictionary = Replay.verify(report)
		check(replay.ok,"Le rapport de la faction %d est rejouable : %s" % [faction,str(replay.get("error",""))])
		check(Report.markdown(report).contains("Brume marine · toutes les 22 s de combat"),"Le rapport lisible décrit la brume")
		var tampered: Dictionary = report.duplicate(true)
		tampered.combat_affix.gold_percent = 20
		check(not Replay.verify(tampered).ok,"Un rapport dont l'affixe est modifié n'est plus rejouable")

func verify_rendering() -> void:
	var model := misty()
	model.gold = 600;model.select_faction(0);model.buy(3,0)
	var view := View.new();view.model = model;root.add_child(view)
	model.start()
	for time in [10.0,10.0,3.0,4.0,5.0]:
		model.advance(time)
		await process_frame
	check(model.elapsed > 0.0,"Le combat avance pendant le dessin")
	view.free()
