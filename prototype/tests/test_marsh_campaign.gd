extends SceneTree
const Main = preload("res://scripts/main.gd")
const Model = preload("res://scripts/valley_model.gd")
const View = preload("res://scripts/valley_view.gd")
const Profile = preload("res://scripts/meta_profile.gd")
const Talents = preload("res://scripts/meta_talents_linked.gd")
const Replay = preload("res://tests/report_replay.gd")
const Report = preload("res://scripts/run_report.gd")
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
	var source: Dictionary = Model.Maps.to_data(Model.Maps.for_id("marsh_basins"))
	for invalid in [null,{},[0],[[0,0,1]],[["0",0,1,1]],[[true,0,1,1]],[[0,0,-1,1]],[[0,0,0,1]],[[-1,0,1,1]],[[17,0,2,1]],[[0,0,INF,1]],[[0,0,1,NAN]]]:
		var bad: Dictionary = source.duplicate(true);bad.water_areas = invalid
		check(Model.Maps.from_data(bad).is_empty(),"Bassin mal formé, non fini ou hors plateau refusé")
	var excessive: Dictionary = source.duplicate(true);excessive.water_areas = []
	for index in range(33): excessive.water_areas.append([0,0,1,1])
	check(Model.Maps.from_data(excessive).is_empty(),"Nombre excessif de bassins refusé")
	for number in range(41,52): await verify_terrain(number)
	for case in range(41,51).map(func(number):return [[0,number],[1,number]]).reduce(func(all,pair):return all+pair,[]):
		var camp: int = case[0]
		var mission: int = case[1]
		var game := Main.new();root.add_child(game);game.set_process(false)
		var profile := Profile.new("");game.meta_profile = profile
		game._open_campaign(camp,5)
		game.campaign_menu._select(mission-41)
		check(game.campaign_menu.start_button.disabled,"Les marais exigent la réussite du chapitre précédent")
		for number in range(1,mission):
			var run: int = profile.begin_mission(camp,Main.CampaignCatalogue.id_for(number),60,10,100)
			check(profile.credit_mission(run,camp,10,true),"Parcours préalable de la faction préparé par le service normal")
		var first: int = Reference.first_talent(camp,mission)
		var tree: int = Talents.coordinates(first).x
		for index in [first,first,first,first,first,Talents.index_for(tree,1)]: check(profile.allocate(camp,index),"Rangs initiaux financés par l'XP acquise")
		var priority: Array = [5,7,9,16,18] if mission>41 else []
		priority.append_array(range(21))
		while Talents.spent(profile.data.banks[camp].ranks)<profile.data.banks[camp].points:
			var allocated := false
			for local in priority:
				if profile.allocate(camp,Talents.index_for(tree,local)): allocated = true;break
			check(allocated,"Les vingt points accessibles sont répartis légalement")
			if not allocated: break
		game._open_campaign(camp,5);game.campaign_menu._select(mission-41);game.campaign_menu._launch()
		check(not game.choosing_faction and game.mission_definition.id==Main.CampaignCatalogue.id_for(mission),"La mission des marais démarre par le parcours normal")
		check(game.model.combat_affix.get("id","") == "miasma" and game.affix_label.visible and game.model.enemy_hp_percent == Main.CampaignCatalogue.faction_hp_percent(mission,game.model.faction) and game.model.gold==150 and game.model.fortress_hp==game.model.max_hp,"Nouveau biome sans vent, avec ses paramètres et une forteresse intacte")
		var types: Array = Reference.types(camp,mission)
		play(game.model,types)
		check(game.model.phase=="victory","Une composition accessible gagne dans chaque faction (mission %d, faction %d)" % [mission,camp])
		var replay: Dictionary = Replay.verify(JSON.parse_string(JSON.stringify(Report.build(game.model))))
		check(replay.ok,"Le rapport avec décoration marais est rejouable")
		game._sync_meta_rewards(true);game._sync_meta_rewards(true)
		check(profile.campaign_status(camp).completed==mission and profile.data.banks[camp].xp==100*mission and profile.data.banks[camp].resource==60*mission and profile.data.banks[camp].points==Profile.Experience.points_for_xp(100*mission),"Première victoire créditée une seule fois selon la courbe normale")
		check(profile.campaign_status(1-camp).completed==0,"Le parcours adverse est inchangé")
		game._show_run_summary();game._summary_to_campaign()
		if mission < 50: check(game.campaign_menu.chapter==5 and game.campaign_menu.nodes.slice(0,mission-40).all(func(node):return node.state=="completed") and game.campaign_menu.nodes.slice(mission-40).all(func(node):return node.state in ["available","locked"]),"Retour sur le chapitre sans mission suivante présentée comme réussie")
		else: check(game.campaign_menu.chapter==6 and game.campaign_menu.nodes[0].state=="available" and game.campaign_menu.nodes.slice(1).all(func(node):return node.state=="locked"),"La fin du chapitre 5 propose la mission 51 sans la lancer")
		game.free()
	print("MARSH_CAMPAIGN_TESTS checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func play(model: RefCounted, types: Array) -> void:
	var slots := [3,4,2];model.rng.seed = 7
	check(model.buy(slots[0],types[0]) and model.buy(slots[1],types[1]),"Recrutement initial dans le budget normal")
	for wave in range(1,11):
		if wave==2: model.upgrade(slots[0])
		if wave>=2 and model.defenders[slots[2]].is_empty(): model.buy(slots[2],types[2])
		if wave>=5:
			for slot in slots:
				if not model.defenders[slot].is_empty(): model.upgrade(slot,0 if model.defenders[slot].level==3 else -1)
		check(model.start(),"Vague de marais lancée par les règles normales");model.advance(10000)
		if model.phase=="defeat": break
		if model.phase=="bonus": model.choose_bonus(Model.reference_bonus(model.bonus_offer))
		if wave<10: model.prepare_next_wave()
	var spent := 0
	for action in model.action_history:
		if action.kind in ["buy","upgrade"]: spent += int(action.cost)
	check(model.gold==150+model.total_income-spent and model.gold>=0,"Recrutements et améliorations sont couverts par les revenus normaux")

func verify_terrain(number: int) -> void:
	var definition: Dictionary = Model.Maps.for_id(Main.CampaignCatalogue.definition(number).map_id)
	check(Model.Maps.validation_error(definition).is_empty() and definition.decoration=="marsh" and definition.path_length=={41:29,42:34,43:28,44:30,45:38,46:28,47:28,48:34,49:37,50:28,51:31}[number],"Première carte des marais valide et de longueur mesurée")
	var serialized: Dictionary = Model.Maps.to_data(definition)
	check(Model.Maps.from_data(JSON.parse_string(JSON.stringify(serialized)))==definition,"La nouvelle décoration survit à la sérialisation des cartes et des rapports")
	var routes: Array = View.routes_for(definition)
	for slot in definition.slots:
		for route in routes:
			for index in range(1,route.path_points.size()):
				check(slot.distance_to(Geometry2D.get_closest_point_to_segment(slot,route.path_points[index-1],route.path_points[index]))>=0.75,"Les emplacements restent à distance des chemins")
	for pool in definition.get("water_areas",View.MarshArt.POOLS):
		check(Rect2(Vector2.ZERO,Vector2(definition.size)).encloses(pool),"Les bassins restent dans les limites du plateau")
		for slot in definition.slots: check(not pool.has_point(slot),"Les emplacements de défense restent sur la terre ferme")
		for route in routes:
			for index in range(1,route.path_points.size()): check(not View._segment_in_rect(route.path_points[index-1],route.path_points[index],pool),"Les chemins de combat restent distincts des bassins décoratifs")
	var model := Model.new(true,definition)
	model.rng.seed = 7
	var view := View.new();view.model = model;root.add_child(view)
	var before: String = JSON.stringify([model.gold,model.fortress_hp,model.rng.state,model.action_history,model.enemies,model.defenders])
	await process_frame;await process_frame
	check(JSON.stringify([model.gold,model.fortress_hp,model.rng.state,model.action_history,model.enemies,model.defenders])==before,"Dessiner les marais ne modifie ni combat, économie, historique ni générateur")
	var scenery: Array = view.terrain_details
	var kinds := {}
	for item in scenery:
		kinds[item.kind] = true
		var area: Rect2 = View.scenery_bounds(item)
		for slot in definition.slots: check(not area.intersects(Rect2(View.project(slot)+Vector2(-44,-78),Vector2(88,110))),"Les ruines et la végétation dégagent les silhouettes de défense")
		for route in routes:
			for index in range(1,route.path_points.size()): check(not View._segment_in_rect(View.project(route.path_points[index-1]),View.project(route.path_points[index]),area.grow(20)),"Le décor ne masque pas les attaquants sur les chemins")
	check(scenery.size()>0 and kinds.has("ruin") and kinds.has("reeds"),"Le terrain affiche des ruines et des roseaux")
	check(scenery==View.scenery_for(definition),"Décor déterministe et indépendant du combat")
	print("MARSH_SCENERY=",JSON.stringify({"count":scenery.size(),"kinds":kinds.keys()}))
	view.model = Model.new()
	check(view.terrain_details.is_empty(),"Revenir au Gué efface le décor des marais")
	view.free()
