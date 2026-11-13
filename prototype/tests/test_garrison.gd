extends SceneTree
const Model = preload("res://scripts/valley_model.gd")
const Garrison = preload("res://scripts/garrison_encounters.gd")
const Enemies = preload("res://scripts/enemy_catalogue.gd")
const Art = preload("res://scripts/enemy_art.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const View = preload("res://scripts/valley_view.gd")
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
	verify_catalogue()
	verify_waves()
	verify_replay()
	print("GARRISON_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func verify_definition() -> void:
	var definition: Dictionary = Model.enemy_definition(Garrison.TYPE)
	check(Garrison.TYPE == 10 and definition == Garrison.DEFINITION and definition.name == "Capitaine de garnison","Définition de la Garnison")
	check(float(definition.hp) > float(Model.ENEMY_TYPES[6].hp) and float(definition.hp) < float(Model.ENEMY_TYPES[7].hp) and float(definition.speed) < float(Model.ENEMY_TYPES[6].speed),"La Garnison est plus résistante que l'élite et plus lente, sans égaler le boss")
	check(is_equal_approx(Model.scaled_enemy_hp(Garrison.TYPE,150),780.0) and is_equal_approx(Model.scaled_enemy_hp(Garrison.TYPE),520.0),"PV de la Garnison mis à l'échelle de la difficulté")

func verify_catalogue() -> void:
	check(View._enemy_scale({"type":10}) > View._enemy_scale({"type":6}) and View.enemy_color(10) != View.enemy_color(6),"La vue dessine la Garnison avec sa propre échelle et sa couleur")
	for faction in [0,1]:
		var identity: Dictionary = Enemies.for_profile(10,faction)
		check(identity.origin == ("horde" if faction == 0 else "alliance") and identity.profile == 10 and identity.name.begins_with("Capitaine de garnison"),"Identité de la Garnison face à la faction %d" % faction)
		check(Art.TEXTURES.has(identity.id) and Art.FRAMES.has(identity.id),"Silhouette provisoire pour %s" % identity.id)
		check(Enemies.by_id(identity.id,faction) == identity and Enemies.available(faction,Garrison.ID).any(func(item):return item.profile == 10),"Catalogue de la citadelle contenant la Garnison")
		check(not Enemies.available(faction).any(func(item):return item.profile == 10) and not Enemies.available(faction,"marsh_drowned").any(func(item):return item.profile == 10),"La Garnison reste propre à la citadelle")
		check(Enemies.available(faction,Garrison.ID).size() == 9,"Neuf identités dans la citadelle")
	check(Enemies.for_profile(12,0).is_empty() and Enemies.for_profile(-1,0).is_empty(),"Profils hors catalogue refusés")

func verify_waves() -> void:
	check(Garrison.WAVES.size() == 10,"Dix vagues")
	var counts: Array[int] = []
	for wave in Garrison.WAVES: counts.append(wave.filter(func(group):return group[0] == Garrison.TYPE).size())
	check(counts == [0,0,0,0,1,0,1,0,1,1],"La Garnison accompagne les vagues 5, 7, 9 et 10")
	var model := Model.new(true)
	check(model.configure_wave_set(Garrison.ID) and model.wave_set_id == Garrison.ID,"Ensemble de vagues accepté")
	check(not Model.new(true).configure_wave_set("citadel_unknown"),"Ensemble inconnu refusé")
	check(Model.Campaign.waves_for(Garrison.ID) == Garrison.WAVES and Model.Campaign.waves_for("ford") != Garrison.WAVES,"Rencontres propres à la citadelle")
	for number in range(1,11):
		for spawn in Model.Campaign.schedule(number,Garrison.ID): check(spawn.type >= 0 and spawn.type <= 10,"Types de la vague %d valides" % number)
	var forecast: Dictionary = model.wave_forecast(5,0,150,Garrison.ID)
	check(forecast.groups.any(func(group):return group.type == 10 and is_equal_approx(float(group.hp),780.0)),"Prévision de la vague 5 avec la Garnison")

func verify_replay() -> void:
	for faction in [0,1]:
		var model := Model.new(true)
		model.configure_wave_set(Garrison.ID);model.configure_enemy_hp(191);model.select_faction(faction);model.rng.seed = 7
		var types: Array = [0,1,1] if faction == 0 else [3,3,5]
		model.buy(3,types[0]);model.buy(4,types[1])
		for wave in range(1,11):
			if wave >= 2 and model.defenders[2].is_empty(): model.buy(2,types[2])
			model.start();model.advance(10000)
			if model.phase == "defeat": break
			if model.phase == "bonus": model.choose_bonus(model.bonus_offer[0])
			if wave < 10: model.prepare_next_wave()
		var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
		check(report.wave_set_id == Garrison.ID and report.enemy_catalog.any(func(item):return item.profile == 10),"Le rapport décrit la citadelle et la Garnison (faction %d)" % faction)
		check(Replay.verify(report).ok,"Le rapport de la citadelle se rejoue à l'identique (faction %d)" % faction)
		var tampered: Dictionary = report.duplicate(true);tampered.wave_set_id = "ford"
		check(not Replay.verify(tampered).ok,"Changer l'ensemble de vagues interdit le rejeu")
