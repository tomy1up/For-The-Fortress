extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_definition()
	verify_rise_once()
	verify_step_independence()
	verify_replay()
	print("REVENANT_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func necro() -> Model:
	var model := Model.new(true,Model.Maps.for_id("necro_gate"))
	check(model.configure_wave_set("necro_revenants"),"Jeu de rencontres du revenant accepté")
	model.configure_enemy_hp(260)
	model.rng.seed = 7
	return model

func verify_definition() -> void:
	var enemy: Dictionary = Model.make_enemy(1,12,0.0,0,260)
	check(not enemy.is_empty() and enemy.name == "Revenant" and enemy.origin == "neutral" and is_equal_approx(enemy.max_hp,30.0*2.6) and enemy.hp == enemy.max_hp,"Le revenant naît avec ses PV pleins, neutre pour la faction défendue")
	var forecast: Dictionary = necro().wave_forecast(4,0,260,"necro_revenants")
	check(forecast.groups.any(func(group):return group.type == 12) and Model.Revenant.WAVES[3].any(func(group):return group[0] == 12),"La prévision de la vague 4 annonce les revenants")

func play(step: float, waves: int = 6) -> Dictionary:
	var model := necro()
	model.gold = 800;model.select_faction(0)
	model.buy(3,0);model.buy(4,1);model.buy(2,1)
	for wave in range(1,waves+1):
		if wave >= 2: model.upgrade(3,0 if model.defenders[3].level == 3 else -1)
		model.start()
		var guard := 0
		while model.phase == "combat" and guard < 100000:
			model.advance(step);guard += 1
		if model.phase == "defeat": break
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if wave < waves: model.prepare_next_wave()
	return {"log":model.event_log.duplicate(),"gold":model.gold,"income":model.total_income,"killed":model.total_killed,"hp":model.fortress_hp,"phase":model.phase}

func verify_rise_once() -> void:
	var result: Dictionary = play(10000.0)
	var rises: Array = result.log.filter(func(line):return str(line).contains(" relève "))
	var deaths: Array = result.log.filter(func(line):return str(line).contains(" mort "))
	check(rises.size() >= 1,"Des revenants se relèvent pendant les quatre premières vagues (%d)" % rises.size())
	var rise_ids: Dictionary = {}
	for line in rises:
		var id: int = int(str(line).split(" ")[2])
		check(not rise_ids.has(id),"Un revenant ne se relève qu'une fois (id %d)" % id)
		rise_ids[id] = true
	# Chaque revenant mort s'est relevé avant sa mort, et sa mort rapporte la récompense du revenant.
	var order: Dictionary = {}
	for index in range(result.log.size()):
		var parts: PackedStringArray = str(result.log[index]).split(" ")
		if parts.size() >= 3 and parts[1] == "relève": order[int(parts[2])] = index
	var revenant_deaths := 0
	for index in range(result.log.size()):
		var parts: PackedStringArray = str(result.log[index]).split(" ")
		if parts.size() >= 4 and parts[1] == "mort" and order.has(int(parts[2])):
			revenant_deaths += 1
			check(int(order[int(parts[2])]) < index and parts[3] == "+%d" % Model.Revenant.DEFINITION.reward,"Le revenant meurt après s'être relevé et rapporte %d or" % Model.Revenant.DEFINITION.reward)
	check(revenant_deaths >= 1 and deaths.size() > revenant_deaths,"Au moins un revenant est éliminé pour de bon, parmi les autres ennemis")

func verify_step_independence() -> void:
	var big: Dictionary = play(10000.0)
	var small: Dictionary = play(0.05)
	var odd: Dictionary = play(0.731)
	check(JSON.stringify(big) == JSON.stringify(small) and JSON.stringify(big) == JSON.stringify(odd),"Même déroulement, relèves comprises, avec un grand pas, des pas de 50 ms et des pas irréguliers")

func verify_replay() -> void:
	for faction in range(2):
		var model := necro()
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
		check(report.get("wave_set_id","") == "necro_revenants","Le rapport conserve le jeu de rencontres du revenant")
		var replay: Dictionary = Replay.verify(report)
		check(replay.ok,"Le rapport de la faction %d est rejouable : %s" % [faction,str(replay.get("error",""))])
