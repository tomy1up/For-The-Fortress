extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
const Reference = preload("res://tests/reference_army.gd")
## Longueur mesurée du premier trajet et nombre d'entrées attendus des missions 61 à 70.
const EXPECTED: Dictionary = {
	61:{"map":"volcano_threshold","length":34.0,"routes":1},
	62:{"map":"volcano_flows","length":36.0,"routes":1},
	63:{"map":"volcano_caldera","length":29.0,"routes":2},
	64:{"map":"volcano_vents","length":33.0,"routes":1},
	65:{"map":"volcano_forges","length":28.0,"routes":3},
	66:{"map":"volcano_bridge","length":27.0,"routes":2},
	67:{"map":"volcano_organs","length":31.0,"routes":1},
	68:{"map":"volcano_twin","length":29.0,"routes":2},
	69:{"map":"volcano_road","length":28.0,"routes":3},
	70:{"map":"volcano_core","length":27.0,"routes":3},
}
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run_checks")
func run_checks() -> void:
	var Catalogue = Main.CampaignCatalogue
	check(Catalogue.available_count() == 200 and Catalogue.definition(70).available and Catalogue.definition(90).available and Catalogue.definition(91).available and Catalogue.definition(101).available and Catalogue.definition(111).available and not Catalogue.definition(201).get("available",false) and Catalogue.runtime("campaign.201").is_empty(),"Cent vingt missions jouables, la 201 reste à venir")
	check(Model.valid_enemy_hp_percent(264) and Model.valid_enemy_hp_percent(400) and not Model.valid_enemy_hp_percent(401),"Les PV ennemis montent jusqu'à 400 %")
	for number in range(61,71):
		var definition: Dictionary = Catalogue.definition(number)
		check(definition.available and definition.chapter == 7 and definition.map_id == EXPECTED[number].map and definition.hp_percent == 99+number and definition.po == 60 and definition.xp == 100 and definition.waves == 10,"Mission %d : carte, PV et gains habituels" % number)
		check(not definition.has("wave_set_id") and definition.get("combat_affix",{}) == Catalogue.BIOME_FIRST_CHAPTER_AFFIXES[7] and Catalogue.runtime(definition.id).get("wave_set_id","ford") == "ford","Mission %d : rencontres standard, ni affixe ni nouveau attaquant (nouveauté prévue au chapitre 8)" % number)
		await verify_map(number)
	for number in range(61,71):
		for camp in range(2): await verify_mission(camp,number)
	print("VOLCANIC_CHAPTER_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func verify_map(number: int) -> void:
	var expected: Dictionary = EXPECTED[number]
	var definition: Dictionary = Model.Maps.for_id(expected.map)
	check(Model.Maps.validation_error(definition).is_empty() and definition.decoration == "volcanic" and definition.path_length == expected.length and not definition.has("flooded") and not definition.has("water_areas"),"Mission %d : carte volcanique valide, sans eau, de longueur mesurée" % number)
	var routes: Array = View.routes_for(definition)
	check(routes.size() == expected.routes,"Mission %d : %d entrée(s)" % [number,expected.routes])
	check((expected.routes == 2) == (definition.get("route_pattern") == "alternating_pressure"),"Mission %d : seules les cartes à deux entrées alternent leur pression" % number)
	check(routes.all(func(route):return route.path_points[-1] == Vector2(17,6)),"Mission %d : tous les trajets rejoignent la forteresse" % number)
	check(Model.Maps.from_data(JSON.parse_string(JSON.stringify(Model.Maps.to_data(definition)))) == definition,"Mission %d : la carte survit à la sérialisation" % number)
	check(definition.slots.size() == 6 and definition.slots.all(func(slot):return Rect2(Vector2.ZERO,Vector2(definition.size)).has_point(slot)),"Mission %d : six emplacements sur le plateau" % number)
	for slot in definition.slots:
		for route in routes:
			for index in range(1,route.path_points.size()):
				check(slot.distance_to(Geometry2D.get_closest_point_to_segment(slot,route.path_points[index-1],route.path_points[index])) >= 0.75,"Mission %d : emplacements à distance des chemins" % number)
	var broken: Dictionary = Model.Maps.to_data(definition);broken.flooded = [{"route":"","from":1.0,"to":2.0}]
	check(Model.Maps.from_data(broken).is_empty(),"Mission %d : l'eau est réservée aux marais" % number)
	var model := Model.new(true,definition)
	model.rng.seed = 7
	var view := View.new();view.model = model;root.add_child(view)
	var before: String = JSON.stringify([model.gold,model.fortress_hp,model.rng.state,model.action_history,model.enemies,model.defenders])
	await process_frame;await process_frame
	check(JSON.stringify([model.gold,model.fortress_hp,model.rng.state,model.action_history,model.enemies,model.defenders]) == before,"Mission %d : dessiner la carte ne modifie pas le combat" % number)
	view.free()

func play(model: Model, types: Array) -> void:
	var slots := [3,4,2];model.rng.seed = 7 # Règles de bonus actuelles depuis la v0.235 (douze bonus historiques auparavant)
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
		if model.phase == "bonus": model.choose_bonus(Model.reference_bonus(model.bonus_offer))
		if wave < 10: model.prepare_next_wave()

func verify_mission(camp: int, number: int) -> void:
	var game := Main.new();root.add_child(game);game.set_process(false)
	var profile := Profile.new("");game.meta_profile = profile
	for previous in range(1,number):
		var run: int = profile.begin_mission(camp,Main.CampaignCatalogue.id_for(previous),60,10,100)
		check(profile.credit_mission(run,camp,10,true),"Parcours préalable de la faction préparé par le service normal")
	var first: int = Reference.first_talent(camp,number)
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
	game._open_campaign(camp,7);game.campaign_menu._select(number-61)
	check(not game.campaign_menu.start_button.disabled and game.campaign_menu.mission_detail.text.contains("PV ennemis : %d %%" % Main.CampaignCatalogue.faction_hp_percent(number,camp)) and game.campaign_menu.mission_detail.text.contains("Nouveau : Éruptions"),"Mission %d : fiche avec l'affixe du biome" % number)
	game.campaign_menu._launch()
	var model: Model = game.model
	check(not game.choosing_faction and game.mission_definition.id == Main.CampaignCatalogue.id_for(number) and model.map_definition.id == EXPECTED[number].map and model.wave_set_id == "ford" and model.enemy_hp_percent == Main.CampaignCatalogue.faction_hp_percent(number,model.faction) and model.gold == 150 and model.combat_affix == Main.CampaignCatalogue.BIOME_FIRST_CHAPTER_AFFIXES[7] and model.fortress_hp == model.max_hp and model.routes.size() == (0 if EXPECTED[number].routes == 1 else EXPECTED[number].routes),"Mission %d : démarrage par le parcours normal" % number)
	play(model,Reference.types(camp,number))
	print("VOLCANIC_RESULT=",camp,",",number,",",model.phase,",hp=",model.fortress_hp,",wave=",model.wave)
	check(model.phase == "victory","Mission %d : une composition accessible gagne (faction %d)" % [number,camp])
	var report: Dictionary = _report(model)
	var replay: Dictionary = Replay.verify(report)
	check(replay.ok,"Mission %d : le rapport est rejouable : %s" % [number,str(replay.get("error",""))])
	check(not report.has("wave_set_id") and report.get("combat_affix",{}).get("id","") == "eruptions" and report.map_definition.decoration == "volcanic","Mission %d : le rapport conserve la carte volcanique et les rencontres standard" % number)
	game._sync_meta_rewards(true);game._sync_meta_rewards(true)
	check(profile.campaign_status(camp).completed == number and profile.data.banks[camp].xp == 100*number and profile.data.banks[camp].resource == 60*number,"Mission %d : première victoire créditée une seule fois" % number)
	check(profile.campaign_status(1-camp).completed == 0,"Le parcours adverse est inchangé")
	game._show_run_summary();game._summary_to_campaign()
	if number < 70: check(game.campaign_menu.chapter == 7 and game.campaign_menu.nodes.slice(0,number-60).all(func(node):return node.state == "completed") and game.campaign_menu.nodes[number-60].state == "available","Mission %d : retour sur le chapitre avec la suivante disponible" % number)
	else: check(game.campaign_menu.chapter == 8 and game.campaign_menu.nodes[0].state == "available" and game.campaign_menu.nodes.slice(1).all(func(node):return node.state == "locked"),"La fin du chapitre 7 propose la mission 71 sans la lancer")
	game.free()

## Rapport rejouable : un modèle aux anciennes règles de tirage (douze bonus) porte la version antérieure à la 0.232.
func _report(model) -> Dictionary:
	var report: Dictionary = JSON.parse_string(JSON.stringify(Report.build(model)))
	if not model.rules_v232: report.game_version = "0.231"
	return report
