extends SceneTree
## Renforts de vague par mission et par faction (v0.252) : validation, calendrier, prévision, rapport rejouable, catalogue et lancement en campagne.
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const Catalogue = preload("res://scripts/campaign_catalogue.gd")
const Report = preload("res://scripts/run_report.gd")
const Replay = preload("res://tests/report_replay.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Scout = preload("res://scripts/mission_scout.gd")
const SAMPLE: Array = [[3,2,5,0.6],[5,4,2,1.5],[3,0,4,0.4]]
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")

func run_checks() -> void:
	verify_validation()
	verify_schedule()
	verify_model_and_forecast()
	verify_report_replay()
	verify_catalogue()
	verify_campaign_launch()
	print("WAVE_REINFORCEMENTS_TESTS checks=%d failures=%d" % [checks,failures])
	quit(0 if failures == 0 else 1)

func verify_validation() -> void:
	var C = Model.Campaign
	check(C.valid_reinforcements([]) and C.valid_reinforcements(SAMPLE),"Renforts vides ou bien formés acceptés")
	check(C.valid_reinforcements([[3.0,2.0,5.0,0.6]]),"Nombres entiers relus d'un rapport JSON acceptés")
	for bad in [null,"3:2:5:0.6",[[0,2,5,0.6]],[[11,2,5,0.6]],[[3,7,1,0.6]],[[3,8,1,0.6]],[[3,-1,1,0.6]],[[3,2,0,0.6]],[[3,2,31,0.6]],[[3,2,5,0.1]],[[3,2,5,6.0]],[[3,2,5]],[[3.5,2,5,0.6]],[[3,2,5,INF]],[[3,2,5,"0.6"]],["3,2,5,0.6"]]:
		check(not C.valid_reinforcements(bad),"Renfort refusé : %s" % str(bad))
	var many: Array = []
	for index in range(21): many.append([1,0,1,1.0])
	check(not C.valid_reinforcements(many),"Au plus vingt groupes de renfort")

func verify_schedule() -> void:
	var C = Model.Campaign
	var before: String = JSON.stringify(C.waves_for("ford"))
	for wave in range(1,11):
		var base: Array[Dictionary] = C.schedule(wave,"ford")
		var reinforced: Array[Dictionary] = C.schedule(wave,"ford",SAMPLE)
		var added: int = 0
		var first_type: int = -1
		for extra in SAMPLE:
			if extra[0] == wave:
				added += extra[2]
				if first_type < 0: first_type = extra[1]
		check(reinforced.size() == base.size()+added,"Vague %d : renforts ajoutés au calendrier" % wave)
		for index in range(base.size()): check(reinforced[index].type == base[index].type and is_equal_approx(reinforced[index].time,base[index].time),"Vague %d : apparitions d'origine inchangées" % wave)
		if added > 0:
			check(is_equal_approx(reinforced[base.size()].time,base[-1].time+4.0) and reinforced[base.size()].type == first_type,"Vague %d : premier renfort quatre secondes après le dernier groupe" % wave)
	var third: Array[Dictionary] = C.schedule(3,"ford",SAMPLE)
	var start: int = C.schedule(3,"ford").size()
	check(is_equal_approx(third[start+4].time-third[start].time,4*0.6) and third[start+5].type == 0 and is_equal_approx(third[start+5].time,third[start+4].time+4.0),"Deux renforts de la même vague se suivent dans l'ordre donné")
	check(C.groups_for(3,"ford",SAMPLE).size() == C.waves_for("ford")[2].size()+2 and JSON.stringify(C.waves_for("ford")) == before,"Les jeux de vagues de référence ne sont pas modifiés")

func verify_model_and_forecast() -> void:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	check(m.configure_wave_reinforcements(SAMPLE) and m.wave_reinforcements == Model.Campaign.normalized_reinforcements(SAMPLE),"Renforts configurés avant la mission")
	check(not m.configure_wave_reinforcements([[3,7,1,0.6]]) and m.wave_reinforcements.size() == 3,"Renfort invalide refusé sans effet")
	check(typeof(m.wave_reinforcements[0][3]) == TYPE_FLOAT and typeof(m.wave_reinforcements[0][2]) == TYPE_INT,"Renforts normalisés")
	var forecast: Dictionary = Model.wave_forecast(3,0,120,"ford",SAMPLE)
	var plain: Dictionary = Model.wave_forecast(3,0,120,"ford")
	check(forecast.groups.size() == plain.groups.size()+2 and forecast.total == plain.total+9,"La prévision montre les renforts de la vague")
	var sprinters: Dictionary = forecast.groups[plain.groups.size()]
	check(sprinters.type == 2 and sprinters.count == 5 and sprinters.hp == Model.scaled_enemy_hp(2,120) and forecast.income == plain.income+5*Model.ENEMY_TYPES[2].reward+4*Model.ENEMY_TYPES[0].reward,"Renforts affichés avec leurs PV et leur butin")
	check(Model.wave_forecast(3,0,120,"ford",[[3,7,1,0.6]]).is_empty(),"Prévision refusée pour des renforts invalides")
	check(m.select_faction(0) and m.forecast_for_routes(3).groups.size() == plain.groups.size()+2,"La prévision du modèle suit ses renforts")
	m.buy(0,0)
	check(not m.configure_wave_reinforcements([]) and m.wave_reinforcements.size() == 3,"Renforts figés après la première action")
	m.reset()
	check(m.wave_reinforcements.size() == 3 and m.spawn_schedule.size() == Model.Campaign.schedule(1,"ford",SAMPLE).size(),"Réessayer conserve les renforts de la mission")

func play_report(reinforcements: Array) -> Dictionary:
	var m = Model.new(true,Model.Maps.for_id("valley_ford"))
	m.configure_enemy_hp(120);m.configure_wave_reinforcements(reinforcements);m.select_faction(0)
	m.rng.seed = 7
	m.buy(3,0);m.buy(4,1)
	for wave in range(1,11):
		if wave == 2: m.buy(2,1)
		if not m.start(): break
		m.advance(10000)
		if m.phase == "defeat": break
		if m.phase == "bonus": m.choose_bonus(Model.reference_bonus(m.bonus_offer))
		if wave < 10: m.prepare_next_wave()
	return JSON.parse_string(JSON.stringify(Report.build(m)))

func verify_report_replay() -> void:
	var report: Dictionary = play_report(SAMPLE)
	check(report.get("wave_reinforcements",[]).size() == 3 and report.game_version == ProjectSettings.get_setting("application/config/version"),"Le rapport garde les renforts de la mission")
	var replay: Dictionary = Replay.verify(report)
	check(replay.ok,"Une partie avec renforts se rejoue : "+str(replay.get("error","")))
	var plain: Dictionary = play_report([])
	check(not plain.has("wave_reinforcements") and Replay.verify(plain).ok,"Sans renfort, le rapport garde son format")
	var removed: Dictionary = report.duplicate(true);removed.erase("wave_reinforcements")
	check(not Replay.verify(removed).ok,"Retirer les renforts d'un rapport le rend incohérent")
	var changed: Dictionary = report.duplicate(true);changed.wave_reinforcements[0][2] = 6
	check(not Replay.verify(changed).ok,"Modifier un renfort rend le rapport incohérent")
	var invalid: Dictionary = report.duplicate(true);invalid.wave_reinforcements = [[3,7,1,0.6]]
	check(not Replay.verify(invalid).ok and Replay.verify(invalid).get("error","") == "Renforts de mission invalides.","Renforts invalides refusés au rejeu")
	var old: Dictionary = report.duplicate(true);old.game_version = "0.251"
	check(not Replay.verify(old).ok and Replay.verify(old).get("error","") == "Renforts de mission invalides.","Un rapport d'avant la v0.252 ne peut pas porter de renforts")

func verify_catalogue() -> void:
	var total: int = 0
	for faction in [0,1]:
		for number in Catalogue.WAVE_REINFORCEMENTS[faction]:
			total += 1
			var extra: Array = Catalogue.wave_reinforcements(number,faction)
			check(number is int and number >= 1 and number <= Catalogue.TOTAL_MISSIONS and not extra.is_empty() and Model.Campaign.valid_reinforcements(extra),"Faction %d, mission %s : renforts valides" % [faction,str(number)])
			extra.clear()
			check(not Catalogue.wave_reinforcements(number,faction).is_empty(),"Le catalogue renvoie une copie de ses renforts")
			var scout: Array[Dictionary] = Scout.encounter_data(number,faction)
			var expected: int = 0
			for wave in range(1,11): expected += Model.Campaign.schedule(wave,Catalogue.definition(number).get("wave_set_id","ford"),Catalogue.wave_reinforcements(number,faction)).size()
			var counted: int = 0
			for entry in scout: counted += int(entry.total)
			check(counted == expected,"Faction %d, mission %d : la reconnaissance compte les renforts" % [faction,number])
	check(Catalogue.wave_reinforcements(1,0).is_empty() and Catalogue.wave_reinforcements(1,2).is_empty(),"Pas de renfort hors du tableau ni pour une faction inconnue")
	# Réglages de la v0.252 (fiche `design/Missions_renforts_v0252.md`), plus cinq en v0.256 (Alliance 13, 40, 132 ; Horde 34, 43 ; fiche `design/Missions_renforts_v0256.md`) ; missions 2 et 3 laissées sans renfort.
	check(Catalogue.WAVE_REINFORCEMENTS[0].keys() == [13,16,23,33,39,40,72,79,105,132,173,178,180] and Catalogue.WAVE_REINFORCEMENTS[1].keys() == [11,22,34,38,41,43,44,79,131,175],"Les vingt-trois réglages renforcés (v0.252 et v0.256)")
	for faction in [0,1]:
		for number in [2,3]: check(Catalogue.wave_reinforcements(number,faction).is_empty(),"Faction %d, mission %d : la prise en main reste sans renfort" % [faction,number])
		for number in Catalogue.WAVE_REINFORCEMENTS[faction]:
			var seen: Array = []
			for extra in Catalogue.wave_reinforcements(number,faction):
				check(int(extra[0]) < 10 and int(extra[1]) in [2,4,6],"Faction %d, mission %d : sprinters, maraudeurs ou élites, jamais pendant la vague du boss" % [faction,number])
				check(not int(extra[0]) in seen,"Faction %d, mission %d : un seul renfort par vague" % [faction,number])
				seen.append(int(extra[0]))
	print("WAVE_REINFORCEMENTS_TABLE=",total)

func verify_campaign_launch() -> void:
	for faction in [0,1]:
		if Catalogue.WAVE_REINFORCEMENTS[faction].is_empty(): continue
		var number: int = Catalogue.WAVE_REINFORCEMENTS[faction].keys()[0]
		var game = Main.new();root.add_child(game);game.set_process(false)
		var profile := Profile.new("")
		for previous in range(1,number):
			var id: int = profile.begin_mission(faction,Catalogue.id_for(previous),60,10,100)
			profile.credit_mission(id,faction,10,true)
		game.meta_profile = profile
		game._open_campaign(faction,(number-1)/10+1)
		game.campaign_menu._select((number-1)%10)
		game.campaign_menu._launch()
		check(not game.choosing_faction and game.model.wave_reinforcements == Model.Campaign.normalized_reinforcements(Catalogue.wave_reinforcements(number,faction)),"Faction %d, mission %d : la campagne lance la mission avec ses renforts" % [faction,number])
		game.free()
