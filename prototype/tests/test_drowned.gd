extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Drowned = preload("res://scripts/drowned_encounters.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const Scout = preload("res://scripts/mission_scout.gd")
const Reference = preload("res://tests/reference_army.gd")
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	verify_catalogue()
	verify_flood_rules()
	verify_map()
	verify_regeneration()
	verify_timeline()
	for camp in range(2): await verify_campaign(camp)
	print("DROWNED_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func verify_catalogue() -> void:
	var Catalogue = Main.CampaignCatalogue
	var definition: Dictionary = Catalogue.definition(51)
	check(definition.available and definition.map_id == "marsh_stagnant" and definition.wave_set_id == "marsh_drowned" and definition.hp_percent == 150 and definition.po == 60 and definition.xp == 100 and definition.waves == 10,"La mission 51 ouvre le chapitre 6 avec ses rencontres et ses gains habituels")
	check(Catalogue.runtime("campaign.051").wave_set_id == "marsh_drowned" and Catalogue.definition(52).available and Catalogue.definition(61).available and Catalogue.definition(81).available and Catalogue.definition(91).available and Catalogue.definition(101).available and Catalogue.definition(111).available and not Catalogue.definition(201).get("available",false) and Catalogue.runtime("campaign.201").is_empty(),"La mission 91 reste à venir")
	check(not Catalogue.definition(50).has("wave_set_id") and Catalogue.definition(50).get("combat_affix",{}).get("id","") == "miasma","Les missions précédentes gardent l'affixe du biome et n'héritent ni des rencontres ni d'un affixe")
	for faction in range(2):
		var identity: Dictionary = Model.Enemies.for_profile(9,faction)
		check(identity.id == "enemy.neutral.drowned" and identity.name == "Gueule-de-Vase" and identity.origin == "neutral" and identity.profile == 9,"Le Noyé est une faune neutre commune aux deux factions")
		var available: Array[Dictionary] = Model.Enemies.available(faction,"marsh_drowned")
		check(available.size() == 9 and available.any(func(item):return item.id == "enemy.neutral.drowned") and not available.any(func(item):return item.id == "enemy.neutral.turtle"),"Le catalogue des marais contient le Noyé et pas la tortue")
		check(Model.Enemies.available(faction).size() == 8 and not Model.Enemies.available(faction,"ford_banks").any(func(item):return item.profile == 9),"Les autres jeux de rencontres sont inchangés")
		check(Model.Enemies.by_id("enemy.neutral.drowned",faction) == identity,"Le Noyé est retrouvable par identifiant")
		var enemy: Dictionary = Model.make_enemy(0,9,0.0,faction,150)
		check(enemy.hp == 225.0 and enemy.max_hp == 225.0 and enemy.speed == 0.85 and enemy.fortress_damage == 2 and enemy.reward == 8 and enemy.name == "Gueule-de-Vase","Statistiques du Noyé à 150 % de PV")
		check(not Scout.encounter_data(51,faction).is_empty() and Scout.encounter_data(51,faction).any(func(item):return item.type == 9),"L'éclaireur annonce le Noyé")
	check(Model.Enemies.for_profile(19,0).is_empty(),"Un profil inconnu reste refusé")
	var forecast: Dictionary = Model.wave_forecast(2,0,150,"marsh_drowned")
	check(forecast.groups[0].type == 9 and forecast.groups[0].count == 1 and forecast.groups[0].name == "Gueule-de-Vase" and Model.wave_forecast(2,0,150,"inconnu").is_empty(),"La prévision de la vague 2 annonce un Noyé")
	check(Model.valid_enemy_hp_percent(150) and Model.valid_enemy_hp_percent(264) and Model.valid_enemy_hp_percent(400) and not Model.valid_enemy_hp_percent(401),"Les PV ennemis montent jusqu'à 400 %")

func verify_flood_rules() -> void:
	var stretches: Array = [{"route":"","from":2.0,"to":5.0},{"route":"","from":8.0,"to":9.0},{"route":"b","from":0.0,"to":4.0}]
	check(is_equal_approx(Drowned.flooded_length(stretches,"",0.0,10.0),4.0) and is_equal_approx(Drowned.flooded_length(stretches,"",3.0,8.5),2.5) and is_equal_approx(Drowned.flooded_length(stretches,"b",1.0,2.0),1.0),"Longueur sous l'eau calculée par trajet")
	check(Drowned.flooded_length(stretches,"",5.0,8.0) == 0.0 and Drowned.flooded_length(stretches,"x",0.0,10.0) == 0.0 and Drowned.flooded_length([],"",0.0,10.0) == 0.0,"Aucune eau hors des tronçons")
	check(Drowned.in_water(stretches,"",2.0) and not Drowned.in_water(stretches,"",5.0) and Drowned.in_water(stretches,"b",3.9) and not Drowned.in_water(stretches,"c",3.0),"Présence dans l'eau : début inclus, fin exclue")
	check(Drowned.regenerated(stretches,"",100.0,0.5,0.0,10.0) == 100.0*Drowned.REGEN_PER_SECOND*8.0 and Drowned.regenerated(stretches,"",100.0,0.5,6.0,4.0) == 0.0 and Drowned.regenerated(stretches,"",100.0,0.0,0.0,10.0) == 0.0,"Régénération proportionnelle au temps passé dans l'eau")
	var lengths := {"":10.0}
	check(Drowned.stretches_error(stretches.slice(0,2),lengths).is_empty() and Drowned.stretches_error([],lengths).is_empty(),"Tronçons valides acceptés")
	var invalid: Array = [null,"a",{},[1],[{"route":"","from":0.0}],[{"route":1,"from":0.0,"to":1.0}],[{"route":"z","from":0.0,"to":1.0}],[{"route":"","from":-1.0,"to":1.0}],[{"route":"","from":2.0,"to":2.0}],[{"route":"","from":3.0,"to":2.0}],[{"route":"","from":0.0,"to":10.5}],[{"route":"","from":0.0,"to":INF}],[{"route":"","from":NAN,"to":1.0}],[{"route":"","from":"0","to":1.0}],[{"route":"","from":0.0,"to":3.0},{"route":"","from":2.0,"to":4.0}],[{"route":"","from":4.0,"to":5.0},{"route":"","from":0.0,"to":1.0}],[{"route":"","from":0.0,"to":1.0,"extra":1}]]
	for bad in invalid: check(not Drowned.stretches_error(bad,lengths).is_empty(),"Tronçons mal formés, superposés ou hors trajet refusés")
	var many: Array = []
	for index in range(9): many.append({"route":"","from":float(index),"to":float(index)+0.5})
	check(not Drowned.stretches_error(many,lengths).is_empty(),"Nombre excessif de tronçons refusé")

func verify_map() -> void:
	var definition: Dictionary = Model.Maps.for_id("marsh_stagnant")
	check(Model.Maps.validation_error(definition).is_empty() and definition.decoration == "marsh" and definition.path_length == 31.0 and definition.flooded.size() == 2,"Les Eaux Mortes sont une carte valide avec deux tronçons inondés")
	var data: Dictionary = Model.Maps.to_data(definition)
	check(Model.Maps.from_data(JSON.parse_string(JSON.stringify(data))) == definition,"Les tronçons inondés survivent à la sérialisation")
	for bad in [{"route":"main","from":1.0,"to":2.0},{"route":"","from":-1.0,"to":2.0},{"route":"","from":30.0,"to":32.0}]:
		var broken: Dictionary = data.duplicate(true);broken.flooded = [bad]
		check(Model.Maps.from_data(broken).is_empty(),"Une carte aux tronçons invalides est refusée")
	var elsewhere: Dictionary = Model.Maps.for_id("marsh_threshold");elsewhere.flooded = [{"route":"","from":1.0,"to":2.0}]
	check(Model.Maps.validation_error(elsewhere).is_empty(),"Un autre marais accepte des tronçons valides")
	elsewhere.decoration = "none"
	check(not Model.Maps.validation_error(elsewhere).is_empty(),"Les tronçons inondés sont réservés aux marais")
	var two_routes: Dictionary = Model.Maps.for_id("marsh_court");two_routes.flooded = [{"route":"upper","from":0.0,"to":2.0},{"route":"lower","from":0.0,"to":2.0}]
	check(Model.Maps.validation_error(two_routes).is_empty(),"Les tronçons peuvent viser chaque trajet d'une carte à plusieurs entrées")
	two_routes.flooded = [{"route":"","from":0.0,"to":2.0}]
	check(not Model.Maps.validation_error(two_routes).is_empty(),"Sans trajet nommé, une carte à plusieurs entrées refuse le tronçon")
	var lines: Array[PackedVector2Array] = View.flooded_polylines(definition)
	check(lines.size() == 2 and lines.all(func(line):return line.size() >= 5) and View.flooded_polylines(Model.Maps.for_id("marsh_threshold")).is_empty(),"Les tronçons inondés sont tracés sur le chemin")
	var model := Model.new(true,definition)
	var view := View.new();view.model = model;root.add_child(view)
	check(view.terrain_details.size() > 0,"Le terrain des Eaux Mortes est décoré")
	view.free()

func make_model(faction: int = 0) -> Model:
	var model := Model.new(true,Model.Maps.for_id("marsh_stagnant"))
	check(model.configure_wave_set("marsh_drowned") and model.configure_enemy_hp(150) and model.select_faction(faction),"Rencontres et PV ennemis réglés avant le choix de faction")
	return model

func verify_regeneration() -> void:
	var run := func(steps: Array) -> Dictionary:
		var model: Model = make_model()
		var enemy: Dictionary = Model.make_enemy(0,9,0.0,0,150);enemy.hp = 10.0
		model.enemies.append(enemy)
		for time in steps:
			model.elapsed = time;model._update_positions()
		return {"hp":enemy.hp,"distance":enemy.distance}
	var dry: Dictionary = run.call([9.0])
	check(dry.hp == 10.0,"Aucune régénération avant le premier tronçon inondé")
	var jump: Dictionary = run.call([19.0])
	var expected: float = 10.0+225.0*Drowned.REGEN_PER_SECOND*7.0/0.85
	check(absf(jump.hp-expected) < 0.000001,"Régénération exacte sur un tronçon traversé d'un seul pas")
	var fine: Array = []
	for index in range(1,1901): fine.append(index*0.01)
	var stepped: Dictionary = run.call(fine)
	check(absf(stepped.hp-jump.hp) < 0.000001 and stepped.distance == jump.distance,"Même résultat avec des pas de 10 ms")
	var coarse: Dictionary = run.call([3.3,11.0,14.1,19.0])
	check(absf(coarse.hp-jump.hp) < 0.000001,"Même résultat avec des pas irréguliers")
	var beyond: Dictionary = run.call([60.0])
	check(absf(beyond.hp-(10.0+225.0*Drowned.REGEN_PER_SECOND*(7.0+6.0)/0.85)) < 0.000001,"Les deux tronçons rendent des PV, la fin du trajet n'en rend plus")
	var model: Model = make_model()
	var full: Dictionary = Model.make_enemy(0,9,0.0,0,150)
	model.enemies.append(full);model.elapsed = 19.0;model._update_positions()
	check(full.hp == full.max_hp,"Un Noyé indemne ne dépasse jamais ses PV maximum")
	var almost: Dictionary = Model.make_enemy(1,9,0.0,0,150);almost.hp = 224.0
	model.enemies.append(almost);model.elapsed = 40.0;model._update_positions()
	check(almost.hp == almost.max_hp,"La régénération s'arrête aux PV maximum")
	var wolf: Dictionary = Model.make_enemy(2,0,0.0,0,150);wolf.hp = 1.0
	model.enemies.append(wolf);model.elapsed = 60.0;model._update_positions()
	check(wolf.hp == 1.0,"Les autres ennemis ne régénèrent pas dans l'eau")
	var wet: Dictionary = Model.make_enemy(3,9,0.0,0,150);wet.distance = 10.0
	var drier: Dictionary = Model.make_enemy(4,9,0.0,0,150);drier.distance = 17.0
	check(model.enemy_in_water(wet) and not model.enemy_in_water(drier) and not model.enemy_in_water(wolf),"L'état « dans l'eau » suit la position")

func play(model: Model, types: Array) -> void:
	var slots := [3,4,2];model.rng.seed = 7
	check(model.buy(slots[0],types[0]) and model.buy(slots[1],types[1]),"Recrutement initial dans le budget normal")
	for wave in range(1,11):
		if wave == 2: model.upgrade(slots[0])
		if wave >= 2 and model.defenders[slots[2]].is_empty(): model.buy(slots[2],types[2])
		if wave >= 5:
			for slot in slots:
				if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level == 3 else -1)
		check(model.start(),"Vague lancée par les règles normales")
		model.advance(10000)
		if model.phase == "defeat": break
		if model.phase == "bonus": Reference.choose_bonus(model) # choix avisé de la référence (v0.255)
		if wave < 10: model.prepare_next_wave()

func verify_timeline() -> void:
	var finish := func(step: float) -> Dictionary:
		var model: Model = make_model(1);model.rng.seed = 7
		model.buy(3,3);model.buy(4,3);model.buy(2,5)
		model.wave = 4;model.spawn_schedule = Model.Campaign.schedule(4,"marsh_drowned")
		model.start()
		var guard := 0
		while model.active and guard < 200000:
			model.advance(step);guard += 1
		return {"log":model.event_log.duplicate(),"killed":model.killed,"escaped":model.escaped,"gold":model.gold,"hp":model.fortress_hp,"elapsed":model.elapsed}
	var big: Dictionary = finish.call(10000.0)
	var small: Dictionary = finish.call(0.05)
	var odd: Dictionary = finish.call(0.731)
	check(Model.Campaign.schedule(4,"marsh_drowned").any(func(entry):return entry.type == 9) and big.killed > 0 and big.log.size() > 0,"La vague de contrôle contient des Noyés et produit des éliminations")
	check(big.log == small.log and big.killed == small.killed and big.escaped == small.escaped and big.gold == small.gold and big.hp == small.hp,"Chronologie identique avec un grand pas et des pas de 50 ms")
	check(big.log == odd.log and big.killed == odd.killed and big.gold == odd.gold,"Chronologie identique avec des pas irréguliers")

func verify_campaign(camp: int) -> void:
	var game := Main.new();root.add_child(game);game.set_process(false)
	var profile := Profile.new("");game.meta_profile = profile
	game._open_campaign(camp,6)
	game.campaign_menu._select(0)
	check(game.campaign_menu.start_button.disabled and game.campaign_menu.chapter == 6,"Le chapitre 6 exige la réussite des missions précédentes")
	for number in range(1,51):
		var run: int = profile.begin_mission(camp,Main.CampaignCatalogue.id_for(number),60,10,100)
		check(profile.credit_mission(run,camp,10,true),"Parcours préalable de la faction préparé par le service normal")
	var first: int = Reference.first_talent(camp,51)
	var tree: int = Talents.coordinates(first).x
	for index in [first,first,first,first,first,Talents.index_for(tree,1)]: check(profile.allocate(camp,index),"Rangs initiaux financés par l'XP acquise")
	var priority: Array = [5,7,9,16,18]
	priority.append_array(range(21))
	while Talents.spent(profile.data.banks[camp].ranks) < profile.data.banks[camp].points:
		var allocated := false
		for local in priority:
			if profile.allocate(camp,Talents.index_for(tree,local)): allocated = true;break
		check(allocated,"Les points accessibles sont répartis légalement")
		if not allocated: break
	game._open_campaign(camp,6);game.campaign_menu._select(0)
	check(not game.campaign_menu.start_button.disabled and game.campaign_menu.mission_detail.text.contains("Gueule-de-Vase") and game.campaign_menu.mission_detail.tooltip_text.contains("%d %%" % roundi(Drowned.REGEN_PER_SECOND*100.0)),"La fiche de la mission 51 annonce le Noyé")
	game.campaign_menu._launch()
	var model: Model = game.model
	check(not game.choosing_faction and game.mission_definition.id == "campaign.051" and model.map_definition.id == "marsh_stagnant" and model.wave_set_id == "marsh_drowned" and model.enemy_hp_percent == Main.CampaignCatalogue.faction_hp_percent(51,model.faction) and model.gold == 150 and model.combat_affix.get("id","") == "miasma","La mission 51 démarre par le parcours normal avec ses rencontres")
	var forecast: Dictionary = model.forecast_for_routes(2)
	check(not forecast.is_empty() and forecast.groups[0].name == "Gueule-de-Vase","La prévision de la vague 2 annonce le Noyé")
	play(model,Reference.types(camp,51))
	print("DROWNED_RESULT=",camp,",",model.phase,",hp=",model.fortress_hp,",wave=",model.wave)
	check(model.phase == "victory","Une composition accessible gagne dans chaque faction")
	var replay: Dictionary = Replay.verify(JSON.parse_string(JSON.stringify(Report.build(model))))
	check(replay.ok,"Le rapport avec tronçons inondés est rejouable : "+str(replay.get("error","")))
	var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
	check(report.wave_set_id == "marsh_drowned" and report.map_definition.flooded.size() == 2 and report.enemy_catalog.any(func(item):return item.id == "enemy.neutral.drowned"),"Le rapport conserve les rencontres, l'eau et le catalogue")
	var tampered: Dictionary = report.duplicate(true);tampered.map_definition.flooded = []
	check(not Replay.verify(tampered).ok,"Un rapport dont l'eau a été retirée n'est plus rejouable à l'identique")
	game._sync_meta_rewards(true);game._sync_meta_rewards(true)
	check(profile.campaign_status(camp).completed == 51 and profile.data.banks[camp].xp == 5100 and profile.data.banks[camp].resource == 3060,"Première victoire créditée une seule fois")
	check(profile.campaign_status(1-camp).completed == 0,"Le parcours adverse est inchangé")
	game._show_run_summary();game._summary_to_campaign()
	check(game.campaign_menu.chapter == 6 and game.campaign_menu.nodes[0].state == "completed" and game.campaign_menu.nodes[1].state == "available" and game.campaign_menu.nodes.slice(2).all(func(node):return node.state == "locked"),"Retour sur le chapitre 6 avec la mission 52 disponible")
	game.free()
