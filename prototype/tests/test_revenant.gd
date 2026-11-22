extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const Library = preload("res://scripts/animation_library.gd")
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
	verify_rise_animation()
	verify_rise_anchor()
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

## Animation de relève (`rise`) : acceptée en mode event, prioritaire à l'état d'ennemi pendant sa durée, horodatée par le moteur.
func verify_rise_animation() -> void:
	var spec := {"version":1,"id":"enemy.test.rise","display_height":40,"foot":[20,38],"animations":{
		"walk":{"file":"walk.png","frames":8,"frame_size":[64,64],"mode":"distance","stride":16},
		"rise":{"file":"rise.png","frames":24,"frame_size":[64,64],"mode":"event","duration":0.72}}}
	check(Library.validation_error(spec) == "","Description avec animation de relève valide")
	var wrong: Dictionary = spec.duplicate(true);wrong.animations.rise = {"file":"r.png","frames":8,"frame_size":[64,64],"mode":"time","fps":8}
	check(Library.validation_error(wrong) != "","La relève se joue une fois : mode event obligatoire")
	var long_rise: Dictionary = spec.duplicate(true);long_rise.animations.rise.duration = 4.0
	check(Library.validation_error(long_rise) != "","La relève est limitée à 3 s")
	check(Library.enemy_state(spec.duplicate(true),{"rise_age":0.3}) == "rise" and Library.enemy_state(spec,{"rise_age":0.8}) == "walk" and Library.enemy_state(spec,{}) == "walk","L'état rise ne dure que 0,72 s après la relève")
	# Le moteur horodate la relève sur le temps de combat.
	var model := necro()
	model.gold = 800;model.select_faction(0)
	model.buy(3,0);model.buy(4,1);model.buy(2,1)
	var stamped := false
	for wave in range(1,7):
		model.start()
		var guard := 0
		while model.phase == "combat" and guard < 5000:
			model.advance(0.25);guard += 1
			for enemy in model.enemies:
				if enemy.get("risen",false):
					stamped = enemy.has("risen_at") and float(enemy.risen_at) <= model.elapsed+0.000001 and model.elapsed-float(enemy.risen_at) < 100.0
		if stamped or model.phase == "defeat": break
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if wave < 6: model.prepare_next_wave()
	check(stamped,"Un revenant relevé porte l'instant de sa relève")

## Appui de la relève (v0.242, lot 7cdfeaf de Codex) : le moteur garde sa règle (le revenant avance pendant la relève) ; l'affichage tient l'appui au
## point de chute pendant les poses basses, puis le raccorde progressivement le long de la route jusqu'à la fin de la relève.
func verify_rise_anchor() -> void:
	const View = preload("res://scripts/valley_view.gd")
	check(View.rise_weight(0.0,0.27,0.72) == 0.0 and View.rise_weight(0.2,0.27,0.72) == 0.0 and View.rise_weight(0.27,0.27,0.72) == 0.0,"Poses basses : appui fixe")
	check(View.rise_weight(0.72,0.27,0.72) == 1.0 and View.rise_weight(2.0,0.27,0.72) == 1.0 and View.rise_weight(0.5,0.27,0.27) == 1.0,"Fin de relève : position du moteur")
	check(View.rise_weight(0.4,0.27,0.72) > 0.0 and View.rise_weight(0.4,0.27,0.72) < View.rise_weight(0.6,0.27,0.72) and View.rise_weight(0.6,0.27,0.72) < 1.0,"Raccord progressif entre 0,27 et 0,72 s")
	var model := necro()
	model.gold = 800;model.select_faction(0)
	model.buy(3,0);model.buy(4,1);model.buy(2,1)
	var risen: Dictionary = {}
	for wave in range(1,7):
		model.start()
		var guard := 0
		while model.phase == "combat" and guard < 20000 and risen.is_empty():
			model.advance(0.02);guard += 1
			for enemy in model.enemies:
				if enemy.get("risen",false) and model.elapsed-float(enemy.risen_at) < 0.03: risen = enemy
		if not risen.is_empty() or model.phase == "defeat": break
		if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
		if wave < 6: model.prepare_next_wave()
	check(not risen.is_empty() and risen.has("risen_distance") and float(risen.risen_distance) <= float(risen.distance)+0.000001,"Le moteur note le point de chute du revenant")
	if risen.is_empty(): return
	check(is_equal_approx(float(risen.hp),float(risen.max_hp)*0.5),"Règle inchangée : relève avec la moitié des PV")
	var view := View.new();view.model = model
	var points: Array[Vector2] = model.enemy_route_points(risen)
	var length: float = model.enemy_route_length(risen)
	var fall: Vector2 = View.project(model.position_at(float(risen.risen_distance),points,length))
	var start: float = float(risen.risen_at)
	var speed: float = float(risen.speed)
	for age in [0.0,0.1,0.2,0.26]:
		model.elapsed = start+age;risen.distance = float(risen.risen_distance)+speed*age
		check(View.project(model.position_at(view.display_distance(risen),points,length)).is_equal_approx(fall),"Relève à %.2f s : appui au point de chute, le moteur a avancé de %.1f px" % [age,View.project(model.position_at(float(risen.distance),points,length)).distance_to(fall)])
	var previous: float = float(risen.risen_distance)
	for age in [0.35,0.45,0.55,0.65]:
		model.elapsed = start+age;risen.distance = float(risen.risen_distance)+speed*age
		var shown: float = view.display_distance(risen)
		check(shown > previous and shown < float(risen.distance),"Relève à %.2f s : l'appui rejoint progressivement le moteur sur la route" % age)
		previous = shown
	model.elapsed = start+0.72;risen.distance = float(risen.risen_distance)+speed*0.72
	check(is_equal_approx(view.display_distance(risen),float(risen.distance)),"Fin de relève : l'appui est celui du moteur")
	var walker: Dictionary = Model.make_enemy(9001,1,0.0,0,100);walker.distance = 3.0
	check(view.display_distance(walker) == 3.0,"Les autres ennemis gardent la position du moteur")
	view.free()
