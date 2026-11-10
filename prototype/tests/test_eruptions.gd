extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const AFFIX := {"id":"eruptions","interval":14,"warning":2,"duration":5}
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
	verify_choice()
	verify_timeline()
	verify_disabling()
	verify_step_independence()
	verify_replay()
	print("ERUPTIONS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func army_model(types: Array = [0,1,2], slots: Array = [3,4,2]) -> Model:
	var model := Model.new(true)
	check(model.configure_combat_affix(AFFIX),"Affixe Éruptions accepté")
	model.rng.seed = 7
	model.gold = 600 # Essai de la règle seule : trois défenseurs sans attendre les revenus.
	for index in range(types.size()): check(model.buy(slots[index],types[index]),"Défenseur acheté pour l'essai")
	return model

func verify_validation() -> void:
	for valid in [AFFIX,{"id":"eruptions","interval":8,"warning":1,"duration":2},{"id":"eruptions","interval":40,"warning":4,"duration":12},{"id":"eruptions","interval":14.0,"warning":2.0,"duration":5.0},{"id":"headwinds","cadence_percent":90},{}]:
		var model := Model.new(true)
		check(model.configure_combat_affix(valid),"Affixe valide accepté : %s" % JSON.stringify(valid))
	var invalid: Array = [null,"eruptions",[],{"id":"eruptions"},{"id":"eruptions","interval":14,"warning":2},{"id":"eruptions","interval":14,"warning":2,"duration":5,"extra":1},
		{"id":"storm","interval":14,"warning":2,"duration":5},{"id":"eruptions","interval":7,"warning":1,"duration":2},{"id":"eruptions","interval":41,"warning":2,"duration":5},
		{"id":"eruptions","interval":14,"warning":0,"duration":5},{"id":"eruptions","interval":14,"warning":5,"duration":5},{"id":"eruptions","interval":14,"warning":2,"duration":1},
		{"id":"eruptions","interval":14,"warning":2,"duration":13},{"id":"eruptions","interval":8,"warning":3,"duration":5},{"id":"eruptions","interval":14.5,"warning":2,"duration":5},
		{"id":"eruptions","interval":14,"warning":2.5,"duration":5},{"id":"eruptions","interval":"14","warning":2,"duration":5},{"id":"eruptions","interval":14,"warning":2,"duration":INF},
		{"id":"eruptions","interval":14,"warning":NAN,"duration":5},{"id":"eruptions","interval":14,"warning":2,"duration":true},{"id":"headwinds"},{"cadence_percent":90}]
	for bad in invalid:
		var model := Model.new(true)
		check(not model.configure_combat_affix(bad) and model.combat_affix.is_empty(),"Affixe mal formé refusé sans effet : %s" % str(bad))
	var started := Model.new(true)
	started.buy(3,0)
	check(not started.configure_combat_affix(AFFIX),"Affixe refusé après une action")
	var later := Model.new(true);later.wave = 2
	check(not later.configure_combat_affix(AFFIX),"Affixe refusé hors de la première vague")

func verify_texts() -> void:
	var model := army_model()
	check(model.affix_description() == "Éruptions · un défenseur désactivé 5 s toutes les 14 s","Description courte de l'affixe")
	check(model.affix_tooltip().contains("14 s") and model.affix_tooltip().contains("5 s") and model.affix_tooltip().contains("2 s") and model.affix_tooltip().contains("Réglage d’essai"),"Infobulle de l'affixe")
	var plain := Model.new(true)
	check(plain.affix_description() == "" and plain.affix_tooltip() == "" and not plain.eruption_enabled() and plain.eruption_status().is_empty(),"Sans affixe : aucun texte ni éruption")
	var winds := Model.new(true);winds.configure_combat_affix({"id":"headwinds","cadence_percent":90})
	check(winds.affix_description().begins_with("Vents contraires") and winds.affix_tooltip().contains("10 %") and not winds.eruption_enabled(),"Vents contraires inchangé")

func verify_choice() -> void:
	var model := army_model()
	model.start()
	var seen := {}
	for number in range(1,61):
		var slot: int = model.eruption_slot(number)
		check(slot in [2,3,4],"L'éruption %d frappe un défenseur en place" % number)
		seen[slot] = true
		check(slot == model.eruption_slot(number),"Le choix de l'éruption %d est stable" % number)
	check(seen.size() == 3,"Sur soixante éruptions, les trois défenseurs sont touchés")
	var lone := army_model([0],[4]);lone.start()
	for number in range(1,12): check(lone.eruption_slot(number) == 4,"Un seul défenseur : toujours lui")
	var empty := Model.new(true);empty.configure_combat_affix(AFFIX);empty.start()
	check(empty.eruption_slot(1) == -1 and empty.eruption_status().is_empty(),"Sans défenseur : aucune éruption")
	var other_seed := army_model();other_seed.rng.seed = 8;other_seed.start()
	var differs := false
	for number in range(1,20): differs = differs or other_seed.eruption_slot(number) != model.eruption_slot(number)
	check(differs,"Une autre graine donne d'autres éruptions")

func verify_timeline() -> void:
	var model := army_model()
	model.start()
	check(model.eruption_status().is_empty(),"Rien au début du combat")
	model.advance(11.9)
	check(model.eruption_status().is_empty(),"Rien avant le délai d'annonce")
	model.advance(0.1)
	var warning: Dictionary = model.eruption_status()
	check(warning.get("state") == "warning" and warning.slot == model.eruption_slot(1) and warning.number == 1 and is_equal_approx(warning.remaining,2.0),"Annonce 2 s avant la première éruption")
	model.advance(2.0)
	var active: Dictionary = model.eruption_status()
	check(active.get("state") == "active" and active.slot == warning.slot and is_equal_approx(active.remaining,5.0),"Désactivation de 5 s à 14 s")
	model.advance(4.9)
	check(model.eruption_status().get("state") == "active","Toujours désactivé à 18,9 s")
	model.advance(0.1)
	check(model.eruption_status().is_empty(),"Fin de la désactivation à 19 s")
	model.advance(7.0)
	var second: Dictionary = model.eruption_status()
	check(second.get("state") == "warning" and second.number == 2 and second.slot == model.eruption_slot(2),"Seconde annonce à 26 s")
	var before: String = JSON.stringify(model.eruption_status())
	check(before == JSON.stringify(model.eruption_status()),"Lire l'état ne modifie rien")

func verify_disabling() -> void:
	var model := army_model()
	model.start()
	var struck: int = model.eruption_slot(1)
	model.advance(13.99)
	check(float(model.defenders[struck].ready_at) < 19.0-0.0001,"Avant l'éruption, le défenseur n'est pas encore désactivé")
	model.advance(0.01)
	check(float(model.defenders[struck].ready_at) >= 19.0-0.000001,"Le défenseur frappé ne tire plus avant 19 s")
	var others_ready := true
	for slot in range(model.defenders.size()):
		if slot != struck and not model.defenders[slot].is_empty() and float(model.defenders[slot].ready_at) >= 19.0-0.000001: others_ready = false
	check(others_ready,"Les autres défenseurs ne sont pas touchés")
	check(model.event_log.any(func(line):return line.contains("éruption 1 emplacement %d" % struck)),"L'éruption est journalisée")
	model.advance(5.0)
	var fired_during := false
	for shot in model.shots:
		if shot.slot == struck and shot.time > 14.0+0.000001 and shot.time < 19.0-0.000001: fired_during = true
	check(not fired_during,"Aucun tir du défenseur frappé pendant sa désactivation")
	# Comparaison avec et sans affixe : l'affixe ne peut qu'affaiblir la défense.
	var with_affix: Dictionary = play_wave(AFFIX,10000.0)
	var without: Dictionary = play_wave({},10000.0)
	check(with_affix.killed <= without.killed and with_affix.escaped >= without.escaped,"L'affixe ne renforce jamais la défense")
	check(with_affix.log_count >= 1 and without.log_count == 0,"Des éruptions seulement avec l'affixe")

func play_wave(affix: Dictionary, step: float) -> Dictionary:
	var model := Model.new(true)
	model.configure_combat_affix(affix)
	model.configure_enemy_hp(120)
	model.rng.seed = 7
	model.buy(3,0);model.buy(4,1)
	model.wave = 1
	model.start()
	var guard := 0
	while model.active and guard < 300000:
		model.advance(step);guard += 1
	var eruptions := 0
	for line in model.event_log: if line.contains("éruption"): eruptions += 1
	return {"killed":model.killed,"escaped":model.escaped,"gold":model.gold,"hp":model.fortress_hp,"elapsed":model.elapsed,"log":model.event_log.duplicate(),"log_count":eruptions}

func verify_step_independence() -> void:
	var big: Dictionary = play_wave(AFFIX,10000.0)
	var small: Dictionary = play_wave(AFFIX,0.05)
	var odd: Dictionary = play_wave(AFFIX,0.731)
	check(big.log_count >= 2,"La vague de contrôle contient plusieurs éruptions")
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
	check(Replay.verify(report).ok,"Le rapport d'une partie avec éruptions se rejoue à l'identique")
	check(Report.markdown(report).contains("Éruptions · toutes les 14 s"),"Le rapport lisible décrit l'affixe")
	var tampered: Dictionary = report.duplicate(true);tampered.combat_affix.interval = 5
	check(not Replay.verify(tampered).ok,"Un affixe invalide interdit le rejeu")
	var removed: Dictionary = report.duplicate(true);removed.erase("combat_affix")
	check(not Replay.verify(removed).ok,"Un rapport dont l'affixe a été retiré n'est plus rejouable à l'identique")
